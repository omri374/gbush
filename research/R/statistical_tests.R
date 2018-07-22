library(dplyr)
library(ggplot2)
library(GGally)

####--- Test the significance of traits vs. finished/not ---- ####
connectionBetweenScoreAndFinish <- function(finishersScores,nonFinisherScores,header, testType = 'wilcox', printMe = F){
  if(!is.null(header))
    print(header)
  if(testType =='wilcox')
    testResult <- wilcox.test(
      x = finishersScores,
      y = nonFinisherScores,
      alternative = 'greater',
      conf.int = T,
      paired = F
    ) else{
      testResult <- t.test(
        x = finishersScores,
        y = nonFinisherScores,
        alternative = 'greater',
        paired = F
      )
    }
  if(printMe)
    print(testResult)
  return(testResult)
}

####---- Test the relations of factors to finish ---- #####
##' Example: toModel <- scoresDF %>% select(Baror,Sociometric,AvgScore,FinishedFactor,GibushMonth,Mitam,GibushMonth) %>% mutate(label = ifelse(FinishedFactor=="TRUE","Yes","No"))
##' featureImportanceForFinishPrediction(toModel)
featureImportanceForFinishPrediction <- function(datasetForModel,  f = as.formula(label ~ .)){
  #library(caret)
  
  ctrl <- caret::trainControl(method = "repeatedcv", number = 4, savePredictions = TRUE,classProbs = T, summaryFunction = caret::twoClassSummary)
  
  
  toModel <- datasetForModel %>% mutate(label = ifelse(FinishedFactor=="TRUE","Yes","No"))
  toModel$FinishedFactor <- NULL
  toModel <- data.frame(toModel)
  

  
  train <- caret::createDataPartition(toModel$label, p=0.7, list=FALSE)
  training <- toModel[ train, ]
  testing <- toModel[ -train, ]
  garbage <- capture.output(
    mod_fit <- caret::train(form = f,data=toModel, method='gbm', metric = "ROC",trControl = ctrl)
  )
  mod_fit$results
  summary(mod_fit)
  pred <- predict(mod_fit, newdata=testing,type = "prob")
  varImp(mod_fit,scale = T)
  
  roc_imp <- filterVarImp(x=training[,-ncol(training)],y=as.factor(training$label))
  
  print(summary(mod_fit))
  
  testing$pred <- pred$Yes
  testing$lab <- with(testing,ifelse(label=="Yes",1,0))
  testing$FinishedFactor <- as.factor(testing$label)
  print(plotDensityByFinishers(scoresDF = testing,param_name = 'pred'))
  
  library(precrec)
  sscurves <- evalmod(scores = testing$pred, labels = testing$lab)
  autoplot(sscurves)
  aucs <- auc(sscurves)
  print(knitr::kable(aucs))
    
}
####---- Spearman test between traits and average score ----####
##' Example: connectionBetweenTraitAndAvgScore(perSoldier)
connectionBetweenTraitAndAvgScore <- function(datasetWithTraits){
  traits <- datasetWithTraits %>% select(PhysicalSkills,TeamSkills,PressureSkills,CognitiveSkills,CommanderSkills,MotivationSkills,UnitSuitability)
  score <- datasetWithTraits$AvgScore
  
  spearmanCorr <- sapply(traits,function(x){
    missing <- is.na(x)
    x <- x[!missing]
    y <- score[!missing]
    cor(x = x,y = y,method = 'spearman')
  })
  
  print(spearmanCorr)
  return(spearmanCorr)
  
}

plotConnectionBetweenTraitsAndMetric <- function(correlation_results,title = ""){
  source(file.path("R","utils.R"))
  correlations <- data.frame(trait = names(correlation_results), val = correlation_results)
  ggplot(data = correlations,aes(x = trait,y = val,fill = trait)) + geom_col() + 
    xlab("תכונה") + ylab("מתאם") + 
    ggtitle(title) #+ 
    #ggtech::theme_tech(theme = 'airbnb')+ theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")
}

connectionBetweenTraitAndUnitSuitability <- function(datasetWithTraits){
  traits <- datasetWithTraits %>% select(PhysicalSkills,TeamSkills,PressureSkills,CognitiveSkills,CommanderSkills,MotivationSkills)
  score <- datasetWithTraits$UnitSuitability
  
  spearmanCorr <- sapply(traits,function(x){
    missing <- is.na(x)
    x <- x[!missing]
    y <- score[!missing]
    cor(x = x,y = y,method = 'spearman')
  })
  
  print(spearmanCorr)
  return(spearmanCorr)
  
}


#####---- HIT/MISS analysis ----#####

hitMissConfusionMatrix <- function(scoresDF, threshold= 4,estimator = 'MaarihScores'){
  
  if(estimator == 'AvgScore'){
    scoresDF$Estimation = scoresDF$AvgScore
  } else if(estimator == 'MaarihScores'){
    scoresDF$Estimation = scoresDF$MaarihScores
  } else if(estimator == 'FinalScore'){
    scoresDF$Estimation = scoresDF$FinalScore
  } else if(estimator == 'UnitSuitability'){
    scoresDF$Estimation = scoresDF$UnitSuitability
  } else if(estimator == 'MiluimScores'){
    scoresDF$Estimation = scoresDF$MiluimScores
  } else if(estimator == 'SadirScores'){
    scoresDF$Estimation = scoresDF$SadirScores
  } else if(estimator == 'Sociometric'){
    scoresDF$Estimation = scoresDF$Sociometric
  }
  
  #hitmiss <- hitMissStats(scoresDF,threshold = threshold,estimator = estimator)
  #mat = matrix(data = c(c(hitmiss$tp,hitmiss$fn),c(hitmiss$fp,hitmiss$tn)),nrow = 2,ncol=2)
  hitMissDF <- scoresDF %>% transmute(FinishedMaslul = FinishedFactor, PassedGibush = Estimation > threshold)
  confusionMatrix = table(hitMissDF)
  #colnames(confusionMatrix) <- c("Finished","DidNotFinish")
  #rownames(confusionMatrix) <- c("AboveThreshold","BelowThreshold")
  confusionMatrix
  #print(confusionMatrix)
}

hitMissStats <- function(scoresDF, threshold = 4, estimator = 'MaarihScores'){
  
  if(!'FinishedFactor' %in% names(scoresDF)){
    scoresDF$FinishedFactor <- as.factor(scoresDF$FinishedMaslul)
  }
  
  prior <- length(which(scoresDF$FinishedFactor == TRUE)) / length(which(!is.na(scoresDF$FinishedFactor)))
  
  if(estimator == 'AvgScore'){
    scoresDF$Estimation = scoresDF$AvgScore
  } else if(estimator == 'MaarihScores'){
    scoresDF$Estimation = scoresDF$MaarihScores
  } else if(estimator == 'FinalScore'){
    scoresDF$Estimation = scoresDF$FinalScore
  } else if(estimator == 'UnitSuitability'){
      scoresDF$Estimation = scoresDF$UnitSuitability
  } else if(estimator == 'MiluimScores'){
    scoresDF$Estimation = scoresDF$MiluimScores
  } else if(estimator == 'SadirScores'){
    scoresDF$Estimation = scoresDF$SadirScores
  } else if(estimator == 'Sociometric'){
    scoresDF$Estimation = scoresDF$Sociometric
  }
  
  
  hitMissDF <- scoresDF %>% filter(!is.na(FinishedFactor)) %>%
    summarize(
      tp = sum(Estimation > threshold & FinishedFactor == T,na.rm = T),
      fp = sum(Estimation > threshold & FinishedFactor == F,na.rm =T ),
      tn = sum(Estimation <= threshold & FinishedFactor == F,na.rm = T),
      fn = sum(Estimation <= threshold & FinishedFactor == T,na.rm = T),
      negatives = fn+tn,
      posities = tp + fp,
      num = n(),
      #num_started = sum(!is.na(FinishedFactor)),
      precision = tp/(tp+fp),
      precisionNot = tn/(tn+fn),
      normalizedPrecision = precision*prior + precisionNot*(1-prior),
      recall = tp/(tp+fn),
      hitVsMiss = (tp+tn)/(fp+fn),
      nonStarts = sum(is.na(FinishedFactor)))
  
  hitMissDF$prior <- prior
  hitMissDF$threshold <- threshold
  hitMissDF$Estimator = estimator
  
  return(hitMissDF)

}

hitmissAnalysis <- function(scoresDF, estimator = 'MaarihScores',range = seq(1,7,0.5)){
  
  hitmiss <- data.frame()
  for(i in range){
    hitmiss <- bind_rows(hitmiss,hitMissStats(scoresDF,threshold = i,estimator = estimator))
  }
  
  return(hitmiss)
  
}

traitsDistributionPlot <- function(raw){
  library(ggplot2)
  library(GGally)
  
  scoresForTraits = raw %>% 
    select(
      TeamSkills,PhysicalSkills,PressureSkills,CognitiveSkills,CommanderSkills,MotivationSkills,UnitSuitability,
      Finished = FinishedMaslul) %>% 
    mutate(
      FinishedFactor = as.factor(Finished)) %>% filter(!is.na(Finished))
  
  scoresForTraits$Finished <- NULL
  
  ggtraits <- ggpairs(scoresForTraits, aes(colour = FinishedFactor, alpha = 0.4), lower=list(combo=wrap("facethist", bins=10)))
  #print(ggtraits)
  ggtraits
}

traitsPlot <- function(raw,title = 'ALL'){

  scoresForPlot <- raw %>% mutate(FinishedMaslul  = as.factor(FinishedMaslul)) %>%
    select(PhysicalSkills,UnitSuitability,TeamSkills,PressureSkills,MotivationSkills,CognitiveSkills,CommanderSkills)#,FinishedMaslul)
  melted <- reshape2::melt(scoresForPlot) %>% filter(!is.na(value))
  melted$variable <- gsub(pattern = "Skills",replacement = "",x = melted$variable)
  ggplot(melted, aes(x=as.factor(value))) + #,fill = FinishedMaslul))  +
    geom_bar(aes(fill = as.factor(variable))) + 
    #geom_bar() + 
    facet_grid(variable~.) +xlab("") +ggtitle(title)# + ggtech::theme_tech(theme="airbnb")
}






# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
  
  plots
}

## Per mitam test
perMitamTest <- function(finishers,nonFinishers, metric = 'FinalScore'){
  nonLiba <- 0
  liba <- c(1,2)
  nonLibaFinishers <- finishers %>% filter(as.numeric(as.character(Mitam)) < 2)
  nonLibaNonFinishers <- nonFinishers %>% filter(as.numeric(as.character(Mitam)) < 2)

  if(metric == 'FinalScore'){
    testResultNL <- connectionBetweenScoreAndFinish(nonLibaFinishers$FinalScore,nonLibaNonFinishers$FinalScore,' Per liba test on final score')
  } else if(metric == 'AvgScore'){
    testResultNL <- connectionBetweenScoreAndFinish(nonLibaFinishers$AvgScore,nonLibaNonFinishers$AvgScore,' Per liba test on Maarihim score')
  } else if(metric == 'Sociometric'){
    testResultNL <- connectionBetweenScoreAndFinish(nonLibaFinishers$Sociometric,nonLibaNonFinishers$Sociometric,' Per liba test on Sociometric score')
  } else if(metric == 'SadirScores'){
    testResultNL <- connectionBetweenScoreAndFinish(nonLibaFinishers$SadirScores,nonLibaNonFinishers$SadirScores,' Per liba test on Sadir score')
  } else if(metric == 'MiluimScores'){
    testResultNL <- connectionBetweenScoreAndFinish(nonLibaFinishers$MiluimScores,nonLibaNonFinishers$MiluimScores,' Per liba test on Miluim score')
  }
  
  print("Non-Liba")
  print(testResultNL)
  
  libaFinishers <- finishers %>% filter(as.numeric(as.character(Mitam)) > 1)
  libaNonFinishers <- nonFinishers %>% filter(as.numeric(as.character(Mitam)) > 1)
  #testResultL <- connectionBetweenScoreAndFinish(libaFinishers$FinalScore,libaNonFinishers$FinalScore,' Per mitam test on final score')
  
  if(metric == 'FinalScore'){
    testResultL <- connectionBetweenScoreAndFinish(libaFinishers$FinalScore,libaNonFinishers$FinalScore,' Per liba test on final score')
  } else if(metric == 'AvgScore'){
    testResultL <- connectionBetweenScoreAndFinish(libaFinishers$AvgScore,libaNonFinishers$AvgScore,' Per liba test on Maarihim score')
  } else if(metric == 'Sociometric'){
    testResultL <- connectionBetweenScoreAndFinish(libaFinishers$Sociometric,libaNonFinishers$Sociometric,' Per liba test on Sociometric score')
  } else if(metric == 'SadirScores'){
    testResultL <- connectionBetweenScoreAndFinish(libaFinishers$SadirScores,libaNonFinishers$SadirScores,' Per liba test on Sadir score')
  } else if(metric == 'MiluimScores'){
    testResultL <- connectionBetweenScoreAndFinish(libaFinishers$MiluimScores,libaNonFinishers$MiluimScores,' Per liba test on Miluim score')
  }
  
  print("Liba")
  print(testResultL)
  
}

## Per month test
perMonthTest <- function(finishers,nonFinishers, metric = 'FinalScore'){
  months <- unique(finishers$GibushMonth)
  for(month in months){
    monthFinishers <- finishers %>% filter(GibushMonth == month)
    monthNonFinishers <- nonFinishers %>% filter(GibushMonth == month)
    if(metric == 'FinalScore'){
      testResult <- connectionBetweenScoreAndFinish(monthFinishers$FinalScore,monthNonFinishers$FinalScore,' Per month test on final score')
    } else if(metric == 'AvgScore'){
      testResult <- connectionBetweenScoreAndFinish(monthFinishers$AvgScore,monthNonFinishers$AvgScore,' Per month test on Maarihim score')
    } else if(metric == 'Sociometric'){
      testResult <- connectionBetweenScoreAndFinish(monthFinishers$Sociometric,monthNonFinishers$Sociometric,' Per month test on Sociometric score')
    } else if(metric == 'SadirScores'){
      testResult <- connectionBetweenScoreAndFinish(monthFinishers$SadirScores,monthNonFinishers$SadirScores,' Per month test on Sadir score')
    } else if(metric == 'MiluimScores'){
      testResult <- connectionBetweenScoreAndFinish(monthFinishers$MiluimScores,monthNonFinishers$MiluimScores,' Per month test on Miluim score')
    }
    print(paste("Month:",month))
    print(testResult)
  }
}


## Per month and liba test
perMonthAndLibaTest <- function(scoresDF){

  scoresForAnalysis <- scoresDF
  
  scoresForAnalysis$Liba <- ifelse(as.numeric(as.character(scoresForAnalysis$Mitam)) > 1,TRUE,FALSE)
  scoresForAnalysis$LibaMonthGroup <- paste0(scoresForAnalysis$GibushMonth,scoresForAnalysis$Liba,"-")
  
  for(grp in unique(scoresForAnalysis$LibaMonthGroup)){
    
    
    grpFinishers <- scoresForAnalysis %>% filter(LibaMonthGroup == grp & FinishedFactor==TRUE)
    grpNonFinishers <- scoresForAnalysis %>% filter(LibaMonthGroup == grp & FinishedFactor==FALSE)
    
    cat(nrow(grpFinishers)," finishers and",nrow(grpNonFinishers),"non finishers." )
    
    testResult <- connectionBetweenScoreAndFinish(grpFinishers$FinalScore,grpNonFinishers$FinalScore,' Per month test on final score')
    
    print(paste("Group:",grp))
    print(testResult)
    cat("\n\n *********** \n\n\n")
  }
}

## Correlations
getCorrelationMartix <- function(scoresDF){
  toModel3 <- scoresDF %>% select(CommanderSkills,
                                  PhysicalSkills,
                                  PressureSkills,
                                  MotivationSkills,
                                  CognitiveSkills,
                                  UnitSuitability,
                                  Sociometric,
                                  #Baror,
                                  AvgScore)
  toModel3 <- toModel3[complete.cases(toModel3),]
  
  # Get lower triangle of the correlation matrix
  get_lower_tri<-function(cormat){
    cormat[upper.tri(cormat)] <- NA
    return(cormat)
  }
  # Get upper triangle of the correlation matrix
  get_upper_tri <- function(cormat){
    cormat[lower.tri(cormat)]<- NA
    return(cormat)
  }
  
  cormat <- round(cor(toModel3),2)
  upper_tri <- get_upper_tri(cormat)
  
  melted_cormat <- reshape2::melt(upper_tri, na.rm = TRUE)
  ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
    geom_tile(color = "white")+
    scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                         midpoint = 0, limit = c(0,1), space = "Lab", 
                         name="Correlation") +
    theme_minimal()+ 
    theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                     size = 12, hjust = 1))+
    coord_fixed()
  
}

### Final score new calculation
logisticRegressionFinalScore <- function(scoresDF){
  
}