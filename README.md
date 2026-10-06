# SŪRA

**Assistant de consultation hors connexion pour les agents de santé communautaires.**
Hackathon FlutterFire Summer Camp 2026 · ODD 3 : bonne santé et bien-être.

---

## Le problème

Dans les zones isolées, les agents de santé travaillent souvent avec des dossiers papier et une connexion Internet rare ou absente. Les informations se perdent, les consultations sont notées de façon incomplète, et il est difficile de repérer à temps un patient qui a besoin d'une prise en charge urgente.

## La solution

SŪRA transforme le téléphone de l'agent en assistant qui **fonctionne sans réseau**. Pendant ou après la consultation, l'application aide à :

1. noter la consultation (enregistrement, transcription, saisie manuelle) ;
2. **structurer** les informations (motif, symptômes, durée, constantes, allergies, médicaments, antécédents) ;
3. **signaler les informations qui semblent manquer** ;
4. **proposer un niveau d'urgence**, avec ses raisons ;
5. faire **valider le dossier par l'agent** ;
6. **synchroniser** les données dès qu'une connexion est disponible.

### Le principe à retenir

> L'application propose, l'agent vérifie, corrige et valide. **L'application ne décide jamais seule.**

- Tout ce qui est proposé est **modifiable** par l'agent.
- Les informations manquantes sont des **alertes**, jamais des blocages.
- Le niveau d'urgence est une **aide** : l'agent peut le changer, avec un motif obligatoire.
- Le dossier n'est enregistré comme validé que si l'agent coche **les 5 confirmations**.
- Les consignes affichées sont des constats (« Cette information semble manquer… »), jamais des ordres.

## Confidentialité

- Les données sont enregistrées **d'abord sur le téléphone**, puis synchronisées.
- **L'audio reste sur le téléphone** : il n'est jamais envoyé en ligne.
- Un enregistrement n'est possible **qu'après le consentement** du patient.
- Le QR code d'un patient ne contient que son identifiant.
- L'accès à l'application est protégé par une connexion, puis par un code PIN.
- Le dépôt ne contient **aucune donnée réelle de patient** : les scénarios de démonstration sont fictifs.

---

## Fonctionnalités

| Fonctionnalité | État |
|---|---|
| Connexion agent (e-mail, mot de passe) et code PIN | ✅ |
| Création, recherche et dossier des patients, identifiant `SUR-XXXX-XXXX` | ✅ |
| QR code du patient (identifiant seul) | ✅ |
| Consentement horodaté, refus tracé | ✅ |
| Stockage local persistant (Drift / SQLite), lecture hors ligne | ✅ |
| Informations manquantes (règles explicables) | ✅ |
| Niveau d'urgence avec raisons, modifiable avec motif | ✅ |
| Récapitulatif, validation par 5 cases, sauvegarde locale | ✅ |
| Synchronisation Firestore (patients avant consultations, réessai, aucune perte) | ✅ |
| Règles de sécurité Firestore (un agent ne voit que ses données) | 🟡 écrites, déploiement et test à confirmer |
| Enregistrement audio, transcription et extraction automatique | 🚧 en cours d'intégration |
| Scan de QR code, chiffrement de la base | ⏳ si le temps le permet |

La liste des tâches et leur avancement se trouvent dans [docs/03_REPARTITION_TACHES.md](docs/03_REPARTITION_TACHES.md).

## Le parcours d'une consultation

```
Patient → Consentement → Enregistrement → Transcription → Informations structurées
        → Informations manquantes → Niveau d'urgence → Récapitulatif → Validation → Sauvegarde
```

Chaque étape est enregistrée sur le téléphone : fermer l'application ne fait perdre aucune donnée, et la consultation peut être reprise.

---

## Installation

### Prérequis
- [Flutter](https://docs.flutter.dev/get-started/install) (canal stable, Dart `^3.12.2`)
- Un téléphone Android ou un émulateur
- Un compte GitHub avec accès au dépôt

### Lancer l'application
```bash
git clone https://github.com/rootusr404/sura.git
cd sura
git checkout develop
flutter pub get
flutter run
```
La première connexion d'un agent se fait **en ligne** (Firebase). Ensuite, l'application fonctionne sans réseau.

### Vérifier le code
```bash
dart format .
flutter analyze
flutter test
```

### Construire l'APK
```bash
flutter build apk --release
```
Le fichier se trouve ensuite dans `build/app/outputs/flutter-apk/app-release.apk`.

### Si le schéma de la base de données change
Les fichiers générés par Drift sont versionnés. Après une modification du schéma :
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Architecture en bref

- **Flutter**, une structure par fonctionnalité (`lib/features/`), **Riverpod** pour l'état, **go_router** pour la navigation.
- **Drift** (SQLite) est la source de vérité sur le téléphone.
- **Firebase** : authentification par e-mail, **Cloud Firestore** pour la synchronisation.
- `lib/domain/` contient les **contrats** (interfaces) et les modèles partagés. Chaque module est développé contre ces contrats, avec des versions simulées (« fakes ») remplaçables en une ligne.
- Les règles métier (informations manquantes, urgence) sont des **fonctions pures et testées**.

Détails : [docs/02_ARCHITECTURE_ET_CHOIX.md](docs/02_ARCHITECTURE_ET_CHOIX.md).

## Démonstration

Trois scénarios fictifs (urgence faible, modérée, élevée) sont décrits dans [docs/demo/SCENARIOS.md](docs/demo/SCENARIOS.md). Le plan de test complet, y compris le parcours en **mode avion**, est dans [docs/recette/PLAN_DE_RECETTE.md](docs/recette/PLAN_DE_RECETTE.md) (une fois la branche principale synchronisée). Le texte de présentation est dans [docs/demo/PITCH.md](docs/demo/PITCH.md).

## Documentation de l'équipe

- [Guide de collaboration](docs/01_GUIDE_COLLABORATION.md)
- [Architecture et choix techniques](docs/02_ARCHITECTURE_ET_CHOIX.md)
- [Répartition des tâches](docs/03_REPARTITION_TACHES.md)
- [Journal des décisions](docs/DECISIONS.md)
- [Synchronisation](docs/S-04_SYNCHRONISATION.md) · [Règles Firestore](docs/S-05_FIRESTORE_RULES.md)

---

## Limites connues

À lire avant d'évaluer le projet :

- **Ce n'est pas un dispositif médical.** SŪRA est un prototype de hackathon. Les règles d'urgence sont des règles à mots-clés simples, **pas une évaluation médicale**, et doivent être relues par des professionnels de santé avant tout usage réel.
- **L'audio, la transcription et l'extraction automatique** sont encore en cours d'intégration. En attendant, la saisie manuelle reste le chemin de repli : le reste du parcours est identique.
- Si le moteur de transcription local n'est pas disponible ou échoue, l'application bascule sur la **saisie manuelle**.
- L'interface est **uniquement en français**, l'âge est saisi **en années** (pas de nourrissons en mois), et il y a **un seul agent par téléphone**.
- Les **règles de sécurité Firestore** sont écrites mais leur déploiement et leur test avec deux comptes restent à confirmer.
- Les écrans ont été vérifiés par des tests automatiques ; la **recette sur plusieurs téléphones** en mode avion est à compléter.
- Le chiffrement de la base locale et le scan de QR code sont **hors du périmètre** de cette version.

## Équipe

| Membre | Rôle | Nom |
|---|---|---|
| 1 | Lead : fondations, patients, consentement | à compléter |
| 2 | Consultation : enregistrement, transcription, structuration | à compléter |
| 3 | Informations manquantes, urgence, validation, tests | à compléter |
| 4 | Authentification, PIN, synchronisation, Firebase | à compléter |
| 5 | Données de démonstration, documentation, présentation | à compléter |

---

*Aucune donnée réelle de patient n'est présente dans ce dépôt.*
