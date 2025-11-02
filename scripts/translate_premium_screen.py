#!/usr/bin/env python3
"""
Script pour remplacer les textes hardcodés dans enhanced_premium_screen.dart
par des appels à TranslationService
"""

import re

# Fichier à modifier
input_file = 'lib/screens/enhanced_premium_screen.dart'
output_file = 'lib/screens/enhanced_premium_screen.dart'

# Mapping des remplacements
replacements = [
    # Titre appBar
    (r"'Quizz4u Premium'", 
     "TranslationService.translate('premium_title')"),
    
    # Message mode test
    (r"'Mode Test: Les achats in-app ne sont pas disponibles sur l\\'émulateur\. Les fonctionnalités premium seront activables sur un appareil réel\.'",
     "TranslationService.translate('test_mode_message')"),
    
    # Titres sections
    (r"'📊 Gratuit vs Premium'",
     "TranslationService.translate('comparison_title')"),
    (r"'Fonctionnalités'",
     "TranslationService.translate('features_label')"),
    (r"'Gratuit'",
     "TranslationService.translate('free_label')"),
    (r"'Premium'",
     "TranslationService.translate('premium_label')"),
    
    # Lignes de comparaison
    (r"_buildComparisonRow\('🚫 Publicités', '❌ Avec pubs', '✅ Aucune pub'\)",
     "_buildComparisonRow(TranslationService.translate('ads_premium'), TranslationService.translate('ads_free'), TranslationService.translate('ads_premium_value'))"),
    
    (r"_buildComparisonRow\('🎯 Questions illimitées', '✅ Oui', '✅ Oui'\)",
     "_buildComparisonRow(TranslationService.translate('unlimited_questions'), TranslationService.translate('yes'), TranslationService.translate('yes'))"),
    
    (r"_buildComparisonRow\('📊 Statistiques avancées', '❌ Basiques', '✅ Complètes'\)",
     "_buildComparisonRow(TranslationService.translate('advanced_stats'), TranslationService.translate('basic'), TranslationService.translate('complete'))"),
    
    (r"_buildComparisonRow\('🎨 Thèmes personnalisés', '❌ Non', '✅ Oui'\)",
     "_buildComparisonRow(TranslationService.translate('custom_themes'), TranslationService.translate('no'), TranslationService.translate('yes'))"),
    
    (r"_buildComparisonRow\('🏆 Badges exclusifs', '❌ Non', '✅ Oui'\)",
     "_buildComparisonRow(TranslationService.translate('exclusive_badges'), TranslationService.translate('no'), TranslationService.translate('yes'))"),
    
    (r"_buildComparisonRow\('💾 Sauvegarde cloud', '❌ Non', '✅ Oui'\)",
     "_buildComparisonRow(TranslationService.translate('cloud_backup'), TranslationService.translate('no'), TranslationService.translate('yes'))"),
    
    (r"_buildComparisonRow\('📱 Multi-appareils', '❌ Non', '✅ Oui'\)",
     "_buildComparisonRow(TranslationService.translate('multi_device'), TranslationService.translate('no'), TranslationService.translate('yes'))"),
    
    (r"_buildComparisonRow\('🎁 Contenu exclusif', '❌ Non', '✅ Oui'\)",
     "_buildComparisonRow(TranslationService.translate('exclusive_content'), TranslationService.translate('no'), TranslationService.translate('yes'))"),
    
    (r"_buildComparisonRow\('⚡ Support prioritaire', '❌ Non', '✅ Oui'\)",
     "_buildComparisonRow(TranslationService.translate('priority_support'), TranslationService.translate('no'), TranslationService.translate('yes'))"),
    
    # Header animé
    (r"'Débloquez Quizz4u Premium'",
     "TranslationService.translate('unlock_premium')"),
    (r"'Accédez à toutes les fonctionnalités avancées'",
     "TranslationService.translate('premium_access')"),
    
    # Options d'achat
    (r"'💎 Choisissez votre option'",
     "TranslationService.translate('choose_your_option')"),
    (r"'Premium à vie'",
     "TranslationService.translate('lifetime_premium')"),
    (r"'Accès permanent à toutes les fonctionnalités'",
     "TranslationService.translate('lifetime_premium_desc')"),
    (r"'Abonnement Mensuel'",
     "TranslationService.translate('monthly_subscription')"),
    (r"'Renouvellement automatique chaque mois'",
     "TranslationService.translate('monthly_subscription_desc')"),
    (r"'Abonnement Annuel'",
     "TranslationService.translate('annual_subscription')"),
    (r"'Renouvellement automatique chaque année'",
     "TranslationService.translate('annual_subscription_desc')"),
    (r"'TOP'",
     "TranslationService.translate('top_label')"),
    
    # Avantages Premium
    (r"'🎯 Avantages Premium'",
     "TranslationService.translate('premium_benefits')"),
    (r"'Et \$\{_benefits\.length - 6\} autres avantages\.\.\.'",
     "TranslationService.translateWithParams('and_more_benefits', {'count': '${_benefits.length - 6}'})"),
    
    # Sécurité
    (r"'Paiement Sécurisé'",
     "TranslationService.translate('secure_payment')"),
    (r"'Transaction sécurisée via Google Play / App Store'",
     "TranslationService.translate('secure_payment_desc')"),
    
    # Actions
    (r"'Restaurer mes achats'",
     "TranslationService.translate('restore_purchases')"),
    (r"'Continuer avec la version gratuite'",
     "TranslationService.translate('continue_free')"),
    
    # Premium User View
    (r"'Utilisateur Premium'",
     "TranslationService.translate('premium_user')"),
    (r"'Vous profitez de toutes les fonctionnalités !'",
     "TranslationService.translate('premium_user_desc')"),
    (r"'✨ Toutes vos fonctionnalités'",
     "TranslationService.translate('all_your_features')"),
    
    # Messages succès/erreur
    (r"'🎉 Abonnement activé avec succès !'",
     "TranslationService.translate('subscription_activated')"),
    (r"'🚫 Abonnement annulé'",
     "TranslationService.translate('subscription_cancelled')"),
    (r"'🎉 Achats restaurés avec succès !'",
     "TranslationService.translate('purchases_restored')"),
    (r"'ℹ️ Aucun achat à restaurer'",
     "TranslationService.translate('no_purchases_to_restore')"),
]

def main():
    # Lire le fichier
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Appliquer les remplacements
    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content)
    
    # Écrire le fichier
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Remplacements appliqués avec succès dans {output_file}")

if __name__ == '__main__':
    main()

