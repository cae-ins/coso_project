"""13 — Calculer les indicateurs « analyse programme » (variante Arthur).

Entrées :
  - 04_resultats/analyse_programme/base_programme.csv   (étape 12)
  - 01_sources/maf_sonet_ci.csv                          (matrice MAF SONET-CI)
  - 02_bases/Questionnaire_COSO_VF_avec_completude.dta   (entonnoir genre, option)
Sortie :
  - 04_resultats/analyse_programme/indicateurs_programme.json

Le JSON contient une liste de « tableaux » prêts à écrire (entêtes + lignes),
une section « statistiques » (percentiles/moyennes), une section « maf »
(écart offre/demande) et une section « entonnoir » (diagnostic genre).
Aucun de ces éléments n'entre dans les 21 indicateurs officiels.

Les scores composites (vuln_score, gap_score/gap_level) suivent la recette
d'Arthur, telle quelle, et sont étiquetés « exploratoire ».
"""

from __future__ import annotations

import argparse
import json
from datetime import date
from pathlib import Path

import numpy as np
import pandas as pd

import lib_programme as LP

ICI = Path(__file__).resolve().parent
RACINE = ICI.parent
BASE = RACINE / "04_resultats" / "analyse_programme" / "base_programme.csv"
MAF = RACINE / "01_sources" / "maf_sonet_ci.csv"
TENTATIVES = RACINE / "02_bases" / "Questionnaire_COSO_VF_avec_completude.dta"
SORTIE = RACINE / "04_resultats" / "analyse_programme" / "indicateurs_programme.json"

BLOCS = {
    "P1": "P1 · Filières du programme",
    "P2": "P2 · Concentration et saturation sectorielles",
    "P3": "P3 · Formation et adéquation",
    "P4": "P4 · Vulnérabilité des ménages (exploratoire)",
    "P5": "P5 · Métiers et gap technique (exploratoire)",
    "P6": "P6 · Écart offre / demande MAF (SONET-CI)",
    "P7": "P7 · Planification géographique",
    "P8": "P8 · Revenus, heures et profil",
    "P9": "P9 · Croisements (trajectoires, formation, confiance)",
    "P10": "P10 · Entonnoir de participation par sexe (diagnostic)",
}


# --------------------------------------------------------------------------- #
# Utilitaires de mise en tableau
# --------------------------------------------------------------------------- #
def _cats(serie: pd.Series, ordre=None):
    vues = [v for v in serie.dropna().unique()]
    if ordre:
        connues = [v for v in ordre if v in set(vues)]
        reste = sorted([v for v in vues if v not in set(connues)])
        return connues + reste
    return sorted(vues)


def _fmt(n, pct, mode):
    if n is None or (isinstance(n, float) and np.isnan(n)):
        return ""
    if pct is None:
        return f"{int(n)}"
    return f"{int(n)} ({pct:.1f} %)".replace(".", ",")


def croise(sub: pd.DataFrame, col_ligne, col_col, titre, bloc, cle,
           ordre_ligne=None, ordre_col=None, mode="colonne", note=None,
           trier_par_effectif=False, masquer_vides=False):
    """Tableau croisé rendu sous forme « n (p %) »."""
    df = pd.DataFrame({"l": col_ligne, "c": col_col}).dropna()
    lignes_cat = _cats(df.l, ordre_ligne)
    cols_cat = _cats(df.c, ordre_col)
    if trier_par_effectif:
        lignes_cat = sorted(lignes_cat, key=lambda k: -(df.l == k).sum())
    total = len(df)
    entetes = [""] + [str(c) for c in cols_cat] + ["Total"]
    lignes = []
    for l in lignes_cat:
        sl = df[df.l == l]
        n_l = len(sl)
        if masquer_vides and n_l == 0:
            continue
        rang = [str(l)]
        for c in cols_cat:
            n = int(((sl.c == c)).sum())
            n_col = int((df.c == c).sum())
            pct = (100 * n / n_col) if (mode in ("colonne", "cellule")
                                        and n_col) else None
            if mode == "ligne":
                pct = (100 * n / n_l) if n_l else None
            if mode == "cellule":
                pct = (100 * n / total) if total else None
            rang.append(_fmt(n, pct, mode))
        rang.append(_fmt(n_l, (100 * n_l / total) if total else None, mode))
        lignes.append(rang)
    # ligne de totaux
    tot = ["Total"]
    for c in cols_cat:
        n = int((df.c == c).sum())
        tot.append(_fmt(n, None, mode))
    tot.append(_fmt(total, None, mode))
    lignes.append(tot)
    return {"cle": cle, "bloc": bloc, "titre": titre, "note": note,
            "entetes": entetes, "lignes": lignes, "n_total": total}


def distribution(sub: pd.DataFrame, serie, titre, bloc, cle, ordre=None,
                 note=None, trier_par_effectif=False):
    s = serie.dropna()
    const = pd.Series("Ensemble", index=s.index)
    return croise(sub, s, const, titre, bloc, cle, ordre_ligne=ordre,
                  ordre_col=["Ensemble"], mode="colonne", note=note,
                  trier_par_effectif=trier_par_effectif)


def stats_table(sub: pd.DataFrame, serie, titre, bloc, cle, groupes=None,
                groupes_ordre=None, unite="", note=None):
    """N, moyenne, P25, médiane, P75 par groupe (ou global)."""
    df = pd.DataFrame({"v": pd.to_numeric(serie, errors="coerce")})
    if groupes is not None:
        df["g"] = pd.Series(groupes).reindex(df.index)
        groups = _cats(df.g, groupes_ordre)
    else:
        df["g"] = "Ensemble"
        groups = ["Ensemble"]
    entetes = ["Groupe", "N", "Moyenne", "P25", "Médiane", "P75", unite or "Min–Max"]
    lignes = []
    for g in groups:
        v = df.loc[df.g == g, "v"].dropna()
        if len(v) == 0:
            lignes.append([str(g), "0", "", "", "", "", ""])
            continue
        lignes.append([
            str(g), str(len(v)),
            f"{v.mean():.1f}".replace(".", ","),
            f"{v.quantile(.25):.0f}",
            f"{v.median():.0f}",
            f"{v.quantile(.75):.0f}",
            f"{v.min():.0f}–{v.max():.0f}",
        ])
    return {"cle": cle, "bloc": bloc, "titre": titre, "note": note,
            "entetes": entetes, "lignes": lignes}


# --------------------------------------------------------------------------- #
# Calcul des blocs
# --------------------------------------------------------------------------- #
def bloc_filieres(d):
    t = []
    d["_track"] = d.track.map(LP.TRACK_COURT)
    t.append(distribution(d, d["_track"], "Filière provisoire (P2)", "P1", "1A",
                          ordre=list(LP.TRACK_COURT.values()),
                          note="Trois filières A/B/C + les P2 non renseignés. "
                               "Population : 664 candidats (notre population)."))
    t.append(croise(d, d["_track"], d["sexe"], "Filière par sexe", "P1", "1B",
                    ordre_ligne=list(LP.TRACK_COURT.values()),
                    ordre_col=["Homme", "Femme"], mode="colonne"))
    t.append(croise(d, d["_track"], d["district"], "Filière par district", "P1", "1C",
                    ordre_ligne=list(LP.TRACK_COURT.values()), mode="colonne"))
    return t


def bloc_saturation(d):
    t = []
    d["_p4s"] = d.P4_sector.map(LP.SECTEUR)
    d["_f2"] = d.F2.map(LP.SECTEUR)
    t.append(distribution(d, d["_p4s"], "Secteur aspiré (P4, « autre » recodé)",
                          "P2", "2A", trier_par_effectif=True,
                          note="Part de chaque secteur dans l'ensemble de la population."))
    t.append(croise(d, d["_p4s"], d["region"],
                    "Secteur aspiré par région (n et % de la région)", "P2", "2B",
                    mode="colonne", trier_par_effectif=True))
    # Saturation : part maximale par région
    lignes = []
    for region, sub in d.groupby("region", sort=True):
        part = sub["_p4s"].value_counts(normalize=True) * 100
        if part.empty:
            continue
        top = part.idxmax()
        parts = ", ".join(f"{k} ({v:.0f} %)" for k, v in part.head(3).items())
        lignes.append([region, len(sub), str(top), f"{part.max():.1f}".replace(".", ","),
                       "Oui" if part.max() > 30 else "Non", parts])
    t.append({"cle": "2C", "bloc": "P2",
              "titre": "Saturation sectorielle (aspiré) : secteur dominant par région",
              "note": "Seuil d'alerte : > 30 % de la région sur un même secteur. "
                      "Régions de petite taille : lire avec les effectifs.",
              "entetes": ["Région", "N", "Secteur dominant", "Part (%)", "Saturation (>30 %)",
                          "Top 3"],
              "lignes": lignes})
    # Secteur actuel des personnes en emploi
    empl = d[d.emploi_calcule == 1].copy()
    t.append(distribution(empl, empl["_f2"],
                          "Secteur actuel (F2) des personnes en emploi", "P2", "2D",
                          trier_par_effectif=True))
    return t


def bloc_formation(d):
    t = []
    d["_o4s"] = d.O4_sector.map(LP.SECTEUR)
    t.append(distribution(d[d.O4_sector.notna()], d.loc[d.O4_sector.notna(), "_o4s"],
                          "Domaine de la formation suivie (O4 codé)", "P3", "3A",
                          trier_par_effectif=True,
                          note="Formations des 12 derniers mois (O3 = Oui). "
                               "97 = non classé, 98 = non spécifique."))
    tr = d[d.O3 == 1].copy()
    t.append(croise(tr, tr["_o4s"], tr["_p4s"] if "_p4s" in tr else tr.P4_sector.map(LP.SECTEUR),
                    "Domaine de formation (O4 codé) par secteur aspiré", "P3", "3B",
                    mode="colonne"))
    tr["_tm"] = tr.train_match.map({1: "Correspond", 0: "Ne correspond pas"})
    t.append(distribution(tr, tr["_tm"],
                          "Adéquation formation ↔ aspiration (train_match)", "P3", "3C",
                          ordre=["Correspond", "Ne correspond pas"],
                          note="Parmi les personnes formées (O3 = Oui) avec un domaine "
                               "classé (O3, O4_sector ∈ 1-14)."))
    t.append(croise(tr, tr["_tm"], tr["sexe"], "Adéquation formation ↔ aspiration par sexe",
                    "P3", "3D", ordre_ligne=["Correspond", "Ne correspond pas"],
                    ordre_col=["Homme", "Femme"], mode="colonne"))
    return t


def bloc_vulnerabilite(d):
    t = []
    signes = [("vuln_1", "Ne peut pas réunir 250 000 FCFA (N6 = non, impossible)"),
              ("vuln_2", "Dépend régulièrement d'une aide extérieure (M2 = oui, régulièrement)"),
              ("vuln_3", "Personne du ménage ne gagne (D4 = 0)"),
              ("vuln_4", "Au moins la moitié du ménage a moins de 15 ans (D2/D1 ≥ 0,5)"),
              ("vuln_5", "Deux biens ou moins (D5 ≤ 2)")]
    lignes = []
    for col, lib in signes:
        s = d[col].dropna()
        n = int(s.eq(1).sum())
        lignes.append([lib, str(len(s)), f"{n}", f"{100 * n / len(s):.1f}".replace(".", ",")])
    t.append({"cle": "4A", "bloc": "P4", "titre": "Signes de vulnérabilité du ménage",
              "note": "Cinq signes binaires ; chaque ligne a son propre dénominateur "
                      "(non-réponses exclues). Aucun score agrégé ici.",
              "entetes": ["Signe", "N", "Effectif positif", "% positif"],
              "lignes": lignes})
    vuln_str = d.vuln_score.map(lambda x: f"{int(x)}" if pd.notna(x) else None)
    t.append(distribution(d, vuln_str,
                          "Score de vulnérabilité (0-5) — exploratoire", "P4", "4B",
                          ordre=[str(i) for i in range(6)],
                          note="Somme des cinq signes ; manquant si un signe manque. "
                               "Recette d'Arthur, non validée comme seuil."))
    t.append(stats_table(d, d.vuln_score, "Score de vulnérabilité par sexe", "P4", "4C",
                         groupes=d.sexe, groupes_ordre=["Homme", "Femme"]))
    t.append(stats_table(d, d.vuln_score, "Score de vulnérabilité par filière", "P4", "4D",
                         groupes=d.track.map(LP.TRACK_COURT),
                         groupes_ordre=list(LP.TRACK_COURT.values())))
    return t


def bloc_metiers(d):
    t = []
    d["_trade"] = d.trade_code.map(LP.TRADE)
    t.append(distribution(d, d["_trade"], "Métier visé (P1 codé, 1-25)", "P5", "5A",
                          trier_par_effectif=True,
                          note="Codage par mots-clés d'après P1. 25 = non codable."))
    t.append(croise(d, d["_trade"], d["sexe"], "Métier visé par sexe", "P5", "5B",
                    mode="colonne", trier_par_effectif=True))
    t.append(croise(d, d["_trade"], d["_track"], "Métier visé par filière", "P5", "5C",
                    mode="colonne", trier_par_effectif=True))
    t.append(croise(d, d.maf_match.map({1: "Métier avec MAF", 0: "Sans MAF"}),
                    d["_track"], "Métier couvert par un MAF, par filière", "P5", "5D",
                    ordre_ligne=["Métier avec MAF", "Sans MAF"],
                    ordre_col=list(LP.TRACK_COURT.values()), mode="colonne",
                    note="Un métier est « MAF-matchable » s'il a un équivalent dans le "
                         "catalogue SONET-CI (codes 7-19 et 21)."))
    t.append(croise(d, d.sector_match.map({1: "Correspond", 0: "Ne correspond pas"}),
                    d["_trade"], "Adéquation emploi actuel ↔ métier visé (sector_match)",
                    "P5", "5E", ordre_ligne=["Correspond", "Ne correspond pas"],
                    mode="colonne",
                    note="F2 (secteur actuel) × trade_code. Version CORRIGÉE du mapping "
                         "d'Arthur (son do-file comporte un décalage +1)."))
    lignes = []
    for col, lib in [("pens_training", "Pas de formation alignée (O3 = non et non aligné)"),
                     ("pens_sector", "Emploi actuel hors du secteur visé"),
                     ("pens_skills", "Compétences auto-évaluées faibles (K7 ≤ 2)")]:
        s = d[col].dropna()
        n = int(s.eq(1).sum())
        lignes.append([lib, str(len(s)), str(n), f"{100 * n / len(s):.1f}".replace(".", ",")])
    t.append({"cle": "5F", "bloc": "P5", "titre": "Décomposition du gap technique (3 pénalités)",
              "note": "Chaque pénalité compte pour 1 point ; gap_score = somme (0-3). "
                      "K7 manquant compté comme faible (choix d'Arthur).",
              "entetes": ["Pénalité", "N", "Effectif positif", "% positif"],
              "lignes": lignes})
    gap_str = d.gap_score.map(lambda x: f"{int(x)}" if pd.notna(x) else None)
    t.append(distribution(d, gap_str,
                          "Score de gap technique (0-3) — exploratoire", "P5", "5G",
                          ordre=[str(i) for i in range(4)]))
    d["_gl"] = d.gap_level.map(LP.GAP_LEVEL)
    t.append(distribution(d, d["_gl"], "Niveau de gap technique (gap_level)", "P5", "5H",
                          ordre=list(LP.GAP_LEVEL.values()),
                          note="0 = non applicable (aspiration non technique) ; "
                               "filière B déjà en poste recodée « faible »."))
    t.append(croise(d, d["_gl"], d["_track"], "Niveau de gap par filière", "P5", "5I",
                    ordre_ligne=list(LP.GAP_LEVEL.values()),
                    ordre_col=list(LP.TRACK_COURT.values()), mode="colonne"))
    t.append(croise(d, d["_gl"], d["sexe"], "Niveau de gap par sexe", "P5", "5J",
                    ordre_ligne=list(LP.GAP_LEVEL.values()),
                    ordre_col=["Homme", "Femme"], mode="colonne"))
    t.append(distribution(d[d.vuln_score >= 3], d.loc[d.vuln_score >= 3, "_track"],
                          "Filière des personnes à vulnérabilité élevée (score ≥ 3)",
                          "P5", "5K", ordre=list(LP.TRACK_COURT.values()),
                          note="Recoupement vulnérabilité × filière."))
    return t


def bloc_maf(d, maf):
    """Écart offre/demande MAF (Analyse 10 d'Arthur)."""
    dem = d[d.maf_match == 1].copy()
    dem["region_norm"] = dem.region.map(lambda x: LP.normaliser(x))
    dcount = (dem.groupby(["trade_code", "region_norm"]).size()
              .rename("demande").reset_index())
    maf = maf.copy()
    maf["region_norm"] = maf.region.map(lambda x: LP.normaliser(x))
    grille = pd.MultiIndex.from_product(
        [sorted(maf.trade_code.unique()), sorted(maf.region_norm.unique())],
        names=["trade_code", "region_norm"]).to_frame(index=False)
    cell = grille.merge(maf[["trade_code", "region_norm", "supply"]],
                        on=["trade_code", "region_norm"], how="left") \
                .merge(dcount, on=["trade_code", "region_norm"], how="left")
    cell["demande"] = cell.demande.fillna(0).astype(int)

    def drapeau(demande, supply):
        if pd.isna(supply):
            return "ND"
        if supply == 0:
            return "Rouge" if demande > 0 else ""
        r = demande / supply
        return "Vert" if r <= 1 else ("Orange" if r <= 3 else "Rouge")

    cell["ratio"] = cell.apply(
        lambda x: (x.demande / x.supply) if x.supply and x.supply > 0 else np.nan, axis=1)
    cell["flag"] = [drapeau(x.demande, x.supply) for x in cell.itertuples()]
    cell["trade_lib"] = cell.trade_code.map(LP.TRADE)
    cell["region_lib"] = cell.region_norm.map(
        lambda n: {LP.normaliser(v): v for v in LP.REGIONS.values()}.get(n, n))

    national = cell.groupby(["trade_code", "trade_lib"], as_index=False) \
                   .agg(demande=("demande", "sum"), offre=("supply", "sum"))
    national["ratio"] = national.apply(
        lambda x: (x.demande / x.offre) if x.offre > 0 else np.nan, axis=1)
    national["flag"] = [drapeau(x.demande, x.offre) for x in national.itertuples()]
    national = national.sort_values("ratio", ascending=False)
    nat_lignes = [[r.trade_lib, str(int(r.demande)), str(int(r.offre)),
                   f"{r.ratio:.2f}".replace(".", ",") if pd.notna(r.ratio) else "—",
                   r.flag] for r in national.itertuples()]

    tab_nat = {"cle": "6A", "bloc": "P6",
               "titre": "Écart offre / demande MAF — niveau national",
               "note": "Demande = candidats aspirant au métier (notre population). "
                       "Offre = MAF recensés par SONET-CI (sept. 2026). La matrice "
                       "région × métier totalise 461 MAF (le catalogue en annonce "
                       "477 au total). Ratio = candidats par MAF. Feux : Vert ≤ 1 ; "
                       "Orange 1-3 ; Rouge > 3. DONNÉE EXTERNE — appariement approximatif.",
               "entetes": ["Métier", "Demande", "Offre (MAF)", "Ratio", "Feu"],
               "lignes": nat_lignes}

    def matrice(valeur, titre, cle, note):
        piv = cell.pivot_table(index="trade_lib", columns="region_lib",
                               values=valeur, aggfunc="first")
        regions = sorted([c for c in piv.columns])
        entetes = ["Métier"] + regions
        lignes = []
        for trade in piv.index:
            rang = [trade]
            for reg in regions:
                v = piv.loc[trade, reg]
                if pd.isna(v) or v == "":
                    rang.append("")
                elif valeur == "ratio":
                    rang.append(f"{v:.2f}".replace(".", ","))
                elif valeur == "flag":
                    rang.append(str(v))
                else:
                    rang.append(str(int(v)))
            lignes.append(rang)
        return {"cle": cle, "bloc": "P6", "titre": titre, "note": note,
                "entetes": entetes, "lignes": lignes}

    return [tab_nat,
            matrice("demande", "Demande par métier × région", "6B",
                    "Nombre de candidats aspirant au métier dans la région."),
            matrice("supply", "Offre MAF par métier × région", "6C",
                    "Source SONET-CI. Les cases vides = aucune donnée métier pour la région."),
            matrice("ratio", "Ratio candidats / MAF par métier × région", "6D",
                    "Ratio = demande / offre. Repère : 1 = un candidat par MAF."),
            matrice("flag", "Feux de saturation par métier × région", "6E",
                    "Vert ≤ 1 ; Orange 1-3 ; Rouge > 3 ou offre nulle avec demande.")], cell


def bloc_geographie(d):
    t = []
    t.append(croise(d, d.region, d.milieu, "Répartition région × milieu (n et %)",
                    "P7", "7A", mode="cellule"))
    d["_track"] = d.track.map(LP.TRACK_COURT)
    t.append(croise(d, d["cluster"], d["_track"],
                    "Mix de filières par cluster (région × milieu, % ligne)", "P7", "7B",
                    ordre_col=list(LP.TRACK_COURT.values()), mode="ligne",
                    note="Chaque ligne = 100 % des candidats du cluster."))
    geo = LP.tableau_geo(d)
    lignes = [[r.cluster, str(r.n), str(r.n_sous_prefectures),
               f"{r.applicants_par_sous_pref:.1f}".replace(".", ",")
               if r.applicants_par_sous_pref is not None else "—",
               "Oui" if r.sparse else ("Non" if r.sparse is not None else "—")]
              for r in geo.itertuples()]
    t.append({"cle": "7C", "bloc": "P7",
              "titre": "Densité et dispersion par cluster",
              "note": "per_sp = candidats par sous-préfecture (B4). "
                      "sparse = moins de 5 candidats par sous-préfecture "
                      "(livraison locale difficile).",
              "entetes": ["Cluster", "Candidats", "Sous-préfectures", "Candidats / sous-préf.",
                          "sparse"],
              "lignes": lignes})
    return t


def bloc_revenus(d):
    t = []
    d["_track"] = d.track.map(LP.TRACK_COURT)
    t.append(stats_table(d, d.revenu_mensuel,
                         "Revenu mensuel du travail (FCFA)", "P8", "8A",
                         groupes=d["_track"], groupes_ordre=list(LP.TRACK_COURT.values()),
                         unite="FCFA",
                         note="Salariés : H3 converti au mois par H2 ; indépendants : H5. "
                              "Variable construite par Arthur, absente de notre pipeline."))
    t.append(stats_table(d[d.F1 == 1], d.loc[d.F1 == 1, "salaire_mensuel"],
                         "Salaire mensuel (H3 × fréquence H2)", "P8", "8B", unite="FCFA"))
    t.append(stats_table(d[d.F1.isin([2, 3, 4])], d.loc[d.F1.isin([2, 3, 4]), "gain_net_H5"],
                         "Gain mensuel des indépendants (H5)", "P8", "8C", unite="FCFA"))
    t.append(stats_table(d, d.P3_clean, "Revenu mensuel souhaité (P3)", "P8", "8D",
                         groupes=d["_track"], groupes_ordre=list(LP.TRACK_COURT.values()),
                         unite="FCFA",
                         note="P3 borné à ]0 ; 5 000 000] FCFA."))
    t.append(stats_table(d, d.P3_clean, "Revenu mensuel souhaité par sexe", "P8", "8E",
                         groupes=d.sexe, groupes_ordre=["Homme", "Femme"], unite="FCFA"))
    sav = d[d.L3.isin([1, 2])]
    t.append(stats_table(sav, sav.L4, "Épargne mensuelle (L4, épargnants)", "P8", "8F",
                         groupes=sav["_track"],
                         groupes_ordre=list(LP.TRACK_COURT.values()), unite="FCFA"))
    t.append(stats_table(d, d.heures_total, "Heures travaillées la semaine dernière (tous emplois)",
                         "P8", "8G", groupes=d.sexe, groupes_ordre=["Homme", "Femme"],
                         unite="h", note="G3 + G6 (Arthur). Absent de notre pipeline."))
    t.append(stats_table(d, d.age_valide, "Âge", "P8", "8H", groupes=d.sexe,
                         groupes_ordre=["Homme", "Femme"], unite="ans"))
    t.append(stats_table(d, d.D1, "Taille du ménage (D1)", "P8", "8I", groupes=d.sexe,
                         groupes_ordre=["Homme", "Femme"], unite="personnes"))
    return t


def bloc_croisements(d):
    t = []
    d["_track"] = d.track.map(LP.TRACK_COURT)
    t.append(croise(d, d.M1.map({1: "Dépendante", 2: "Partielle", 3: "Autonome"}),
                    d.M4.map({1: "Dépendante", 2: "Partielle", 3: "Autonome"}),
                    "Autonomie actuelle (M1) × autonomie anticipée (M4)", "P9", "9A",
                    ordre_ligne=["Dépendante", "Partielle", "Autonome"],
                    ordre_col=["Dépendante", "Partielle", "Autonome"], mode="cellule",
                    note="Tableau croisé à deux dimensions."))
    t.append(croise(d, d.O3.map({1: "Formé", 2: "Non formé"}), d["_track"],
                    "Formation (O3) par filière", "P9", "9B",
                    ordre_ligne=["Formé", "Non formé"],
                    ordre_col=list(LP.TRACK_COURT.values()), mode="colonne"))
    k7_labels = {1: "Très faibles", 2: "Faibles", 3: "Moyennes", 4: "Bonnes",
                 5: "Très bonnes"}
    t.append(croise(d, d.K7.map(k7_labels), d["_track"],
                    "Auto-évaluation des compétences (K7) par filière",
                    "P9", "9C", ordre_ligne=list(k7_labels.values()),
                    ordre_col=list(LP.TRACK_COURT.values()), mode="colonne"))
    return t


def bloc_entonnoir(tentatives: Path | None):
    if tentatives is None or not Path(tentatives).exists():
        return None
    raw = pd.read_stata(tentatives, convert_categoricals=False)
    if "cover_id" not in raw or "A4" not in raw or "B6D" not in raw:
        return None
    sexe = np.where(raw.cover_id.astype(str).str[:2].eq("F-"), "Femme", "Homme")
    raw = raw.assign(_sexe=sexe)
    raw["_answered"] = raw.A4.eq(1).astype(int)
    raw["_consented"] = raw.B6D.eq(1).astype(int)
    raw["_complete"] = (raw.A4.eq(1) & raw.B6D.eq(1)
                        & raw.HHR_fin.notna()).astype(int) if "HHR_fin" in raw else 0
    g = raw.groupby("cover_id").agg(_sexe=("_sexe", "first"),
                                    answered=("_answered", "max"),
                                    consented=("_consented", "max"),
                                    complete=("_complete", "max")).reset_index()
    entetes = ["Étape", "Hommes", "Femmes", "Total", "% femmes"]
    lignes = []
    n_appeles = {"Homme": int((g._sexe == "Homme").sum()),
                 "Femme": int((g._sexe == "Femme").sum())}
    etapes = [("Tentatives (liste tablettes)", None),
              ("Entretien réalisé (A4 = 1)", "answered"),
              ("Consentement enregistré (B6D = 1)", "consented"),
              ("Entretien complété (A4 & B6D & fin)", "complete")]
    for lib, col in etapes:
        h = n_appeles["Homme"] if col is None else int(g.loc[g._sexe == "Homme", col].sum())
        f = n_appeles["Femme"] if col is None else int(g.loc[g._sexe == "Femme", col].sum())
        tot = h + f
        lignes.append([lib, str(h), str(f), str(tot),
                       f"{100 * f / tot:.1f}".replace(".", ",") if tot else "—"])
    return {"cle": "10A", "bloc": "P10",
            "titre": "Entonnoir de participation par sexe (sur toutes les tentatives)",
            "note": "Diagnostic calculé sur la base des tentatives (1032), hors population "
                    "d'analyse. Sexe déduit du préfixe de cover_id (F-/H-), "
                    "comme dans le do-file d'Arthur.",
            "entetes": entetes, "lignes": lignes}


def calculer(base: Path = BASE, maf_path: Path = MAF,
             tentatives: Path | None = TENTATIVES) -> dict:
    d = pd.read_csv(base)
    maf = LP.charger_maf(maf_path)

    tableaux = []
    tableaux += bloc_filieres(d)
    tableaux += bloc_saturation(d)
    tableaux += bloc_formation(d)
    tableaux += bloc_vulnerabilite(d)
    tableaux += bloc_metiers(d)
    maf_tables, maf_cell = bloc_maf(d, maf)
    tableaux += maf_tables
    tableaux += bloc_geographie(d)
    tableaux += bloc_revenus(d)
    tableaux += bloc_croisements(d)
    ent = bloc_entonnoir(tentatives)
    if ent:
        tableaux.append(ent)

    maf_cell = maf_cell.rename(columns={"region_lib": "region"})
    maf_cell["metier"] = maf_cell["trade_code"].map(LP.TRADE)
    colonnes = ["trade_code", "metier", "region", "demande", "supply", "ratio", "flag"]
    enregistrements = []
    for r in maf_cell[colonnes].to_dict(orient="records"):
        propre = {}
        for k, v in r.items():
            if isinstance(v, float) and np.isnan(v):
                propre[k] = None
            elif isinstance(v, (np.integer,)):
                propre[k] = int(v)
            elif isinstance(v, (np.floating,)):
                propre[k] = round(float(v), 4)
            else:
                propre[k] = v
        enregistrements.append(propre)
    payload = {
        "metadata": {
            "date_calcul": date.today().isoformat(),
            "base": base.name,
            "population": int(len(d)),
            "mode_sector_match": LP.MODE_SECTOR_MATCH,
            "source_maf": maf_path.name,
            "blocs": BLOCS,
            "avertissement": "Volet « analyse programme » exploratoire, séparé des "
                             "21 indicateurs officiels. Contient des scores composites "
                             "et une donnée externe (SONET-CI), non validés.",
        },
        "tableaux": tableaux,
        "maf": {
            "source": {"fichier": maf_path.name,
                       "reference": "Rapport de mission SONET-CI, septembre 2026 "
                                    "(table des MAF par métier et région). 14 métiers × "
                                    "10 régions = 140 cellules ; la matrice totalise 461 "
                                    "MAF, tandis que le catalogue SONET-CI en annonce 477 "
                                    "au total (l'écart de 16 n'est pas ventilable par "
                                    "région dans la source)."},
            "cellules": enregistrements,
        },
    }
    return payload


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", type=Path, default=BASE)
    parser.add_argument("--maf", type=Path, default=MAF)
    parser.add_argument("--tentatives", type=Path, default=TENTATIVES)
    parser.add_argument("--sortie", type=Path, default=SORTIE)
    args = parser.parse_args()
    resultat = calculer(args.base, args.maf, args.tentatives)
    args.sortie.parent.mkdir(parents=True, exist_ok=True)
    args.sortie.write_text(json.dumps(resultat, ensure_ascii=False, indent=1),
                           encoding="utf-8")
    print(json.dumps({"tableaux": len(resultat["tableaux"]),
                      "cellules_maf": len(resultat["maf"]["cellules"]),
                      "population": resultat["metadata"]["population"]},
                     ensure_ascii=False))
