#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Crée des fichiers de traduction stubs (copies du FR) pour les fichiers enriched
Ces fichiers pourront être traduits manuellement ultérieurement
"""

import json
import shutil
from pathlib import Path

ASSETS_DIR = Path('assets/questions')
FILES = [
    'enriched_culture_questions.json',
    'enriched_science_questions.json',
    'enriched_history_questions.json'
]

LANGUAGES = ['en', 'ar', 'zh', 'es', 'hi']

print("╔════════════════════════════════════════════════════════════════════════╗")
print("║         📝 CRÉATION DE STUBS DE TRADUCTION (FR → AUTRES)              ║")
print("╚════════════════════════════════════════════════════════════════════════╝")
print()

total_created = 0

for source_filename in FILES:
    source_file = ASSETS_DIR / source_filename
    
    if not source_file.exists():
        print(f"⚠️  {source_filename} non trouvé")
        continue
    
    # Lire le fichier source
    with open(source_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Compter les questions
    q_count = sum(len(questions) for questions in data.values() if isinstance(questions, list))
    
    print(f"📁 {source_filename} ({q_count} questions)")
    
    # Créer un fichier pour chaque langue
    for lang in LANGUAGES:
        base_name = source_filename.replace('.json', '')
        target_filename = f"{base_name}_{lang}.json"
        target_file = ASSETS_DIR / target_filename
        
        # Copier le contenu FR (stub pour traduction manuelle)
        with open(target_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"  ✅ {target_filename} créé (stub FR, à traduire)")
        total_created += 1

print()
print("╔════════════════════════════════════════════════════════════════════════╗")
print("║                         ✅ STUBS CRÉÉS                                 ║")
print("╚════════════════════════════════════════════════════════════════════════╝")
print()
print(f"📊 Total fichiers créés: {total_created}")
print()
print("⚠️  IMPORTANT: Ces fichiers contiennent du texte en FRANÇAIS")
print("   Ils doivent être traduits manuellement ou avec un outil externe.")
print()
print("✅ Le jeu fonctionnera quand même car les catégories principales")
print("   sont déjà traduites (Football, Musique, Maths, Afrique).")



