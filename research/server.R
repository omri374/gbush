library(dplyr)
library(ggplot2)
library(reshape2)
library(gridExtra)
library(readxl)

source("R/utils.R", encoding = 'WINDOWS-1255')
source("R/one_megabesh_stats.R", encoding = 'WINDOWS-1255')
source("R/statistical_tests.R", encoding = 'WINDOWS-1255')

server <- function(input, output) {
  getXls <- reactive({
    xls1 <- readExcel('data/data-excel.xlsx')
    xls2 <- readExcel('data/2018.xlsx')
    xls <- bind_rows(xls1, xls2)
    #xls <- xls1
    cat('length of input data = ', nrow(xls))
    xls <- xls %>% distinct()
    xls
  })
  
  getRaw <- reactive({
    xls <- getXls()
    raw <-
      parseRawData(xls, exclude_medical = input$exclude_medical)
    raw
  })
  getMegabeshRaw <- reactive({
    if(is.null(input$megabesh)) return(NULL)
    getRaw() %>% filter(megabesh == input$megabesh)
  })
  
  getPerSoldier <- reactive({
    raw <- getRaw()
    if(is.null(raw)) return(NULL)
    getDataPerSoldier(raw)
  })
  
  getPerSoldierForMegabesh <- reactive({
    megabeshRaw <- getMegabeshRaw()
    if(is.null(megabeshRaw)) return(NULL)
    getDataPerSoldier(megabeshRaw)
  })
  
  getPerSoldierFiltered <- reactive({
    perSoldier <- getPerSoldier()
    
    if(is.null(perSoldier)) return(NULL)
    to_return <- perSoldier
    
    if(input$liba_filter == "Liba"){
      to_return <- perSoldier %>% filter(Liba)
    } else if(input$liba_filter == "NonLiba"){
      to_return <- perSoldier %>% filter(!Liba)
    }
    
    if(input$month_filter=="Aug"){
      to_return <- to_return %>% filter(GibushMonth == "Aug")
    } else if(input$month_filter=="Nov"){
      to_return <- to_return %>% filter(GibushMonth == "Nov")
    }  else if(input$month_filter=="Mar"){
      to_return <- to_return %>% filter(GibushMonth == "Mar")
    }
    
    return(to_return)
  })
  

  
  getMegabeshPerSoldierFiltered <- reactive({
    perSoldier <- getPerSoldierForMegabesh()
    if(is.null(perSoldier)) return(NULL)
    
    to_return <- perSoldier
    
    if(is.null(perSoldier)) return(NULL)
    if(input$liba_filter == "Liba"){
      to_return <- perSoldier %>% filter(Liba)
    } else if(input$liba_filter == "NonLiba"){
      to_return <- perSoldier %>% filter(!Liba)
    }
    
    if(input$month_filter=="Aug"){
      to_return <- to_return %>% filter(GibushMonth == "Aug")
    } else if(input$month_filter=="Nov"){
      to_return <- to_return %>% filter(GibushMonth == "Nov")
    }  else if(input$month_filter=="Mar"){
      to_return <- to_return %>% filter(GibushMonth == "Mar")
    }
    
    return(to_return)
  })
  
  is_majority_liba <- function(df){
    if(nrow(df %>% filter(Liba))>0) {
      libaSize <- df %>% filter(Liba) %>% select(number_of_soldiers_in_tsevet) %>% unlist()
    } else{
      return(FALSE)
    }
    if(nrow(df %>% filter(!Liba))>0) {
      
    nonlibaSize <- df %>% filter(!Liba) %>% select(number_of_soldiers_in_tsevet) %>% unlist()
    } else{
      return(TRUE)
    }
    return (libaSize > nonlibaSize)
    
  }
  
  getMegabeshGibushim <- reactive({
    megabeshRaw <- getMegabeshRaw()
    if(is.null(megabeshRaw)) return(NULL)
    megabeshRaw$Liba <- ifelse(as.numeric(as.character(megabeshRaw$Mitam))>1,T,F)
    teams <- megabeshRaw %>% group_by(Date,Tsevet,Liba) %>% summarize(number_of_soldiers_in_tsevet = n())
    unique_dates <- unique(teams$Date)
    cleanTeams <- data.frame()
    for (unique_date in unique_dates){
      this_gibush <- teams %>% ungroup() %>% filter(Date==unique_date)
      liba <- is_majority_liba(this_gibush)
      num_soldiers <- sum(this_gibush$number_of_soldiers_in_tsevet)
      cleanTeams <- bind_rows(cleanTeams,data.frame(Date = unique_date,Liba = liba,number_of_soldiers_in_tsevet = num_soldiers))
    }
    cleanTeams
  })
  
  output$header <- renderText({
    paste("Statistics for",input$megabesh)
  })
  
  output$raw_data <- DT::renderDataTable({
    getMegabeshRaw()
  })
  
  output$gibushim <- DT::renderDataTable({
    getMegabeshGibushim()
  })
  
  output$megabesh <- renderUI({
    selectInput("megabesh", "Miluimnik", choices = unique(getRaw()$megabesh))
  })
  
  
  
  
  
  
  
  output$numOfGibushim <- renderText ({
    teams <- getMegabeshGibushim()
    if(is.null(teams)) return(NULL)
    liba <- teams %>% filter(Liba)
    nonliba <- teams %>% filter(!Liba)
    paste("Number of gibushim :",nrow(teams),"
          \nNumber of Liba teams :",nrow(liba),"
          \nNumber of non-Liba teams :",nrow(nonliba))
  })
  
  output$generalStats <- renderText({
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    if(is.null(megabeshPerSoldier)) return(NULL)
    total <- nrow(megabeshPerSoldier)
    finished <- megabeshPerSoldier %>% filter(FinishedMaslul) %>% nrow()
    didNotFinish <- megabeshPerSoldier %>% filter(!FinishedMaslul) %>% nrow()
    started <- megabeshPerSoldier %>% filter(StartedMaslul) %>% nrow()
    didNotStart <- megabeshPerSoldier %>% filter(!StartedMaslul) %>% nrow()
    
paste("Number of evaluated soldiers:",total,"
          \nFinished maslul:",finished,"
          \nDidn't finish maslul:",didNotFinish,"
          \nStart maslul:",started,"
          \nDid not start:",didNotStart)
  })
  
  output$hitMiss <- renderTable({
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    scores <- getScores(megabeshPerSoldier)
    #hitmiss <- hitMissStats(scores,threshold = input$threshold)
    hitMissConfusionMatrix(scoresDF = scores,threshold = input$threshold)
    
    
    })
  
  output$hitMissPlot <- renderPlot({
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    if(is.null(megabeshPerSoldier)) return(NULL)
    scores <- getScores(megabeshPerSoldier)
    #hitmiss <- hitMissStats(scores,threshold = input$threshold)
    hitMissConfusionMatrix(scoresDF = scores,threshold = input$threshold)
    
  })
  
  output$traitPlot <- renderPlot({
    library(ggplot2)
    
    param_name <- input$trait
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    if(is.null(megabeshPerSoldier)) return(NULL)
    scoresDF <- getScores(megabeshPerSoldier)
    
    
    scores <- scoresDF %>% select(param_name,FinishedFactor) %>% rename_(param = param_name, Finished = 'FinishedFactor')
    
    scores$Finished <- ifelse(as.character(scores$Finished),"Finished maslul","Did not finish maslul")
    if(input$sliceByFinished){
      p = ggplot(scores, aes(x=param,fill = Finished)) +
        geom_histogram(alpha=0.8, bins = 7,aes(fill = Finished)) +
        facet_grid(Finished~.) + 
        ggtitle(paste("Distribution for",param_name)) + 
        ylab("Number of soldiers") + 
        xlab(param_name)# + 
    } else{
      p = ggplot(scores, aes(x=param)) +
        geom_histogram(alpha=0.8, bins = 7) +
        ggtitle(paste("Distribution for :",param_name)) + 
        ylab('Number of soldiers') + 
        xlab(param_name)# + 
    }
    p
    
  })
  
  output$traitPlotComparison <- renderPlot({
    library(ggplot2)
    
    param_name <- input$trait
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    if(is.null(megabeshPerSoldier)) return(NULL)
    scoresDF <- getScores(megabeshPerSoldier)
    
    
    scores <- scoresDF %>% select(param_name,FinishedFactor) %>% rename_(param = param_name, Finished = 'FinishedFactor')
    
    scores$Finished <- ifelse(as.character(scores$Finished),"Finished maslul","Did not finish maslul")
    megabeshPlot = ggplot(scores, aes(x=param)) +
        geom_histogram(alpha=0.8, bins = 7) +
        ggtitle(paste("Distribution for :",param_name)) + 
        ylab('Number of soldiers') + 
        xlab(param_name)
    
    
    rawOthers <- getRaw() %>% filter(megabesh != input$megabesh)
    perSoldierOthers <- getDataPerSoldier(rawOthers) %>% semi_join(megabeshPerSoldier,by='Code')
    
    scoresDFOthers <- getScores(perSoldierOthers)
    scoresOthers <- scoresDFOthers %>% select(param_name,FinishedFactor) %>% rename_(param = param_name, Finished = 'FinishedFactor')
    
    scoresOthers$Finished <- ifelse(as.character(scoresOthers$Finished),"Finished maslul","Did not finish maslul")
    othersPlot = ggplot(scoresOthers, aes(x=param)) +
      geom_histogram(alpha=0.8, bins = 7) +
      ggtitle(paste("Distribution for :",param_name)) + 
      ylab('Number of soldiers') + 
      xlab(param_name) 
    
    return(gridExtra::grid.arrange(megabeshPlot,othersPlot))
  })
  
  output$correlationToUnitSuitability <- renderPlot({
    
    param_name <- input$trait
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    if(is.null(megabeshPerSoldier)) return(NULL)
    scoresDF <- getScores(megabeshPerSoldier)
    
    if(!input$sliceByFinished){
    
    unitSuitabilityCorrelation <- connectionBetweenTraitAndUnitSuitability(scoresDF)
    correlations <- data.frame(trait = names(unitSuitabilityCorrelation), val = unitSuitabilityCorrelation)
    g <- ggplot(data = correlations,aes(x = trait,y = val,fill = trait)) + geom_col() + 
      xlab('Trait') + ylab("Spearman") + 
      ggtitle(paste("Spearman correlation between Unit Suitability and",input$trait)) + theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")
    
    return(g)
    } else{
      finisherScores <- scoresDF %>% filter(FinishedFactor ==TRUE)
      nonFinisherScores <- scoresDF %>% filter(FinishedFactor == FALSE)
      
      unitSuitabilityCorrelationFinished <- connectionBetweenTraitAndUnitSuitability(finisherScores)
      finishedCorrelations <- data.frame(trait = names(unitSuitabilityCorrelationFinished), val = unitSuitabilityCorrelationFinished)
      g1 <- ggplot(data = finishedCorrelations,aes(x = trait,y = val,fill = trait)) + geom_col() + 
        xlab('Trait') + ylab("Spearman") + 
        ggtitle(paste("Spearman correlation between Unit Suitability and",input$trait,"for finishers")) + theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")
      
      unitSuitabilityCorrelationNotFinished <- connectionBetweenTraitAndUnitSuitability(nonFinisherScores)
      notFinishedCorrelations <- data.frame(trait = names(unitSuitabilityCorrelationNotFinished), val = unitSuitabilityCorrelationNotFinished)
      
      
      g2 <- ggplot(data = notFinishedCorrelations,aes(x = trait,y = val,fill = trait)) + geom_col() + 
        xlab('Trait') + ylab("Spearman") + 
        ggtitle(paste("Spearman correlation between Unit Suitability and",input$trait,"for non-finishers")) + theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")
      return(gridExtra::grid.arrange(g1,g2))
      
    }
  })
}

#shinyApp(ui = ui, server = server)