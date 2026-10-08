"""05 — Vérifier la base apurée, les agrégations et les deux livrables."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from pathlib import Path

import pandas as pd
from openpyxl import load_workbook


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "résultats"
SOURCE = ROOT / "base" / "QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta"


def verifier(json_path: Path, out: Path = OUT) -> None:
    payload = json.loads(json_path.read_text(encoding="utf-8"))
    meta, results = payload["metadata"], payload["resultats"]
    d = pd.read_csv(out / "base_apuree.csv")
    raw = pd.read_stata(SOURCE, convert_categoricals=False)
    chosen = raw.classe_completude.isin(["1-COMPLET", "2-QUASI_COMPLET"])
    assert hashlib.sha256(SOURCE.read_bytes()).hexdigest() == meta["sha256_source"]
    assert len(raw) == meta["n_source"] and chosen.sum() == meta["n_apres_completude"]
    assert len(d) == meta["n_apures"] == int((chosen & raw.consentement.eq(1)).sum())
    assert d.interview__key.is_unique
    assert not {"nom", "telephone", "B7", "R1A", "R2A", "R3B", "R4", "R6"} & set(d.columns)
    assert d.classe_completude.isin(["1-COMPLET", "2-QUASI_COMPLET"]).all()
    assert d.consentement.eq(1).all()
    assert d.n_anomalies.sum() == meta["n_signalements"]
    assert d.n_anomalies.gt(0).sum() == meta["n_entretiens_signales"]
    assert meta["signalements_par_type"].get("Q2_NON_QUANTIFIABLE", 0) == int(
        d.anomalies.fillna("").str.contains("Q2_NON_QUANTIFIABLE").sum())
    assert (d.loc[d.G3.eq(998), "heures_principales"].isna()).all()
    assert (d.loc[d.H3.eq(99999), "montant_H3"].isna()).all()
    assert (d.loc[d.H5.eq(999999), "gain_net_H5"].isna()).all()
    assert (d.loc[d.H5.eq(0), "gain_net_H5"].isna()).all()
    assert (d.loc[d.F1.ne(1), "montant_H3"].isna()).all()
    assert (d.loc[~d.F1.isin([2, 3, 4]), "gain_net_H5"].isna()).all()
    assert (d.loc[d.N1.eq(2), "retablissement_N5"].isna()).all()
    assert meta["n_h3_exacts"] == int(d.montant_H3.notna().sum())
    assert meta["n_h5_exacts"] == int(d.gain_net_H5.notna().sum())
    assert meta["n_age_invalides"] == int(d.age_valide.isna().sum())

    assert len(payload["couverture"]) == 21
    assert len({x["code"] for x in payload["couverture"]}) == 21
    assert not any(x["code"] in {"1.1", "1.2", "1.3", "1.4", "1.5", "1.6",
                                 "1.7", "2.1", "2.2", "2.3", "4.1"} for x in results)
    for level in ("District", "Région", "Sexe", "Âge", "Milieu"):
        groups = [r for r in results if r["niveau"] == level and r["code"] == "profil"]
        assert sum(r["effectif"] for r in groups) == len(d), level
    for code, measure, modality in [
        ("3.1", "Statut d'activité observé", "En emploi"),
        ("3.6", "Formation ou apprentissage durant les 12 derniers mois", ""),
        ("3.8", "Ménage ayant subi un choc", ""),
    ]:
        overall = next(r for r in results if r["niveau"] == "Ensemble" and r["code"] == code
                       and r["mesure"] == measure and r["modalite"] == modality)
        for level in ("District", "Région", "Sexe", "Âge", "Milieu"):
            parts = [r for r in results if r["niveau"] == level and r["code"] == code
                     and r["mesure"] == measure and r["modalite"] == modality]
            assert sum(r["effectif"] for r in parts) == overall["effectif"], (code, level)
            assert sum(r["denominateur"] for r in parts) == overall["denominateur"], (code, level)
    def overall(code: str, measure: str) -> dict:
        return next(r for r in results if r["niveau"] == "Ensemble"
                    and r["code"] == code and r["mesure"] == measure)
    assert overall("3.4", "Salaire net dernière paie : médiane")["valeur"] == d.montant_H3.median()
    assert overall("3.4", "Gain net du dernier mois : médiane")["valeur"] == d.gain_net_H5.median()

    wb = load_workbook(out / "indicateurs_COSO.xlsx", read_only=False, data_only=True)
    assert wb.sheetnames == ["Synthèse", "Territoires", "Résultats", "Méthode"]
    assert wb["Résultats"].max_row == len(results) + 4
    assert wb["Territoires"].max_row >= 18  # 4 districts + 10 régions, plus entête
    assert len(wb["Résultats"].tables) == 1  # filtres actifs
    summary = wb["Synthèse"]
    assert summary["C5"].value == len(d)
    row = next(r for r in summary.iter_rows(min_row=5, values_only=True) if r[1] == "Statut d'activité observé — En emploi")
    employed = d.E1.eq(1) | d.E2.eq(1) | (d.E3.eq(1) & d.E3A.eq(1))
    assert row[4] == int(employed.sum()) and row[5] == len(d)
    assert all(r[2] is not None for r in summary.iter_rows(min_row=5, values_only=True) if r[0] is not None)

    pdf = out / "synthese_COSO.pdf"
    assert pdf.is_file() and pdf.stat().st_size > 10_000
    pdfinfo = subprocess.run(["pdfinfo", str(pdf)], check=True, capture_output=True, text=True).stdout
    assert "Pages:           2" in pdfinfo
    text = subprocess.run(["pdftotext", str(pdf), "-"], check=True,
                          capture_output=True, text=True).stdout
    assert str(meta["n_apures"]) in text and str(meta["n_signalements"]) in text
    for name in ["Denguélé", "Savanes", "Woroba", "Zanzan", "Bafing", "Gontougo"]:
        assert name in text
    expected_files = {"base_apuree.csv", "indicateurs_COSO.xlsx", "synthese_COSO.pdf"}
    assert {p.name for p in out.iterdir() if p.is_file() and not p.name.startswith("~$")} == expected_files
    print("VERIFICATION_COSO_OK")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--resultats", type=Path, required=True)
    parser.add_argument("--dossier", type=Path, default=OUT)
    args = parser.parse_args()
    verifier(args.resultats, args.dossier)
