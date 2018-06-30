#' ---
#' title: "Nahal Gibush Statistical Analysis Feb 2018"
#' author: "Omri Mendels"
#' date: "Feb 22nd, 2018"
#' ---

library(ggplot2)
library(ggtech) #remotes::install_github("ricardo-bion/ggtech", dependencies=TRUE)


readExcel <- function(path = "data/data-excel.xlsx"){
#  library(readxl)
  sheet = 'raw'
  suppressWarnings({
    raw <- readxl::read_xlsx(path = path,sheet = sheet)
  })
  head(raw)
  cat("Size = ",nrow(raw),'\n')
  raw <- raw %>% unique()
  cat("Size after duplicate removal = ",nrow(raw),'\n')
  raw
}


parseRawData <- function(xls,exclude_medical = TRUE){

  ## Set up finished column (medical related or not)
  raw <- xls %>% mutate(
    megabesh = paste(MegashFirst,MegabeshLast),
    StartedMaslul = !is.na(Finished),
    FinishedMaslul = ifelse(Finished == 1,TRUE,ifelse(Finished == 0,FALSE,NA)),
    MedicalLeave = ifelse(LeavingReason == 'Medical' & FinishedMaslul == FALSE,TRUE,ifelse(is.na(FinishedMaslul),NA,FALSE)),
    FinishedMaslulExlMedical = ifelse(FinishedMaslul == TRUE,TRUE,ifelse(FinishedMaslul==FALSE & MedicalLeave == FALSE,FALSE,NA))
    
  )
  
  if(exclude_medical){
    rawNoMedical <- raw %>% filter(!MedicalLeave | is.na(MedicalLeave))
    cat("Size after medical removal = ",nrow(rawNoMedical),'.\nRemoved',nrow(raw)-nrow(rawNoMedical),'assessments due to medical reasons\n')
    return(rawNoMedical)
  }
  
  return(raw)
}


getDataPerSoldier <- function(raw){
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
      Sociometric = Sociometric[1],
      Baror=Baror[1],
      FinalScore = FinalScore[1],
      Liba = ifelse(Mitam[1]==0,F,T),
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
  
  cat(nrow(perSoldier),'soldiers in dataset\n')
  
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
  
  dict[['Sociometric']]  <- '??????????????????'
  dict[['Baror']] <-'??????????'
  dict[['GibushMonth']] <-'??????????'
  dict[['GibushYear']] <-'??????'
  dict[['Date']] <-'??????????'
  dict[['MegabeshFirst']] <-'???? ????????'
  dict[['MegabeshLast']] <-'???? ??????????'
  dict[['CommanderName']] <-'???? ????????'
  dict[['FinalScore']] <-'???????? ????????'
  dict[['Mitam']] <-'????????'
  dict[['PhysicalSkills']] <-'?????????? ??????????'
  dict[['TeamSkills']] <-'?????????? ????????'
  dict[['PressureSkills']] <-'?????????? ?????????? ??????'
  dict[['MotivationSkills']] <-'???????????????? ????????????'
  dict[['CognitiveSkills']] <-'?????????? ??????????'
  dict[['CommanderSkills']] <-'?????????? ??????????'
  dict[['UnitSuitability']] <-'?????????? ????????????'
  dict[['FinishedMaslul']] <-'???????? ??????????' 
  dict[['AvgScore']] <-'???????? ?????????????? ??????????' 
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
    xlab('????????') + ylab('????????') + ggtitle('???????? ?????? ??????????????') + ggtech::theme_tech(theme="etsy")
}


perMonthStats <- function(perSoldier){
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
  scores$Finished <- ifelse(as.character(scores$Finished),'????????','???? ????????')
  p = ggplot(scores, aes(x=param,fill = Finished)) +
    #geom_histogram(position="identity", colour="grey40", alpha=0.9, bins = 10) +
    geom_density(aes(y=..density..*10), alpha=0.5) +
    facet_grid(Finished~.) + 
    ggtitle(paste("?????????????? ?????????? :",translate(param_name))) + 
    ylab('?????????????????? %') + 
    xlab(translate(param_name)) + 
    ggtech::theme_tech(theme = 'etsy')+ ggtech::scale_fill_tech(theme="etsy")
  
  p
}

plotHistogramByFinishers <- function(scoresDF,param_name = 'Sociometric', postfix = ""){
  library(ggplot2)
  scores <- scoresDF %>% select(param_name,FinishedFactor) %>% rename_(param = param_name, Finished = 'FinishedFactor') #%>% mutate(param = param/nrow(scoresDF))
  scores$Finished <- ifelse(as.character(scores$Finished),'????????','???? ????????')
  p = ggplot(scores, aes(x=param,fill = Finished)) +
    geom_histogram(alpha=0.8, bins = 7,aes(fill = Finished)) +
    #geom_histogram(data = scores %>% filter(Finished ==FALSE),position="identity", colour="grey40", alpha=0.3, bins = 7,position = 'dodge') +
    #geom_histogram(data = scores %>% filter(is.na(Finished)),position="identity", colour="grey50", alpha=0.3, bins = 7,position = 'dodge') +
    
    #geom_density(aes(y=..density..*10), alpha=0.5) +
    #facet_grid(Finished~.) + 
    ggtitle(paste("?????????????? ?????????? :",translate(param_name),postfix)) + 
    ylab('?????????????????? %') + 
    xlab(translate(param_name)) + 
    ggtech::theme_tech(theme = 'etsy')+ ggtech::scale_fill_tech(theme="etsy")
  
  p
}

plotHistogramByFinishersPerMonth <- function(scoresDF,param_name = 'Sociometric', postfix = ""){
  library(ggplot2)
  scores <- scoresDF %>% select(param_name,FinishedFactor,GibushMonth) %>% rename_(param = param_name, Finished = 'FinishedFactor') #%>% mutate(param = param/nrow(scoresDF))
  scores$Finished <- ifelse(as.character(scores$Finished),'????????','???? ????????')
  p = ggplot(scores, aes(x=param,fill = Finished)) +
    geom_histogram(alpha=0.8, bins = 7,aes(fill = Finished)) +
    #geom_histogram(data = scores %>% filter(Finished ==FALSE),position="identity", colour="grey40", alpha=0.3, bins = 7,position = 'dodge') +
    #geom_histogram(data = scores %>% filter(is.na(Finished)),position="identity", colour="grey50", alpha=0.3, bins = 7,position = 'dodge') +
    
    #geom_density(aes(y=..density..*10), alpha=0.5) +
    facet_grid(GibushMonth~.) + 
    ggtitle(paste("?????????????? ?????????? :",translate(param_name),postfix)) + 
    ylab('?????????????????? %') + 
    xlab(translate(param_name)) + 
    ggtech::theme_tech(theme = 'etsy')+ ggtech::scale_fill_tech(theme="etsy")
  
  p
}