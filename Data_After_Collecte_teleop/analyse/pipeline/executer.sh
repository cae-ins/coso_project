#!/bin/sh
# Lance 01 -> 05. Les deux JSON et le LaTeX restent temporaires.
set -eu
coso_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
coso_python=${COSO_PYTHON:-/opt/anaconda3/bin/python3}
coso_node_modules=${COSO_NODE_MODULES:-$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules}
if [ -e "$coso_root/résultats/"'~$indicateurs_COSO.xlsx' ]; then
  echo "Fermez indicateurs_COSO.xlsx dans Excel avant de relancer le pipeline." >&2
  exit 1
fi
coso_tmp_dir=$(mktemp -d)
trap 'rm -rf "$coso_tmp_dir"' EXIT
cp "$coso_root/pipeline/03_excel.mjs" "$coso_tmp_dir/03_excel.mjs"
ln -s "$coso_node_modules" "$coso_tmp_dir/node_modules"

"$coso_python" "$coso_root/pipeline/01_apurement.py" \
  --sortie "$coso_root/résultats/base_apuree.csv" --meta "$coso_tmp_dir/apurement.json"
"$coso_python" "$coso_root/pipeline/02_indicateurs.py" \
  --base "$coso_root/résultats/base_apuree.csv" \
  --meta "$coso_tmp_dir/apurement.json" --sortie "$coso_tmp_dir/indicateurs.json"
node "$coso_tmp_dir/03_excel.mjs" \
  "$coso_tmp_dir/indicateurs.json" "$coso_root/résultats/indicateurs_COSO.xlsx"
"$coso_python" "$coso_root/pipeline/04_rapport.py" \
  --resultats "$coso_tmp_dir/indicateurs.json" --tex "$coso_tmp_dir/synthese_COSO.tex"
tectonic --only-cached "$coso_tmp_dir/synthese_COSO.tex" --outdir "$coso_root/résultats"
"$coso_python" "$coso_root/pipeline/05_verifier.py" \
  --resultats "$coso_tmp_dir/indicateurs.json"
