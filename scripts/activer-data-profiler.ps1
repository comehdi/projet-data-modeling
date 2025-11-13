# =====================================================
# Script pour activer le Data Profiler dans OpenMetadata
# Cela permettra d'afficher les données d'échantillon dans l'UI
# =====================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Activation du Data Profiler" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Trouver le fichier de configuration
Write-Host "1. Recherche du fichier de configuration..." -ForegroundColor Yellow
$configFiles = docker exec openmetadata-ingestion sh -lc "ls -t /opt/airflow/dag_generated_configs/*.json 2>/dev/null | head -1"

if ([string]::IsNullOrEmpty($configFiles)) {
    Write-Host "  ❌ Aucun fichier de configuration trouvé" -ForegroundColor Red
    Write-Host "  Vérifiez que vous avez configuré une ingestion dans OpenMetadata UI" -ForegroundColor Yellow
    exit 1
}

$configFile = $configFiles.Trim()
Write-Host "  ✅ Configuration trouvée: $configFile" -ForegroundColor Green
Write-Host ""

# 2. Modifier la configuration pour activer le profiler
Write-Host "2. Activation du Data Profiler..." -ForegroundColor Yellow

$pythonScriptContent = @'
import json
import sys

configPath = sys.argv[1]

# Lire la configuration
with open(configPath, 'r') as f:
    config = json.load(f)

# Activer le profiler dans sourceConfig
if 'sourceConfig' in config and 'config' in config['sourceConfig']:
    sourceConfig = config['sourceConfig']['config']
    
    # Activer le profiler
    sourceConfig['generateSampleData'] = True
    
    # Configurer le profiler (optionnel, valeurs par défaut)
    if 'profileSample' not in sourceConfig:
        sourceConfig['profileSample'] = 100.0  # Profiler 100% des données
    
    if 'tableFilterPattern' not in sourceConfig:
        sourceConfig['tableFilterPattern'] = {
            "includes": ["mdm_.*"]  # Profiler toutes les tables MDM
        }
    
    print('generateSampleData = True')
    print('profileSample = 100.0%')
    print('tableFilterPattern = mdm_.*')

# Forcer l'override pour réingérer avec le profiler
if 'sourceConfig' in config and 'config' in config['sourceConfig']:
    config['sourceConfig']['config']['overrideMetadata'] = True

if 'openMetadataServerConnection' in config:
    config['openMetadataServerConnection']['forceEntityOverwriting'] = True

# Écrire la configuration modifiée
with open(configPath, 'w') as f:
    json.dump(config, f, indent=2)

print('Configuration modifiée avec succès')
'@

# Écrire le script dans un fichier temporaire local
$tempScriptLocal = "$env:TEMP\activate_profiler_$(Get-Random).py"
$pythonScriptContent | Out-File -FilePath $tempScriptLocal -Encoding utf8

# Copier le script dans le conteneur
$tempScript = "/tmp/activate_profiler.py"
docker cp $tempScriptLocal "openmetadata-ingestion:$tempScript"

# Exécuter le script
$result = docker exec openmetadata-ingestion sh -lc "python3 $tempScript $configFile"
Write-Host $result -ForegroundColor Gray

# Nettoyer
docker exec openmetadata-ingestion sh -lc "rm -f $tempScript" 2>$null | Out-Null
Remove-Item -Path $tempScriptLocal -Force -ErrorAction SilentlyContinue

if ($result -match "Configuration modifiée avec succès") {
    Write-Host "  ✅ Data Profiler activé" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Activation effectuée mais vérification incertaine" -ForegroundColor Yellow
}

Write-Host ""

# 3. Trouver le DAG ID
Write-Host "3. Recherche du DAG ID..." -ForegroundColor Yellow
$configFileName = Split-Path -Leaf $configFile
$configBaseName = $configFileName -replace '\.json$', ''
$dagId = $configBaseName

Write-Host "  ✅ DAG ID: $dagId" -ForegroundColor Green
Write-Host ""

# 4. Relancer l'ingestion
Write-Host "4. Relance de l'ingestion avec Data Profiler..." -ForegroundColor Yellow
Write-Host "  (Cela peut prendre 1-2 minutes car le profiler analyse les données)" -ForegroundColor Gray
Write-Host ""

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
Write-Host "5. Attente de la fin de l'exécution (peut prendre 1-2 minutes)..." -ForegroundColor Yellow
$maxWait = 180
$waited = 0
$interval = 10

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
docker exec openmetadata-ingestion sh -lc "ls -t /opt/airflow/logs/dag_id=$dagId/run_id=*/task_id=ingestion_task/attempt=1.log 2>/dev/null | head -1 | xargs tail -25 | grep -E 'Processed|Updated|Filtered|Success|table|column|profile|sample' -i" 2>$null

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vérification dans OpenMetadata UI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Ouvrez http://localhost:8585" -ForegroundColor White
Write-Host "2. Allez dans Explore > Databases > MDM Clinique Hub" -ForegroundColor White
Write-Host "3. Cliquez sur une table (ex: mdm_patient)" -ForegroundColor White
Write-Host "4. Allez dans l'onglet 'Sample Data' ou 'Profiler & Data Quality'" -ForegroundColor White
Write-Host "5. Vous devriez maintenant voir les données d'échantillon" -ForegroundColor White
Write-Host ""
Write-Host "Note: Si l'onglet 'Sample Data' n'apparaît pas, attendez quelques secondes" -ForegroundColor Yellow
Write-Host "      et rafraîchissez la page (F5)" -ForegroundColor Yellow
Write-Host ""

