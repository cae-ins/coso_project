param(
    [string]$InputDir = "Data\Suivi_Collecte",
    [string]$InputFile = "",
    [string]$OutputRoot = "Analyse\suivi_qualite"
)

$ErrorActionPreference = "Stop"
$rscript = "C:\Program Files\R\R-4.5.3\bin\Rscript.exe"
if (-not (Test-Path -LiteralPath $rscript)) { $rscript = "Rscript.exe" }

if ([string]::IsNullOrWhiteSpace($InputFile)) {
    $candidate = Get-ChildItem -LiteralPath $InputDir -Recurse -File |
        Where-Object { $_.Extension -in @('.zip', '.dta') -and $_.Name -notmatch 'outputs|analytique|indicateurs' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($null -eq $candidate) { throw "Aucun export .zip ou .dta trouve dans $InputDir" }
    $InputFile = $candidate.FullName
}

New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
& $rscript "Analyse\R\06_suivi_qualite_quotidien.R" $InputFile $OutputRoot
if ($LASTEXITCODE -ne 0) { throw "Le suivi qualite R a echoue." }

$runDir = Get-ChildItem -LiteralPath $OutputRoot -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($null -eq $runDir) { throw "Dossier de run absent apres execution." }

$pandoc = (Get-Command pandoc -ErrorAction SilentlyContinue).Source
if ($pandoc) {
    & $pandoc (Join-Path $runDir.FullName "rapport_qualite_quotidien.md") `
        -o (Join-Path $runDir.FullName "rapport_qualite_quotidien.pdf") `
        --pdf-engine=xelatex -V geometry:margin=1.8cm
    if ($LASTEXITCODE -ne 0) { throw "La conversion PDF a echoue." }
} else {
    Write-Warning "Pandoc absent : le Markdown est disponible, mais le PDF n'a pas ete genere."
}

Write-Host "Rapport PDF : $(Join-Path $runDir.FullName 'rapport_qualite_quotidien.pdf')"
Write-Host "Dashboard : $(Join-Path $runDir.FullName 'dashboard_qualite.html')"
