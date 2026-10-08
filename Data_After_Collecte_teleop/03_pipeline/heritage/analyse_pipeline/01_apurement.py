"""01 — Filtrer, contrôler et apurer le DTA sans modifier la source."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "base" / "QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta"
OUTPUT = ROOT / "résultats" / "base_apuree.csv"
DISTRICTS = {105: "Denguélé", 111: "Savanes", 113: "Woroba", 114: "Zanzan"}
REGIONS = {10510: "Kabadougou", 10524: "Folon", 11103: "Poro", 11120: "Bagoué",
           11132: "Tchologo", 11314: "Worodougou", 11319: "Bafing", 11322: "Béré",
           11408: "Gontougo", 11423: "Bounkani"}

# Colonnes nécessaires aux indicateurs et à la vérification. Aucune donnée nominative.
COLUMNS = ["interview__key", "classe_completude", "consentement", "B1", "B2", "B5",
           "C1", "age", "E1", "E2", "E3", "E3A", "EMPLOYE", "F1", "F2",
           "G3", "G5", "G6", "G7", "G7A", "H2", "H3", "H3A", "H5", "H5A",
           "I1", "I2", "I3", "J0", "J0A", "J0B", "J1", "J2", "J3", "K1",
           "M1", "M2", "M3", "M4", "N1", "N3", "N4", "N5", "N6", "N7",
           "O3", "O5", "O6", "Q1", "Q2", "Q3", "Q4", "Q5", "Q6", "Q7",
           "Q8", "Q9", "Q10"]


def apurer(source: Path = SOURCE, output: Path = OUTPUT) -> dict:
    raw = pd.read_stata(source, convert_categoricals=False)
    complete = raw.classe_completude.isin(["1-COMPLET", "2-QUASI_COMPLET"])
    selected = raw.loc[complete]
    kept = selected.loc[selected.consentement.eq(1)].copy()
    if kept.interview__key.isna().any() or kept.interview__key.duplicated().any():
        raise ValueError("Identifiant d'entretien absent ou dupliqué : résoudre avant de calculer.")
    d = kept[COLUMNS].copy()
    d["district"] = d.B1.map(DISTRICTS)
    d["region"] = d.B2.map(REGIONS)
    d["sexe"] = d.C1.map({1: "Homme", 2: "Femme"})
    d["milieu"] = d.B5.map({1: "Urbain", 2: "Rural"})
    # Moins de 15 ans est invraisemblable pour un candidat interrogé. Aucune
    # borne supérieure propre au projet n'est appliquée sans règle officielle.
    d["age_valide"] = d.age.where(d.age.between(15, 120))
    d["age_groupe"] = pd.cut(d.age_valide, bins=[14, 24, 34, 120],
                            labels=["15–24 ans", "25–34 ans", "35 ans ou plus"]).astype(object).fillna("Âge invalide")
    emploi = d.E1.eq(1) | d.E2.eq(1) | (d.E3.eq(1) & d.E3A.eq(1))
    d["emploi_calcule"] = np.where(d.E1.isin([1, 2]), emploi.astype(int), np.nan)
    d["heures_principales"] = d.G3.where(d.G3.between(0, 168))
    d["heures_secondaires"] = d.G6.where(d.G6.between(0, 168) & d.G5.eq(1))
    # H3 est un salaire de dernière paie : la mesure publiée se limite aux salariés.
    # H5 est réservé aux employeurs/indépendants/coopératives et doit être > 0.
    d["montant_H3"] = d.H3.where(d.F1.eq(1) & d.H3.ge(0) & d.H3.ne(99999))
    d["gain_net_H5"] = d.H5.where(d.F1.isin([2, 3, 4]) & d.emploi_calcule.eq(1)
                                    & d.H5.gt(0) & d.H5.ne(999999))
    d["impact_choc_N3"] = d.N3.where(d.N1.eq(1))
    d["retablissement_N5"] = d.N5.where(d.N1.eq(1))
    d["dispensateur_O5"] = d.O5.where(d.O3.eq(1))
    q2 = d.Q2.fillna("").astype(str).str.strip().str.upper()
    q2_num = pd.to_numeric(q2, errors="coerce")
    q2_num = q2_num.where(~q2.isin(["NON", "AUCUN", "AUNCUN"]), 0)
    q2_num = q2_num.where(q2.ne("UNE FOIS"), 1)
    q2_num = q2_num.where(q2.ne("2 FOIS"), 2)
    d["participations_Q2"] = q2_num.where(q2_num.between(0, 365))

    flags: dict[str, pd.Series] = {
        "AGE_IMPLAUSIBLE": ~d.age.between(15, 120),
        "GEOGRAPHIE_INVALIDE": d.district.isna() | d.region.isna() |
            d.B2.fillna(-1).astype(int).astype(str).str[:3].ne(d.B1.fillna(-1).astype(int).astype(str)),
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
    d["anomalies"] = [";".join(name for name, mask in flags.items() if bool(mask.loc[idx]))
                      for idx in d.index]
    d["n_anomalies"] = d.anomalies.str.count(";") + d.anomalies.ne("").astype(int)
    interview_year = pd.to_datetime(kept.A2_date, errors="coerce").dt.year
    birth_year = pd.to_numeric(kept.C2A_annee, errors="coerce")
    age_comparable = d.age_valide.notna() & birth_year.ge(1900) & birth_year.le(interview_year)
    output.parent.mkdir(parents=True, exist_ok=True)
    d.to_csv(output, index=False)
    metadata = {
        "source": source.name,
        "sha256_source": hashlib.sha256(source.read_bytes()).hexdigest(),
        "n_source": int(len(raw)),
        "n_complet": int(raw.classe_completude.eq("1-COMPLET").sum()),
        "n_quasi": int(raw.classe_completude.eq("2-QUASI_COMPLET").sum()),
        "n_apres_completude": int(len(selected)),
        "n_exclus_sans_consentement": int(selected.consentement.ne(1).sum()),
        "n_apures": int(len(d)),
        "n_entretiens_signales": int(d.n_anomalies.gt(0).sum()),
        "n_signalements": int(d.n_anomalies.sum()),
        "signalements_par_type": {name: int(mask.sum()) for name, mask in flags.items() if int(mask.sum())},
        "n_age_invalides": int(d.age_valide.isna().sum()),
        "n_age_annee_comparables": int(age_comparable.sum()),
        "n_age_annee_ecarts": int((age_comparable & (d.age - (interview_year - birth_year)).abs().gt(1)).sum()),
        "n_h3_salaries": int(d.F1.eq(1).sum()),
        "n_h3_exacts": int(d.montant_H3.notna().sum()),
        "n_h5_eligibles": int((d.F1.isin([2, 3, 4]) & d.emploi_calcule.eq(1)).sum()),
        "n_h5_exacts": int(d.gain_net_H5.notna().sum()),
        "n_h5_refus": int((d.F1.isin([2, 3, 4]) & d.H5.eq(999999)).sum()),
    }
    return metadata


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--sortie", type=Path, default=OUTPUT)
    parser.add_argument("--meta", type=Path)
    args = parser.parse_args()
    info = apurer(args.source, args.sortie)
    if args.meta:
        args.meta.write_text(json.dumps(info, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(info, ensure_ascii=False))
