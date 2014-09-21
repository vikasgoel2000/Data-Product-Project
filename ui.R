library(shiny)
#library(shinyIncubator)

# make a dropdownlist for portfolios
portfolio = c("My Global Market Rotation", 
              "My Five Cores Rotation", 
              "US Sector SPDR Rotation")

# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  #progressInit(),
  headerPanel(""),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel( 
    width = 3,
    
    tags$label(strong("Optimize Your Investment Portfolio Performance")), 
    
    tags$label("Make the following selections to backtest portfolio performance 
               based on the last 10-year historical data provided by Yahoo Finance."),
    
    selectInput("symbols_fr_portfolio", "Choose a portfolio:", choices = portfolio),
    
    selectInput("momLen", "Performance Look Back Period (month):", choices =  1:12,selected=3),
    #selectInput("momLen", strong("Momentum Length (months):"), choices =  1:12,selected=3),
    numericInput("topn", "Invest in top # funds:", 1),
    numericInput("keepn", "Keep position till the rank drops below:", 2),    		
    #         dateRangeInput('dateRange',
    #                        label = 'Pick a starting and ending date:',
    #                        startview = 'year',
    #                        min = '2005-01-01',
    #                        format = "yyyy-mm-dd",
    #                        start = Sys.Date() - 3650, end = Sys.Date() 
    #         ),
    br(),
    
    tags$label("After making changes, click the button:"),
    submitButton("Update Chart & Tables"),
    htmlOutput("status2")
    ),
  
  
  # Show a plot of the generated distribution
  mainPanel(
    tabsetPanel(
      tabPanel("Charts & Summary", 
               textOutput("text1"),
               
               h6( textOutput("portfolio") ),
               plotOutput("strategyPlot"),
               br(),
               h4("Backtest Scenarios and Performance Summary"),
               tableOutput("sidebysideTable"),
               br(),
               h4("Annual Perfromance"),
               tableOutput("annualTable"),
               #h4("Transition Map"),
               #plotOutput("transitionPlot"),
               br(),
               #                      h4("The Most Recent 50 Trade Logs"),
               #                      tableOutput("tradesTable"),				
               #downloadButton("downloadReport", "Download Report"),
               #downloadButton("downloadData", "Download Data"),
               br(),
               br()	
      ),			
      
      tabPanel("Trade Logs", 
               h4("The Most Recent 50 Trade Logs"),
               tableOutput("tradesTable")   			
      ),
      
      tabPanel("BackTest Usage", 
               h4("Usasge"),
               p('The Sector Rotation strategy selects top N funds (i.e. 2 funds) based on the momentum (i.e 6 month returns)
                 and adjusts the holdings only when these funds drop their momentum rank below 
                 a threshold. This study is based on the',    	
                 a('ETF Sector Strategy.', href="http://www.etfscreen.com/sectorstrategy.php", target="_blank")),
               
               h5("Example 1"),
               p('Select the "US Sector SPDR Rotation" portfolio, and keep the rest of 
                 settings, then click Update Chart & Tables button. You can see from the chart, 
                 there is big drawn down during 2008 timeframe.'),
               
               h5("Example 2"),                   
               p('Select the "My Five Cores Rotation" portfolio, and keep the rest of 
                 settings, then click Update Chart and Tables button. The overall performance is 
                 not bad at all. The green line shows that if you equally invested in the five 
                 funds, the black line shows that if you invested only in the top 1 ranking fund 
                 and keep the fund until it drops its ranking below 2. The red line represents 
                 the case where if you invested in the top 1 ranking fund and keep the fund until 
                 it drops its ranking below 1.  This example may keep you motivated, and 
                 continue to find settings that fit your risk profile but not over-fit historical 
                 data.'),   
               
               h5("Example 3"),                   
               p('Select the portfolio that you prefer from the dropdown list, and change other 
                 parameters one at time, click Update Chart & Tables button to refresh the 
                 chart.'),                   
               
               h5("Note:"),
               p('This App is for demo and learning purpose. It is not for providing 
                 investment advice of any kind.'),   
               
               br()                  
               
               
               ),
      
      tabPanel("About",
               p('This application demonstrates how to backtest and optimize a investment portfolio using ',
                 a("Shiny", href="http://www.rstudio.com/shiny/", target="_blank"), 'framework.'),
               
               br(),
               
               strong('References'),
               p(                       
                 HTML('<li>'),'Packages: shiny, shinyapps, systematic investor toolbox',HTML('</li>'),
                 HTML('<li>'),a("ETF Sector Strategy", href="http://www.etfscreen.com/sectorstrategy.php", target="_blank"),HTML('</li>'),
                 HTML('<li>'),a("Systematic Investor", href="http://www.systematicportfolio.com/", target="_blank"),HTML('</li>'),
                 HTML('</ul>'))
      )    
               )
               )
    ))
