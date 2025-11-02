#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Régénère les traductions chinoises depuis les fichiers français originaux
Utilise un dictionnaire de traductions manuelles pour les phrases complètes
"""

import json
import os
from pathlib import Path

# Traductions manuelles de questions complètes
QUESTION_TRANSLATIONS = {
    # Union Africaine
    "Quand a été créée l'Union Africaine (UA) ?": "非洲联盟（AU）成立于何时？",
    "Où se trouve le siège de l'Union Africaine ?": "非洲联盟的总部在哪里？",
    "Quel est le siège de l'Union Africaine ?": "非洲联盟的总部在哪里？",
    
    # ONU / Nations Unies
    "Qui est l'actuel Secrétaire général des Nations Unies (depuis 2017) ?": "谁是现任联合国秘书长（自2017年起）？",
    "Qui est le Secrétaire général de l'ONU ?": "谁是联合国秘书长？",
    
    # Afrique du Sud / Apartheid
    "Quel président sud-africain a mis fin à l'apartheid ?": "哪位南非总统结束了种族隔离制度？",
    "Qui a mis fin à l'apartheid en Afrique du Sud ?": "谁结束了南非的种族隔离制度？",
    
    # Startups / Economie
    "Quelle startup nigériane est devenue une licorne en 2020 ?": "哪家尼日利亚初创公司在2020年成为了独角兽？",
    "Quel est le plus grand marché e-commerce africain ?": "非洲最大的电子商务市场是什么？",
}

# Traductions pour les explications
EXPLANATION_PATTERNS = {
    "António Guterres, ancien Premier ministre portugais, est SG de l'ONU depuis 2017.": 
        "安东尼奥·古特雷斯，前葡萄牙总理，自2017年起担任联合国秘书长。",
    
    "Le siège de l'UA est situé à Addis-Abeba, en Éthiopie.":
        "非洲联盟总部位于埃塞俄比亚的亚的斯亚贝巴。",
    
    "Nelson Mandela est devenu le premier président noir d'Afrique du Sud en 1994, après 27 ans de prison.":
        "纳尔逊·曼德拉在监禁27年后，于1994年成为南非第一位黑人总统。",
    
    "Flutterwave, plateforme de paiements, a atteint une valorisation de +1 milliard USD en 2020.":
        "支付平台Flutterwave在2020年估值超过10亿美元。",
}

def translate_question_object(question_obj, original_question=""):
    """Traduit un objet question complet"""
    if not isinstance(question_obj, dict):
        return question_obj
    
    result = {}
    
    for key, value in question_obj.items():
        if key == "question" and isinstance(value, str):
            # Vérifier si c'est une question connue
            if value in QUESTION_TRANSLATIONS:
                result[key] = QUESTION_TRANSLATIONS[value]
            else:
                # Garder la question originale française si pas de traduction
                result[key] = value
                print(f"   ⚠️  Traduction manquante: {value[:60]}...")
        
        elif key == "explanation" and isinstance(value, str):
            # Vérifier si c'est une explication connue
            if value in EXPLANATION_PATTERNS:
                result[key] = EXPLANATION_PATTERNS[value]
            else:
                # Garder l'explication originale
                result[key] = value
        
        elif key == "correctAnswer":
            # Garder tel quel (noms propres)
            result[key] = value
        
        elif key == "options" and isinstance(value, list):
            # Garder les options telles quelles (noms de lieux/personnes)
            result[key] = value
        
        elif key in ["difficulty", "category", "subcategory"]:
            # Traduire les méta-données
            if value == "Facile" or value == "简单":
                result[key] = "简单"
            elif value == "Moyen" or value == "中等":
                result[key] = "中等"
            elif value == "Difficile" or value == "困难":
                result[key] = "困难"
            elif key == "category":
                # Traduire les noms de catégories
                category_map = {
                    "Politique et Économie": "政治与经济",
                    "Histoire": "历史",
                    "Culture générale": "常识",
                    "Sciences": "科学",
                    "Mathématiques": "数学",
                    "Afrique": "非洲",
                    "Football": "足球",
                    "Musique": "音乐",
                    "Arts et Culture": "艺术与文化",
                    "Technologie et Innovation": "科技与创新",
                    "Santé et Médecine": "健康与医学",
                    "Environnement et Écologie": "环境与生态",
                }
                result[key] = category_map.get(value, value)
            else:
                result[key] = value
        else:
            result[key] = value
    
    return result

def process_file_pair(fr_file, zh_file):
    """Traite une paire de fichiers français/chinois"""
    print(f"\n📝 {os.path.basename(fr_file)} → {os.path.basename(zh_file)}")
    
    try:
        # Lire le fichier français
        with open(fr_file, 'r', encoding='utf-8') as f:
            fr_data = json.load(f)
        
        # Lire le fichier chinois existant
        if os.path.exists(zh_file):
            with open(zh_file, 'r', encoding='utf-8') as f:
                zh_data = json.load(f)
        else:
            zh_data = {}
        
        # Fonction récursive pour traduire
        def translate_recursive(fr_obj, zh_obj=None):
            if zh_obj is None:
                zh_obj = {}
            
            if isinstance(fr_obj, dict):
                result = {}
                for key, value in fr_obj.items():
                    if isinstance(value, dict):
                        result[key] = translate_recursive(value, zh_obj.get(key, {}))
                    elif isinstance(value, list) and value and isinstance(value[0], dict):
                        # Liste de questions
                        result[key] = [translate_question_object(q) for q in value]
                    else:
                        result[key] = value
                return result
            return fr_obj
        
        # Traduire
        new_zh_data = translate_recursive(fr_data, zh_data)
        
        # Sauvegarder
        with open(zh_file, 'w', encoding='utf-8') as f:
            json.dump(new_zh_data, f, ensure_ascii=False, indent=2)
        
        print(f"   ✅ Fichier mis à jour")
        return True
        
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
        return False

def main():
    print("🚀 Régénération des traductions chinoises depuis les fichiers français")
    print("=" * 70)
    
    questions_dir = Path(__file__).parent.parent / "assets" / "questions"
    
    # Trouver les paires de fichiers
    fr_files = sorted(questions_dir.glob("*.json"))
    fr_files = [f for f in fr_files if not any(x in f.name for x in ['_ar', '_en', '_es', '_hi', '_zh'])]
    
    print(f"📁 {len(fr_files)} fichiers français trouvés\n")
    
    success = 0
    for fr_file in fr_files:
        zh_file = fr_file.parent / fr_file.name.replace('.json', '_zh.json')
        if zh_file.exists():
            if process_file_pair(fr_file, zh_file):
                success += 1
    
    print("\n" + "=" * 70)
    print(f"✅ {success} fichiers traités avec succès")

if __name__ == "__main__":
    main()



