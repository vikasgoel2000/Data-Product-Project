library(shiny)
library(xtable)


if(!file.exists('sit'))
  shiny:::download('https://github.com/systematicinvestor/SIT/raw/master/sit.lite.gz', 'sit', mode = 'wb', quiet = TRUE)
con = gzcon(file('sit', 'rb'))
source(con)
close(con)


load.packages("quantmod")
if (!require(quantmod)) {
  stop("This app requires the quantmod package. To install it, run 'install.packages(\"quantmod\")'.\n")
}


plotbt.custom.report.part1.mod <- function
( 
  ..., 
  dates = NULL, 
  main = '', 
  trade.summary = FALSE,
  x.highlight = NULL
) 
{  
  layout(1:1)   # one col, one row
  
  models = variable.number.arguments( ... )
  model = models[[1]]
  
  # Main plot
  plotbt(models, dates = dates, main = main, plotX = F, log = 'y', LeftMargin = 3, x.highlight = x.highlight)	    	
  mtext('Cumulative Performance', side = 2, line = 1)
  
  #plotbt(models[1], plottype = '12M', dates = dates, plotX = F, LeftMargin = 3, x.highlight = x.highlight)	    	
  #mtext('12 Month Rolling', side = 2, line = 1)
  
  #plotbt(models[1], dates = dates, xfun = function(x) { 100 * compute.drawdown(x$equity) }, LeftMargin = 3, x.highlight = x.highlight)
  #mtext('Drawdown', side = 2, line = 1)
}
