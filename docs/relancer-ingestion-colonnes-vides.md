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

## Configurer et lancer le Profiler Agent pour voir les données

Maintenant que vos tables sont visibles avec leurs colonnes dans OpenMetadata, vous devez configurer le **Profiler Agent** pour qu'OpenMetadata puisse lire les données (sample data) de vos tables.

### Étape 1 : Vérifier que les tables contiennent des données

Avant de configurer le Profiler Agent, assurez-vous que vos tables PostgreSQL contiennent des données :

```bash
# Se connecter à PostgreSQL
docker exec -it postgres-mdm-hub psql -U postgres -d mdm_clinique

# Vérifier les données dans les tables
SELECT COUNT(*) FROM mdm_patient;
SELECT COUNT(*) FROM mdm_praticien;
SELECT COUNT(*) FROM mdm_service;
SELECT COUNT(*) FROM mdm_location;

# Quitter PostgreSQL
\q
```

Si les tables sont vides, lancez d'abord vos jobs Talend via Airflow pour remplir les tables.

### Étape 2 : Configurer le Profiler Agent dans OpenMetadata

1. **Accéder à OpenMetadata** : http://localhost:8585

2. **Naviguer vers votre service** :
   - Allez dans **Settings** → **Services** → **Databases**
   - Cliquez sur votre service **MDM Clinique Hub**

3. **Accéder à l'onglet Agents** :
   - Cliquez sur l'onglet **Agents** (en haut de la page)

4. **Ajouter un Profiler Agent** :
   - Cliquez sur le bouton bleu **Add Agent** (menu déroulant)
   - Sélectionnez **Add Profiler Agent**

5. **Configurer le Profiler Agent** :
   - **Name** : `mdm_clinique_hub_profiler`
   - **Table Filter Pattern - Includes** : Ajoutez vos 4 tables (tapez le nom, puis "Entrée")
     - `mdm_patient`
     - `mdm_praticien`
     - `mdm_service`
     - `mdm_location`
   - **Data Profiler Options** :
     - **Profile Sample** : Tapez `100` (pour 100 lignes) ou `100%` (pour 100% des données)
     - **Profile Sample Type** : Choisissez **ROWS** (Lignes)
     - **Cochez la case** : **Include Columns**
   - Cliquez sur **Next**

6. **Configurer la planification** :
   - **Schedule Interval** : Choisissez **Day** (Quotidien)
   - Il est logique de le faire tourner après votre job Talend (ex: à 1h00 du matin, si votre job Talend tourne à minuit)
   - Cliquez sur **Add & Deploy**

### Étape 3 : Lancer le Profiler Agent

1. **Retourner à l'onglet Agents** :
   - Vous devriez maintenant voir deux agents :
     - Votre agent d'ingestion (Metadata Ingestion)
     - Votre nouveau Profiler Agent (`mdm_clinique_hub_profiler`)

2. **Lancer le Profiler Agent** :
   - Trouvez votre **mdm_clinique_hub_profiler**
   - Cliquez sur l'icône **▶️ (Run)** pour le lancer immédiatement

3. **Vérifier le statut** :
   - Attendez que le statut passe à **Success**
   - Vous pouvez voir les logs en cliquant sur l'icône de logs

### Étape 4 : Vérifier les données dans OpenMetadata

1. **Naviguer vers vos tables** :
   - Allez dans **Explore** → **Tables**
   - Sélectionnez votre service **MDM Clinique Hub**
   - Cliquez sur une de vos tables (ex: `mdm_patient`)

2. **Vérifier les données** :
   - Allez dans l'onglet **Sample Data**
   - Vous devriez maintenant voir les données de vos tables
   - Vous pouvez également voir les statistiques dans l'onglet **Profiler & Data Quality**

### Résolution des problèmes du Profiler Agent

Si le Profiler Agent échoue :

1. **Vérifier les logs** :
   - Cliquez sur l'icône de logs à côté du Profiler Agent
   - Vérifiez les erreurs dans les logs

2. **Vérifier que les tables contiennent des données** :
   - Utilisez les commandes SQL ci-dessus pour vérifier

3. **Relancer le Profiler Agent** :
   - Cliquez à nouveau sur l'icône **▶️ (Run)**

4. **Vérifier la configuration** :
   - Assurez-vous que le **Table Filter Pattern** est correct
   - Vérifiez que le **Profile Sample** est configuré correctement

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

### Ingestion des métadonnées

- Les colonnes sont ingérées automatiquement avec les tables si `includeTables: true` est activé
- Si `Processed records: 0`, cela signifie que les tables existent déjà dans OpenMetadata et sont considérées comme à jour
- L'option `Override Metadata: true` force OpenMetadata à réingérer même si les tables existent déjà
- L'option `Force Entity Overwriting: true` force l'écrasement des métadonnées existantes

### Profiler Agent

- Le **Profiler Agent** est nécessaire pour générer les **sample data** (données d'échantillonnage) dans OpenMetadata
- L'ingestion des métadonnées (tables et colonnes) et le profilage des données (sample data) sont deux processus distincts
- Le Profiler Agent doit être configuré **après** que les tables contiennent des données dans PostgreSQL
- Le Profiler Agent peut être planifié pour s'exécuter automatiquement (ex: quotidiennement après les jobs Talend)
- Le **Profile Sample** peut être configuré en nombre de lignes (ex: 100) ou en pourcentage (ex: 100%)
- Les statistiques générées par le Profiler Agent sont disponibles dans l'onglet **Profiler & Data Quality** de chaque table

