# S-05 — règles Firestore préparées, non déployées

## Configuration et chemins vérifiés

`firebase.json` contient la configuration FlutterFire du projet `sura-eb4db`.
La nouvelle section `firestore.rules` référence le fichier racine
`firestore.rules`, sans modifier la configuration client FlutterFire.
Aucun `.firebaserc`, configuration d'émulateur du projet, package de tests
Node ou base de tests de règles n'était présent lors de l'inspection.

Les seuls accès Firestore du code applicatif sont :

| Code | Chemin | Champs d'identité observés |
| --- | --- | --- |
| `FirebaseAuthService.register` | `agents/{user.uid}` | `agent_id` |
| `FirestoreSyncRemoteStore.sendPatient` | `agents/{uid}/patients/{patient.id}` | `id`, `createdByAgentId` |
| `FirestoreSyncRemoteStore.sendConsultation` | `agents/{uid}/consultations/{consultation.id}` | `id`, `patientId`, `agentId` |

Le provider de synchronisation fournit l'UID de
`FirebaseAuth.instance.currentUser`. Le transport effectue une lecture puis
une écriture en transaction, donc les règles autorisent les deux au propriétaire,
y compris la lecture d'un document encore absent avant sa création.

## Politique

Une requête client doit être authentifiée et son `request.auth.uid` doit
correspondre au `{uid}` du chemin. Le propriétaire peut lire, lister, créer,
modifier et supprimer ses patients et consultations. Il peut aussi accéder à
son profil agent, nécessaire au parcours d'inscription existant.

La propriété repose sur le chemin, pas sur un champ modifiable du document.
Changer `agent_id`, `createdByAgentId` ou `agentId` ne donne donc aucun droit
sur le chemin d'un autre agent. Aucune nouvelle validation de schéma n'est
ajoutée dans cette tâche. Le choix explicite des champs sans audio reste assuré
par S-04; les présentes règles ne constituent pas une validation du contenu.

Les autres chemins et les sous-collections plus profondes sont refusés par
défaut. Il n'existe aucun accès global permissif à toutes les données d'agents.
Les requêtes doivent viser la sous-collection du bon UID : une requête globale
sur `agents` ou un groupe `patients`/`consultations` n'est pas autorisée sans
règle spécifique. Aucun client applicatif actuel n'effectue ces requêtes.

## Vérification avec deux identités

Utiliser des données fictives. Les règles de ce fichier ne sont pas déployées :
un test sur le projet distant mesurerait ses règles déjà publiées, pas celles
préparées ici.

Pour une première vérification manuelle sans publication, saisir les règles
dans l'éditeur Firestore puis utiliser le Rules Playground sans les publier.
Simuler une requête non authentifiée et des requêtes authentifiées portant
respectivement `uid = agent-a` et `uid = agent-b`. Préparer les documents et les
champs proposés dans les simulations; le Playground ne remplace pas une recette
complète avec de vrais clients.

| Cas à vérifier pour profils, patients et consultations | Résultat attendu |
| --- | --- |
| A lit, crée, modifie ou supprime un document sous `agents/agent-a` | Autorisé |
| B effectue les mêmes opérations sous `agents/agent-b` | Autorisé |
| B lit, crée, modifie ou supprime un document sous `agents/agent-a` | Refusé |
| A effectue les mêmes opérations sous `agents/agent-b` | Refusé |
| Une requête non authentifiée accède à ces documents | Refusé |
| A liste ses patients et consultations | Autorisé |
| B liste les patients ou consultations de A | Refusé |
| A lit un patient absent dans son propre chemin avant création | Autorisé (document absent) |
| A accède à `agents/agent-a/patients/p1/audio/a1` | Refusé |
| A accède à une collection racine non prévue | Refusé |

Pour une vérification automatisée complète, il reste à configurer les
émulateurs Firestore (et Auth pour une recette réelle à deux comptes) dans
`firebase.json`. Le CLI Firebase est déjà présent; vérifier aussi la version
Java requise par l'émulateur. Les dépendances de tests
`@firebase/rules-unit-testing` et le SDK JavaScript `firebase` sont nécessaires
pour exécuter réellement les règles avec deux contextes authentifiés et un
contexte non authentifié. Elles ne sont pas installées dans cette tâche.

Les futurs tests doivent charger explicitement `firestore.rules`, utiliser un
projet fictif `demo-sura`, vérifier la matrice ci-dessus et une transaction
lecture/écriture comme celle de S-04. Lancer ces tests avec un émulateur local,
pas un SDK Admin distant qui contournerait les règles. Pour la recette Flutter,
connecter explicitement Auth et Firestore aux émulateurs, créer deux comptes,
synchroniser les données fictives de chacun puis tenter les accès croisés.

## Limites de la vérification locale

La validation JSON, la revue des chemins et les tests Flutter disponibles ne
compilent pas les règles et ne prouvent pas le refus d'un deuxième compte.
La compilation et les tests d'autorisation restent à exécuter dans le
Playground ou l'émulateur. Aucune commande de déploiement n'est exécutée.

Références officielles :

- [Structure et portée des règles](https://firebase.google.com/docs/firestore/security/rules-structure)
- [Tests des règles avec émulateur](https://firebase.google.com/docs/rules/unit-tests)
- [Rules Playground](https://firebase.google.com/docs/rules/simulator)

## Mise à jour : règles renforcées et testées sur l'émulateur

Les règles valident maintenant le **contenu** des documents, en plus de leur propriétaire :

- liste fermée de champs pour le profil, les patients et les consultations : un champ audio ou inconnu est refusé ;
- `id`, `createdByAgentId` et `agentId` doivent correspondre au chemin et au compte connecté ;
- types et valeurs permises (âge entier de 0 à 130, sexe `F` ou `M`, statut, niveau d'urgence, consentement) et taille maximale des textes ;
- suppression refusée côté client.

28 tests automatisés (`firestore-tests/`, `npm test`) vérifient ces règles contre l'émulateur local, avec des documents identiques à ceux de l'application. Voir `firestore-tests/README.md`.

**Toujours à faire** : déployer ces règles sur le projet réel, puis tester avec deux comptes sur téléphone. Les règles de ce dépôt ne sont **pas déployées** tant que `firebase deploy --only firestore:rules` n'a pas été lancé par le Membre 4.

