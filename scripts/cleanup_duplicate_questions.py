#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de nettoyage des questions en doublon
Supprime les doublons des catégories non traduites par rapport aux catégories traduites
"""

import json
import os
from pathlib import Path
from difflib import SequenceMatcher

# Catégories traduites (référence - à garder)
TRANSLATED_CATEGORIES = [
    'enriched_history_questions.json',
    'enriched_culture_questions.json',
    'enriched_science_questions.json',
    'math_questions.json',
    'africa_questions.json',
    'football_questions.json',
    'music_questions.json',
    'arts_culture_questions_expansion.json',
    'politics_economy_questions_expansion.json',
    'technology_questions_expansion.json',
    'health_medicine_questions_expansion.json',
    'environment_questions_expansion.json',
]

# Catégories non traduites (à nettoyer)
UNTRANSLATED_CATEGORIES = [
    'enriched_questions_phase7.json',
    'general_culture_questions.json',
    'massive_extension_phase4.json',
    'phase2_new_categories.json',
    'phase3_advanced_questions.json',
    'premium_questions_phase6.json',
    'questions_extension_phase1.json',
    'science_questions.json',
    'mali_history_questions.json',
]

def normalize_text(text):
    """Normalise le texte pour la comparaison"""
    if not text:
        return ""
    # Enlever espaces multiples, ponctuation finale, et convertir en minuscules
    text = text.strip().lower()
    text = text.rstrip('?.!,;:')
    text = ' '.join(text.split())
    return text

def similarity_ratio(text1, text2):
    """Calcule la similarité entre deux textes (0-1)"""
    return SequenceMatcher(None, normalize_text(text1), normalize_text(text2)).ratio()

def extract_questions_from_file(file_path):
    """Extrait toutes les questions d'un fichier JSON"""
    questions = []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        def extract_recursive(obj):
            if isinstance(obj, dict):
                if 'question' in obj:
                    # C'est un objet question
                    questions.append(obj)
                else:
                    # Parcourir récursivement
                    for value in obj.values():
                        extract_recursive(value)
            elif isinstance(obj, list):
                for item in obj:
                    extract_recursive(item)
        
        extract_recursive(data)
        return questions
        
    except Exception as e:
        print(f"   ❌ Erreur lecture {file_path}: {e}")
        return []

def find_duplicates(reference_questions, target_questions, threshold=0.85):
    """Trouve les doublons entre deux listes de questions"""
    duplicates = []
    unique = []
    
    for target_q in target_questions:
        target_text = target_q.get('question', '')
        is_duplicate = False
        
        for ref_q in reference_questions:
            ref_text = ref_q.get('question', '')
            similarity = similarity_ratio(target_text, ref_text)
            
            if similarity >= threshold:
                duplicates.append({
                    'question': target_q,
                    'similar_to': ref_text,
                    'similarity': similarity
                })
                is_duplicate = True
                break
        
        if not is_duplicate:
            unique.append(target_q)
    
    return duplicates, unique

def cleanup_file(file_path, reference_questions, backup=True):
    """Nettoie un fichier en supprimant les doublons"""
    print(f"\n📝 Analyse: {os.path.basename(file_path)}")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Extraire les questions
        target_questions = extract_questions_from_file(file_path)
        original_count = len(target_questions)
        
        if original_count == 0:
            print(f"   ⚠️  Aucune question trouvée")
            return 0, 0
        
        # Trouver les doublons
        duplicates, unique = find_duplicates(reference_questions, target_questions)
        duplicates_count = len(duplicates)
        
        print(f"   📊 Questions originales: {original_count}")
        print(f"   🔍 Doublons trouvés: {duplicates_count}")
        print(f"   ✅ Questions uniques: {len(unique)}")
        
        if duplicates_count > 0:
            # Afficher quelques exemples
            print(f"   📋 Exemples de doublons:")
            for i, dup in enumerate(duplicates[:3]):
                similarity_pct = int(dup['similarity'] * 100)
                print(f"      {i+1}. {dup['question']['question'][:60]}... ({similarity_pct}%)")
        
        # Si tous sont des doublons, marquer le fichier pour suppression
        if len(unique) == 0:
            print(f"   🗑️  FICHIER À SUPPRIMER (100% doublons)")
            return original_count, duplicates_count
        
        # Si des questions uniques existent, créer un fichier nettoyé
        if duplicates_count > 0:
            # Backup
            if backup:
                backup_path = str(file_path) + '.backup'
                with open(backup_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                print(f"   💾 Backup: {os.path.basename(backup_path)}")
            
            # Reconstruire la structure JSON avec seulement les questions uniques
            # Pour simplifier, on va créer une structure plate
            cleaned_data = {
                "category": os.path.basename(file_path).replace('.json', ''),
                "questions": unique
            }
            
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(cleaned_data, f, ensure_ascii=False, indent=2)
            
            print(f"   ✅ Fichier nettoyé: {len(unique)} questions conservées")
        
        return original_count, duplicates_count
        
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
        return 0, 0

def main():
    print("🧹 NETTOYAGE DES QUESTIONS EN DOUBLON")
    print("=" * 70)
    
    questions_dir = Path(__file__).parent.parent / "assets" / "questions"
    
    if not questions_dir.exists():
        print(f"❌ Dossier non trouvé: {questions_dir}")
        return
    
    # Charger toutes les questions des catégories traduites (référence)
    print("\n📚 Chargement des questions de référence (catégories traduites)...")
    reference_questions = []
    
    for cat_file in TRANSLATED_CATEGORIES:
        file_path = questions_dir / cat_file
        if file_path.exists():
            questions = extract_questions_from_file(file_path)
            reference_questions.extend(questions)
            print(f"   ✅ {cat_file}: {len(questions)} questions")
    
    print(f"\n📊 Total questions de référence: {len(reference_questions)}")
    
    # Nettoyer les catégories non traduites
    print("\n" + "=" * 70)
    print("🧹 NETTOYAGE DES CATÉGORIES NON TRADUITES")
    print("=" * 70)
    
    total_original = 0
    total_duplicates = 0
    files_to_delete = []
    
    for cat_file in UNTRANSLATED_CATEGORIES:
        file_path = questions_dir / cat_file
        if file_path.exists():
            original, duplicates = cleanup_file(file_path, reference_questions)
            total_original += original
            total_duplicates += duplicates
            
            # Si 100% doublons, marquer pour suppression
            if original > 0 and duplicates == original:
                files_to_delete.append(file_path)
    
    # Résumé
    print("\n" + "=" * 70)
    print("📊 RÉSUMÉ DU NETTOYAGE")
    print("=" * 70)
    print(f"📚 Questions de référence: {len(reference_questions)}")
    print(f"📝 Questions analysées: {total_original}")
    print(f"🗑️  Doublons supprimés: {total_duplicates}")
    print(f"✅ Questions conservées: {total_original - total_duplicates}")
    
    if files_to_delete:
        print(f"\n🗑️  FICHIERS À SUPPRIMER (100% doublons):")
        for file_path in files_to_delete:
            print(f"   ❌ {os.path.basename(file_path)}")
        
        print(f"\n⚠️  Pour supprimer ces fichiers, exécutez:")
        for file_path in files_to_delete:
            print(f"   rm {file_path}")
    
    print("\n✅ Nettoyage terminé!")
    print(f"💾 Les fichiers originaux ont été sauvegardés avec l'extension .backup")

if __name__ == "__main__":
    main()



