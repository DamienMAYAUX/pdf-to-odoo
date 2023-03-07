
packages <- c("tidyverse", "reticulate")

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

library(reticulate)
library(tidyverse)

py_install(c("py_pdf_parser", "pandas"), pip = T)

py_pdf_parser <- import("py_pdf_parser")
pandas <- import("pandas")
csv <- import("csv")
re <- import("re")


## CHARGEMENT DES PARSERS

R_parser_list = list.files("Parsers", pattern = ".*\\.R")
for (parser in R_parser_list){
  # parser = R_parser_list[1]
  
  tryCatch(
    { source( paste0("Parsers/",parser) ) },
    error = function(e) {print(paste("Erreur de chargement du script", parser))},
    finally = {}
  )
  
}

Python_parser_list = list.files("Parsers", pattern = ".*\\.py")
for (parser in Python_parser_list){
  # parser = python_parser_list[1]
  
  tryCatch(
    {source_python( paste0("Parsers/",parser) )},
    error = function(e) {print(paste("Erreur de chargement du script", parser))},
    finally = {}
  )
  
}

full_parser_list = list.files("Parsers")

## EXECUTION DES PARSERS SUR LES EXEMPLES

for (parser in full_parser_list){
  # parser = R_parser_list[1]
  
  tryCatch(
    {
      argument_type = str_extract(parser, "(.*)_to_csv_(.*)\\..*", group = 1) 
      document_name = str_extract(parser, "(.*)_to_csv_(.*)\\..*", group = 2)
      function_name = str_extract(parser, "(.*)\\..*", group = 1)
      argument_name = paste0("Raw/", document_name, ".", argument_type)
      
      parsing_function = get(function_name)
      parsing_function(argument_name)
    },
    error = function(e) {print(paste("Erreur lors de l'execution du script", parser))},
    finally = {}
  )
  
}
