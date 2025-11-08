#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de génération de données services pour Phase 3.1
Génère 3 fichiers CSV avec des données "messy" pour simuler les systèmes hétérogènes
des 3 cliniques du Groupe Santé Horizon.
"""

import csv
import random
from typing import List, Dict

# Seed pour reproductibilité
random.seed(44)

SERVICES = [
    ("CARD-01", "Cardiologie", "Clinique"),
    ("DERM-02", "Dermatologie", "Clinique"),
    ("ENDO-03", "Endocrinologie", "Clinique"),
    ("GAST-04", "Gastro-entérologie", "Clinique"),
    ("GYNE-05", "Gynécologie", "Clinique"),
    ("HEMA-06", "Hématologie", "Clinique"),
    ("NEUR-07", "Neurologie", "Clinique"),
    ("ONCO-08", "Oncologie", "Clinique"),
    ("OPHT-09", "Ophtalmologie", "Clinique"),
    ("ORTH-10", "Orthopédie", "Clinique"),
    ("PEDI-11", "Pédiatrie", "Clinique"),
    ("PNEU-12", "Pneumologie", "Clinique"),
    ("PSYC-13", "Psychiatrie", "Clinique"),
    ("RAD-14", "Radiologie", "Support"),
    ("RHUM-15", "Rhumatologie", "Clinique"),
    ("URO-16", "Urologie", "Clinique"),
    ("CHIR-17", "Chirurgie générale", "Clinique"),
    ("ANES-18", "Anesthésie", "Support"),
    ("URG-19", "Urgences", "Clinique"),
    ("LAB-20", "Laboratoire", "Support"),
    ("ADM-21", "Administration", "Administratif"),
    ("COMPT-22", "Comptabilité", "Administratif"),
    ("RH-23", "Ressources Humaines", "Administratif")
]

RESPONSABLES = [
    "Dr. Martin", "Dr. Dubois", "Dr. Bernard", "Dr. Thomas", "Dr. Robert",
    "Dr. Richard", "Dr. Petit", "Dr. Durand", "Dr. Leroy", "Dr. Moreau"
]

DEPARTEMENTS = [
    "Cardiologie", "Urgences", "Chirurgie", "Médecine générale", "Pédiatrie",
    "Radiologie", "Laboratoire", "Bloc opératoire", "Soins intensifs", "Administration"
]

# Services qui apparaîtront dans plusieurs fichiers (doublons intentionnels)
DOUBLONS_SERVICES = [
    {
        "code": "CARD-01",
        "nom": "Cardiologie",
        "variations": [
            {"code": "CARD-01", "nom": "Cardiologie"},
            {"code": "C001", "nom": "Cardiologie"},
            {"code": "CARD", "nom": "Service de Cardiologie"}
        ]
    },
    {
        "code": "URG-19",
        "nom": "Urgences",
        "variations": [
            {"code": "URG-19", "nom": "Urgences"},
            {"code": "U001", "nom": "Service des Urgences"},
            {"code": "URG", "nom": "URGENCES"}
        ]
    }
]


def generate_phone() -> str:
    """Génère un numéro de téléphone"""
    return f"0{random.randint(1, 5)}{random.randint(10000000, 99999999)}"


def generate_email_service(code: str, clinique: str) -> str:
    """Génère un email pour un service"""
    domains = {
        "A": "clinique-a.fr",
        "B": "clinique-b.com",
        "C": "clinique-c.fr"
    }
    service_name = code.lower().replace("-", "")
    return f"{service_name}@{domains[clinique]}"


def generate_service_clinique_a(num_services: int = 20) -> List[Dict]:
    """Génère les données services pour la Clinique A"""
    services = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_SERVICES:
        variation = doublon["variations"][0]
        code, nom, categorie = next((s[0], s[1], s[2]) for s in SERVICES if s[0] == doublon["code"])
        services.append({
            "code": variation["code"],
            "nom": variation["nom"],
            "departement": random.choice(DEPARTEMENTS),
            "responsable": random.choice(RESPONSABLES),
            "tel": generate_phone(),
            "email": generate_email_service(variation["code"], "A"),
            "categorie": categorie
        })
    
    # Générer les autres services
    services_list = [s for s in SERVICES if s[0] not in [d["code"] for d in DOUBLONS_SERVICES]]
    selected = random.sample(services_list, min(num_services - len(DOUBLONS_SERVICES), len(services_list)))
    
    for code, nom, categorie in selected:
        tel = generate_phone() if random.random() > 0.1 else ""
        email = generate_email_service(code, "A") if random.random() > 0.15 else ""
        
        services.append({
            "code": code,
            "nom": nom,
            "departement": random.choice(DEPARTEMENTS),
            "responsable": random.choice(RESPONSABLES),
            "tel": tel,
            "email": email,
            "categorie": categorie
        })
    
    return services


def generate_service_clinique_b(num_services: int = 18) -> List[Dict]:
    """Génère les données services pour la Clinique B"""
    services = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_SERVICES:
        variation = doublon["variations"][1] if len(doublon["variations"]) > 1 else doublon["variations"][0]
        code, nom, categorie = next((s[0], s[1], s[2]) for s in SERVICES if s[0] == doublon["code"])
        services.append({
            "code_service": variation["code"],
            "nom_service": variation["nom"],
            "dept": random.choice(DEPARTEMENTS),
            "manager": random.choice(RESPONSABLES),
            "telephone": generate_phone() if random.random() > 0.15 else None,
            "email_service": generate_email_service(variation["code"], "B") if random.random() > 0.1 else None,
            "type": categorie
        })
    
    # Générer les autres services
    services_list = [s for s in SERVICES if s[0] not in [d["code"] for d in DOUBLONS_SERVICES]]
    selected = random.sample(services_list, min(num_services - len(DOUBLONS_SERVICES), len(services_list)))
    
    for code, nom, categorie in selected:
        tel = generate_phone() if random.random() > 0.15 else (None if random.random() > 0.5 else "")
        email = generate_email_service(code, "B") if random.random() > 0.1 else (None if random.random() > 0.3 else "")
        
        services.append({
            "code_service": code,
            "nom_service": nom,
            "dept": random.choice(DEPARTEMENTS),
            "manager": random.choice(RESPONSABLES),
            "telephone": tel,
            "email_service": email,
            "type": categorie
        })
    
    return services


def generate_service_clinique_c(num_services: int = 22) -> List[Dict]:
    """Génère les données services pour la Clinique C"""
    services = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_SERVICES:
        variation = doublon["variations"][-1]
        code, nom, categorie = next((s for s in SERVICES if s[0] == doublon["code"]))
        services.append({
            "code": variation["code"],
            "nom": variation["nom"].upper() if random.random() > 0.6 else variation["nom"],
            "departement": random.choice(DEPARTEMENTS),
            "responsable": random.choice(RESPONSABLES),
            "telephone": generate_phone() if random.random() > 0.1 else "",
            "email": generate_email_service(variation["code"], "C") if random.random() > 0.1 else "",
            "categorie": categorie
        })
    
    # Générer les autres services
    services_list = [s for s in SERVICES if s[0] not in [d["code"] for d in DOUBLONS_SERVICES]]
    selected = random.sample(services_list, min(num_services - len(DOUBLONS_SERVICES), len(services_list)))
    
    for code, nom, categorie in selected:
        nom_display = nom.upper() if random.random() > 0.6 else nom
        tel = generate_phone() if random.random() > 0.1 else ""
        email = generate_email_service(code, "C") if random.random() > 0.1 else ""
        
        services.append({
            "code": code,
            "nom": nom_display,
            "departement": random.choice(DEPARTEMENTS),
            "responsable": random.choice(RESPONSABLES),
            "telephone": tel,
            "email": email,
            "categorie": categorie
        })
    
    return services


def write_csv(filename: str, services: List[Dict], fieldnames: List[str]):
    """Écrit les données dans un fichier CSV"""
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for service in services:
            row = {k: (v if v is not None else "") for k, v in service.items()}
            writer.writerow(row)
    print(f"✓ {filename} créé avec {len(services)} services")


def main():
    """Fonction principale"""
    print("=" * 60)
    print("Génération des données services - Phase 3.1")
    print("=" * 60)
    print()
    
    print("Génération des données Clinique A...")
    services_a = generate_service_clinique_a(20)
    write_csv("clinique_A_services.csv", services_a,
              ["code", "nom", "departement", "responsable", "tel", "email", "categorie"])
    
    print("\nGénération des données Clinique B...")
    services_b = generate_service_clinique_b(18)
    write_csv("clinique_B_services.csv", services_b,
              ["code_service", "nom_service", "dept", "manager", "telephone", "email_service", "type"])
    
    print("\nGénération des données Clinique C...")
    services_c = generate_service_clinique_c(22)
    write_csv("clinique_C_services.csv", services_c,
              ["code", "nom", "departement", "responsable", "telephone", "email", "categorie"])
    
    print("\n" + "=" * 60)
    print("✅ Génération terminée !")
    print("=" * 60)


if __name__ == "__main__":
    main()

