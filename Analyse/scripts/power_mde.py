"""
Calcul de l'Effet Minimum Détectable (MDE) — Évaluation d'impact COSO Nord
============================================================================
Design : essai randomisé à DEUX bras, randomisation INDIVIDUELLE.
    - Bras traité  : bénéficiaires tirés au sort recevant le package (≈ 600)
    - Bras témoin  : liste d'attente (candidats non sélectionnés)
Estimande : intention-de-traiter (ITT) = effet d'être tiré au sort.

Méthode J-PAL (formule MDE pour 2 bras, randomisation individuelle) :

    MDE = (t_{1-κ} + t_{α/2}) * sqrt( 1 / (P(1-P)) ) * sqrt( σ² / N )

    soit, en unités d'écart-type (σ = 1) :

    MDE_σ = (t_{1-κ} + t_{α/2}) / sqrt( P(1-P) * N )

Randomisation individuelle => PAS d'effet de grappe (pas d'ICC à corriger).
Avec contrôle de la valeur baseline (ANCOVA), on multiplie par sqrt(1 - R²).

CONSTANTES RÉELLES tirées de la baseline COSO (voir Data/) :
    - Vivier total enrôlé ............. 1 688 candidats (1 127 H / 561 F = 33 % F)
    - Places (bénéficiaires) .......... 600  -> sur-souscription 2,8 : 1
    - Vivier témoin disponible ........ ~1 088 (= 1 688 - 600)
    - Joignabilité (campagne pts focaux) ~60 % (975/1615 "donnée correcte")
      (sous-échantillon Arlette : 46-48 %)  -> RÉTENTION réaliste ≈ 0,60

LIMITE ASSUMÉE EXPLICITEMENT :
    La baseline NE CONTIENT PAS de variable de revenu. L'écart-type / CV du
    revenu ne peut donc PAS être estimé sur données. La traduction du MDE en
    "% de la moyenne" utilise un coefficient de variation (CV) de benchmark
    (microentreprises : CV ~ 1,0 à 1,5), à remplacer par la vraie valeur dès
    qu'un module revenu sera collecté à la baseline.

Sorties : tableau console + CSV + 2 graphiques PNG dans scripts/_outputs/.
Usage   : python Analyse/scripts/power_mde.py
"""

import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

import numpy as np
import pandas as pd
from scipy.stats import norm

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# --------------------------------------------------------------------------- #
# Constantes réelles (baseline COSO Nord)
# --------------------------------------------------------------------------- #
N_TRAITE = 600              # bénéficiaires tirés au sort
VIVIER_TEMOIN = 1088        # 1688 enrôlés - 600 places
JOIGNABILITE = 0.60         # taux "donnée correcte" campagne points focaux

ALPHA = 0.05                # significativité bilatérale
OUT = Path(__file__).resolve().parent / "_outputs"
OUT.mkdir(parents=True, exist_ok=True)


# --------------------------------------------------------------------------- #
# Formule MDE (J-PAL)
# --------------------------------------------------------------------------- #
def mde_sigma(n_traite, n_temoin, power=0.80, alpha=ALPHA, r2=0.0):
    """MDE en unités d'écart-type (σ=1). Randomisation individuelle, 2 bras."""
    n = n_traite + n_temoin
    p = n_traite / n
    facteur = norm.ppf(1 - alpha / 2) + norm.ppf(power)   # 2.80 @80% ; 3.24 @90%
    return facteur * np.sqrt((1 - r2) / (p * (1 - p) * n))


def appliquer_retention(n_traite, n_temoin, retention):
    """Échantillon EFFECTIVEMENT observé après attrition/injoignables."""
    return n_traite * retention, n_temoin * retention


# --------------------------------------------------------------------------- #
# 1) Tableau : scénarios d'allocation (sans attrition, puis ANCOVA)
# --------------------------------------------------------------------------- #
def tableau_scenarios():
    scenarios = [
        ("300 / 300 (échantillon total = 600)", 300, 300),
        ("600 / 400", 600, 400),
        ("600 / 600 (recommandé)", 600, 600),
        ("600 / 1088 (témoin max)", 600, 1088),
    ]
    rows = []
    for label, nt, nc in scenarios:
        rows.append({
            "Allocation (T/C)": label,
            "N": nt + nc,
            "P": round(nt / (nt + nc), 3),
            "MDE 80%": round(mde_sigma(nt, nc, 0.80), 3),
            "MDE 90%": round(mde_sigma(nt, nc, 0.90), 3),
            "MDE 80% +ANCOVA(R²=.4)": round(mde_sigma(nt, nc, 0.80, r2=0.4), 3),
        })
    return pd.DataFrame(rows)


# --------------------------------------------------------------------------- #
# 2) Tableau : effet de la rétention (injoignables) — scénario 600/600
# --------------------------------------------------------------------------- #
def tableau_retention():
    rows = []
    for ret in [0.50, 0.60, 0.75, 0.90, 1.00]:
        nt, nc = appliquer_retention(N_TRAITE, 600, ret)
        rows.append({
            "Rétention": f"{ret:.0%}",
            "N observé": int(nt + nc),
            "MDE 80% (σ)": round(mde_sigma(nt, nc, 0.80), 3),
            "MDE 80% +ANCOVA": round(mde_sigma(nt, nc, 0.80, r2=0.4), 3),
        })
    return pd.DataFrame(rows)


# --------------------------------------------------------------------------- #
# 3) Traduction MDE(σ) -> % de la moyenne du revenu (CV de benchmark)
# --------------------------------------------------------------------------- #
def tableau_traduction(mde_ref):
    rows = []
    for cv in [1.0, 1.5]:
        rows.append({
            "Hypothèse CV revenu": cv,
            "MDE en % de la moyenne": f"{mde_ref * cv:.0%}",
        })
    # outcome binaire (emploi, survie d'activité) : σ = sqrt(p(1-p)) ≈ 0.5
    rows.append({"Hypothèse CV revenu": "binaire (p≈.5)",
                 "MDE en % de la moyenne": f"{mde_ref * 0.5 * 100:.1f} points"})
    return pd.DataFrame(rows)


# --------------------------------------------------------------------------- #
# 4) Graphiques
# --------------------------------------------------------------------------- #
def graphe_mde_vs_temoin():
    """MDE = f(nb de témoins enquêtés), traité fixé à 600."""
    nc = np.arange(100, VIVIER_TEMOIN + 1, 10)
    plt.figure(figsize=(8, 5))
    for power, style in [(0.80, "-"), (0.90, "--")]:
        plt.plot(nc, [mde_sigma(N_TRAITE, c, power) for c in nc],
                 style, label=f"Puissance {power:.0%} (sans baseline)")
        plt.plot(nc, [mde_sigma(N_TRAITE, c, power, r2=0.4) for c in nc],
                 style, alpha=0.5, label=f"Puissance {power:.0%} +ANCOVA (R²=.4)")
    plt.axvline(600, color="grey", ls=":", lw=1)
    plt.text(610, plt.ylim()[1] * 0.92, "600 témoins", color="grey", fontsize=8)
    plt.axhline(0.35, color="red", ls=":", lw=1)
    plt.text(120, 0.36, "effet type littérature ≈ 0,35 σ (Ouganda YOP)",
             color="red", fontsize=8)
    plt.xlabel("Nombre de témoins enquêtés (traités = 600)")
    plt.ylabel("Effet minimum détectable (écarts-type)")
    plt.title("MDE vs taille du groupe témoin — COSO Nord (randomisation individuelle)")
    plt.legend(fontsize=8)
    plt.grid(alpha=0.3)
    plt.tight_layout()
    f = OUT / "mde_vs_temoin.png"
    plt.savefig(f, dpi=130)
    plt.close()
    return f


def graphe_mde_vs_retention():
    """MDE = f(taux de rétention) — illustre le gain à réduire les injoignables."""
    ret = np.linspace(0.40, 1.0, 61)
    plt.figure(figsize=(8, 5))
    for nc, lab in [(600, "600/600"), (1088, "600/1088")]:
        y = [mde_sigma(*appliquer_retention(N_TRAITE, nc, r), 0.80, r2=0.4) for r in ret]
        plt.plot(ret * 100, y, label=f"{lab} +ANCOVA, 80%")
    plt.axvline(JOIGNABILITE * 100, color="orange", ls="--", lw=1)
    plt.text(JOIGNABILITE * 100 + 1, plt.ylim()[1] * 0.9,
             "joignabilité actuelle ≈ 60%", color="orange", fontsize=8)
    plt.xlabel("Taux de rétention / joignabilité (%)")
    plt.ylabel("MDE (écarts-type), puissance 80%")
    plt.title("Valeur de réduire les injoignables — chaque point de rétention compte")
    plt.legend(fontsize=8)
    plt.grid(alpha=0.3)
    plt.tight_layout()
    f = OUT / "mde_vs_retention.png"
    plt.savefig(f, dpi=130)
    plt.close()
    return f


# --------------------------------------------------------------------------- #
def main():
    print("=" * 72)
    print("MDE — COSO Nord | 2 bras | randomisation individuelle | α = 0,05")
    print("=" * 72)

    t1 = tableau_scenarios()
    print("\n[1] MDE selon l'allocation (T = traité / C = témoin)\n")
    print(t1.to_string(index=False))

    t2 = tableau_retention()
    print("\n[2] Effet de la rétention (injoignables) — scénario 600/600\n")
    print(t2.to_string(index=False))

    mde_ref = mde_sigma(600, 600, 0.80, r2=0.4)   # scénario recommandé
    t3 = tableau_traduction(mde_ref)
    print(f"\n[3] Traduction du MDE recommandé ({mde_ref:.3f} σ, 600/600 +ANCOVA)\n")
    print(t3.to_string(index=False))
    print("    (% = MDE_σ × CV ; CV du revenu à confirmer par module baseline)")

    t1.to_csv(OUT / "mde_scenarios.csv", index=False)
    t2.to_csv(OUT / "mde_retention.csv", index=False)
    f1 = graphe_mde_vs_temoin()
    f2 = graphe_mde_vs_retention()

    print("\n[4] Fichiers écrits :")
    for f in [OUT / "mde_scenarios.csv", OUT / "mde_retention.csv", f1, f2]:
        print("   ", f.relative_to(Path(__file__).resolve().parents[2]))
    print("\nLecture : avec 600 témoins enquêtés et la baseline en ANCOVA, on")
    print("détecte ~0,13 σ à 80% — bien en deçà des effets attendus (~0,35 σ).")
    print("La contrainte mordante n'est pas N, c'est la rétention (injoignables).")


if __name__ == "__main__":
    main()
