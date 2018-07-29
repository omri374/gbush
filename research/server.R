library(dplyr)
library(ggplot2)
library(reshape2)
library(gridExtra)
library(readxl)
library(prettyunits)
library(progress)

source(file.path("R","utils.R"))#, encoding = 'WINDOWS-1255')
#source("R/one_megabesh_stats.R", encoding = 'WINDOWS-1255')
source(file.path("R","statistical_tests.R"))#, encoding = 'WINDOWS-1255')

server <- function(input, output) {
  getDefaultXls <- reactive({
    if(!file.exists('data/data-excel.xlsx')) return(NULL)
    xls <- readExcel('data/data-excel.xlsx')
    cat('length of input data = ', nrow(xls))
    xls <- xls %>% distinct()
    xls
  })
  
  getXls <- reactive({
    inFile <- input$file
    
    if(is.null(inFile))
      return(NULL)
    file.rename(inFile$datapath,
                paste(inFile$datapath, ".xlsx", sep=""))
    xls <- read_excel(paste(inFile$datapath, ".xlsx", sep=""), 1)
    xls <- xls %>% distinct()
    xls
  })
  
  
  
  getRaw <- reactive({
    xls <- getXls()
    
    #xls2 <- getDefaultXls()
    xls2 <- NULL
    if(is.null(xls)) xls <- xls2
    
    if(is.null(xls)) return(NULL)
    
    raw <-
      parseRawData(xls, exclude_medical = input$exclude_medical)
    raw
  })
  getMegabeshRaw <- reactive({
    if(is.null(input$megabesh)) return(NULL)
    
    raw <- getRaw()
    if(input$megabesh != 'ALL'){
      raw <- raw %>% filter(megabesh == input$megabesh)
    }
    
    raw
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
  
  output$falsePositives <- DT::renderDataTable({
    raw <- getMegabeshRaw()
    if(is.null(raw)) return(NULL)
    
    raw %>% 
      filter(UnitSuitability >= input$threshold & FinishedMaslul==FALSE) %>% 
      select(Date,megabesh,Liba, Reason,LeavingReason,UnitSuitability, PhysicalSkills, TeamSkills,PressureSkills,MotivationSkills,CognitiveSkills,CommanderSkills)
  },options = list(scrollX = TRUE))
  
  output$raw_data <- DT::renderDataTable({
    getMegabeshRaw()
  },options = list(scrollX = TRUE))
  
  output$gibushim <- DT::renderDataTable({
    getMegabeshGibushim()
  })
  
  output$megabesh <- renderUI({
    selectInput("megabesh", "Miluimnik", choices = c("ALL",sort(unique(getRaw()$megabesh))))
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
  
  output$hitMiss <- renderPrint({
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    if(is.null(megabeshPerSoldier)){ return(invisible())}
    scoresMaarih <- getScores(megabeshPerSoldier)

    hitmissMegabesh <- hitMissConfusionMatrix(scoresDF = scoresMaarih,
                                              threshold = input$threshold,
                                              estimator = 'UnitSuitability')
    print(hitmissMegabesh)
    
    #perSoldier <- getPerSoldierFiltered()
    #scores <- getScores(perSoldier)
    #hitmissAll <- as.data.frame(hitMissConfusionMatrix(scoresDF = scores,threshold = input$threshold))
    #hitmissAll$Freq <- hitmissAll$Freq/sum(hitmissAll$Freq)
    #all <- inner_join(hitmissMegabesh,hitmissAll,by=c("FinishedMaslul","PassedGibush"))
    #names(all) <- c("Finished Maslul","Above threshold","This megabesh","All")
    #all
    
    
    
  })
  
  getHitMissText <- function(hitmiss){
    paste0("Hit/Miss = ",format(hitmiss$hitVsMiss,digits = 3,scientific = F),"<BR>= (", hitmiss$tp ," + ",hitmiss$tn ,")/(",hitmiss$fp," + ",hitmiss$fn,")
          <BR>Accept precision = ",format(hitmiss$precision,digits = 3,scientific = F),"<BR>= ",hitmiss$tp ,"/(",hitmiss$tp," + ",hitmiss$fp,")
          <BR>Reject precision = ",format(hitmiss$precisionNot,digits = 3,scientific = F),"<BR>= ",hitmiss$tn ,"/(",hitmiss$tn," + ",hitmiss$fn,")")
  }
  
  output$hitMissSummary <- renderUI({
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    if(is.null(megabeshPerSoldier)){ return(invisible())}
    scoresMegabesh <- getScores(megabeshPerSoldier)
    hitmissMegabesh <- hitMissStats(scoresMegabesh,
                                    threshold = input$threshold,
                                    estimator = 'UnitSuitability')
    
    perSoldier <- getPerSoldierFiltered()
    scores <- getScores(perSoldier)
    hitmissAll <- hitMissStats(scores,
                               threshold = input$threshold,
                               estimator = 'UnitSuitability')
    
    rawOthers <- getRaw() %>% filter(megabesh != input$megabesh)
    perSoldierOthers <- getDataPerSoldier(rawOthers) %>% semi_join(megabeshPerSoldier,by='Code')
    
    scoresDFOthers <- getScores(perSoldierOthers)
    hitmissOthers <- hitMissStats(scoresDFOthers,
                                  threshold = input$threshold,
                                  estimator = 'UnitSuitability')
    
    
    HTML(paste("<B>This megabesh:</B><p>",getHitMissText(hitmissMegabesh),"</p><B>Entire gibush:</B><p>",getHitMissText(hitmissAll),"</p><B>Megabshism evaluating the same soldiers as me:</B><p>",getHitMissText(hitmissOthers),"</p>"))
    
    
  })
  
  output$hitMissPlot <- renderPlot({
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    if(is.null(megabeshPerSoldier)) return(NULL)
    scores <- getScores(megabeshPerSoldier)

    confusionMatrix <- hitMissConfusionMatrix(scoresDF = scores,threshold = input$threshold,estimator = 'MaarihScores')
    plot(confusionMatrix,xlab = 'Maarih',ylab = 'Actual')
    
  })
  
  
  output$hitMissPlotAll <- renderPlot({
    perSoldier <- getPerSoldierFiltered()
    if(is.null(perSoldier)) return(NULL)
    scores <- getScores(perSoldier)

    confusionMatrix <- hitMissConfusionMatrix(scoresDF = scores,threshold = input$threshold,estimator = 'AvgScore')
    plot(confusionMatrix,xlab = 'Maarih',ylab = 'Actual')
    
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
  
  output$traitPlotFull <- renderPlot({
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    scoresDF <- getScores(megabeshPerSoldier)
    
    scores <- scoresDF %>% select(FinishedFactor,PressureSkills,PhysicalSkills,MotivationSkills,CognitiveSkills,CommanderSkills,TeamSkills,UnitSuitability)
    
    
    scores$Finished <- ifelse(as.character(scores$FinishedFactor),"Finished maslul","Did not finish maslul")
    scores$FinishedFactor <- NULL
    melted <- melt(scores)
    
    p = ggplot(melted,aes(x = value,fill = variable)) +
      geom_histogram(alpha=0.8, bins = 7) +
      facet_grid(variable ~ .)
    ylab('Number of soldiers')
    
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
      ggtitle(paste("This megabesh, distribution for :",param_name)) + 
      ylab('Number of soldiers') + 
      xlab(param_name)
    
    
    rawOthers <- getRaw() %>% filter(megabesh != input$megabesh)
    perSoldierOthers <- getDataPerSoldier(rawOthers) %>% semi_join(megabeshPerSoldier,by='Code')
    
    scoresDFOthers <- getScores(perSoldierOthers)
    scoresOthers <- scoresDFOthers %>% select(param_name,FinishedFactor) %>% rename_(param = param_name, Finished = 'FinishedFactor')
    
    scoresOthers$Finished <- ifelse(as.character(scoresOthers$Finished),"Finished maslul","Did not finish maslul")
    othersPlot = ggplot(scoresOthers, aes(x=param)) +
      geom_histogram(alpha=0.8, bins = 7) +
      ggtitle(paste("Same soldiers megabshim, distribution for :",param_name)) + 
      ylab('Number of soldiers') + 
      xlab(param_name)
    
    perSoldierAll <- getDataPerSoldier(rawOthers)
    
    scoresDFAll <- getScores(perSoldierAll)
    scoresAll <- scoresDFAll %>% select(param_name,FinishedFactor) %>% rename_(param = param_name, Finished = 'FinishedFactor')
    
    scoresAll$Finished <- ifelse(as.character(scoresAll$Finished),"Finished maslul","Did not finish maslul")
    allPlot = ggplot(scoresAll, aes(x=param)) +
      geom_histogram(alpha=0.8, bins = 7) +
      ggtitle(paste("All megabshim distribution for :",param_name)) + 
      ylab('Number of soldiers') + 
      xlab(param_name)
    
    return(gridExtra::grid.arrange(megabeshPlot,othersPlot,allPlot))
  })
  
  output$correlationToUnitSuitability <- renderPlot({
    
    param_name <- input$trait
    megabeshPerSoldier <- getMegabeshPerSoldierFiltered()
    perSoldier <- getPerSoldier()
    if(is.null(megabeshPerSoldier)) return(NULL)
    scoresDFMegabesh <- getScores(megabeshPerSoldier)
    scoresDFAll <- getScores(perSoldier)
    if(!input$sliceByFinished){
      
      unitSuitabilityCorrelationMegabesh <- connectionBetweenTraitAndUnitSuitability(scoresDFMegabesh)
      correlationMegabesh <- data.frame(trait = names(unitSuitabilityCorrelationMegabesh),
                                        val = unitSuitabilityCorrelationMegabesh,
                                        population = input$megabesh)
      
      
      unitSuitabilityCorrelationALL <- connectionBetweenTraitAndUnitSuitability(scoresDFAll)
      correlationAll <- data.frame(trait = names(unitSuitabilityCorrelationALL),
                                   val = unitSuitabilityCorrelationALL,
                                   population = 'All')
      
      correlations <- bind_rows(correlationMegabesh,correlationAll)
      
      #correlations <- data.frame(trait = names(unitSuitabilityCorrelation), val = unitSuitabilityCorrelation)
      g <- ggplot(data = correlations,aes(x = trait,y = val,fill = trait)) + geom_col() + 
        xlab('Trait') + ylab("Spearman") + 
        facet_grid(.~population) +
        ggtitle(paste("Spearman correlation between Unit Suitability and other traits")) + 
        theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")
      
      return(g)
    } else{
      finisherScores <- scoresDFMegabesh %>% filter(FinishedFactor ==TRUE)
      nonFinisherScores <- scoresDFMegabesh %>% filter(FinishedFactor == FALSE)
      
      unitSuitabilityCorrelationFinished <- connectionBetweenTraitAndUnitSuitability(finisherScores)
      finishedCorrelations <- data.frame(trait = names(unitSuitabilityCorrelationFinished), val = unitSuitabilityCorrelationFinished)
      g1 <- ggplot(data = finishedCorrelations,aes(x = trait,y = val,fill = trait)) + geom_col() + 
        xlab('Trait') + ylab("Spearman") + 
        ggtitle(paste("Spearman correlation between Unit Suitability and other traits for finishers")) + 
        theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")
      
      unitSuitabilityCorrelationNotFinished <- connectionBetweenTraitAndUnitSuitability(nonFinisherScores)
      notFinishedCorrelations <- data.frame(trait = names(unitSuitabilityCorrelationNotFinished), val = unitSuitabilityCorrelationNotFinished)
      
      
      g2 <- ggplot(data = notFinishedCorrelations,aes(x = trait,y = val,fill = trait)) + geom_col() + 
        xlab('Trait') + ylab("Spearman") + 
        ggtitle(paste("Spearman correlation between Unit Suitability and",input$trait,"for non-finishers")) + theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")
      return(gridExtra::grid.arrange(g1,g2))
      
    }
  })
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      temp_dir <- tempdir()
      
      r_dir <- dir.create(file.path(temp_dir,"R"))
      data_dir <- dir.create(file.path(temp_dir,"data"))
      
      tempReport <- file.path(temp_dir, "megabesh_report.Rmd")
      file.copy("megabesh_report.Rmd", tempReport, overwrite = TRUE)
      
      tempUtils <- file.path(temp_dir,"R","utils.R")
      file.copy(file.path("R","utils.R"), tempUtils, overwrite = TRUE)
      
      temp_statistical_tests <- file.path(temp_dir, "R","statistical_tests.R")
      file.copy(file.path("R","statistical_tests.R"), temp_statistical_tests, overwrite = TRUE)
      
      input_file <- input$file
      if(is.null(input$file)){
        stop("No input file found")
      }
      
      file.copy(paste0(input_file$datapath,".xlsx"), file.path(temp_dir,"data","0.xlsx"), overwrite = TRUE)
      
      
      # Set up parameters to pass to Rmd document
      params <- list(  
        exclude_medical= input$exclude_medical,
        liba_filter= input$liba_filter,
        megabesh= input$megabesh,
        month_filter= input$month_filter,
        threshold= input$threshold,
        filepath = file.path(temp_dir,"data","0.xlsx")
      )
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
  
}

#shinyApp(ui = ui, server = server)