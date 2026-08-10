param(
    [string]$OutputRoot = "Analyse\suivi_qualite",
    [string]$Branch = "dashboard"
)

$ErrorActionPreference = "Stop"

$currentBranch = (git branch --show-current).Trim()
if ($currentBranch -ne $Branch) {
    throw "Se placer sur la branche '$Branch' avant de publier. Branche actuelle : '$currentBranch'."
}

$latestRun = Get-ChildItem -LiteralPath $OutputRoot -Directory |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if ($null -eq $latestRun) { throw "Aucun run trouve dans $OutputRoot." }

$source = Join-Path $latestRun.FullName "dashboard_public.html"
if (-not (Test-Path -LiteralPath $source)) { throw "Dashboard absent : $source" }

$html = Get-Content -LiteralPath $source -Raw
$forbidden = @("observed_value", "quality_cases_for_review", "pii_exposure_summary", "<th>interview__key</th>", "<th>cover_id</th>", "<h2>Agents</h2>", "<th>agent</th>")
foreach ($pattern in $forbidden) {
    if ($html.Contains($pattern)) { throw "Publication bloquee : contenu individuel detecte ($pattern)." }
}

New-Item -ItemType Directory -Force -Path "docs" | Out-Null
Copy-Item -LiteralPath $source -Destination "docs\index.html" -Force

git add -- "docs/index.html"
if ($LASTEXITCODE -ne 0) { throw "Echec de git add." }

git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "Aucun changement de dashboard a publier."
    exit 0
}

$runName = $latestRun.Name
git commit -m "Actualise le dashboard qualite ($runName)"
if ($LASTEXITCODE -ne 0) { throw "Echec du commit." }

git push origin $Branch
if ($LASTEXITCODE -ne 0) { throw "Echec du push vers origin/$Branch." }

Write-Host "Dashboard pousse sur origin/$Branch. Le workflow GitHub Pages va le publier."
