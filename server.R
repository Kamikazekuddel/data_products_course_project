library(quantmod)
library(lubridate)

getSymbols(c('AAPL','SPY'),auto.assign = TRUE)
getSymbols('DGS3MO',src='FRED',auto.assign = TRUE)

aapl_daily_returns <- log(AAPL$AAPL.Adjusted/lag(AAPL$AAPL.Adjusted)) %>%
  window(start = ymd(20150101),end=ymd(20171231))

spy_daily_returns<- log(SPY$SPY.Adjusted/lag(SPY$SPY.Adjusted)) %>%
  window(start = ymd(20150101),end=ymd(20171231))

DGS3MO <- na.locf(DGS3MO)
DGS3MO$risk_free<- as.double((index(DGS3MO)-
                                  lag(index(DGS3MO))))*
  lag(DGS3MO$DGS3MO/100)/360

risk_free_daily_returns <-  DGS3MO$risk_free%>%
  window(start=ymd(20150101),end=ymd(20171231))

returns <- merge(aapl_daily_returns,spy_daily_returns,risk_free_daily_returns) %>%na.fill(0)

portfolioSubSeries <- function(values,start,end) {
  subseries <- returns %>% window(start=start,end=end) %>% exp
  subseries$AAPL.Adjusted <- (cumprod(subseries$AAPL.Adjusted)) *values[1]
  subseries$SPY.Adjusted <- cumprod(subseries$SPY.Adjusted)*values[2]
  subseries$risk_free <- cumprod(subseries$risk_free)*values[3]
  res <- subseries$AAPL.Adjusted + subseries$SPY.Adjusted + subseries$risk_free
  names(res) <- 'portfolio_value'
  res
}

rebalancedValue <- function(totalValue,weights) {
 totalValue * weights 
}

finalValue <- function(ts) {as.double(ts[length(ts)])}

addCurrMax <- function(ts) {
  ts <- as.zoo(ts)
  ts$currMax <- rollapply(ts,width=length(ts),FUN=max,align='right',partial=TRUE)
  ts
}

maxDownturn <- function(ts) {
  tsWithCurrMax <- addCurrMax(ts)
  min(tsWithCurrMax$portfolio_value/ tsWithCurrMax$currMax - 1)
}

totalReturn <- function(ts) {
  n <- length(ts) 
  as.double(ts[n])/as.double(ts[1]) - 1
}

portfolioTimeSeries <- function(weights,monthlyRebalance=FALSE) {
  totalValue <-100
  if (monthlyRebalance) {
    y<-seq(ymd(20150101),ymd(20171231),by='month')
    f<-data.frame(start=y,end=lead(y)-1)
    f[nrow(f),'end'] <- ymd(20171231)
    
    res <- xts()
    for (i in 1:nrow(f)) {
      values<-rebalancedValue(totalValue,weights) 
      periodSeries <- portfolioSubSeries(values,f$start[i],f$end[i])
      res <- append(res,periodSeries)
      totalValue <- finalValue(periodSeries)
    }
    res 
  } else {
    portfolioSubSeries(rebalancedValue(totalValue,weights)
                       ,start=ymd(20150101),end=ymd(20171231))
  }
  
}


server<-function(input, output) {
  weights <- reactive({c(input$aapl,input$spy,1-input$aapl - input$spy)})
  portfolioTS <- reactive(portfolioTimeSeries(weights(),input$rebalance))
  output$return <- renderText({sprintf("%0.1f%%",totalReturn(portfolioTS())*100)})
  output$downturn <- renderText({sprintf("%0.1f%%",-maxDownturn(portfolioTS())*100)})
  output$cash <- renderText({weights()[3]})
  output$plot <- renderPlot({plot(portfolioTS(),
                                  ylim=c(as.double(input$ymin),
                                         as.double(input$ymax)),
                                  main = "Portfolio Value")})
#  output$txtout <- renderText({
#    paste(input$txt, input$slider, format(input$date), sep = ", ")
#  })
#  output$table <- renderTable({
#    head(cars, 4)
#  })
}
