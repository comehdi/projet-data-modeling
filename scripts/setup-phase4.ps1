# =====================================================
# Script de vérification pour la Phase 4
# Gouvernance, Data Catalogue & Data Quality
# =====================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Phase 4 : Vérification de l'environnement" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier qu'OpenMetadata est lancé
Write-Host "1. Vérification des services OpenMetadata..." -ForegroundColor Yellow
$openmetadataServices = docker ps --filter "name=openmetadata" --format "{{.Names}}" 2>&1
if ($openmetadataServices -match "openmetadata") {
    Write-Host "  ✅ OpenMetadata est lancé" -ForegroundColor Green
    docker ps --filter "name=openmetadata" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
} else {
    Write-Host "  ❌ OpenMetadata n'est pas lancé" -ForegroundColor Red
    Write-Host "  Pour le lancer:" -ForegroundColor Yellow
    Write-Host "    docker-compose -f docker-compose.openmetadata.yml up -d" -ForegroundColor Gray
}

Write-Host ""

# 2. Vérifier que la base MDM contient des données
Write-Host "2. Vérification des données dans les tables MDM..." -ForegroundColor Yellow
$patientCount = docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -t -c "SELECT COUNT(*) FROM mdm_patient;" 2>&1
$praticienCount = docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -t -c "SELECT COUNT(*) FROM mdm_praticien;" 2>&1
$serviceCount = docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -t -c "SELECT COUNT(*) FROM mdm_service;" 2>&1
$locationCount = docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -t -c "SELECT COUNT(*) FROM mdm_location;" 2>&1

if ($patientCount -match "^\s*\d+\s*$" -and [int]$patientCount.Trim() -gt 0) {
    Write-Host "  ✅ mdm_patient : $($patientCount.Trim()) lignes" -ForegroundColor Green
} else {
    Write-Host "  ❌ mdm_patient : Aucune donnée" -ForegroundColor Red
}

if ($praticienCount -match "^\s*\d+\s*$" -and [int]$praticienCount.Trim() -gt 0) {
    Write-Host "  ✅ mdm_praticien : $($praticienCount.Trim()) lignes" -ForegroundColor Green
} else {
    Write-Host "  ❌ mdm_praticien : Aucune donnée" -ForegroundColor Red
}

if ($serviceCount -match "^\s*\d+\s*$" -and [int]$serviceCount.Trim() -gt 0) {
    Write-Host "  ✅ mdm_service : $($serviceCount.Trim()) lignes" -ForegroundColor Green
} else {
    Write-Host "  ❌ mdm_service : Aucune donnée" -ForegroundColor Red
}

if ($locationCount -match "^\s*\d+\s*$" -and [int]$locationCount.Trim() -gt 0) {
    Write-Host "  ✅ mdm_location : $($locationCount.Trim()) lignes" -ForegroundColor Green
} else {
    Write-Host "  ❌ mdm_location : Aucune donnée" -ForegroundColor Red
}

Write-Host ""

# 3. Informations de connexion
Write-Host "3. Informations de connexion OpenMetadata..." -ForegroundColor Yellow
Write-Host "  URL : http://localhost:8585" -ForegroundColor White
Write-Host "  Email : admin@open-metadata.org" -ForegroundColor White
Write-Host "  Password : admin" -ForegroundColor White

Write-Host ""

# 4. Informations de connexion PostgreSQL MDM
Write-Host "4. Informations de connexion PostgreSQL MDM Hub..." -ForegroundColor Yellow
Write-Host "  Host (depuis OpenMetadata) : postgres-mdm-hub" -ForegroundColor White
Write-Host "  Port : 5432" -ForegroundColor White
Write-Host "  Database : mdm_clinique" -ForegroundColor White
Write-Host "  Username : postgres" -ForegroundColor White
Write-Host "  Password : root" -ForegroundColor White

Write-Host ""

# 5. Checklist Phase 4
Write-Host "5. Checklist Phase 4..." -ForegroundColor Yellow
Write-Host "  ☐ Connexion OpenMetadata à PostgreSQL MDM Hub créée" -ForegroundColor Gray
Write-Host "  ☐ 4 tables MDM ingérées dans OpenMetadata" -ForegroundColor Gray
Write-Host "  ☐ Owners attribués à chaque table" -ForegroundColor Gray
Write-Host "  ☐ Tags ajoutés (Master Data, PII, Sensitive, Golden Record)" -ForegroundColor Gray
Write-Host "  ☐ Dictionnaire de données complété (descriptions pour toutes les colonnes)" -ForegroundColor Gray
Write-Host "  ☐ Tests de Data Quality configurés (Complétude, Validité, Unicité, Cohérence)" -ForegroundColor Gray
Write-Host "  ☐ Dashboard Data Quality à 100% de succès" -ForegroundColor Gray

Write-Host ""
Write-Host "Pour plus de détails, consultez : docs/05-phase-4-data-catalogue-quality.md" -ForegroundColor Cyan

