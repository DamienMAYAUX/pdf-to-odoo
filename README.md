# pdf-to-odoo
Outil permettant de convertir les pdf de bons de livraison et factures de grosssistes dans l'alimentaire en csv directement importables dans Odoo

L'application RShiny app.R 
  
- prend en entrée :
  - une facture, un bon de livraison ou un bon de commande au format pdf (ou xls) d'un fournisseur
  - un état de l'inventaire exporté depuis Odoo
  - une liste des produits exportée depuis Odoo

- utilise 
  - le script XX_to_csv_YY.R ou XX_to_csv_YY_ZZ.py adapté au fichier de type YY de format XX du fournisseur ZZ donné en entrée pour produire un fichier au format csv de référence

- renvoie :
  - un état de l'inventaire actualisé destiné à être importé dans Odoo 
  - une liste des produits avec de nouveaux prix destinée à être importée dans Odoo 


Les scripts pour transformer les fichiers fournisseurs en csv au format de référence

- s'appellent XX_to_csv_YY_ZZ.R ou XX_to_csv_YY_ZZ.py où 
  - XX est le nom du format d'origine
  - YY est le nom du type de document (F pour facture, BL pour bon de livraison, BC pour bon de commande)
  - ZZ est le nom du fournisseur
  
- contiennent une fonction XX_to_csv_YY_ZZ qui 
  - prend en argument le nom d'un fichier au format XX
  - écrit un fichier YY_ZZ.csv au format csv de référence dans le répertoire de travail (pas nécessairement celui où se trouve le fichier)


Le format csv de référence

- le format est le suivant
  - les cinq premières lignes peuvent être utilisées pour stocker des messages spécifiques à la commandes ("skip = 5")
  - la sixième ligne contient le nom des variables
  - le séparateur est le point virgule 
  - les nombres décimaux sont ecrits avec un point au lieu d'une virgule
  - le contenu des variables textuelles ne doivent pas être entre guillemets (pas de "quote")
  - l'encodage des caractères doit être utf-8 et le retour à la ligne est \n (et non \r\n) 
  - voir l'exemple modele_csv_reference.csv

- contient obligatoirement les variables
  - "nom_produit_chez_fournisseur"
  - "quantite_totale"
  - "quantite_par_unite_achat"
  - "prix_achat_ht_par_unite_achat"
  - "code_barre", si le produit a un code-barre

- contient accessoirement d'autres variables de description des produits
  - si elles sont disponibles, on pourra ajouter les variables suivantes (origine, label, taux_tva, prix_ttc_par_unite_achat)
  - on peut éventuellement rajouter d'autres variables relatives aux produits, après avoir vérifié qu'elles n'ont pas d'équivalent dans la liste précédente et en choisissant un nom explicite, concis, en utilisant des _ au lieu des espaces.
  - ces variables ne contiennent que des informations qui sonts pas spécifiques à un ou plusieurs produits, pas des informations portant sur la commande en général 

- contient accessoirement dans les cinq premières lignes des informations relatives à la commande
  - si elles sont disponibles, on pourra y ajouter le texte du document qui donne les informations suivantes (le document est un avoir, annonce exceptionnelle du fournisseur sur le document)
  - laisser la ligne vide si l'on ne souhaite pas faire figurer d'information supplémentaire
  - ne pas insérer de retour à la ligne dans le texte qu'on copie dans une des lignes
