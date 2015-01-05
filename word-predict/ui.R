shinyUI(fluidPage(
    titlePanel("Word Prediction"),
    mainPanel(
        width=6
        ,uiOutput("topPanel")
        ,p()
        ,tags$textarea(id="text1", rows=6, cols=80, "Give it a ")
        ,p()
        ,uiOutput("bottomPanel")
        ,p()
        ,selectInput("rand_bab", "Babble top prediction only:",
                    choices = c(TRUE, FALSE))
        ,numericInput(inputId="num_bab", label="Number of words to babble:",
                      value=4,min=1,max=100)
        
    ),
    sidebarPanel(
        width=6
        ,tabsetPanel(id = "explanation", position="above"
            ,tabPanel("Prediction", includeHTML("readme_prediction.html"))
            ,tabPanel("Processing the Data", includeHTML("readme_processing.html"))
        )
    )
))