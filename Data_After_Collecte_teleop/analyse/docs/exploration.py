import pyreadstat, pandas as pd, os

SRC = "/Users/macbookair/Desktop/CAE/COSO/COSO-repo/coso_project/Data_After_Collecte_teleop/resultats/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta"
OUT = os.path.dirname(os.path.abspath(__file__))

df, meta = pyreadstat.read_dta(SRC, apply_value_formats=False)

with open(os.path.join(OUT, "01_structure.txt"), "w") as f:
    f.write(f"Observations: {df.shape[0]}\nVariables: {df.shape[1]}\n\n")
    f.write("VARIABLES:\n")
    for c in df.columns:
        lab = meta.column_names_to_labels.get(c, "")
        f.write(f"  {c} | {df[c].dtype} | non-null={df[c].notna().sum()} | manquants={df[c].isna().sum()} | {lab}\n")

# dossier de valeurs labellisees
labrows = []
for var, fmt in meta.variable_value_labels.items():
    for val, lbl in fmt.items():
        labrows.append({"variable": var, "valeur": val, "libelle": lbl})
pd.DataFrame(labrows).to_csv(os.path.join(OUT, "02_labels_valeurs.csv"), index=False)

# apercu
df.head(50).to_csv(os.path.join(OUT, "03_apercu_50_lignes.csv"), index=False)

# statistiques descriptives basiques pour numeriques
df.describe(include="all").T.to_csv(os.path.join(OUT, "04_descriptif.csv"))

print(df.shape)
print(df.dtypes.value_counts())
