#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script pour compléter les traductions chinoises avec un dictionnaire exhaustif
"""

import json
import os
import re
from pathlib import Path

# Dictionnaire de traduction français -> chinois (exhaustif)
FR_TO_ZH = {
    # Questions types
    "Qui est": "谁是",
    "Quel est": "什么是",
    "Quelle est": "什么是",
    "Quels sont": "有哪些",
    "Quelles sont": "有哪些",
    "Où se trouve": "位于哪里",
    "Quand a été créée": "何时成立",
    "Quand a été créé": "何时成立",
    "Quand a été fondée": "何时创立",
    "Quand a été fondé": "何时创立",
    "Comment s'appelle": "叫什么名字",
    "Combien": "多少",
    "Pourquoi": "为什么",
    
    # Verbes courants
    "est": "是",
    "a été": "已经",
    "était": "是",
    "sont": "是",
    "ont été": "已经",
    "se trouve": "位于",
    "a créé": "创建了",
    "a fondé": "创立了",
    "a mis fin à": "结束了",
    "est devenu": "成为了",
    "est devenue": "成为了",
    "sont devenus": "成为了",
    "sont devenues": "成为了",
    "a découvert": "发现了",
    "a inventé": "发明了",
    "a remporté": "赢得了",
    
    # Titres et positions
    "l'actuel": "现任",
    "actuel": "现任",
    "l'ancien": "前任",
    "ancien": "前任",
    "le président": "总统",
    "président": "总统",
    "le premier ministre": "总理",
    "premier ministre": "总理",
    "le roi": "国王",
    "roi": "国王",
    "la reine": "女王",
    "reine": "女王",
    "Secrétaire général": "秘书长",
    "secrétaire général": "秘书长",
    "directeur": "主任",
    "ministre": "部长",
    
    # Organisations
    "l'Union Africaine": "非洲联盟",
    "Union Africaine": "非洲联盟",
    "l'ONU": "联合国",
    "ONU": "联合国",
    "Nations Unies": "联合国",
    "des Nations Unies": "联合国",
    "l'Organisation": "组织",
    "Organisation": "组织",
    "l'Union Européenne": "欧盟",
    "Union Européenne": "欧盟",
    
    # Lieux
    "le siège": "总部",
    "siège": "总部",
    "la capitale": "首都",
    "capitale": "首都",
    "le pays": "国家",
    "pays": "国家",
    "la ville": "城市",
    "ville": "城市",
    "le continent": "大陆",
    "continent": "大陆",
    
    # Adjectifs
    "grand": "大",
    "grande": "大",
    "plus grand": "最大的",
    "plus grande": "最大的",
    "le plus grand": "最大的",
    "la plus grande": "最大的",
    "petit": "小",
    "petite": "小",
    "premier": "第一",
    "première": "第一",
    "dernier": "最后",
    "dernière": "最后",
    "nouveau": "新",
    "nouvelle": "新",
    "ancien": "古老的",
    "ancienne": "古老的",
    "moderne": "现代的",
    
    # Mots de liaison
    "de": "的",
    "du": "的",
    "de la": "的",
    "des": "的",
    "à": "在",
    "au": "在",
    "en": "在",
    "depuis": "自",
    "après": "之后",
    "avant": "之前",
    "pendant": "期间",
    "avec": "与",
    "sans": "没有",
    "pour": "为",
    "par": "被",
    "dans": "在",
    "sur": "在",
    "sous": "在...下",
    
    # Nombres et temps
    "ans": "年",
    "années": "年",
    "mois": "月",
    "jours": "天",
    "siècle": "世纪",
    "millénaire": "千年",
    
    # Mots courants
    "qui": "谁",
    "que": "什么",
    "quoi": "什么",
    "où": "哪里",
    "quand": "什么时候",
    "comment": "如何",
    "pourquoi": "为什么",
    "combien": "多少",
    "startup": "初创公司",
    "une licorne": "独角兽",
    "licorne": "独角兽",
    "marché": "市场",
    "e-commerce": "电子商务",
    "africain": "非洲的",
    "africaine": "非洲的",
    "nigériane": "尼日利亚的",
    "nigérian": "尼日利亚的",
    "sud-africain": "南非的",
    "sud-africaine": "南非的",
    "l'apartheid": "种族隔离",
    "apartheid": "种族隔离",
    "noir": "黑人",
    "noire": "黑人",
    "prison": "监狱",
    "portugais": "葡萄牙的",
    "portugaise": "葡萄牙的",
    "plateforme": "平台",
    "de paiements": "支付",
    "paiements": "支付",
    "a atteint": "达到了",
    "valorisation": "估值",
    "milliard": "十亿",
    "million": "百万",
    "USD": "美元",
}

# Pays et villes (complet)
LOCATIONS_FR_TO_ZH = {
    # Pays africains
    "Afrique": "非洲",
    "Afrique du Sud": "南非",
    "Éthiopie": "埃塞俄比亚",
    "Nigeria": "尼日利亚",
    "Égypte": "埃及",
    "Kenya": "肯尼亚",
    "Mali": "马里",
    "Sénégal": "塞内加尔",
    "Ghana": "加纳",
    "Côte d'Ivoire": "科特迪瓦",
    "Cameroun": "喀麦隆",
    "Congo": "刚果",
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
    
    # Villes
    "Addis-Abeba": "亚的斯亚贝巴",
    "Abuja": "阿布贾",
    "Le Caire": "开罗",
    "Caire": "开罗",
    "Nairobi": "内罗毕",
    "Bamako": "巴马科",
    "Dakar": "达喀尔",
    "Accra": "阿克拉",
    "Lagos": "拉各斯",
    "Johannesburg": "约翰内斯堡",
    "Le Cap": "开普敦",
    "Cap": "开普敦",
    "Kinshasa": "金沙萨",
    "Luanda": "罗安达",
    "Maputo": "马普托",
}

def translate_text(text):
    """Traduit un texte français vers le chinois"""
    if not text or not isinstance(text, str):
        return text
    
    # Si déjà en chinois (aucun caractère latin alphabétique)
    if not any(c.isalpha() and ord(c) < 256 for c in text):
        return text
    
    result = text
    
    # Appliquer les traductions de lieux d'abord (plus spécifiques)
    for fr, zh in LOCATIONS_FR_TO_ZH.items():
        result = result.replace(fr, zh)
        result = result.replace(fr.lower(), zh)
    
    # Appliquer les traductions générales
    for fr, zh in FR_TO_ZH.items():
        # Remplacer en préservant la casse
        result = result.replace(fr, zh)
        result = result.replace(fr.lower(), zh)
        result = result.replace(fr.capitalize(), zh)
        result = result.replace(fr.upper(), zh)
    
    # Nettoyer les espaces multiples
    result = re.sub(r'\s+', ' ', result)
    result = result.strip()
    
    return result

def process_file(file_path):
    """Traite un fichier JSON"""
    print(f"\n📝 Traitement: {os.path.basename(file_path)}")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        changes = 0
        
        def process_value(obj):
            nonlocal changes
            if isinstance(obj, dict):
                for key, value in obj.items():
                    if isinstance(value, str):
                        translated = translate_text(value)
                        if translated != value:
                            obj[key] = translated
                            changes += 1
                    elif isinstance(value, (dict, list)):
                        process_value(value)
            elif isinstance(obj, list):
                for i, item in enumerate(obj):
                    if isinstance(item, str):
                        translated = translate_text(item)
                        if translated != item:
                            obj[i] = translated
                            changes += 1
                    elif isinstance(item, (dict, list)):
                        process_value(item)
        
        process_value(data)
        
        if changes > 0:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"   ✅ {changes} traductions appliquées")
        else:
            print(f"   ℹ️  Déjà à jour")
        
        return changes
        
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
        return 0

def main():
    print("🚀 Traduction complète en chinois mandarin")
    print("=" * 60)
    
    questions_dir = Path(__file__).parent.parent / "assets" / "questions"
    chinese_files = sorted(questions_dir.glob("*_zh.json"))
    
    print(f"📁 {len(chinese_files)} fichiers à traiter\n")
    
    total = 0
    for file_path in chinese_files:
        total += process_file(file_path)
    
    print("\n" + "=" * 60)
    print(f"✅ Terminé ! {total} traductions appliquées au total")

if __name__ == "__main__":
    main()




