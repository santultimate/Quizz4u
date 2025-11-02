#!/bin/bash
# Script de vérification rapide de la progression

echo "═══════════════════════════════════════════════════════════"
echo "     🔍 VÉRIFICATION RAPIDE - Correction Chinoise"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Vérifier si le script tourne
if ps aux | grep "fix_chinese_translations" | grep -v grep > /dev/null; then
    echo "✅ Script EN COURS"
    echo ""
else
    echo "❌ Script ARRÊTÉ"
    echo "   → Relancer avec: python3 scripts/fix_chinese_translations.py --yes"
    echo ""
    exit 1
fi

# Fichier en cours
echo "📄 Fichier actuel:"
grep "\[.*\]" chinese_correction.log | tail -1
echo ""

# Progression
echo "📊 Progression:"
tail -5 chinese_correction.log | grep "Traduction:" | tail -1
echo ""

# Fichiers terminés
nb_files=$(grep "✅.*_zh.json" chinese_correction.log 2>/dev/null | wc -l | tr -d ' ')
echo "✅ Fichiers complétés: $nb_files/7"
echo ""

# Temps écoulé
start_time="11:21"
current_time=$(date +"%H:%M")
echo "⏱️  Démarré à: $start_time"
echo "   Maintenant: $current_time"
echo ""

# Estimation fin
echo "🎯 Fin estimée: 17:30 ± 1h"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Pour plus de détails: tail -30 chinese_correction.log"
