# SŪRA — Architecture et choix techniques

Ce document est la **référence technique de l'équipe**. Il reprend les choix validés (cahier des charges, section 8, et document « Options techniques ») et signale les **3 ajustements** décidés pour tenir le délai.

---

## 1. Choix techniques

Légende : ✅ validé dans les documents · ⚙️ ajusté (voir `DECISIONS.md`) · 🔲 à confirmer

| Domaine | Choix | Statut | Responsable |
|---|---|---|---|
| Plateforme | Flutter / Dart, **Android** en priorité | ✅ | Tous |
| Architecture | Feature-first légère, pas de Clean Architecture stricte | ✅ | Lead |
| État | **Riverpod** (`flutter_riverpod`), providers écrits à la main | ⚙️ D-03 : sans `riverpod_generator` | Lead |
| Navigation | `go_router` | ✅ | Lead |
| Modèles | **Classes Dart écrites à la main** (`toJson`/`fromJson`/`copyWith`) | ⚙️ D-02 : sans `freezed` | Lead |
| Stockage local | **Drift** (SQLite typé). Seule source de vérité au quotidien | ✅ | Lead (F-02) |
| Chiffrement local | SQLCipher | ⚙️ D-04 : reporté en P2 | Membre 4 |
| Authentification | Firebase Auth (e-mail + mot de passe), 1ʳᵉ connexion en ligne | ✅ | Membre 4 |
| Déverrouillage | PIN 6 chiffres (biométrie en P2) | ✅ | Membre 4 |
| Synchronisation | File d'attente locale (`syncState`) → Cloud Firestore | ✅ | Membre 4 |
| Détection réseau | `connectivity_plus` (≠ Internet garanti) | ✅ | Membre 4 |
| Audio | package `record` | ✅ | Membre 2 |
| Transcription hors ligne | `whisper_edge`, repli `vosk_flutter`, repli final saisie manuelle | 🔲 test C-01 | Membre 2 |
| Extraction des champs | Règles et RegExp en Dart, explicables | ✅ | Membre 2 |
| Informations manquantes | Règles déterministes | ✅ | Membre 3 |
| Urgence | Règles à mots-clés, **raisons affichées**, validée par l'agent | ✅ | Membre 3 |
| QR | `qr_flutter` (affichage) + `mobile_scanner` (lecture). **Contient uniquement l'identifiant** | ✅ | Lead |
| Tests | Ciblés sur les parties sensibles (extraction, règles, PIN, synchro) | ✅ | Membre 3 |
| Stabilité | Crashlytics | ✅ en P2 | Membre 4 |

**Principe produit à ne jamais violer :** IA → proposition → l'agent vérifie → l'agent corrige → l'agent valide → sauvegarde. **L'IA ne décide jamais seule (R8).**

---

## 2. Structure du dépôt et propriété des dossiers

```
lib/
├── main.dart                               Lead (Membre 4 : init Firebase)
├── app/                                    Lead      router.dart, app.dart
├── core/                                   Lead      thème, widgets partagés, base Drift, utilitaires
│   ├── theme/ · widgets/ · db/ · utils/
├── domain/                                 CONTRATS — modification par PR « contract » uniquement
│   ├── models/                             enums, StructuredInfo, MissingItem, UrgencyProposal, records
│   ├── contracts/                          interfaces (repositories et services)
│   └── fakes/                              implémentations de développement
└── features/
    ├── home/ · patient/                    Membre 1
    ├── consultation/
    │   ├── flow/ · consent/                Membre 1   (parcours, consentement)
    │   ├── capture/                        Membre 2   (enregistrement, transcription, structuration)
    │   └── review/                         Membre 3   (manquants, urgence, récap, validation, sauvegarde)
    ├── auth/ · sync/ · settings/           Membre 4
test/                                       miroir de lib/ — chacun teste son code
test/fixtures/                              Membre 5 (D-03) — données fictives de démonstration
assets/ · docs/demo/                        Membre 5
.github/ · docs/                            Lead
```

Chaque propriétaire peut **créer librement des fichiers** dans ses dossiers. Il ne touche pas aux dossiers des autres sans accord.

---

## 3. Règles de dépendance

1. `domain/` est du **Dart pur** : il n'importe ni Flutter (UI), ni Drift, ni Firebase.
2. Les **écrans** parlent à des **providers**, qui parlent à des **contrats**. Jamais directement à Drift, Firebase ou un plugin.
3. Une feature **n'importe pas le code d'une autre feature**. Elle passe par `domain/` (contrats, modèles) ou par les providers publics.
4. Les écrans du parcours lisent et écrivent la consultation **uniquement via `ConsultationRepository`**.
5. Les règles métier (extraction, manquants, urgence) sont des **fonctions pures** : texte ou objets en entrée, résultat en sortie, sans I/O. C'est ce qui les rend testables.

---

## 4. Les contrats

| Contrat | Fichier | Producteur | Consommateurs |
|---|---|---|---|
| `PatientRepository` | `domain/contracts/patient_repository.dart` | Membre 1 (F-02) | M1, M4 (sync) |
| `ConsultationRepository` | `…/consultation_repository.dart` | Membre 1 (F-02) | M1, M2, M3, M4 |
| `AudioRecorderService` | `…/audio_recorder_service.dart` | Membre 2 (C-02) | M2 |
| `TranscriptionService` | `…/transcription_service.dart` | Membre 2 (C-03) | M2 |
| `InformationExtractor` | `…/information_extractor.dart` | Membre 2 (C-04) | M2, M3 (tests) |
| `MissingInfoChecker` | `…/missing_info_checker.dart` | Membre 3 (U-01) | M3 |
| `UrgencyScorer` | `…/urgency_scorer.dart` | Membre 3 (U-02) | M3 |
| `AuthService` | `…/auth_service.dart` | Membre 4 (S-02) | M1, M4 |
| `SyncService` | `…/sync_service.dart` | Membre 4 (S-04) | M1 (affichage), M3 (statut) |

**Modèles partagés** : `PatientRecord`, `ConsultationRecord`, `StructuredInfo`, `MissingItem`, `UrgencyProposal`, `PatientContext`, enums (`UrgencyLevel`, `SyncState`, `ConsentStatus`, `ConsultationStatus`).

### Brancher une vraie implémentation (le geste à retenir)
Chaque propriétaire a **un fichier de providers** avec une ligne par service. Exemple pour le Membre 2 :
```dart
// lib/features/consultation/capture/capture_providers.dart
final transcriptionServiceProvider =
    Provider<TranscriptionService>((ref) => WhisperTranscriptionService()); // était : FakeTranscriptionService()
```
Aucun écran ne change. Les autres membres continuent d'utiliser le fake jusqu'au merge.

---

## 5. Le parcours de consultation

```
Patient ──► Consentement ──► Enregistrement ──► Transcription ──► Structuré ──► Manquants ──► Urgence ──► Récap ──► Validation ──► Sauvegarde
 (M1)          (M1)             (M2)               (M2)            (M2)          (M3)         (M3)       (M3)       (M3)          (M3)
```
- Chemins : `/consultation/<id>/<étape>`. Étape suivante : `context.go(step.next!.path(id))` (voir `consultation_steps.dart`).
- Chaque écran **charge** le `ConsultationRecord`, **modifie** via `copyWith`, **sauvegarde** via le repository, puis navigue. L'état vit dans la base, pas dans l'écran : fermer l'application ne perd rien (R10, R12).
- **Reprise** : le champ `step` mémorise l'étape courante.

### Statuts de synchronisation (`SyncState`)
`offline` · `pending` (en attente) · `syncing` · `synced` · `error`. Un enregistrement validé passe en `pending`. L'état est **toujours visible** (R15) via `StatusChip`.

### Règles métier à respecter
| Règle | Où elle se vérifie |
|---|---|
| R1/R2 — identifiant unique ; le QR ne contient que l'identifiant | F-04, F-05 |
| R3 — **aucun enregistrement audio sans consentement** | C-02 refuse de démarrer si `consent != granted` |
| R4/R5 — transcription et champs corrigeables | C-03, C-04 |
| R6 — manquants = alertes, jamais blocages | U-01 |
| R7/R8 — urgence modifiable (motif obligatoire), l'agent valide seul | U-02, U-03 |
| R9 — sauvegarde locale **avant** synchronisation | U-03 (`markValidated`) |
| R10/R11/R12 — aucune perte, réessai possible, lecture hors ligne | F-02, S-04 |
| R13/R14 — pas de mot de passe en clair ; 1ʳᵉ connexion en ligne | S-02 |
| R15 — état de connexion/synchronisation toujours visible | F-03, S-06 |

---

## 6. Conventions de code

- `dart format .` avant chaque commit ; `flutter analyze` sans avertissement ; `flutter test` vert.
- Noms de fichiers en `snake_case.dart` ; classes en `PascalCase` ; un écran = `xxx_screen.dart`.
- Pas de logique métier dans les widgets : elle va dans une classe testable.
- Chaînes affichées en **français**. Messages d'erreur : ce qui s'est passé + quoi faire (« Pas de réseau. Vos données restent sur le téléphone. »).
- Pas de `print` : utiliser `debugPrint` et le retirer avant la PR.
- Tests : un fichier `xxx_test.dart` par unité, dans `test/` au même chemin que dans `lib/`.
- Pas de nouvelle dépendance sans en parler au lead (voir guide §4.5).

---

## 7. Fakes et mode développement

Tant qu'un service réel n'est pas livré, l'application fonctionne avec un **fake** (texte de consultation simulé, extraction simulée, urgence « modérée » simulée, patients de démonstration). Le menu d'accueil provisoire permet de lancer **tout le parcours dès le premier jour**. Les fakes restent dans le dépôt : ils servent aussi aux tests.

---

## 8. Décisions ouvertes : valeurs par défaut proposées

Pour que personne ne soit bloqué, voici le comportement **par défaut** tant que l'équipe n'a pas tranché (numérotation de la spécification, section 16). **Provisoire : le lead confirme ou change, puis consigne dans `DECISIONS.md`.**

| # | Sujet | Défaut proposé |
|---|---|---|
| 6 | Sécurité du PIN | 6 chiffres · 5 essais puis blocage progressif (30 s, doublé à chaque échec, max 15 min) · verrouillage après 60 s en arrière-plan · pas de verrouillage pendant un enregistrement actif |
| 7 | PIN oublié | On efface le PIN et on exige le mot de passe (en ligne). **Les données locales sont conservées.** |
| 8 | Refus de consentement | Pas d'enregistrement audio. Saisie manuelle possible, le refus est tracé. « Micro refusé » traité de la même façon. |
| 9 | Identifiant de connexion | E-mail uniquement pour le MVP |
| 10 | Champs d'identité agent | Prénom, nom, téléphone (facultatif), district, poste, rôle. Identifiant agent généré. |
| 11 | Langues | Français uniquement |
| 12 | Thème sombre | Hors périmètre |
| 13 | Nourrissons | Âge en années uniquement pour le MVP |
| 14 | Constantes | Température et pouls facultatifs, extraits s'ils sont dictés |
| 15 | Patient créé hors ligne | Synchronisé **avant** ses consultations, dans la même file |
| 16 | Plusieurs agents par téléphone | Un seul agent par appareil |
| 17-19 | Stockage plein, journal d'audit, références R1–R15 | Hors périmètre du MVP |
| — | Audio | Reste sur le téléphone, jamais synchronisé |
