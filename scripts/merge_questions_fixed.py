#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de fusion amélioré - Gère les différentes structures JSON
"""

import json
import os
from pathlib import Path

MERGE_MAPPINGS = {
    'mali_history_questions.json': 'enriched_history_questions.json',
    'general_culture_questions.json': 'enriched_culture_questions.json',
    'science_questions.json': 'enriched_science_questions.json',
}

def load_json(file_path):
    """Charge un fichier JSON"""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_json(file_path, data):
    """Sauvegarde un fichier JSON"""
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def extract_questions(data):
    """Extrait les questions quelque soit la structure"""
    questions = []
    
    # Structure 1: {"category": "...", "questions": [...]}
    if isinstance(data, dict) and 'questions' in data:
        return data['questions']
    
    # Structure 2: {"Catégorie": [...]}
    if isinstance(data, dict):
        for key, value in data.items():
            if isinstance(value, list) and value and isinstance(value[0], dict):
                if 'question' in value[0]:
                    return value
    
    # Structure 3: Extraction récursive
    def extract_recursive(obj):
        if isinstance(obj, dict):
            if 'question' in obj and ('answers' in obj or 'options' in obj):
                questions.append(obj)
            else:
                for value in obj.values():
                    extract_recursive(value)
        elif isinstance(obj, list):
            for item in obj:
                extract_recursive(item)
    
    extract_recursive(data)
    return questions

def merge_files(source_file, dest_file, questions_dir):
    """Fusionne deux fichiers"""
    source_path = questions_dir / source_file
    dest_path = questions_dir / dest_file
    
    print(f"\n📝 Fusion: {source_file} → {dest_file}")
    
    # Charger
    source_data = load_json(source_path)
    dest_data = load_json(dest_path)
    
    # Extraire questions
    source_questions = extract_questions(source_data)
    dest_questions = extract_questions(dest_data)
    
    print(f"   📊 Source: {len(source_questions)} questions")
    print(f"   📊 Destination (avant): {len(dest_questions)} questions")
    
    # Fusionner
    all_questions = dest_questions + source_questions
    print(f"   ✅ Total (après): {len(all_questions)} questions")
    
    # Reconstruire - garder la structure de destination
    if isinstance(dest_data, dict):
        # Trouver la clé principale
        main_key = None
        for key, value in dest_data.items():
            if isinstance(value, list):
                main_key = key
                break
        
        if main_key:
            dest_data[main_key] = all_questions
        else:
            dest_data = {list(dest_data.keys())[0]: all_questions}
    
    # Sauvegarder
    save_json(dest_path, dest_data)
    print(f"   💾 Sauvegardé: {dest_file}")
    
    return len(all_questions)

def main():
    print("🔀 FUSION DES QUESTIONS (VERSION CORRIGÉE)")
    print("=" * 70)
    
    questions_dir = Path(__file__).parent.parent / "assets" / "questions"
    
    totals = {}
    for source, dest in MERGE_MAPPINGS.items():
        try:
            total = merge_files(source, dest, questions_dir)
            totals[dest] = total
        except Exception as e:
            print(f"   ❌ Erreur: {e}")
    
    print("\n" + "=" * 70)
    print("📊 NOUVEAUX TOTAUX")
    print("=" * 70)
    for dest, total in totals.items():
        print(f"✅ {dest}: {total} questions")
    
    print("\n✅ Fusion terminée!")
    print("\n🌍 PROCHAINE ÉTAPE: Traduire les nouvelles questions")

if __name__ == "__main__":
    main()



