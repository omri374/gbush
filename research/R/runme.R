# Set locale to support Hebrew
Sys.setlocale(category = "LC_ALL", locale = "Hebrew_Israel.1255")


#library(plyr)
#library(caret)
library(dplyr)
library(ggplot2)
library(readxl)
source("R/utils.R")#, encoding = 'WINDOWS-1255')
source("R/statistical_tests.R")#, encoding = 'WINDOWS-1255')


###--- create raw data ---###

xls <- readExcel('../data/data-excel-english-names.xlsx')
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
scoresDFWithMedical <- getScores(perSoldierWithMedical)
#getScoresPlot(scoresDF) ## SLOW

finisherScores <- scoresDF %>% filter(FinishedFactor ==TRUE)
nonFinisherScores <- scoresDF %>% filter(FinishedFactor == FALSE)

finisherScoresWMedical <- scoresDFWithMedical %>% filter(FinishedFactor ==TRUE)
nonFinisherScoresWMedical <- scoresDFWithMedical %>% filter(FinishedFactor == FALSE)


plotLeavingReason(raw)


##Sociometric
sociometric <- plotHistogramByFinishers(scoresDF,param_name = 'Sociometric')
ggsave("out/Sociometric.png",plot = sociometric,width = 300,height = 150,units = "mm")
connectionBetweenScoreAndFinish(finishersScores = finisherScores$Sociometric,nonFinisherScores = nonFinisherScores$Sociometric,header = 'Sociometric')

sociomedical <- plotHistogramByFinishers(scoresDFWithMedical,param_name = 'Sociometric')
ggsave("out/Sociometric_with_medical.png",plot = sociomedical,width = 300,height = 150,units = "mm")

connectionBetweenScoreAndFinish(finishersScores = finisherScoresWMedical$Sociometric,nonFinisherScores = nonFinisherScoresWMedical$Sociometric,header = 'Sociometric')


##Baror
baror <- plotHistogramByFinishers(scoresDF,param_name = 'Baror')
ggsave("out/Baror.png",plot = baror,width = 300,height = 150,units = "mm")

connectionBetweenScoreAndFinish(
  finishersScores = finisherScores$Baror,
  nonFinisherScores = nonFinisherScores$Baror,
  header = 'Baror')

#with medical
connectionBetweenScoreAndFinish(
  finishersScores = finisherScoresWMedical$Baror,
  nonFinisherScores = nonFinisherScoresWMedical$Baror,
  header = 'Baror')

#AvgScore
avgscore <- plotHistogramByFinishers(scoresDF,param_name = 'AvgScore')
connectionBetweenScoreAndFinish(
  finishersScores = finisherScores$AvgScore,
  nonFinisherScores = nonFinisherScores$AvgScore,
  header = 'AvgScore')
ggsave("out/AvgScore.png",plot = avgscore,width = 300,height = 150,units = "mm")

#FinalScore
finalscore <- plotHistogramByFinishers(scoresDF,param_name = 'FinalScore')
connectionBetweenScoreAndFinish(
  finishersScores = finisherScores$FinalScore,
  nonFinisherScores = nonFinisherScores$FinalScore,
  header = 'FinalScore')
ggsave("out/FinalScore.png",plot = finalscore,width = 300,height = 150,units = "mm")

#FinalScore
final_medical <- plotHistogramByFinishers(scoresDFWithMedical,param_name = 'FinalScore')
connectionBetweenScoreAndFinish(
  finishersScores = finisherScoresWMedical$FinalScore,
  nonFinisherScores = nonFinisherScoresWMedical$FinalScore,
  header = 'FinalScore')
ggsave("out/FinalScoreWitMedical.png",plot = final_medical,width = 300,height = 150,units = "mm")


#MiluimScores
miluim <- plotHistogramByFinishers(scoresDF,param_name = 'MiluimScores')
connectionBetweenScoreAndFinish(
  finishersScores = finisherScores$MiluimScores,
  nonFinisherScores = nonFinisherScores$MiluimScores,
  header = 'MiluimScores')
ggsave("out/MiluimScores.png",plot = miluim,width = 300,height = 150,units = "mm")


#Per month
perMonthTest(finisherScores,nonFinisherScores,metric = 'FinalScore')
# plotHistogramByFinishers(scoresDF %>% filter(GibushMonth=='אוג'),param_name = 'AvgScore','אוג')
# plotHistogramByFinishers(scoresDF %>% filter(GibushMonth=='נוב'),param_name = 'AvgScore','נוב')
# plotHistogramByFinishers(scoresDF %>% filter(GibushMonth=='מרץ'),param_name = 'AvgScore','מרץ')

# Liba vs. non-liba
connectionBetweenScoreAndFinish(finishersScores = (finisherScores %>% filter(Liba))$FinalScore,nonFinisherScores = (nonFinisherScores %>% filter(Liba))$FinalScore,header = 'Liba final scores test')
connectionBetweenScoreAndFinish(finishersScores = (finisherScores %>% filter(!Liba))$FinalScore,nonFinisherScores = (nonFinisherScores %>% filter(!Liba))$FinalScore,header = 'Non-Liba final scores test')


plotHistogramByFinishersPerMonth(scoresDF,param_name = 'AvgScore')

plotHistogramByFinishersCustomFacet(scoresDF,param_name = 'AvgScore',postfix = 'ליבה מול לא ליבה',facet_formula = formula("Finished~ Liba"))

#per mitam
perMitamTest(finisherScores,nonFinisherScores)

#Mitam 0 plot
plotHistogramByFinishers(scoresDF %>% filter(as.numeric(as.character(Mitam))<2),param_name='AvgScore','?? ????')
#Mitam 1,2 plot
plotHistogramByFinishers(scoresDF %>% filter(as.numeric(as.character(Mitam))>1),param_name='AvgScore', '????')


## Miluim vs. Sadir:
plotHistogramByFinishersPerJob(perSoldierWithMedical)

connectionBetweenScoreAndFinish(finishersScores = finisherScores$SadirScores,nonFinisherScores = nonFinisherScores$SadirScores,header = 'Sadir scores test')
## Sadir - Significant

connectionBetweenScoreAndFinish(finishersScores = finisherScores$MiluimScores,nonFinisherScores = nonFinisherScores$MiluimScores,header = 'Miluim scores test')
## Miluim - significant


#only not liba
connectionBetweenScoreAndFinish(finishersScores = (finisherScores %>% filter(!Liba))$SadirScores,nonFinisherScores = (nonFinisherScores %>% filter(!Liba))$SadirScores,header = 'Sadir scores test')
connectionBetweenScoreAndFinish(finishersScores = (finisherScores %>% filter(!Liba))$MiluimScores,nonFinisherScores = (nonFinisherScores %>% filter(!Liba))$MiluimScores,header = 'Miluim scores test')
## Sadir not significant


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
traitsplot <- traitsPlot(rawWithMedical)
ggsave("out/traitsHistograms.png",traitsplot,height=150,width = 300, units = "mm")

traits_liba <- traitsPlot(rawWithMedical %>% filter(Liba == TRUE))
ggsave("out/traitsHistogramsLiba.png",traits_liba,height=150,width = 300, units = "mm")

traits_non_liba <- traitsPlot(rawWithMedical %>% filter(Liba == FALSE))
ggsave("out/traitsHistogramsNonLiba.png",traits_non_liba,height=150,width = 300, units = "mm")


####---- Connection between traits and score ----####
avgScoreCorreation <- connectionBetweenTraitAndAvgScore(scoresDF)
plotConnectionBetweenTraitsAndMetric(avgScoreCorreation, 'מתאם בין תכונות לציון מעריכים ממוצע')


unitSuitabilityCorrelation_liba <- connectionBetweenTraitAndUnitSuitability(scoresDFWithMedical %>% filter(Liba))
unitSuitabilityCorrelation_nonliba <- connectionBetweenTraitAndUnitSuitability(scoresDFWithMedical %>% filter(!Liba))
spearman_liba <- plotConnectionBetweenTraitsAndMetric(unitSuitabilityCorrelation_liba, '????: ????? ?? ?? ????? ??? ???? ????? ??????')
spearman_nonliba <- plotConnectionBetweenTraitsAndMetric(unitSuitabilityCorrelation_nonliba, '?? ????: ????? ?? ?? ????? ??? ???? ????? ??????')
ggsave("out/spearman_liba.png",spearman_liba,height=150,width = 300, units = "mm")
ggsave("out/spearman_nonliba.png",spearman_nonliba,height=150,width = 300, units = "mm")



####---- hit /miss ----####


#Specific threshold
hitmiss <- hitMissStats(scoresDF,threshold = 4, estimator = 'UnitSuitability')

hitmiss_liba <- hitMissStats(scoresDF %>% filter(Liba),threshold = 4, estimator = 'UnitSuitability')
hitmiss_nonliba <- hitMissStats(scoresDF %>% filter(!Liba),threshold = 4, estimator = 'UnitSuitability')

#Specific threshold - final score
hitmiss_final <- hitMissStats(scoresDF,threshold = 60, estimator = 'FinalScore')

hitmiss_final_liba <- hitMissStats(scoresDF %>% filter(Liba),threshold = 60, estimator = 'FinalScore')
hitmiss_final_nonliba <- hitMissStats(scoresDF %>% filter(!Liba),threshold = 60, estimator = 'FinalScore')

#Specific threshold - unit suitability
hitmiss_unitsuitability <- hitMissStats(scoresDF,threshold = 4, estimator = 'UnitSuitability')

hitmiss_unitsuitability_liba <- hitMissStats(scoresDFWithMedical %>% filter(Liba),threshold = 4, estimator = 'UnitSuitability')
hitmiss_unitsuitability_nonliba <- hitMissStats(scoresDFWithMedical %>% filter(!Liba),threshold = 4, estimator = 'UnitSuitability')


#All thresholds
hitmissAnalysisDf <- hitmissAnalysis(scoresDF, estimator = 'UnitSuitability')

#All thresholds
hitmissAnalysisDf <- hitmissAnalysis(scoresDF, estimator = 'FinalScore',range = seq(0,100,5))



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

reasons <- raw %>% 
  group_by(Code) %>% 
  summarize(
    UnitSuitability = mean(UnitSuitability), 
    FinalScore = FinalScore[1],
    LeavingReason = LeavingReason[1],
    Reason = Reason[1]) %>% 
  filter(!is.na(LeavingReason))


gall <- reasons %>% ggplot(aes(x = LeavingReason)) + geom_bar(aes(y = (..count..)/sum(..count..))) + ggtitle("מספר מודחים מהמסלול לפי סיבה")

g5 <- reasons %>% filter(UnitSuitability >=5) %>% ggplot(aes(x = LeavingReason)) + geom_bar(aes(y = (..count..)/sum(..count..))) + ggtitle("מספר מודחים מהמסלול לפי סיבה עבור חיילים שקיבלנו ציון התאמה ליחידה גדול או שוה ל-5")
gridExtra::grid.arrange(gall,g5)

write.csv("output/megabshim.csv",x = hitMissMegabeshim)
