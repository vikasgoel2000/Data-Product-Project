# Define server
shinyServer(function(input, output) {
  
  # Configure my sample portfolios
  gm.portfolio <- spl('MDY,IEV,EEM,ILF,EPP,EDV,SHY')
  em.portfolio <- spl('BND,EFA,IWM,SPY,EDV')
  us.sector.portfolio <- spl('XLY,XLP,XLE,XLF,XLV,XLI,XLB,XLK,XLU')
  
  # Return the requested dataset, note:datasetInput is a reactive function. 
  datasetInput <- reactive({   
    switch(input$symbols_fr_portfolio,
           "My Global Market Rotation" = gm.portfolio,   
           "My Five Cores Rotation" = em.portfolio,  
           "US Sector SPDR Rotation" = us.sector.portfolio )
  })
  
  output$text1 <- renderText({ 
    paste("The chart represents the backtest performance of the portfolio selected 
          from the left panel. The funds in the portfolio got reviewed and traded at 
          the end of every month for the last ten years programatically. The 
          portfolio contains the following ETF funds: ")
  })
  
  output$portfolio <- renderText({ 
    datasetInput() 
  })
  
  # Create an environment for storing data
  symbol_env <- new.env()
  
  #*****************************************************************
  # Shared Reactive functions
  # http://rstudio.github.com/shiny/tutorial/#inputs-and-outputs
  #******************************************************************      
  # Get stock data
  getData <- reactive( {    
    cat('getData was called\n')
    
    data <- new.env()
    for(symbol in getStocks() ) {
      if (is.null(symbol_env[[symbol]]))
        tryCatch(
{
  symbol_env[[symbol]] = 
    #getSymbols(symbol, from='2005-01-01', src='yahoo', auto.assign = FALSE)
    #getSymbols(symbol, from=input$dateRange[1], to=input$dateRange[2], src='yahoo', auto.assign = FALSE) 
    getSymbols(symbol, from= Sys.Date() - 3650, src='yahoo', auto.assign = FALSE)
}, 
error = function(e) { 
  stop(paste('Problem getting prices for',symbol)) 
})
data[[symbol]] = adjustOHLC(symbol_env[[symbol]], use.Adjusted=T)  			
    }

#bt.prep(data, align='keep.all', dates='2000::')
bt.prep(data, align='keep.all')
#bt.prep(data, align='keep.all', dates=input$dateRange[1])
data		
  })

# Helper fns
getStocks <- reactive( { spl(toupper(gsub('\n',',',datasetInput() ))) })

getBackTest <- reactive( { 
  #*****************************************************************
  # Load historical data
  #******************************************************************  
  data = getData()
  
  tryCatch({		
    #*****************************************************************
    # Code Strategies
    #****************************************************************** 
    prices = data$prices   
    nperiods = nrow(prices)
    n = ncol(prices)
    
    # find period ends
    period.ends = endpoints(prices, 'months')
    period.ends = period.ends[period.ends > 0]
    
    models = list()
    
    #*****************************************************************
    # Code Strategies
    #****************************************************************** 
    dates = '2001::'
    
    # Equal Weight
    data$weight[] = NA
    data$weight[period.ends,] = ntop(prices, n)[period.ends,]	
    models$equal.weight = bt.run.share(data, clean.signal=F, dates=dates)
    
    # model parameters	
    momLen = as.numeric(input$momLen) * 22
    topn = floor(as.numeric(input$topn))
    keepn = floor(as.numeric(input$keepn))
    
    # Rank on momLen month return
    position.score = prices / mlag(prices, momLen)	
    
    # Select Top topn funds
    data$weight[] = NA
    data$weight[period.ends,] = ntop(position.score[period.ends,], topn)	
    models[[ paste('top', topn, sep='') ]] = 
      bt.run.share(data, clean.signal=T, trade.summary=T, dates=dates)
    
    # Seletop Top topn funds,  and Keep then till they are in 1:keepn rank
    data$weight[] = NA
    data$weight[period.ends,] = ntop.keep(position.score[period.ends,], topn, keepn)	
    models[[ paste('top', topn, '.keep', keepn, sep='') ]] = 
      bt.run.share(data, clean.signal=T, trade.summary=T, dates=dates)    
    
    rev(models)
  }, 
  error = function(e) { 
    stop(paste('Problem running Back Test:', e)) 
  })
})


# Make table
makeSidebysideTable <- reactive( {
  models = getBackTest()
  plotbt.strategy.sidebyside(models, return.table=T, make.plot=F)
})


#*****************************************************************
# Not Reactive helper functions
#*****************************************************************
# Make table
makeTradesTable <- function(i = 1) {
  models = getBackTest()
  model = models[[i]]
  
  if (!is.null(model$trade.summary)) {
    ntrades = min(50, nrow(model$trade.summary$trades))		
    last(model$trade.summary$trades, ntrades)
  }
}

# Make table
makeAnnualTable <- function(i = 1) {
  models = getBackTest()
  plotbt.monthly.table(models[[i]]$equity, make.plot = F)
}

#*****************************************************************
# Update plot(s) and table(s)
#******************************************************************    	
# Generate a plot
output$strategyPlot <- renderPlot( {        
  models = getBackTest()		
  plotbt.custom.report.part1.mod(models)  					
  #plota.add.copyright()
}, height = 400, width = 600)

# Generate a table
output$sidebysideTable <- reactive( {
  temp = makeSidebysideTable()	
  tableColor(as.matrix(temp))		
})

# Generate a table
output$annualTable <- reactive( {
  tableColor(as.matrix(makeAnnualTable(1)))
})

# Generate a plot
output$transitionPlot <- renderPlot( {
  models = getBackTest()
  plotbt.transition.map(models[[1]]$weight)
  plota.add.copyright()
}, height = 400, width = 600)

# Generate a table
output$tradesTable <- reactive( {
  tableColor(as.matrix(makeTradesTable(1)), include.rownames=FALSE)
})


#*****************************************************************
# Update status message 
#******************************************************************    
output$status2 <- renderUI( {
  out = tryCatch( getData(), error=function( err ) paste(err))        				
  if( is.character( out ) ) 
    HTML(paste("<b>Status</b>: <b><font color='red'>Error:</font></b>",out))
  else
    HTML("<b>Status</b>: <b><font color='green'>Ok</font></b>")		
})

  })
