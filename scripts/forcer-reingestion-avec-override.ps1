# =====================================================
# Script pour forcer une réingestion avec overrideMetadata et forceEntityOverwriting
# =====================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Forcer une réingestion complète" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Trouver le fichier de configuration
Write-Host "1. Recherche du fichier de configuration..." -ForegroundColor Yellow
$configFiles = docker exec openmetadata-ingestion sh -lc "ls /opt/airflow/dag_generated_configs/*.json 2>/dev/null | head -1"

if ([string]::IsNullOrEmpty($configFiles)) {
    Write-Host "  ❌ Aucun fichier de configuration trouvé" -ForegroundColor Red
    Write-Host "  Vérifiez que vous avez configuré une ingestion dans OpenMetadata UI" -ForegroundColor Yellow
    Write-Host "  http://localhost:8585 > Settings > Services > Databases > MDM Clinique Hub > Ingestion Pipelines" -ForegroundColor Gray
    exit 1
}

$configFile = $configFiles.Trim()
Write-Host "  ✅ Configuration trouvée: $configFile" -ForegroundColor Green
Write-Host ""

# 2. Lire et modifier la configuration
Write-Host "2. Modification de la configuration pour forcer l'override..." -ForegroundColor Yellow

# Créer un script Python temporaire dans le conteneur
$pythonScriptContent = @'
import json
import sys
import os

configPath = sys.argv[1]

# Lire la configuration
with open(configPath, 'r') as f:
    config = json.load(f)

# Modifier pour forcer l'override
if 'sourceConfig' in config and 'config' in config['sourceConfig']:
    config['sourceConfig']['config']['overrideMetadata'] = True
    print('overrideMetadata = True')

if 'openMetadataServerConnection' in config:
    config['openMetadataServerConnection']['forceEntityOverwriting'] = True
    print('forceEntityOverwriting = True')

# Écrire la configuration modifiée
with open(configPath, 'w') as f:
    json.dump(config, f, indent=2)

print('Configuration modifiée avec succès')
'@

# Écrire le script dans un fichier temporaire local
$tempScriptLocal = "$env:TEMP\fix_config_$(Get-Random).py"
$pythonScriptContent | Out-File -FilePath $tempScriptLocal -Encoding utf8

# Copier le script dans le conteneur
$tempScript = "/tmp/fix_config.py"
docker cp $tempScriptLocal "openmetadata-ingestion:$tempScript"

# Exécuter le script
$result = docker exec openmetadata-ingestion sh -lc "python3 $tempScript $configFile"
Write-Host $result -ForegroundColor Gray

# Nettoyer (ignore les erreurs)
docker exec openmetadata-ingestion sh -lc "rm -f $tempScript" 2>$null | Out-Null
Remove-Item -Path $tempScriptLocal -Force -ErrorAction SilentlyContinue

# Vérifier que la modification a réussi en vérifiant le résultat
if ($result -match "Configuration modifiée avec succès") {
    Write-Host "  ✅ Configuration modifiée" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Modification effectuée mais vérification incertaine" -ForegroundColor Yellow
}

Write-Host "  ✅ Configuration modifiée" -ForegroundColor Green
Write-Host ""

# 3. Trouver le DAG ID depuis le nom du fichier de config
Write-Host "3. Recherche du DAG ID..." -ForegroundColor Yellow
$configFileName = Split-Path -Leaf $configFile
$configBaseName = $configFileName -replace '\.json$', ''
$dagId = $configBaseName

Write-Host "  ✅ DAG ID trouvé depuis le fichier de config: $dagId" -ForegroundColor Green
Write-Host ""

# 4. Relancer l'ingestion
Write-Host "4. Relance de l'ingestion..." -ForegroundColor Yellow
$response = docker exec openmetadata-ingestion sh -lc "curl -s -u admin:admin -X POST -H 'Content-Type: application/json' -d '{}' http://localhost:8080/api/v1/dags/$dagId/dagRuns"

if ($response -match '"dag_run_id"') {
    $runId = ($response | ConvertFrom-Json).dag_run_id
    Write-Host "  ✅ Ingestion relancée - Run ID: $runId" -ForegroundColor Green
} else {
    Write-Host "  ❌ Erreur lors du déclenchement" -ForegroundColor Red
    Write-Host "  Réponse: $response" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# 5. Attendre la fin
Write-Host "5. Attente de la fin de l'exécution (peut prendre 30-60 secondes)..." -ForegroundColor Yellow
$maxWait = 90
$waited = 0
$interval = 5

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds $interval
    $waited += $interval
    
    $statusJson = docker exec openmetadata-ingestion sh -lc "curl -s -u admin:admin http://localhost:8080/api/v1/dags/$dagId/dagRuns/$runId"
    
    if ($statusJson -match '"state"') {
        $status = $statusJson | ConvertFrom-Json
        $state = $status.state
        
        if ($state -eq "success") {
            Write-Host "  ✅ Ingestion terminée avec succès" -ForegroundColor Green
            break
        } elseif ($state -eq "failed") {
            Write-Host "  ❌ Ingestion échouée" -ForegroundColor Red
            Write-Host "  Consultez les logs pour plus de détails" -ForegroundColor Yellow
            break
        } else {
            Write-Host "  ⏳ État: $state (attente: ${waited}s)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ⏳ En cours... (attente: ${waited}s)" -ForegroundColor Gray
    }
}

Write-Host ""

# 6. Afficher les résultats
Write-Host "6. Résultats de l'ingestion:" -ForegroundColor Yellow
Write-Host ""
docker exec openmetadata-ingestion sh -lc "ls -t /opt/airflow/logs/dag_id=$dagId/run_id=*/task_id=ingestion_task/attempt=1.log 2>/dev/null | head -1 | xargs tail -20 | grep -E 'Processed|Updated|Filtered|Success|table|column' -i" 2>$null

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification dans OpenMetadata UI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Ouvrez http://localhost:8585" -ForegroundColor White
Write-Host "2. Allez dans Explore > Databases > MDM Clinique Hub" -ForegroundColor White
Write-Host "3. Cliquez sur une table (ex: mdm_patient)" -ForegroundColor White
Write-Host "4. Vérifiez l'onglet Schema - les colonnes devraient être visibles" -ForegroundColor White
Write-Host ""

