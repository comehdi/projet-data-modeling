# Données Sources MDM - Phase 3.1

Ce dossier contient les données sources "messy" (sales) générées pour simuler les systèmes d'information hétérogènes des 3 cliniques (A, B, C) du Groupe Santé Horizon.

## Structure

```
data/
├── patient/          # Données patients (Membre 1)
│   ├── generate_patient_data.py
│   ├── clinique_A_patients.csv
│   ├── clinique_B_patients.csv
│   └── clinique_C_patients.csv
├── praticien/        # Données praticiens (Membre 2)
│   ├── generate_praticien_data.py
│   ├── clinique_A_praticiens.csv
│   ├── clinique_B_praticiens.csv
│   └── clinique_C_praticiens.csv
├── service/          # Données services (Membre 3)
│   ├── generate_service_data.py
│   ├── clinique_A_services.csv
│   ├── clinique_B_services.csv
│   └── clinique_C_services.csv
└── location/         # Données localisations (Membre 4)
    ├── generate_location_data.py
    ├── clinique_A_locations.csv
    ├── clinique_B_locations.csv
    └── clinique_C_locations.csv
```

## Caractéristiques des données "Messy"

Les fichiers CSV générés incluent intentionnellement :

- **Formats différents** : dates (DD-MM-YYYY, YYYY/MM/DD, etc.), téléphones (avec/sans indicatif, espaces, etc.)
- **Valeurs manquantes** : NULL, chaînes vides, espaces
- **Doublons** : mêmes personnes/services dans plusieurs fichiers avec des informations différentes
- **Incohérences** : orthographes différentes, abréviations, majuscules/minuscules
- **Données réalistes** : noms français, adresses françaises, spécialités médicales réelles

## Génération des données

Pour générer les données, exécutez les scripts Python :

```bash
# Générer les données patients
cd data/patient
python generate_patient_data.py

# Générer les données praticiens
cd ../praticien
python generate_praticien_data.py

# Générer les données services
cd ../service
python generate_service_data.py

# Générer les données localisations
cd ../location
python generate_location_data.py
```

Ou depuis la racine du projet :

```bash
python data/patient/generate_patient_data.py
python data/praticien/generate_praticien_data.py
python data/service/generate_service_data.py
python data/location/generate_location_data.py
```

## Notes importantes

- Les scripts utilisent un seed pour la reproductibilité
- Certains patients/praticiens apparaissent dans plusieurs fichiers (doublons intentionnels)
- Les formats varient entre les cliniques pour simuler des systèmes hétérogènes
- Les données sont générées de manière réaliste mais sont fictives

