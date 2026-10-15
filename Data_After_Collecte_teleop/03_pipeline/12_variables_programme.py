"""12 — Construire la base « analyse programme » (variante Arthur).

Entrée :
  - 04_resultats/traitement/base_apuree.csv            (notre population, 664)
  - 02_bases/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta       (pour B4 et P44X)
Sorties :
  - 04_resultats/analyse_programme/base_programme.csv
  - 04_resultats/analyse_programme/meta_programme.json

On conserve STRICTEMENT notre population (classe_completude ∈ COMPLET/QUASI,
cf. étape 07). Seules des variables dérivées de type « programme » sont ajoutées
(filières, secteurs recodés, métiers, vulnérabilité, gap technique, revenus
mensualisés, clusters géographiques).
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import pandas as pd

import lib_programme as LP

ICI = Path(__file__).resolve().parent
RACINE = ICI.parent
BASE_APUREE = RACINE / "04_resultats" / "traitement" / "base_apuree.csv"
SOURCE_DTA = RACINE / "02_bases" / "QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta"
DOSSIER = RACINE / "04_resultats" / "analyse_programme"
SORTIE = DOSSIER / "base_programme.csv"
META = DOSSIER / "meta_programme.json"


def construire(base: Path = BASE_APUREE, source: Path = SOURCE_DTA,
               sortie: Path = SORTIE, meta_path: Path = META,
               mode_sector_match: str = LP.MODE_SECTOR_MATCH) -> dict:
    d = pd.read_csv(base, dtype={"interview__key": str})

    # Colonnes non exportées par 07 mais nécessaires (B4 = sous-préfecture,
    # P44X = « autre » du secteur aspiré ; nommé P4X chez Arthur).
    extra = pd.read_stata(source, convert_categoricals=False,
                          columns=["interview__key", "B4", "P44X"])
    extra["interview__key"] = extra["interview__key"].astype(str)
    d = d.merge(extra, on="interview__key", how="left", validate="1:1")

    d = LP.deriver(d, mode_sector_match=mode_sector_match)

    # Régénère le CSV de référence MAF s'il est absent (les CSV sont ignorés
    # par git : la matrice embarquée dans lib_programme garantit la reproductibilité).
    ref_maf = RACINE / "01_sources" / "maf_sonet_ci.csv"
    if not ref_maf.exists():
        ref_maf.parent.mkdir(parents=True, exist_ok=True)
        LP.donnees_maf().to_csv(ref_maf, index=False)

    sortie.parent.mkdir(parents=True, exist_ok=True)
    d.to_csv(sortie, index=False)

    geo = LP.tableau_geo(d)
    meta = {
        "source_base": base.name,
        "source_dta": source.name,
        "n_population": int(len(d)),
        "mode_sector_match": mode_sector_match,
        "repartition_track": {LP.TRACK[int(k)]: int(v) for k, v in
                              d.track.value_counts().sort_index().items()},
        "n_maf_matchables": int(d.maf_match.eq(1).sum()),
        "repartition_maf_match": {str(k): int(v) for k, v in
                                  d.maf_match.value_counts().sort_index().items()},
        "n_vuln_calculable": int(d.vuln_score.notna().sum()),
        "vuln_score_moyen": round(float(d.vuln_score.mean()), 3),
        "n_sans_sous_prefecture": int(d.B4.isna().sum()),
        "n_secteur_non_code": int((d.O4_sector == 97).sum()),
        "n_metier_non_codable": int(d.trade_code.eq(25).sum()),
        "n_gap_calculable": int(d.gap_level.notna().sum()),
        "clusters": geo.to_dict(orient="records"),
    }
    meta_path.parent.mkdir(parents=True, exist_ok=True)
    meta_path.write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")
    return meta


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", type=Path, default=BASE_APUREE)
    parser.add_argument("--source", type=Path, default=SOURCE_DTA)
    parser.add_argument("--sortie", type=Path, default=SORTIE)
    parser.add_argument("--meta", type=Path, default=META)
    parser.add_argument("--sector-match", choices=["corrige", "litteral"],
                        default=LP.MODE_SECTOR_MATCH)
    args = parser.parse_args()
    info = construire(args.base, args.source, args.sortie, args.meta,
                      args.sector_match)
    print(json.dumps(info, ensure_ascii=False, indent=2))
