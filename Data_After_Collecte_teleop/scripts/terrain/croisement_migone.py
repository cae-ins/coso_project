#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Croisement des candidats MIGONE avec les bases COSO.

Le script produit des fichiers CSV simples, lisibles dans Excel.

Définition de VIDE :
    taux_completude = 0
    n_rempli = 0

Cela signifie qu'aucune question attendue du questionnaire n'est remplie.
Les informations techniques ou d'identification peuvent quand même exister
(clé d'interview, nom, téléphone, statut de l'interview, etc.).
"""

import os

import pandas as pd
import pyreadstat


# -------------------------------------------------------------------
# 1. CHEMINS DES FICHIERS
# -------------------------------------------------------------------
ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet
DOSSIER_RESULTATS = os.path.join(RACINE, "MIGONE", "resultats_croisement")

FICHIER_MIGONE = os.path.join(
    RACINE, "inputs", "candidats_sans_bonne_fiche_20260922_restreint.xlsx"
)
BASE_CONTACTS = os.path.join(RACINE, "inputs", "Base_Candidats_COSO_contactés.xlsx")
BASE_SANS_DOUBLONS = os.path.join(
    RACINE, "resultats", "QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta"
)
BASE_COMPLETE = os.path.join(
    RACINE, "resultats", "Questionnaire_COSO_VF_avec_completude.dta"
)
FICHIER_PROJET = os.path.join(RACINE, "inputs", "FICHIER PROJET COSO.xlsx")

os.makedirs(DOSSIER_RESULTATS, exist_ok=True)


# -------------------------------------------------------------------
# 2. PETITES FONCTIONS UTILES
# -------------------------------------------------------------------
def nettoyer_cle(valeur):
    """Transforme une clé en texte propre."""
    if pd.isna(valeur):
        return ""
    return str(valeur).strip()


def joindre_valeurs_uniques(serie):
    """Réunit les valeurs différentes d'une colonne dans une seule cellule."""
    valeurs = []
    for valeur in serie.dropna():
        texte = str(valeur).strip()
        if texte and texte not in valeurs:
            valeurs.append(texte)
    return " | ".join(valeurs)


def definir_action(observations):
    """Déduit une action simple à partir des observations du fichier projet."""
    texte = str(observations).upper()

    if "ACHEVE" in texte or "ACHEVÉ" in texte:
        return "REPRENDRE LE QUESTIONNAIRE"

    if "REFUS" in texte:
        return "NE PAS RECONTACTER - REFUS"

    numero_incorrect = (
        "INCORRECT" in texte
        or "INCCORECT" in texte
        or "ERREUR CONTACT" in texte
    )
    if numero_incorrect:
        return "CORRIGER LE NUMERO PUIS RELANCER"

    return "RELANCER L'APPEL"


def enregistrer_csv(tableau, nom_fichier):
    """Enregistre un CSV compatible avec Excel en français."""
    chemin = os.path.join(DOSSIER_RESULTATS, nom_fichier)
    tableau.to_csv(chemin, index=False, sep=";", encoding="utf-8-sig")
    print(f"Créé : {chemin} ({len(tableau)} lignes)")


# -------------------------------------------------------------------
# 3. LECTURE DES BASES
# -------------------------------------------------------------------
migone = pd.read_excel(FICHIER_MIGONE, sheet_name="318 candidats")
base_contacts = pd.read_excel(BASE_CONTACTS, sheet_name="Base complète")
coso_sans_doublons, _ = pyreadstat.read_dta(BASE_SANS_DOUBLONS)
coso_complete, _ = pyreadstat.read_dta(BASE_COMPLETE)
projet = pd.read_excel(FICHIER_PROJET, sheet_name="Feuil1")

# On nettoie les clés avant les comparaisons.
migone["cle"] = migone["interview_keys"].map(nettoyer_cle)
coso_sans_doublons["cle"] = coso_sans_doublons["interview__key"].map(
    nettoyer_cle
)
coso_complete["cle"] = coso_complete["interview__key"].map(nettoyer_cle)
projet["cle"] = projet["INTERVIEW KEY"].map(nettoyer_cle)


# -------------------------------------------------------------------
# 4. LES 4 CANDIDATS NON TROUVÉS PAR LE FILTRE DIRECT
# -------------------------------------------------------------------
# Le filtre direct ne reconnaît pas une cellule contenant deux clés :
# "28-91-17-73 ; 96-99-03-28" n'est pas une clé unique.
cles_sans_doublons = set(coso_sans_doublons["cle"])
les_4 = migone.loc[~migone["cle"].isin(cles_sans_doublons)].copy()

# Vérification de leur présence dans la feuille "Base complète" des contacts.
ids_base_contacts = set(base_contacts["ID"].map(nettoyer_cle))
les_4["dans_base_complete_contacts"] = les_4["candidate_id"].map(
    nettoyer_cle
).isin(ids_base_contacts)

# On sépare maintenant les deux clés de chaque candidat.
details_cles_4 = les_4[
    ["candidate_id", "cover_id", "nom", "telephone", "interview_keys"]
].copy()
details_cles_4["cle"] = details_cles_4["interview_keys"].str.split(r"\s*;\s*")
details_cles_4 = details_cles_4.explode("cle")
details_cles_4["cle"] = details_cles_4["cle"].map(nettoyer_cle)

colonnes_completude = [
    "cle",
    "interview__id",
    "interview__status",
    "A4",
    "consentement",
    "n_attendu",
    "n_rempli",
    "taux_completude",
    "classe_completude",
]

details_cles_4 = details_cles_4.merge(
    coso_complete[colonnes_completude],
    on="cle",
    how="left",
    indicator="presence_base_dta_complete",
)
details_cles_4["dans_base_dta_complete"] = details_cles_4[
    "presence_base_dta_complete"
].eq("both")
details_cles_4 = details_cles_4.drop(columns="presence_base_dta_complete")

# Résumé des classes de complétude, conservé sur une ligne par candidat.
details_cles_4["resume_completude"] = details_cles_4.apply(
    lambda ligne: (
        f"{ligne['cle']} : {ligne['classe_completude']} "
        f"({ligne['taux_completude']:.1%})"
    ),
    axis=1,
)
resume_4 = (
    details_cles_4.groupby("candidate_id")["resume_completude"]
    .apply(" | ".join)
    .reset_index()
)
les_4 = les_4.merge(resume_4, on="candidate_id", how="left")


# -------------------------------------------------------------------
# 5. FILTRE MIGONE : 253 INCOMPLETS ET 34 VIDES
# -------------------------------------------------------------------
coso_filtre_migone = coso_sans_doublons.loc[
    coso_sans_doublons["cle"].isin(set(migone["cle"]))
].copy()

incomplets = coso_filtre_migone.loc[
    coso_filtre_migone["classe_completude"].eq("4-INCOMPLET")
].copy()

vides = coso_filtre_migone.loc[
    coso_filtre_migone["classe_completude"].eq("5-VIDE")
].copy()

incomplets_et_vides = pd.concat([incomplets, vides], ignore_index=True)

colonnes_utiles = [
    "interview__key",
    "interview__id",
    "cover_id",
    "nom",
    "telephone",
    "cover_region",
    "cover_district",
    "localite",
    "interview__status",
    "A4",
    "consentement",
    "n_attendu",
    "n_rempli",
    "taux_completude",
    "classe_completude",
    "cle",
]
colonnes_utiles = [c for c in colonnes_utiles if c in incomplets_et_vides.columns]


# -------------------------------------------------------------------
# 6. ÉTAT DES 287 DANS "FICHIER PROJET COSO.xlsx"
# -------------------------------------------------------------------
# Une clé peut apparaître plusieurs fois dans le fichier projet.
# On garde toutes ses observations, réunies dans une seule cellule.
projet_valide = projet.loc[projet["cle"].ne("")].copy()

etat_projet = (
    projet_valide.groupby("cle")
    .agg(
        nombre_lignes_projet=("cle", "size"),
        observations_projet=("OBSERVATIONS", joindre_valeurs_uniques),
        noms_projet=("CHEF DE MENAGE", joindre_valeurs_uniques),
        contacts_projet=("CONTACTS", joindre_valeurs_uniques),
        tentatives_appels=("TENTATIVES APPELS", joindre_valeurs_uniques),
        dates_cloture=("DATE DE CLÔTURE", joindre_valeurs_uniques),
    )
    .reset_index()
)

etat_projet["trouve_dans_fichier_projet"] = True
etat_projet["action_proposee"] = etat_projet["observations_projet"].map(
    definir_action
)

verification_287 = incomplets_et_vides[colonnes_utiles].merge(
    etat_projet,
    on="cle",
    how="left",
)

verification_287["trouve_dans_fichier_projet"] = verification_287[
    "trouve_dans_fichier_projet"
].fillna(False)

verification_287["action_proposee"] = verification_287[
    "action_proposee"
].fillna("VERIFIER - ABSENT DU FICHIER PROJET")

recap_actions = (
    verification_287.groupby(["classe_completude", "action_proposee"])
    .size()
    .reset_index(name="nombre")
)


# -------------------------------------------------------------------
# 7. ENREGISTREMENT DES RÉSULTATS
# -------------------------------------------------------------------
enregistrer_csv(les_4, "01_les_4_candidats_non_trouves.csv")
enregistrer_csv(details_cles_4, "02_details_des_cles_des_4.csv")
enregistrer_csv(incomplets[colonnes_utiles], "03_incomplets_253.csv")
enregistrer_csv(vides[colonnes_utiles], "04_vides_34.csv")
enregistrer_csv(
    verification_287,
    "05_incomplets_et_vides_avec_etat_projet.csv",
)
enregistrer_csv(recap_actions, "06_recapitulatif_actions.csv")


# -------------------------------------------------------------------
# 8. RÉSUMÉ AFFICHÉ À L'ÉCRAN
# -------------------------------------------------------------------
print("\nRÉSUMÉ")
print(f"Candidats non trouvés par le filtre direct : {len(les_4)}")
print(
    "Clés individuelles des 4 trouvées dans la base DTA complète : "
    f"{int(details_cles_4['dans_base_dta_complete'].sum())} / "
    f"{len(details_cles_4)}"
)
print(f"INCOMPLETS : {len(incomplets)}")
print(f"VIDES : {len(vides)}")
print(f"INCOMPLETS + VIDES : {len(verification_287)}")
print("\nActions proposées :")
print(
    verification_287["action_proposee"]
    .value_counts()
    .rename_axis("action")
    .to_string()
)
