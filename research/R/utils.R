#' ---
#' title: "Nahal Gibush Statistical Analysis Feb 2018"
#' author: "Omri Mendels"
#' date: "Feb 22nd, 2018"
#' ---

library(ggplot2)
library(ggtech) #remotes::install_github("ricardo-bion/ggtech", dependencies=TRUE)


readExcel <- function(path = "data/data-excel.xlsx",verbose=F){
  #  library(readxl)
  sheet = 'raw'
  suppressWarnings({
    raw <- readxl::read_xlsx(path = path,sheet = sheet)
  })
  head(raw)
  if(verbose) cat("Size = ",nrow(raw),'\n')
  raw <- raw %>% unique()
  if(verbose) cat("Size after duplicate removal = ",nrow(raw),'\n')
  raw
}


parseRawData <- function(xls,exclude_medical = TRUE, verbose = F){
  
  ## Set up finished column (medical related or not)
  raw <- xls %>% mutate(
    megabesh = paste(MegashFirst,MegabeshLast),
    StartedMaslul = !is.na(Finished),
    FinishedMaslul = ifelse(Finished == 1,TRUE,ifelse(Finished == 0,FALSE,NA)),
    MedicalLeave = ifelse(LeavingReason == 'Medical' & FinishedMaslul == FALSE,TRUE,ifelse(is.na(FinishedMaslul),NA,FALSE)),
    FinishedMaslulExlMedical = ifelse(FinishedMaslul == TRUE,TRUE,ifelse(FinishedMaslul==FALSE & MedicalLeave == FALSE,FALSE,NA)),
    Liba = ifelse(as.numeric(as.character(Mitam))>1,T,F)
  )
  
  raw$GibushMonth <- as.character(raw$GibushMonth)
  raw$GibushMonth <- ifelse(raw$GibushMonth=="אוג","Aug",ifelse(raw$GibushMonth=="נוב","Nov",ifelse(raw$GibushMonth=="מרץ","Mar",raw$GibushMonth)))
  
  if(exclude_medical){
    rawNoMedical <- raw %>% filter(!MedicalLeave | is.na(MedicalLeave))
    if(verbose) cat("Size after medical removal = ",nrow(rawNoMedical),'.\nRemoved',nrow(raw)-nrow(rawNoMedical),'assessments due to medical reasons\n')
    return(rawNoMedical)
  }
  
  return(raw)
}


getDataPerSoldier <- function(raw, verbose=F){
  perSoldier <- raw %>% dplyr::group_by(Code) %>% 
    dplyr::summarize(
      GibushMonth = GibushMonth[1],
      GibushYear = GibushYear[1],
      Date = Date[1],
      Maarih1Score = Maarih1Score[1],
      Maarih2Score = Maarih2Score[1],
      Maarih3Score = Maarih3Score[1],
      Maarih4Score = Maarih4Score[1],
      Maarih5Score = Maarih5Score[1],
      MaarihScores = MaarihScores[1],
      CommanderScores = CommanderScores[1],
      MiluimScores = mean(c(CommanderScores,Maarih1Score),na.rm = T),
      SadirScores = ifelse(is.na(Maarih3Score) & is.na(Maarih4Score),NA,mean(c(Maarih3Score,Maarih4Score,Maarih5Score),na.rm = T)),
      Sociometric = Sociometric[1],
      Baror=Baror[1],
      FinalScore = FinalScore[1],
      Liba = ifelse(as.numeric(as.character(Mitam[1]))>1,T,F),
      Mitam = Mitam[1],
      PhysicalSkills = PhysicalSkills[1],
      TeamSkills = TeamSkills[1],
      PressureSkills = PressureSkills[1],
      MotivationSkills = MotivationSkills[1],
      CognitiveSkills = CognitiveSkills[1],
      CommanderSkills = CommanderSkills[1],
      UnitSuitability = UnitSuitability[1],
      AvgScore = AvgScore[1],
      CrewSize=CrewSize[1],
      #Finished = Finished[1],
      LeavingReason =LeavingReason[1],
      Reason = Reason[1],
      TironutGrade = TironutGrade[1],
      
      StartedMaslul = StartedMaslul[1],
      FinishedMaslul = FinishedMaslul[1],
      MedicalLeave = MedicalLeave[1],
      FinishedMaslulExlMedical = FinishedMaslulExlMedical[1]
      
      
    ) 
  
  if(verbose) cat(nrow(perSoldier),'soldiers in dataset\n')
  
  return(perSoldier)
}

getDataPerGibush <- function(perSoldier){
  perGibush <- perSoldier %>% 
    group_by(GibushMonth,GibushYear) %>% 
    summarize(
      count = n(),
      Date = Date[1],
      MaslulEnded = length(which(!is.na(FinishedMaslul)))>0,
      StartedMaslul = ifelse(MaslulEnded,length(which(StartedMaslul==T)),NA)
      
    )
}


printDescriptiveStats <- function(perSoldier,perGibush){
  
  perSoldierJoined <- inner_join(perSoldier,perGibush,by='Date')
  
  numberOfSoldiers <- nrow(perSoldier)
  numberOfSoldiersInFinishedMaslulim <- nrow(perSoldierJoined %>% filter(MaslulEnded))
  numberOfSoldiersThatStartedMaslul <- length(which(perSoldier$StartedMaslul==TRUE))
  numbersOfPeriodsFinishedMaslul <- length(which(perGibush$MaslulEnded == TRUE))
  numberOfFinishers <- length(which(perSoldier$FinishedMaslul == TRUE))
  numberOfNonFinishers <- length(which(perSoldier$FinishedMaslul == FALSE))
  numberOfNonFinishersExlMedical <- length(which(perSoldier$FinishedMaslulExlMedical == FALSE))
  maslulAcceptanceRate <- (numberOfSoldiersThatStartedMaslul / numberOfSoldiersInFinishedMaslulim)
  unitAcceptanceRate <- (numberOfFinishers)/(numberOfFinishers+numberOfNonFinishers)
  unitAcceptanceRateExlMedical <- (numberOfFinishers)/(numberOfFinishers+numberOfNonFinishersExlMedical)
  
  cat('\nNumber of assessments(gibushim) that finished training:',numbersOfPeriodsFinishedMaslul,"
  \nNumber of soldiers in analysis:",numberOfSoldiers,"
\nNumber of soldiers in finished maslulim (that we know about):",numberOfSoldiersInFinishedMaslulim,"
\nNumber of soldiers who started maslul:",numberOfSoldiersThatStartedMaslul,"
  \nNumber of soldiers that finished training:",numberOfFinishers,"
    \nNumber of soldiers that didn't finish training:",numberOfNonFinishers,"
    \nNumber of soldiers that didn't finish exluding medical:",numberOfNonFinishersExlMedical,"
    \nMaslul accepance rate:",maslulAcceptanceRate,"
    \nUnit acceptance rate exl. medical:",unitAcceptanceRateExlMedical,"
      \n----------------------------------\nUnit acceptance rate:",unitAcceptanceRate,"\n----------------------------------\n")
  
  
}

translate <- function(english_string){
  return(english_string)
  dict <- list()
  
  dict[['Sociometric']]  <- '?????????'
  dict[['Baror']] <-'?????'
  dict[['GibushMonth']] <-'????'
  dict[['GibushYear']] <-'???'
  dict[['Date']] <-'?????'
  dict[['FinalScore']] <-'???? ????'
  dict[['Mitam']] <-'????'
  dict[['PhysicalSkills']] <-'????? ?????'
  dict[['TeamSkills']] <-'????? ????'
  dict[['PressureSkills']] <-'????? ????? ???'
  dict[['MotivationSkills']] <-'????????'
  dict[['CognitiveSkills']] <-'????? ?????'
  dict[['CommanderSkills']] <-'????? ?????'
  dict[['UnitSuitability']] <-'????? ??????'
  dict[['FinishedMaslul']] <-'???? ?????' 
  dict[['AvgScore']] <-'???? ??????? ?????' 
  dict[['MiluimScores']] <-'???? ????? - ?????? ???????'
  dict[['SadirScores']] <-'???? ????? - ??????? ??????'
  return(dict[[english_string]])
}

percent <- function(x, digits = 2, format = "f", ...) {
  paste0(formatC(x*100, format = format, digits = digits, ...), "%")
}

plotLeavingReason <- function(raw){
  leavers <- raw %>% filter(FinishedMaslul==FALSE)
  reasonsprop <- table(leavers$LeavingReason)/nrow(leavers)
  
  reasonsDF <- data.frame(reasonsprop)# %>% mutate(pct = prop.table(n) * 100)
  ggplot(reasonsDF, aes(x=Var1,y=Freq)) + 
    geom_bar(stat="identity") + 
    geom_text(aes(y = Freq+.02,label = percent(Freq)),position = position_dodge(width = .1)) + 
    xlab('Reason') + ylab('% of dropouts') + ggtitle('Reasons for dropouts') + ggtech::theme_tech(theme="etsy")
}


perMonthStats <- function(perSoldier,perGibush){
  perSoldier <- inner_join(perSoldier,perGibush,by=c('GibushMonth','GibushYear')) %>% filter(MaslulEnded) %>% rename(StartedMaslul = StartedMaslul.x)
  perMonth <- perSoldier %>% 
    group_by(GibushMonth) %>% 
    summarize(
      Total = n(),
      NumStartedMaslul = length(which(StartedMaslul==TRUE)),
      NumDidNotStartMaslul = length(which(StartedMaslul == FALSE)),
      NumFinishedMaslul = length(which(FinishedMaslul == TRUE)),
      NumDidNotFinishMaslul = length(which(FinishedMaslul == FALSE)),
      FinishChance = NumFinishedMaslul / NumStartedMaslul,
      StartChance = NumStartedMaslul / (NumDidNotStartMaslul + NumStartedMaslul)
    )
  
  head(perMonth)
}

getScores <- function(perSoldier){
  scoresDF = perSoldier %>% 
    select(
      Code,
      GibushMonth,
      FinalScore,
      Baror,
      Sociometric,
      AvgScore, 
      MiluimScores,
      SadirScores,
      PressureSkills,
      PhysicalSkills,
      MotivationSkills,
      CognitiveSkills,
      CommanderSkills,
      TeamSkills,
      UnitSuitability,
      MaarihScores,
      Mitam,
      Liba,
      Finished = FinishedMaslul) %>% 
    mutate(
      Mitam = factor(Mitam,levels = c(0,1,2)),
      GibushMonth = factor(GibushMonth),
      Finished = as.logical(Finished),
      FinishedFactor = as.factor(Finished)) %>% filter(!is.na(Finished))
  
  
  scoresDF$Finished <- NULL
  scoresDF$Code <- NULL
  
  levels(scoresDF$Mitam) <- c(0,1,2)
  
  scoresDF
}

getScoresPlot <- function(scoresDF,save_to_file=F){
  library(ggplot2)
  library(GGally)
  ggp <- ggpairs(scoresDF, aes(colour = FinishedFactor, alpha = 0.4))
  
  if(save_to_file){
    ggsave(filename = paste0("plots/factors.png"),ggp)
  }
  ggp
}


plotDensityByFinishers <- function(scoresDF,param_name = 'Sociometric'){
  library(ggplot2)
  scores <- scoresDF %>% select(param_name,FinishedFactor) %>% rename_(param = param_name, Finished = 'FinishedFactor') #%>% mutate(param = param/nrow(scoresDF))
  scores$Finished <- ifelse(as.character(scores$Finished),'סיימו מסלול','לא סיימו מסלול')
  p = ggplot(scores, aes(x=param,fill = Finished)) +
    #geom_histogram(position="identity", colour="grey40", alpha=0.9, bins = 10) +
    geom_density(aes(y=..density..*10), alpha=0.5) +
    facet_grid(Finished~.) + 
    ggtitle(paste("Estimation distribution for :",translate(param_name))) + 
    ylab('% of soldiers') + 
    xlab(translate(param_name)) #+ 
  #ggtech::theme_tech(theme = 'etsy')+ ggtech::scale_fill_tech(theme="etsy")
  
  p
}

plotHistogramByFinishers <- function(scoresDF,param_name = 'Sociometric', postfix = ""){
  library(ggplot2)
  scores <- scoresDF %>% select(param_name,FinishedFactor) %>% rename_(param = param_name, Finished = 'FinishedFactor') #%>% mutate(param = param/nrow(scoresDF))
  scores$Finished <- ifelse(as.character(scores$Finished),'סיימו מסלול','לא סיימו מסלול')
  p = ggplot(scores, aes(x=param,fill = Finished)) +
    #geom_histogram(alpha=0.8, bins = 7,aes(fill = Finished)) +
    #geom_histogram(data = scores %>% filter(Finished ==FALSE),position="identity", colour="grey40", alpha=0.3, bins = 7,position = 'dodge') +
    #geom_histogram(data = scores %>% filter(is.na(Finished)),position="identity", colour="grey50", alpha=0.3, bins = 7,position = 'dodge') +
    
    geom_density(aes(y=..density..*10), alpha=0.5) +
    facet_grid(Finished~.) + 
    ggtitle(paste("התפלגות הערכות עבור :",translate(param_name),postfix)) + 
    ylab('מספר חיילים') + 
    #ggtech::theme_tech(theme = 'etsy')+ ggtech::scale_fill_tech(theme="etsy")
    
    p
}

plotHistogramByFinishersPerMonth <- function(scoresDF,param_name = 'Sociometric', postfix = ""){
  library(ggplot2)
  scores <- scoresDF %>% select(param_name,FinishedFactor,GibushMonth) %>% rename_(param = param_name, Finished = 'FinishedFactor') #%>% mutate(param = param/nrow(scoresDF))
  scores$Finished <- ifelse(as.character(scores$Finished),'סיימו מסלול','לא סיימו מסלול')
  p = ggplot(scores, aes(x=param,fill = Finished)) +
    geom_histogram(alpha=0.8, bins = 7,aes(fill = Finished)) +
    #geom_histogram(data = scores %>% filter(Finished ==FALSE),position="identity", colour="grey40", alpha=0.3, bins = 7,position = 'dodge') +
    #geom_histogram(data = scores %>% filter(is.na(Finished)),position="identity", colour="grey50", alpha=0.3, bins = 7,position = 'dodge') +
    
    #geom_density(aes(y=..density..*10), alpha=0.5) +
    facet_grid(Finished~GibushMonth) + 
    ggtitle(paste("התפלגות הערכות עבור :",translate(param_name),postfix)) + 
    ylab('מספר חיילים') + 
    xlab(translate(param_name)) + 
    ggtech::theme_tech(theme = 'etsy')+ ggtech::scale_fill_tech(theme="etsy")
  
  p
}

plotHistogramByFinishersCustomFacet <- function(scoresDF,param_name = 'Sociometric', postfix = "",facet_formula = formula("Finished~GibushMonth")){
  library(ggplot2)
  scores <- scoresDF %>% select(param_name,FinishedFactor,GibushMonth,Mitam,Liba,PressureSkills,CommanderSkills,TeamSkills,UnitSuitability,CognitiveSkills,MotivationSkills) %>% rename_(param = param_name, Finished = 'FinishedFactor') #%>% mutate(param = param/nrow(scoresDF))
  scores$Finished <- ifelse(as.character(scores$Finished),'סיימו מסלול','לא סיימו מסלול')
  p = ggplot(scores, aes(x=param,fill = Finished)) +
    geom_histogram(alpha=0.8, bins = 7,aes(fill = Finished)) +
    #geom_histogram(data = scores %>% filter(Finished ==FALSE),position="identity", colour="grey40", alpha=0.3, bins = 7,position = 'dodge') +
    #geom_histogram(data = scores %>% filter(is.na(Finished)),position="identity", colour="grey50", alpha=0.3, bins = 7,position = 'dodge') +
    
    #geom_density(aes(y=..density..*10), alpha=0.5) +
    facet_grid(facet_formula) + 
    ggtitle(paste("התפלגות הערכות עבור :",translate(param_name),postfix)) + 
    ylab('מספר חיילים') + 
    xlab(translate(param_name)) + 
    ggtech::theme_tech(theme = 'etsy')+ ggtech::scale_fill_tech(theme="etsy")
  
  p
}

plotHistogramByFinishersPerJob <- function(perSoldierWithMedical, postfix = ""){
  library(ggplot2)
  library(gridExtra)
  scores <- perSoldierWithMedical %>% select(MiluimScores,SadirScores) %>% reshape2::melt()
  scores$variable <- ifelse(scores$variable=='MiluimScores','???????','????')
  g <- ggplot(scores,aes(x = value)) + geom_density(aes(y=..density..), alpha=1.0) + facet_grid(variable ~.) + 
    ggtitle('התפלגות הערכות - מילואים לעומת סדיר') + 
    ylab('אחוז חיילים') + 
    xlab('הערכה')# + 
  
  return(g)
  
  get_hist_per_job <- function(scores){
    #scores$Finished = scores$FinishedFactor
    p1 = ggplot(scores, aes(x=MiluimScores)) + #,fill = Finished)) +
      geom_histogram(alpha=0.8, bins = 7) + #,aes(fill = Finished)) +
      ggtitle('התפלגות הערכות - מילואים לעומת סדיר') + 
      ylab('מספר חיילים') + 
      xlab('Miluim score')# + 
    #ggtech::theme_tech(theme = 'etsy')+ ggtech::scale_fill_tech(theme="etsy")
    
    p2 = ggplot(scores, aes(x=SadirScores)) + #,fill = Finished)) +
      geom_histogram(alpha=0.8, bins = 7) + #,aes(fill = Finished)) +
      ylab('% of soldiers') + 
      xlab('Sadir score') #+ 
    #    ggtech::theme_tech(theme = 'etsy')+ ggtech::scale_fill_tech(theme="etsy")
    
    gridExtra::grid.arrange(p1,p2)
    
  }
}

plotConnectionBetweenTraitsAndMetric <- function(correlation_results,title = ""){
  correlations <- data.frame(trait = sapply(names(correlation_results),translate), val = correlation_results)
  ggplot(data = correlations,aes(x = trait,y = val,fill = trait)) + geom_col() + 
    xlab('תכונה') + ylab('מתאם ספירמן') + 
    ggtitle(title) + 
    ggtech::theme_tech(theme = 'airbnb')+ theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")
}