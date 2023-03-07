
packages <- c("tidyverse", "reticulate", "shiny")

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

library(reticulate)
library(tidyverse)
library(shiny)

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


# INTERFACE
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
              selected = wholesaler_list,
              multiple = TRUE
            ),
            
            # Selection du type (BC, BL, F) et format (pdf, xls, xlsx) du document en entree 
            uiOutput("type_and_format"),
            
            # Bouton de chargement du document
            fileInput("wholesaler_file", "Document de commande", accept = ".pdf"),
            
            # Bouton d'execution du parser sur le document
            actionButton("parsing_button", "Parser le document")
            
        ),

        # PANNEAU PRINCIPAL
        mainPanel(
          
          # Affichage du csv de reference produit par le parseur
          tableOutput("table_reference_csv")
           
        )
    )
)

# SERVEUR
server <- function(input, output) {

  # Generation de l'interface de choix d'un type et format de document selon le grossiste choisi
  output$type_and_format <- renderHTML({

    
    
    selectInput(
      "type_and_format",
      "TYpe et format du document",
      choices = wholesaler_list,
      selected = wholesaler_list,
      multiple = TRUE
    )
    
    
  })
  
  # Fichier csv de reference importe
  
  
  
  # Table
  output$table_reference_csv <- renderTable(
    read.table(input$wholesaler_file, sep = ";", skip = 5)
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)
