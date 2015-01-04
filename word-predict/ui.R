shinyUI(pageWithSidebar(
    headerPanel("Word Prediction"),
    sidebarPanel(
        width=5
        #textInput(inputId="text1", label = "Enter text here"),
        ,tags$textarea(id="text1", rows=4, cols=80, "Give it a ")
        #tags$head(tags$style(type="text/css", "#text1 {width: 90%}")),
        ,actionButton('random.btn', 'Random 4gram')
        ,p()
        ,textOutput('text7')
        ),
    mainPanel(
        selectInput("rand_bab", "Babble top prediction only:",
                    choices = c(TRUE, FALSE))
        ,numericInput(inputId="num_bab", label="Number of words to babble:",
                      value=4,min=1,max=100)
        ,uiOutput("uiOutputPanel")
    )
))