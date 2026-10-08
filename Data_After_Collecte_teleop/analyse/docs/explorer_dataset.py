#!/usr/bin/env python3
"""
Exploration complète du questionnaire COSO_VF (962 obs, 226 var).
Sorties dans le dossier analyse_QUESTIONNAIRE_VF/ :
  - 10_modules.txt          : découpage par module (A, B, C, D, E, ...)
  - 11_frequences.csv       : tableaux de fréquence de toutes les variables codées/labellisées
  - 12_manquants.csv        : taux de non-réponse par variable
  - 13_croisements.csv      : croisements clés (district x consentement, etc.)
  - 14_matrices.csv         : séries temporelles / matrice de base (si colonnes identifiées)
  - 15_profils.csv          : profils de complétude (nb de réponses, modules)
Plus un rapport synthétique 10_resume.txt.
"""

import os
import sys
import re
from collections import Counter

import pandas as pd
import numpy as np

try:
    import pyreadstat
except ImportError:
    sys.exit("Installez pyreadstat : pip install pyreadstat")

SRC = "/Users/macbookair/Desktop/CAE/COSO/COSO-repo/coso_project/Data_After_Collecte_teleop/resultats/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta"
OUT = os.path.dirname(os.path.abspath(__file__))

# ---------------------------------------------------------------------------
# 1. Lecture
# ---------------------------------------------------------------------------
print("Lecture du .dta ...")
df, meta = pyreadstat.read_dta(SRC, apply_value_formats=False)
labels_var = meta.column_names_to_labels
labels_vals = meta.variable_value_labels  # code -> libellé par variable

n_obs, n_var = df.shape
resume = []
resume.append(f"FICHIER : {os.path.basename(SRC)}")
resume.append(f"Observations : {n_obs}")
resume.append(f"Variables   : {n_var}")

# ---------------------------------------------------------------------------
# 2. Module / préfixe des variables
# ---------------------------------------------------------------------------
def module_de(col):
    m = re.match(r"^([A-Z]{1,3})", col)
    return m.group(1) if m else "AUTRE/ident"

mods = Counter(module_de(c) for c in df.columns)
with open(os.path.join(OUT, "10_modules.txt"), "w") as f:
    f.write("Distribution des variables par module (préfixe):\n\n")
    for m, nb in sorted(mods.items(), key=lambda x: (len(x[0]), x[0])):
        f.write(f"  {m:<10} {nb:>4}\n")

# ---------------------------------------------------------------------------
# 3. Fréquences des variables catégorielles/labellisées
# ---------------------------------------------------------------------------
freq_rows = []
for col in df.columns:
    if col in labels_vals:
        codes = df[col].dropna()
        n_tot = len(codes)
        cnt = codes.value_counts()
        for code, n in cnt.items():
            lib = labels_vals[col].get(code, "")
            pct = 100 * n / n_tot if n_tot else np.nan
            freq_rows.append({
                "variable": col,
                "libelle_var": labels_var.get(col, ""),
                "code": code,
                "libelle": lib,
                "n": int(n),
                "pct": round(pct, 1),
                "label": f"{code} - {lib}",
            })
        # ligne totale
        freq_rows.append({
            "variable": col, "libelle_var": labels_var.get(col, ""),
            "code": "TOTAL", "libelle": "", "n": int(n_tot),
            "pct": 100.0, "label": "TOTAL",
        })
pd.DataFrame(freq_rows).to_csv(os.path.join(OUT, "11_frequences.csv"), index=False)

# ---------------------------------------------------------------------------
# 4. Manquants
# ---------------------------------------------------------------------------
miss = pd.DataFrame({
    "variable": df.columns,
    "libelle_var": [labels_var.get(c, "") for c in df.columns],
    "module": [module_de(c) for c in df.columns],
    "type": [str(df[c].dtype) for c in df.columns],
    "n_non_manquants": df.notna().sum().values,
    "n_manquants": df.isna().sum().values,
    "pct_manquants": np.round(100 * df.isna().mean().values, 1),
})
miss = miss.sort_values("pct_manquants", ascending=False)
miss.to_csv(os.path.join(OUT, "12_manquants.csv"), index=False)

# ---------------------------------------------------------------------------
# 5. Croisements clés (ajustez la liste selon le questionnaire)
# ---------------------------------------------------------------------------
cible_consentement = "consentement" if "consentement" in df.columns else None
croisements = []

if cible_consentement and "cover_district" in df.columns:
    out = pd.crosstab(df["cover_district"], df[cible_consentement], dropna=False)
    croisements.append(("district x consentement", out))
    resume.append("")
    resume.append("consentement x district :")
    resume.append(out.head(20).to_string())

def creer_croisement(var_ligne, var_col):
    out = pd.crosstab(df[var_ligne], df[var_col], dropna=False)
    out.index = [f"{var_ligne}|{i}" for i in out.index]
    croisements.append((f"{var_ligne} x {var_col}", out))

# quelques croisements génériques si les colonnes existent
for cl in df.columns:
    pass  # placeholder : laissez libre pour paramétrer

with open(os.path.join(OUT, "13_croisements.txt"), "w") as f:
    for titre, tab in croisements:
        f.write(f"== {titre} ==\n")
        f.write(tab.to_string())
        f.write("\n\n")

# ---------------------------------------------------------------------------
# 6. Matrices (colonnes date/heure => durée; sinon listage)
# ---------------------------------------------------------------------------
date_cols = [c for c in df.columns if c.endswith(("_date", "_heure", "debut", "fin"))]
matrices = []
for c in date_cols:
    matrices.append({"type": "date/heure", "colonne": c,
                     "libelle": labels_var.get(c, "")})
with open(os.path.join(OUT, "14_matrices.csv"), "w") as f:
    if matrices:
        pd.DataFrame(matrices).drop_duplicates().to_csv(f, index=False)
    else:
        f.write("Aucune colonne date/heure identifiée.\n")

# ---------------------------------------------------------------------------
# 7. Profils de complétude par enquêté
# ---------------------------------------------------------------------------
df["nb_reponses"] = df.notna().sum(axis=1)
df["profil"] = pd.cut(
    df["nb_reponses"],
    bins=[0, 50, 100, 150, 200, 226],
    labels=["0-50", "51-100", "101-150", "151-200", "201+"],
)
profil_summary = df["profil"].value_counts().rename_axis("profil").reset_index(name="n")
profil_summary["pct"] = round(100 * profil_summary["n"] / n_obs, 1)
profil_summary.to_csv(os.path.join(OUT, "15_profils.csv"), index=False)
resume.append("")
resume.append("Profil de complétude :")
resume.append(profil_summary.to_string(index=False))

# ---------------------------------------------------------------------------
# 8. Rapport synthétique
# ---------------------------------------------------------------------------
resume.insert(0, "=" * 60)
resume.insert(1, "RAPPORT D'EXPLORATION")
resume.insert(2, "=" * 60)
with open(os.path.join(OUT, "10_resume.txt"), "w") as f:
    f.write("\n".join(resume))

print("Fichiers générés dans :", OUT)
print(sorted(os.listdir(OUT)))


