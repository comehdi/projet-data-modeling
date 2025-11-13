# Corriger l'erreur de Lineage : "Number of Hits: 0"

## Problème

Lors de la création d'un lineage entre Airflow et PostgreSQL, vous obtenez :
```
Issue in Search Entity By Key: fqnHash.keyword, Value Fqn: MDM Airflow Pipeline Service, Number of Hits: 0
```

**Cause** : OpenMetadata ne trouve pas le service Pipeline dans Elasticsearch, probablement à cause d'un problème d'indexation ou d'un nom incorrect.

## Solutions

### Solution 1 : Vérifier le nom exact du service

1. **Ouvrez OpenMetadata** : http://localhost:8585
2. Allez dans **Settings** > **Services** > **Pipelines**
3. Vérifiez le **nom exact** de votre service Pipeline
4. Notez le nom exact (il peut être légèrement différent de ce que vous pensez)

### Solution 2 : Réindexer Elasticsearch

Si le service existe mais n'est pas trouvé dans Elasticsearch :

#### Option A : Redémarrer les services (Simple)

```powershell
# Redémarrer Elasticsearch
docker-compose --profile openmetadata restart elasticsearch

# Attendre 20 secondes
Start-Sleep -Seconds 20

# Redémarrer OpenMetadata Server pour réindexer
docker-compose --profile openmetadata restart openmetadata-server

# Attendre 30 secondes
Start-Sleep -Seconds 30
```

#### Option B : Forcer la réindexation via l'API (Avancé)

```powershell
# Obtenir un token d'authentification (si nécessaire)
# Puis appeler l'API de réindexation
```

### Solution 3 : Recréer le service Pipeline

Si le problème persiste, recréez le service :

1. **Supprimer l'ancien service** :
   - Settings > Services > Pipelines
   - Trouvez votre service
   - Cliquez sur **"Delete"**

2. **Créer un nouveau service** :
   - **Add New Service** > **Airflow**
   - **Name** : `MDM Airflow Pipeline Service` (utilisez exactement ce nom)
   - **Host and Port** : `openmetadata-ingestion:8080`
   - **Username** : `admin`
   - **Password** : `admin`
   - **Test Connection** > **Save**

3. **Attendre la découverte** :
   - Allez dans **Explore** > **Pipelines**
   - Vous devriez voir les DAGs Airflow
   - Attendez 1-2 minutes pour que le service soit indexé

### Solution 4 : Créer le Lineage correctement

Le lineage dans OpenMetadata se crée généralement de deux façons :

#### Méthode 1 : Via les DAGs Airflow (Automatique)

Si vos DAGs Airflow utilisent des opérateurs qui se connectent à PostgreSQL, le lineage peut être détecté automatiquement :

1. **Vérifiez que les DAGs sont ingérés** :
   - Explore > Pipelines
   - Vous devriez voir `mdm_pipeline` et d'autres DAGs

2. **Vérifiez le lineage automatique** :
   - Cliquez sur un DAG (ex: `mdm_pipeline`)
   - Onglet **"Lineage"**
   - Le lineage devrait apparaître automatiquement si les connexions sont détectées

#### Méthode 2 : Via l'interface Lineage (Manuel)

1. **Ouvrez une table** :
   - Explore > Databases > MDM Clinique Hub > mdm_clinique > public
   - Cliquez sur une table (ex: `mdm_patient`)

2. **Onglet Lineage** :
   - Cliquez sur l'onglet **"Lineage"**
   - Cliquez sur **"Add Edge"** ou **"Connect"**

3. **Sélectionner le Pipeline** :
   - Dans le champ de recherche, tapez le nom de votre DAG (ex: `mdm_pipeline`)
   - Ou cherchez par service : `MDM Airflow Pipeline Service`
   - Sélectionnez le DAG ou la tâche

4. **Définir la relation** :
   - Sélectionnez le type de relation (ex: "Produces", "Consumes")
   - Cliquez sur **"Save"**

### Solution 5 : Vérifier que les DAGs sont bien ingérés

Pour que le lineage fonctionne, les DAGs doivent être ingérés :

1. **Vérifiez les DAGs** :
   - Explore > Pipelines
   - Vous devriez voir vos DAGs Airflow

2. **Si les DAGs ne sont pas visibles** :
   - Settings > Services > Pipelines > [Votre Service]
   - Vérifiez que la connexion fonctionne (Test Connection)
   - Les DAGs devraient être découverts automatiquement

## Vérification

### 1. Vérifier que le service existe dans Elasticsearch

```powershell
docker exec openmetadata-elasticsearch curl -s "http://localhost:9200/pipeline_service_search_index/_search?q=*&pretty" | Select-String -Pattern "name|fullyQualifiedName"
```

### 2. Vérifier que les DAGs sont indexés

```powershell
docker exec openmetadata-elasticsearch curl -s "http://localhost:9200/pipeline_search_index/_search?q=*&pretty" | Select-String -Pattern "name|service"
```

### 3. Vérifier dans l'UI OpenMetadata

- **Settings** > **Services** > **Pipelines** : Le service devrait être listé
- **Explore** > **Pipelines** : Les DAGs devraient être visibles

## Dépannage

### Le service n'apparaît toujours pas

1. **Vérifiez les logs** :
   ```powershell
   docker logs openmetadata-server --tail 100 | Select-String -Pattern "pipeline|elasticsearch|index"
   ```

2. **Vérifiez Elasticsearch** :
   ```powershell
   docker exec openmetadata-elasticsearch curl -s "http://localhost:9200/_cluster/health?pretty"
   ```

3. **Réinitialisez Elasticsearch** (dernier recours) :
   - ⚠️ Cela supprimera toutes les données indexées
   - Vous devrez réingérer tous les services

### Le lineage ne se crée pas

1. **Vérifiez que les deux entités existent** :
   - La table PostgreSQL doit être ingérée
   - Le DAG Airflow doit être ingéré

2. **Utilisez le FQN complet** :
   - Pour une table : `MDM Clinique Hub 1.1.mdm_clinique.public.mdm_patient`
   - Pour un DAG : `MDM Airflow Pipeline Service.mdm_pipeline`

3. **Créez le lineage manuellement** :
   - Via l'onglet Lineage de la table
   - Ou via l'onglet Lineage du DAG

## Résumé

1. **Vérifiez le nom exact** du service Pipeline
2. **Redémarrez Elasticsearch et OpenMetadata Server** pour réindexer
3. **Recréez le service** si nécessaire
4. **Créez le lineage** via l'interface Lineage
5. **Vérifiez** que les DAGs et tables sont bien ingérés

Le problème vient généralement d'un problème d'indexation Elasticsearch ou d'un nom de service incorrect.

