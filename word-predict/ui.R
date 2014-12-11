shinyUI(pageWithSidebar(
    headerPanel("Word Prediction"),
    sidebarPanel(
        textInput(inputId="text1", label = "Enter text here"),
        tags$head(tags$style(type="text/css", "#text1 {width: 90%}")),
        actionButton('random.btn', 'Random 4gram')
        ),
    mainPanel(
        p('Top prediction:'),
        textOutput('text1'),
        br(),
        p('2nd prediction:'),
        textOutput('text2'), ## watch the commas!
        br(),
        p('3rd:'),
        textOutput('text3'), ## watch the commas!
        br(),
        p('4th:'),
        textOutput('text4'),
        br(),
        p('5th:'),
        textOutput('text5'), ## watch the commas!
        br(),
        p('6th:'),
        textOutput('text6'), ## watch the commas!
        br(),
        p('Random 4gram'),
        textOutput('text7') ## watch the commas!
    )
))
