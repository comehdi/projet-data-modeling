#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de génération de données patients pour Phase 3.1
Génère 3 fichiers CSV avec des données "messy" pour simuler les systèmes hétérogènes
des 3 cliniques du Groupe Santé Horizon.
"""

import csv
import random
from datetime import datetime, timedelta
from typing import List, Dict, Tuple

# Seed pour reproductibilité
random.seed(42)

# Noms et prénoms français réalistes
PRENOMS = [
    "Jean", "Marie", "Pierre", "Sophie", "Michel", "Catherine", "Philippe", "Isabelle",
    "Alain", "Françoise", "Bernard", "Monique", "Daniel", "Nathalie", "Patrick", "Sylvie",
    "Claude", "Martine", "Laurent", "Valérie", "Stéphane", "Sandrine", "Nicolas", "Céline",
    "David", "Julie", "Thomas", "Emilie", "Julien", "Caroline", "Antoine", "Aurélie"
]

NOMS = [
    "Dupont", "Martin", "Bernard", "Dubois", "Thomas", "Robert", "Richard", "Petit",
    "Durand", "Leroy", "Moreau", "Simon", "Laurent", "Lefebvre", "Michel", "Garcia",
    "David", "Bertrand", "Roux", "Vincent", "Fournier", "Morel", "Girard", "André",
    "Lefevre", "Mercier", "Dupuis", "Lambert", "Bonnet", "François", "Martinez", "Legrand"
]

VILLES_FRANCE = [
    ("Paris", "75001"), ("Lyon", "69001"), ("Marseille", "13001"), ("Toulouse", "31000"),
    ("Nice", "06000"), ("Nantes", "44000"), ("Strasbourg", "67000"), ("Montpellier", "34000"),
    ("Bordeaux", "33000"), ("Lille", "59000"), ("Rennes", "35000"), ("Reims", "51100")
]

GROUPES_SANGUINS = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
GENRES = ["M", "F"]

ALLERGIES_COMMUNES = [
    "pénicilline", "aspirine", "iode", "latex", "arachides", "lactose", "gluten",
    "pollen", "acariens", "moules", "crustacés", "œufs", "soja", "sulfamides"
]

# Patients qui apparaîtront dans plusieurs fichiers (doublons intentionnels)
DOUBLONS_PATIENTS = [
    {
        "nom": "Dupont",
        "prenom": "Jean",
        "ddn": "1980-05-01",
        "variations": [
            {"nom": "Dupont", "prenom": "Jean", "ddn": "01-05-1980"},
            {"nom": "Dupond", "prenom": "Jean", "ddn": "1980/05/01"},
            {"nom": "DUPONT", "prenom": "JEAN", "ddn": "01/05/1980"}
        ]
    },
    {
        "nom": "Martin",
        "prenom": "Marie",
        "ddn": "1975-03-15",
        "variations": [
            {"nom": "Martin", "prenom": "Marie", "ddn": "15-03-1975"},
            {"nom": "MARTIN", "prenom": "marie", "ddn": "1975/03/15"},
            {"nom": "MARTIN", "prenom": "MARIE", "ddn": "15/03/1975"}
        ]
    },
    {
        "nom": "Bernard",
        "prenom": "Sophie",
        "ddn": "1990-11-20",
        "variations": [
            {"nom": "Bernard", "prenom": "Sophie", "ddn": "20-11-1990"},
            {"nom": "BERNARD", "prenom": "SOPHIE", "ddn": "1990/11/20"},
            {"nom": "BERNARD", "prenom": "SOPHIE", "ddn": "20/11/1990"}
        ]
    }
]


def generate_phone_clinique_a() -> str:
    """Format téléphone Clinique A : 0612345678"""
    return f"0{random.randint(6, 7)}{random.randint(10000000, 99999999)}"


def generate_phone_clinique_b() -> str:
    """Format téléphone Clinique B : +33 6 12 34 56 78"""
    return f"+33 {random.randint(6, 7)} {random.randint(10, 99)} {random.randint(10, 99)} {random.randint(10, 99)} {random.randint(10, 99)}"


def generate_phone_clinique_c() -> str:
    """Format téléphone Clinique C : 06.12.34.56.78"""
    return f"0{random.randint(6, 7)}.{random.randint(10, 99)}.{random.randint(10, 99)}.{random.randint(10, 99)}.{random.randint(10, 99)}"


def generate_date_clinique_a(birth_date: datetime) -> str:
    """Format date Clinique A : DD-MM-YYYY"""
    return birth_date.strftime("%d-%m-%Y")


def generate_date_clinique_b(birth_date: datetime) -> str:
    """Format date Clinique B : YYYY/MM/DD"""
    return birth_date.strftime("%Y/%m/%d")


def generate_date_clinique_c(birth_date: datetime) -> str:
    """Format date Clinique C : DD/MM/YYYY"""
    return birth_date.strftime("%d/%m/%Y")


def generate_email(nom: str, prenom: str) -> str:
    """Génère un email réaliste"""
    domains = ["gmail.com", "yahoo.fr", "hotmail.fr", "outlook.fr", "free.fr"]
    return f"{prenom.lower()}.{nom.lower()}@{random.choice(domains)}"


def generate_address() -> str:
    """Génère une adresse française réaliste"""
    numero = random.randint(1, 200)
    rues = [
        "rue de la République", "avenue des Champs", "boulevard Saint-Michel",
        "rue Victor Hugo", "avenue Jean Jaurès", "rue de Paris", "place de la Mairie",
        "rue du Commerce", "avenue de la Gare", "rue des Fleurs", "boulevard de la Paix"
    ]
    ville, code_postal = random.choice(VILLES_FRANCE)
    return f"{numero} {random.choice(rues)}, {code_postal} {ville}"


def generate_allergies() -> str:
    """Génère une liste d'allergies"""
    num_allergies = random.choices([0, 1, 2, 3], weights=[30, 40, 25, 5])[0]
    if num_allergies == 0:
        return ""
    allergies = random.sample(ALLERGIES_COMMUNES, num_allergies)
    return ", ".join(allergies)


def generate_patient_clinique_a(num_patients: int = 50) -> List[Dict]:
    """Génère les données patients pour la Clinique A"""
    patients = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_PATIENTS:
        variation = doublon["variations"][0]  # Première variation pour Clinique A
        ddn = datetime.strptime(variation["ddn"], "%d-%m-%Y")
        patients.append({
            "id": f"P-{random.randint(100, 999)}",
            "nom": variation["nom"],
            "prenom": variation["prenom"],
            "ddn": variation["ddn"],
            "tel": generate_phone_clinique_a(),
            "allergies": generate_allergies() if random.random() > 0.3 else ""
        })
    
    # Générer les autres patients
    for i in range(num_patients - len(DOUBLONS_PATIENTS)):
        prenom = random.choice(PRENOMS)
        nom = random.choice(NOMS)
        birth_date = datetime.now() - timedelta(days=random.randint(365*18, 365*90))
        
        # Certains champs peuvent être vides (valeurs manquantes)
        tel = generate_phone_clinique_a() if random.random() > 0.15 else ""
        allergies = generate_allergies() if random.random() > 0.4 else ""
        
        patients.append({
            "id": f"P-{random.randint(100, 999)}",
            "nom": nom,
            "prenom": prenom,
            "ddn": generate_date_clinique_a(birth_date),
            "tel": tel,
            "allergies": allergies
        })
    
    return patients


def generate_patient_clinique_b(num_patients: int = 45) -> List[Dict]:
    """Génère les données patients pour la Clinique B"""
    patients = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_PATIENTS:
        variation = doublon["variations"][1] if len(doublon["variations"]) > 1 else doublon["variations"][0]
        ddn = datetime.strptime(variation["ddn"], "%Y/%m/%d")
        patients.append({
            "id": f"PAT-{random.randint(10, 99)}",
            "nom": variation["nom"],
            "prenom": variation["prenom"],
            "date_naissance": variation["ddn"],
            "telephone": generate_phone_clinique_b() if random.random() > 0.2 else None,
            "infos": generate_allergies() if random.random() > 0.5 else None
        })
    
    # Générer les autres patients
    for i in range(num_patients - len(DOUBLONS_PATIENTS)):
        prenom = random.choice(PRENOMS)
        nom = random.choice(NOMS)
        birth_date = datetime.now() - timedelta(days=random.randint(365*18, 365*90))
        
        # Format différent : parfois NULL, parfois vide
        tel = generate_phone_clinique_b() if random.random() > 0.2 else (None if random.random() > 0.5 else "")
        infos = generate_allergies() if random.random() > 0.4 else (None if random.random() > 0.3 else "")
        
        patients.append({
            "id": f"PAT-{random.randint(10, 99)}",
            "nom": nom,
            "prenom": prenom,
            "date_naissance": generate_date_clinique_b(birth_date),
            "telephone": tel,
            "infos": infos
        })
    
    return patients


def generate_patient_clinique_c(num_patients: int = 55) -> List[Dict]:
    """Génère les données patients pour la Clinique C"""
    patients = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_PATIENTS:
        variation = doublon["variations"][-1]  # Dernière variation pour Clinique C (format DD/MM/YYYY)
        # La date est déjà au bon format pour la clinique C
        patients.append({
            "id": f"{random.randint(1000, 9999)}",
            "nom": variation["nom"],
            "prenom": variation["prenom"],
            "date_naissance": variation["ddn"],
            "telephone": generate_phone_clinique_c() if random.random() > 0.1 else "",
            "allergies_connues": generate_allergies() if random.random() > 0.3 else ""
        })
    
    # Générer les autres patients
    for i in range(num_patients - len(DOUBLONS_PATIENTS)):
        prenom = random.choice(PRENOMS)
        nom = random.choice(NOMS)
        birth_date = datetime.now() - timedelta(days=random.randint(365*18, 365*90))
        
        # Format encore différent
        tel = generate_phone_clinique_c() if random.random() > 0.1 else ""
        allergies = generate_allergies() if random.random() > 0.3 else ""
        
        patients.append({
            "id": f"{random.randint(1000, 9999)}",
            "nom": nom.upper() if random.random() > 0.7 else nom,  # Parfois en majuscules
            "prenom": prenom.upper() if random.random() > 0.7 else prenom,
            "date_naissance": generate_date_clinique_c(birth_date),
            "telephone": tel,
            "allergies_connues": allergies
        })
    
    return patients


def write_csv(filename: str, patients: List[Dict], fieldnames: List[str]):
    """Écrit les données dans un fichier CSV"""
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for patient in patients:
            # Convertir None en chaîne vide pour le CSV
            row = {k: (v if v is not None else "") for k, v in patient.items()}
            writer.writerow(row)
    print(f"✓ {filename} créé avec {len(patients)} patients")


def main():
    """Fonction principale"""
    print("=" * 60)
    print("Génération des données patients - Phase 3.1")
    print("=" * 60)
    print()
    
    # Générer les données pour chaque clinique
    print("Génération des données Clinique A...")
    patients_a = generate_patient_clinique_a(50)
    write_csv("clinique_A_patients.csv", patients_a, 
              ["id", "nom", "prenom", "ddn", "tel", "allergies"])
    
    print("\nGénération des données Clinique B...")
    patients_b = generate_patient_clinique_b(45)
    write_csv("clinique_B_patients.csv", patients_b,
              ["id", "nom", "prenom", "date_naissance", "telephone", "infos"])
    
    print("\nGénération des données Clinique C...")
    patients_c = generate_patient_clinique_c(55)
    write_csv("clinique_C_patients.csv", patients_c,
              ["id", "nom", "prenom", "date_naissance", "telephone", "allergies_connues"])
    
    print("\n" + "=" * 60)
    print("✅ Génération terminée !")
    print("=" * 60)
    print("\nFichiers créés :")
    print("  - clinique_A_patients.csv (format: id,nom,prenom,ddn,tel,allergies)")
    print("  - clinique_B_patients.csv (format: id,nom,prenom,date_naissance,telephone,infos)")
    print("  - clinique_C_patients.csv (format: id,nom,prenom,date_naissance,telephone,allergies_connues)")
    print("\n⚠️  Note: Les fichiers contiennent des doublons intentionnels et des formats différents")


if __name__ == "__main__":
    main()

