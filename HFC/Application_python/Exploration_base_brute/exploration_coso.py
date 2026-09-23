# -*- coding: utf-8 -*-
"""
Exploration + controle de coherence de la derniere base brute COSO.

Fichier a cellules `#%%` : s'ouvre tel quel dans Spyder (Ctrl+Entree par cellule)
et dans Jupyter / VS Code (chaque `#%%` devient une cellule).

Il trouve tout seul le dernier export Survey Solutions dans Bases/Base_brute,
affiche l'etat d'avancement, liste les incoherences et exporte les lignes
concernees dans un classeur Excel (un onglet par anomalie).
"""

#%% Imports et localisation du dernier export
import re
from pathlib import Path

import numpy as np
import pandas as pd

pd.set_option("display.width", 250)
pd.set_option("display.max_columns", 60)

BASE_BRUTE = Path(
    "/Users/macbookair/Desktop/CAE/COSO/COSO-repo/coso_project/HFC/Bases/Base_brute"
)

# les exports SuSo sont nommes ..._<AAAAMMJJ>T<HHMM>Z -> le tri alphabetique suffit
EXPORTS = sorted(p for p in BASE_BRUTE.iterdir() if p.is_dir())
assert EXPORTS, f"aucun export trouve dans {BASE_BRUTE}"
EXPORT = EXPORTS[-1]
print("Export analyse :", EXPORT.name)

MAIN_DTA = next(EXPORT.glob("Questionnaire_COSO_V*.dta"))
SORTIE_XLSX = EXPORT.parent / f"Anomalies_{EXPORT.name}.xlsx"


#%% Chargement
def lire(nom):
    """Lit un .dta de l'export en gardant les codes numeriques."""
    return pd.read_stata(EXPORT / nom, convert_categoricals=False)


d = lire(MAIN_DTA.name)
diag = lire("interview__diagnostics.dta").drop(columns=["interview__status"])
erreurs = lire("interview__errors.dta")
actions = lire("interview__actions.dta")

d = d.merge(diag, on=["interview__id", "interview__key"], how="left").copy()

# duree en minutes depuis le format SuSo "JJ.HH:MM:SS"
_dur = d["interview__duration"].str.extract(r"(\d+)\.(\d+):(\d+):(\d+)").astype(float)
d["duree_min"] = _dur[0] * 1440 + _dur[1] * 60 + _dur[2] + _dur[3] / 60

# codes NSP/refus de Survey Solutions : a neutraliser AVANT toute stat
CODES_NSP = [-7972, 9998, 9999, -9998, -9999]
for col in ["age", "C2A_Jour", "C2A_Mois", "C2A_annee"]:
    d[col] = pd.to_numeric(d[col], errors="coerce").replace(CODES_NSP, np.nan)

print(f"{len(d)} interviews, {d.shape[1]} variables")


#%% Helpers
def vide(s):
    """True la ou la valeur est absente / vide / ##N/A## (marche sur Series et DataFrame)."""
    if isinstance(s, pd.DataFrame):
        return s.apply(vide)
    return s.astype(str).str.strip().replace({"nan": "", "##N/A##": ""}) == ""


def horo(col):
    return pd.to_datetime(d[col], errors="coerce")


SECTIONS = list("ABCDEFGHIJKLMNOPQR")

STATUTS = {
    60: "60 remplie, attente superviseur",
    65: "65 validee superviseur, attente HQ",
    100: "100 approuvee HQ",
    80: "80 rejetee superviseur",
    125: "125 rejetee HQ",
}

# rempli par `flag()`, exporte en fin de script
ANOMALIES = {}


def flag(nom, masque, colonnes=("interview__key", "responsible", "cover_region")):
    """Enregistre les lignes en anomalie et affiche le compte."""
    masque = masque.fillna(False)
    cols = [c for c in list(colonnes) if c in d.columns]
    # nom d'onglet Excel : 31 caracteres max, sans []:*?/\
    onglet = re.sub(r"[\[\]:*?/\\]", "", nom)[:31]
    ANOMALIES[onglet] = d.loc[masque, cols]
    print(f"{masque.sum():5d}  {nom}")
    return masque


#%% 1. Etat d'avancement
print("--- Statuts ---")
print(d["interview__status"].map(STATUTS).value_counts().to_string())

print("\n--- Resultat de l'entretien (A4) ---")
print(d["A4"].value_counts(dropna=False).sort_index().to_string())

print("\n--- Consentement ---")
print(d["consentement"].value_counts(dropna=False).to_string())

debut, fin = horo("HHA_debut"), horo("HHR_fin")
print(f"\nPeriode de collecte : {debut.min()}  ->  {debut.max()}")
print("Derniere action serveur :", pd.to_datetime(actions["date"] + " " + actions["time"]).max())
print(f"Duree medianne d'entretien : {d['duree_min'].median():.1f} min")

print("\n--- Interviews par jour ---")
print(debut.dt.date.value_counts().sort_index().to_string())

print("\n--- Region x statut ---")
print(pd.crosstab(d["cover_region"], d["interview__status"], margins=True))


#%% 2. Suivi par agent
agents = (
    d.groupby("responsible")
    .agg(
        n=("interview__id", "size"),
        validees=("interview__status", lambda x: (x >= 65).sum()),
        duree_med=("duree_min", "median"),
        rejets=("rejections__sup", "sum"),
        q_sans_reponse=("n_questions_unanswered", "mean"),
    )
    .assign(taux_validation=lambda t: (t.validees / t.n * 100).round(1))
    .sort_values("duree_med")
)
print(agents.to_string())
print("\nAgents a controler (duree medianne < 15 min) :")
print(agents[agents.duree_med < 15].to_string())


#%% 3. Incoherences - identification
print("--- Identification ---")
for col in ["cover_id", "telephone", "nom"]:
    flag(f"doublon {col}", d[col].astype(str).str.strip().duplicated(keep=False),
         ("interview__key", col, "nom", "telephone", "cover_region", "responsible"))

# meme cover_id mais telephones differents -> id reutilise ou echantillon double
par_id = d.groupby("cover_id")["telephone"].nunique()
flag("cover_id reutilise (tel differents)", d["cover_id"].map(par_id) > 1,
     ("interview__key", "cover_id", "nom", "telephone", "cover_region"))

tel_num = d["telephone"].astype(str).str.replace(r"\D", "", regex=True)
flag("telephone != 10 chiffres", (~vide(d["telephone"])) & (tel_num.str.len() != 10),
     ("interview__key", "telephone", "responsible"))


#%% 4. Incoherences - filtres et coherence du questionnaire
print("--- Questionnaire ---")
sec_debut = [f"HH{s}_debut" for s in "CDEFGHIJKLMNOPQR"]
demarrees = (~vide(d[sec_debut])).sum(axis=1)

flag("A4 vide alors que statut >= 60", d["A4"].isna())
flag("A4 vide mais deja validee", d["A4"].isna() & (d["interview__status"] >= 65))
flag("A4=acheve mais consentement != oui", (d["A4"] == 1) & (d["consentement"] != 1))
flag("consentement=non mais sections remplies", (d["consentement"] == 0) & (demarrees > 0))
flag("consentement=oui mais aucune section", (d["consentement"] == 1) & (demarrees == 0))
flag("questions sans reponse", d["n_questions_unanswered"] > 0)

# sections ouvertes sans horodatage de fin
for s in SECTIONS:
    a, b = f"HH{s}_debut", f"HH{s}_fin"
    if a in d and b in d:
        m = (~vide(d[a])) & (vide(d[b]))
        if m.sum():
            flag(f"section {s} sans horodatage de fin", m)


#%% 5. Incoherences - dates, durees, plausibilite
print("--- Dates et durees ---")
flag("HHR_fin anterieur a HHA_debut", fin < debut,
     ("interview__key", "HHA_debut", "HHR_fin", "responsible"))
flag("A5_date (RDV) avant A2_date (appel)", horo("A5_date") < horo("A2_date"),
     ("interview__key", "A2_date", "A5_date", "responsible"))
flag("duree < 5 min", d["duree_min"] < 5,
     ("interview__key", "duree_min", "interview__status", "A4", "responsible"))
flag("duree < 5 min mais deja validee",
     (d["duree_min"] < 5) & (d["interview__status"] >= 65),
     ("interview__key", "duree_min", "interview__status", "A4", "responsible"))
flag("A4=acheve mais duree < 10 min", (d["A4"] == 1) & (d["duree_min"] < 10),
     ("interview__key", "duree_min", "A4", "responsible"))
flag("duree > 180 min (session laissee ouverte)", d["duree_min"] > 180,
     ("interview__key", "duree_min", "responsible"))

print("--- Plausibilite ---")
flag("age hors [15, 70]", ~d["age"].between(15, 70) & d["age"].notna(),
     ("interview__key", "age", "C2A_annee", "responsible"))
ecart = (d["age"] - (2026 - d["C2A_annee"])).abs()
flag("age incoherent avec annee de naissance", ecart > 1,
     ("interview__key", "age", "C2A_annee", "responsible"))
flag("annee de naissance hors [1950, 2011]",
     d["C2A_annee"].notna() & ~d["C2A_annee"].between(1950, 2011),
     ("interview__key", "C2A_annee", "responsible"))
flag("nom recueilli (B7) absent", vide(d["B7"]), ("interview__key", "B7", "responsible"))

print("\nErreurs de validation remontees par le questionnaire :", len(erreurs))
print(erreurs.to_string())


#%% 6. Export Excel : un onglet par anomalie non vide
recap = pd.DataFrame(
    [(nom, len(t)) for nom, t in ANOMALIES.items()], columns=["anomalie", "n_lignes"]
).sort_values("n_lignes", ascending=False)

with pd.ExcelWriter(SORTIE_XLSX, engine="openpyxl") as xl:
    recap.to_excel(xl, sheet_name="Recapitulatif", index=False)
    agents.to_excel(xl, sheet_name="Suivi_agents")
    for nom, table in ANOMALIES.items():
        if len(table):
            table.to_excel(xl, sheet_name=nom, index=False)

print(recap.to_string(index=False))
print("\nExporte ->", SORTIE_XLSX)


#%% 7. Auto-controle (echoue si la logique de detection casse)
def _autocontrole():
    t = pd.DataFrame({"x": ["a", " ", "##N/A##", np.nan, "b"]})
    assert vide(t["x"]).tolist() == [False, True, True, True, False]
    assert d["age"].max() < 120, "codes NSP non neutralises sur age"
    assert d["duree_min"].notna().sum() > 0, "parsing de interview__duration casse"
    assert set(ANOMALIES) and all(
        isinstance(v, pd.DataFrame) for v in ANOMALIES.values()
    ), "aucune anomalie collectee"
    print("auto-controle OK")


_autocontrole()
