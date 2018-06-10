ui<-fluidPage(tagList(
  navbarPage("",
    tabPanel("Portfolio",
             sidebarPanel(
               sliderInput("aapl", "Fraction Apple Stock", -1,2,value=1, step=0.1),
               sliderInput("spy", "Fraction SPY:", -1,2,value=0,step=0.1),
               h5(tags$b('Fraction Cash:')),
               textOutput('cash'),
               checkboxInput("rebalance", label = "Monthly Rebalancing", value = FALSE),
               textInput('ymin','ymin',value=80),
               textInput('ymax','ymax',value=200)
             ),
             mainPanel(
               h2("Total Return: ",textOutput('return',inline = TRUE)),
               h2("Maximum Downturn: ",textOutput('downturn',inline=TRUE)),
               plotOutput('plot')
             )
    ),
    tabPanel("App Description",
             h1("Description"),
             paste("This app illustrates the performance of a simple portfolio",
                   "made up Apple stocks, SPY (ETF tracking the S&P 500) and cash. The user can",
                   "sepcify the fracton of each stock. The cash fraction is determined",
                   "such that all fractions add up to 1. The server will calculate",
                   "the performance of a portfolio, where an amount of $100 is invested",
                   "initially according to the specified fraction. The portfolio performance",
                   "is then evaluated on the historic period from 2015-01-01 to 2017-12-31.",
                   "In order to do this adjusted closing prices from yahoo finance are used",
                   "for apple and SPY. Cash accrues risk free interes according to the",
                   "historical yields of 90 day US treasury bills obtained from fred.stlouisfed.org.",
                   "All historical data was loaded using R's quantmod package."),
             h2("Controlls"),
             p(tags$b('Sliders'),' for stock fractions'),
             p(tags$b('Checkbox'),' for portfolio rebalancing. If this is checked the portfolio is rebalanced every month such that the original fraction of each stock is restored accounting for returns and losses.'),
             p(tags$b('ymin and ymax'),' specify the range of the plot window') ,
             h2("Output"),
             p(tags$b("Plot")," of the portfolio Value"),
             p(tags$b("Total return")," of the portfolio over the entire period"),
             p(tags$b("Maximum drawdown")," is calculated as the maximum of the current drawdown through the time period. The current drawdown is a portfolios historic maximum value minus its current value, and hence always positive. On days when the portfolio obtains a new maximum value the drawdown is zero."),
             h2("Things to observe"),
             paste("One can observe that the Apple stock tends to be the most risky investment",
                   ", but also offers the highest returns. SPY is essentially a diversified stock portfolio",
                   "and offers lower returns at slightly lower risk, wheras the treasury bills as a cash investment",
                   "offer the lowest return at the lowest risk. It is interesting to note",
                   "that a leveraged SPY portfolio (1.7 in SPY and -0.7 in cash) has around the same return",
                   "but less risk (as measured by the maximum downturn) that a pure Apple investment")
    )
  )
)
)
