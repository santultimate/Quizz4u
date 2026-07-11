# 📋 CHECKLIST Déploiement Stores — Quizz4U

**Dernière mise à jour**: 10 juillet 2026  
**Version**: 2.0.7+12  
**Package**: `com.quizz4u.app`

---

## ✅ Verdict actuel

**OUI — prêt pour soumission Google Play**, sous réserve de vérifier dans Play Console :

1. Produit IAP `premium_lifetime` actif et lié à l'app
2. Description store alignée (voir `PLAY_STORE_DESCRIPTION.md`)
3. Privacy policy URL accessible

Les traductions ne sont **plus** des stubs : 500 questions × 6 langues validées.

---

## Pré-vol rapide

| Check | Statut |
|-------|--------|
| Questions FR valides (500) | ✅ `scripts/validate_category_shuffle.py` |
| Traductions questions (0 stubs) | ✅ `scripts/validate_translations.py` |
| 12 catégories actives | ✅ |
| UI i18n 6 langues (433 clés) | ✅ |
| AdMob prod + `kDebugMode` test | ✅ |
| IAP unique : `EnhancedPurchaseService` → `premium_lifetime` | ✅ |
| `POST_NOTIFICATIONS` (Android 13+) | ✅ |
| AAB signé release | ✅ `flutter build appbundle --release` |
| Version UI / pubspec / gradle | ✅ 2.0.7+12 |

---

## À faire dans Play Console (manuel)

- [ ] Coller short/full description FR + EN depuis `PLAY_STORE_DESCRIPTION.md`
- [ ] Confirmer le produit `premium_lifetime` (achat unique)
- [ ] Captures d'écran à jour
- [ ] Notes de version 2.0.7 (ex. : 500 questions, 12 catégories, mode révision, correctifs pubs/IAP)

---

## Notes

- L'ancien checklist d'octobre 2025 (stubs de traduction) est **obsolète**.
- Ne pas annoncer multiplayer réseau / cloud backup tant que non branchés.
- Fichiers `phase2_new_categories.json` et `premium_questions_phase6.json` restent hors bundle production.
