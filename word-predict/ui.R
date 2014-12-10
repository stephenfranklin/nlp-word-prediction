shinyUI(pageWithSidebar(
    headerPanel("Word Prediction"),
    sidebarPanel(
        textInput(inputId="text1", label = "Enter text here"),
        tags$head(tags$style(type="text/css", "#text1 {width: 90%}")),
        actionButton('word1but', 'Predict')
        ),
    mainPanel(
        p('Output text1'),
        textOutput('text1'),
        br(),
        p('Output text2'),
        textOutput('text2'), ## watch the commas!
        br(),
        p('Output text3'),
        textOutput('text3') ## watch the commas! 
    )
))
