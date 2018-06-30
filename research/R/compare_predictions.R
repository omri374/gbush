## ROC comparison of current and model prediction

library(precrec)
library(ggplot2)
sscurves <- evalmod(scores = scoresDF$FinalScore, labels = scoresDF$FinishedFactor)
autoplot(sscurves)
aucs <- auc(sscurves)
print(knitr::kable(aucs))


predictionPlot <- function(scoresDF,group_name = 'ALL', estimator = 'AvgScore'){
  source("R/GibushStatTests.R")
  
  
  precDFTotal <- data.frame(thresh = as.numeric(NA),
                            precision = as.numeric(NA),
                            precisionNot = as.numeric(NA),
                            numSoldiersAbove = as.numeric(NA),
                            numSoldiersBelow = as.numeric(NA))
  
  ## General precision plot
  
  num = 1
  for(i in seq(1,7,1)){
    precDFTotal[num,'thresh'] = i
    x <- hitMissStats(scoresDF,i,estimator = estimator)
    precDFTotal[num,'precision'] <- x$precision
    precDFTotal[num,'recall'] <- x$recall
    precDFTotal[num,'precisionNot'] <- x$precisionNot
    precDFTotal[num,'numSoldiersAbove'] <- scoresDF %>% filter_(paste(estimator ,">= i")) %>% nrow()
    precDFTotal[num,'numSoldiersBelow'] <- scoresDF %>% filter_(paste(estimator ,"< i")) %>% nrow()
    num = num + 1
  }
  
  prec = qplot(precDFTotal$thresh,precDFTotal$precision,xlab = estimator,ylab = 'Precision = TP/(TP+FP)',main = paste('Precision for a specific threshold (',group_name,')'),geom = 'line') + geom_point()+ scale_y_continuous(breaks = seq(0,1,0.1))+ scale_x_continuous(breaks = seq(0,7,1))
  rec = qplot(precDFTotal$thresh,precDFTotal$recall,xlab = estimator,ylab = 'Recall = TP/(TP+FN)',main = paste('Recall for a specific threshold (',group_name,')'),geom = 'line') + geom_point() + scale_y_continuous(breaks = seq(0,1,0.1))+ scale_x_continuous(breaks = seq(0,7,1))
  precnot = qplot(precDFTotal$thresh,precDFTotal$precisionNot,xlab = estimator,ylab = 'Precision for rejection = TN/(TN+FN)',main = paste('Precision for rejection (',group_name,')'),geom = 'line') + geom_point() + scale_y_continuous(breaks = seq(0,1,0.1)) + scale_x_continuous(breaks = seq(0,7,1))
  numOfSoldiersAbove = qplot(precDFTotal$thresh,precDFTotal$numSoldiersAbove,xlab = estimator,ylab = 'Number of soldiers with score >= threshold',main = paste('Number of soldiers >= threshold (',group_name,')'),geom = 'line') + geom_point()  + scale_y_continuous(breaks = seq(0,nrow(scoresDF),25)) + scale_x_continuous(breaks = seq(0,7,1))#+ scale_x_continuous(breaks = seq(0,100,3))
  numOfSoldiersBelow = qplot(precDFTotal$thresh,precDFTotal$numSoldiersBelow,xlab = estimator,ylab = 'Number of soldiers with score < threshold',main = paste('Number of soldiers < threshold (',group_name,')'),geom = 'line') + geom_point()  + scale_y_continuous(breaks = seq(0,nrow(scoresDF),25)) + scale_x_continuous(breaks = seq(0,7,1))#+ scale_x_continuous(breaks = seq(0,100,3))
  
  library(gridExtra)
  
  p1 <- grid.arrange(prec,rec,precnot)
  p2 <- grid.arrange(numOfSoldiersAbove,numOfSoldiersBelow)
  
  
  return(list(p1,p2))
}


## General precision plot
a1 <- predictionPlot(scoresDF)

## Liba precision plot
a2 <- predictionPlot(scoresDF %>% filter(Liba == TRUE),'Liba')


## Non-Liba precision plot
a3 <- predictionPlot(scoresDF %>% filter(Liba == FALSE),'Non-Liba')


grid.arrange(a1[[1]],a1[[2]],a2[[1]],a2[[2]],a3[[1]],a3[[2]])
