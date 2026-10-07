# Tests des règles Firestore (S-05)

Ces tests vérifient `../firestore.rules` contre l'**émulateur Firestore local**.
Ils utilisent un projet fictif (`demo-sura`) et des données fictives : ils ne touchent **jamais** au projet Firebase réel.

## Lancer les tests

Prérequis : Node.js 20 ou plus, Java 11 ou plus (testé avec Java 17).

```bash
cd firestore-tests
npm install
npm test
```

Le premier lancement télécharge l'émulateur (environ 60 Mo).

## Ce qui est vérifié

- **Accès** : un agent ne lit et n'écrit que ses documents ; sans connexion, pour une autre collection ou une sous-collection non prévue, tout est refusé.
- **Contenu** : liste fermée de champs (un champ audio ou inconnu est refusé), identifiants cohérents avec le chemin et avec le compte connecté (`createdBy`, `agentId`), types et valeurs permises (âge, sexe `F`/`M`/`O`, mode `voice`/`manual`, consentement, niveaux d'urgence de 0 à 2), taille maximale des textes.
- **Suppression** : impossible côté client (les données ne se perdent jamais).
- **Compatibilité** : les documents de test reproduisent ceux que l'application écrit, avec `merge: true`, dates en texte, horodatage serveur et valeurs nulles :
  - `lib/features/sync/sync_service.dart` (patients et consultations) ;
  - `lib/features/auth/auth_service.dart` (inscription) puis `lib/features/profile/profile_service.dart` (profil), deux écritures fusionnées dans `agents/{uid}`.
- **Restauration** : l'agent peut lister ses patients et ses consultations (`restoreFromServer`).

**Si l'application ajoute un champ à ce qu'elle écrit dans Firestore, il faut l'ajouter aussi dans `firestore.rules`**, sinon l'envoi sera refusé et les données resteront « en attente ».

## Problème connu sous Windows

`firebase emulators:exec` peut laisser un processus Java actif après les tests. Au lancement suivant, l'erreur est : `Could not start Firestore Emulator, port taken`. Fermez alors le processus Java de l'émulateur (Gestionnaire des tâches) et relancez. Ce dossier utilise les ports 8187 et 9187 (voir `firebase.test.json`) pour éviter les conflits avec l'émulateur par défaut.

## Ce que ces tests ne prouvent pas

- Ils ne déploient **rien**. Les règles du projet réel doivent être déployées séparément : `firebase deploy --only firestore:rules`.
- Ils utilisent le SDK JavaScript, pas l'application Flutter. Une recette avec deux vrais comptes sur téléphone (inscription, profil, synchronisation, restauration) reste nécessaire.
