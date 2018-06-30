# Set locale to support Hebrew
Sys.setlocale(category = "LC_ALL", locale = "Hebrew_Israel.1255")


#library(plyr)
#library(caret)
library(dplyr)
library(ggplot2)

source("R/utils.R", encoding = 'WINDOWS-1252')
source("R/GibushStatTests.R", encoding = 'UTF-8')


###--- create raw data ---###

xls1 <- readExcel('data/data-excel.xlsx')
xls2 <- readExcel('data/2018.xlsx')
#xls <- bind_rows(xls1,xls2)
xls <- xls1
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

perMonth <- perMonthStats(perSoldierWithMedical)
knitr::kable(perMonth)

scoresDF <- getScores(perSoldier)
scoresDFWithMedical <- getScores(perSoldierWithMedical)
#getScoresPlot(scoresDF) ## SLOW

finisherScores <- scoresDF %>% filter(FinishedFactor ==TRUE)
nonFinisherScores <- scoresDF %>% filter(FinishedFactor == FALSE)

##Sociometric
plotHistogramByFinishers(scoresDF,param_name = 'Sociometric')
connectionBetweenScoreAndFinish(finishersScores = finisherScores$Sociometric,nonFinisherScores = nonFinisherScores$Sociometric,header = 'Sociometric')

##Baror
plotHistogramByFinishers(scoresDF,param_name = 'Baror')
connectionBetweenScoreAndFinish(
  finishersScores = finisherScores$Baror,
  nonFinisherScores = nonFinisherScores$Baror,
  header = 'Baror')

#AvgScore
plotHistogramByFinishers(scoresDF,param_name = 'AvgScore')
connectionBetweenScoreAndFinish(
  finishersScores = finisherScores$AvgScore,
  nonFinisherScores = nonFinisherScores$AvgScore,
  header = 'AvgScore')

#FinalScore
plotHistogramByFinishers(scoresDF,param_name = 'FinalScore')
connectionBetweenScoreAndFinish(
  finishersScores = finisherScores$FinalScore,
  nonFinisherScores = nonFinisherScores$FinalScore,
  header = 'FinalScore')


#Per month
perMonthTest(finisherScores,nonFinisherScores)
# plotHistogramByFinishers(scoresDF %>% filter(GibushMonth=='אוג'),param_name = 'AvgScore','אוג')
# plotHistogramByFinishers(scoresDF %>% filter(GibushMonth=='נוב'),param_name = 'AvgScore','נוב')
# plotHistogramByFinishers(scoresDF %>% filter(GibushMonth=='מרץ'),param_name = 'AvgScore','מרץ')

plotHistogramByFinishersPerMonth(scoresDF,param_name = 'AvgScore')

#per mitam
perMitamTest(finisherScores,nonFinisherScores)

#Mitam 0 plot
plotHistogramByFinishers(scoresDF %>% filter(as.numeric(as.character(Mitam))==0),param_name='AvgScore','מתאם 0')
#Mitam 1,2 plot
plotHistogramByFinishers(scoresDF %>% filter(as.numeric(as.character(Mitam))>0),param_name='AvgScore', 'מתאם > 0')


## Attribute importance
toModel <- scoresDF %>% select(Baror,Sociometric,AvgScore,FinishedFactor) %>% mutate(label = ifelse(FinishedFactor==TRUE,"Yes","No"))
featureImportanceForFinishPrediction(toModel)

toModel2 <- scoresDF %>% select(CommanderSkills,PhysicalSkills,PressureSkills,MotivationSkills,CognitiveSkills,TeamSkills,FinishedFactor) %>% mutate(label = ifelse(FinishedFactor==TRUE,"Yes","No"))
toModel2 <- toModel2[complete.cases(toModel2),]
featureImportanceForFinishPrediction(toModel2)


getScoresPlot(toModel2 %>% select(-label))

connectionBetweenScoreAndFinish(
  finishersScores = finisherScores$CommanderSkills,
  nonFinisherScores = nonFinisherScores$CommanderSkills,
  header = 'CommanderSkills')

getCorrelationMartix(scoresDF)

## Traits plots
plotHistogramByFinishers(scoresDF,param_name = 'PhysicalSkills')


## Connection between traits and score
avgScoreCorreation <- connectionBetweenTraitAndAvgScore(scoresDF)
plotConnectionBetweenTraitsAndMetric(avgScoreCorreation, 'מתאם בין תכונות לציון מעריכים ממוצע')


unitSuitabilityCorrelation <- connectionBetweenTraitAndUnitSuitability(scoresDF)
plotConnectionBetweenTraitsAndMetric(unitSuitabilityCorrelation, 'מתאם בין תכונות לציון התאמה ליחידה')

## hit /miss

hitmiss <- hitMissStats(scoresDF,threshold = 4)

hitmissAnalysis <- hitmissAnalysis(scoresDF)

## PR curve
library(PRROC)
prcurve <- pr.curve(finisherScores$FinalScore,nonFinisherScores$FinalScore,curve = T)
plot(prcurve,main = 'PR Curve for final scores')

prcurve_avg <- pr.curve(finisherScores$AvgScore,nonFinisherScores$FinalScore,curve = T)
plot(prcurve_avg,main = 'PR Curve for average scores')



## per maarih
source("R/OneMegabeshStats.R")
relevantMegabshim <- raw %>% filter(!is.na(FinishedMaslul)) %>%
  group_by(megabesh) %>% 
  summarize(number = n()) %>% 
  filter(number > 25) %>%
  select(megabesh) %>% unlist()

names(relevantMegabshim) <- NULL

hitMissMegabeshim <- data.frame()
num = 1
for(maarih in relevantMegabshim){
  maarih <- as.character(maarih)
  thisMegabeshData <- raw %>% filter(!is.nan(MaarihScores),megabesh==megabeshName) %>% mutate(FinishedFactor = as.factor(FinishedMaslul))
  traits <- traitsPlot(thisMegabeshData,title = paste("Traits for maarih",maarih))
  ggsave(paste0('output/plots/',num,'-traits_distribution.pdf'),plot = traits)

  hm <- statsPerMegabesh(raw = raw,megabeshName = maarih, megabeshNum = num)
  hitMissMegabeshim <- bind_rows(hitMissMegabeshim,hm)
  histPlot <- plotHistogramByFinishers(thisMegabeshData,param_name = 'UnitSuitability')
  histPlot <- histPlot + ggtitle(paste0('Maarih',num))
  ggsave(paste0('output/plots/',num,'-scores.pdf'),plot=histPlot)
  
  ##TODO: add spearman between traits and midat hatama
  traitsSpearman <- connectionBetweenTraitAndUnitSuitability(thisMegabeshData)
  traitsSpearman <- data.frame(trait = names(traitsSpearman),val = traitsSpearman)
  traitsCoorPlot <- ggplot(traitsSpearman,aes(x = traitsSpearman$trait,y = traitsSpearman$val)) + geom_col() + xlab('trait') + ylab('spearman correlation') + ggtitle('Spearman between megabesh traits and megash unit suitability')
  ggsave(paste0('output/plots/',num,'-traits_corrrelations.pdf'),plot=traitsCoorPlot)
  
  num <- num+1
  
}

write.csv("output/megabshim.csv",x = hitMissMegabeshim)
