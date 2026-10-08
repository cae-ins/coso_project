"""02 — Calculer les indicateurs à partir de la seule base apurée."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "résultats" / "base_apuree.csv"

COUVERTURE = [
    ("1.1", "Jeunes enrôlés", "indisponible", "Registre d'enrôlement requis"),
    ("1.2", "Sélectionnés ayant démarré une formation", "indisponible", "Registres de sélection et de formation requis"),
    ("1.3", "Femmes parmi les sélectionnés", "indisponible", "Statut de sélection requis"),
    ("1.4", "Bénéficiaires de zones enclavées", "indisponible", "Statut de sélection et référentiel des zones enclavées requis"),
    ("1.5", "Formation achevée", "indisponible", "Registre d'achèvement requis"),
    ("1.6", "Taux d'achèvement", "indisponible", "Début et achèvement par cohorte requis"),
    ("1.7", "Kits d'installation remis", "indisponible", "Registre des remises requis"),
    ("2.1", "MAF mobilisés", "indisponible", "Registre des MAF et séances requis"),
    ("2.2", "Inscrits à la chambre des métiers", "indisponible", "Preuve d'inscription requise"),
    ("2.3", "Intégrés à un AVEC", "indisponible", "Registre d'adhésion requis"),
    ("3.1", "Statut d'activité", "partiel", "Emploi et recherche observés ; disponibilité des chercheurs non mesurée"),
    ("3.2", "Type d'activité et secteur", "calculé", "Distribution parmi les personnes en emploi"),
    ("3.3", "Durée du travail", "calculé", "Heures de l'activité principale ; codes spéciaux exclus"),
    ("3.4", "Revenus ou chiffre d'affaires", "partiel", "H3 limité aux salariés, H5 aux indépendants/employeurs/coopératives ; aucun chiffre d'affaires"),
    ("3.5", "Recherche d'emploi et contraintes", "calculé", "Populations en emploi et sans emploi séparées"),
    ("3.6", "Formation ou AGR", "partiel", "Formation et activité générales, sans lien COSO établi"),
    ("3.7", "Chômage et sous-emploi", "partiel", "Composantes disponibles ; taux normatifs non publiés"),
    ("3.8", "Résilience économique", "partiel", "Dimensions observées ; aucun indice composite validé"),
    ("3.9", "Statut socio-économique perçu", "calculé", "Modalités M1, M3 et M4, sans score composite"),
    ("4.1", "Exclusion sociale et perte d'espoir", "indisponible", "Questions insuffisantes"),
    ("4.2", "Cohésion sociale perçue", "partiel", "Appartenance, participation et confiance ; pas d'indice global"),
]

F1 = {1: "Salarié", 2: "Employeur", 3: "Indépendant", 4: "Coopérative",
      5: "Aide familial", 7: "Apprenti ou stagiaire", 9: "Autre"}
F2 = {1: "Agriculture", 2: "Industries extractives", 3: "Industrie manufacturière",
      4: "Construction", 5: "Commerce", 6: "Transport", 7: "Hébergement et restauration",
      8: "Information et communication", 9: "Finance et assurance", 10: "Administration publique",
      11: "Éducation", 12: "Santé et action sociale", 13: "Travail domestique",
      14: "Autres services", 99: "Autre secteur précisé"}
I2 = {1: "Revenu insuffisant", 2: "Emploi instable", 3: "Compétences mieux utilisées",
      4: "Meilleur emploi", 5: "Autre"}
J0A = {1: "Découragement", 2: "Pas d'emploi adapté", 3: "Études ou formation",
       4: "Santé ou handicap", 5: "Obligations familiales", 6: "Attente de la saison agricole",
       7: "Attente de démarches", 8: "Activité prochaine", 9: "Autre"}
N5 = {1: "Moins d'un mois", 2: "1 à 3 mois", 3: "3 à 6 mois",
      4: "Plus de 6 mois", 5: "Pas encore rétabli"}


def groupes(d: pd.DataFrame):
    all_values = dict(district="Tous", region="Toutes", sexe="Tous", age_groupe="Tous", milieu="Tous")
    yield "Ensemble", all_values, d
    for district, sub in d.groupby("district", dropna=False, sort=True):
        yield "District", {**all_values, "district": district}, sub
    for (district, region), sub in d.groupby(["district", "region"], dropna=False, sort=True):
        yield "Région", {**all_values, "district": district, "region": region}, sub
    for sexe, sub in d.groupby("sexe", dropna=False, sort=True):
        yield "Sexe", {**all_values, "sexe": sexe}, sub
    for age, sub in d.groupby("age_groupe", dropna=False, sort=True):
        yield "Âge", {**all_values, "age_groupe": age}, sub
    for milieu, sub in d.groupby("milieu", dropna=False, sort=True):
        yield "Milieu", {**all_values, "milieu": milieu}, sub
    for (district, region, sexe), sub in d.groupby(["district", "region", "sexe"], dropna=False, sort=True):
        yield "Région × sexe", {**all_values, "district": district, "region": region, "sexe": sexe}, sub


def calculer(base: Path = BASE, meta: dict | None = None) -> dict:
    d = pd.read_csv(base)
    if d.interview__key.isna().any() or d.interview__key.duplicated().any():
        raise ValueError("La base apurée contient un identifiant absent ou dupliqué.")
    rows: list[dict] = []

    for niveau, keys, g in groupes(d):
        n = len(g)
        geo = dict(niveau=niveau, **keys, n_groupe=n)

        def emit(code: str, mesure: str, variable: str, effectif: int | None,
                 denom: int | None, unite: str, statut: str = "calculé",
                 modalite: str = "", valeur: float | None = None, note: str = "",
                 attendus: int | None = None) -> None:
            if valeur is None and effectif is not None:
                valeur = round(100 * effectif / denom, 2) if unite == "%" and denom else (
                    float(effectif) if unite != "%" else None)
            rows.append({**geo, "code": code, "mesure": mesure, "modalite": modalite,
                         "valeur": valeur, "unite": unite, "effectif": effectif,
                         "denominateur": denom,
                         "sans_reponse": (attendus if attendus is not None else n) - denom
                         if denom is not None else None,
                         "statut": statut, "variables": variable,
                         "precision": note if denom is None or denom >= 30 else
                         (note + " Effectif faible : dénominateur < 30.").strip()})

        def rate(code: str, label: str, variable: str, population: pd.Series,
                 yes: pd.Series, known: pd.Series, statut: str = "calculé", note: str = "") -> None:
            denom = int((population & known).sum())
            num = int((population & known & yes).sum())
            emit(code, label, variable, num, denom, "%", statut, note=note,
                 attendus=int(population.sum()))

        def median(code: str, label: str, variable: str, population: pd.Series,
                   values: pd.Series, unite: str, statut: str = "calculé", note: str = "") -> None:
            vals = values.where(population).dropna()
            emit(code, label, variable, None, len(vals), unite, statut,
                 valeur=round(float(vals.median()), 2) if len(vals) else None, note=note,
                 attendus=int(population.sum()))

        def distribution(code: str, label: str, variable: str, population: pd.Series,
                         labels: dict, statut: str = "calculé", note: str = "") -> None:
            observed = g.loc[population, variable]
            observed = observed[observed.isin(labels)]
            denom = len(observed)
            for key, text in labels.items():
                emit(code, label, variable, int(observed.eq(key).sum()), denom,
                     "%", statut, modalite=text, note=note,
                     attendus=int(population.sum()))

        all_mask = pd.Series(True, index=g.index)
        employed = g.emploi_calcule.eq(1)
        unemployed = g.emploi_calcule.eq(0)
        salaried = employed & g.F1.eq(1)
        self_employed = employed & g.F1.isin([2, 3, 4])
        emit("profil", "Candidats retenus", "classe_completude,consentement", n, None, "personnes")
        # 3.1 : catégories observées, sans prétendre au chômage normatif.
        status = pd.Series("Indéterminé", index=g.index)
        status.loc[employed] = "En emploi"
        status.loc[unemployed & g.J0.eq(1)] = "Sans emploi, en recherche"
        status.loc[unemployed & g.J0.eq(2)] = "Sans emploi, sans recherche"
        denom_status = int(status.ne("Indéterminé").sum())
        for cat in ["En emploi", "Sans emploi, en recherche", "Sans emploi, sans recherche"]:
            emit("3.1", "Statut d'activité observé", "E1,E2,E3,E3A,J0",
                 int(status.eq(cat).sum()), denom_status, "%", "partiel", cat,
                 note="La disponibilité des personnes en recherche n'est pas mesurée.")
        distribution("3.2", "Type d'activité", "F1", employed, F1)
        distribution("3.2", "Secteur principal", "F2", employed, F2)
        median("3.3", "Heures hebdomadaires principales : médiane", "G3", employed,
               g.heures_principales, "heures")
        rate("3.3", "Autre activité déclarée", "G5", employed, g.G5.eq(1), g.G5.isin([1, 2]))
        median("3.4", "Salaire net dernière paie : médiane", "F1,H2,H3", salaried,
               g.montant_H3, "FCFA", "partiel",
               "Salariés seulement ; fréquences de paie différentes ; montant exact.")
        median("3.4", "Salaire net mensuel déclaré : médiane", "F1,H2,H3",
               salaried & g.H2.eq(4), g.montant_H3, "FCFA/mois", "partiel",
               "Salariés payés mensuellement ; petit effectif, montant exact.")
        median("3.4", "Gain net du dernier mois : médiane", "F1,H5", self_employed,
               g.gain_net_H5, "FCFA/mois", "partiel", "Gain net, pas chiffre d'affaires.")
        rate("3.5", "En emploi recherchant une autre activité", "I1", employed,
             g.I1.eq(1), g.I1.isin([1, 2]))
        distribution("3.5", "Motif de recherche parmi les personnes en emploi", "I2",
                     employed & g.I1.eq(1), I2)
        distribution("3.5", "Motif de non-recherche parmi les sans emploi", "J0A",
                     unemployed & g.J0.eq(2), J0A)
        rate("3.6", "Formation ou apprentissage durant les 12 derniers mois", "O3",
             all_mask, g.O3.eq(1), g.O3.isin([1, 2]), "partiel",
             "Formation générale ; attribution à COSO inconnue.")
        rate("3.6", "A déjà créé une activité génératrice de revenus", "K1",
             all_mask, g.K1.eq(1), g.K1.isin([1, 2]), "partiel",
             "Expérience générale ; appui COSO inconnu.")
        rate("3.7", "En emploi souhaitant davantage d'heures", "G7", employed,
             g.G7.eq(1), g.G7.isin([1, 2]), "partiel",
             "Composante, pas taux de sous-emploi.")
        rate("3.8", "Ménage ayant subi un choc", "N1", all_mask,
             g.N1.eq(1), g.N1.isin([1, 2]), "partiel")
        median("3.8", "Capacité déclarée à résister à un choc : médiane", "N7",
               all_mask, g.N7.where(g.N7.between(1, 10)), "/10", "partiel")
        distribution("3.8", "Capacité à réunir 250 000 FCFA", "N6", all_mask,
                     {1: "Facilement", 2: "Avec difficulté", 3: "Impossible"}, "partiel")
        distribution("3.8", "Délai de rétablissement après choc", "retablissement_N5",
                     g.N1.eq(1), N5, "partiel")
        distribution("3.9", "Autonomie économique actuelle", "M1", all_mask,
                     {1: "Dépend de l'aide", 2: "Autonomie partielle", 3: "Autonomie complète"})
        distribution("3.9", "Contribution économique perçue", "M3", all_mask,
                     {1: "Pas du tout d'accord", 2: "Plutôt pas d'accord", 3: "Neutre",
                      4: "Plutôt d'accord", 5: "Tout à fait d'accord"})
        distribution("3.9", "Autonomie anticipée à 12 mois", "M4", all_mask,
                     {1: "Dépendance", 2: "Autonomie partielle", 3: "Autonomie complète"})
        rate("4.2", "Membre d'une association", "Q1", all_mask,
             g.Q1.eq(1), g.Q1.isin([1, 2]), "partiel")
        rate("4.2", "Participation communautaire au moins une fois en 30 jours", "participations_Q2",
             all_mask, g.participations_Q2.ge(1), g.participations_Q2.notna(), "partiel",
             "Réponses textuelles ambiguës exclues du dénominateur.")
        rate("4.2", "Confiance envers la plupart des gens", "Q3", all_mask,
             g.Q3.eq(1), g.Q3.isin([1, 2]), "partiel")
        for q in [f"Q{i}" for i in range(4, 11)]:
            rate("4.2", f"Confiance partielle ou forte : {q}", q, all_mask,
                 g[q].isin([3, 4]), g[q].isin([1, 2, 3, 4]), "partiel",
                 "9 = ne sait pas, exclu.")

    return {"metadata": meta or {"n_apures": len(d)},
            "couverture": [{"code": c, "indicateur": name, "statut": status, "limite": why}
                          for c, name, status, why in COUVERTURE],
            "resultats": rows}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", type=Path, default=BASE)
    parser.add_argument("--meta", type=Path)
    parser.add_argument("--sortie", type=Path, required=True)
    args = parser.parse_args()
    meta = json.loads(args.meta.read_text(encoding="utf-8")) if args.meta else None
    output = calculer(args.base, meta)
    args.sortie.write_text(json.dumps(output, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"groupes": len({(r['niveau'], r['district'], r['region'], r['sexe'], r['age_groupe'], r['milieu'])
                                      for r in output['resultats']}),
                      "lignes": len(output["resultats"]), "indicateurs": len(output["couverture"])},
                     ensure_ascii=False))
