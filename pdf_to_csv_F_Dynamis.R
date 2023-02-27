
## Installation des librairies, si necessaire

packages <- c("tidyverse", "Rcpp", "pdftools")

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}



## Chargement des librairies

library(tidyverse)
# Librairie essentielle, contient notamment
# - dplyr pour manipuler des dataframes
# - stringr pour les expressions rationelles

library(Rcpp)
# Librairie requise pour le fonctionnement de pdftools

library(pdftools)
# Librairie utilisée pour parser les pdf



## Fonction principale

pdf_to_csv_F_Dynamis = function(path_to_file){
  # Prend en entree le chemin d'acces au fichier pdf a traiter
  # Ecrit un fichier csv au format de reference dans le repertoire courant
  
  #####################################################################
  
  ## On transforme le pdf en un tres long fichier texte
  
  bill_text = pdf_text(path_to_file)
  # bill_text est une liste contenant une chaine de caractere unique par page du pdf initial
  
  #####################################################################
    
  ## Extraction de champs specifiques a la commande
  
  # Date de la commmande
  bill_date = bill_text%>%
    str_extract("(?<=DU)[:blank:]*[0-9]{2}/[0-9]{2}/[0-9]{2}")%>%
    unique()%>% # enleve les doublons
    .[1] # ne consver 
  # print(bill_date)
    
  # La commande est-elle un avoir ?
  bill_avoir = bill_text%>%
    str_detect("[aA][vV][Oo][iI][rR]")%>%
    .[1]
  # print(bill_avoir)
  
  #####################################################################
    
  ## Extraction de champs specifiques aux produits
    
    df_bill = bill_text%>% 
    
    map(~str_split(., pattern = "\\n"))%>%
    # Pour chaque chaine de caractere correspondant a une page, 
    # on obtient une liste de chaines de caracteres en decoupant la chaine initiale a chaque retour a la ligne
    
    map(~.[[1]])%>%
    
    map(~str_subset(., pattern = "^[a-zA-Z].*[0-9]$"))%>% 
    # On ne garde que les lignes contenant certaines chaines de caracteres
    
    map(~str_subset(., pattern = "(Client)|(B.L)|(Echéance)", negate = T))%>% 
    # On ne garde que les lignes ne contenant pas certaines chaines de caracteres
    
    map(~str_split(., pattern = "[:blank:]{3,}"))%>%
    # Pour chaque chaine de caractere correspondant a une ligne, 
    # on obtient une liste de chaine de caracteres en decoupant la ligne initiale a chaque vide important
    
    unlist(recursive = F)%>%
    # On transforme la liste de liste (premiere liste de pages, deuxieme liste de lignes, une liste de variables par ligne)
    # en une liste unique des lignes de toutes les pages contenant avec une liste de variables par ligne 
    
    do.call(rbind, .)%>%
    
    # On transforme la liste de liste obtenue au format dataframe 
    as.data.frame()%>%
    
    # On renomme les informations extraites de la table
    rename(
      product = V1,
      number = V2,
      quantity = V3,
      mass = V4,
      unit_price = V5,
      pretax_price = V6
      # V1 est le nom donne par defaut a la premiere colonne de la dataframe
    )%>%
    mutate(
      pretax_price = ifelse(str_detect(unit_price, "[A-Z]{2,}"), mass, pretax_price),
      mass = ifelse(str_detect(unit_price, "[A-Z]{2,}"), NA_character_, mass),
      mass = ifelse(is.na(mass), NA_character_, mass),
      unit_price = ifelse(is.na(mass), quantity, unit_price),
      quantity = ifelse(is.na(mass), NA_character_, quantity),
      unit = str_extract(unit_price, "[A-Z]"),
      unit_price = str_replace_all(unit_price, "[^0-9\\.]", ""),
      #date = bill_date,
      #is_avoir = bill_avoir
    )%>%
    mutate_at(
      vars(number, quantity, mass, unit_price, pretax_price),
      as.numeric
    )%>%
    rename(
      nom_product_chez_fournisseur = product,
      quantite_totale = quantity,
      prix_achat_ht_par_unite_achat = unit_price,
      masse = mass,
      unite_quantite = unit,
      prix_achat_ht_total = pretax_price,
      nombre_colisage = number
    )
  
  ## Ecriture du fichier csv
  
  conn = file("F_Dynamis.csv", "w")
  
  cat( bill_avoir, file = conn, sep = "\n" )
  cat( bill_date, file = conn, sep = "\n" )
  cat(file = conn, sep = "\n")
  cat(file = conn, sep = "\n")
  cat(file = conn, sep = "\n")
  
  write.table(
    df_bill, 
    file = "F_Dynamis.csv",
    append = TRUE,
    row.names = FALSE,
    col.names = TRUE,
    sep = ";",
    eol = "\n",
    dec = ".",
    quote = FALSE,
    fileEncoding = "UTF-8"
  )
  
  unlink(conn)
  
}


# setwd("D:/Users/Louise/Desktop/Coop14")
# path_to_file = "LCR Dynamis facture_client_462766_21-05-2022_L135.pdf"
# pdf_to_csv_F_Dynamis(file_path)


