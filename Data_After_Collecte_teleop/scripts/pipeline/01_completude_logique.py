# -*- coding: utf-8 -*-
"""
01_completude_logique.py
========================
Calcule la COMPLETUDE LOGIQUE de chaque interview COSO.

Pour chaque interview on determine la liste des questions qui DEVAIENT
etre repondues au vu des reponses precedentes (= logique de saut / skip
logic du questionnaire). Puis :
    taux_completude = questions_attendu_remplies / questions_attendues

On classe ensuite chaque interview :
    1-COMPLET      : 100 %  des questions attendues sont remplies
    2-QUASI_COMPLET: 90-100 %
    3-MOYEN        : 50-90 %
    4-INCOMPLET    :  1-50 %
    5-VIDE         :  0 %

Toutes les regles ci-dessous ont ete VALIDEES statistiquement sur les
425 interviews de reference (statut 100 ET A4 = 1) : pour chaque question
conditionnelle, elles correspondent a ce qui est observe dans les donnees.

Sorties (dans le dossier ./resultats) :
  - Questionnaire_COSO_VF_avec_completude.dta  : base complete + 2 colonnes
        taux_completude   (0..1, pourcentage)
        classe_completude  (texte, pour filtrer)
  - manquants_par_classe.csv : questions manquantes par classe de completude
"""

import os
import pyreadstat
import pandas as pd
import numpy as np

# ---------------------------------------------------------------
# 0) DOSSIERS
#    Le script peut etre lance d'ici ou de la racine des donnees.
# ---------------------------------------------------------------
ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet
DOSSIER_BASE = os.path.join(RACINE, "bases")       # contient la base
DOSSIER_RES  = os.path.join(RACINE, "resultats")

# ---------------------------------------------------------------
# 1) OUTILS : comment reconnaitre une reponse "remplie" ?
#    La base contient des chaines vides "" ou "." qui ne sont PAS NaN.
#    Une question est remplie uniquement si elle a une valeur non vide.
# ---------------------------------------------------------------
def remplie(df, colonne):
    s = df[colonne]
    return (s.notna()
            & s.astype(str).str.strip().ne("")
            & s.astype(str).str.strip().ne("."))

def egale(df, colonne, valeur):
    """True quand la colonne vaut exactement 'valeur' (les vides -> False)."""
    s = df[colonne].astype(str).str.strip()
    return s.notna() & (s.astype("Float64").fillna(-9).eq(float(valeur)))

# ---------------------------------------------------------------
# 2) CHARGEMENT DE LA BASE
# ---------------------------------------------------------------
df, meta = pyreadstat.read_dta(f"{DOSSIER_BASE}/Questionnaire_COSO_VF.dta")

# ---------------------------------------------------------------
# 3) LES REGLES DE COMPLETUDE
#    Chaque regle dit : cette question EST ATTENDUE si [condition].
#    - attendu_tous()        : question posee a tout le monde
#    - attendu_si(...)       : question posee seulement si la condition est vraie
# ---------------------------------------------------------------
attendu = {}

def attendu_tous(liste_questions):
    """Ces questions sont attendues pour toutes les interviews."""
    for q in liste_questions:
        attendu[q] = pd.Series(True, index=df.index)

def attendu_si(question, condition):
    """Cette question n'est attendue que quand `condition` est vraie."""
    attendu[question] = condition

# QUELQUES CONDITIONS PRATIQUES (reutilises ci-dessous) -----------
employe   = egale(df, "EMPLOYE", 1)           # a une activite remuneree
sans_emploi = egale(df, "EMPLOYE", 0)         # sans activite remuneree
non_salar = (egale(df, "F1", 2)               # F1 = statut dans l'emploi
             | egale(df, "F1", 3)
             | egale(df, "F1", 4))            # 2 apprenti / 3 independant / 4 aide
epargne   = egale(df, "L3", 1) | egale(df, "L3", 2)   # epargne oui / parfois
etudes    = df["C4"].fillna(-9) >= 2          # niveau d'etudes >= primaire

# ---- Section A : oui / non / pas de reponse au telephone ---------
attendu_tous(["A1", "A4"])                    # A1 no appel / A4 resultat appel
attendu_si("A4X",      egale(df, "A4", 8))    # "Autre" : preciser
attendu_si("A5_date",  egale(df, "A4", 5))    # rendez-vous : date
attendu_si("A5_heure", egale(df, "A4", 5))    # rendez-vous : heure

# ---- Section B : identification ----
attendu_tous(["B5", "B6"])                    # B5 urbain/rural, B6 bonne personne ?
attendu_si("B6A", egale(df, "B6", 2))         # pas la bonne personne -> dispo ?
attendu_si("B6B", egale(df, "B6", 2) & egale(df, "B6A", 2))

# ---- Section C : caracteristiques socio-demographiques ----
attendu_tous(["C1", "C3", "C4", "C7"])        # sexe, age, niveau etudes, ...
# age en clair (jour/mois/annee) : attendu si la date de naissance type C2
# n'est pas complete; C2 reste facultative car redondante avec C2A
attendu_si("C2A_Jour",  ~remplie(df, "C2"))
attendu_si("C2A_Mois",  ~remplie(df, "C2"))
attendu_si("C2A_annee", ~remplie(df, "C2"))
# C2 : date complete, pas exigeante (les enquetes remplissent souvent C2A)
attendu_si("C2", remplie(df, "C2"))
# diplome : seulement si niveau d'etudes >= primaire
attendu_si("C5", etudes)
# pays : seulement si reponse C7 = 1 (Cote d'Ivoire)
attendu_si("C8", egale(df, "C7", 1))
# C6, C9, C10, C11 : champs libres/observation, non contraignants

# ---- Section D : education ----
attendu_tous(["D1", "D2", "D3", "D4"] + [f"D5__{i}" for i in range(1, 12)])

# ---- Section E : situation d'emploi ----
attendu_tous(["E1"])
attendu_si("E2",  egale(df, "E1", 2))         # sans activite -> en a-t-il eu ?
attendu_si("E3",  egale(df, "E1", 2) & egale(df, "E2", 2))
attendu_si("E3A", egale(df, "E1", 2) & egale(df, "E2", 2) & egale(df, "E3", 1))

# ---- Sections F/G/H/I : UNIQUEMENT SI la personne a une activite ----
attendu_si("F1", employe)                     # statut dans l'activite
attendu_si("F2", employe)                     # secteur d'activite
attendu_si("F3", employe)                     # lieu d'activite
attendu_si("F4", employe)                     # duree d'exercice
attendu_si("F1X", employe & egale(df, "F1", 9))   # statut autre : preciser
attendu_si("F2X", employe & egale(df, "F2", 99))  # secteur autre : preciser
attendu_si("F3X", employe & egale(df, "F3", 9))   # lieu autre : preciser

attendu_si("G1", employe)                     # heures d'activite principale
attendu_si("G2", employe)
attendu_si("G3", employe)
attendu_si("G4", employe)
attendu_si("G4A", employe & egale(df, "G4", 2))
attendu_si("G5", employe)                     # a une 2e activite ?
attendu_si("G5A", employe & egale(df, "G5", 1))
attendu_si("G6",  employe & egale(df, "G5", 1))
attendu_si("G7", employe)
attendu_si("G7A", employe & egale(df, "G7", 1))

attendu_si("H1", employe & egale(df, "F1", 1))      # salarie : mode de paiement
attendu_si("H2", employe & egale(df, "F1", 1))      # salarie : frequence
attendu_si("H3", employe)                            # montant gagne (mois)
attendu_si("H3A", employe & egale(df, "H3", 99999)) # ne veut pas dire -> classe
attendu_si("H4", employe & non_salar)                # non salarie : enreg. ?
attendu_si("H5", employe & non_salar)                # non salarie : profit
attendu_si("H5A", employe & non_salar & egale(df, "H5", 999999))

attendu_si("I1", employe)                      # cherche un autre emploi ?
attendu_si("I2", employe & egale(df, "I1", 1)) # pourquoi
attendu_si("I3", employe & egale(df, "I1", 1)) # demarches effectuees

# ---- Section J : UNIQUEMENT SI la personne est sans emploi ----
attendu_si("J0", sans_emploi)                  # recherche d'emploi ?
attendu_si("J0A", sans_emploi & egale(df, "J0", 2))  # ne cherche pas : pourquoi
attendu_si("J0B", sans_emploi & egale(df, "J0", 2) & egale(df, "J0A", 9))
attendu_si("J1", sans_emploi & egale(df, "J0", 1))   # demarches
attendu_si("J2", sans_emploi & egale(df, "J0", 1))
attendu_si("J3", sans_emploi)                  # disponible pour travailler ?

# ---- Section K : projet de creation d'activite ----
attendu_tous(["K1", "K6", "K7"])
attendu_si("K2", egale(df, "K1", 2))           # sans activite -> creation ?
attendu_si("K3", egale(df, "K1", 1))           # a une activite -> financement
attendu_si("K4", egale(df, "K1", 2) & egale(df, "K2", 1))
# K5 : obstacles (plusieurs cases)
for i in [1, 2, 3, 4, 5, 6, 7, 9]:
    attendu_si(f"K5__{i}", egale(df, "K1", 2) & egale(df, "K2", 1))
# K5X : "autre" obstacle -> preciser, seulement si la case 9 est cochee
attendu_si("K5X", egale(df, "K1", 2) & egale(df, "K2", 1) & egale(df, "K5__9", 1))

# ---- Section L : epargne et credit ----
attendu_tous(["L1", "L2", "L3", "L6"])
attendu_si("L4", epargne)                      # montant de l'epargne
attendu_si("L5", epargne)                      # ou l'epargne est conservee
attendu_si("L5X", epargne & egale(df, "L5", 5))
attendu_si("L7", egale(df, "L6", 1))           # endette : remboursement
attendu_si("L8", egale(df, "L6", 1))
attendu_si("L9", egale(df, "L6", 1))

# ---- Section M : revenus / depenses ----
attendu_tous(["M1", "M2", "M3", "M4"])

# ---- Section N : chocs ----
attendu_tous(["N1", "N6", "N7"])
choc = egale(df, "N1", 1)
attendu_si("N2", choc)
attendu_si("N3", choc)
attendu_si("N4", choc)
attendu_si("N5", choc)

# ---- Section O : formation professionnelle ----
attendu_tous(["O1", "O3"])
attendu_si("O2", egale(df, "O1", 1))           # a recu une formation : age
attendu_si("O4", egale(df, "O3", 1))           # domaine de formation
attendu_si("O5", egale(df, "O3", 1))
attendu_si("O6", egale(df, "O3", 1))

# ---- Section P : aides et services ----
attendu_tous(["P1", "P2", "P3", "P4", "P5"])
attendu_si("P44X", egale(df, "P4", 99))        # autre aide : preciser

# ---- Section Q : perception des institutions ----
attendu_tous([c for c in df.columns if c.startswith("Q")])

# ---- Section R : observations de l'enqueteur ----
attendu_tous(["R1", "R2", "R3", "R4", "R5", "R6", "R7"])
attendu_si("R1A", egale(df, "R1", 2))
attendu_si("R2A", egale(df, "R2", 1))
attendu_si("R3A", egale(df, "R3", 1))
attendu_si("R3B", egale(df, "R3A", 2))

# ---------------------------------------------------------------
# 4) TABLEAUX DES QUESTIONS "ATTENDUES" ET "REMPLIES"
# ---------------------------------------------------------------
attendues = pd.DataFrame(attendu)             # True si la question est attendue
remplies  = pd.DataFrame({q: remplie(df, q) for q in attendu})

n_attendu = attendues.sum(axis=1)             # nb de questions attendues
n_rempli  = (remplies & attendues).sum(axis=1)  # nb attendues ET remplies
taux      = n_rempli / n_attendu.replace(0, np.nan)

# ---------------------------------------------------------------
# 5) CLASSEMENT DES INTERVIEWS
# ---------------------------------------------------------------
def classer(t):
    if pd.isna(t):
        return "5-VIDE"
    if t == 1.0:
        return "1-COMPLET"
    if t >= 0.90:
        return "2-QUASI_COMPLET"
    if t >= 0.50:
        return "3-MOYEN"
    if t > 0:
        return "4-INCOMPLET"
    return "5-VIDE"

classe = taux.map(classer)

print("=" * 62)
print("REPARTITION PAR CLASSE DE COMPLETUDE  (toutes interviews)")
print("=" * 62)
print(classe.value_counts().sort_index().to_string())
print()
print(f"taux moyen : {taux.mean():.3f}  |  mediane : {taux.median():.3f}")

# ---------------------------------------------------------------
# 6) VALIDATION STATISTIQUE SUR LES 425 REFERENCES
#    (statut 100 ET A4=1) : doit etre >= 90% pour presque toutes.
# ---------------------------------------------------------------
test = (df["interview__status"] == 100) & egale(df, "A4", 1)
t_ref = taux[test]
print()
print("=" * 62)
print("VALIDATION SUR LES 425 REFERENCES (statut 100 et A4=1)")
print("=" * 62)
print(f"min : {t_ref.min():.3f}   mediane : {t_ref.median():.3f}   "
      f"moyenne : {t_ref.mean():.3f}")
print(f"refs < 90% : {(t_ref < 0.9).sum()}  |  refs = 100% : {(t_ref == 1.0).sum()}")

# ---------------------------------------------------------------
# 7) EX1 : QUESTIONS MANQUANTES PAR CLASSE (<< detail du rapport)
# ---------------------------------------------------------------
manquantes = attendues & ~remplies
print()
print("=" * 62)
print("QUESTIONS 'ATTENDUES MAIS VIDES' PAR CLASSE")
print("=" * 62)
lignes = []
for nom_classe in classe.unique():
    sel = classe == nom_classe
    n_int = int(sel.sum())
    manq = manquantes.loc[sel].sum().sort_values(ascending=False)
    manq = manq[manq > 0]
    for q, nb in manq.items():
        lignes.append({"classe": nom_classe, "n_interviews": n_int,
                       "question": q, "n_manquante": int(nb),
                       "pct_interviews": round(100 * nb / n_int, 1)})
    if nom_classe == "1-COMPLET":
        print(f"\n{nom_classe} ({n_int}) : aucune question manquante")
    else:
        print(f"\n{nom_classe} ({n_int}) :")
        for q, nb in manq.head(12).items():
            print(f"   {q:<8} manquante dans {int(nb)} interviews")
if lignes:
    pd.DataFrame(lignes).to_csv(f"{DOSSIER_RES}/manquants_par_classe.csv",
                                index=False)

# ---------------------------------------------------------------
# 7b) EXCEL "ID + MANQUE" : une ligne par (interview, question manquante)
#     Praticite : on peut filtrer par classe et recuperer les id a traiter.
# ---------------------------------------------------------------
ids_cols = [c for c in ["interview__id", "interview__key"]      # id des interviews
            if c in df.columns]
registres = []
for q in manquantes.columns:              # pour chaque question (peu, vectoriel)
    qui = manquantes[q]                    # onde True si cette question manque
    qui = qui[qui]
    if len(qui):
        registres.append(pd.DataFrame({
            "classe": classe.reindex(qui.index).tolist(),
            "question_manquante": q,
            **{c: df.loc[qui.index, c].astype(str).tolist() for c in ids_cols},
        }))
if registres:
    detail_id = pd.concat(registres, ignore_index=True)
    detail_id = detail_id.sort_values(["classe", "question_manquante"])
    detail_id.to_excel(f"{DOSSIER_RES}/manquants_id_detail.xlsx", index=False)
    print()
    print(f"Excel ecrit : manquants_id_detail.xlsx  ({len(detail_id)} lignes)")

# ---------------------------------------------------------------
# 8) EX1 : BASE FINALE AVEC LES 2 COLONNES A FILTRER
#    taux_completude    : proportion de 0..1 (a *100 pour le %)
#    classe_completude  : 1-COMPLET / 2-QUASI_COMPLET / 3-MOYEN / ...
# ---------------------------------------------------------------
base = df.copy()
base["taux_completude"] = taux
base["classe_completude"] = classe.astype(str)
base["n_attendu"] = n_attendu
base["n_rempli"] = n_rempli
pyreadstat.write_dta(base, f"{DOSSIER_RES}/Questionnaire_COSO_VF_avec_completude.dta",
                     variable_value_labels=meta.variable_value_labels)

# tableau de synthese aussi en CSV (simple a voir dans Excel)
recap = pd.DataFrame({"classe": sorted(classe.unique())})
recap["n_interviews"] = recap["classe"].map(classe.value_counts())
recap.to_csv(f"{DOSSIER_RES}/recap_classes.csv", index=False)

print()
print("Fichiers ecrits dans", DOSSIER_RES, ":")
print("  - Questionnaire_COSO_VF_avec_completude.dta")
print("  - manquants_par_classe.csv")
print("  - recap_classes.csv")