# Guide de Dépannage Complet - Projet MDM

Ce guide répertorie tous les problèmes courants rencontrés lors de l'installation et de l'utilisation du projet MDM, avec leurs solutions.

## 📋 Table des matières

1. [Erreurs de connexion OpenMetadata](#erreurs-de-connexion-openmetadata)
2. [Erreurs PostgreSQL](#erreurs-postgresql)
3. [Erreurs Airflow](#erreurs-airflow)
4. [Erreurs d'ingestion OpenMetadata](#erreurs-dingestion-openmetadata)
5. [Erreurs Elasticsearch](#erreurs-elasticsearch)
6. [Erreurs de Pipeline Service](#erreurs-de-pipeline-service)
7. [Tables vides dans OpenMetadata](#tables-vides-dans-openmetadata)
8. [Erreurs de DAG Airflow](#erreurs-de-dag-airflow)
9. [Problèmes de services Docker](#problèmes-de-services-docker)

## Erreurs de connexion OpenMetadata

### Erreur : "Failed to trigger workflow due to airflow API returned Internal Server Error" avec "Connection refused" sur `localhost:8585`

**Symptôme** :
```
Failed to trigger workflow due to airflow API returned Internal Server Error and response {"error": "Error running automation workflow due to [HTTPConnectionPool(host='localhost', port=8585): Max retries exceeded with url: /api/v1/system/version (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7c3fd2310700>: Failed to establish a new connection: [Errno 111] Connection refused'))] "}
```

**Cause** : L'Airflow d'ingestion essaie de se connecter au serveur OpenMetadata via `localhost:8585` au lieu d'utiliser le nom du conteneur Docker (`openmetadata-server:8585`).

**Solution** : Vérifiez que la variable d'environnement `SERVER_HOST_API_URL` est configurée dans `openmetadata-server` :

```bash
# Vérifier la configuration
docker exec openmetadata-server env | grep SERVER_HOST_API_URL
```

Vous devriez voir :
```
SERVER_HOST_API_URL=http://openmetadata-server:8585/api
```

Si ce n'est pas le cas, redémarrez le conteneur :

```bash
docker-compose --profile openmetadata restart openmetadata-server
```

**Documentation détaillée** : Voir [Configuration OpenMetadata](03-openmetadata-options.md#erreur-failed-to-trigger-workflow-due-to-airflow-api-returned-internal-server-error)

### Erreur : "Failed to connect to Airflow"

**Symptôme** :
```
Failed to connect to Airflow due to java.net.ConnectException. Is the host available at http://openmetadata-ingestion:8080?
```

**Cause** : Le service `openmetadata-ingestion` n'est pas démarré ou la base de données Airflow n'est pas initialisée.

**Solution** :

1. **Vérifier que le service est démarré** :
```bash
docker ps | grep openmetadata-ingestion
```

2. **Initialiser la base de données Airflow** :
```powershell
# Windows
.\scripts\init-openmetadata-airflow.ps1

# Linux/Mac
./scripts/init-openmetadata-airflow.sh
```

3. **Redémarrer le service** :
```bash
docker-compose --profile openmetadata restart openmetadata-ingestion
```

**Documentation détaillée** : Voir [Configuration OpenMetadata](03-openmetadata-options.md#erreur-failed-to-connect-to-airflow)

## Erreurs PostgreSQL

### Erreur : "Failed to fetch queries, please validate if postgres instance has pg_stat_statements extension installed"

**Symptôme** :
```
Failed to fetch queries, please validate if postgres instance has pg_stat_statements extension installed and the user has at least select privileges for pg_stat_statements table.
```

**Cause** : L'extension `pg_stat_statements` n'est pas activée dans PostgreSQL.

**Solution** : L'extension est automatiquement configurée dans `docker-compose.yml` pour `postgres-mdm-hub`. Si vous avez des problèmes :

1. **Vérifier que l'extension est installée** :
```bash
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "SELECT extname, extversion FROM pg_extension WHERE extname = 'pg_stat_statements';"
```

2. **Vérifier que shared_preload_libraries contient pg_stat_statements** :
```bash
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "SHOW shared_preload_libraries;"
```

3. **Redémarrer PostgreSQL si nécessaire** :
```bash
docker-compose restart postgres-mdm-hub
```

**Documentation détaillée** : Voir [Configuration OpenMetadata](03-openmetadata-options.md#erreur-failed-to-fetch-queries-please-validate-if-postgres-instance-has-pg_stat_statements-extension-installed)

### Erreur : "Connection refused" à PostgreSQL

**Symptôme** : Impossible de se connecter à PostgreSQL depuis OpenMetadata.

**Solution** :

1. **Vérifier que PostgreSQL est démarré** :
```bash
docker ps | grep postgres-mdm-hub
```

2. **Vérifier la configuration dans OpenMetadata** :
   - Host : `postgres-mdm-hub` (nom du conteneur Docker, pas `localhost`)
   - Port : `5432` (port interne Docker)
   - Database : `mdm_clinique`
   - Username : `postgres`
   - Password : `root`

3. **Tester la connexion depuis OpenMetadata** :
   - Dans OpenMetadata UI : **Settings** > **Services** > **Databases** > **MDM Clinique Hub** > **Test Connection**

## Erreurs Airflow

### Erreur : "airflow-webserver exited (1)"

**Symptôme** :
```
✘ Container airflow-webserver Error
dependency failed to start: container airflow-webserver exited (1)
```

**Solution** : Voir [Dépannage Airflow](04-depannage-airflow.md#1-erreur-airflow-webserver-exited-1)

### Erreur : "Database is not initialized"

**Solution** :
```bash
# Forcer la réinitialisation
docker-compose --profile init up airflow-init --force-recreate
```

**Documentation détaillée** : Voir [Dépannage Airflow](04-depannage-airflow.md#3-erreur-database-is-not-initialized)

## Erreurs d'ingestion OpenMetadata

### Erreur : "No DAG run found"

**Symptôme** :
```
Failed to get last ingestion logs due to {"error": "No DAG run found for e02a3b57-dd5c-4417-a76e-4b59333f1270."}
```

**Cause** : Le pipeline d'ingestion n'a pas été exécuté. Le DAG existe mais aucun run n'a été créé.

**Solution** :

1. **Déclencher manuellement le DAG** :
```bash
# Remplacer <DAG_ID> par l'ID de votre DAG d'ingestion
docker exec openmetadata-ingestion curl -s -u admin:admin -X POST -H 'Content-Type: application/json' -d '{}' http://localhost:8080/api/v1/dags/<DAG_ID>/dagRuns
```

2. **Via l'interface OpenMetadata** :
   - Allez dans **Settings** > **Services** > **Databases** > **MDM Clinique Hub**
   - Cliquez sur l'onglet **"Ingestion Pipelines"**
   - Cliquez sur le pipeline actif
   - Cliquez sur **"Run Now"**

3. **Via l'interface Airflow** :
   - Ouvrez http://localhost:8080
   - Trouvez votre DAG d'ingestion
   - Cliquez sur **"Trigger DAG"**

**Documentation détaillée** : Voir [Relancer ingestion colonnes vides](relancer-ingestion-colonnes-vides.md)

### Erreur : Tables vides sans colonnes

**Symptôme** : Les tables sont visibles dans OpenMetadata mais n'ont pas de colonnes affichées.

**Solution** : Voir [Relancer ingestion colonnes vides](relancer-ingestion-colonnes-vides.md)

### Erreur : Tables vides sans données

**Symptôme** : Les tables ont des colonnes mais pas de données d'échantillonnage (Sample Data).

**Solution** : Voir [Relancer ingestion colonnes vides](relancer-ingestion-colonnes-vides.md#configurer-et-lancer-le-profiler-agent-pour-voir-les-données)

## Erreurs Elasticsearch

### Erreur : "Search failed due to Elasticsearch exception"

**Symptôme** :
```
Search failed due to Elasticsearch exception [type=search_phase_execution_exception, reason=all shards failed]
```

**Solution** :

1. **Redémarrer Elasticsearch** :
```bash
docker-compose --profile openmetadata restart elasticsearch
Start-Sleep -Seconds 20
```

2. **Redémarrer OpenMetadata Server** :
```bash
docker-compose --profile openmetadata restart openmetadata-server
Start-Sleep -Seconds 30
```

**Documentation détaillée** : Voir [Corriger Elasticsearch et Service](corriger-elasticsearch-et-service.md)

## Erreurs de Pipeline Service

### Erreur : "relation serialized_dag does not exist"

**Symptôme** :
```
(psycopg2.errors.UndefinedTable) relation "serialized_dag" does not exist
```

**Cause** : Vous avez configuré **PostgreSQL** comme **Pipeline Service** au lieu d'**Airflow**.

**Solution** : Voir [Corriger Pipeline Service](corriger-pipeline-service.md)

### Erreur : "Issue in Search Entity By Key: fqnHash.keyword, Value Fqn: MDM Airflow Pipeline Service, Number of Hits: 0"

**Symptôme** : Impossible de créer un lineage entre Airflow et PostgreSQL.

**Cause** : OpenMetadata ne trouve pas le service Pipeline dans Elasticsearch.

**Solution** : Voir [Corriger Lineage Pipeline Database](corriger-lineage-pipeline-database.md)

### Erreur : DAGs Airflow non visibles dans OpenMetadata

**Symptôme** : Le DAG `mdm_pipeline` est visible dans Airflow (port 8080) mais n'apparaît pas dans OpenMetadata.

**Solution** : Voir [Configurer Pipeline Service](configurer-pipeline-service-openmetadata.md)

## Tables vides dans OpenMetadata

### Tables sans colonnes

**Symptôme** : Les tables sont visibles dans OpenMetadata mais n'ont pas de colonnes affichées.

**Solution** : Voir [Relancer ingestion colonnes vides](relancer-ingestion-colonnes-vides.md#solution-forcer-une-réingestion-complète)

### Tables sans données

**Symptôme** : Les tables ont des colonnes mais pas de données d'échantillonnage (Sample Data).

**Solution** : Voir [Relancer ingestion colonnes vides](relancer-ingestion-colonnes-vides.md#configurer-et-lancer-le-profiler-agent-pour-voir-les-données)

## Erreurs de DAG Airflow

### Erreur : DAG non visible dans Airflow

**Symptôme** : Le DAG `mdm_pipeline` n'apparaît pas dans l'interface Airflow.

**Solution** :

1. **Vérifier que le DAG est dans le bon répertoire** :
```bash
# Vérifier que le fichier existe
docker exec openmetadata-ingestion ls -la /opt/airflow/dags/project_mdm/
```

2. **Vérifier les logs Airflow** :
```bash
docker logs openmetadata-ingestion --tail 100 | grep -i "mdm_pipeline"
```

3. **Vérifier la syntaxe du DAG** :
```bash
# Lancer un test de syntaxe Python
docker exec openmetadata-ingestion python -m py_compile /opt/airflow/dags/project_mdm/mdm_pipeline.py
```

4. **Redémarrer Airflow** :
```bash
docker-compose restart openmetadata-ingestion
```

## Problèmes de services Docker

### Services ne démarrent pas

**Symptôme** : Les services Docker ne démarrent pas ou s'arrêtent immédiatement.

**Solution** :

1. **Vérifier les logs** :
```bash
docker-compose logs -f
```

2. **Vérifier l'état des services** :
```bash
docker-compose ps
```

3. **Vérifier l'utilisation des ressources** :
```bash
docker stats
```

4. **Redémarrer un service spécifique** :
```bash
docker-compose restart <service-name>
```

### Conflits de ports

**Symptôme** : Erreur "port already in use" lors du démarrage des services.

**Solution** :

1. **Identifier le processus qui utilise le port** :
```powershell
# Windows
netstat -ano | findstr :8585

# Linux/Mac
lsof -i :8585
```

2. **Arrêter le processus ou modifier le port dans docker-compose.yml**

3. **Redémarrer les services** :
```bash
docker-compose down
docker-compose up -d
```

### Problèmes de volumes Docker

**Symptôme** : Les données ne persistent pas après redémarrage ou erreur de permissions.

**Solution** :

1. **Vérifier les volumes** :
```bash
docker volume ls
```

2. **Vérifier les permissions** :
```bash
# Windows (PowerShell)
.\scripts\fix-airflow-permissions.ps1

# Linux/Mac
chmod -R 755 airflow/
```

3. **Supprimer et recréer les volumes** (⚠️ supprime les données) :
```bash
docker-compose down -v
docker-compose up -d
```

## Commandes utiles

### Vérifier l'état de tous les services

```bash
docker-compose ps
```

### Voir les logs d'un service

```bash
docker-compose logs -f <service-name>
```

### Redémarrer tous les services

```bash
docker-compose restart
```

### Arrêter tous les services

```bash
docker-compose down
```

### Arrêter et supprimer les volumes (⚠️ supprime les données)

```bash
docker-compose down -v
```

### Vérifier l'utilisation des ressources

```bash
docker stats
```

### Nettoyer les conteneurs arrêtés

```bash
docker container prune
```

### Nettoyer les images non utilisées

```bash
docker image prune -a
```

## Documentation de référence

- [Configuration OpenMetadata](03-openmetadata-options.md)
- [Dépannage Airflow](04-depannage-airflow.md)
- [Relancer ingestion colonnes vides](relancer-ingestion-colonnes-vides.md)
- [Corriger Elasticsearch et Service](corriger-elasticsearch-et-service.md)
- [Corriger Pipeline Service](corriger-pipeline-service.md)
- [Corriger Lineage Pipeline Database](corriger-lineage-pipeline-database.md)
- [Configurer Pipeline Service](configurer-pipeline-service-openmetadata.md)

## Besoin d'aide ?

Si vous ne trouvez pas la solution à votre problème dans ce guide :

1. Vérifiez les logs des services : `docker-compose logs -f <service-name>`
2. Consultez la documentation spécifique pour chaque service
3. Vérifiez que tous les services sont démarrés : `docker-compose ps`
4. Vérifiez l'utilisation des ressources : `docker stats`

