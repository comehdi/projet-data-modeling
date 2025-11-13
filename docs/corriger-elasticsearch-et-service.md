# Corriger Elasticsearch et retrouver le service Database

## Problème 1 : Erreur Elasticsearch

**Erreur** : `Search failed due to Elasticsearch exception [type=search_phase_execution_exception, reason=all shards failed]`

**Cause** : Elasticsearch est en statut "yellow" avec des shards non assignés. C'est courant avec Elasticsearch en mode single-node.

## Solution pour Elasticsearch

### Option 1 : Redémarrer Elasticsearch (Recommandé)

```powershell
# Redémarrer Elasticsearch
docker-compose --profile openmetadata restart elasticsearch

# Attendre 15-20 secondes
Start-Sleep -Seconds 20

# Vérifier le statut
docker exec openmetadata-elasticsearch curl -s http://localhost:9200/_cluster/health?pretty
```

Le statut devrait passer à "green" ou au moins "yellow" (acceptable pour un single-node).

### Option 2 : Réindexer les données (si le redémarrage ne suffit pas)

Si le problème persiste après le redémarrage :

1. **Redémarrer OpenMetadata Server** pour qu'il se reconnecte à Elasticsearch :
   ```powershell
   docker-compose --profile openmetadata restart openmetadata-server
   ```

2. **Vérifier les logs** :
   ```powershell
   docker logs openmetadata-server --tail 50
   ```

### Option 3 : Réinitialiser Elasticsearch (Dernier recours)

⚠️ **Attention** : Cela supprimera toutes les données indexées dans OpenMetadata. Vous devrez réingérer toutes les métadonnées.

```powershell
# Arrêter Elasticsearch
docker-compose --profile openmetadata stop elasticsearch

# Supprimer le volume Elasticsearch
docker volume rm projet-data-modeling_es-data

# Redémarrer Elasticsearch
docker-compose --profile openmetadata up -d elasticsearch

# Attendre 30 secondes
Start-Sleep -Seconds 30

# Redémarrer OpenMetadata Server
docker-compose --profile openmetadata restart openmetadata-server
```

Après cela, vous devrez réingérer tous vos services (Database, Pipeline, etc.).

## Problème 2 : Service Database non visible dans Explore

**Problème** : Vous avez supprimé "MDM Clinique Hub" et créé "MDM Clinique Hub 1.1", mais il n'apparaît pas dans Explore.

**Cause** : Un service Database doit avoir un **pipeline d'ingestion actif** pour que les tables apparaissent dans Explore.

## Solution pour retrouver le service

### Étape 1 : Vérifier que le service existe

1. Ouvrez http://localhost:8585
2. Allez dans **Settings** > **Services** > **Databases**
3. Vérifiez que **"MDM Clinique Hub 1.1"** (ou le nom que vous avez donné) existe
4. Si non, créez-le :
   - **Add New Service** > **PostgreSQL**
   - **Name** : `MDM Clinique Hub` (ou le nom de votre choix)
   - **Host and Port** : `postgres-mdm-hub:5432`
   - **Database** : `mdm_clinique`
   - **Username** : `postgres`
   - **Password** : `root`
   - **Test Connection** > **Save**

### Étape 2 : Créer un Pipeline d'Ingestion

1. Dans **Settings** > **Services** > **Databases** > **[Votre Service]**
2. Cliquez sur l'onglet **"Ingestion Pipelines"**
3. Cliquez sur **"Add Ingestion Pipeline"**
4. Sélectionnez **"Metadata"** (pour ingérer les tables et colonnes)
5. Cliquez sur **"Next"**

### Étape 3 : Configurer l'Ingestion

1. **Sélection des tables** :
   - Dans **"Table Filter Pattern"**, sélectionnez les tables ou utilisez `mdm_.*`

2. **Configuration avancée** (pour voir les données) :
   - Faites défiler jusqu'à **"Advanced Configuration"**
   - Activez :
     - ✅ **Generate Sample Data** : `true`
     - **Profile Sample** : `100.0`
     - ✅ **Override Metadata** : `true`
     - ✅ **Force Entity Overwriting** : `true`

3. Cliquez sur **"Save"**

### Étape 4 : Lancer l'Ingestion

1. Dans l'onglet **"Ingestion Pipelines"**
2. Cliquez sur le pipeline que vous venez de créer
3. Cliquez sur **"Deploy"** (si nécessaire)
4. Cliquez sur **"Run Now"**
5. Attendez la fin de l'exécution (1-2 minutes)

### Étape 5 : Vérifier dans Explore

1. Allez dans **Explore** > **Databases**
2. Vous devriez maintenant voir votre service (ex: "MDM Clinique Hub 1.1")
3. Cliquez dessus > **mdm_clinique** > **public**
4. Les 4 tables MDM devraient être visibles

## Vérification complète

### 1. Vérifier Elasticsearch

```powershell
# Statut du cluster
docker exec openmetadata-elasticsearch curl -s http://localhost:9200/_cluster/health?pretty

# Devrait afficher "status" : "green" ou "yellow"
```

### 2. Vérifier le service Database

```powershell
# Vérifier que PostgreSQL est accessible
docker exec postgres-mdm-hub psql -U postgres -d mdm_clinique -c "\dt"
```

### 3. Vérifier les pipelines d'ingestion

Dans OpenMetadata UI :
- **Settings** > **Services** > **Databases** > **[Votre Service]**
- Onglet **"Ingestion Pipelines"**
- Devrait afficher au moins un pipeline avec le statut **"Deployed"**

### 4. Vérifier dans Explore

- **Explore** > **Databases**
- Votre service devrait apparaître
- Les tables devraient être visibles

## Dépannage

### Le service n'apparaît toujours pas dans Explore

1. Vérifiez que l'ingestion a réussi (onglet **"Runs"**)
2. Rafraîchissez la page (F5)
3. Vérifiez que le pipeline est **"Deployed"**
4. Vérifiez les logs d'ingestion pour les erreurs

### Elasticsearch reste en erreur

1. Vérifiez les logs :
   ```powershell
   docker logs openmetadata-elasticsearch --tail 100
   ```

2. Vérifiez l'espace disque :
   ```powershell
   docker exec openmetadata-elasticsearch df -h
   ```

3. Augmentez la mémoire si nécessaire (dans `docker-compose.yml`) :
   ```yaml
   environment:
     - ES_JAVA_OPTS=-Xms2048m -Xmx2048m
   ```

### Les tables sont vides

1. Vérifiez que les données existent dans PostgreSQL
2. Relancez l'ingestion avec **Override Metadata: true**
3. Activez **Generate Sample Data: true**

## Résumé

1. **Elasticsearch** : Redémarrer → Vérifier le statut
2. **Service Database** : Créer/Configurer → Pipeline d'ingestion → Lancer
3. **Explore** : Les tables apparaîtront après une ingestion réussie

