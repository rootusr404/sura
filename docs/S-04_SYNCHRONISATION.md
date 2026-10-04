# S-04 — état et coordination F-02

## État actuel

Le provider utilise `RepositorySyncService` et le transport Firestore, avec
l'UID Firebase courant et les chemins `agents/{uid}/patients/{id}` et
`agents/{uid}/consultations/{id}`. `FakeSyncService` reste disponible pour les
tests, mais n'est plus branché dans les providers.

Les patients précèdent leurs consultations. Seules les consultations avec
`status == saved` et `validatedAt != null` sont envoyées. Les champs distants
sont sélectionnés explicitement : aucun audio, contenu audio ou chemin audio.
Les erreurs conservent les données du repository. Le réessai automatique suit
2, 4, 8, 16, 32, 64 puis 120 secondes maximum. `retry(id)` accepte l'identifiant
d'un patient ou d'une consultation et relance aussi le parent si nécessaire.

## Persistance locale intégrée lors de la fusion F-02

Les providers utilisent désormais `DriftPatientRepository` et
`DriftConsultationRepository`. Les deux repositories implémentent les mises
à jour atomiques de l'état, des tentatives et des erreurs. La migration SQLite
v1 vers v2 ajoute les métadonnées patients sans supprimer les données existantes.

`test/drift_sync_integration_test.dart` vérifie les versions concurrentes,
la migration et la reprise après des échecs avec fermeture/réouverture d'une
base SQLite sur disque. Le transport de ces tests est simulé : la recette
Firebase sur appareil et la validation des règles S-05 restent nécessaires.

## Contrat partagé avec le membre 1 (F-02)

- Les repositories Drift sont branchés dans `lib/core/db/repository_providers.dart`.
- Persister les données et `syncState`, ainsi que `syncAttempts` et `syncError`
  des patients et des consultations. Ne supprimer aucun enregistrement en cas d'échec d'envoi.
- Implémenter les méthodes `updateSyncState` déjà déclarées dans les contrats
  comme mises à jour atomiques conditionnées par `id` et `expectedUpdatedAt`.
  Retourner `false` si la version a changé, sans modifier les données métier
  ni leur `updatedAt`; effacer `syncError` quand l'erreur reçue est nulle.
- Après une modification d'une consultation validée, avancer `updatedAt` et
  remettre `syncState` à `pending`. `markValidated` doit persister `saved`,
  `validatedAt` et `pending` avant d'émettre le changement.
- Les streams doivent émettre la valeur initiale puis les changements
  persistés. Le service récupère les états `pending`, `error` ou `syncing`
  abandonnés lors du redémarrage.
- Tester une fermeture/réouverture SQLite après un échec et pendant un envoi,
  puis vérifier la reprise sans perte ni suppression locale.

Les échéances de réessai restent en mémoire; les états et compteurs persistants
permettront la reprise après redémarrage avec un délai réinitialisé. Aucun
stockage parallèle n'est introduit en attendant F-02. Les règles Firestore
(S-05) ne sont pas déployées dans cette tâche. La recette Firebase sur appareil reste à réaliser après cette intégration.

## Contrat commun pour les métadonnées locales

Les deux repositories exposent :

```dart
Future<bool> updateSyncState(
  String id,
  SyncState state, {
  required DateTime expectedUpdatedAt,
  int? attempts,
  String? error,
});
```

Les deux records portent `syncAttempts` (défaut 0) et `syncError` (nullable).
Le service incrémente les tentatives avant chaque envoi et conserve le compteur
au succès. Une erreur est enregistrée sans effacer les données; le succès
l'efface. Ces champs locaux ne sont pas envoyés à Firestore.

Pour Drift, une seule instruction `UPDATE ... WHERE id = ? AND updatedAt = ?`
doit modifier ensemble `syncState`, `syncAttempts` et `syncError`, sans avancer
`updatedAt`. `attempts == null` conserve le compteur, `error == null` efface
l'erreur. Le booléen correspond à la présence d'une ligne mise à jour.
Les tests en mémoire vérifient le contrat; les tests Drift vérifient aussi sa persistance SQLite.