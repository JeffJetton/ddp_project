library(shiny)

# Constants/globals
lwd <- 3.5                           # Line widths in graph
col.exp <- rgb( .84, .33, .33, .7)   # Color to use for expenses
col.inc <- rgb( .33, .84, .33, .7)   # Color to use for savings income
col.xov <- rgb( .33, .61, .74, .7)   # Color to use for crossover point




#### TO DO :  Add % of time the stock market has met or exceeded input percentage


shinyServer(
    function(input, output) {
        
        xover <- reactive({

            # Convert growth rates to monthly percentages
            intrate <- (1 + input$intrate / 100)^(1/12) - 1
            inflation <- (1 + input$inflation / 100)^(1/12) - 1

            # Create "months" vector
            months <- 0:(input$maxyears*12)
            
            # Create expense vector, taking into account inflation
            exp.real <- (input$expenses) * (1 + inflation)^months
            
            # Calculate growth of initial "nest egg"
            nestegg.growth <- input$nestegg * (1 + intrate)^months
            # Calculate growth of contributions
            cont.growth <- (input$contribution) * ((1 + intrate)^months - 1) / intrate
            # Add the two to get total investment value each month
            investment <- nestegg.growth + cont.growth
            
            # Figure out how much income the investment will provide each month,
            # assuming we leave in enough to keep pace with inflation
            income <- investment * (intrate - inflation)
            
            # Determine crossover point, if any
            point.index <- which(income > exp.real)
            if (length(point.index) == 0) {
                # No crossover point found in the year range
                graph.text <- paste("The income from your investments will not exceed your",
                                     "expenses at any point during the period specified.")
                inv.text <- ""
                point <- -1
            } else {
                point <- months[min(point.index)]
                if (point == 0) {
                    graph.text <<- paste("The income from your investments is already more",
                                         "than your expenses. Congratulations!")
                    inv.text <- ""
                } else {
                    year.point <- floor(point/12)
                    month.point <- point %% 12                   
                    yeartext <- ifelse(year.point==1, "year", "years")
                    monthtext <- ifelse(month.point==1, "month,", "months,")
                    graph.text <- paste("In about", year.point, yeartext, "and", month.point,
                                         monthtext, "the income from your investments is estimated",
                                         "to be able to pay for your expenses.")
                    inv.text <- paste0("Your investments will have grown to $",
                                       format(investment[point], digits=9, big.mark=",", nsmall=2))
                }
            }
            
            # Build a list to return everything in
            list(months=months, expenses=exp.real, income=income,
                 point=point, graph.text=graph.text, inv.text=inv.text)
        })
        
        output$xover.plot <- renderPlot({

            # Plot expense vs. investment income
            #par(xaxt="n")  # Don't auto-plot the x-axis
            plot(xover()$months, xover()$expenses, type="l", lwd=lwd,
                 xlab="Years from Now", ylab="Amount (in Your Currency)",
                 main="Expenses vs. Investment Income", col=col.exp, xaxt="n",
                 ylim=c(0, max(c(xover()$income, xover()$expenses))))
            lines(xover()$months, xover()$income, col=col.inc, lwd=lwd)
            # Add x-axis. Ticks every five years unless we're plotting 25 years or less.
            if (length(xover()$months) > 301) {
                ticks <- seq(0, length(xover()$months), by=60)
            } else {
                ticks <- seq(0, length(xover()$months), by=12)
            }
            labels <- as.character(ticks/12)
            axis(1, at=ticks, labels=labels)
            # Add legend
            legend("topleft", c("Expenses", "Income from Investments", "Crossover Point"),
                   lwd=lwd, col=c(col.exp, col.inc, col.xov), lty=c(1, 1, 3))
            
            # Add crossover point line to plot, if it exists
            if (xover()$point > 0) {
                abline(v=xover()$point, lwd=lwd, col=col.xov, lty=3)
            }

    	  })
        output$graph.text <- renderText(xover()$graph.text)
        output$inv.text <- renderText(xover()$inv.text)
    }
)