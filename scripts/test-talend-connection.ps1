# =====================================================
# Script de test de connexion Talend à PostgreSQL
# =====================================================

Write-Host "Test de connexion PostgreSQL pour les jobs Talend..." -ForegroundColor Cyan
Write-Host ""

# Tester la connexion avec postgres/root
Write-Host "Test 1: Connexion avec postgres/root..." -ForegroundColor Yellow
$result = docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "SELECT current_user, current_database();" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Connexion réussie avec postgres/root" -ForegroundColor Green
    Write-Host $result
} else {
    Write-Host "  ❌ Échec de la connexion" -ForegroundColor Red
    Write-Host $result
}

Write-Host ""
Write-Host "Test 2: Vérification des tables MDM..." -ForegroundColor Yellow
$tables = docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'mdm_%' ORDER BY table_name;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Tables trouvées:" -ForegroundColor Green
    $tables | ForEach-Object { if ($_.Trim()) { Write-Host "    - $($_.Trim())" } }
} else {
    Write-Host "  ❌ Erreur lors de la vérification des tables" -ForegroundColor Red
}

Write-Host ""
Write-Host "Note: Si les jobs Talend échouent encore, le mot de passe chiffré" -ForegroundColor Yellow
Write-Host "      dans le code Java ne correspond peut-être pas à 'root'." -ForegroundColor Yellow
Write-Host "      Dans ce cas, il faut modifier la connexion dans Talend Studio" -ForegroundColor Yellow
Write-Host "      et réexporter les jobs." -ForegroundColor Yellow

