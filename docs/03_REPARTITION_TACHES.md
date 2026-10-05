# SŪRA — Répartition des tâches

Chaque tâche a un **ID**, un **livrable**, des **critères d'acceptation** et une **échéance**. Elle devient une issue GitHub, une branche `feature/<ID>-slug`, puis une PR.
Priorités : **P0** indispensable · **P1** important · **P2** si le temps le permet (voir guide §8).

Échéances en heure locale. Les « J » du cahier des charges sont remplacés par les dates réelles.

---

## Vue d'ensemble

| Date | Membre 1 (Lead) | Membre 2 | Membre 3 | Membre 4 | Membre 5 |
|---|---|---|---|---|---|
| **Jeu 1 oct** | F-00 squelette | C-01 test STT | Lire docs · préparer règles | S-01 Firebase | D-01 décisions design |
| **Ven 2 oct** | F-01 · F-03 · F-04 · F-07 | C-02 · C-04 | U-01 · U-02 | S-03 PIN | D-03 données de démo · D-02 |
| **Sam 3 oct** | F-02 · F-05 · F-06 | C-03 · branchement réel | U-03 · U-04 | S-02 · S-04 | D-04 revue UX |
| **Dim 4 oct** | Intégration · revue | Correctifs · tests | U-04 · U-05 | S-04 · S-05 · S-06 | D-05 pitch · vidéo |
| **Lun 5 oct** | Gel 12:00 · APK | Correctifs | U-05 recette | Correctifs | D-06 soumission |

**Chemin critique :** F-00 → (F-02 Drift ‖ fakes) → parcours complet → sync. Grâce aux fakes, **seul F-00 bloque les autres** ; F-02 ne bloque personne avant samedi.

---

## Membre 1 — Lead · fondations, patients, consentement

| ID | P | Tâche | Livrable et critères d'acceptation | Échéance |
|---|---|---|---|---|
| **F-00** | P0 | Squelette et dépôt | Kit appliqué sur `develop` · CI verte · protections de branches · issues créées · message de lancement envoyé. **Critère : les 4 autres ont cloné et lancé l'application.** | Jeu 1 oct, 23:00 |
| **F-01** | P0 | Thème et composants | `SuraTheme`, `SuraButton`, `UrgencyBadge`, `StatusChip`, `InlineAlert` branchés dans `app.dart`. Urgence = forme + texte + couleur. 2 tests de widgets. | Ven 2, 12:00 |
| **F-03** | P0 | Navigation et accueil | Barre du bas (Accueil · Patients · **Consulter** · Paramètres), masquée pendant la consultation. Accueil réel : compteurs, statut de connexion. Bandeau « hors ligne ». | Ven 2, 18:00 |
| **F-04** | P0 | Patients : créer, rechercher, lister | Formulaire (nom, prénom, âge en années, sexe, village, téléphone facultatif) · identifiant `SUR-XXXX-XXXX` · recherche par nom/identifiant/village · fonctionne **hors ligne**. | Ven 2, 20:00 |
| **F-07** | P0 | Consentement | Accord/refus **horodaté**, enregistré dans le `ConsultationRecord` (R3). Refus : pas d'enregistrement, saisie manuelle proposée. Texte clair, lisible à voix haute. | Ven 2, 20:00 |
| **F-02** | P0 | Base Drift + repositories | Tables Agents/Patients/Consultations · `DriftPatientRepository`, `DriftConsultationRepository` · providers basculés · **les données survivent au redémarrage** · ≥ 4 tests (base en mémoire). | Sam 3, 14:00 |
| **F-06** | P1 | Dossier patient | Fiche + historique des consultations avec `StatusChip` · bouton « Consulter ». | Sam 3, 20:00 |
| **F-05** | P1/P2 | QR | Affichage du QR (**identifiant seul**, R2) = P1. Scan → ouvre le patient, message si inconnu = P2. | Sam 3, 20:00 |
| **F-08** | P0 | Pilotage | Relire/merger sous 2 h · intégration 20:00 chaque soir · tags v0.1/v0.5/v0.9/v1.0 · APK de démo. | Quotidien |

---

## Membre 2 — Consultation : enregistrement, transcription, structuration

| ID | P | Tâche | Livrable et critères d'acceptation | Échéance |
|---|---|---|---|---|
| **C-01** | P0 | **Test de transcription hors ligne** | Essai de `whisper_edge` (puis `vosk_flutter` si trop lourd) sur **les téléphones cibles**. Tableau : modèle, taille, temps pour 30 s d'audio, RAM, qualité en français. **Décision GO/NO-GO** consignée dans `DECISIONS.md` (D-07). **Plafond : 3 h d'effort.** | Ven 2, 18:00 |
| **C-02** | P0 | Enregistrement audio | `AudioRecorderService` réel (`record`) · écran : minuteur, pause, arrêt · permission micro (refus → message + saisie manuelle) · **refuse de démarrer sans consentement accordé (R3)** · fichier local uniquement. | Ven 2, 20:00 |
| **C-04** | P0 | Extraction des champs | `InformationExtractor` à base de règles/RegExp : motif, symptômes, durée, température, pouls, allergies, médicaments, antécédents. Écran « Informations structurées » **modifiable** (R5). **Ne plante jamais** sur texte vide ou incohérent. ≥ 6 tests, dont les fixtures de D-03. | Sam 3, 12:00 |
| **C-03** | P0 | Transcription | `TranscriptionService` réel selon C-01 · écran de transcription **modifiable** (R4), indicateur de progression, fonctionne en mode avion · **repli : saisie manuelle** si le moteur échoue. | Sam 3, 20:00 |

*Règle de repli :* si C-01 est un NO-GO, la saisie manuelle devient le chemin officiel pour la démo, et `whisper_edge` passe en P2. Ce n'est **pas** un échec : le reste du parcours est identique.

---

## Membre 3 — Checklist, urgence, validation, tests

| ID | P | Tâche | Livrable et critères d'acceptation | Échéance |
|---|---|---|---|---|
| **U-01** | P0 | Informations manquantes | `MissingInfoChecker` déterministe + écran. Formulation : « Cette information semble manquer. » (jamais « Vous devez… »). **Non bloquant** (R6). ≥ 4 tests. | Ven 2, 20:00 |
| **U-02** | P0 | Niveau d'urgence | `UrgencyScorer` à mots-clés avec **raisons affichées** · écran : `UrgencyBadge` grand format, raisons, **modification possible avec motif obligatoire** (R7). ≥ 8 tests (tableau de cas : convulsions, difficulté respiratoire, fièvre prolongée de l'enfant, cas bénin…). | Sam 3, 12:00 |
| **U-03** | P0 | Récapitulatif, validation, sauvegarde | Récap de toutes les sections (liens pour corriger) · **validation par 5 cases à cocher** (R8) · `markValidated` (R9) · écran de sauvegarde avec statut de synchronisation. Impossible de valider sans les 5 cases. | Sam 3, 20:00 |
| **U-04** | P0 | Tests et CI | Objectif **≥ 20 tests au total** (tous membres) et CI verte. Suit le compteur, relance les membres en retard, complète les cas manquants. | Dim 4, 20:00 |
| **U-05** | P0 | Recette | Plan de test écrit : **3 scénarios de démo** (avec D-03) + parcours complet **en mode avion sur 2 téléphones**. Liste de bugs en issues. | Dim 4 → Lun 5, 14:00 |

---

## Membre 4 — Authentification, PIN, synchronisation, Firebase

| ID | P | Tâche | Livrable et critères d'acceptation | Échéance |
|---|---|---|---|---|
| **S-01** | P0 | **Projet Firebase** | Projet créé · application Android enregistrée (identifiant de paquet identique au dépôt) · **Auth e-mail/mot de passe** et **Firestore** activés · `flutterfire configure` · tous les membres ajoutés comme éditeurs · `Firebase.initializeApp` dans `main.dart` **sous try/catch** (l'application démarre même sans Firebase). PR avec la configuration client (consigne du lead pour `google-services.json`). | Jeu 1 oct, 23:00 |
| **S-03** | P1 | PIN local | PIN 6 chiffres haché avec sel, stocké dans le stockage sécurisé · écrans de création et déverrouillage · valeurs par défaut du `02` §8 (#6, #7) · ≥ 4 tests. | Ven 2, 20:00 |
| **S-02** | P1 | Authentification Firebase | `FirebaseAuthService` · écrans connexion / inscription (profil agent) / mot de passe oublié · **message clair hors ligne** (R14) · aucun mot de passe en clair (R13) · garde `redirect` dans le routeur. | Sam 3, 20:00 |
| **S-04** | P1 | Synchronisation | `SyncService` réel : file d'attente basée sur `syncState` · **patients avant consultations** · réessai avec délai croissant · reprise au retour du réseau · **aucune perte si coupure en cours d'envoi** (R10, R11) · **l'audio n'est jamais envoyé** · ≥ 4 tests (machine d'états). | Dim 4, 14:00 |
| **S-05** | P1 | Règles Firestore | Structure `agents/{uid}/patients/{id}` et `agents/{uid}/consultations/{id}` · règles : un agent ne lit/écrit **que** ses documents · déployées · testées avec un 2ᵉ compte. | Dim 4, 14:00 |
| **S-06** | P1 | Écran d'état de synchronisation et paramètres | Liste des éléments en attente/en erreur · bouton « Réessayer » · déconnexion · « Verrouiller maintenant ». | Dim 4, 20:00 |
| **S-07** | P2 | SQLCipher · Crashlytics | Chiffrement de la base derrière un interrupteur ; Crashlytics branché. **Ne démarre que si P0 et P1 sont terminés.** | Dim 4, soir |

---

## Membre 5 — Charte graphique, maquettes, pitch, démonstration

| ID | P | Tâche | Livrable et critères d'acceptation | Échéance |
|---|---|---|---|---|
| **D-01** | P0 | Décisions design restantes | Trancher et consigner : logo retenu, typographie, bibliothèque d'icônes (spécification §16, #1-5). **Logo et icône exportés en SVG/PNG** dans `assets/`. | Jeu 1 → Ven 2, 12:00 |
| **D-03** | P0 | **Données de démonstration** | `test/fixtures/consultations.json` + `docs/demo/SCENARIOS.md` : **3 scénarios** (patient fictif, texte dicté de 8 à 12 phrases en français, extraction attendue, informations manquantes attendues, urgence attendue). **Livrer au plus tôt : M2 et M3 en dépendent pour leurs tests.** | Ven 2, 12:00 |
| **D-02** | P1 | Icône et écran de démarrage | Icône d'application et splash intégrés (`flutter_launcher_icons`) dans une PR autonome. | Ven 2, 20:00 |
| **D-04** | P1 | Revue UX sur téléphone | Écrans comparés aux maquettes : lisibilité en plein soleil, zones tactiles ≥ 48 dp, urgence jamais par la couleur seule. Chaque écart = une issue. | Sam 3 → Dim 4 |
| **D-05** | P0 | Pitch, vidéo, README | Pitch (problème → solution → démo → impact ODD 3) · **vidéo de démonstration** (parcours en mode avion) · README du dépôt (installation, fonctionnalités, limites connues, équipe). | Dim 4, 22:00 |
| **D-06** | P0 | Dossier de soumission | Liste de contrôle remplie : lien du dépôt, APK de la version finale, vidéo, texte de présentation, captures, vérification que **rien de réel ni de secret** n'est publié. | Lun 5, 18:00 |

---

## Qui produit, qui consomme

| Livrable | Produit par | Attendu par | Pour |
|---|---|---|---|
| Squelette (F-00) | M1 | M2, M3, M4, M5 | démarrer |
| Données de démo (D-03) | M5 | M2, M3 | tests d'extraction, de manquants, d'urgence |
| Projet Firebase (S-01) | M4 | M4 | auth et synchronisation |
| Décision STT (C-01) | M2 | M2, lead | choix du moteur ou repli manuel |
| Repositories Drift (F-02) | M1 | M2, M3, M4 | persistance réelle |
| Texte transcrit (C-03) | M2 | M3 | extraction, urgence |
| Consultation validée (U-03) | M3 | M4 | synchronisation |
| Logo/icônes (D-01) | M5 | M1 | thème et icône |

---

## Ce que chacun attend des autres

- **De tous :** PR petites, relecture sous 2 h, `develop` toujours vert, message `[BLOQUÉ]` plutôt que le silence.
- **Du lead :** squelette stable, contrats clairs, décisions rapides, merges réguliers.
- **De chaque propriétaire :** il livre son module **testé** et **fonctionnel hors ligne**, avec le fake remplacé par le réel en une ligne.
