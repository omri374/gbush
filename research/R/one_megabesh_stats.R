getMaslulSoldidersPerMegabsh <- function(raw){
  megabshim <- raw %>% filter(!is.na(FinishedMaslul)) %>%
    group_by(megabesh) %>% 
    summarize(number = n()) %>% 
    arrange(desc(number)) %>%
    filter(number > 20)# %>%
    #select(megabesh) %>% unlist()
  
  #names(megabshim) <- megabshim
  megabshim
}

statsPerMegabesh <- function(raw, megabeshName,megabeshNum,minSamples=10){
  
  thisMegabeshData <- raw %>% filter(!is.nan(MaarihScores),megabesh==megabeshName)
  
  libaPerGibush <- thisMegabeshData %>% group_by(Date) %>% summarize(Liba = ifelse(Mitam[1] ==0,0,1))
  soldiersPerMonth <- thisMegabeshData %>% group_by(GibushMonth) %>% summarize(len = n())
  augSoldiers <- soldiersPerMonth %>% filter(GibushMonth == 'אוג') %>% select(len) %>% unlist()
  novSoldiers <- soldiersPerMonth %>% filter(GibushMonth == 'נוב') %>% select(len) %>% unlist()
  marchSoldiers <- soldiersPerMonth %>% filter(GibushMonth == 'מרץ') %>% select(len) %>% unlist()

  noOfLiba <- length(which(libaPerGibush$Liba==1))
  noOfNonLiba <- length(which(libaPerGibush$Liba==0))
  
  finishers <- thisMegabeshData %>% filter(FinishedMaslul==T)
  nonFinishers <- thisMegabeshData %>% filter(FinishedMaslul==F)    
  
  ##TODO: add number of gibushim
 # countOfGibushim <- thisMegabeshData %>% group_by(Date) %>% summarize(nc = n()) %>% nrow()
  
  print(paste0('Finishers = ',nrow(finishers),'. avg score =',mean(finishers$AvgScore)))
  print(paste0('Non Finishers = ',nrow(nonFinishers),'. avg score =',mean(nonFinishers$AvgScore)))
  
  testResults <- NULL
  
  if(nrow(finishers) > minSamples && nrow(nonFinishers) > minSamples){
    testResults <- connectionBetweenScoreAndFinish(finishersScores = finishers$MaarihScores,nonFinisherScores = nonFinishers$MaarihScores,header = megabeshName,printMe = T)
    
    
  } else{
    print('Not enough data for this megabesh')
  }
  THRESHOLD = 4
  
  hitMiss <- hitMissStats(thisMegabeshData,estimator = 'UnitSuitability')
  
  
  megabeshStats = data.frame(megabesh = megabeshName,
                             megabeshId = megabeshNum,
                             noOfFinishers = nrow(finishers),
                             noOfGibushim = length(unique(thisMegabeshData$Date)),
                             noOfLiba = ifelse(length(noOfLiba)>0,noOfLiba,0),
                             noOfNonLiba = ifelse(length(noOfNonLiba)>0,noOfNonLiba,0),
                             augSoldiers = ifelse(length(augSoldiers)>0,augSoldiers,0),
                             novSoldiers = ifelse(length(novSoldiers)>0,novSoldiers,0),
                             marchSoldiers = ifelse(length(marchSoldiers)>0,marchSoldiers,0),
                             avgFinishers = mean(finishers$AvgScore),
                             noOfNonFinishers = nrow(nonFinishers),
                             avgNonFinishers = mean(nonFinishers$AvgScore),
                             pvalue = ifelse(!is.null(testResults),testResults$p.value,NA)
                             )
  
  megabeshStats <- cbind(megabeshStats,hitMiss)
  
  megabeshStats
  
}


traitsPerMegabesh <- function(raw,megabeshName){
  thisMegabeshData <- raw %>% filter(!is.nan(MaarihScores),megabesh==megabeshName)
  traitsDistributionPlot(thisMegabeshData)
  everyones <- traitsPlot(raw)
  megabesh <- traitsPlot(thisMegabeshData,title = megabeshName)
  
  return(multiplot(megabesh,everyones))
}