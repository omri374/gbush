# Set locale to support Hebrew
Sys.setlocale(category = "LC_ALL", locale = "Hebrew_Israel.1255")


library(dplyr)
library(ggplot2)
library(pROC)
source("R/utils.R")#, encoding = 'WINDOWS-1255')
source("R/statistical_tests.R")#, encoding = 'WINDOWS-1255')


###--- create raw data ---###

xls <- readExcel('data/data-excel.xlsx')
cat('length of input data = ',nrow(xls))
xls <- xls %>% distinct()
cat('length of input data after removing duplications = ',nrow(xls))


###-----------------------###



rawWithMedical <- parseRawData(xls, exclude_medical = FALSE)
raw <- parseRawData(xls, exclude_medical = TRUE)

perSoldierWithMedical <- getDataPerSoldier(rawWithMedical)
perSoldier <- getDataPerSoldier(raw)


perGibushWithMedical <- getDataPerGibush(perSoldierWithMedical)
perGibush <- getDataPerGibush(perSoldier)
knitr::kable(perGibush)
printDescriptiveStats(perSoldierWithMedical,perGibushWithMedical)

perMonth <- perMonthStats(perSoldierWithMedical,perGibushWithMedical)
knitr::kable(perMonth)

scoresDF <- getScores(perSoldier)

####----------------------------- grid search -----------------------####


params = list(
  liba = c(T,F)#,  month = c("Aug","Nov","Mar")
)

grid <- expand.grid(params,stringsAsFactors = F) 

weights <- expand.grid(seq(0,1,0.05),
                       seq(0,1,0.05),
                       seq(0,1,0.05))

weights <- weights[rowSums(weights)==1,]
names(weights) <- c("Baror","Sociometric","AvgScore")

get_metrics <- function(scores, baror_weight, socio_weight, grade_weight, threshold = 70){
  
  
  prior <- length(which(scores$FinishedFactor == TRUE)) / length(which(!is.na(scores$FinishedFactor)))
  #print(prior)
  
  hitMissDF <- scores %>% filter(!is.na(FinishedFactor)) %>%
    mutate(Estimation = Baror * baror_weight + Sociometric*socio_weight + ((AvgScore - 1)*100/6.0)*grade_weight) %>%
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
      normalizedPrecision = precision*(1-prior) + precisionNot*(prior),
      recall = tp/(tp+fn),
      hitVsMiss = (tp+tn)/(fp+fn),
      nonStarts = sum(is.na(FinishedFactor)))
  
  hitMissDF
}

metric_values <- matrix(nrow = nrow(weights), ncol = nrow(grid))
rownames(metric_values) <- Reduce(paste,weights)
colnames(metric_values) <- Reduce(paste,grid)


for(gr in 1:nrow(grid)){
  liba = grid[gr,'liba']
  if(is.null(grid$month)){
    scores <- scoresDF %>% filter(Liba == liba)  %>% select(Baror,Sociometric,AvgScore,FinishedFactor)
    
  } else{
    month = grid[gr,'month']
    scores <- scoresDF %>% filter(Liba == liba & GibushMonth == month)  %>% select(Baror,Sociometric,AvgScore,FinishedFactor)
  }
  
  for (w in 1:nrow(weights)){
    #print(w)
    #final_score <- scores$Baror * weights[w,1] + scores$Sociometric*weights[w,2] + ((scores$AvgScore - 1)*100/6.0)*weights[w,3]
    #area <- pROC::auc(scores$FinishedFactor,final_score)
    #area <- with(scores,length(which(final_score > 70 & scores$FinishedFactor==T)
    metrics <- get_metrics(scores,baror_weight = weights[w,1],socio_weight = weights[w,2],grade_weight = weights[w,3],threshold = 70)
    metric <- unlist(metrics$normalizedPrecision)
    #names(metric) <- Reduce(paste,w)
    #print(metric)
    metric_values[w,gr] <- metric
  }
  
  cat(paste0("Liba = ",liba,",Month = ",month," Max metric value = ",max(metric_values),", Weights = ",Reduce(paste,weights[which.max(metric_values),])))
  cat("\n")
}

