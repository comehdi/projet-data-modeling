# Options pour OpenMetadata

Vous avez deux options pour lancer OpenMetadata dans ce projet :

## Option 1 : OpenMetadata intégré dans docker-compose.yml (Recommandé)

OpenMetadata est configuré dans le `docker-compose.yml` principal mais avec un **profil** pour pouvoir le lancer séparément si besoin.

### Démarrer OpenMetadata avec le reste des services

```bash
# Démarrer tous les services SAUF OpenMetadata
docker-compose up -d

# Démarrer OpenMetadata séparément (après initialisation)
docker-compose --profile openmetadata-init up openmetadata-migrate
docker-compose --profile openmetadata up -d openmetadata-server
```

### Avantages
- Tous les services dans le même réseau Docker
- Facilite la connexion entre services
- Gestion centralisée

## Option 2 : OpenMetadata standalone (docker-compose.openmetadata.yml)

Si vous préférez lancer OpenMetadata complètement séparément (comme dans votre TP1), utilisez le fichier `docker-compose.openmetadata.yml`.

### Démarrer OpenMetadata standalone

**Linux/Mac :**
```bash
chmod +x scripts/start-openmetadata.sh
./scripts/start-openmetadata.sh
```

**Windows (PowerShell) :**
```powershell
# Créer le répertoire pour les volumes
mkdir -p docker-volume/db-data-postgres

# Démarrer OpenMetadata
docker-compose -f docker-compose.openmetadata.yml up -d
```

### Arrêter OpenMetadata standalone

```bash
docker-compose -f docker-compose.openmetadata.yml down
```

### Avantages
- Complètement isolé du reste de l'environnement
- Utilise la même configuration que votre TP1
- Peut être lancé indépendamment

## Configuration des identifiants

Dans les deux cas, les identifiants par défaut sont :
- **Email** : `admin@open-metadata.org`
- **Password** : `admin`

## Connexion à la base de données MDM

Pour connecter OpenMetadata à votre base de données MDM (`mdm_clinique`), vous devrez :

1. Accéder à OpenMetadata : http://localhost:8585
2. Aller dans **Settings** > **Services** > **Databases**
3. Ajouter une nouvelle connexion PostgreSQL :
   - **Name** : MDM Clinique
   - **Host** : `postgres-mdm-hub` (si intégré) ou `localhost` (si standalone)
   - **Port** : `5432`
   - **Database** : `mdm_clinique`
   - **Username** : `mdm_user`
   - **Password** : `mdm_password`

## Résolution des conflits de ports

Si vous utilisez les deux options en même temps, vous aurez des conflits de ports. Voici les ports utilisés :

| Service | Port | Conflit possible |
|---------|------|------------------|
| PostgreSQL MDM | 5432 | ✅ Conflit avec OpenMetadata standalone |
| PostgreSQL OpenMetadata (intégré) | 5433 | ❌ Pas de conflit |
| PostgreSQL OpenMetadata (standalone) | 5432 | ✅ Conflit avec PostgreSQL MDM |
| OpenMetadata Server | 8585 | ✅ Conflit si les deux sont lancés |
| Elasticsearch | 9200 | ✅ Conflit si les deux sont lancés |

**Recommandation** : Utilisez une seule option à la fois.

## Dépannage

### Erreur "pull access denied"

Si vous obtenez une erreur de pull d'image, assurez-vous d'être connecté à Docker :
```bash
docker login docker.getcollate.io
```

### Erreur de migration

Si la migration échoue, vous pouvez la relancer :
```bash
# Pour l'option intégrée
docker-compose --profile openmetadata-init up openmetadata-migrate

# Pour l'option standalone
docker-compose -f docker-compose.openmetadata.yml up execute-migrate-all
```

### Vérifier l'état des services

```bash
# Option intégrée
docker-compose ps

# Option standalone
docker-compose -f docker-compose.openmetadata.yml ps
```

