param(
    [Parameter(Mandatory = $true)]
    [string]$SourceZip
)

$ErrorActionPreference = "Stop"

$toolsRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $toolsRoot))
$stagingRoot = [System.IO.Path]::GetFullPath((Join-Path $projectRoot "datain\staging"))
$bruteRoot = [System.IO.Path]::GetFullPath((Join-Path $projectRoot "datain\brute"))
$resolvedSource = (Resolve-Path -LiteralPath $SourceZip).Path

if ([System.IO.Path]::GetExtension($resolvedSource) -ne ".zip") {
    throw "La source doit etre une archive .zip Survey Solutions : $resolvedSource"
}

if (-not $stagingRoot.StartsWith($projectRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Chemin staging hors du projet : $stagingRoot"
}
if (-not $bruteRoot.StartsWith($projectRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Chemin brute hors du projet : $bruteRoot"
}

New-Item -ItemType Directory -Path $stagingRoot -Force | Out-Null
New-Item -ItemType Directory -Path $bruteRoot -Force | Out-Null

$stagedZip = Join-Path $stagingRoot "export_coso.zip"
Copy-Item -LiteralPath $resolvedSource -Destination $stagedZip -Force

Get-ChildItem -LiteralPath $bruteRoot -Force |
    Where-Object { $_.Name -ne ".gitkeep" } |
    Remove-Item -Recurse -Force

Expand-Archive -LiteralPath $stagedZip -DestinationPath $bruteRoot -Force

$mainDta = Get-ChildItem -LiteralPath $bruteRoot -Recurse -File -Filter "Questionnaire_COSO_V5.dta" |
    Select-Object -First 1
if ($null -eq $mainDta) {
    throw "Questionnaire_COSO_V5.dta est absent de l'archive."
}

$questionnaireHtml = Get-ChildItem -LiteralPath $bruteRoot -Recurse -File -Filter "Original Questionnaire_COSO_V5.html" |
    Select-Object -First 1
if ($null -eq $questionnaireHtml) {
    throw "Le questionnaire HTML Survey Solutions est absent de l'archive."
}

$hash = (Get-FileHash -LiteralPath $stagedZip -Algorithm SHA256).Hash
$metadata = @(
    "source_path=$resolvedSource"
    "staged_path=$stagedZip"
    "sha256=$hash"
    "staged_at=$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
    "main_dta=$($mainDta.FullName)"
    "questionnaire_html=$($questionnaireHtml.FullName)"
    "raw_modified=FALSE"
)
Set-Content -LiteralPath (Join-Path $stagingRoot "source_manifest.txt") -Value $metadata -Encoding UTF8

Write-Host "Snapshot copie dans datain/staging."
Write-Host "Copie de travail recreee dans datain/brute."
Write-Host "SHA-256 : $hash"
