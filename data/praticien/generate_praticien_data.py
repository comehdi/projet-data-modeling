#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de génération de données praticiens pour Phase 3.1
Génère 3 fichiers CSV avec des données "messy" pour simuler les systèmes hétérogènes
des 3 cliniques du Groupe Santé Horizon.
"""

import csv
import random
from typing import List, Dict

# Seed pour reproductibilité
random.seed(43)

PRENOMS_PRATICIENS = [
    "Jean", "Marie", "Pierre", "Sophie", "Michel", "Catherine", "Philippe", "Isabelle",
    "Alain", "Françoise", "Bernard", "Monique", "Daniel", "Nathalie", "Patrick", "Sylvie",
    "Claude", "Martine", "Laurent", "Valérie", "Stéphane", "Sandrine", "Nicolas", "Céline"
]

NOMS_PRATICIENS = [
    "Martin", "Bernard", "Dubois", "Thomas", "Robert", "Richard", "Petit", "Durand",
    "Leroy", "Moreau", "Simon", "Laurent", "Lefebvre", "Michel", "Garcia", "David",
    "Bertrand", "Roux", "Vincent", "Fournier", "Morel", "Girard", "André", "Lefevre"
]

SPECIALITES = [
    "Cardiologie", "Dermatologie", "Endocrinologie", "Gastro-entérologie",
    "Gynécologie", "Hématologie", "Neurologie", "Oncologie", "Ophtalmologie",
    "Orthopédie", "Pédiatrie", "Pneumologie", "Psychiatrie", "Radiologie",
    "Rhumatologie", "Urologie", "Chirurgie générale", "Anesthésie", "Urgences"
]

STATUTS = ["actif", "inactif", "en mission", "congé", "vacances"]
DEPARTEMENTS = [
    "Cardiologie", "Urgences", "Chirurgie", "Médecine générale", "Pédiatrie",
    "Radiologie", "Laboratoire", "Bloc opératoire", "Soins intensifs"
]

# Praticiens qui apparaîtront dans plusieurs fichiers (doublons intentionnels)
DOUBLONS_PRATICIENS = [
    {
        "nom": "Martin",
        "prenom": "Jean",
        "specialite": "Cardiologie",
        "variations": [
            {"nom": "Martin", "prenom": "Jean", "specialite": "Cardiologie"},
            {"nom": "MARTIN", "prenom": "JEAN", "specialite": "Cardiologie"},
            {"nom": "Martin", "prenom": "J.", "specialite": "Cardio"}
        ]
    },
    {
        "nom": "Dubois",
        "prenom": "Marie",
        "specialite": "Pédiatrie",
        "variations": [
            {"nom": "Dubois", "prenom": "Marie", "specialite": "Pédiatrie"},
            {"nom": "DUBOIS", "prenom": "marie", "specialite": "Pédiatrie"}
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


def generate_email(nom: str, prenom: str, clinique: str) -> str:
    """Génère un email professionnel"""
    domains = {
        "A": "clinique-a.fr",
        "B": "clinique-b.com",
        "C": "clinique-c.fr"
    }
    return f"{prenom.lower()}.{nom.lower()}@{domains[clinique]}"


def generate_praticien_clinique_a(num_praticiens: int = 30) -> List[Dict]:
    """Génère les données praticiens pour la Clinique A"""
    praticiens = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_PRATICIENS:
        variation = doublon["variations"][0]
        praticiens.append({
            "id": f"DOC-{random.randint(100, 999)}",
            "nom": variation["nom"],
            "prenom": variation["prenom"],
            "specialite": variation["specialite"],
            "tel": generate_phone_clinique_a(),
            "email": generate_email(variation["nom"], variation["prenom"], "A"),
            "statut": random.choice(["actif", "en mission"])
        })
    
    # Générer les autres praticiens
    for i in range(num_praticiens - len(DOUBLONS_PRATICIENS)):
        prenom = random.choice(PRENOMS_PRATICIENS)
        nom = random.choice(NOMS_PRATICIENS)
        specialite = random.choice(SPECIALITES)
        
        tel = generate_phone_clinique_a() if random.random() > 0.1 else ""
        email = generate_email(nom, prenom, "A") if random.random() > 0.15 else ""
        statut = random.choice(STATUTS)
        
        praticiens.append({
            "id": f"DOC-{random.randint(100, 999)}",
            "nom": nom,
            "prenom": prenom,
            "specialite": specialite,
            "tel": tel,
            "email": email,
            "statut": statut
        })
    
    return praticiens


def generate_praticien_clinique_b(num_praticiens: int = 28) -> List[Dict]:
    """Génère les données praticiens pour la Clinique B"""
    praticiens = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_PRATICIENS:
        variation = doublon["variations"][1] if len(doublon["variations"]) > 1 else doublon["variations"][0]
        praticiens.append({
            "id": f"MED-{random.randint(10, 99)}",
            "nom": variation["nom"],
            "prenom": variation["prenom"],
            "specialite_medicale": variation["specialite"],
            "telephone": generate_phone_clinique_b() if random.random() > 0.15 else None,
            "email_pro": generate_email(variation["nom"], variation["prenom"], "B") if random.random() > 0.1 else None,
            "status": random.choice(["actif", "inactif"])
        })
    
    # Générer les autres praticiens
    for i in range(num_praticiens - len(DOUBLONS_PRATICIENS)):
        prenom = random.choice(PRENOMS_PRATICIENS)
        nom = random.choice(NOMS_PRATICIENS)
        specialite = random.choice(SPECIALITES)
        
        tel = generate_phone_clinique_b() if random.random() > 0.15 else (None if random.random() > 0.5 else "")
        email = generate_email(nom, prenom, "B") if random.random() > 0.1 else (None if random.random() > 0.3 else "")
        statut = random.choice(STATUTS)
        
        praticiens.append({
            "id": f"MED-{random.randint(10, 99)}",
            "nom": nom,
            "prenom": prenom,
            "specialite_medicale": specialite,
            "telephone": tel,
            "email_pro": email,
            "status": statut
        })
    
    return praticiens


def generate_praticien_clinique_c(num_praticiens: int = 32) -> List[Dict]:
    """Génère les données praticiens pour la Clinique C"""
    praticiens = []
    
    # Ajouter les doublons
    for doublon in DOUBLONS_PRATICIENS:
        variation = doublon["variations"][-1]
        praticiens.append({
            "id": f"{random.randint(1000, 9999)}",
            "nom": variation["nom"],
            "prenom": variation["prenom"],
            "specialite": variation["specialite"],
            "telephone": generate_phone_clinique_c() if random.random() > 0.1 else "",
            "email": generate_email(variation["nom"], variation["prenom"], "C") if random.random() > 0.1 else "",
            "etat": random.choice(["actif", "inactif", "en mission"])
        })
    
    # Générer les autres praticiens
    for i in range(num_praticiens - len(DOUBLONS_PRATICIENS)):
        prenom = random.choice(PRENOMS_PRATICIENS)
        nom = random.choice(NOMS_PRATICIENS)
        specialite = random.choice(SPECIALITES)
        
        # Parfois en majuscules
        nom_display = nom.upper() if random.random() > 0.7 else nom
        prenom_display = prenom.upper() if random.random() > 0.7 else prenom
        
        tel = generate_phone_clinique_c() if random.random() > 0.1 else ""
        email = generate_email(nom, prenom, "C") if random.random() > 0.1 else ""
        statut = random.choice(STATUTS)
        
        praticiens.append({
            "id": f"{random.randint(1000, 9999)}",
            "nom": nom_display,
            "prenom": prenom_display,
            "specialite": specialite,
            "telephone": tel,
            "email": email,
            "etat": statut
        })
    
    return praticiens


def write_csv(filename: str, praticiens: List[Dict], fieldnames: List[str]):
    """Écrit les données dans un fichier CSV"""
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for praticien in praticiens:
            row = {k: (v if v is not None else "") for k, v in praticien.items()}
            writer.writerow(row)
    print(f"✓ {filename} créé avec {len(praticiens)} praticiens")


def main():
    """Fonction principale"""
    print("=" * 60)
    print("Génération des données praticiens - Phase 3.1")
    print("=" * 60)
    print()
    
    print("Génération des données Clinique A...")
    praticiens_a = generate_praticien_clinique_a(30)
    write_csv("clinique_A_praticiens.csv", praticiens_a,
              ["id", "nom", "prenom", "specialite", "tel", "email", "statut"])
    
    print("\nGénération des données Clinique B...")
    praticiens_b = generate_praticien_clinique_b(28)
    write_csv("clinique_B_praticiens.csv", praticiens_b,
              ["id", "nom", "prenom", "specialite_medicale", "telephone", "email_pro", "status"])
    
    print("\nGénération des données Clinique C...")
    praticiens_c = generate_praticien_clinique_c(32)
    write_csv("clinique_C_praticiens.csv", praticiens_c,
              ["id", "nom", "prenom", "specialite", "telephone", "email", "etat"])
    
    print("\n" + "=" * 60)
    print("✅ Génération terminée !")
    print("=" * 60)


if __name__ == "__main__":
    main()

