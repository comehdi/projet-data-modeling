#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de génération de données localisations pour Phase 3.1
Génère 3 fichiers CSV avec des données "messy" pour simuler les systèmes hétérogènes
des 3 cliniques du Groupe Santé Horizon.
"""

import csv
import random
from typing import List, Dict

# Seed pour reproductibilité
random.seed(45)

SITES = [
    ("Clinique Horizon Paris", "15 rue de la Santé", "75014", "Paris"),
    ("Clinique Horizon Lyon", "42 avenue de la République", "69003", "Lyon"),
    ("Clinique Horizon Marseille", "8 boulevard de la Canebière", "13001", "Marseille")
]

BATIMENTS = ["Bâtiment A", "Bâtiment B", "Bâtiment C", "Bâtiment Principal", "Annexe", "Pavillon Est", "Pavillon Ouest"]
ETAGES = ["RDC", "1er étage", "2ème étage", "3ème étage", "Sous-sol", "Rez-de-chaussée"]
TYPES_LOCALISATION = ["Site", "Unité", "Chambre", "Salle d'opération", "Bureau", "Laboratoire", "Salle d'attente"]

NUMEROS_CHAMBRES = [f"CH-{i:03d}" for i in range(101, 250)]
NUMEROS_SALLES = [f"SO-{i:02d}" for i in range(1, 20)]

# Localisations qui apparaîtront dans plusieurs fichiers (doublons intentionnels)
DOUBLONS_LOCATIONS = [
    {
        "site": "Clinique Horizon Paris",
        "batiment": "Bâtiment A",
        "variations": [
            {"site": "Clinique Horizon Paris", "batiment": "Bâtiment A"},
            {"site": "CLINIQUE HORIZON PARIS", "batiment": "Batiment A"},
            {"site": "Clinique Horizon - Paris", "batiment": "Bât. A"}
        ]
    },
    {
        "site": "Clinique Horizon Lyon",
        "batiment": "Bâtiment Principal",
        "variations": [
            {"site": "Clinique Horizon Lyon", "batiment": "Bâtiment Principal"},
            {"site": "CLINIQUE HORIZON LYON", "batiment": "Batiment Principal"}
        ]
    }
]


def generate_location_clinique_a(num_locations: int = 40) -> List[Dict]:
    """Génère les données localisations pour la Clinique A"""
    locations = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_LOCATIONS:
        variation = doublon["variations"][0]
        site_info = next((s for s in SITES if variation["site"].upper() in s[0].upper()), SITES[0])
        locations.append({
            "id": f"LOC-{random.randint(100, 999)}",
            "site": variation["site"],
            "batiment": variation["batiment"],
            "etage": random.choice(ETAGES),
            "salle": random.choice(NUMEROS_CHAMBRES + NUMEROS_SALLES),
            "adresse": site_info[1],
            "ville": site_info[3],
            "code_postal": site_info[2],
            "type": random.choice(TYPES_LOCALISATION)
        })
    
    # Générer les autres localisations
    for i in range(num_locations - len(DOUBLONS_LOCATIONS)):
        site_info = random.choice(SITES)
        batiment = random.choice(BATIMENTS)
        etage = random.choice(ETAGES) if random.random() > 0.2 else ""
        salle = random.choice(NUMEROS_CHAMBRES + NUMEROS_SALLES) if random.random() > 0.15 else ""
        type_loc = random.choice(TYPES_LOCALISATION)
        
        locations.append({
            "id": f"LOC-{random.randint(100, 999)}",
            "site": site_info[0],
            "batiment": batiment,
            "etage": etage,
            "salle": salle,
            "adresse": site_info[1],
            "ville": site_info[3],
            "code_postal": site_info[2],
            "type": type_loc
        })
    
    return locations


def generate_location_clinique_b(num_locations: int = 38) -> List[Dict]:
    """Génère les données localisations pour la Clinique B"""
    locations = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_LOCATIONS:
        variation = doublon["variations"][1] if len(doublon["variations"]) > 1 else doublon["variations"][0]
        site_info = next((s for s in SITES if variation["site"].upper() in s[0].upper()), SITES[0])
        locations.append({
            "id": f"CH-{random.randint(10, 99)}",
            "nom_site": variation["site"],
            "batiment": variation["batiment"],
            "niveau": random.choice(ETAGES) if random.random() > 0.2 else None,
            "numero": random.choice(NUMEROS_CHAMBRES + NUMEROS_SALLES) if random.random() > 0.15 else None,
            "adresse_complete": f"{site_info[1]}, {site_info[2]} {site_info[3]}",
            "type_localisation": random.choice(TYPES_LOCALISATION)
        })
    
    # Générer les autres localisations
    for i in range(num_locations - len(DOUBLONS_LOCATIONS)):
        site_info = random.choice(SITES)
        batiment = random.choice(BATIMENTS)
        niveau = random.choice(ETAGES) if random.random() > 0.2 else (None if random.random() > 0.5 else "")
        numero = random.choice(NUMEROS_CHAMBRES + NUMEROS_SALLES) if random.random() > 0.15 else (None if random.random() > 0.5 else "")
        type_loc = random.choice(TYPES_LOCALISATION)
        
        locations.append({
            "id": f"CH-{random.randint(10, 99)}",
            "nom_site": site_info[0],
            "batiment": batiment,
            "niveau": niveau,
            "numero": numero,
            "adresse_complete": f"{site_info[1]}, {site_info[2]} {site_info[3]}",
            "type_localisation": type_loc
        })
    
    return locations


def generate_location_clinique_c(num_locations: int = 42) -> List[Dict]:
    """Génère les données localisations pour la Clinique C"""
    locations = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_LOCATIONS:
        variation = doublon["variations"][-1]
        site_info = next((s for s in SITES if variation["site"].upper() in s[0].upper()), SITES[0])
        locations.append({
            "id": f"{random.randint(1000, 9999)}",
            "site": variation["site"].upper() if random.random() > 0.5 else variation["site"],
            "batiment": variation["batiment"],
            "etage": random.choice(ETAGES) if random.random() > 0.2 else "",
            "chambre": random.choice(NUMEROS_CHAMBRES + NUMEROS_SALLES) if random.random() > 0.15 else "",
            "adresse": site_info[1],
            "code_postal": site_info[2],
            "ville": site_info[3],
            "type": random.choice(TYPES_LOCALISATION)
        })
    
    # Générer les autres localisations
    for i in range(num_locations - len(DOUBLONS_LOCATIONS)):
        site_info = random.choice(SITES)
        batiment = random.choice(BATIMENTS)
        etage = random.choice(ETAGES) if random.random() > 0.2 else ""
        chambre = random.choice(NUMEROS_CHAMBRES + NUMEROS_SALLES) if random.random() > 0.15 else ""
        type_loc = random.choice(TYPES_LOCALISATION)
        
        # Parfois en majuscules
        site_display = site_info[0].upper() if random.random() > 0.6 else site_info[0]
        
        locations.append({
            "id": f"{random.randint(1000, 9999)}",
            "site": site_display,
            "batiment": batiment,
            "etage": etage,
            "chambre": chambre,
            "adresse": site_info[1],
            "code_postal": site_info[2],
            "ville": site_info[3],
            "type": type_loc
        })
    
    return locations


def write_csv(filename: str, locations: List[Dict], fieldnames: List[str]):
    """Écrit les données dans un fichier CSV"""
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for location in locations:
            row = {k: (v if v is not None else "") for k, v in location.items()}
            writer.writerow(row)
    print(f"✓ {filename} créé avec {len(locations)} localisations")


def main():
    """Fonction principale"""
    print("=" * 60)
    print("Génération des données localisations - Phase 3.1")
    print("=" * 60)
    print()
    
    print("Génération des données Clinique A...")
    locations_a = generate_location_clinique_a(40)
    write_csv("clinique_A_locations.csv", locations_a,
              ["id", "site", "batiment", "etage", "salle", "adresse", "ville", "code_postal", "type"])
    
    print("\nGénération des données Clinique B...")
    locations_b = generate_location_clinique_b(38)
    write_csv("clinique_B_locations.csv", locations_b,
              ["id", "nom_site", "batiment", "niveau", "numero", "adresse_complete", "type_localisation"])
    
    print("\nGénération des données Clinique C...")
    locations_c = generate_location_clinique_c(42)
    write_csv("clinique_C_locations.csv", locations_c,
              ["id", "site", "batiment", "etage", "chambre", "adresse", "code_postal", "ville", "type"])
    
    print("\n" + "=" * 60)
    print("✅ Génération terminée !")
    print("=" * 60)


if __name__ == "__main__":
    main()

