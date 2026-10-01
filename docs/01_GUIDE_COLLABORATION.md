# SŪRA — Guide de collaboration

**Équipe de 5 · Hackathon FlutterFire Summer Camp 2026 · Soumission avant le lundi 5 octobre 2026, 23h59**
Version 1 — 1er octobre 2026. Ordre de lecture : ce guide → `02_ARCHITECTURE_ET_CHOIX.md` → votre section de `03_REPARTITION_TACHES.md`.

---

## 1. Les 9 règles d'or

1. **Une tâche = une issue = une branche = une Pull Request** relue par un autre membre (cahier des charges).
2. **On ne pousse jamais directement sur `main` ni `develop`.**
3. **PR petites** (idéalement moins de 400 lignes), ouvertes tôt (en *Draft*), fusionnées **le jour même**.
4. **Chacun ne modifie que ses dossiers** (voir `02`, §2). Besoin ailleurs ? Message au propriétaire ou issue.
5. **Les contrats ne changent que par une PR dédiée** (label `contract`) approuvée par le lead et annoncée au groupe.
6. **On développe contre les fakes**, puis on branche le vrai en changeant une ligne de provider. Personne n'attend personne.
7. **`develop` compile et passe les tests, toujours.** CI rouge = priorité absolue de l'auteur du dernier merge.
8. **Aucune donnée réelle de patient, aucun secret** dans le dépôt, les captures ou les vidéos.
9. **Bloqué plus de 30 minutes = on le dit** dans le groupe, avec le tag `[BLOQUÉ]`.

---

## 2. Rôles et relecture croisée

| Membre | Nom | Module | Relu par |
|---|---|---|---|
| 1 — **Lead** | ____ | Fondations, patients, consentement · **gardien du dépôt Git** | Membre 4 |
| 2 | ____ | Consultation : enregistrement, transcription, structuration | Membre 3 |
| 3 | ____ | Checklist, urgence, récapitulatif/validation, tests | Membre 2 |
| 4 | ____ | Authentification, PIN, synchronisation, Firebase | Membre 1 |
| 5 | ____ | Charte graphique, maquettes, pitch, démo, données de démonstration | Membre 1 |

Le lead a le dernier mot sur l'architecture et les contrats. Il ne relit pas tout : la relecture croisée ci-dessus est la règle.

---

## 3. Calendrier (compressé sur 4 jours)

| Date | Objectif | Version | Point clé |
|---|---|---|---|
| **Jeu 1 oct (soir)** | Squelette publié, Firebase créé, test de transcription lancé | v0.0 | `develop` compile · tout le monde a lancé l'app |
| **Ven 2 oct** | **Sprint 1** : chaque module contre les fakes | v0.1 | Intégration 20:00 |
| **Sam 3 oct** | **Sprint 2 (1/2)** : on branche le réel (base locale, transcription, extraction, auth) | v0.5 | Intégration 20:00 · **point de contrôle 22:00** |
| **Dim 4 oct** | **Sprint 2 (2/2)** : synchronisation, PIN, erreurs, tests ≥ 20 | v0.9 | **Gel des fonctionnalités à 22:00** |
| **Lun 5 oct** | Gel du code **12:00** · corrections de bugs uniquement · test sur 2 téléphones en mode avion 14:00 · APK · vidéo/pitch | v1.0 | **Soumission visée à 20:00** (marge de 4 h) |

**Point de contrôle de samedi 22:00 :** le parcours complet (patient → consultation → validation → sauvegarde locale) doit fonctionner de bout en bout sur au moins un téléphone. Sinon, on applique le **plan de coupe** (§8) le soir même.

---

## 4. Git au quotidien

### 4.1 Branches
- `main` : version démontrable (tags v0.1, v0.5, v0.9, v1.0).
- `develop` : intégration. Toutes les PR visent `develop`.
- `feature/<ID>-<slug>` : une tâche. Ex. `feature/F-04-creation-patient`.
- `fix/<slug>` : correction. Ex. `fix/crash-scan-qr`.

### 4.2 Cycle d'une tâche
```bash
git checkout develop && git pull
git checkout -b feature/F-04-creation-patient

# ... coder ...
dart format .
flutter analyze
flutter test

git add -A
git commit -m "feat(patient): création patient avec identifiant SUR-XXXX-XXXX (F-04)"
git push -u origin feature/F-04-creation-patient
# puis ouvrir la PR vers develop sur GitHub
```
**Commits** : `feat|fix|test|docs|chore(portée): message (ID)`.

### 4.3 Rester à jour (au moins chaque matin)
```bash
git fetch origin
git merge origin/develop      # ou: git rebase origin/develop si vous le maîtrisez
```
Pas de `git push --force` sur une branche que quelqu'un d'autre utilise.

### 4.4 Pull Request
1. Cible : `develop`. Remplir le modèle de PR (il s'affiche tout seul).
2. CI verte, **1 approbation** du relecteur désigné au §2.
3. Fusion en **Squash and merge**, puis suppression de la branche.
4. **Délai de relecture : 2 h maximum** en journée. Relire = lancer la branche si possible, pas seulement lire le code.

Le relecteur vérifie : la tâche est faite · les règles R1–R15 concernées sont respectées · pas de fichier hors périmètre · des tests existent pour la logique · pas de secret ni de donnée réelle.

### 4.5 Fichiers à risque
| Fichier | Règle |
|---|---|
| `pubspec.yaml` / `pubspec.lock` | Le lead pré-installe les dépendances communes. Ajout d'une dépendance : PR **séparée et minuscule**, fusionnée tout de suite. En cas de conflit sur `pubspec.lock` : prenez la version de `develop`, puis `flutter pub get`. |
| `lib/app/router.dart` | **Ne pas modifier.** Toutes les routes existent déjà. Exceptions : Membre 4 (logique `redirect`), Membre 1 (coque de navigation). |
| `lib/domain/contracts/`, `lib/domain/models/` | PR dédiée, label `contract`, annonce `[CONTRAT]` au groupe. |
| `android/app/src/main/AndroidManifest.xml` | Permissions déjà ajoutées. Autre changement : prévenir le lead. |
| `*.g.dart` (Drift) | Générés : on les **commite**. Après un changement de schéma : `dart run build_runner build --delete-conflicting-outputs`. |

### 4.6 Conflit de fusion
Ne paniquez pas et ne forcez rien. `git status` → ouvrir les fichiers marqués → garder les deux intentions → `flutter analyze && flutter test` → `git add` → `git commit`. Pas sûr de vous ? Appelez le propriétaire du fichier.

---

## 5. Rythme de l'équipe

| Rituel | Quand | Format |
|---|---|---|
| **Stand-up** | Chaque jour, 9:00 | 10 min max. Hier · aujourd'hui · blocages. |
| **Intégration** | Chaque soir, 20:00 | Le lead lance `develop` sur un téléphone. Chacun montre son apport en 2 min. Bugs d'intégration créés en issues. |
| **Revue de sprint** | Fin de sprint | Démo du parcours + décisions pour la suite. |

**Messages** : un seul groupe, avec des tags : `[BLOQUÉ]` · `[CONTRAT]` · `[CI]` · `[DÉCISION]` · `[INFO]`.
**Décisions** : toute décision prise à l'oral est notée dans `docs/DECISIONS.md` par celui qui la porte. Pas de trace = pas de décision.

---

## 6. Définition de « terminé »

Une tâche est terminée si, et seulement si :
- [ ] les règles fonctionnelles concernées (R1–R15) sont respectées ;
- [ ] `dart format .`, `flutter analyze`, `flutter test` passent ;
- [ ] la logique a des tests (extraction, règles, PIN, synchronisation…) ;
- [ ] ça marche **hors ligne** si la fonctionnalité le demande ;
- [ ] testé sur un **vrai téléphone** quand il y a micro, caméra ou stockage ;
- [ ] aucune donnée réelle, aucun secret ;
- [ ] PR approuvée et fusionnée dans `develop`.

---

## 7. Qualité, sécurité, données

- **Données de test** : uniquement fictives (voir `test/fixtures/`). Jamais d'audio réel de patient dans Git.
- **Secrets** : jamais de clé de compte de service, de `.env` ou de mot de passe. Les fichiers de configuration client Firebase sont gérés par le Membre 4 selon la consigne du lead.
- **Interface** : l'urgence n'est jamais indiquée par la couleur seule (forme + texte + couleur) ; zones tactiles ≥ 48 dp ; chiffres alignés pour les identifiants.
- **Texte** : interface en français pour le MVP.
- **Audio** : reste sur le téléphone ; jamais envoyé à Firestore (valeur par défaut, voir `02` §8).

---

## 8. Plan de coupe : quand on prend du retard

| Priorité | Contenu |
|---|---|
| **P0 — indispensable à la démo** | Créer/rechercher un patient · QR affiché · consentement · saisie/transcription (au pire manuelle) · structuration · informations manquantes · urgence · validation · **sauvegarde locale** · statut de synchronisation visible |
| **P1 — important** | Connexion Firebase · synchronisation réelle · PIN · test mode avion sur 2 téléphones · 20 tests |
| **P2 — si le temps le permet** | Scan de QR · chiffrement SQLCipher · historique/dossier détaillé · Crashlytics · réglages avancés |

**Ordre de coupe : P2 d'abord, puis une partie de P1** (par exemple synchronisation réduite à un bouton « Envoyer »). **On ne coupe jamais P0.**
Si vous craignez de ne pas tenir votre échéance : dites-le **tout de suite**, pas à la veille.

---

## 9. Indicateurs de réussite (cahier des charges)

| Indicateur | Cible |
|---|---|
| PR fusionnées par membre | 5 ou plus |
| Tests automatisés | 20 ou plus, CI verte |
| Parcours complet en mode avion | Sans erreur sur 2 téléphones |
| Scénarios de démo réussis | 3 sur 3 |
