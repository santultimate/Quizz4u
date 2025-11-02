# 🔐 Guide de Sécurité Firebase

## 📋 État Actuel

Les fichiers suivants contiennent des clés API Firebase :
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

**Status**: ✅ Ces fichiers ont été commités dans Git et sont publics sur GitHub.

---

## ✅ Sécurité Firebase - Bonnes Pratiques

### 🔑 Types de Clés Firebase

Les clés Firebase dans les apps mobiles sont de **2 types** :

#### 1. ✅ Client App Keys (SÉCURISÉES - OK pour GitHub)
- **Localisation**: `firebase_options.dart`, `google-services.json`
- **Usage**: Intégration dans les apps mobiles
- **Public**: OUI, normalement publiques
- **Sécurité**: Restrictions côté Firebase

#### 2. ❌ Service Account Keys (CRITIQUES - JAMAIS sur GitHub)
- **Localisation**: Généralement `.json` (clés privées)
- **Usage**: Backend, admin operations
- **Public**: NON, doit rester SECRET
- **Sécurité**: Pas de restrictions publiques

---

## 🛡️ Restrictions Firebase (OBLIGATOIRE)

### ✅ Actuellement Configuré

Notre config actuelle :
```dart
// lib/firebase_options.dart
android:
  apiKey: 'AIzaSyDKPyfPY6xpOWeB3IN4cV_moXpTgqJ96U0'
  appId: '1:431660199679:android:061ab84c20330f4a69e6ca'
  package_name: 'com.quizz4u.app'
```

### ⚠️ ACTIONS REQUISES

**Firebase Console** → **Project Settings** → **General**

#### 1. Vérifier Restrictions API Keys

```
Firebase Console → API Keys → Restrictions

Pour chaque API Key (Android/iOS):
  ✅ Application restrictions
     → Android apps
     → Package name: com.quizz4u.app
     → SHA-256: [votre certificat]
  
  ✅ API restrictions
     → Restrict key
     → Select APIs: 
        • Firebase Dynamic Links
        • Firebase Cloud Messaging
        • Firebase Authentication
```

#### 2. Vérifier App Check

```
Firebase Console → App Check → Apps

Pour chaque app:
  ✅ Play Integrity (Android)
  ✅ DeviceCheck/AppAttest (iOS)
```

---

## 🔍 Vérification Sécurité

### ✅ CHECKLIST

- [ ] Restrictions package name configurées
- [ ] Restrictions SHA-256 configurées
- [ ] API restrictions activées
- [ ] App Check configuré (optionnel mais recommandé)
- [ ] Alertes billing activées
- [ ] Monitoring usage configuré

### 🚨 Si Clé Compromise

1. **Immediate**: Révoquer la clé Firebase Console
2. **Régénérer**: `flutterfire configure` pour nouvelles clés
3. **Mettre à jour**: Commit nouvelles clés
4. **Audit**: Vérifier usage anormal
5. **Roter**: Changer toutes les clés liées

---

## 📊 Monitoring

### Firebase Console Monitoring

```
Firebase Console → Usage and Billing → Monitoring

Surveiller:
  • Usage anormal
  • Coûts inattendus
  • Accès non autorisés
```

### Alertes Recommandées

- Email alert si > 100% usage baseline
- Email alert si coûts > seuil défini
- Email alert si usage suspect

---

## 🎯 Recommandation Finale

### ✅ ACTUEL: KEEP FILES PUBLIC

**Raison**: 
- Ces clés sont normales pour apps mobiles
- Tous les utilisateurs les voient dans l'APK
- Sécurité par **restrictions** pas par **cachage**

### ✅ ACTIONS IMMÉDIATES

1. **Vérifier restrictions** dans Firebase Console
2. **Activer monitoring** et alertes
3. **Documenter** restrictions configurées
4. **Formation équipe** sur bonne pratiques

### ⚠️ SI VOULEZ CACHER (Alternative)

Si vous préférez cacher malgré tout :

1. **Ajouter au .gitignore**:
   ```gitignore
   lib/firebase_options.dart
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```

2. **Créer templates**:
   ```bash
   lib/firebase_options.dart.template
   android/app/google-services.json.template
   ```

3. **Documenter**:
   ```bash
   SETUP.md avec instructions
   Copier les templates et configurer
   ```

**Avantages**: 
- Plus "paranoïaque" sécurisé
- Empêche fuite accidentelle

**Inconvénients**:
- Build plus complexe
- Collaboration plus difficile
- Moins standard pour Flutter/Firebase

---

## 📚 Ressources

- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Firebase App Check](https://firebase.google.com/docs/app-check)
- [Google API Key Best Practices](https://cloud.google.com/docs/authentication/api-keys)

---

**Dernière mise à jour**: Novembre 2025  
**Version**: 2.0.5+10

