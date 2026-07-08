#!/bin/bash
# Tableau de bord en temps réel - Traduction Chinoise

clear

while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  🇨🇳 TRADUCTION CHINOISE - TABLEAU DE BORD EN DIRECT       ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Statut du script
    if ps aux | grep "fix_chinese_translations_v2" | grep -v grep > /dev/null; then
        echo "🟢 STATUT: ACTIF"
    else
        echo "🔴 STATUT: ARRÊTÉ"
    fi
    echo ""
    
    # Fichier actuel
    echo "📄 FICHIER EN COURS:"
    grep "\[.*\]" chinese_correction_v2.log | tail -1
    echo ""
    
    # Progression barre
    echo "📊 PROGRESSION:"
    tail -20 chinese_correction_v2.log | grep "Traduction:" | tail -1
    echo ""
    
    # Fichiers terminés
    nb_files=$(grep "✅.*_zh.json" chinese_correction_v2.log 2>/dev/null | wc -l | tr -d ' ')
    echo "✅ FICHIERS TERMINÉS: $nb_files/7"
    
    # Échecs
    nb_fails=$(grep "❌ Échec final" chinese_correction_v2.log 2>/dev/null | wc -l | tr -d ' ')
    echo "❌ ÉCHECS: $nb_fails"
    echo ""
    
    # Heure
    echo "🕐 HEURE: $(date '+%H:%M:%S')"
    echo ""
    
    # Dernières lignes
    echo "📋 DERNIÈRE ACTIVITÉ:"
    tail -5 chinese_correction_v2.log | grep -v "^$"
    echo ""
    
    echo "════════════════════════════════════════════════════════════"
    echo "Mise à jour toutes les 10 secondes - Ctrl+C pour quitter"
    echo "════════════════════════════════════════════════════════════"
    
    sleep 10
done





