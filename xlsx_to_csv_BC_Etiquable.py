import pandas as pd

def xlsx_to_csv_BC_Etiquable(nom_fichier):
    nom_fichier_csv = "{}.csv".format(nom_fichier[:-5])
    introduction = ["Ethiquable\n"]*5
    df = pd.read_excel(nom_fichier , header=10)
    df = df[(~df["GENCOD"].isna())&(df["GENCOD"] != "GENCOD")&(~df['Qté \nCdé \ncolis'].isna())]

    colonnes = ["nom_produit_chez_fournisseur", "quantite_totale",\
                    "quantite_par_unite_achat", "code_barre", "prix_ht_par_unite_achat", "taux_tva"]

    dico = {"GENCOD":"code_barre", "DESIGNATION":"nom_produit_chez_fournisseur",\
            "Tarif NET HT":"prix_ht_par_unite_achat", "PCB \nUVC\nColis":"quantite_par_unite_achat",\
            "TVA":"taux_tva", "Qté \nCdé \ncolis":"quantite_colis" }

    df = df.rename(columns=dico)
    df["quantite_totale"] = df["quantite_colis"].astype(int) * df["quantite_par_unite_achat"].astype(int)
    df = df[["nom_produit_chez_fournisseur", "quantite_totale", "quantite_par_unite_achat", "code_barre", "prix_ht_par_unite_achat", "taux_tva"]]
    df = df[df.columns.intersection(colonnes)]
    df['nom_produit_chez_fournisseur'] = df['nom_produit_chez_fournisseur'].str.replace('  ','')

    with open(nom_fichier_csv,'w') as f:
        for i in range(5):
            f.write(introduction[i])
    df.to_csv(nom_fichier_csv, mode='a', index=False) 
