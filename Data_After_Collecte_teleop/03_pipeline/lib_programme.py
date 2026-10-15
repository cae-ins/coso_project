"""lib_programme — Dérivations « analyse programme » (variante Arthur).

Ce module rassemble les règles de codage et de construction des variables
employées par les do-files d'Arthur, transposées en Python pour notre pipeline.
Il est utilisé par l'étape `12` (variables) et `13` (indicateurs).

Rien ici ne modifie le pipeline officiel des 21 indicateurs (étapes 07→11) :
ces dérivations alimentent le volet « analyse programme » séparé.

Trois écarts assumés par rapport au do-file d'Arthur sont documentés :

1. Codage sectoriel (`O4_sector`, `P4X_sector`, `P4_sector`) : repris à
   l'identique (mots-clés, ordre de priorité).
2. `sector_match` : le do-file d'Arthur (02_analysis.do, l.1570-1592) utilise
   un décalage systématique (+1) par rapport au codage officiel F2 (voir
   libelles_coso : 2 = industries extractives, 3 = industrie manufacturière,
   4 = construction, …). Sa propre en-tête de commentaire (« 2=Manufacturing,
   3=Construction, 4=Commerce… ») montre son intention. On implémente donc la
   version CORRIGÉE (`MODE_SECTOR_MATCH = "corrige"`), alignée sur le codage
   réel, tout en gardant la version littérale disponible (`"litteral"`).
3. `pens_skills` : Arthur traite K7 manquant comme faible (conservateur) ;
   c'est repris tel quel.
"""

from __future__ import annotations

import unicodedata

import numpy as np
import pandas as pd

# --------------------------------------------------------------------------- #
# Référentiels géographiques (identiques à l'étape 07)
# --------------------------------------------------------------------------- #
DISTRICTS = {105: "Denguélé", 111: "Savanes", 113: "Woroba", 114: "Zanzan"}
REGIONS = {10510: "Kabadougou", 10524: "Folon", 11103: "Poro", 11120: "Bagoué",
           11132: "Tchologo", 11314: "Worodougou", 11319: "Bafing", 11322: "Béré",
           11408: "Gontougo", 11423: "Bounkani"}

# Libellés des filières provisoires (Analyses 1 et suivantes)
TRACK = {
    1: "Filière A — Création d'entreprise",
    2: "Filière B — Développement d'une activité existante",
    3: "Filière C — Apprentissage vers l'emploi salarié",
    4: "Indéterminée (P2 non renseigné)",
}
TRACK_COURT = {1: "A — Création", 2: "B — Développement", 3: "C — Salarié",
               4: "Indéterminée"}

# Libellés des 25 codes métiers (trade_code) du do-file d'Arthur
TRADE = {
    1: "Commerce — vêtements/tissus", 2: "Commerce — vivres/produits agricoles",
    3: "Commerce — cosmétiques/beauté", 4: "Commerce — quincaillerie/matériaux",
    5: "Commerce — autres spécifiques", 6: "Commerce — générique/non précisé",
    7: "Coiffure/esthétique", 8: "Couture/cordonnerie",
    9: "Maçonnerie/carrelage/BTP", 10: "Menuiserie/bois",
    11: "Mécanique auto/moto", 12: "Électricité", 13: "Soudure/ferronnerie",
    14: "Peinture/décoration", 15: "Plomberie", 16: "Froid/climatisation",
    17: "Vulcanisation/réparation pneus", 18: "Réparation téléphone/électronique",
    19: "Élevage", 20: "Agriculture/cultures", 21: "Transport/conduite",
    22: "Restauration/maquis", 23: "Pâtisserie/transformation alimentaire",
    24: "Santé/social/secteur public", 25: "Non codable/autre",
}

# Secteurs (P4 / F2 / O4_sector) — codage officiel du codebook
SECTEUR = {
    1: "Agriculture, élevage, pêche, sylviculture", 2: "Industries extractives",
    3: "Industrie manufacturière", 4: "Construction/BTP",
    5: "Commerce de gros ou de détail", 6: "Transport, entreposage, logistique",
    7: "Hébergement et restauration",
    8: "Information, communication, services numériques",
    9: "Activités financières et d'assurance", 10: "Administration publique",
    11: "Éducation", 12: "Santé humaine et action sociale",
    13: "Travail domestique chez un particulier",
    14: "Autres services (réparation, services personnels, arts)",
    97: "Non classé (texte non reconnu)", 98: "Non spécifique (ex. entrepreneuriat)",
}

# GAP_LEVEL (Analyses 9)
GAP_LEVEL = {
    0: "Non applicable (aspiration non technique)",
    1: "Faible (évaluation ou module court)",
    2: "Moyen (module technique court, 1–2 mois)",
    3: "Moyen-élevé (module structuré + mentorat)",
    4: "Élevé (apprentissage complet recommandé)",
}

# Codes métiers disposant d'un MAF équivalent dans le catalogue SONET-CI
TRADES_MAF = (7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21)

# Facteur de conversion en mensuel d'après la fréquence de paie H2 (Arthur, 01 l.690)
FACTEUR_H2 = {1: 26.0, 2: 52 / 12, 3: 26 / 12, 4: 1.0,
              5: 1 / 2, 6: 1 / 3, 7: 1 / 6, 8: 1 / 12}

# --------------------------------------------------------------------------- #
# Matrice de référence MAF (SONET-CI, septembre 2026)
#   477 MAF, 14 métiers × 10 régions. Transcrite du do-file d'Arthur
#   (02_analysis.do, l.1835+). Source externe, embarquée ici pour que le
#   pipeline reste autoportant ; 01_sources/maf_sonet_ci.csv est identique.
# --------------------------------------------------------------------------- #
MAF_SONET_CI_TEXTE = """\
7 PORO 8
7 BAGOUE 13
7 GONTOUGO 16
7 BOUNKANI 13
7 BERE 12
7 FOLON 6
7 TCHOLOGO 2
7 KABADOUGOU 4
7 BAFING 2
7 WORODOUGOU 1
8 PORO 9
8 BAGOUE 2
8 GONTOUGO 10
8 BOUNKANI 8
8 BERE 9
8 FOLON 9
8 TCHOLOGO 8
8 KABADOUGOU 2
8 BAFING 3
8 WORODOUGOU 0
9 PORO 20
9 BAGOUE 35
9 GONTOUGO 5
9 BOUNKANI 2
9 BERE 6
9 FOLON 7
9 TCHOLOGO 1
9 KABADOUGOU 1
9 BAFING 0
9 WORODOUGOU 1
10 PORO 10
10 BAGOUE 10
10 GONTOUGO 7
10 BOUNKANI 5
10 BERE 1
10 FOLON 7
10 TCHOLOGO 4
10 KABADOUGOU 2
10 BAFING 2
10 WORODOUGOU 1
11 PORO 10
11 BAGOUE 12
11 GONTOUGO 0
11 BOUNKANI 7
11 BERE 4
11 FOLON 8
11 TCHOLOGO 2
11 KABADOUGOU 0
11 BAFING 2
11 WORODOUGOU 4
12 PORO 12
12 BAGOUE 5
12 GONTOUGO 4
12 BOUNKANI 1
12 BERE 3
12 FOLON 1
12 TCHOLOGO 4
12 KABADOUGOU 1
12 BAFING 0
12 WORODOUGOU 1
13 PORO 11
13 BAGOUE 4
13 GONTOUGO 1
13 BOUNKANI 4
13 BERE 2
13 FOLON 3
13 TCHOLOGO 2
13 KABADOUGOU 0
13 BAFING 2
13 WORODOUGOU 0
14 PORO 6
14 BAGOUE 5
14 GONTOUGO 10
14 BOUNKANI 5
14 BERE 2
14 FOLON 1
14 TCHOLOGO 3
14 KABADOUGOU 1
14 BAFING 1
14 WORODOUGOU 0
15 PORO 3
15 BAGOUE 2
15 GONTOUGO 3
15 BOUNKANI 0
15 BERE 0
15 FOLON 0
15 TCHOLOGO 0
15 KABADOUGOU 3
15 BAFING 0
15 WORODOUGOU 0
16 PORO 0
16 BAGOUE 0
16 GONTOUGO 0
16 BOUNKANI 0
16 BERE 0
16 FOLON 0
16 TCHOLOGO 0
16 KABADOUGOU 0
16 BAFING 0
16 WORODOUGOU 0
17 PORO 0
17 BAGOUE 0
17 GONTOUGO 0
17 BOUNKANI 0
17 BERE 0
17 FOLON 0
17 TCHOLOGO 0
17 KABADOUGOU 0
17 BAFING 0
17 WORODOUGOU 0
18 PORO 1
18 BAGOUE 1
18 GONTOUGO 0
18 BOUNKANI 2
18 BERE 0
18 FOLON 0
18 TCHOLOGO 0
18 KABADOUGOU 0
18 BAFING 0
18 WORODOUGOU 0
19 PORO 5
19 BAGOUE 0
19 GONTOUGO 6
19 BOUNKANI 4
19 BERE 10
19 FOLON 0
19 TCHOLOGO 1
19 KABADOUGOU 0
19 BAFING 2
19 WORODOUGOU 2
21 PORO 2
21 BAGOUE 0
21 GONTOUGO 0
21 BOUNKANI 0
21 BERE 0
21 FOLON 0
21 TCHOLOGO 6
21 KABADOUGOU 0
21 BAFING 0
21 WORODOUGOU 0"""


def donnees_maf() -> pd.DataFrame:
    """Renvoie la matrice MAF (trade_code, region, supply) embarquée."""
    enregistrements = [l.split() for l in MAF_SONET_CI_TEXTE.strip().splitlines()]
    return pd.DataFrame([(int(a), b, int(c)) for a, b, c in enregistrements],
                        columns=["trade_code", "region", "supply"])


def charger_maf(chemin=None) -> pd.DataFrame:
    """Lit le CSV de référence s'il existe, sinon la matrice embarquée."""
    if chemin is not None:
        from pathlib import Path as _Path
        p = _Path(chemin)
        if p.exists():
            return pd.read_csv(p)
    return donnees_maf()


MODE_SECTOR_MATCH = "corrige"  # ou "litteral"


# --------------------------------------------------------------------------- #
# Normalisation de texte (majuscules, sans accents, espaces simples)
# --------------------------------------------------------------------------- #
def normaliser(texte) -> str:
    if texte is None or (isinstance(texte, float) and np.isnan(texte)):
        return ""
    s = str(texte)
    s = s.replace("\u2019", "'").replace("`", "'")
    s = "".join(c for c in unicodedata.normalize("NFD", s)
                if unicodedata.category(c) != "Mn")
    return " ".join(s.upper().split())


# --------------------------------------------------------------------------- #
# 6.10 — Codage du secteur (O4, P4X) par mots-clés
#   L'ordre compte : une règle postérieure écrase une règle antérieure.
# --------------------------------------------------------------------------- #
def _match(cond, t: str) -> bool:
    if callable(cond):
        return bool(cond(t))
    if isinstance(cond, tuple):
        return all(normaliser(k) in t for k in cond)
    return normaliser(cond) in t


SECTEUR_REGLES = [
    (6, ["CHAUFFEUR", "CONDUCTEUR", "TRANSPORT"]),
    (1, ["ELEVAGE", "ELEVEUR", "VOLAILLE", "POULET", "AQUACULTURE", "PISCICULT",
         "AGRICULT", "AGRICOLE", "CULTIVAT", "LABOUR"]),
    (3, ["FORGE", "MENUIS", "MENUSERIE", "SCIERIE", "TAPISSERIE",
         "AGROALIMENTAIRE", "TRANSFORMATION"]),
    (4, ["BTP", "BATIMENT", "MACON", "CARREL", "ELECTRI", "PLOMB", "PEINT"]),
    (5, ["COMMERC", "VENTE", "VENDEU"]),
    (7, ["PATISS", "CUISIN", "RESTAURA"]),
    (8, ["COMMUNICATION", "MARKETING", "INFORMATIQUE"]),
    (9, ["TRANSFERT", "COMPTAB"]),
    (14, ["COUTUR", "COIFF", "TRESS", "ESTHETI", "ONGLE", "MECANI", "PHOTO",
          "FERRON", "FERON"]),
    (98, ["ENTREPREN", "HUMANITAIRE", "SENSIBILISATION", "ETAT CIVIL"]),
]


def coder_secteur(texte) -> float | None:
    """Reproduit le bloc 6.10 d'Arthur. None si le texte est vide."""
    if texte is None:
        return None
    try:
        if pd.isna(texte):
            return None
    except (TypeError, ValueError):
        pass
    if str(texte).strip() == "":
        return None
    t = " " + normaliser(texte) + " "
    code = 97
    for valeur, conditions in SECTEUR_REGLES:
        if any(_match(c, t) for c in conditions):
            code = valeur
    return code


# --------------------------------------------------------------------------- #
# 9.1 — Codage du métier (trade_code 1-25) depuis P1 (premier match gagnant)
# --------------------------------------------------------------------------- #
TRADE_REGLES = [
    (1, ["PAGNE", "VETEMENT", "CHAUSSURE", "HABIT", "MERCERIE", "MODE",
         "PRET-A-PORTER", "MAGASIN DE VETEMENT", "COMMERCE D HABIT",
         "COMMERCE D'ARTICLES POUR FEMMES", "VENDEUSE DE PRET"]),
    (2, ["POISSON", "POSSONNIERE", "VIVRIER", "MANIOC", "MAIS", "ANACARDE",
         "IGNAME", "MARAICH", "CHAMBRE FROIDE", "PRODUIT AGRICOLE",
         "PRODUITS AGRICOLES", "ACHETEUR VIVRIER", "ACHATEUR", "VENTE D'EAU",
         "VENTE D EAU", "NOURRITURE", "ATIEKE", "SUCRE", "SAVON", "BOISSON",
         "MAQUIS RESTAURANT"]),
    (3, ["COSMETIQUE", "POMMADE"]),
    (4, ["QUINCAILL", "CIMENT", "COMMERCE EN CONSTRUCTION",
         "COMMERCE MATERIEL DE CONSTRUCTION", "MATERIEL DE CONSTRUCTION",
         ("PEINTURE", "MAGASIN")]),
    (5, ["ESSENCE", "ESSENSE", "PIECE DETACHE", "TELEPHONE ET ACCESSOIRE",
         ("POULET", "COMMERCE"), ("BOEUF", "COMMERCE"), "USTENCILE", "DIVERS",
         ("GAZ", "VENTE"), "MOTO ET PIECES", "VENTE DE PIECES"]),
    (6, ["COMMERCE", "COMMERC", "BOUTIQUE", "MAGASIN", "GROSSISTE", "KIOSQUE",
         "VENDEUR", "VENDEUSE", lambda t: t == "VENTE DE SAVON",
         "GERANT DE", "GERANTE DE"]),
    (7, ["COIFFURE", "COIFFEUR", "COIFFEUSE", "SALON DE COIFFURE", "ESTHETIQUE",
         "ONGLERIE", "PEDICURE", "MANICURE", "BEAUTE"]),
    (8, ["COUTURE", "COUTURIER", "COUTURIERE", "TAPISSERIE", "TAPISSIER",
         "SALON DE COUTURE", "COUTURE ET MERCERIE"]),
    (9, ["MACON", "MACONN", "CARRELEUR", "CARRELAGE", "CARRELLAGE",
         "BRIQUE FABRIQUE", "ENTREPRENEUR BTP", "ENTREPRENEUR BATIMENT",
         "BATIMENT", "CONSTRUCTION /BTP", "CONSTRUCTION/BTP"]),
    (10, ["MENUISERIE", "MENUISIERIE", "MENUSERIE", "MENUISIER", "CHARPENTE",
          "SCIEUR"]),
    (11, ["MECANICIEN", "MECANIQUE", "GARAGE",
          ("REPARATION", "VEHICULE")]),
    (12, ["ELECTRICIEN", "ELETRICIEN", "ELECTRICITE", "ELEVAGE ELECTRICITE"]),
    (13, ["SOUDURE", "SOUDEUR", "FERRONN", "FERONN", "FERRONNIER", "FORGERON",
          "ENTREPRISE DE FORGERON"]),
    (14, [lambda t: "PEINTRE" in t or ("PEINTURE" in t and "MAGASIN" not in t)]),
    (15, ["PLOMBERIE", "PLOMBIER"]),
    (16, ["FROID", "CLIMATISATION"]),
    (17, ["VULCANIS", "VULGANIS", "VIGANIS"]),
    (18, ["REPARATEUR DE TELEPHONE", "REPARATION DE TELEPHONE",
          "GESTION DES CABINES", "MAGASIN DE TELEPHONE"]),
    (19, ["ELEVAGE", "ELEVEUR", "ELEVEURS", "EVELAGE", "POULAILLER", "POULAYE",
          "GERANT FERME", "INVESTIR DANS MON POULAYER", "PROJET DE PORCS",
          "SOUHAITE FAIRE L ELEVAGE", "DEVELLOPER L'ELEVAGE",
          "JE FAIS DE L'ELEVAGE"]),
    (20, ["AGRICULTURE", "AGRICULTEUR", "CULTIVATEUR", "CULTIVATRICE", "CULTURE",
          "PLANTEUR", "MARAICH", "CHAMPS", "TRAVAUX CHAMPETRES",
          "RENFORCER SO CHAMPS", "AGRADIR LES TRAVAUX", "GRAND AGRICULTEUR",
          "CHAUFFEUR D ENGINS AGRICOLE", "MEUNIER"]),
    (21, ["TRANSPORT", "CHAUFFEUR", "CONDUCTEUR", "CONDUITE",
          "PROPRIETAIRE DE VEHICULE"]),
    (22, ["RESTAURAT", "MAQUIS", "OUVRIRE UN MAQUIS", "MAQUI RESTAURANT"]),
    (23, ["PATISSERIE", "PATISERIE", "PATISSIERE", "BROYEUSE"]),
    (24, ["SAGE FEMME", "INFIRMIER", "AIDE SOIGNANTE", "EDUCATRICE", "IMMOBILIER",
          "JOURNALISTE", "MILITAIRE", "FONCTION PUBLIQUE"]),
]


def coder_metier(p1) -> int:
    """Reproduit le bloc 9.1b : trade_code 1-25 (25 = non codable)."""
    t = normaliser(p1)
    for valeur, conditions in TRADE_REGLES:
        if any(_match(c, t) for c in conditions):
            return valeur
    return 25


# --------------------------------------------------------------------------- #
# 9.3a — Correspondance secteur courant (F2) ↔ métier visé (trade_code)
#   Version corrigée : alignée sur le codage officiel F2 du codebook.
# --------------------------------------------------------------------------- #
def _sector_match_corrige(f2, trade_code) -> int:
    if pd.isna(f2) or pd.isna(trade_code):
        return 0
    f2 = int(f2)
    t = int(trade_code)
    paires = {
        1: (19, 20),                              # agriculture/élevage
        3: (8, 23),                               # industrie manufacturière
        4: (9, 10, 12, 13, 14, 15, 16),           # construction/BTP
        5: (1, 2, 3, 4, 5, 6),                    # commerce
        6: (21,),                                 # transport
        7: (22,),                                 # hébergement/restauration
        8: (18,),                                 # information/numérique
        14: (7, 8, 11, 13, 17, 18),               # autres services
        13: (7,),                                 # travail domestique
    }
    return int(t in paires.get(f2, ()))


def _sector_match_litteral(f2, trade_code) -> int:
    """Transcription stricte du do-file (avec le décalage d'origine)."""
    if pd.isna(f2) or pd.isna(trade_code):
        return 0
    f2 = int(f2)
    t = int(trade_code)
    paires = {
        1: (19, 20), 2: (8, 23), 3: (9, 10, 12, 13, 14, 15, 16),
        4: (1, 2, 3, 4, 5, 6), 5: (21,), 6: (22,), 7: (18,),
        12: (7, 8, 11, 13, 17, 18), 13: (7,),
    }
    return int(t in paires.get(f2, ()))


def calculer_sector_match(d: pd.DataFrame, mode: str = MODE_SECTOR_MATCH) -> pd.Series:
    f = _sector_match_corrige if mode == "corrige" else _sector_match_litteral
    return pd.Series([f(f2, t) for f2, t in zip(d.F2, d.trade_code)],
                     index=d.index, dtype="Int64")


# --------------------------------------------------------------------------- #
# Construction complète des variables « programme » sur une base apurée
# --------------------------------------------------------------------------- #
def deriver(d: pd.DataFrame, mode_sector_match: str = MODE_SECTOR_MATCH) -> pd.DataFrame:
    """Ajoute les variables dérivées d'Arthur à une copie de `d`.

    `d` doit contenir les colonnes de base_apuree.csv et, idéalement, B4 et
    P44X (fusionnés par l'appelant). Les colonnes manquantes sont tolérées.
    """
    d = d.copy()

    # — Filières (Analyse 1) —
    track = pd.Series(4, index=d.index, dtype="Int64")
    track = track.mask(d.P2.eq(2), 1).mask(d.P2.eq(3), 2).mask(d.P2.eq(1), 3)
    d["track"] = track
    d["track_libelle"] = track.map(TRACK)
    d["track_court"] = track.map(TRACK_COURT)
    d["crit_A"] = (track == 1).astype("Int64")
    d["crit_B"] = (track == 2).astype("Int64")
    d["crit_C"] = (track == 3).astype("Int64")

    # — Codage sectoriel (bloc 6.10) —
    d["O4_sector"] = [coder_secteur(x) for x in d.get("O4", pd.Series(index=d.index))]
    p4x = d.get("P44X", pd.Series(index=d.index))
    d["P4X_sector"] = [coder_secteur(x) for x in p4x]
    p4_sector = d.P4.astype("Float64").copy()
    repl = d.P4.eq(99) & d.P4X_sector.isin(range(1, 15))
    p4_sector = p4_sector.mask(repl, d.P4X_sector)
    d["P4_sector"] = p4_sector.astype("Int64")

    # — Adéquation formation ↔ aspiration (Analyse 3) —
    ok = d.O3.eq(1) & d.O4_sector.isin(range(1, 15))
    tm = (d.O4_sector == d.P4_sector)
    d["train_match"] = tm.where(ok).astype("Int64")

    # — Codage métier et drapeau MAF (Analyse 9) —
    p1 = d.get("P1", pd.Series(index=d.index))
    d["trade_code"] = [coder_metier(x) for x in p1]
    d["trade_libelle"] = d.trade_code.map(TRADE)
    d["maf_match"] = d.trade_code.isin(TRADES_MAF).astype("Int64")

    # — Gap technique (Analyse 9.3) —
    d["sector_match"] = calculer_sector_match(d, mode_sector_match)
    empl = d.emploi_calcule.eq(1)
    d.loc[~empl, "sector_match"] = 0
    d["sector_match"] = d.sector_match.astype("Int64")
    # Stata : `O3 == 0` est faux quand O3 est manquant → pénalité 0.
    d["pens_training"] = (d.O3.eq(0) & (d.train_match.isna()
                                        | d.train_match.eq(0))).astype("Int64")
    d["pens_sector"] = d.sector_match.eq(0).astype("Int64")
    # Arthur : K7 manquant traité comme faible (conservateur).
    d["pens_skills"] = ((d.K7 <= 2) | d.K7.isna()).astype("Int64")
    d["gap_score"] = (d.pens_training.fillna(0) + d.pens_sector.fillna(0)
                      + d.pens_skills.fillna(0)).astype("Int64")
    gl = pd.Series(pd.NA, index=d.index, dtype="Int64")
    gl = gl.mask(d.gap_score.eq(0), 1).mask(d.gap_score.eq(1), 2) \
           .mask(d.gap_score.eq(2), 3).mask(d.gap_score.eq(3), 4)
    gl = gl.mask(d.trade_code.isin([1, 2, 3, 4, 5, 6, 20, 22, 23, 24, 25]), 0)
    gl = gl.mask(d.track.eq(2) & d.sector_match.eq(1) & gl.gt(1), 1)
    d["gap_level"] = gl

    # — Vulnérabilité du ménage (Analyse 4) —
    d["vuln_1"] = (d.N6.eq(3)).where(d.N6.notna()).astype("Int64")
    d["vuln_2"] = (d.M2.eq(1)).where(d.M2.notna()).astype("Int64")
    d["vuln_3"] = (d.D4.eq(0)).where(d.D4.notna()).astype("Int64")
    ratio = (d.D2.astype("Float64") / d.D1.astype("Float64")).where(d.D1.gt(0) & d.D1.notna())
    d["vuln_4"] = (ratio >= 0.5).where(ratio.notna()).astype("Int64")
    d["vuln_5"] = (d.nb_biens <= 2).where(d.nb_biens.notna()).astype("Int64")
    signes = d[["vuln_1", "vuln_2", "vuln_3", "vuln_4", "vuln_5"]]
    d["vuln_score"] = signes.sum(axis=1, skipna=False).astype("Int64")
    d["high_vuln"] = (d.vuln_score >= 3).where(d.vuln_score.notna()).astype("Int64")

    # — Revenus mensualisés et heures (Arthur, 01 l.684-703) —
    d["heures_total"] = d.heures_principales + d.heures_secondaires.fillna(0)
    d["heures_total"] = d.heures_total.where(d.heures_principales.notna())
    facteur = d.H2.map(FACTEUR_H2).astype("Float64")
    d["salaire_mensuel"] = (d.montant_H3.astype("Float64") * facteur).round(0)
    d["revenu_mensuel"] = d.salaire_mensuel
    d.loc[d.F1.isin([2, 3, 4]), "revenu_mensuel"] = d.loc[d.F1.isin([2, 3, 4]), "gain_net_H5"]
    d["P3_clean"] = d.P3.where(d.P3.gt(0) & d.P3.le(5_000_000))

    # — Planification géographique (Analyse 7) —
    d["cluster"] = (d.region.fillna("—") + " × " + d.milieu.fillna("—"))
    return d


def tableau_geo(d: pd.DataFrame) -> pd.DataFrame:
    """Densité / dispersion par cluster (Analyse 7.3)."""
    if "cluster" not in d:
        return pd.DataFrame()
    lignes = []
    for cluster, sub in d.groupby("cluster", sort=True):
        b4 = sub["B4"].dropna() if "B4" in sub else pd.Series(dtype=float)
        n_sp = b4.nunique()
        n_b4 = int(b4.shape[0])
        per_sp = (n_b4 / n_sp) if n_sp else np.nan
        lignes.append({
            "cluster": cluster,
            "n": int(len(sub)),
            "n_avec_sous_pref": n_b4,
            "n_sous_prefectures": int(n_sp),
            "applicants_par_sous_pref": round(per_sp, 2) if pd.notna(per_sp) else None,
            "sparse": (per_sp < 5) if pd.notna(per_sp) else None,
        })
    return pd.DataFrame(lignes)
