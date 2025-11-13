# Solution : Tables vides sans colonnes dans OpenMetadata

## Problème
Les tables sont visibles dans OpenMetadata mais n'ont pas de colonnes affichées.

## Solution : Forcer une réingestion complète

### Méthode 1 : Via l'UI OpenMetadata (Recommandé)

1. **Ouvrez OpenMetadata**
   - URL : http://localhost:8585
   - Email : `admin@open-metadata.org`
   - Password : `admin`

2. **Accédez au pipeline d'ingestion**
   - Allez dans **Settings** > **Services** > **Databases** > **MDM Clinique Hub**
   - Cliquez sur l'onglet **"Ingestion Pipelines"**
   - Cliquez sur le pipeline actif (celui avec le statut "Deployed")

3. **Modifiez la configuration**
   - Cliquez sur **"Edit"** (icône crayon)
   - Dans la section **"Advanced Configuration"**, modifiez :
     - **Override Metadata** : ✅ `true` (au lieu de `false`)
     - **Force Entity Overwriting** : ✅ `true` (au lieu de `false`)
   - Cliquez sur **"Save"**

4. **Relancez l'ingestion**
   - Cliquez sur **"Run Now"** pour relancer l'ingestion
   - Attendez la fin de l'exécution (30-60 secondes)
   - Vous pouvez suivre la progression dans l'onglet **"Runs"**

5. **Vérifiez les résultats**
   - Rafraîchissez la page (F5)
   - Allez dans **Explore** > **Databases** > **MDM Clinique Hub** > **mdm_clinique** > **public**
   - Cliquez sur une table (ex: `mdm_patient`)
   - Vérifiez l'onglet **"Schema"** - les colonnes devraient maintenant être visibles

### Méthode 2 : Via le script PowerShell

```powershell
# Relancer l'ingestion simplement
.\scripts\forcer-reingestion-simple.ps1
```

### Méthode 3 : Via l'API Airflow directement

```powershell
# Déclencher un nouveau run
docker exec openmetadata-ingestion sh -lc "curl -s -u admin:admin -X POST -H 'Content-Type: application/json' -d '{}' http://localhost:8080/api/v1/dags/e02a3b57-dd5c-4417-a76e-4b59333f1270/dagRuns"
```

## Vérification

### Vérifier que les colonnes existent dans PostgreSQL

```powershell
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "SELECT table_name, (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'public' AND table_name = t.table_name) as column_count FROM information_schema.tables t WHERE t.table_schema = 'public' AND t.table_name LIKE 'mdm_%' ORDER BY table_name;"
```

Vous devriez voir :
- `mdm_location` : 12 colonnes
- `mdm_patient` : 12 colonnes
- `mdm_praticien` : 10 colonnes
- `mdm_service` : 10 colonnes

### Vérifier les logs d'ingestion

```powershell
docker exec openmetadata-ingestion sh -lc "ls -t /opt/airflow/logs/dag_id=e02a3b57-dd5c-4417-a76e-4b59333f1270/run_id=*/task_id=ingestion_task/attempt=1.log 2>/dev/null | head -1 | xargs tail -30 | grep -E 'Processed|Updated|Filtered|Success' -i"
```

Vous devriez voir :
- `Processed records: 11` ou plus (tables + colonnes)
- `Success %: 100.0`

## Si le problème persiste

1. **Supprimer et recréer le service**
   - Dans OpenMetadata UI : **Settings** > **Services** > **Databases** > **MDM Clinique Hub**
   - Cliquez sur **"Delete"**
   - Recréez le service avec les mêmes paramètres
   - Relancez l'ingestion

2. **Vérifier les logs du serveur OpenMetadata**
   ```powershell
   docker logs openmetadata-server --tail 100
   ```

3. **Vérifier que les services sont bien démarrés**
   ```powershell
   docker ps --filter "name=openmetadata" --format "table {{.Names}}\t{{.Status}}"
   ```

## Notes importantes

- Les colonnes sont ingérées automatiquement avec les tables si `includeTables: true` est activé
- Si `Processed records: 0`, cela signifie que les tables existent déjà dans OpenMetadata et sont considérées comme à jour
- L'option `Override Metadata: true` force OpenMetadata à réingérer même si les tables existent déjà
- L'option `Force Entity Overwriting: true` force l'écrasement des métadonnées existantes

