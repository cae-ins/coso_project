"""08 — Calculer tous les indicateurs descriptifs (blocs D1 à D11).

Entrées : 04_resultats/traitement/base_apuree.csv + meta_apurement.json
Sortie  : 04_resultats/indicateurs/indicateurs.json

Une proportion est le nombre de réponses dans la modalité divisé par le nombre
de réponses valides de la population concernée. Les réponses sautées, les codes
de refus et les codes « ne sait pas » ne sont jamais comptés comme « non ».
Les médianes portent sur les valeurs valides et n'ont pas de numérateur.
Les sous-groupes de moins de 30 réponses valides portent la mention
« Effectif faible ». Aucune imputation.
"""

from __future__ import annotations

import argparse
import json
import unicodedata
from datetime import date
from pathlib import Path

import pandas as pd

from libelles_coso import LIBELLES

ICI = Path(__file__).resolve().parent
RACINE = ICI.parent
BASE = RACINE / "04_resultats" / "traitement" / "base_apuree.csv"
META = RACINE / "04_resultats" / "traitement" / "meta_apurement.json"
SORTIE = RACINE / "04_resultats" / "indicateurs" / "indicateurs.json"

TRANCHES_ORDRE = ["Moins de 30 000", "[30 000 – 75 000[", "[75 000 – 150 000[",
                  "[150 000 – 300 000[", "[300 000 – 500 000[",
                  "[500 000 – 800 000[", "[800 000 – 1 000 000[",
                  "Plus d'un million"]

ETUDES_GROUPE = ["Aucun niveau", "Préscolaire ou primaire", "Secondaire", "Supérieur"]
AGE_GROUPES = ["15–24 ans", "25–34 ans", "35 ans ou plus", "Âge invalide"]
DUREE_TRANCHES = ["Moins de 15 min", "15 à 30 min", "30 à 45 min", "45 à 60 min"]

FAMILLES_METIER = [
    ("Agriculture et élevage", ["AGRICOL", "ELEVAGE", "ELEVEUR", "CULTIV", "FERM",
                                "PECHE", "SYLVIC", "AVICUL", "PORC", "BOVIN", "CAPRIN",
                                "VOLAILLE", "CAFE", "CACAO", "ANANAS", "MANIOC", "COTON",
                                "PALMIER", "HEVEA", "HORTIC", "JARDIN", "PISCIC", "EBURI"]),
    ("Commerce et vente", ["COMMER", "MARCH", "VENTE", "VENDEUR", "BOUTI", "GROSS",
                           "DETAILL", "ACHAT", "REVENTE", "ETAL", "SUPERETTE"]),
    ("Bâtiment et travaux", ["MACON", "BRIQUE", "CARREL", "PEINT", "ELECTRIC", "MENUIS",
                             "CHARPENT", "COUVRE", "PLOMB", "SERRUR", "CONSTRUCT", "BTP",
                             "TERRASS", "STUCC", "DECOU", "SOUDE", "METALL", "FORGER"]),
    ("Artisanat et industries", ["COUTUR", "TISSU", "TISSAG", "POTER", "VANNER",
                                 "TRANFORMATION", "AGRO", "FABRIC", "MECANIC", "MECA",
                                 "AUTOMOB", "GARAGE", "TAMBOUR", "BOIS"]),
    ("Transport", ["TRANSPORT", "TAXI", "MOTOTAXI", "CHAUFFEUR", "LIVRAISON",
                   "CAMION", "UBER", "COURRIER"]),
    ("Restauration et hôtellerie", ["RESTAUR", "CUISIN", "TRAITEUR", "HOTEL", "BAR",
                                    "CANTINE", "PIZZA", "MAQUIS", "GARGOTE", "PATISS"]),
    ("Coiffure et beauté", ["COIFF", "BEAUT", "ESTHET", "ONGLE", "MAQUILL", "TRESS"]),
    ("Santé", ["PHARM", "SANT", "INFIRM", "MEDIC", "DOCTEUR", "CLINIQUE", "SAGE-FEMME"]),
    ("Éducation et formation", ["ENSEIGN", "PROFESS", "ECOLE", "EDUCAT", "MAITRE",
                                "TUITION", "CENTRE DE FORMATION"]),
    ("Numérique et bureautique", ["INFORMAT", "DIGITAL", "WEB", "RESEAU", "DEVELOP",
                                  "PROGRAMM", "BUREAU", "SECRE", "COMPTAB", "CAISSE"]),
    ("Finance et assurance", ["BANQUE", "ASSUR", "MICROFIN", "INSTITUTION", "AGENT"]),
    ("Services aux personnes", ["GARDIENN", "SURETE", "VIGILE", "MENAGE", "FEMME DE MAISON",
                                "BLANCHI", "DEMENAG"]),
]

FAMILLES_OBSTACLE = [
    ("Financement et manque de moyens", ["FINANC", "MOYEN", "CAPITAL", "ARGENT", "FOND",
                                         "CREDIT", "EMPRUNT", "SUBVENT", "APPUI", "DENIER",
                                         "FCFA", "RESSOUR", "BOURSE", "INVESTIS"]),
    ("Compétences et formation", ["COMPETEN", "FORMATION", "SAVOIR", "EXPERIEN", "QUALIF",
                                  "CONNAISS", "DIPLOME", "APPRENT", "NIVEAU", "ETUDE",
                                  "ILLITER", "ANALPHAB"]),
    ("Marché et débouchés", ["MARCHE", "CLIENT", "DEMANDE", "ECOULE", "CONCURREN", "VENDRE"]),
    ("Équipement et local", ["EQUIPEM", "LOCAL", "MACHIN", "OUTILL", "MATERIEL", "MAGASIN",
                             "BOUTIQUE", "OUTIL", "ORDINATEUR", "VEHICULE"]),
    ("Obstacles administratifs", ["ADMINISTR", "AUTORIS", "PERMIS", "ENREGISTR", "PAPIER",
                                  "IMPOT", "TAXE", "FISC", "CRITERE", "DOSSIER"]),
    ("Responsabilités familiales ou santé", ["FAMIL", "MARI", "CONJOINT", "ENFANT", "PARENT",
                                             "OBLIGAT", "SANTE", "MALAD", "HANDICAP",
                                             "GROSSES", "CHARGE"]),
    ("Peur de l'échec ou du risque", ["PEUR", "RISQUE", "ECHEC", "DOUTE", "INSECUR"]),
    ("Manque de temps", ["TEMPS", "HORAIRE", "DISPONIB"]),
]

COUVERTURE = [
    {"code": "1.1", "indicateur": "Jeunes enrôlés", "statut": "en attente",
     "limite": "Dénominateur à convenir : la base d'enquête compte 663 entretiens "
               "utilisables (962 entretiens bruts) ; le registre d'enrôlement fait foi."},
    {"code": "1.2", "indicateur": "Sélectionnés ayant démarré une formation",
     "statut": "en attente",
     "limite": "Aucune variable de sélection ou de formation COSO dans le DTA ; "
               "le proxy O3 (formation générale des 12 derniers mois) n'est pas équivalent."},
    {"code": "1.3", "indicateur": "Femmes parmi les sélectionnés", "statut": "en attente",
     "limite": "Statut de sélection absent ; par identité de définition la part des femmes "
               "parmi les répondants est fournie en D1.1 (227/663)."},
    {"code": "1.4", "indicateur": "Bénéficiaires de zones enclavées", "statut": "indisponible",
     "limite": "Statut de sélection et référentiel officiel des localités enclavées requis "
               "(B5 = rural n'est pas une mesure d'enclavement)."},
    {"code": "1.5", "indicateur": "Formation achevée", "statut": "indisponible",
     "limite": "Registre d'achèvement de formation requis."},
    {"code": "1.6", "indicateur": "Taux d'achèvement", "statut": "indisponible",
     "limite": "Début et achèvement par cohorte requis."},
    {"code": "1.7", "indicateur": "Kits d'installation remis", "statut": "indisponible",
     "limite": "Registre des remises de kits requis."},
    {"code": "2.1", "indicateur": "MAF mobilisés", "statut": "indisponible",
     "limite": "Registre des maîtres artisans formateurs et des séances requis."},
    {"code": "2.2", "indicateur": "Inscrits à la chambre des métiers", "statut": "indisponible",
     "limite": "Preuve d'inscription spécifique requise (H4 mesure un enregistrement "
               "d'activité général)."},
    {"code": "2.3", "indicateur": "Intégrés à un AVEC", "statut": "indisponible",
     "limite": "Registre d'adhésion AVEC requis (L5/L7 indiquent un lien financier possible)."},
    {"code": "3.1", "indicateur": "Statut d'activité", "statut": "partiel",
     "limite": "Statuts observés ; aucun taux de chômage normatif (disponibilité non mesurée "
               "pour l'ensemble des chercheurs)."},
    {"code": "3.2", "indicateur": "Type d'activité et secteur", "statut": "calculé",
     "limite": "Distributions parmi les personnes en emploi."},
    {"code": "3.3", "indicateur": "Durée du travail", "statut": "calculé",
     "limite": "Heures de l'activité principale ; codes spéciaux 998 exclus."},
    {"code": "3.4", "indicateur": "Revenus ou chiffre d'affaires", "statut": "partiel",
     "limite": "H3 limité aux salariés, H5 aux employeurs/indépendants/coopératives ; "
               "aucun chiffre d'affaires ; populations et périodes distinctes."},
    {"code": "3.5", "indicateur": "Recherche d'emploi et contraintes", "statut": "calculé",
     "limite": "Populations en emploi et sans emploi séparées."},
    {"code": "3.6", "indicateur": "Formation ou AGR", "statut": "partiel",
     "limite": "Formation et activité générales, sans lien individuel avec COSO."},
    {"code": "3.7", "indicateur": "Chômage et sous-emploi", "statut": "partiel",
     "limite": "Composantes disponibles ; taux normatifs non publiés (disponibilité et "
               "seuil horaire non validés)."},
    {"code": "3.8", "indicateur": "Résilience économique", "statut": "partiel",
     "limite": "Dimensions observées séparément ; aucun indice composite validé."},
    {"code": "3.9", "indicateur": "Statut socio-économique perçu", "statut": "calculé",
     "limite": "Modalités M1, M3, M4 ; aucun score composite."},
    {"code": "4.1", "indicateur": "Exclusion sociale et perte d'espoir", "statut": "indisponible",
     "limite": "Les questions disponibles ne mesurent pas directement ces concepts."},
    {"code": "4.2", "indicateur": "Cohésion sociale perçue", "statut": "partiel",
     "limite": "Appartenance, participation et confiance ; aucun indice global."},
]

BLOCS = {
    "D1": "D1 · Profil et composition",
    "D2": "D2 · Ménage et patrimoine",
    "D3": "D3 · Emploi et travail",
    "D4": "D4 · Revenus et rémunération",
    "D5": "D5 · Recherche d'emploi",
    "D6": "D6 · Entrepreneuriat",
    "D7": "D7 · Épargne, crédit et services financiers",
    "D8": "D8 · Formation et aspirations",
    "D9": "D9 · Trajectoires perçues",
    "D10": "D10 · Résilience et cohésion",
    "D11": "D11 · Qualité de l'enquête",
}

CODES_PAR_INDICATEUR = {
    "3.1": ["D3.1"],
    "3.2": ["D3.2", "D3.3"],
    "3.3": ["D3.8", "D3.9", "D3.10", "D3.13"],
    "3.4": ["D4.1", "D4.2", "D4.3", "D4.4", "D4.5", "D4.6", "D4.7", "D4.8", "D4.9"],
    "3.5": ["D5.1", "D5.2", "D5.3", "D5.4", "D5.5", "D5.6", "D5.7", "D5.8", "D5.9"],
    "3.6": ["D6.1", "D6.2", "D6.3", "D8.1"],
    "3.7": ["D3.14", "D3.15", "D5.4", "D5.7", "D5.9"],
    "3.8": ["D10.1", "D10.2", "D10.3", "D10.4", "D10.5", "D10.6", "D10.7"],
    "3.9": ["D9.1", "D9.3", "D9.4", "D9.5", "D9.6", "D9.7"],
    "4.2": ["D10.8", "D10.9", "D10.10", "D10.11", "D10.12", "D10.13", "D10.14",
            "D10.15", "D10.16", "D10.17"],
}


def _sans_accents(texte: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFD", texte)
                   if unicodedata.category(c) != "Mn")


def coder(texte: str, bareme: list[tuple[str, list[str]]]) -> str:
    """Première famille dont un mot-clé apparaît, sinon « Autre ou non précisé »."""
    if texte is None or not str(texte).strip():
        return ""
    t = _sans_accents(str(texte)).upper()
    for famille, motifs in bareme:
        for motif in motifs:
            if motif in t:
                return famille
    return "Autre ou non précisé"


def groupes(d: pd.DataFrame):
    toutes = dict(district="Toutes", region="Toutes", sexe="Tous",
                  age_groupe="Tous", milieu="Tous")
    yield "Ensemble", toutes, d
    for district, sub in d.groupby("district", sort=True):
        yield "District", {**toutes, "district": district}, sub
    for (district, region), sub in d.groupby(["district", "region"], sort=True):
        yield "Région", {**toutes, "district": district, "region": region}, sub
    for sexe, sub in d.groupby("sexe", sort=True):
        yield "Sexe", {**toutes, "sexe": sexe}, sub
    for age, sub in d.groupby("age_groupe", sort=True, observed=True):
        yield "Âge", {**toutes, "age_groupe": age}, sub
    for milieu, sub in d.groupby("milieu", sort=True):
        yield "Milieu", {**toutes, "milieu": milieu}, sub


def _preparer(d: pd.DataFrame) -> pd.DataFrame:
    c4 = d.C4.where(d.C4.between(0, 99))
    d["etudes_groupe"] = pd.cut(c4, bins=[-1, 0.5, 2.5, 6.5, 99],
                                labels=ETUDES_GROUPE).astype(object).fillna("Non renseigné")
    d["metier_P1"] = [coder(t, FAMILLES_METIER) if str(t).strip() else ""
                      for t in d.P1.fillna("")]
    d["formation_O4"] = [coder(t, FAMILLES_METIER) if str(t).strip() else ""
                         for t in d.O4.fillna("")]
    d["obstacle_P5"] = [coder(t, FAMILLES_OBSTACLE) if str(t).strip() else ""
                        for t in d.P5.fillna("")]
    d["autre_activite_G5A"] = [coder(t, FAMILLES_METIER) if str(t).strip() else ""
                               for t in d.G5A.fillna("")]
    d["tranche_duree"] = pd.cut(d.duree_entretien_min.where(d.duree_valide),
                                bins=[0, 15, 30, 45, 60], labels=DUREE_TRANCHES,
                                right=False).astype(object)
    return d


def calculer(base: Path = BASE, meta_path: Path = META) -> dict:
    d = pd.read_csv(base)
    if d.interview__key.isna().any() or d.interview__key.duplicated().any():
        raise ValueError("Identifiant d'entretien absent ou dupliqué dans la base apurée.")
    if not d.classe_completude.isin(["1-COMPLET", "2-QUASI_COMPLET"]).all() or not d.consentement.eq(1).all():
        raise ValueError("La base apurée contient un entretien hors population.")
    meta = json.loads(meta_path.read_text(encoding="utf-8")) if meta_path.exists() else {}
    d = _preparer(d)
    lignes: list[dict] = []

    def labels_de(variable: str, extra: dict | None = None) -> dict:
        base_lab = dict(LIBELLES.get(variable, {}))
        if extra:
            base_lab.update(extra)
        return base_lab

    for niveau, cles, g in groupes(d):
        n = len(g)
        geo = dict(niveau=niveau, **cles, n_groupe=n)

        def emit(code, mesure, variable, effectif, denom, unite, modalite="",
                 valeur=None, note="", attendus=None, bloc=None):
            if valeur is None and effectif is not None and denom:
                valeur = round(100 * effectif / denom, 2) if unite == "%" else float(effectif)
            if bloc is None:
                bloc = BLOCS.get(code.split(".")[0], "")
            precision = note if denom is None or denom >= 30 else (
                (note + " ").strip() + "Effectif faible : dénominateur < 30.")
            lignes.append({**geo, "bloc": bloc, "code": code, "mesure": mesure,
                           "modalite": modalite,
                           "valeur": None if valeur is None else round(float(valeur), 2),
                           "unite": unite, "effectif": effectif, "denominateur": denom,
                           "sans_reponse": ((attendus if attendus is not None else n) - denom)
                           if denom is not None else None,
                           "variables": variable, "precision": precision})

        def rate(code, mesure, variable, population, oui, connu, note="", modalite="",
                 bloc=None):
            denom = int((population & connu).sum())
            num = int((population & connu & oui).sum())
            emit(code, mesure, variable, num, denom, "%", modalite=modalite, note=note,
                 attendus=int(population.sum()), bloc=bloc)

        def median(code, mesure, variable, population, valeurs, unite, note="", bloc=None):
            vals = valeurs.where(population).dropna()
            emit(code, mesure, variable, None, len(vals), unite,
                 valeur=round(float(vals.median()), 2) if len(vals) else None, note=note,
                 attendus=int(population.sum()), bloc=bloc)

        def distribution(code, mesure, variable, population, lab, note="", bloc=None):
            observees = g.loc[population, variable]
            observees = observees[observees.isin(lab)]
            denom = len(observees)
            for cle, texte in lab.items():
                emit(code, mesure, variable, int(observees.eq(cle).sum()), denom, "%",
                     modalite=texte, note=note, attendus=int(population.sum()), bloc=bloc)

        tous = pd.Series(True, index=g.index)
        en_emploi = g.emploi_calcule.eq(1)
        sans_emploi = g.emploi_calcule.eq(0)
        salarie = en_emploi & g.F1.eq(1)
        independant = en_emploi & g.F1.isin([2, 3, 4])
        emit("D1.0", "Candidats retenus (population analysée)", "classe_completude,consentement",
             n, None, "personnes")

        # — D1 · Profil —
        distribution("D1.1", "Sexe", "sexe", tous, {"Homme": "Homme", "Femme": "Femme"})
        median("D1.2", "Âge : médiane", "age", tous, g.age_valide, "ans")
        distribution("D1.3", "Groupe d'âge", "age_groupe", tous,
                     {k: k for k in AGE_GROUPES})
        distribution("D1.4", "Statut matrimonial", "C3", g.C3.notna(), labels_de("C3"))
        distribution("D1.5", "Niveau d'études (regroupé)", "etudes_groupe",
                     g.etudes_groupe.notna(), {k: k for k in ETUDES_GROUPE})
        distribution("D1.6", "Diplôme le plus élevé obtenu", "C5", g.C5.notna(),
                     labels_de("C5"))
        distribution("D1.7", "Alphabétisation déclarée", "C6", g.C6.notna(), labels_de("C6"))
        rate("D1.8", "A changé de localité pour au moins 6 mois (12 derniers mois)", "C7",
             tous, g.C7.eq(1), g.C7.notna())
        distribution("D1.9", "Localité d'origine des personnes mobiles", "C8",
                     g.C8.notna(), labels_de("C8"), note="Populations mobiles uniquement (C7 = 1).")

        # — D2 · Ménage —
        median("D2.1", "Taille du ménage : médiane", "D1", tous, g.D1, "personnes")
        somme_moins15 = int(g.D2.fillna(0).sum())
        somme_menages = int(g.D1.fillna(0).sum())
        emit("D2.2", "Part des personnes de moins de 15 ans (rapport d'agrégation)",
             "D1,D2", somme_moins15, somme_menages, "%",
             valeur=round(100 * somme_moins15 / somme_menages, 2) if somme_menages else None,
             note="Somme des personnes de moins de 15 ans rapportée à la somme des tailles "
                  "de ménage (et non moyenne de ratios).",
             attendus=somme_menages)
        median("D2.3", "Personnes du ménage exerçant une activité rémunérée : médiane",
               "D4", tous, g.D4, "personnes")
        distribution("D2.4", "Position dans le ménage", "D3", g.D3.notna(), labels_de("D3"))
        rate("D2.5", "Ménage ne possédant aucun des biens listés", "D5__11", tous,
             g.D5__11.eq(1), g.D5__11.notna())
        for i in range(1, 11):
            col = f"D5__{i}"
            nom_bien = LIBELLES[col][1]
            rate(f"D2.{5 + i}", f"Ménage possédant : {nom_bien}", col, tous,
                 g[col].eq(1), g[col].notna())
        median("D2.16", "Nombre de biens détenus : médiane", "D5__1…D5__10", tous,
               g.nb_biens, "biens")

        # — D3 · Emploi —
        statut = pd.Series("Indéterminé", index=g.index)
        statut.loc[en_emploi] = "En emploi"
        statut.loc[sans_emploi & g.J0.eq(1)] = "Sans emploi, en recherche"
        statut.loc[sans_emploi & g.J0.eq(2)] = "Sans emploi, sans recherche"
        determine = statut.ne("Indéterminé")
        denom_statut = int(determine.sum())
        for categorie in ["En emploi", "Sans emploi, en recherche",
                          "Sans emploi, sans recherche"]:
            emit("D3.1", "Statut d'activité observé", "E1,E2,E3,E3A,J0",
                 int(statut.eq(categorie).sum()), denom_statut, "%", modalite=categorie,
                 note="La disponibilité des personnes en recherche n'est pas mesurée "
                      "pour tous ; aucun taux de chômage normatif.",
                 attendus=n)
        distribution("D3.2", "Type d'activité", "F1", en_emploi, labels_de("F1"))
        distribution("D3.3", "Secteur d'activité", "F2", en_emploi, labels_de("F2"))
        distribution("D3.4", "Lieu de travail", "F3", g.F3.notna(), labels_de("F3"))
        distribution("D3.5", "Ancienneté dans l'activité", "F4", g.F4.notna(), labels_de("F4"))
        distribution("D3.6", "Type d'accord de travail", "G1", g.G1.notna(), labels_de("G1"))
        rate("D3.7", "Couverture sociale déclarée", "G2", g.G2.notna(), g.G2.eq(1),
             g.G2.notna())
        median("D3.8", "Heures hebdomadaires de l'activité principale : médiane", "G3",
               en_emploi, g.heures_principales, "heures",
               note="Code 998 (ne sait pas) exclu.")
        heures_ok = g.heures_principales.notna()
        rate("D3.9", "Travaillant 40 heures ou plus par semaine", "G3", heures_ok,
             g.heures_principales.ge(40), heures_ok,
             note="Parmi les personnes ayant donné des heures valides.")
        rate("D3.10", "Exerce une autre activité rémunérée", "G5", en_emploi,
             g.G5.eq(1), g.G5.notna())
        distribution("D3.11", "Nature de l'autre activité (codage par mots-clés)",
                     "autre_activite_G5A", g.G5.eq(1) & g.autre_activite_G5A.ne(""),
                     {k: k for k in [f for f, _ in FAMILLES_METIER] + ["Autre ou non précisé"]},
                     note="Codage par mots-clés ; voir la section « Codages ».")
        rate("D3.12", "Heures saisies déclarées habituelles", "G4", g.G4.notna(), g.G4.eq(1),
             g.G4.notna())
        median("D3.13", "Heures hebdomadaires des autres activités : médiane", "G6",
               g.heures_secondaires.notna(), g.heures_secondaires, "heures",
               note="Uniquement pour les personnes déclarant une autre activité (G5 = 1).")
        rate("D3.14", "Souhaite travailler davantage d'heures", "G7", en_emploi,
             g.G7.eq(1), g.G7.notna(),
             note="Composante de sous-emploi ; pas un taux de sous-emploi.")
        distribution("D3.15", "Disponibilité pour plus d'heures dans les deux semaines",
                     "G7A", g.G7.eq(1) & g.G7A.notna(), labels_de("G7A"))

        # — D4 · Revenus —
        median("D4.1", "Salaire net de la dernière paie : médiane", "H3", salarie,
               g.montant_H3, "FCFA",
               note="Salariés seulement, montant exact ; fréquences de paie différentes.",
               )
        median("D4.2", "Salaire net mensuel (paie mensuelle) : médiane", "H3,H2",
               salarie & g.H2.eq(4), g.montant_H3, "FCFA/mois",
               note="Salariés payés mensuellement ; petit effectif.")
        distribution("D4.3", "Tranche de salaire (montant exact ou bande déclarée)",
                     "tranche_salaire", g.tranche_salaire.notna(),
                     {t: t for t in TRANCHES_ORDRE},
                     note="Couvre les montants exacts (H3) et les bandes (H3A).")
        median("D4.4", "Gain net du mois dernier : médiane", "H5", independant,
               g.gain_net_H5, "FCFA/mois",
               note="Employeurs, indépendants et coopératives ; gain net, pas chiffre "
                    "d'affaires ; strictement positif.")
        distribution("D4.5", "Tranche de gain net (montant exact ou bande déclarée)",
                     "tranche_gain", g.tranche_gain.notna(), {t: t for t in TRANCHES_ORDRE},
                     note="Couvre les montants exacts (H5) et les bandes (H5A).")
        distribution("D4.6", "Fréquence de paie", "H2", g.H2.notna(), labels_de("H2"))
        distribution("D4.7", "Forme de la rémunération déclarée", "H1", g.H1.notna(),
                     labels_de("H1"))
        distribution("D4.8", "Activité enregistrée", "H4", g.H4.notna(), labels_de("H4"),
                     note="Enregistrement fiscal, registre de commerce ou autorités locales.")
        ouvriers = g.H4A.between(0, 100)
        rate("D4.9", "Emploie au moins un travailleur rémunéré", "H4A", ouvriers,
             g.H4A.ge(1), ouvriers, note="Valeurs hors 0–100 exclues.")

        # — D5 · Recherche d'emploi —
        rate("D5.1", "En emploi mais recherche une autre activité", "I1", en_emploi,
             g.I1.eq(1), g.I1.notna())
        distribution("D5.2", "Motif de recherche (personnes en emploi)", "I2",
                     g.I1.eq(1), labels_de("I2"))
        distribution("D5.3", "Canal de recherche utilisé (personnes en emploi)", "I3",
                     g.I1.eq(1), labels_de("I3"))
        rate("D5.4", "Sans emploi et en recherche d'emploi", "J0", sans_emploi,
             g.J0.eq(1), g.J0.notna(),
             note="Part parmi les personnes sans emploi ; pas un taux de chômage.")
        distribution("D5.5", "Motif de non-recherche (sans emploi)", "J0A", g.J0.eq(2),
                     labels_de("J0A"))
        distribution("D5.6", "Canal de recherche (sans emploi)", "J1", g.J1.notna(),
                     labels_de("J1"))
        rate("D5.7", "Souhaiterait travailler actuellement", "J0B", g.J0B.notna(),
             g.J0B.eq(1), g.J0B.notna())
        distribution("D5.8", "Durée sans emploi et en recherche", "J2", g.J2.notna(),
                     labels_de("J2"))
        rate("D5.9", "Disponible pour démarrer dans les deux semaines si emploi trouvé",
             "J3", g.J3.notna(), g.J3.eq(1), g.J3.notna(),
             note="Sous-population interrogée sur la disponibilité ; ne couvre pas tous "
                  "les chercheurs.")

        # — D6 · Entrepreneuriat —
        rate("D6.1", "A déjà créé une activité génératrice de revenus", "K1", tous,
             g.K1.eq(1), g.K1.notna())
        rate("D6.2", "Souhaite créer une activité à l'avenir (sans activité actuelle)",
             "K2", g.K1.eq(2), g.K2.eq(1), g.K2.notna())
        distribution("D6.3", "Activité(s) déjà créée(s)", "K3", g.K1.eq(1), labels_de("K3"))
        distribution("D6.4", "Source de financement envisagée", "K4", g.K4.notna(),
                     labels_de("K4"))
        for i in [1, 2, 3, 4, 5, 6, 7, 9]:
            col = f"K5__{i}"
            rate(f"D6.{4 + [1, 2, 3, 4, 5, 6, 7, 9].index(i) + 1}",
                 f"Frein à la création : {LIBELLES[col][1]}", col, g.K1.eq(2),
                 g[col].eq(1), g[col].notna(),
                 note="Plusieurs réponses possibles ; la somme peut dépasser 100 %.")
        rate("D6.13", "Épargne en vue de créer une activité", "K6", g.K6.notna(),
             g.K6.eq(1), g.K6.notna())
        distribution("D6.14", "Auto-évaluation des compétences entrepreneuriales", "K7",
                     g.K7.notna(), labels_de("K7"))

        # — D7 · Financement et épargne —
        rate("D7.1", "Possède un compte Mobile Money", "L1", g.L1.notna(), g.L1.eq(1),
             g.L1.notna())
        rate("D7.2", "Possède un compte bancaire", "L2", g.L2.notna(), g.L2.eq(1),
             g.L2.notna())
        distribution("D7.3", "Épargne régulière", "L3", g.L3.notna(), labels_de("L3"))
        median("D7.4", "Épargne mise de côté par mois typique : médiane", "L4",
               g.L3.isin([1, 2]), g.L4.where(g.L4.between(0, 1e9)), "FCFA/mois",
               note="Parmi ceux qui déclarent épargner.")
        distribution("D7.5", "Mode d'épargne principal", "L5", g.L5.notna(), labels_de("L5"))
        rate("D7.6", "A un prêt ou une dette en cours", "L6", g.L6.notna(), g.L6.eq(1),
             g.L6.notna())
        distribution("D7.7", "Source du crédit en cours", "L7", g.L7.notna(), labels_de("L7"))
        l8_ok = g.L8.between(0, 1e9) & g.L8.ne(99998)
        median("D7.8", "Montant total dû : médiane", "L8", l8_ok,
               g.L8.where(l8_ok), "FCFA", note="Code 99998 (ne sait pas) exclu.")
        distribution("D7.9", "Motif principal du prêt", "L9", g.L9.notna(), labels_de("L9"))

        # — D8 · Formation et aspirations —
        rate("D8.1", "Formation ou apprentissage durant les 12 derniers mois", "O3",
             tous, g.O3.eq(1), g.O3.notna(),
             note="Formation générale ; aucune attribution possible à COSO.")
        distribution("D8.2", "Dispenseur de la formation", "O5", g.O3.eq(1), labels_de("O5"))
        distribution("D8.3", "Métier ou domaine de la formation (codage par mots-clés)",
                     "formation_O4", g.O4.fillna("").astype(str).str.strip().ne(""),
                     {k: k for k in [f for f, _ in FAMILLES_METIER] + ["Autre ou non précisé"]})
        distribution("D8.4", "Utilité perçue de la formation", "O6", g.O6.notna(),
                     labels_de("O6"))
        rate("D8.5", "A commencé un premier emploi ou une première activité", "O1",
             tous, g.O1.eq(1), g.O1.notna())
        o2 = g.O2.where(g.O2.between(5, 80))
        median("D8.6", "Âge au premier emploi : médiane", "O2", g.O1.eq(1), o2, "ans",
               note="Valeurs hors 5–80 ans exclues (années saisies par erreur).")
        o2_ok = o2.notna()
        rate("D8.7", "Premier emploi avant 18 ans", "O2", o2_ok & g.O1.eq(1),
             o2.lt(18), o2_ok, note="Parmi les âges plausibles (5–80 ans).")
        distribution("D8.8", "Projet principal", "P2", g.P2.notna(), labels_de("P2"))
        median("D8.9", "Revenu mensuel souhaité : médiane", "P3", tous,
               g.P3.where(g.P3.between(1, 5_000_000)), "FCFA/mois",
               note="Valeurs nulles ou supérieure à 5 M FCFA exclues (vraisemblance).")
        distribution("D8.10", "Secteur d'activité privilégié", "P4", g.P4.notna(),
                     labels_de("P4"))
        distribution("D8.11", "Métier ou activité visé à 5 ans (codage par mots-clés)",
                     "metier_P1", g.metier_P1.ne(""),
                     {k: k for k in [f for f, _ in FAMILLES_METIER] + ["Autre ou non précisé"]})
        distribution("D8.12", "Obstacle principal aux objectifs (codage par mots-clés)",
                     "obstacle_P5", g.obstacle_P5.ne(""),
                     {k: k for k in [f for f, _ in FAMILLES_OBSTACLE] + ["Autre ou non précisé"]})

        # — D9 · Trajectoires perçues —
        distribution("D9.1", "Autonomie économique actuelle", "M1", g.M1.notna(),
                     labels_de("M1"))
        distribution("D9.2", "Aide externe reçue sur 12 mois", "M2", g.M2.notna(),
                     labels_de("M2"))
        distribution("D9.3", "Contribution économique perçue", "M3", g.M3.notna(),
                     labels_de("M3"))
        distribution("D9.4", "Autonomie anticipée", "M4", g.M4.notna(), labels_de("M4"))
        mv = g.M1.notna() & g.M4.notna()
        progression = mv & g.M4.gt(g.M1)
        stabilite = mv & g.M4.eq(g.M1)
        recul = mv & g.M4.lt(g.M1)
        note_m = "M4 comparée à M1 pour les personnes répondant aux deux questions."
        rate("D9.5", "Trajectoire ascendante (M4 > M1)", "M1,M4", mv, progression, mv,
             note=note_m)
        rate("D9.6", "Stabilité (M4 = M1)", "M1,M4", mv, stabilite, mv, note=note_m)
        rate("D9.7", "Trajectoire descendante (M4 < M1)", "M1,M4", mv, recul, mv, note=note_m)

        # — D10 · Résilience et cohésion —
        rate("D10.1", "Ménage ayant subi un choc ou problème important", "N1", tous,
             g.N1.eq(1), g.N1.notna())
        distribution("D10.2", "Choc le plus important subi", "N2", g.N1.eq(1),
                     labels_de("N2"))
        distribution("D10.3", "Impact du choc", "N3", g.N1.eq(1), labels_de("N3"))
        distribution("D10.4", "Réponse au choc", "N4", g.N1.eq(1), labels_de("N4"))
        distribution("D10.5", "Délai de rétablissement", "N5", g.N1.eq(1), labels_de("N5"))
        distribution("D10.6", "Capacité à réunir 250 000 FCFA", "N6", g.N6.notna(),
                     labels_de("N6"))
        median("D10.7", "Capacité déclarée à résister à un choc : médiane", "N7", tous,
               g.N7.where(g.N7.between(1, 10)), "/10")
        rate("D10.8", "Membre d'une association ou organisation", "Q1", tous, g.Q1.eq(1),
             g.Q1.notna())
        q2ok = g.participations_Q2.notna()
        rate("D10.9", "Participation communautaire au moins une fois en 30 jours", "Q2",
             tous, g.participations_Q2.ge(1), q2ok,
             note="Textes non quantifiables et absents exclus du dénominateur.")
        rate("D10.10", "Confiance envers la plupart des gens", "Q3", tous, g.Q3.eq(1),
             g.Q3.notna())
        for i in range(4, 11):
            q = f"Q{i}"
            connu = g[q].isin([1, 2, 3, 4])
            rate(f"D10.{7 + i}", f"Confiance partielle ou forte : {q}", q, tous,
                 g[q].isin([3, 4]), connu,
                 note="Échelle 1–4 ; 9 (ne sait pas) exclu. « 3 » = partiellement confiance.")

        # — D11 · Qualité de l'enquête —
        distribution("D11.1", "Résultat de l'appel (essai ayant abouti)", "A4", tous,
                     labels_de("A4"))
        distribution("D11.2", "Numéro de tentative d'appel", "A1", g.A1.notna(),
                     labels_de("A1"))
        dur_ok = g.duree_valide.fillna(False)
        median("D11.3", "Durée de l'entretien : médiane", "durée (horodatages HH*)", tous,
               g.duree_entretien_min.where(dur_ok), "minutes",
               note="Horodatages bornés à 1–600 minutes.")
        distribution("D11.4", "Tranche de durée d'entretien", "tranche_duree", dur_ok,
                     {k: k for k in DUREE_TRANCHES})
        median("D11.5", "Taux de complétude de l'entretien : médiane", "taux_completude",
               tous, g.taux_completude * 100, "%")
        distribution("D11.6", "Classe de complétude", "classe_completude", tous,
                     {k: k for k in ["1-COMPLET", "2-QUASI_COMPLET"]})

    couverture = []
    for entree in COUVERTURE:
        mesures = CODES_PAR_INDICATEUR.get(entree["code"], [])
        codes_reels = sorted({l["code"] for l in lignes if l["code"] in mesures})
        couverture.append({**entree, "mesures": codes_reels})

    non_calculables = [{"code": e["code"], "indicateur": e["indicateur"],
                        "statut": e["statut"], "raison": e["limite"]}
                       for e in couverture if e["statut"] in ("indisponible", "en attente")]

    payload = {
        "metadata": {
            **meta,
            "date_calcul": date.today().isoformat(),
            "base_apuree": BASE.name,
            "n_variables": len(d.columns),
            "blocs": BLOCS,
        },
        "couverture": couverture,
        "non_calculables": non_calculables,
        "resultats": lignes,
    }
    return payload


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", type=Path, default=BASE)
    parser.add_argument("--meta", type=Path, default=META)
    parser.add_argument("--sortie", type=Path, default=SORTIE)
    args = parser.parse_args()
    resultat = calculer(args.base, args.meta)
    args.sortie.parent.mkdir(parents=True, exist_ok=True)
    args.sortie.write_text(json.dumps(resultat, ensure_ascii=False, indent=1),
                           encoding="utf-8")
    groupes_vus = len({(l["niveau"], l["district"], l["region"], l["sexe"],
                       l["age_groupe"], l["milieu"]) for l in resultat["resultats"]})
    print(json.dumps({"lignes": len(resultat["resultats"]), "groupes": groupes_vus,
                      "couverture": len(resultat["couverture"]),
                      "non_calculables": len(resultat["non_calculables"])},
                     ensure_ascii=False))
