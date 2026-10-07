# SŪRA : assistant de consultation hors ligne pour agents de santé

**Principe :** *SŪRA propose, l'agent vérifie et valide.* L'application ne pose jamais de diagnostic.
Elle aide un agent de santé de première ligne à documenter une consultation (patient, consentement, voix ou saisie manuelle,
informations structurées, niveau d'urgence), **sans connexion Internet**, puis synchronise avec Firebase au retour du réseau.

ODD visé : **ODD 3, bonne santé et bien-être.** MVP réalisé pour le FlutterFire Summer Camp 2026 (hackathon). Données de test uniquement.

## 1. Ce que fait l'application (état réel)

| Domaine | Fonctionnement |
|---|---|
| Compte | Inscription complète (e-mail, mot de passe confirmé, identité, affectation, rôle, engagement de confidentialité) ; page « mot de passe oublié » ; Firebase Auth seulement à la première connexion |
| Verrouillage | PIN à 6 chiffres (empreinte salée), biométrie facultative, verrouillage progressif après 5 échecs, bouton **Verrouiller maintenant** (Paramètres) |
| Patients | Création (identifiant `SUR-AAAA-XXXXXXXX` automatique), recherche, dossier, QR du carnet (identifiant opaque), lecture du QR ou saisie de l'identifiant |
| Consultation | **8 étapes** : consentement, enregistrement, transcription, informations, manquantes, urgence, récapitulatif, validation |
| Refus du patient | **Saisie manuelle (6 étapes)** : symptômes à cocher, durée, température, allergies/traitement ; **estimation de l'urgence en direct** ; le refus est consigné |
| Transcription | Locale (Vosk) si `kUseRealStt = true`, sinon texte de démonstration. **Mode connecté facultatif** (IA distante, désactivé par défaut). Toujours modifiable |
| Structuration | Règles explicables : symptômes (avec synonymes), durée (chiffres ou lettres), température (chiffres ou lettres) |
| Informations manquantes | Alertes seulement : ne bloquent jamais la consultation |
| Urgence | Proposition par règles **de démonstration** (non validées cliniquement), relue sur les symptômes en saisie vocale comme manuelle ; l'agent peut la modifier ; sa décision prime |
| Validation | Checklist de 5 points ; l'IA ne valide jamais seule |
| Hors ligne | Base locale (Drift/SQLite) ; aucune perte en cas de coupure |
| Synchronisation | Automatique au retour du réseau ; reprise par dossier ; statuts ○ en attente, ⟳ en cours, ✓ synchronisé, ⚠ erreur |
| Profil | Accueil personnalisé (« Bonjour, Prénom »), fiche consultable, modifiable et complétable hors ligne, jauge de complétion, statistiques |
| Réglages | Thème clair/sombre, sécurité, changement de PIN, stockage, mode connecté, à propos ; filtres des consultations |

## 2. Architecture

```
Interface Flutter (écrans, thème clair/sombre, go_router)
        │
   Riverpod (état)
        │
 Services : ConsultationService · SyncService · AuthService · ProfileService · SpeechEngine (Vosk | Cloud)
        │                          │
 Drift / SQLite (source de vérité)  └──► Firebase (Auth + Firestore, agents/{uid}/...)
```

`lib/features/<domaine>` (auth, patients, consultation, sync, profile, settings, home) · `lib/core` (thème, composants, routage) ·
`lib/domain` (règles métier en Dart pur, testées) · `lib/data` (base locale). Navigation : barre du bas masquée pendant la consultation.

## 3. Interrupteurs de configuration (`lib/core/config.dart`)

| Constante | Valeur | Effet |
|---|---|---|
| `kUseFirebase` | `false` (démo) / `true` | Connexion et envoi réels vers Firebase, ou simulés |
| `kUseRealStt` | `false` / `true` | Texte de démonstration, ou reconnaissance vocale locale réelle |
| `kDbEncrypted` | `false` | **Informatif** : le chiffrement de la base n'est pas activé dans cette version |
| `kUploadTranscript` | `false` | Envoyer ou non le texte corrigé à Firestore |
| `kRodiumKey` | fournie à la compilation | Clé du **mode connecté** (jamais dans le dépôt) |

## 4. Installation
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # génère lib/data/database.g.dart (Drift)
flutter analyze
flutter test                                               # 76 tests unitaires
flutter run -d <id-du-téléphone>
```
Android : `minSdk` 23 ou plus (24 si Gradle le demande) ; permissions `INTERNET`, `RECORD_AUDIO`, `CAMERA`, `USE_BIOMETRIC` ;
`MainActivity` étend `FlutterFragmentActivity` (biométrie).

## 5. Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure                       # génère lib/firebase_options.dart
firebase deploy --only firestore:rules      # publie firestore.rules
```
Puis `kUseFirebase = true`. Contrôle : une consultation validée apparaît sous `agents/{uid}/consultations` ; un second compte ne lit pas les données du premier.

## 6. Reconnaissance vocale
**Locale (par défaut)** :
```bash
mkdir -p assets/models
wget -P assets/models https://alphacephei.com/vosk/models/vosk-model-small-fr-0.22.zip   # ne pas décompresser
flutter pub add vosk_flutter      # puis kUseRealStt = true et redémarrage complet
```
Qualité moyenne en français médical : la transcription est **toujours modifiable**.

**Mode connecté (facultatif, désactivé par défaut)** : avec Internet, l'audio est envoyé à un service d'IA externe (Rodium AI,
modèle `openai/gpt-4o-mini-transcribe` par défaut) puis supprimé de l'appareil. Il demande un compte Rodium **disposant de crédits RODI** :
```bash
flutter run -d <id> --dart-define=RODIUM_KEY=$RODIUM_KEY [--dart-define=RODIUM_STT_MODEL=openai/gpt-4o-transcribe]
```
La clé ne doit jamais être versionnée ; elle reste extractible d'un APK : utiliser une clé dédiée et la révoquer après le hackathon.
Le consentement du patient indique l'envoi de l'audio quand ce mode est actif.

## 7. APK de démonstration
```bash
flutter build apk --release --dart-define=RODIUM_KEY=$RODIUM_KEY     # sans la clé : mode connecté indisponible
adb install -r build/app/outputs/flutter-apk/app-release.apk
flutter build apk --debug                                            # APK de secours
```
Si l'APK release plante au lancement de l'enregistrement : `isMinifyEnabled = false` dans le bloc `release` de `android/app/build.gradle(.kts)`.

## 8. Confidentialité et données
- **Sur l'appareil :** patients, consultations, profil, préférences. Aucune donnée réelle dans ce dépôt.
- **Envoyé à Firebase :** patients et consultations validées (champs structurés, urgence, consentement), profil de l'agent.
- **Audio :** jamais conservé. Par défaut il reste sur l'appareil ; en **mode connecté** facultatif il est envoyé à un service d'IA externe pour la transcription, puis supprimé.
- **QR du carnet :** identifiant opaque, aucune donnée médicale.
- **Consentement :** obligatoire avant tout enregistrement ; un refus est consigné et mène à la saisie manuelle.

## 9. Limites connues (par honnêteté)
1. **Chiffrement de la base locale non activé** (prévu : SQLCipher). Le PIN protège l'accès à l'interface, pas les fichiers.
2. **Restauration après réinstallation :** le profil, les patients et les consultations déjà envoyés sont ré-importés depuis Firebase (automatiquement si l'appareil est vide, ou via Paramètres → Synchronisation → « Restaurer depuis le serveur »). Les brouillons, les consultations jamais envoyées et les transcriptions ne sont pas récupérables.
3. **Seuils d'urgence de démonstration :** à faire valider par des professionnels de santé (PCIME/OMS) avant tout usage réel.
4. **Reconnaissance vocale locale de qualité moyenne** ; le mode connecté dépend de crédits et d'Internet.
5. Non réalisés : « PIN oublié » complet, langues locales, notifications, aide intégrée, photo de profil, plusieurs agents sur un téléphone.
6. Testé sur Android uniquement. En mode démo (`kUseFirebase = false`), la synchronisation est simulée.

## 10. Feuille de route
Chiffrement SQLCipher · validation clinique des règles d'urgence ·
langues locales · constantes (tension, pouls, SpO₂) · structuration par IA · tableau de bord pour les structures de référence.

## 11. Documents
`docs/DEMO.md` (démonstration) · `docs/PITCH.md` (pitch et questions du jury) · cahier des charges v3 · choix techniques v3 · `firestore.rules`.
