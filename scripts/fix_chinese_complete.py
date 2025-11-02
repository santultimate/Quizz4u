#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour corriger et compléter les traductions chinoises
Corrige les fichiers mal traduits qui contiennent des mélanges français-chinois
"""

import json
import os
from pathlib import Path

# Dictionnaire de traductions manuelles pour les termes clés
MANUAL_TRANSLATIONS = {
    # Termes généraux
    "question": "问题",
    "options": "选项",
    "correctAnswer": "正确答案",
    "explanation": "解释",
    "difficulty": "难度",
    "category": "类别",
    "subcategory": "子类别",
    
    # Niveaux de difficulté
    "Facile": "简单",
    "Moyen": "中等",
    "Difficile": "困难",
    "简单": "简单",
    "中等": "中等",
    "困难": "困难",
    
    # Organisations
    "l'Union Africaine": "非洲联盟",
    "l'ONU": "联合国",
    "Nations Unies": "联合国",
    "l'Organisation": "组织",
    "Secrétaire général": "秘书长",
    
    # Mots courants qui apparaissent souvent
    "siège": "总部",
    "le siège": "总部",
    "se trouve": "位于",
    "où se trouve": "位于哪里",
    "président": "总统",
    "premier": "第一",
    "actuel": "现任",
    "ancien": "前任",
    "a été créée": "成立于",
    "est devenu": "成为了",
    "plus grand": "最大的",
    "marché": "市场",
    "pays": "国家",
    
    # Pays et villes
    "Afrique": "非洲",
    "Éthiopie": "埃塞俄比亚",
    "Nigeria": "尼日利亚",
    "Égypte": "埃及",
    "Kenya": "肯尼亚",
    "Addis-Abeba": "亚的斯亚贝巴",
    "Abuja": "阿布贾",
    "Le Caire": "开罗",
    "Nairobi": "内罗毕",
    "Mali": "马里",
    "Sénégal": "塞内加尔",
    "Ghana": "加纳",
    "Côte d'Ivoire": "科特迪瓦",
    "Cameroun": "喀麦隆",
    "Congo": "刚果",
    "Afrique du Sud": "南非",
    "Mozambique": "莫桑比克",
    "Angola": "安哥拉",
    "Zambie": "赞比亚",
    "Zimbabwe": "津巴布韦",
    "Tanzanie": "坦桑尼亚",
    "Ouganda": "乌干达",
    "Rwanda": "卢旺达",
    "Burundi": "布隆迪",
    "Somalie": "索马里",
    "Maroc": "摩洛哥",
    "Algérie": "阿尔及利亚",
    "Tunisie": "突尼斯",
    "Libye": "利比亚",
    "Soudan": "苏丹",
    "Tchad": "乍得",
    "Niger": "尼日尔",
    "Mauritanie": "毛里塔尼亚",
}

# Traductions de questions complètes fréquentes
COMPLETE_QUESTION_TRANSLATIONS = {
    "Où se trouve le siège de l'Union Africaine ?": "非洲联盟的总部在哪里？",
    "Quand a été créée l'Union Africaine (UA) ?": "非洲联盟（AU）成立于何时？",
    "Qui est l'actuel Secrétaire général des Nations Unies (depuis 2017) ?": "谁是现任联合国秘书长（自2017年起）？",
    "Quel président sud-africain a mis fin à l'apartheid ?": "哪位南非总统结束了种族隔离制度？",
    "Quelle startup nigériane est devenue une licorne en 2020 ?": "哪家尼日利亚初创公司在2020年成为了独角兽？",
    "Quel est le plus grand marché e-commerce africain ?": "非洲最大的电子商务市场是什么？",
}

def clean_mixed_text(text):
    """Nettoie le texte qui contient un mélange de français et chinois"""
    if not text or not isinstance(text, str):
        return text
    
    # Si le texte est déjà entièrement en chinois (pas de caractères latins sauf ponctuation)
    has_french = any(c.isalpha() and ord(c) < 256 for c in text)
    if not has_french:
        return text
    
    # Vérifier si c'est une question complète connue
    for fr_q, zh_q in COMPLETE_QUESTION_TRANSLATIONS.items():
        if fr_q.lower() in text.lower():
            return zh_q
    
    # Remplacer les termes connus
    result = text
    for fr_term, zh_term in MANUAL_TRANSLATIONS.items():
        result = result.replace(fr_term, zh_term)
        result = result.replace(fr_term.lower(), zh_term)
        result = result.replace(fr_term.capitalize(), zh_term)
    
    return result

def fix_chinese_file(file_path):
    """Corrige un fichier de traduction chinois"""
    print(f"\n🔧 Correction de {os.path.basename(file_path)}...")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        fixed_count = 0
        
        # Parcourir récursivement le JSON
        def fix_recursive(obj):
            nonlocal fixed_count
            
            if isinstance(obj, dict):
                for key, value in obj.items():
                    if isinstance(value, str):
                        cleaned = clean_mixed_text(value)
                        if cleaned != value:
                            obj[key] = cleaned
                            fixed_count += 1
                    elif isinstance(value, (dict, list)):
                        fix_recursive(value)
            elif isinstance(obj, list):
                for i, item in enumerate(obj):
                    if isinstance(item, str):
                        cleaned = clean_mixed_text(item)
                        if cleaned != item:
                            obj[i] = cleaned
                            fixed_count += 1
                    elif isinstance(item, (dict, list)):
                        fix_recursive(item)
        
        fix_recursive(data)
        
        if fixed_count > 0:
            # Sauvegarder le fichier corrigé
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"   ✅ {fixed_count} corrections appliquées")
        else:
            print(f"   ℹ️  Aucune correction nécessaire")
        
        return fixed_count
        
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
        return 0

def main():
    """Fonction principale"""
    print("🚀 Correction des traductions chinoises...")
    print("=" * 60)
    
    # Chemin vers le dossier des questions
    questions_dir = Path(__file__).parent.parent / "assets" / "questions"
    
    if not questions_dir.exists():
        print(f"❌ Dossier non trouvé: {questions_dir}")
        return
    
    # Trouver tous les fichiers chinois
    chinese_files = list(questions_dir.glob("*_zh.json"))
    
    if not chinese_files:
        print("❌ Aucun fichier chinois trouvé")
        return
    
    print(f"📁 {len(chinese_files)} fichiers chinois trouvés\n")
    
    total_fixes = 0
    for file_path in sorted(chinese_files):
        fixes = fix_chinese_file(file_path)
        total_fixes += fixes
    
    print("\n" + "=" * 60)
    print(f"✅ Terminé ! {total_fixes} corrections au total")
    print(f"📝 {len(chinese_files)} fichiers traités")

if __name__ == "__main__":
    main()



