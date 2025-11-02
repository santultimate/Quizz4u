#!/bin/bash
# Script pour surveiller la progression de la traduction

echo "🔍 Surveillance de la traduction chinoise..."
echo "Appuyez sur Ctrl+C pour arrêter"
echo ""

while true; do
    clear
    echo "🇨🇳 ÉTAT DE LA TRADUCTION CHINOISE"
    echo "=================================="
    echo ""
    
    # Vérifier si le processus est actif
    if ps aux | grep -i "analyze_and_translate_zh" | grep -v grep > /dev/null; then
        echo "✅ Script en cours d'exécution"
    else
        echo "❌ Script terminé ou arrêté"
    fi
    
    echo ""
    echo "📊 Dernières lignes du log:"
    echo "-----------------------------------"
    tail -20 translation_progress.log 2>/dev/null || echo "Log non disponible"
    
    echo ""
    echo "⏱️  Mise à jour toutes les 5 secondes..."
    echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    
    sleep 5
done
