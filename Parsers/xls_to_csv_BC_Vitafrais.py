import pandas as pd

def xls_to_csv_BC_Vitafrais(nom_fichier):
    nom_fichier_csv = "{}.csv".format(nom_fichier[:-4])
    introduction = ["Vitafrais"]*5
    df = pd.read_excel(nom_fichier)

    colonnes = ["nom_produit_chez_fournisseur", "quantite_totale",\
                "quantite_par_unite_achat", "code_barre", "prix_ht_par_unite_achat"]

    df = df[~df["Prix"].isna()]
    df["Prix_brut"] = df.Prix.apply(lambda x: x.split("€ Brut")[0].replace(",","."))

    dico = {"Code EAN":"code_barre", "Désignation":"nom_produit_chez_fournisseur",\
                "Prix_brut":"prix_ht_par_unite_achat", "PCB":"quantite_par_unite_achat",\
                "Quantité":"quantite_totale" }

    df = df.rename(columns=dico)
    df = df[df.columns.intersection(colonnes)]
    df['code_barre'] = df['code_barre'].str.replace('"','')

    with open(nom_fichier_csv,'w') as f:
        for i in range(5):
            f.write(introduction[i])
    df.to_csv(nom_fichier_csv, mode='a', index=False)