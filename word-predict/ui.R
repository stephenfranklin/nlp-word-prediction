shinyUI(pageWithSidebar(
    headerPanel("Word Prediction"),
    sidebarPanel(
        textInput(inputId='text1', label='Input Text1'), ## watch the commas!
        actionButton('goButton', 'word 1'),
        actionButton('goButton', 'word 2'),
        actionButton('goButton', 'word 3'),
        actionButton('goButton', 'word 4'), 
        actionButton('goButton', 'word 5'),
        actionButton('goButton', 'word 6')
        ),
    mainPanel(
        p('Output text1'),
        textOutput('text1') ## watch the commas!       
    )
))
