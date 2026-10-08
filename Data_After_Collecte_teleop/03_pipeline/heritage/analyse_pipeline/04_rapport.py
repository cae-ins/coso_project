"""04 — Rédiger le résumé LaTeX depuis les mêmes résultats que l'Excel."""

from __future__ import annotations

import argparse
import json
from datetime import date
from pathlib import Path


def pct(x: dict | None) -> str:
    return "n.d." if x is None or x["valeur"] is None else f'{x["valeur"]:.1f}'.replace(".", ",") + r"\%"


def nombre(x: dict | None) -> str:
    return "n.d." if x is None or x["valeur"] is None else f'{x["valeur"]:,.0f}'.replace(",", " ")


def produire(data: dict, sortie: Path) -> None:
    rows = data["resultats"]
    meta = data["metadata"]

    def find(level: str, code: str, measure: str, modalite: str = "",
             district: str | None = None, region: str | None = None,
             sexe: str | None = None) -> dict | None:
        return next((r for r in rows if r["niveau"] == level and r["code"] == code
                     and r["mesure"] == measure and r["modalite"] == modalite
                     and (district is None or r["district"] == district)
                     and (region is None or r["region"] == region)
                     and (sexe is None or r["sexe"] == sexe)), None)

    total = lambda code, measure, modality="": find("Ensemble", code, measure, modality)
    employment = "Statut d'activité observé"
    training = "Formation ou apprentissage durant les 12 derniers mois"
    shock = "Ménage ayant subi un choc"
    autonomy = "Autonomie économique actuelle"
    districts = sorted({r["district"] for r in rows if r["niveau"] == "District"})
    regions = sorted({(r["district"], r["region"]) for r in rows if r["niveau"] == "Région"})
    h3 = total("3.4", "Salaire net dernière paie : médiane")
    h3_month = total("3.4", "Salaire net mensuel déclaré : médiane")
    h5 = total("3.4", "Gain net du dernier mois : médiane")
    shock_poro = find("Région", "3.8", shock, district="Savanes", region="Poro")
    shock_tchologo = find("Région", "3.8", shock, district="Savanes", region="Tchologo")
    autonomy_women = find("Sexe", "3.9", autonomy, "Autonomie complète", sexe="Femme")
    autonomy_men = find("Sexe", "3.9", autonomy, "Autonomie complète", sexe="Homme")
    mois = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet",
            "août", "septembre", "octobre", "novembre", "décembre"]
    today = date.today()
    date_rapport = f"{today.day} {mois[today.month - 1]} {today.year}"

    def territory(level: str, district: str, region: str | None = None) -> str:
        label = region or district
        group = find(level, "profil", "Candidats retenus", district=district, region=region)
        e = find(level, "3.1", employment, "En emploi", district, region)
        f = find(level, "3.6", training, district=district, region=region)
        s = find(level, "3.8", shock, district=district, region=region)
        a = find(level, "3.9", autonomy, "Autonomie complète", district, region)
        return f"{label} & {int(group['valeur']) if group else 0} & {pct(e)} & {pct(f)} & {pct(s)} & {pct(a)} \\\\"

    district_rows = "\n".join(territory("District", x) for x in districts)
    region_rows = "\n".join(territory("Région", d, r) for d, r in regions)

    tex = rf"""\documentclass[10pt,a4paper]{{article}}
\usepackage[margin=17mm]{{geometry}}
\usepackage{{fontspec}}
\setmainfont{{Arial}}
\usepackage{{xcolor,booktabs,tabularx,array,fancyhdr}}
\definecolor{{navy}}{{HTML}}{{17324D}}
\pagestyle{{fancy}}\fancyhf{{}}
\fancyhead[L]{{\small COSO | Résultats descriptifs}}
\fancyhead[R]{{\small {date_rapport}}}
\fancyfoot[C]{{\small\thepage}}
\setlength{{\headheight}}{{14pt}}
\setlength{{\parindent}}{{0pt}}\setlength{{\parskip}}{{5pt}}
\newcommand{{\band}}[1]{{\vspace{{5pt}}\noindent\colorbox{{navy}}{{\parbox{{\dimexpr\linewidth-2\fboxsep}}{{\color{{white}}\bfseries #1}}}}\vspace{{4pt}}}}
\begin{{document}}
{{\LARGE\bfseries\color{{navy}} Synthèse des indicateurs COSO}}\\[4pt]
{{\large Enquête téléphonique auprès des candidats}}\\[8pt]

\band{{Population et apurement}}
Le DTA contient {meta['n_source']} entretiens. Parmi eux, {meta['n_apres_completude']} sont classés complets ou quasi complets. Après exclusion de {meta['n_exclus_sans_consentement']} entretien sans consentement positif, la base apurée compte \textbf{{{meta['n_apures']} candidats}}. L'audit relève \textbf{{{meta['n_signalements']} points à revoir}} concernant {meta['n_entretiens_signales']} entretiens. Les chiffres ci-dessous décrivent les répondants retenus.

\band{{Principaux résultats}}
\begin{{tabularx}}{{\linewidth}}{{>{{\raggedright\arraybackslash}}X r}}
\toprule Mesure & Résultat \\ \midrule
En emploi & {pct(total('3.1', employment, 'En emploi'))} ({total('3.1', employment, 'En emploi')['effectif']}/{meta['n_apures']}) \\
Sans emploi, en recherche & {pct(total('3.1', employment, 'Sans emploi, en recherche'))} \\
Heures de l'activité principale, médiane & {nombre(total('3.3', 'Heures hebdomadaires principales : médiane'))} h \\
Formation ou apprentissage en 12 mois & {pct(total('3.6', training))} \\
Ménage ayant subi un choc & {pct(total('3.8', shock))} \\
Capacité déclarée à résister à un choc, médiane & {nombre(total('3.8', 'Capacité déclarée à résister à un choc : médiane'))}/10 \\
Autonomie économique actuelle complète & {pct(total('3.9', autonomy, 'Autonomie complète'))} \\
Membre d'une association & {pct(total('4.2', "Membre d'une association"))} \\
\bottomrule
\end{{tabularx}}

\band{{Lecture des revenus et des effets}}
Le salaire de la dernière paie (H3) a une médiane de {nombre(h3)} FCFA sur {h3['denominateur']} salariés ayant donné un montant exact ; parmi les {h3_month['denominateur']} payés mensuellement, la médiane est {nombre(h3_month)} FCFA. Le gain net mensuel (H5) a une médiane de \textbf{{{nombre(h5)} FCFA}} sur {h5['denominateur']} montants positifs chez les indépendants, employeurs et coopératives. Ces populations et périodes diffèrent ; aucun chiffre d'affaires n'est mesuré.

\band{{Districts}}
\begin{{tabularx}}{{\linewidth}}{{>{{\raggedright\arraybackslash}}X r r r r r}}
\toprule District & N & Emploi & Formation & Choc & Autonomie \\ \midrule
{district_rows}
\bottomrule
\end{{tabularx}}

\band{{Limites essentielles}}
Les registres du projet sont nécessaires pour l'enrôlement, la sélection, l'achèvement des formations, les kits, les MAF, la chambre des métiers et l'AVEC. Les taux normatifs de chômage ou de sous-emploi et les indices composites ne sont pas publiés. Les petites sous-populations demandent une lecture prudente. Le classeur Excel fournit chaque effectif, dénominateur et désagrégation.

\newpage
{{\Large\bfseries\color{{navy}} Résultats par région}}\\[5pt]
{{\small Parts calculées parmi les répondants de chaque région. Les dénominateurs propres aux questions figurent dans le classeur Excel.}}\\[8pt]
\begin{{tabularx}}{{\linewidth}}{{>{{\raggedright\arraybackslash}}X r r r r r}}
\toprule Région & N & Emploi & Formation & Choc & Autonomie \\ \midrule
{region_rows}
\bottomrule
\end{{tabularx}}

\band{{Deux écarts descriptifs à examiner}}
Dans les Savanes, un choc est déclaré par {pct(shock_poro)} des répondants du Poro ({shock_poro['effectif']}/{shock_poro['denominateur']}) et {pct(shock_tchologo)} de ceux du Tchologo ({shock_tchologo['effectif']}/{shock_tchologo['denominateur']}). L'autonomie complète est déclarée par {pct(autonomy_women)} des femmes ({autonomy_women['effectif']}/{autonomy_women['denominateur']}) et {pct(autonomy_men)} des hommes ({autonomy_men['effectif']}/{autonomy_men['denominateur']}). Ces écarts sont descriptifs, sans ajustement ni inférence causale.

\vspace{{12pt}}
\band{{Méthode en bref}}
Une proportion est le nombre de réponses correspondant à la modalité divisé par le nombre de réponses valides dans la population concernée. Les médianes excluent les codes de refus et les valeurs hors plage. Les réponses aux questions posées seulement après un saut de questionnaire ne sont jamais imputées comme « non ». Le classeur distingue les mesures directes, les composantes partielles et les indicateurs indisponibles.

\vspace{{8pt}}
{{\small\color{{navy}} Source : QUESTIONNAIRE\_VF\_SANS\_DOUBLON\_VF.dta. Méthodes détaillées : rapport méthodologique du pipeline.}}
\end{{document}}
"""
    sortie.write_text(tex, encoding="utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--resultats", type=Path, required=True)
    parser.add_argument("--tex", type=Path, required=True)
    args = parser.parse_args()
    produire(json.loads(args.resultats.read_text(encoding="utf-8")), args.tex)
    print(args.tex)
