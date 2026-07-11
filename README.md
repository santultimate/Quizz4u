# 🎯 Quizz4u - Application de Quiz Multilingue

[![Version](https://img.shields.io/badge/version-2.0.6-blue.svg)](https://github.com/santultimate/Quizz4u)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-Educational-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-Production-ready-brightgreen.svg)](https://github.com/santultimate/Quizz4u)

## 📱 Description

**Quizz4u** est une application de quiz éducatif moderne, interactive et multilingue. Elle propose **500 questions** réparties dans **12 catégories**, disponibles en **6 langues**.

> 🚀 **Version 2.0.6+11** — prête pour Google Play Store

### 🌍 Langues Supportées
- 🇫🇷 **Français** (langue principale)
- 🇬🇧 **Anglais**
- 🇸🇦 **Arabe**
- 🇨🇳 **Chinois Mandarin**
- 🇪🇸 **Espagnol**
- 🇮🇳 **Hindi**

**Total actif** : 500 questions × 6 langues = 3 000 instances de questions

---

## 🌟 Fonctionnalités Principales

### 📚 12 Catégories de Questions

#### ✅ Catégories actives (6 langues)
* 🇲🇱 **Histoire du Mali** (52)
* 🌍 **Culture générale** (45)
* 🔬 **Sciences** (32)
* ➗ **Mathématiques** (40)
* 🌍 **Afrique** (43)
* ⚽ **Football** (30)
* 🎵 **Musique** (30)
* 🎨 **Arts et Culture** (40)
* 💼 **Politique et Économie** (40)
* 💻 **Technologie et Innovation** (40)
* 🏥 **Santé et Médecine** (40)
* 🌱 **Environnement et Écologie** (40)

### 🎮 Expérience de Jeu Avancée

#### 🎲 Système de Sélection Intelligent
* **Sélection aléatoire** de 10 questions par partie depuis la banque globale
* **Anti-répétition** : historique des 20 dernières questions
* **Mélange multiple** : garantit une vraie randomisation
* **Évite l'effet déjà-vu** : chaque partie est unique

#### ⏱️ Timer Dynamique
* **30 secondes** par question (par défaut)
* **Configurable** : 10-20 secondes dans les paramètres
* **Animation fluide** avec changement de couleurs
* **Arrêt automatique** lors de la réponse

#### 🎯 Système de Scoring Intelligent
* **10 points** de base par bonne réponse
* **Bonus temps** : jusqu'à +10 points (timer/3)
* **Maximum** : 20 points par question
* **Score réaliste** : affiché en points ET en pourcentage de précision
* **Pas de points négatifs** pour encourager l'apprentissage

#### 🎨 Interface et Animations
* **Design moderne** et intuitif
* **Animations fluides** avec Lottie
* **Feedback visuel** immédiat
* **Mode pause** avec popup élégant
* **Réponses mélangées** automatiquement
* **Thème adaptatif** (clair/sombre/système)

### 🎵 Fonctionnalités Audio Optimisées

* **Effets sonores** pour bonnes/mauvaises réponses
* **Musique de fond** avec contrôle de volume
* **Gestion intelligente** : pause automatique pendant les publicités
* **Service audio unifié** : optimisé pour éviter les conflits
* **Contrôles individuels** : volume principal, musique, effets

> ✅ **Text-to-Speech** : Lecture automatique des questions dans toutes les langues supportées

### 🏆 Système de Progression Avancé

#### 📈 Système XP Double Niveau

**ProgressService** (Principal):
- **5 XP** de base par bonne réponse
- **Bonus score** : points gagnés / 20
- **Bonus difficulté** : +3 XP (difficile), +1 XP (moyen)
- **Bonus niveau** : niveau actuel / 5
- **Plafonné** : 15 XP maximum par question
- **Participation** : 1 XP même pour mauvaise réponse

**AdvancedProgressionService** (Avancé):
- **Score parfait** : +50% XP
- **Série quotidienne** : jusqu'à +100 XP
- **Bonus rapidité** : +30% XP
- **Bonus variété** : +20% XP pour diversification

#### 🎖️ Niveaux et Badges
* **Système de niveaux** : 100 XP = 1 niveau
* **Progression visible** : barre de progression vers niveau suivant
* **Badges débloquables** : Expert, Démon de Vitesse, Polyglotte, etc.
* **6 rangs** : Débutant → Étudiant → Connaisseur → Expert → Maître → Légende

#### 📊 Statistiques Détaillées
* **Classement local** avec noms des joueurs
* **Historique des parties** avec date et scores
* **Statistiques par catégorie** (nombre de parties, précision)
* **Meilleur score** et **moyenne** affichés
* **Partage social** de vos performances

### 📺 Publicités et Monétisation

* **AdMob intégré** en mode PRODUCTION
* **Publicités banner** : en bas des écrans principaux
* **Publicités interstitielles** : entre les parties (après résultats)
* **Publicités récompensées** : bonus XP ou second chance
* **Mode premium** : supprime toutes les publicités (en développement)
* **Configuration optimisée** : IDs de production validés

### ⚙️ Personnalisation Complète

#### 🎨 Apparence
* **3 modes de thème** : Clair, Sombre, Système
* **Design adaptatif** : s'ajuste automatiquement
* **Couleurs harmonieuses** : accessibles et agréables
* **Animations** : activables/désactivables

#### ⚡ Paramètres de Jeu
* **Durée du timer** : 10-20 secondes
* **Niveau de difficulté** : Facile, Moyen, Difficile
* **Contrôles audio** : volume principal, musique, effets
* **Vibrations** : feedback haptique
* **Notifications** : rappels quotidiens

#### 🌍 Langues
* **Changement instantané** : interface traduite en temps réel
* **Questions traduites** : chargement automatique
* **6 langues** : FR, EN, AR, ZH, ES, HI
* **Persistance** : langue sauvegardée entre les sessions

### 🔔 Engagement Utilisateur

* **Défis quotidiens** : nouvelles questions chaque jour
* **Séries quotidiennes** : bonus pour jeu régulier
* **Objectifs hebdomadaires** : défis à relever
* **Notifications locales** : nouveaux badges et niveaux
* **Système de rappels** : encourage à jouer régulièrement

---

## 📋 Architecture de l'Application

### 🗺️ Navigation Principale

```
LoadingScreen (Initialisation)
    ↓
HomeScreen (Accueil)
    ↓
CategorySelectionScreen (Choix catégorie)
    ↓
QuizScreen (Jeu)
    ↓
LeaderboardScreen (Résultats)
```

### 📱 Écrans Disponibles

#### 🏠 Écran d'Accueil (HomeScreen)
* Logo et titre élégants
* Bouton "Commencer" principal
* Affichage niveau et XP
* Accès rapide aux paramètres
* Bannière publicitaire (si non-premium)

#### 🎯 Sélection de Catégorie
* **10 cartes colorées** avec icônes thématiques
* **Indicateurs de progression** par catégorie
* **Barre de recherche** pour filtrer
* **Design moderne** avec animations
* **Nombre de questions** affiché par catégorie

#### 🎮 Écran de Quiz
* **Question claire** et lisible
* **4 réponses** mélangées aléatoirement
* **Timer animé** avec barre de progression circulaire
* **Bouton pause** accessible
* **Feedback visuel** immédiat (vert/rouge)
* **Explication** affichée après chaque réponse
* **Compteur de progression** (ex: 3/10)

#### 📊 Écran de Résultats (Leaderboard)
* **Score final** en points et pourcentage
* **Nombre de bonnes réponses** sur total
* **Saisie du nom** pour enregistrement
* **Historique** des 10 meilleurs scores
* **Bouton partage** pour réseaux sociaux
* **Options** : rejouer, changer catégorie, accueil

#### ⚙️ Paramètres (Settings)
* **Thème** : Clair / Sombre / Système
* **Langue** : 6 langues disponibles
* **Audio** : Musique de fond, Effets sonores, Volumes
* **Jeu** : Durée timer, Difficulté
* **Notifications** : Activation, Fréquence
* **Vibrations** : Feedback haptique
* **À propos** : Informations application

#### 📈 Statistiques (Stats)
* **Vue d'ensemble** : Niveau, XP, Taux de réussite
* **Par catégorie** : Nombre de parties, Moyenne, Meilleur score
* **Graphiques** : Évolution des performances
* **Badges** : Collection et conditions
* **Séries** : Série actuelle et record

#### 🏆 Profil Utilisateur
* **Avatar** et nom d'utilisateur
* **Niveau** et progression
* **Badges** débloqués
* **Statistiques globales**
* **Historique** de jeu

#### 💎 Premium
* **Avantages** : Pas de pub, bonus XP, badges exclusifs, thèmes personnalisés
* **Options** : Abonnement mensuel/annuel ou achat à vie
* **Paiement sécurisé** : Google Play Billing / App Store

---

## 🎉 Dernières Mises à Jour (v2.0.5+10)

### ✨ Nouvelles Fonctionnalités
- 🌍 **Support multilingue complet** : Interface traduite en 6 langues (FR, EN, AR, ZH, HI, ES)
- 💎 **Page Premium entièrement traduite** : 10 avantages premium traduits dans toutes les langues
- 🎨 **UI optimisée** : Fixes d'overflow et adaptation automatique aux textes traduits
- 🔐 **Sécurité renforcée** : Configuration sécurisée des clés de signature

### 🐛 Corrections
- ✅ Correction des traductions d'écran de chargement
- ✅ Correction des traductions du timer (temps restant)
- ✅ Correction des traductions de l'écran d'accueil (stats)
- ✅ Retrait des imports inutilisés
- ✅ Nettoyage massif du code (70+ fichiers de développement supprimés)

### 🚀 Préparation Production
- ✅ Version incrémentée à 2.0.5+10
- ✅ Configuration Google Play prête
- ✅ AdMob en mode production
- ✅ Firebase intégré
- ✅ Code optimisé et obfusqué

### 📊 Statistiques Code
- **237 fichiers modifiés** dans le dernier commit
- **69,613 lignes ajoutées**, **8,827 supprimées**
- **Code propre et maintenable**

---

## 🛠️ Technologies et Architecture

### 📦 Framework et Langage
* **Flutter 3.x** - Framework cross-platform
* **Dart** - Langage de programmation moderne
* **Material Design 3** - Design system de Google

### 🗂️ Architecture de Code

#### Services Optimisés
* `QuestionServiceOptimized` - Gestion des questions avec cache
* `UnifiedAudioServiceOptimized` - Audio unifié sans conflits
* `ProgressService` - Progression et statistiques
* `LocalizationService` - Traductions et langues
* `AdService` - Gestion des publicités AdMob
* `PremiumService` - Achats in-app
* `CachedPreferencesService` - Cache SharedPreferences

#### Utilitaires
* `SafeNavigator` - Navigation sécurisée anti-ANR
* `BadgeService` - Gestion des badges
* `DailyChallengeService` - Défis quotidiens
* `QuestionTranslationService` - Traduction des questions

### 📚 Packages Principaux
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # UI & Animations
  lottie: ^2.7.0                    # Animations vectorielles
  confetti: ^0.7.0                  # Effets de célébration
  
  # Audio
  audioplayers: ^5.2.1              # Lecture audio
  flutter_tts: ^3.8.5               # Text-to-Speech
  
  # Données & Storage
  shared_preferences: ^2.2.2        # Stockage local
  
  # Publicités & Monétisation
  google_mobile_ads: ^4.0.0         # AdMob
  in_app_purchase: ^3.1.13          # Achats in-app
  
  # Fonctionnalités
  share_plus: ^7.2.1                # Partage social
  url_launcher: ^6.2.2              # Ouverture liens
  vibration: ^1.8.4                 # Feedback haptique
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  
  # Qualité de code
  flutter_lints: ^3.0.1
```

---

## 📱 Compatibilité et Configuration

### 📱 Plateformes Supportées
* **Android** : API 21+ (Android 5.0 Lollipop et supérieur)
* **iOS** : iOS 12.0+ 
* **Taille optimisée** : ~54 MB (AAB pour Android)

### 🔧 Configuration Requise

#### Pour Développement
```bash
Flutter SDK: >=3.0.0 <4.0.0
Dart SDK: >=3.0.0 <4.0.0
Android Studio / VS Code
Xcode (pour iOS)
```

#### Organisation Android
```
packageName: com.quizz4u.quizz4u
applicationId: com.quizz4u
```

---

## 🚀 Installation et Déploiement

### 📲 Pour les Utilisateurs

**Google Play Store** (Soumission prochaine) 🚀
```
1. Recherchez "Quizz4u" sur le Play Store
2. Téléchargez et installez l'application
3. Ouvrez et commencez à jouer !

Version prête pour soumission Google Play Console
```

**App Store** (En développement)
```
À venir prochainement
```

### 💻 Pour les Développeurs

#### Installation
```bash
# Cloner le repository
git clone https://github.com/santultimate/Quizz4u.git
cd question_pour_toi

# Installer les dépendances
flutter pub get

# Vérifier la configuration
flutter doctor

# Lancer en mode debug
flutter run

# Build de production Android
flutter build appbundle --release

# Build de production iOS
flutter build ipa --release
```

#### Configuration AdMob
Mettre vos IDs AdMob dans `lib/services/ad_service.dart`:
```dart
static const String _androidBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String _iosBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
// ... autres IDs
```

#### Organisation du Projet
```bash
flutter create --org com.quizz4u .
```

---

## 🎯 Guide d'Utilisation

### 🎮 Comment Jouer

1. **Lancez l'application** et appuyez sur "Commencer"
2. **Choisissez une langue** (première utilisation)
3. **Sélectionnez une catégorie** qui vous intéresse
4. **Lisez la question** attentivement
5. **Choisissez votre réponse** parmi les 4 options
6. **Validez avant** la fin du timer (30 secondes)
7. **Consultez l'explication** après chaque réponse
8. **Terminez les 10 questions** de la partie
9. **Voyez votre score** et enregistrez-le
10. **Partagez** vos performances sur les réseaux sociaux !

### 🏆 Conseils pour un Bon Score

* ⚡ **Répondez rapidement** : Bonus de temps jusqu'à +10 points
* 📚 **Lisez attentivement** : Certaines questions ont des pièges
* 🎯 **Pratiquez régulièrement** : Série quotidienne = bonus XP
* 🌍 **Explorez toutes les catégories** : Bonus de diversité
* 🏅 **Débloquez des badges** : Objectifs supplémentaires
* 📊 **Consultez vos stats** : Identifiez vos points forts/faibles

### 🎖️ Débloquer des Badges

* **Expert** : 80%+ de bonnes réponses
* **Démon de Vitesse** : Répondre en moins de 10 secondes
* **Perfectionniste** : 100% de bonnes réponses
* **Polyglotte** : Jouer dans 3 langues différentes
* **Acharné** : Série de 7 jours consécutifs
* **Maître** : Atteindre le niveau 20
* ... et bien d'autres !

---

## 📊 Statistiques du Projet

### 📈 Base de Questions

| Métrique | Valeur |
|----------|--------|
| **Total questions FR** | 319 questions |
| **Catégories complètes (6 langues)** | 4 catégories (143 questions) |
| **Langues supportées** | 6 langues |
| **Total toutes langues** | 1,128 questions |
| **Questions traduites** | 858 questions (76%) |
| **En attente de traduction** | 176 questions (24%) |

### 💾 Taille et Performance

| Métrique | Valeur |
|----------|--------|
| **Bundle Android (AAB)** | 53.9 MB |
| **Code source Dart** | 524 KB |
| **Assets (images, sons)** | ~20 MB |
| **Temps de démarrage** | < 2 secondes |
| **Mémoire utilisée** | ~150 MB |

### 📊 Qualité du Code

| Aspect | Note |
|--------|------|
| **Architecture** | ⭐⭐⭐⭐⭐ 9/10 |
| **Lisibilité** | ⭐⭐⭐⭐ 8/10 |
| **Documentation** | ⭐⭐⭐⭐ 7/10 |
| **Tests** | ⭐⭐ 2/10 |
| **Performance** | ⭐⭐⭐⭐ 8/10 |
| **Stabilité** | ⭐⭐⭐⭐ 8/10 |

---

## 🔄 Historique des Versions

### Version 2.0.5 (Actuelle) - 29 Octobre 2025

#### ✅ Nouvelles Fonctionnalités
* ✅ **Fusion des questions** : +99 questions dans 3 catégories
* ✅ **Système multilingue** : 6 langues supportées
* ✅ **Sélection aléatoire améliorée** : Anti-répétition intelligent
* ✅ **Audio optimisé** : Service unifié sans conflits
* ✅ **Navigation sécurisée** : SafeNavigator anti-ANR

#### 🐛 Corrections
* ✅ **Audio** : Migration vers UnifiedAudioServiceOptimized
* ✅ **Scores** : Affichage correct en points ET pourcentage
* ✅ **Traductions** : Rechargement automatique au changement de langue
* ✅ **Chinois** : Traduction complète et corrections
* ✅ **Doublons** : Suppression de 66 questions dupliquées

#### ⚡ Optimisations
* ✅ **Taille projet** : Réduction de 1.5GB (60% de réduction)
* ✅ **Bundle AAB** : 53.9MB (taille idéale pour Play Store)
* ✅ **Services** : Architecture optimisée avec cache
* ✅ **Chargement** : Catégories essentielles en priorité
* ✅ **Code** : Suppression de 50+ fichiers inutiles

#### 📚 Base de Questions
* ✅ **Histoire du Mali** : 10 → 52 questions (+420%)
* ✅ **Culture Générale** : 10 → 45 questions (+350%)
* ✅ **Sciences** : 10 → 32 questions (+220%)
* ✅ **Total ajouté** : +99 questions de qualité

#### ⚠️ Problèmes Connus
* ⚠️ TTS temporairement désactivé (crashs détectés)
* ⚠️ Firebase non initialisé (notifications push désactivées)
* ⚠️ 176 questions en attente de traduction
* ⚠️ setState après dispose dans LoadingScreen (mineur)

### Version 2.0.0 - 24 Octobre 2025
* ✅ Refonte complète de l'interface
* ✅ Système de badges avancé
* ✅ AdMob en mode production
* ✅ Optimisation des performances
* ✅ Nettoyage du code

### Version 1.0.0 - Initial
* 🎉 Lancement initial
* 📚 200+ questions
* 🎮 5 catégories de base
* 🎵 Système TTS
* 🏆 Classement local

---

## 🛠️ Développement Futur

### 🔜 Prochaines Fonctionnalités (v2.1.0)

#### Haute Priorité
- [ ] **Traduction complète** : 176 questions restantes → 5 langues
- [ ] **Réactivation TTS** : Corriger les crashs détectés
- [ ] **Mode Premium complet** : Système d'achat fonctionnel
- [ ] **Firebase** : Initialisation et notifications push
- [ ] **Tests unitaires** : Couverture > 50%

#### Priorité Moyenne
- [ ] **Mode hors-ligne** : Toutes les fonctionnalités sans internet
- [ ] **Statistiques avancées** : Graphiques et analytics
- [ ] **Questions communautaires** : Contribution utilisateurs
- [ ] **Mode multijoueur** : Défis entre amis
- [ ] **Classement en ligne** : Leaderboard global

#### Améliorations UX
- [ ] **Onboarding** : Tutorial pour nouveaux utilisateurs
- [ ] **Achievements** : Système de récompenses étendu
- [ ] **Thèmes personnalisés** : Choix de couleurs
- [ ] **Animations** : Plus d'effets visuels
- [ ] **Accessibilité** : Support lecteurs d'écran

---

## 📞 Support et Contact

### 💬 Besoin d'Aide ?

* **📧 Email** : support@quizz4u.com
* **📱 WhatsApp** : +223 76 03 91 92
* **🌐 Site Web** : https://quizz4u.site/
* **📄 Documentation** : Voir fichiers AUDIT_*.md

### 🐛 Signaler un Bug

1. Vérifiez que le bug n'est pas déjà connu (voir section "Problèmes Connus")
2. Notez les étapes pour reproduire le bug
3. Incluez votre version Android/iOS
4. Envoyez un email détaillé à support@quizz4u.com

### 💡 Proposer une Fonctionnalité

Nous sommes ouverts à vos suggestions ! Contactez-nous par email avec:
* Description de la fonctionnalité
* Cas d'usage
* Mockups si possible

---

## 🤝 Contribution

### 👥 Comment Contribuer

Les contributions sont les bienvenues ! Voici comment participer:

1. **Fork** le projet
2. **Créez une branche** (`git checkout -b feature/AmazingFeature`)
3. **Committez** vos changements (`git commit -m 'Add AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrez une Pull Request**

### 📝 Guidelines de Contribution

* Code commenté en français
* Respecter l'architecture existante
* Tests unitaires pour nouvelles fonctionnalités
* Documentation à jour
* Commits clairs et descriptifs

### 🎓 Ajouter des Questions

Format JSON à respecter:
```json
{
  "question": "Votre question ?",
  "answers": {
    "Bonne réponse": true,
    "Mauvaise réponse 1": false,
    "Mauvaise réponse 2": false,
    "Mauvaise réponse 3": false
  },
  "explanation": "Explication de la réponse",
  "difficulty": "easy|medium|hard",
  "subcategory": "Sous-catégorie"
}
```

---

## 📄 Licence et Crédits

### 📜 Licence

Cette application est développée à des fins **éducatives et de divertissement**.  
Tous droits réservés © 2025 YACOUBA SANTARA

### 👏 Crédits

* **Développeur** : YACOUBA SANTARA
* **Design** : Material Design 3
* **Animations** : LottieFiles
* **Sons** : Ressources libres de droits
* **Questions** : Compilation et création originale

### 🙏 Remerciements

Merci à tous les testeurs et utilisateurs qui ont contribué à améliorer cette application !

---

## 📚 Documentation Technique

### 📖 Guides de Déploiement

* `CHECKLIST_DEPLOIEMENT_STORES.md` - Checklist complète de préparation aux stores
* `GUIDE_BUILD_OPTIMISE.md` - Guide de build pour production
* `GUIDE_DEPLOIEMENT_PLAY_STORE.md` - Guide spécifique Google Play
* `GUIDE_PAIEMENTS_PREMIUM.md` - Configuration des achats in-app

### 🔍 Analyses Disponibles

* ✅ Logique du jeu (scoring, timer, progression)
* ✅ Base de questions (structure, cohérence, qualité)
* ✅ Flux de navigation (SafeNavigator, routes)
* ✅ Performances et stabilité
* ✅ Système de traduction multilingue
* ✅ Architecture des services

---

## 🎮 Screenshots

_Screenshots à venir dans une prochaine mise à jour_

---

## 📊 Métriques de Projet

```
┌────────────────────────────────────────┐
│  QUIZZ4U - MÉTRIQUES GLOBALES          │
├────────────────────────────────────────┤
│  Version:          2.0.5+10            │
│  Langues:          6                   │
│  Questions:        1,128 (total)       │
│  Catégories:       10                  │
│  Services:         15+                 │
│  Écrans:           12                  │
│  Taille AAB:       ~50 MB (optimisé)   │
│  Lignes de code:   ~15,000             │
│  Statut:           Production-ready    │
└────────────────────────────────────────┘
```

---

**Développé avec ❤️ par YACOUBA SANTARA**

_Quizz4u - Apprenez en vous amusant !_ 🎓🎮

---

## 🔗 Liens Utiles

* [Flutter Documentation](https://flutter.dev/docs)
* [AdMob Integration](https://firebase.google.com/docs/admob)
* [Material Design 3](https://m3.material.io/)
* [Politique de Confidentialité](PRIVACY_POLICY.md)

---

🌟 **Si vous aimez Quizz4u, laissez une étoile sur GitHub !** ⭐
