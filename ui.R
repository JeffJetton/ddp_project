
shinyUI(
    pageWithSidebar(
        headerPanel("Crossover Point Calculator"),
        sidebarPanel(
            p(paste("Your \"crossover point\" is the point in time when the money",
                    "you've saved/invested is generating more income than your expenses.",
                    "It is one common way to define financial independence.")),
            p(paste("This Shiny app provides a simple, basic estimate of when your",
                    "own crossover point may occur.")),
            hr(),
            p("Use whatever currency units you like--just be consistent!"),
            numericInput("expenses", "Your current monthly expenses", 3000, min=0, step=250),
            numericInput("nestegg", "Amount you have invested already", 50000, step=1000),
            numericInput("contribution", "How much you plan to add to your investments each month", 500, min=0, step=100),
            sliderInput("intrate", "Estimated investment growth rate (in yearly percentage)", 7.5, min=0, max=15, step=0.5),
            sliderInput("inflation", "Estimated inflation rate (in yearly percentage)", 3.0, min=0, max=10, step=0.5),
            sliderInput("maxyears", "Years to display on graph", 50, min=5, max=75, step=5)
        ),
        mainPanel(
            plotOutput("xover.plot", height="550px"),
            h3(textOutput("graph.text")),
            p(textOutput("inv.text")),
            p(paste("This assumes that your expenses and contributions both increase with",
                    "inflation but otherwise do not change. The income from your investments is",
                    "based on an earnings rate equal to the interest rate minus the inflation",
                    "rate."))
        )
    )
)