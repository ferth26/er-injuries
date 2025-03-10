#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


library(shiny)
library(vroom)
library(tidyverse)

count_top <- function(df, var, n = 5) {
  df %>%
    mutate({
      {
        var
      }
    } := fct_lump(fct_infreq({
      {
        var
      }
    }), n = n)) %>%
    group_by({
      {
        var
      }
    }) %>%
    summarise(n = as.integer(sum(weight)))
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  selected <- reactive(injuries %>% filter(prod_code == input$code))
  
  output$diag <- renderTable({
    count_top(selected(), diag)
  }, width = "100%")
  
  output$body_part <- renderTable({
    count_top(selected(), body_part)
  }, width = "100%")
  
  output$location <- renderTable({
    count_top(selected(), location)
  }, width = "100%")
  
  summary <- reactive({
    selected() %>%
      count(age, sex, wt = weight) %>%
      left_join(population, by = c("age", "sex")) %>%
      mutate(rate = n / population * 1e4)
  })
  
  output$age_sex <- renderPlot({
    if (input$y == "count") {
      summary() %>%
        ggplot(aes(age, n, colour = sex)) +
        geom_line() +
        labs(y = "Estimated number of injuries")
    } else {
      summary() %>%
        ggplot(aes(age, rate, colour = sex)) +
        geom_line(na.rm = TRUE) +
        labs(y = "Injuries per 10,000 people")
    }
  }, res = 96)
})
