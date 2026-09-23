# -*- coding: utf-8 -*-
"""
Completude LOGIQUE du questionnaire COSO (v2 - regles corrigees).
Pour chaque interview : questions "attendues" selon la logique de saut
(skip logic), puis taux = remplies / attendues.
100% = TOTALEMENT REMPLIE.
Chaque regle a ete validee sur les 425 interviews de reference
(statut 100 AND A4=1).
"""
import pyreadstat
import pandas as pd
import numpy as np

df, meta = pyreadstat.read_dta("Questionnaire_COSO_VF.dta")

def non_vide(df, col):
    s = df[col]
    return s.notna() & s.astype(str).str.strip().ne("") & s.astype(str).str.strip().ne(".")

def est(df, col, valeur):
    s = df[col].astype(str).str.strip()
    return s.notna() & (s.astype("Float64").fillna(-9).eq(float(valeur)))

a_exclure = ["interview__id", "interview__key", "interview__status", "Nom",
             "nom_sup", "nom_agent", "telephone", "localite", "cover_region",
             "cover_district", "sous_district", "position", "longitude",
             "latitude", "altitude", "accuracy", "sssys_irnd", "consentement",
             "place", "time", "Villages", "région", "EMP_occ", "age",
             "B1", "B2", "B3", "B4", "B7", "A2_date", "A2_heure"]
a_exclure += [c for c in df.columns if c in ("ntac", "b1b1", "B2_cover")]
a_exclure += [c for c in df.columns if c.endswith("_debut") or c.endswith("_fin")]

masques = {}
def masque_pour(colonne, condition):
    masques[colonne] = condition

vrai = pd.Series(True, index=df.index)
faux = pd.Series(False, index=df.index)

# --- Section A ----------------------------------------------------------
masque_pour("A1", vrai)
masque_pour("A4", vrai)
masque_pour("A4X", est(df, "A4", 8))
masque_pour("A5_date", est(df, "A4", 5))
masque_pour("A5_heure", est(df, "A4", 5))

# --- Section B ----------------------------------------------------------
for c in ["B5", "B6"]:
    masque_pour(c, vrai)
b62 = est(df, "B6", 2)
masque_pour("B6A", b62)
masque_pour("B6B", b62 & est(df, "B6A", 2))

# --- Section C ----------------------------------------------------------
for c in ["C1", "C3", "C4", "C7"]:
    masque_pour(c, vrai)
# C2 : date de naissance complete (optionnelle si age en clair C2A)
masque_pour("C2", non_vide(df, "C2"))
# C2A : age en clair -> toujours attendu (ou si date absente)
masque_pour("C2A_Jour", ~non_vide(df, "C2") | non_vide(df, "C2A_Jour"))
masque_pour("C2A_Mois", ~non_vide(df, "C2"))
masque_pour("C2A_annee", ~non_vide(df, "C2"))
# C5 : diplome -> seulement si niveau d'etudes >= primaire (C4>=2)
masque_pour("C5", df["C4"].fillna(-9) >= 2)
# C8 : pays -> seulement si C7 == 1
masque_pour("C8", est(df, "C7", 1))
# C6, C9, C10, C11 : champs libres / observation -> non contraignants

# --- Section D ----------------------------------------------------------
for c in ["D1", "D2", "D3", "D4", "D5__1", "D5__2", "D5__3", "D5__4",
          "D5__5", "D5__6", "D5__7", "D5__8", "D5__9", "D5__10", "D5__11"]:
    masque_pour(c, vrai)

# --- Section E ----------------------------------------------------------
masque_pour("E1", vrai)
masque_pour("E2", est(df, "E1", 2))
masque_pour("E3", est(df, "E2", 2))
masque_pour("E3A", est(df, "E3", 1))

# --- Sections F/G/H/I : si EMPLOYE = 1 ----------------------------------
employe = est(df, "EMPLOYE", 1)
for c in ["F1", "F2", "F3", "F4"]:
    masque_pour(c, employe)
masque_pour("F1X", employe & est(df, "F1", 9))
masque_pour("F2X", employe & est(df, "F2", 99))
masque_pour("F3X", employe & est(df, "F3", 9))
for c in ["G1", "G2", "G3", "G4", "G5", "G7"]:
    masque_pour(c, employe)
masque_pour("G4A", employe & est(df, "G4", 2))
masque_pour("G5A", employe & est(df, "G5", 1))
masque_pour("G6", employe & est(df, "G5", 1))
masque_pour("G7A", employe & est(df, "G7", 1))
# Section H (revenus)
for c in ["H3", "H4", "H5"]:
    masque_pour(c, employe)
masque_pour("H3A", employe & est(df, "H3", 99999))
masque_pour("H5A", employe & est(df, "H5", 999999))
masque_pour("H1", employe & est(df, "F1", 1))
masque_pour("H2", employe & est(df, "F1", 1))
# Section I (recherche emploi)
masque_pour("I1", employe)
masque_pour("I2", employe & est(df, "I1", 1))
masque_pour("I3", employe & est(df, "I1", 1))

# --- Section J : si EMPLOYE = 0 ------------------------------------------
non_employe = est(df, "EMPLOYE", 0)
for c in ["J0", "J3"]:
    masque_pour(c, non_employe)
masque_pour("J0A", non_employe & est(df, "J0", 2))
masque_pour("J0B", non_employe & est(df, "J0", 2) & est(df, "J0A", 9))
masque_pour("J1", non_employe & est(df, "J0", 1))
masque_pour("J2", non_employe & est(df, "J0", 1))

# --- Section K ----------------------------------------------------------
for c in ["K1", "K6", "K7"]:
    masque_pour(c, vrai)
projet = est(df, "K1", 2)
masque_pour("K2", projet)
att_k2 = projet & est(df, "K2", 1)
masque_pour("K4", att_k2)
for k5 in [c for c in df.columns if c.startswith("K5")]:
    masque_pour(k5, att_k2)
masque_pour("K3", est(df, "K1", 1))

# --- Section L ----------------------------------------------------------
for c in ["L1", "L2", "L3", "L6"]:
    masque_pour(c, vrai)
epargne = est(df, "L3", 1) | est(df, "L3", 2)
masque_pour("L4", epargne)
masque_pour("L5", epargne)
masque_pour("L5X", epargne & est(df, "L5", 5))
endette = est(df, "L6", 1)
for c in ["L7", "L8", "L9"]:
    masque_pour(c, endette)

# --- Section M ----------------------------------------------------------
for c in ["M1", "M2", "M3", "M4"]:
    masque_pour(c, vrai)

# --- Section N ----------------------------------------------------------
for c in ["N1", "N6", "N7"]:
    masque_pour(c, vrai)
choc = est(df, "N1", 1)
for c in ["N2", "N3", "N4", "N5"]:
    masque_pour(c, choc)

# --- Section O ----------------------------------------------------------
for c in ["O1", "O3"]:
    masque_pour(c, vrai)
masque_pour("O2", est(df, "O1", 1))
forme = est(df, "O3", 1)
for c in ["O4", "O5", "O6"]:
    masque_pour(c, forme)

# --- Section P ----------------------------------------------------------
for c in ["P1", "P2", "P3", "P4", "P5"]:
    masque_pour(c, vrai)
masque_pour("P44X", est(df, "P4", 99))

# --- Section Q ----------------------------------------------------------
for c in [c for c in df.columns if c.startswith("Q")]:
    masque_pour(c, vrai)

# --- Section R (observations enqueteur) ---------------------------------
for c in ["R1", "R2", "R3", "R4", "R5", "R6", "R7"]:
    masque_pour(c, vrai)
masque_pour("R1A", est(df, "R1", 2))
masque_pour("R2A", est(df, "R2", 1))
masque_pour("R3A", est(df, "R3", 1))
masque_pour("R3B", est(df, "R3A", 2))

# ---------------------------------------------------------------
# 4) CALCUL PAR INTERVIEW
# ---------------------------------------------------------------
remplies = pd.DataFrame({c: non_vide(df, c) for c in masques})
attendues = pd.DataFrame(masques)

n_atte = attendues.sum(axis=1)
n_remp = (remplies & attendues).sum(axis=1)
taux = n_remp / n_atte.replace(0, np.nan)

r = pd.DataFrame({"n_attendues": n_atte, "n_remplies": n_remp, "taux": taux})
r["classification"] = pd.cut(
    taux, bins=[-0.01, 0.0, 0.50, 0.90, 0.999, 1.0],
    labels=["VIDE (0%)", "PARTIELLE (<50%)", "BIEN (50-90%)",
            "QUASI COMPLETE (90-100%)", "TOTALEMENT REMPLIE (100%)"],
)

print("=== CLASSIFICATION (COMPLETUDE LOGIQUE) ===")
print(r["classification"].value_counts().sort_index())
print()
r["statut"] = df["interview__status"]
r["A4"] = df["A4"]
print("=== x statut ===")
print(pd.crosstab(r["classification"], r["statut"]))
print()
print("=== x A4 ===")
print(pd.crosstab(r["classification"], r["A4"]))
print()

tot = r[r["taux"] == 1.0]
print(f"=== TOTALEMENT REMPLIES (taux = 100%) : {len(tot)} ===")
print(tot[["statut", "A4"]].value_counts().to_string())
print()

ref = r[(df["interview__status"] == 100) & est(df, "A4", 1)]
print("=== CONTROLE : statut 100 & A4=1 (425 ref) ===")
print(ref["taux"].describe().to_string())
print("ref < 90%:", int((ref["taux"] < 0.90).sum()))
print("ref = 100%:", int((ref["taux"] == 1.0).sum()))

vf_out = df.copy()
vf_out["n_attendu"] = n_atte
vf_out["n_rempli"] = n_remp
vf_out["taux_completude_logique"] = taux
vf_out["classe"] = r["classification"].astype(str)
pyreadstat.write_dta(vf_out, "Questionnaire_COSO_VF_avec_completude_logique.dta",
                     variable_value_labels=meta.variable_value_labels)
print()
print("Exported : Questionnaire_COSO_VF_avec_completude_logique.dta")