#!/bin/bash
# Script de vérification rapide - Traduction Chinoise V2

echo "═══════════════════════════════════════════════════════════"
echo "  🔍 VÉRIFICATION RAPIDE - Traduction Chinoise V2"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Vérifier si le script tourne
if ps aux | grep "fix_chinese_translations_v2" | grep -v grep > /dev/null; then
    echo "✅ Script V2 ACTIF"
    echo ""
else
    echo "❌ Script V2 ARRÊTÉ"
    echo "   → Relancer avec:"
    echo "   nohup python3 scripts/fix_chinese_translations_v2.py --yes > chinese_correction_v2.log 2>&1 &"
    echo ""
    exit 1
fi

# Progression actuelle
echo "📊 PROGRESSION:"
tail -10 chinese_correction_v2.log | grep "\[.*\]" | tail -1
echo ""

# Fichiers terminés
nb_files=$(grep "✅.*_zh.json" chinese_correction_v2.log 2>/dev/null | wc -l | tr -d ' ')
echo "✅ Fichiers complétés: $nb_files/7"

# Échecs
nb_fails=$(grep "❌ Échec final" chinese_correction_v2.log 2>/dev/null | wc -l | tr -d ' ')
echo "❌ Échecs totaux: $nb_fails"
echo ""

# Temps
start_time="15:45"
current_time=$(date +"%H:%M")
echo "⏱️  Démarré: $start_time"
echo "   Maintenant: $current_time"
echo ""

# Estimation
echo "🎯 Fin estimée: Demain 2h-8h"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📋 Commandes utiles:"
echo "   • Voir progression: tail -f chinese_correction_v2.log"
echo "   • Arrêter: pkill -f fix_chinese_translations_v2.py"
echo "   • Log complet: less chinese_correction_v2.log"
echo ""





