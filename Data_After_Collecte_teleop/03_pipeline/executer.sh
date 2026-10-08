#!/usr/bin/env bash
# Exécution de la chaîne complète des indicateurs COSO, étapes 01 → 11.
#
#   bash 03_pipeline/executer.sh
#
# Variable d'environnement :
#   COSO_PYTHON   interpréteur Python à utiliser
#                 (défaut : /opt/anaconda3/bin/python3 s'il existe, sinon python3)
#
# La chaîne part de 02_bases/ et écrit dans 04_resultats/, 05_docs/ et 06_notes/.
# Chaque étape s'arrête au premier échec (set -e). L'étape 11 contrôle les
# livrables et sort avec un code non nul si un contrôle échoue.

set -euo pipefail

DOSSIER="$(cd "$(dirname "$0")" && pwd)"   # 03_pipeline
cd "$(dirname "$DOSSIER")"                 # racine Data_After_Collecte_teleop

if [[ -n "${COSO_PYTHON:-}" ]]; then
    PYTHON="$COSO_PYTHON"
elif [[ -x /opt/anaconda3/bin/python3 ]]; then
    PYTHON=/opt/anaconda3/bin/python3
else
    PYTHON=python3
fi

lancer() {
    local fichier="$1"
    echo ""
    echo "=================================================================="
    echo "== Étape ${fichier%%_*} : $(basename "$fichier" .py)"
    echo "=================================================================="
    "$PYTHON" "03_pipeline/$fichier"
}

for etape in \
    01_completude_logique.py \
    02_generer_notes.py \
    03_lire_verifier_bases.py \
    04_generer_note_manques.py \
    05_generer_rattrapage.py \
    06_pipeline_doublons.py \
    07_apurement_indicateurs.py \
    08_calcul_indicateurs.py \
    09_excel_indicateurs.py \
    10_rapport_indicateurs.py \
    11_verifier_indicateurs.py
do
    lancer "$etape"
done

echo ""
echo "=================================================================="
echo " Chaîne terminée : livrables dans 04_resultats/indicateurs/"
echo "   - indicateurs.json"
echo "   - Indicateurs_COSO.xlsx"
echo "   - Rapport_indicateurs_COSO.docx"
echo "=================================================================="
