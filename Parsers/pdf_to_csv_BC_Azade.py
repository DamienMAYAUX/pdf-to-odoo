from py_pdf_parser import tables
from py_pdf_parser.loaders import load_file
import re
import csv 

def pdf_to_csv_BC_Azade(nom_fichier):
    document = load_file(nom_fichier)

    colonnes = ["nom_produit_chez_fournisseur", "quantite_totale",\
                "quantite_par_unite_achat", "code_barre", "prix_ht_par_unite_achat"]
    recherche_intro = ["Commande\tn°", "Date\tde\tcommande","Date\tde\tlivraison\tsouhaitée"]
    table = tables.extract_table(document.elements, fix_element_in_multiple_cols=True, fix_element_in_multiple_rows=True, as_text=True)
    produits = []
    introduction = [""]*4
    j = 1
    k = 0

    for i in range(len(table)):
        elem = table[i]
        if any(ext in elem for ext in recherche_intro) and k<4:
            introduction[k] = " ".join(elem).replace("\t", " ").replace("  ", "")
            k += 1
        if str(j) in elem[0]:
            produit = {}
            produit["nom_produit_chez_fournisseur"] = elem[6].replace("\t", " ").replace("\n", " ")
            produit["quantite_par_unite_achat"] = int(elem[13])
            colis = int(elem[11])
            produit["quantite_totale"] = produit["quantite_par_unite_achat"]*colis
            produit["prix_ht_par_unite_achat"] = elem[15].replace("\t€", "")
            if "EAN13" in table[i][1]:
                produit["code_barre"] = re.findall('[0-9]{13}', table[i][1])[0]
            elif "EAN13" in table[i+1][1]:
                produit["code_barre"] = re.findall('[0-9]{13}', table[i+1][1])[0]
            else:
                produit["code_barre"] = ""
            produits.append(produit)
            j+=1

    with open('{}.csv'.format(nom_fichier[:-4]), 'w', newline='') as output_file:
        output_file.write('Azade\n')
        for i in range(4):
            output_file.write('{}\n'.format(introduction[i]))  
        dict_writer = csv.DictWriter(output_file, colonnes, delimiter =';')
        dict_writer.writeheader()
        dict_writer.writerows(produits)
    