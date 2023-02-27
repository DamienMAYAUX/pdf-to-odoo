# pdf-to-odoo
Outil permettant de convertir les pdf de bons de livraison et factures de grosssistes dans l'alimentaire en csv directement importables dans Odoo

* L'application RShiny app.R 
  
- prend en entrée :
  - une facture, un bon de livraison ou un bon de commande au format pdf (ou xls) d'un fournisseur
  - un état de l'inventaire exporté depuis Odoo
  - une liste des produits exportée depuis Odoo

- utilise 
  - le script xxx_to_csv_YY.R ou xxx_to_csv_YY_ZZ.py adapté au fichier de type YY de format XXX du fournisseur ZZ donné en entrée pour obtenir un fichier csv des nouveaux produits et de leurs prix (voir format csv de référence)

- renvoie :
  - un état de l'inventaire actualisé destiné à être importé dans Odoo 
  - une liste des produits avec de nouveaux prix destinée à être importée dans Odoo 


* Les scripts pour transformer les fichiers fournisseurs en csv au format de référence

- ces scripts s'appellent XX_to_csv_YY_ZZ.R ou XX_to_csv_YY_ZZ.py où 
  - XX est le nom du format d'origine
  - YY est le nom du type de document (F pour facture, BL pour bon de livraison, BC pour bon de commande)
  - ZZ est le nom du fournisseur
  
- ces scripts contiennent une fonction XX_to_csv_YY_ZZ qui 
  - prend en argument le nom d'un fichier au format XX
  - renvoie un fichier YY_ZZ.csv
