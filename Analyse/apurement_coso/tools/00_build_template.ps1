param(
    [Parameter(Mandatory = $true)]
    [string]$SourceZip,

    [string]$RscriptPath = "C:\Program Files\R\R-4.5.3\bin\Rscript.exe"
)

$ErrorActionPreference = "Stop"

$toolsRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $toolsRoot
$stagedZip = Join-Path $projectRoot "datain\staging\export_coso.zip"
$generatedRoot = Join-Path $projectRoot "generated"

New-Item -ItemType Directory -Path $generatedRoot -Force | Out-Null

& (Join-Path $toolsRoot "01_stage_export.ps1") -SourceZip $SourceZip

if (-not (Test-Path -LiteralPath $RscriptPath -PathType Leaf)) {
    throw "Rscript introuvable : $RscriptPath"
}

& $RscriptPath `
    (Join-Path $toolsRoot "02_extract_dta_dictionary.R") `
    $stagedZip `
    (Join-Path $generatedRoot "dictionnaire_variables.csv")
if ($LASTEXITCODE -ne 0) {
    throw "L'extraction du dictionnaire Stata a echoue."
}

& $RscriptPath `
    (Join-Path $toolsRoot "05_validate_data_evidence.R") `
    $stagedZip `
    (Join-Path $generatedRoot "data_evidence_validation.csv")
if ($LASTEXITCODE -ne 0) {
    throw "La validation dynamique des donnees a echoue."
}

python (Join-Path $toolsRoot "03_extract_questionnaire_rules.py") `
    $stagedZip `
    (Join-Path $generatedRoot "questionnaire_rules.csv") `
    (Join-Path $generatedRoot "sections_questionnaire.csv")
if ($LASTEXITCODE -ne 0) {
    throw "L'extraction des regles du questionnaire a echoue."
}

python (Join-Path $toolsRoot "04_generate_stata_sections.py") `
    --project-root $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw "La generation des do-files Stata a echoue."
}

python (Join-Path $toolsRoot "04_generate_r_sections.py") `
    --project-root $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw "La generation des scripts R par section a echoue."
}

python (Join-Path $toolsRoot "validate_stata_excel_exports.py") --project-root $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw "La validation des exports Excel Stata a echoue."
}

python (Join-Path $toolsRoot "validate_rule_matrix.py") --project-root $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw "La validation de la matrice de regles a echoue."
}

python (Join-Path $toolsRoot "validate_translation_semantics.py") `
    --project-root $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw "La validation de la semantique nullable Stata a echoue."
}

& $RscriptPath `
    (Join-Path $projectRoot "R\00_master.R") `
    $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw "L'execution du moteur R d'apurement a echoue."
}

& $RscriptPath `
    (Join-Path $toolsRoot "06_validate_r_pipeline.R") `
    $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw "La validation du moteur R d'apurement a echoue."
}

Write-Host "Template COSO et moteur R construits et valides."
Write-Host "Archive source : $SourceZip"
Write-Host "Dossier         : $projectRoot"
