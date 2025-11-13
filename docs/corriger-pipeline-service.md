# Corriger la configuration du Pipeline Service

## Problème

Vous avez configuré **PostgreSQL** comme **Pipeline Service**, ce qui est incorrect. L'erreur indique :
```
relation "serialized_dag" does not exist
```

Cela signifie qu'OpenMetadata cherche les tables Airflow (`serialized_dag`) dans PostgreSQL MDM Hub, mais ces tables n'existent que dans la base de données Airflow.

## Solution : Deux services distincts

Dans OpenMetadata, il faut configurer **deux services différents** :

1. **Database Service (PostgreSQL)** : Pour ingérer les tables et leurs données
2. **Pipeline Service (Airflow)** : Pour découvrir les DAGs Airflow

## Étape 1 : Supprimer la configuration incorrecte

1. Ouvrez http://localhost:8585
2. Allez dans **Settings** > **Services** > **Pipelines**
3. Trouvez le service que vous avez créé avec PostgreSQL
4. Cliquez sur **"Delete"** pour le supprimer

## Étape 2 : Configurer le Database Service (PostgreSQL)

Si vous ne l'avez pas déjà fait :

1. Allez dans **Settings** > **Services** > **Databases**
2. Cliquez sur **"Add New Service"** > **PostgreSQL**
3. Configurez :
   - **Name** : `MDM Clinique Hub`
   - **Description** : `Base de données Master Data Management`
   - **Host and Port** : `postgres-mdm-hub:5432` (nom du conteneur Docker)
   - **Database** : `mdm_clinique`
   - **Username** : `postgres`
   - **Password** : `root`
4. Cliquez sur **"Test Connection"** puis **"Save"**
5. Créez un pipeline d'ingestion pour ingérer les tables

## Étape 3 : Configurer le Pipeline Service (Airflow)

1. Allez dans **Settings** > **Services** > **Pipelines**
2. Cliquez sur **"Add New Service"**
3. **IMPORTANT** : Sélectionnez **"Airflow"** (pas PostgreSQL !)
4. Configurez :
   - **Name** : `MDM Airflow Pipeline Service`
   - **Description** : `Service Pipeline pour découvrir les DAGs MDM`
   - **Host and Port** : `openmetadata-ingestion:8080` (nom du conteneur Docker)
   - **Username** : `admin`
   - **Password** : `admin`
   - **Connection Options** (optionnel) :
     ```
     timeout=10
     ```
5. Cliquez sur **"Test Connection"**
   - Vous devriez voir : ✅ **CheckAccess: Success**
   - ✅ **PipelineDetailsAccess: Success**
   - ✅ **TaskDetailAccess: Success**
6. Cliquez sur **"Save"**

## Étape 4 : Vérifier

1. Allez dans **Explore** > **Pipelines**
   - Vous devriez voir les DAGs Airflow, y compris `mdm_pipeline`
2. Allez dans **Explore** > **Databases** > **MDM Clinique Hub**
   - Vous devriez voir les tables MDM

## Résumé des services

| Type de Service | Nom | Configuration |
|----------------|-----|---------------|
| **Database** | MDM Clinique Hub | `postgres-mdm-hub:5432` / `mdm_clinique` |
| **Pipeline** | MDM Airflow Pipeline Service | `openmetadata-ingestion:8080` (Airflow) |

## Pourquoi cette erreur ?

- **Pipeline Service** doit pointer vers **Airflow** (qui contient les tables `serialized_dag`, `dag`, etc.)
- **Database Service** doit pointer vers **PostgreSQL** (qui contient vos tables MDM)
- Ce sont deux services complètement différents avec des objectifs différents

## Si vous voulez voir les données dans les tables

Pour voir les données (pas seulement les colonnes) dans OpenMetadata :

1. Allez dans **Settings** > **Services** > **Databases** > **MDM Clinique Hub**
2. Cliquez sur l'onglet **"Ingestion Pipelines"**
3. Cliquez sur le pipeline actif > **"Edit"**
4. Dans **"Advanced Configuration"**, activez :
   - ✅ **Generate Sample Data** : `true`
   - **Profile Sample** : `100.0`
5. **Save** > **Run Now**

Après l'ingestion, les données apparaîtront dans l'onglet **"Sample Data"** de chaque table.

