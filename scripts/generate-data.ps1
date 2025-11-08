# =====================================================
# Script PowerShell pour générer toutes les données MDM
# =====================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Génération de toutes les données MDM" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Split-Path -Parent $PSScriptRoot
$dataDir = Join-Path $projectRoot "data"

# Vérifier que le dossier data existe
if (-not (Test-Path $dataDir)) {
    Write-Host "❌ Le dossier data n'existe pas !" -ForegroundColor Red
    exit 1
}

# Scripts à exécuter
$scripts = @(
    @{Path = "patient\generate_patient_data.py"; Name = "Patients"},
    @{Path = "praticien\generate_praticien_data.py"; Name = "Praticiens"},
    @{Path = "service\generate_service_data.py"; Name = "Services"},
    @{Path = "location\generate_location_data.py"; Name = "Localisations"}
)

$successCount = 0
$failCount = 0

foreach ($script in $scripts) {
    $scriptPath = Join-Path $dataDir $script.Path
    $scriptDir = Split-Path -Parent $scriptPath
    
    Write-Host "Génération des données $($script.Name)..." -ForegroundColor Yellow
    
    if (-not (Test-Path $scriptPath)) {
        Write-Host "  ❌ Script non trouvé: $scriptPath" -ForegroundColor Red
        $failCount++
        continue
    }
    
    try {
        Push-Location $scriptDir
        $output = python $scriptPath 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host $output
            Write-Host "  ✅ $($script.Name) générés avec succès" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  ❌ Erreur lors de la génération des $($script.Name)" -ForegroundColor Red
            Write-Host $output
            $failCount++
        }
    } catch {
        Write-Host "  ❌ Erreur: $_" -ForegroundColor Red
        $failCount++
    } finally {
        Pop-Location
    }
    Write-Host ""
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Résumé" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ✅ Réussis: $successCount" -ForegroundColor Green
Write-Host "  ❌ Échoués: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "✅ Toutes les données ont été générées avec succès !" -ForegroundColor Green
    Write-Host ""
    Write-Host "Fichiers créés :" -ForegroundColor Cyan
    Write-Host "  - data\patient\ : 3 fichiers CSV" -ForegroundColor White
    Write-Host "  - data\praticien\ : 3 fichiers CSV" -ForegroundColor White
    Write-Host "  - data\service\ : 3 fichiers CSV" -ForegroundColor White
    Write-Host "  - data\location\ : 3 fichiers CSV" -ForegroundColor White
    Write-Host ""
    Write-Host "Total : 12 fichiers CSV prêts pour le Data Wrangling !" -ForegroundColor Green
} else {
    Write-Host "⚠️  Certaines générations ont échoué." -ForegroundColor Yellow
    exit 1
}

