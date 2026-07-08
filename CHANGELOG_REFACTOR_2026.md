# Changelog — Refactoring majeur (juillet 2026)

## Résumé

Session de consolidation **v2.0.5+10** : architecture de traduction unifiée, correction de 868 bugs `correctAnswer`, fix bannières AdMob, nettoyage du code legacy, et validation complète **323 questions × 6 langues**.

---

## 1. Architecture & code legacy

| Changement | Fichier(s) |
|------------|------------|
| Suppression `QuizScreen`/`QuizPage` legacy (~960 lignes) | `lib/main.dart` (146 lignes) |
| `TranslationService` → JSON uniquement (`assets/translations/*.json`) | `lib/services/translation_service.dart` |
| Backup Dart legacy pour resync | `lib/services/translation_service_legacy.dart` |
| `AutoQuestionTranslator` → stub (JSON par langue) | `lib/services/auto_question_translator.dart` |
| IDs stables sur toutes les questions | `lib/models/question_model.dart` |
| Historique anti-répétition via `id` | `lib/services/question_service_optimized.dart` |
| Défi quotidien → `QuestionServiceOptimized` | `lib/services/daily_challenge_service.dart` |

---

## 2. Traductions

### UI (433 clés × 6 langues)
- Source unique : `assets/translations/{fr,en,ar,zh,hi,es}.json`
- Fusion legacy Dart → JSON via `scripts/sync_ui_translations.py`

### Questions (323 × 6 langues = 1 615 paires)
- IDs assignés : `scripts/assign_question_ids.py`
- **868 `correctAnswer` corrigés** (réponses traduites mais clé FR) : `scripts/fix_correct_answers.py`
- Catégories expansion reconstruites (51 questions × 5 langues) : `scripts/rebuild_expansion_translations.py`
- Fichiers ZH dupliqués nettoyés (`马里历史`, `音乐`)
- Validation CI : `scripts/validate_translations.py`

### Statistiques finales
```
fr_questions: 323
translated_pairs: 1615
untranslated_identical: 0
invalid_questions: 0
✅ Toutes les traductions UI et questions sont valides
```

---

## 3. Gameplay & UX

| Paramètre | Avant | Après |
|-----------|-------|-------|
| Timer par défaut | 30 s hardcodé | `SettingsService.defaultTimerDuration` (25 s) |
| Délai entre questions | 1000 ms | 500 ms |
| Volume musique | 0.2 | 0.35 (constante centralisée) |
| Reprise musique après pub | immédiate | délai 500 ms |

---

## 4. Bannières publicitaires (AdMob)

| Bug corrigé | Détail |
|-------------|--------|
| Double `load()` | `createBannerAd()` + widget appelaient `load()` deux fois |
| Double `dispose` | `onAdFailedToLoad` + catch en conflit |
| Préférence ignorée | `SettingsService.isAdsEnabled()` non utilisée |
| Code dupliqué | `CategorySelectionScreen` utilise `AdBannerWidget` |

**Emplacements** : accueil (`home_bottom`), catégories (`category_selection`), résultats quiz (`quiz_results`).

---

## 5. Scripts de maintenance

| Script | Usage |
|--------|-------|
| `scripts/validate_translations.py` | Validation parité UI + questions (pre-release) |
| `scripts/assign_question_ids.py` | Assigner IDs FR → langues traduites |
| `scripts/fix_correct_answers.py` | Aligner `correctAnswer` sur la clé `true` |
| `scripts/rebuild_expansion_translations.py` | Reconstruire traductions expansion |
| `scripts/sync_ui_translations.py` | Fusionner traductions UI Dart → JSON |

---

## 6. Analyse finale

| Vérification | Résultat |
|--------------|----------|
| `flutter analyze lib` | **0 error** (906 info : `avoid_print`, `withOpacity` deprecated) |
| `scripts/validate_translations.py` | **✅ OK** |
| Compilation | OK |

### Hors périmètre (FR uniquement, legacy)
- `phase2_new_categories.json` (14 questions)
- `premium_questions_phase6.json` (22 questions)
- Non chargés par `QuestionServiceOptimized`

---

## 7. Fichiers principaux modifiés

```
lib/main.dart
lib/quiz_screen.dart
lib/category_selection_screen.dart
lib/widgets/ad_banner_widget.dart
lib/services/translation_service.dart
lib/services/ad_service.dart
lib/services/settings_service.dart
lib/services/question_service_optimized.dart
lib/models/question_model.dart
assets/translations/*.json
assets/questions/* (IDs + traductions + correctAnswer)
scripts/*.py
```
