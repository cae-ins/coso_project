"""07 — Filtrer, contrôler et apurer la base dédoublonnée pour les indicateurs.

Entrée : 02_bases/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta (962 entretiens)
Sorties : 04_resultats/traitement/base_apuree.csv + meta_apurement.json

Règle de population : classe_completude ∈ {1-COMPLET, 2-QUASI_COMPLET} ET consentement = 1.
La source n'est jamais modifiée. Aucune donnée nominative (nom, téléphone) n'est exportée.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pandas as pd

ICI = Path(__file__).resolve().parent
RACINE = ICI.parent
DOSSIER_BASE = RACINE / "02_bases"
DOSSIER_TRAIT = RACINE / "04_resultats" / "traitement"
SOURCE_DEFAUT = DOSSIER_BASE / "QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta"
SORTIE_DEFAUT = DOSSIER_TRAIT / "base_apuree.csv"
META_DEFAUT = DOSSIER_TRAIT / "meta_apurement.json"

DISTRICTS = {105: "Denguélé", 111: "Savanes", 113: "Woroba", 114: "Zanzan"}
REGIONS = {10510: "Kabadougou", 10524: "Folon", 11103: "Poro", 11120: "Bagoué",
           11132: "Tchologo", 11314: "Worodougou", 11319: "Bafing", 11322: "Béré",
           11408: "Gontougo", 11423: "Bounkani"}

TRANCHES = {1: "Moins de 30 000", 2: "[30 000 – 75 000[", 3: "[75 000 – 150 000[",
            4: "[150 000 – 300 000[", 5: "[300 000 – 500 000[",
            6: "[500 000 – 800 000[", 7: "[800 000 – 1 000 000[",
            8: "Plus d'un million"}

COLONNES_BASE = [
    "interview__key", "classe_completude", "taux_completude", "consentement",
    "A1", "A4", "age", "C2A_annee",
    "B1", "B2", "B5", "C1", "C3", "C4", "C5", "C6", "C7", "C8",
    "D1", "D2", "D3", "D4",
    "E1", "E2", "E3", "E3A", "EMPLOYE",
    "F1", "F2", "F3", "F4", "G1", "G2", "G3", "G4", "G5", "G6", "G7", "G7A",
    "H1", "H2", "H3", "H3A", "H4", "H4A", "H5", "H5A",
    "I1", "I2", "I3", "J0", "J0A", "J0B", "J1", "J2", "J3",
    "K1", "K2", "K3", "K4", "K6", "K7",
    "L1", "L2", "L3", "L4", "L5", "L6", "L7", "L8", "L9",
    "M1", "M2", "M3", "M4",
    "N1", "N2", "N3", "N4", "N5", "N6", "N7",
    "O1", "O2", "O3", "O5", "O6",
    "P2", "P3", "P4",
    "Q1", "Q2", "Q3", "Q4", "Q5", "Q6", "Q7", "Q8", "Q9", "Q10",
]
COLONNES_MULTICHOIX = ([f"D5__{i}" for i in range(1, 12)] +
                       [f"K5__{i}" for i in [1, 2, 3, 4, 5, 6, 7, 9]])
COLONNES_TEXTE = ["G5A", "O4", "P1", "P5"]
HEURE_COLS = None  # rempli au chargement (toutes les colonnes HH*_debut / HH*_fin)


def _colonnes_heures(raw: pd.DataFrame) -> list[str]:
    return [c for c in raw.columns if c.startswith("HH") and
            (c.endswith("_debut") or c.endswith("_fin"))]


def tranche_de_montant(montant: float | None, code_tranche: float | None) -> str | None:
    """Tranche commune aux montants exacts et aux bandes H3A/H5A."""
    if montant is not None and pd.notna(montant):
        bornes = [(30_000, 1), (75_000, 2), (150_000, 3), (300_000, 4),
                  (500_000, 5), (800_000, 6), (1_000_000, 7)]
        for borne, code in bornes:
            if montant < borne:
                return TRANCHES[code]
        return TRANCHES[8]
    if code_tranche is not None and pd.notna(code_tranche) and int(code_tranche) in TRANCHES:
        return TRANCHES[int(code_tranche)]
    return None


def apurer(source: Path = SOURCE_DEFAUT, sortie: Path = SORTIE_DEFAUT,
           meta_path: Path = META_DEFAUT) -> dict:
    raw = pd.read_stata(source, convert_categoricals=False)
    if "classe_completude" not in raw or "consentement" not in raw:
        raise ValueError("Colonnes de complétude ou de consentement absentes.")
    completes = raw.classe_completude.isin(["1-COMPLET", "2-QUASI_COMPLET"])
    selection = raw.loc[completes]
    gardes = selection.loc[selection.consentement.eq(1)].copy()
    if gardes.interview__key.isna().any() or gardes.interview__key.duplicated().any():
        raise ValueError("Identifiant d'entretien absent ou dupliqué : résoudre avant calcul.")

    colonnes = COLONNES_BASE + COLONNES_MULTICHOIX + COLONNES_TEXTE
    colonnes = [c for c in colonnes if c in raw.columns]
    d = gardes[colonnes].copy()

    d["district"] = d.B1.map(DISTRICTS)
    d["region"] = d.B2.map(REGIONS)
    d["sexe"] = d.C1.map({1: "Homme", 2: "Femme"})
    d["milieu"] = d.B5.map({1: "Urbain", 2: "Rural"})
    d["age_valide"] = d.age.where(d.age.between(15, 120))
    d["age_groupe"] = pd.cut(d.age_valide, bins=[14, 24, 34, 120],
                             labels=["15–24 ans", "25–34 ans",
                                     "35 ans ou plus"]).astype(object).fillna("Âge invalide")

    emploi = d.E1.eq(1) | d.E2.eq(1) | (d.E3.eq(1) & d.E3A.eq(1))
    d["emploi_calcule"] = np.where(d.E1.isin([1, 2]), emploi.astype(int), np.nan)
    d["heures_principales"] = d.G3.where(d.G3.between(0, 168))
    d["heures_secondaires"] = d.G6.where(d.G6.between(0, 168) & d.G5.eq(1))

    d["montant_H3"] = d.H3.where(d.F1.eq(1) & d.H3.ge(0) & d.H3.ne(99999))
    d["gain_net_H5"] = d.H5.where(d.F1.isin([2, 3, 4]) & d.emploi_calcule.eq(1)
                                  & d.H5.gt(0) & d.H5.ne(999999))
    d["tranche_salaire"] = [tranche_de_montant(m, t) for m, t in zip(
        d.montant_H3, d.H3A.where(d.montant_H3.isna() & d.F1.eq(1)))]
    d["tranche_gain"] = [tranche_de_montant(m, t) for m, t in zip(
        d.gain_net_H5, d.H5A.where(d.gain_net_H5.isna() & d.F1.isin([2, 3, 4])
                                   & d.emploi_calcule.eq(1)))]
    d["impact_choc_N3"] = d.N3.where(d.N1.eq(1))
    d["retablissement_N5"] = d.N5.where(d.N1.eq(1))
    d["dispensateur_O5"] = d.O5.where(d.O3.eq(1))
    d["nb_biens"] = d[[f"D5__{i}" for i in range(1, 11)]].eq(1).sum(axis=1).where(
        d[[f"D5__{i}" for i in range(1, 11)]].notna().any(axis=1))

    q2 = d.Q2.fillna("").astype(str).str.strip().str.upper()
    q2_num = pd.to_numeric(q2, errors="coerce")
    q2_num = q2_num.where(~q2.isin(["NON", "AUCUN", "AUNCUN"]), 0)
    q2_num = q2_num.where(q2.ne("UNE FOIS"), 1)
    q2_num = q2_num.where(q2.ne("2 FOIS"), 2)
    d["participations_Q2"] = q2_num.where(q2_num.between(0, 365))

    debut = gardes[_colonnes_heures(gardes)].filter(like="_debut").apply(
        pd.to_datetime, errors="coerce").min(axis=1)
    fin = gardes[_colonnes_heures(gardes)].filter(like="_fin").apply(
        pd.to_datetime, errors="coerce").max(axis=1)
    duree = (fin - debut).dt.total_seconds() / 60
    d["duree_entretien_min"] = duree.round(1)
    d["duree_valide"] = duree.between(1, 600)

    flags: dict[str, pd.Series] = {
        "AGE_IMPLAUSIBLE": ~d.age.between(15, 120),
        "GEOGRAPHIE_INVALIDE": d.district.isna() | d.region.isna() |
            d.B2.fillna(-1).astype(int).astype(str).str[:3].ne(
                d.B1.fillna(-1).astype(int).astype(str)),
        "EMPLOI_CONTRADICTOIRE": d.EMPLOYE.notna() & d.EMPLOYE.ne(d.emploi_calcule),
        "F1_HORS_PARCOURS": d.emploi_calcule.eq(0) & d.F1.notna(),
        "F2_HORS_PARCOURS": d.emploi_calcule.eq(0) & d.F2.notna(),
        "H2_HORS_PARCOURS": d.H2.notna() & d.F1.ne(1),
        "H5_HORS_PARCOURS": d.H5.notna() & (~d.F1.isin([2, 3, 4]) | d.emploi_calcule.ne(1)),
        "H5_NON_POSITIF": d.H5.eq(0),
        "J0_HORS_PARCOURS": d.emploi_calcule.eq(1) & d.J0.notna(),
        "G6_HORS_PARCOURS": d.G5.eq(2) & d.G6.notna(),
        "G7A_HORS_PARCOURS": d.G7.eq(2) & d.G7A.notna(),
        "CHOC_HORS_PARCOURS": d.N1.eq(2) & d[["N3", "N4", "N5"]].notna().any(axis=1),
        "FORMATION_HORS_PARCOURS": d.O3.eq(2) & d[["O5", "O6"]].notna().any(axis=1),
        "HEURES_HORS_PLAGE": (d.G3.notna() & d.G3.ne(998) & ~d.G3.between(0, 168)) |
            (d.G6.notna() & ~d.G6.between(0, 168)),
        "Q2_NON_QUANTIFIABLE": q2.ne("") & d.participations_Q2.isna(),
    }
    d["anomalies"] = [";".join(nom for nom, masque in flags.items() if bool(masque.loc[idx]))
                      for idx in d.index]
    d["n_anomalies"] = d.anomalies.str.count(";") + d.anomalies.ne("").astype(int)

    sortie.parent.mkdir(parents=True, exist_ok=True)
    meta_path.parent.mkdir(parents=True, exist_ok=True)
    d.to_csv(sortie, index=False)

    metadata = {
        "source": source.name,
        "sha256_source": hashlib.sha256(source.read_bytes()).hexdigest(),
        "n_source": int(len(raw)),
        "repartition_classes": {k: int(v) for k, v in raw.classe_completude.value_counts().items()},
        "n_apres_completude": int(len(selection)),
        "n_exclus_sans_consentement": int(selection.consentement.ne(1).sum()),
        "n_apures": int(len(d)),
        "n_entretiens_signales": int(d.n_anomalies.gt(0).sum()),
        "n_signalements": int(d.n_anomalies.sum()),
        "signalements_par_type": {nom: int(masque.sum()) for nom, masque in flags.items()
                                  if int(masque.sum())},
        "n_age_invalides": int(d.age_valide.isna().sum()),
        "duree_entretien": {
            "n_mesurees": int(d.duree_entretien_min.notna().sum()),
            "n_dans_la_plage_1_600": int(d.duree_valide.sum()),
            "mediane_minutes": round(float(d.loc[d.duree_valide, "duree_entretien_min"].median()), 1),
            "n_hors_plage": int((d.duree_entretien_min.notna() & ~d.duree_valide).sum()),
        },
        "n_h3_salaries": int(d.F1.eq(1).sum()),
        "n_h3_exacts": int(d.montant_H3.notna().sum()),
        "n_h3_tranches": int(d.tranche_salaire.notna().sum()),
        "n_h5_eligibles": int((d.F1.isin([2, 3, 4]) & d.emploi_calcule.eq(1)).sum()),
        "n_h5_exacts": int(d.gain_net_H5.notna().sum()),
        "n_h5_tranches": int(d.tranche_gain.notna().sum()),
        "n_emploi": int(d.emploi_calcule.eq(1).sum()),
        "n_sans_emploi": int(d.emploi_calcule.eq(0).sum()),
        "mediane_taux_completude": round(float(d.taux_completude.median()), 3),
    }
    meta_path.write_text(json.dumps(metadata, ensure_ascii=False, indent=2), encoding="utf-8")
    return metadata


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=SOURCE_DEFAUT)
    parser.add_argument("--sortie", type=Path, default=SORTIE_DEFAUT)
    parser.add_argument("--meta", type=Path, default=META_DEFAUT)
    args = parser.parse_args()
    info = apurer(args.source, args.sortie, args.meta)
    print(json.dumps(info, ensure_ascii=False, indent=2))
