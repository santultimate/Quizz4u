#!/bin/bash

# Check ponctuel de l'état de la traduction
clear
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║              📊 ÉTAT DE LA TRADUCTION - $(date '+%H:%M:%S')                      ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""

ASSETS_DIR="$(dirname "$0")/../assets/questions"

# Fichiers à surveiller
FILES=(
    "enriched_culture_questions"
    "enriched_science_questions"
    "enriched_history_questions"
)

LANGS=("en" "ar" "zh" "es" "hi")
TOTAL_FILES=15
COMPLETED=0

# Vérifier si le script de traduction est en cours
PROCESS_COUNT=$(ps aux | grep "translate_enriched_free_progress.py" | grep -v grep | wc -l)

if [ $PROCESS_COUNT -gt 0 ]; then
    echo "🔄 Script de traduction EN COURS D'EXÉCUTION"
    echo ""
else
    echo "⏸️  Aucun script de traduction en cours"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for file in "${FILES[@]}"; do
    echo "📁 $file:"
    
    # Vérifier si le fichier source existe
    source_file="${ASSETS_DIR}/${file}.json"
    if [ ! -f "$source_file" ]; then
        echo "   ❌ Fichier source introuvable!"
        echo ""
        continue
    fi
    
    for lang in "${LANGS[@]}"; do
        target_file="${ASSETS_DIR}/${file}_${lang}.json"
        
        if [ -f "$target_file" ]; then
            # Obtenir la taille et date de modification
            size=$(stat -f%z "$target_file" 2>/dev/null || echo 0)
            mod_time=$(stat -f "%Sm" -t "%H:%M:%S" "$target_file" 2>/dev/null || echo "??:??:??")
            
            # Formatter la taille
            if [ $size -gt 1024 ]; then
                size_kb=$((size / 1024))
                size_str="${size_kb}KB"
            else
                size_str="${size}B"
            fi
            
            # Vérifier si c'est un stub (comparer première question)
            is_stub="❓"
            
            # Méthode simple : lire les premiers caractères de chaque fichier
            first_q_target=$(cat "$target_file" | grep -m 1 '"question"' | head -1)
            first_q_source=$(cat "$source_file" | grep -m 1 '"question"' | head -1)
            
            if [ "$first_q_target" = "$first_q_source" ]; then
                is_stub="⏳ STUB"
                status_icon="⏳"
            else
                is_stub="✅ TRADUIT"
                status_icon="✅"
                ((COMPLETED++))
            fi
            
            echo "   $lang: $status_icon  |  $size_str  |  Modifié: $mod_time"
        else
            echo "   $lang: ❌ Fichier manquant"
        fi
    done
    echo ""
done

# Barre de progression globale
PROGRESS=$((COMPLETED * 100 / TOTAL_FILES))
BAR_LENGTH=50
FILLED=$((BAR_LENGTH * COMPLETED / TOTAL_FILES))
EMPTY=$((BAR_LENGTH - FILLED))

# Créer la barre
BAR=""
for ((i=0; i<FILLED; i++)); do BAR="${BAR}█"; done
for ((i=0; i<EMPTY; i++)); do BAR="${BAR}░"; done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 PROGRESSION GLOBALE:"
echo ""
echo "   [$BAR]"
echo ""
echo "   🎯 Complétés: $COMPLETED/$TOTAL_FILES ($PROGRESS%)"
echo ""

if [ $COMPLETED -eq $TOTAL_FILES ]; then
    echo "   ✅ TRADUCTION TERMINÉE !"
    echo ""
    echo "📋 PROCHAINES ÉTAPES:"
    echo "   1. Vérifier échantillon de qualité"
    echo "   2. Tester l'app dans différentes langues"
    echo "   3. Lancer sur les stores 🚀"
elif [ $COMPLETED -eq 0 ]; then
    echo "   ⏳ Traduction en cours..."
    echo "   ⏱️  Temps estimé: 30-45 minutes"
else
    echo "   🔄 Traduction en cours..."
    remaining=$((TOTAL_FILES - COMPLETED))
    echo "   ⏳ Restants: $remaining fichiers"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Commandes utiles:"
echo "   • Revoir cet état: ./scripts/check_translation_status.sh"
echo "   • Monitoring auto (20min): ./scripts/monitor_translation.sh"
echo "   • Voir le processus: ps aux | grep translate_enriched"
echo ""


