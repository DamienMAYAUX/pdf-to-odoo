from py_pdf_parser.loaders import load_file
import csv 

def pdf_to_csv_BL_Biodis(nom_fichier):
    """ Fonction permettant d'exporter le contenu d'un bon de livraison Biodis en CSV"""
    document = load_file(nom_fichier)
    longueur_ligne = 20

    colonnes = ["nom_produit_chez_fournisseur", "quantite_totale",\
                "quantite_par_unite_achat", "code_barre", "prix_ht_par_unite_achat"]
    elems_txt = [e.text() for e in document.elements]
    produits = []
    intro = False
    introduction = [""]*4

    for i in range(len(elems_txt)-2):
        if elems_txt[i]=="Commande n°" and not intro:
            for j in range(4):
                introduction[j] = elems_txt[i+j]
            intro = True
        if elems_txt[i].isdigit() and elems_txt[i+2].isdigit() and len(elems_txt[i+2]) == 13:
            produit = {}
            produit["code_barre"] = elems_txt[i+2]
            produit["quantite_totale"] = elems_txt[i+4]
            produit["quantite_par_unite_achat"] = int(elems_txt[i+4]) / int(elems_txt[i+3])
            prix_trouve = False
            for j in range(longueur_ligne):
                if "Prix brut" in elems_txt[i+j]: #Produit classique : on prend le prix sans remise
                    produit["prix_ht_par_unite_achat"] = elems_txt[i+j+1].replace(",",".")
                    produit["nom_produit_chez_fournisseur"] = elems_txt[i+j-1].replace("\n","")
                    prix_trouve = True
            if not prix_trouve: #Pas de prix brut trouve : on a donc un produit Elibio et on extrait le prix net
                for j in range(longueur_ligne):
                    if "Prix Net" in elems_txt[i+j]:
                        produit["prix_ht_par_unite_achat"] = elems_txt[i+j].split()[-1].replace(",",".")
                        produit["nom_produit_chez_fournisseur"] = elems_txt[i+j-1].replace("\n","")
            produits.append(produit)

    with open('{}.csv'.format(nom_fichier[:-4]), 'w', newline='') as output_file:
        output_file.write('Biodis\n')
        for i in range(4):
            output_file.write('{}\n'.format(introduction[i]))  
        dict_writer = csv.DictWriter(output_file, colonnes, delimiter =';')
        dict_writer.writeheader()
        dict_writer.writerows(produits)
