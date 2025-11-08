#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script maître pour générer toutes les données MDM
Exécute tous les scripts de génération pour créer tous les fichiers CSV
"""

import os
import sys
import subprocess

def run_script(script_path, description):
    """Exécute un script Python et affiche le résultat"""
    print(f"\n{'='*60}")
    print(f"{description}")
    print(f"{'='*60}")
    
    try:
        result = subprocess.run(
            [sys.executable, script_path],
            cwd=os.path.dirname(script_path),
            check=True,
            capture_output=True,
            text=True
        )
        print(result.stdout)
        if result.stderr:
            print("Avertissements:", result.stderr)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Erreur lors de l'exécution de {script_path}")
        print(f"Code de retour: {e.returncode}")
        print(f"Sortie: {e.stdout}")
        print(f"Erreur: {e.stderr}")
        return False
    except FileNotFoundError:
        print(f"❌ Script non trouvé: {script_path}")
        return False


def main():
    """Fonction principale"""
    print("=" * 60)
    print("Génération de toutes les données MDM - Phase 3.1")
    print("=" * 60)
    
    # Définir les chemins des scripts
    base_dir = os.path.dirname(os.path.abspath(__file__))
    
    scripts = [
        (os.path.join(base_dir, "patient", "generate_patient_data.py"), 
         "Génération des données Patients"),
        (os.path.join(base_dir, "praticien", "generate_praticien_data.py"),
         "Génération des données Praticiens"),
        (os.path.join(base_dir, "service", "generate_service_data.py"),
         "Génération des données Services"),
        (os.path.join(base_dir, "location", "generate_location_data.py"),
         "Génération des données Localisations")
    ]
    
    results = []
    for script_path, description in scripts:
        success = run_script(script_path, description)
        results.append((description, success))
    
    # Résumé
    print("\n" + "=" * 60)
    print("Résumé de la génération")
    print("=" * 60)
    
    for description, success in results:
        status = "✅ Réussi" if success else "❌ Échoué"
        print(f"{status}: {description}")
    
    all_success = all(success for _, success in results)
    
    if all_success:
        print("\n" + "=" * 60)
        print("✅ Toutes les données ont été générées avec succès !")
        print("=" * 60)
        print("\nFichiers créés dans les dossiers respectifs :")
        print("  - data/patient/ : 3 fichiers CSV")
        print("  - data/praticien/ : 3 fichiers CSV")
        print("  - data/service/ : 3 fichiers CSV")
        print("  - data/location/ : 3 fichiers CSV")
        print("\nTotal : 12 fichiers CSV prêts pour le Data Wrangling !")
    else:
        print("\n" + "=" * 60)
        print("⚠️  Certaines générations ont échoué. Vérifiez les erreurs ci-dessus.")
        print("=" * 60)
        sys.exit(1)


if __name__ == "__main__":
    main()

