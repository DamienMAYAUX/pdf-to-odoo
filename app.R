
packages <- c("tidyverse", "reticulate", "shiny")

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

library(reticulate)
library(tidyverse)
library(shiny)

## CHARGEMENT DES PARSERS

# Liste des parseurs
full_parser_list = list.files("Parsers")
Python_parser_list = list.files("Parsers", pattern = ".*\\.py")
R_parser_list = list.files("Parsers", pattern = ".*\\.R")

# Liste des grossistes
wholesaler_list = str_extract(full_parser_list, "(.*)_to_csv_(.*)_(.*)\\..*", group = 3)

# Liste des parseurs disponibles pour chaque grossiste (liste de liste)
format_type_list_per_wholesaler = wholesaler_list%>% 
  lapply( function(wholesaler){grep(wholesaler, full_parser_list, value = TRUE)} )%>%
  lapply( 
    function(parser_list){
      paste(
        str_extract(parser_list, "(.*)_to_csv_(.*)_(.*)\\..*", group = 2),
        str_extract(parser_list, "(.*)_to_csv_(.*)\\..*", group = 1)
      )
      } 
    )
# Parseurs Python
for (parser in R_parser_list){
  # parser = R_parser_list[1]
  tryCatch(
    { source( paste0("Parsers/",parser) ) },
    error = function(e) {print(paste("Erreur de chargement du script", parser))},
    finally = {}
  )
}

# Parseurs R
for (parser in Python_parser_list){
  # parser = python_parser_list[1]
  tryCatch(
    {source_python( paste0("Parsers/",parser) )},
    error = function(e) {print(paste("Erreur de chargement du script", parser))},
    finally = {}
  )
}



## INTERFACE
ui <- fluidPage(

    # TITRE
    titlePanel("Importation de commandes"),

    sidebarLayout(
      
        # PANNEAU LATERAL
        sidebarPanel(
          
            # Selection du grossiste
            selectInput(
              "wholesaler",
              "Grossiste",
              choices = wholesaler_list,
              selected = wholesaler_list[1],
            ),
            
            # Selection du type (BC, BL, F) et format (pdf, xls, xlsx) du document en entree 
            uiOutput("type_and_format"),
            
            # Bouton de chargement du document
            fileInput("wholesaler_file", "Document de commande", accept = ".pdf")
            
        ),

        # PANNEAU PRINCIPAL
        mainPanel(
          
          # Affichage du csv de reference produit par le parseur
          tableOutput("table_reference_csv")
           
        )
    )
)

## SERVEUR
server <- function(input, output) {

  # Generation de l'interface de choix d'un type et format de document selon le grossiste choisi
  output$type_and_format <- renderUI({
    radioButtons(
      "type_and_format",
      "Type et format du document",
      choices = format_type_list_per_wholesaler[input$wholesaler == wholesaler_list],
      selected = format_type_list_per_wholesaler[input$wholesaler == wholesaler_list][[1]]
    )
  })
  
  # Fichier csv de reference importe
  df_reference_csv <- reactive(
    {
      type = str_extract(input$type_and_format, "(.*) (.*)", group = 1)
      format = str_extract(input$type_and_format, "(.*) (.*)", group = 2)
      
      parsing_function_name = paste0(format, "_to_csv_", type, "_", input$wholesaler)
      parsing_function = get(parsing_function_name)
      
      csv_file_name = paste0(type, "_", input$wholesaler, ".csv")
      parsing_function(gsub("/","\\\\",input$wholesaler_file$datapath))
      
      read.table(csv_file_name, sep = ";", skip = 5, header = TRUE)
    })
  
  
  # Table
  output$table_reference_csv <- renderTable(
    df_reference_csv()
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)
