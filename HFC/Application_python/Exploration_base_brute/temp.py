# -*- coding: utf-8 -*-
"""
Exploration statistique de la base brute COSO (Questionnaire_COSO_V5.dta).

Fichier a cellules `#%%` : s'ouvre tel quel dans Spyder (Ctrl+Entree) et dans
Jupyter / VS Code (chaque `#%%` devient une cellule).

Il localise tout seul le dernier export Survey Solutions dans Bases/Base_brute,
applique les libelles de la version active du questionnaire et produit :

  1. l'etat d'avancement (statuts, regions, agents, rythme) ;
  2. le profil des non-reponses (par variable, par section, par interview) ;
  3. la distribution de chaque question (sections A -> R) ;
  4. l'analyse des questions a choix multiples (D5, K5) ;
  5. un rapport Excel (un onglet par theme) dans le dossier de l'export.

Les codes de non-reponse Survey Solutions (NSP/refus : -7972, 9998, 9999,
-9998, -9999) sont neutralises avant tout calcul.
"""

#%% Imports et localisation du dernier export
from pathlib import Path

import numpy as np
import pandas as pd
import pyreadstat

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

MAIN_DTA = EXPORT / "Questionnaire_COSO_V5.dta"
SORTIE_XLSX = EXPORT / f"Exploration_{EXPORT.name}.xlsx"
DIAG = EXPORT / "interview__diagnostics.dta"

CODES_NSP = [-7972, 9998, 9999, -9998, -9999]
SECTIONS = list("ABCDEFGHIJKLMNOPQR")


#%% Chargement (codes numeriques + libelles de la version active)
df, meta = pyreadstat.read_dta(str(MAIN_DTA))
LIBELLES = meta.variable_value_labels   # {col: {code: libelle}}
LIB_COLS = meta.column_names_to_labels  # {col: texte de la question}

# metadata des .dta complementaires
if DIAG.exists():
    dg, _ = pyreadstat.read_dta(str(DIAG))
    if "interview__status" in dg.columns:
        dg = dg.drop(columns="interview__status")
    df = df.merge(dg, on=["interview__id", "interview__key"], how="left").copy()

erreurs = None
if (EXPORT / "interview__errors.dta").exists():
    erreurs, _ = pyreadstat.read_dta(str(EXPORT / "interview__errors.dta"))

# neutralisation des codes NSP/refus et passage en numerique des variables numeriques
for c in ["C2", "age", "C2A_Jour", "C2A_Mois", "C2A_annee"]:
    df[c] = pd.to_numeric(df[c], errors="coerce").replace(CODES_NSP, np.nan)

# duree totale : HHA_debut -> HHR_fin (format ISO "AAAA-MM-JJTHH:MM:SS")
df["duree_min"] = np.nan
debut = pd.to_datetime(df["HHA_debut"], errors="coerce")
fin = pd.to_datetime(df["HHR_fin"], errors="coerce")
df.loc[fin.notna() & debut.notna(), "duree_min"] = (fin - debut).dt.total_seconds() / 60

print(f"{len(df)} interviews, {df.shape[1]} variables")


#%% Helpers
def vide(s):
    """True la ou la valeur est absente / vide / ##N/A## (Series ou DataFrame)."""
    if isinstance(s, pd.DataFrame):
        return s.apply(vide)
    return s.astype(str).str.strip().replace({"nan": "", "##N/A##": ""}) == ""


def libelle(col, code):
    """Libelle associe a un code numerique, sinon le code lui-meme."""
    d = LIBELLES.get(col)
    if d is not None:
        try:
            return d.get(int(code), code)
        except (TypeError, ValueError):
            return code
    return code


def table(col, maxi=15):
    """Effectifs d'une colonne avec libelles, codes NSP neutralises."""
    s = pd.to_numeric(df[col], errors="coerce").replace(CODES_NSP, np.nan)
    vc = s.dropna().value_counts()
    vc.index = [libelle(col, k) for k in vc.index]
    return vc.head(maxi)


def questions(section):
    """Questions d'une section (hors horodates et fractions de choix multiples)."""
    return [
        c for c in df.columns
        if c.startswith(section) and "__" not in c and not c.startswith(f"HH{section}")
    ]


#%% 1. Etat d'avancement
print("=== Etat d'avancement ===")
print("--- Statuts ---")
print(df["interview__status"].value_counts().to_string())

print("\n--- Resultat de l'appel (A4) ---")
print(table("A4", maxi=20).to_string())

print("\n--- Consentement ---")
print(table("consentement").to_string())

# complet = entretien realise et consentement obtenu
df["COMPLET"] = (df["A4"] == 1) & (df["consentement"] == 1).astype(bool)
print(f"\nEntretiens complets (A4=1 & consentement=1) : {int(df['COMPLET'].sum())}/{len(df)}")

print("\n--- Region x statut ---")
print(pd.crosstab(df["cover_region"], df["interview__status"], margins=True).to_string())

print("\n--- Districts (top 15) ---")
print(df["cover_district"].value_counts().head(15).to_string())

print("\n--- Entretiens complets par agent (top 15) ---")
print(
    df.loc[df["COMPLET"], "nom_agent"]
    .map(lambda x: libelle("nom_agent", x))
    .value_counts().head(15).to_string()
)

print("\n--- Interviews par jour (debut de session) ---")
print(debut.dt.date.dropna().value_counts().sort_index().to_string())

print(f"\nDuree medianne d'entretien (min) : {df['duree_min'].dropna().median():.1f}")


#%% 2. Profil des non-reponses
print("\n=== Non-reponses ===")
manq = df.apply(vide).astype(int)

print("--- 15 variables les plus manquantes ---")
print((manq.mean().sort_values(ascending=False).head(15) * 100).round(1).to_string())

print("\n--- Taux de vide par section (% median de questions vides) ---")
synthese = {}
for s in SECTIONS:
    cols = questions(s)
    if cols:
        synthese[s] = {
            "n_questions": len(cols),
            "%_globale_vide": round(manq[cols].mean().sum() / len(df) * 100, 1),
            "%_median_vide": round(manq[cols].mean().median() * 100, 1),
        }
print(pd.DataFrame(synthese).T.to_string())

print("\n--- Interviews avec le plus de questions vides (top 10) ---")
n_vides = manq[df.columns.difference(["interview__id"])].sum(axis=1)
profil = df[["interview__key", "cover_region", "responsible", "interview__status"]].assign(
    n_questions_vides=n_vides
)
print(profil.nlargest(10, "n_questions_vides").to_string())


#%% 3. Distributions de chaque question (sections A -> R)
print("\n=== Distributions par question ===")
DISTRIB = {}
for s in SECTIONS:
    rows = []
    for c in questions(s):
        t = table(c, maxi=15)
        if t.empty:
            continue
        for cle, n in t.items():
            rows.append({
                "question": c,
                "libelle": (LIB_COLS.get(c, "") or "")[:120],
                "modalite": str(cle),
                "n": n,
                "pct": round(n / len(df) * 100, 1),
                "vide_pct": round(vide(df[c]).mean() * 100, 1),
            })
    if rows:
        DISTRIB[f"Section_{s}"] = pd.DataFrame(rows)
        print(f"\n########## Section {s} ##########")
        print(DISTRIB[f"Section_{s}"][["question", "modalite", "n", "pct"]].to_string(index=False))


#%% 4. Questions a choix multiples (D5, K5)
print("\n=== Choix multiples ===")


def multip_stub(stub, options):
    """Frequence de mention des options d'une question a choix multiples."""
    cols = [c for c in df.columns if c.startswith(stub + "__")]
    lib = LIB_COLS.get(cols[0], "") if cols else ""
    n_rep = int((~vide(df[cols])).any(axis=1).sum())
    print(f"\n--- {stub} ({lib[:90]}) ---")
    print(f"options: {len(cols)} ; repondants: {n_rep}/{len(df)}")
    retour = []
    for i, c in enumerate(cols, 1):
        cible = int((df[c] == 1).sum())
        pct = cible / n_rep * 100 if n_rep else 0
        nom = options.get(i, c)
        print(f"  {nom:<55} {cible:5d}  ({pct:5.1f}%)")
        retour.append({"option": nom, "n": cible, "pct_repondants": round(pct, 1)})
    return pd.DataFrame(retour)


multip_stub("D5", {i: f"D5_{i}" for i in range(1, 12)})
multip_stub("K5", {i: f"K5_{i}" for i in range(1, 8)} | {9: "K5_9"})


#%% 5. Rapport Excel
print("\n=== Ecriture du rapport Excel ===")
with pd.ExcelWriter(SORTIE_XLSX, engine="openpyxl") as xl:
    # metadonnees : variable, libelle, type, taux de vide
    pd.DataFrame(
        {
            "variable": df.columns,
            "libelle": [LIB_COLS.get(c, "") for c in df.columns],
            "type": df.dtypes.astype(str).values,
            "vide_pct": (manq.mean() * 100).round(1).values,
        }
    ).to_excel(xl, sheet_name="Metadonnees", index=False)

    # distributions par section
    for nom, tbl in DISTRIB.items():
        tbl.to_excel(xl, sheet_name=nom[:31], index=False)

    # suivi agents
    agents = (
        df.groupby("responsible")
        .agg(n=("interview__id", "size"),
             complets=("COMPLET", "sum"),
             duree_med=("duree_min", "median"))
        .assign(taux_complet=lambda t: (t["complets"] / t["n"] * 100).round(1))
        .sort_values("n", ascending=False)
    )
    agents.to_excel(xl, sheet_name="Agents")

    # statistiques croisees
    pd.crosstab(df["cover_region"], df["interview__status"]).to_excel(
        xl, sheet_name="Region_x_statut")
    rempli = (1 - manq.mean(axis=1)) * 100
    pct_remplissage = pd.DataFrame({"remplissage_pct": rempli})
    pct_remplissage["cover_region"] = df["cover_region"]
    pct_remplissage["interview__status"] = df["interview__status"]
    pct_remplissage.groupby(["cover_region", "interview__status"])["remplissage_pct"] \
        .mean().round(1).to_excel(xl, sheet_name="Remplissage_region_statut")

    if erreurs is not None and len(erreurs):
        erreurs.to_excel(xl, sheet_name="Erreurs_validation", index=False)

print("Exporte ->", SORTIE_XLSX)


#%% 6. Auto-controle
def _autocontrole():
    t = pd.DataFrame({"x": ["a", " ", "##N/A##", np.nan, "b"]})
    assert vide(t["x"]).tolist() == [False, True, True, True, False]
    assert df["interview__id"].notna().all(), "cle absente"
    assert df["duree_min"].notna().sum() > 0, "calcul de duree casse"
    assert int(df["COMPLET"].sum()) > 0, "aucun entretien complet"
    assert DISTRIB, "aucune distribution construite"
    print("auto-controle OK")


_autocontrole()