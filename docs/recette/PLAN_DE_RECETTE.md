# SŪRA — Plan de recette (U-05)

Objectif : prouver que le parcours complet fonctionne **sans réseau**, sur **2 téléphones**, avec **3 scénarios** de démonstration.
Toutes les données sont **fictives**. Aucun vrai patient, aucun vrai audio.

> **À aligner avec D-03.** Les scénarios ci-dessous sont provisoires : D-03 (`test/fixtures/consultations.json`, `docs/demo/SCENARIOS.md`) n'était pas encore livré à la rédaction. Quand il l'est, remplacer les textes dictés par ceux de D-03 et garder les résultats attendus s'ils concordent. Sinon, noter l'écart comme bug ou comme décision.

---

## 1. Avant de commencer

| À préparer | Détail |
|---|---|
| Version testée | Dernier `develop` (noter le hash : `git log -1 --oneline`) |
| Téléphones | 2 appareils Android réels (marque, modèle, version Android à noter) |
| Installation | `flutter run --release` ou l'APK fourni par le Lead |
| Compte agent | Un compte de test créé **en ligne** une première fois (R14) |
| Réseau | Au départ **en ligne** pour la connexion, puis **mode avion** pour le parcours |
| Rappel | Les P2 (scan QR, SQLCipher, Crashlytics) ne sont pas testés ici |

Cas d'arrêt : si le téléphone ne démarre pas l'application, ne pas continuer, ouvrir une issue `bug` (voir §6).

---

## 2. Les 3 scénarios (provisoires)

Les résultats attendus viennent des règles actuelles : `RuleMissingInfoChecker` (U-01) et `RuleUrgencyScorer` (U-02).

### Scénario A : cas bénin
- **Patient fictif** : Awa TEST, 30 ans, F, village « Test-A ».
- **Texte dicté** : « Bonjour, je viens pour un petit rhume. Le nez coule depuis deux jours. Pas de fièvre. Je n'ai aucune allergie. Je ne prends aucun médicament. Pas d'antécédents. »
- **Attendu**
  - Motif : rhume · Durée : 2 jours.
  - Informations manquantes : aucune (ou température non demandée : adulte sans fièvre évoquée).
  - Urgence : **Faible**, avec la raison « Aucun signe de gravité détecté… ».

### Scénario B : urgence modérée
- **Patient fictif** : Moussa TEST, 35 ans, M, village « Test-B ».
- **Texte dicté** : « J'ai de la fièvre depuis quatre jours avec des courbatures. Température 38,8. Allergies : aucune. Aucun médicament. Pas d'antécédents. »
- **Attendu**
  - Motif : fièvre · Durée : 4 jours · Température : 38,8 °C.
  - Informations manquantes : aucune.
  - Urgence : **Modérée**, raison « Fièvre depuis 4 jours ».

### Scénario C : urgence élevée chez l'enfant
- **Patient fictif** : Ibrahim TEST, 3 ans, M, village « Test-C » (accompagné d'un parent).
- **Texte dicté** : « Mon fils a de la fièvre depuis trois jours. Hier soir il a fait des convulsions. Il n'a pas d'allergies connues. Il ne prend aucun médicament. »
- **Attendu**
  - Informations manquantes : au minimum **la température** (enfant de moins de 5 ans) et **les antécédents**.
  - Urgence : **Élevée**, avec au moins 2 raisons (convulsions signalées ; fièvre depuis 3 jours chez un enfant de moins de 5 ans).

Si la transcription automatique n'est pas disponible (voir C-01 / D-07), utiliser la **saisie manuelle** : le reste du parcours est identique.

---

## 3. Déroulé d'un scénario (à répéter pour A, B, C)

Pour chaque étape, cocher `OK` ou `KO`. Un `KO` = une issue (voir §6).

| # | Étape | Résultat attendu | A | B | C |
|---|---|---|---|---|---|
| 1 | Créer le patient | Identifiant `SUR-XXXX-XXXX` généré, patient trouvé par la recherche | ☐ | ☐ | ☐ |
| 2 | Démarrer une consultation | L'écran de consentement s'affiche, texte lisible à voix haute | ☐ | ☐ | ☐ |
| 3 | Accepter le consentement | Horodaté, passage à l'enregistrement | ☐ | ☐ | ☐ |
| 4 | Enregistrer ou saisir le texte | Minuteur visible, permission micro demandée | ☐ | ☐ | ☐ |
| 5 | Transcription | Texte affiché et **modifiable** (R4) | ☐ | ☐ | ☐ |
| 6 | Informations structurées | Champs extraits **modifiables** (R5) | ☐ | ☐ | ☐ |
| 7 | Informations manquantes | Liste conforme au scénario, formulation « Cette information semble manquer… », bouton « Continuer » toujours actif (R6) | ☐ | ☐ | ☐ |
| 8 | Niveau d'urgence | Niveau et raisons conformes ; badge avec forme + texte + couleur | ☐ | ☐ | ☐ |
| 9 | Changer le niveau | Impossible de continuer sans **motif** (R7) ; avec motif, le changement est gardé | ☐ | ☐ | ☐ |
| 10 | Récapitulatif | Toutes les sections affichées, « Modifier » ouvre la bonne étape | ☐ | ☐ | ☐ |
| 11 | Validation | Bouton désactivé avec 0 à 4 cases ; actif avec 5 cases (R8) | ☐ | ☐ | ☐ |
| 12 | Sauvegarde | Message « enregistrée sur ce téléphone », statut **En attente** en mode avion (R9, R15) | ☐ | ☐ | ☐ |
| 13 | Dossier patient | La consultation apparaît dans l'historique avec son statut | ☐ | ☐ | ☐ |

---

## 4. Test en mode avion (sur 2 téléphones)

À faire sur le **téléphone 1**, puis répété sur le **téléphone 2**.

1. Se connecter **en ligne** (première connexion, R14), puis activer le **mode avion**.
2. Dérouler les scénarios A, B et C (§3) sans jamais rétablir le réseau.
3. Vérifier que :
   - [ ] aucun écran n'affiche une erreur bloquante liée au réseau ;
   - [ ] le bandeau « hors ligne » est visible (R15) ;
   - [ ] les 3 consultations sont enregistrées avec le statut **En attente**.
4. **Fermer complètement l'application**, la rouvrir (il faudra peut-être saisir le PIN) et vérifier que les 3 consultations et leurs patients sont toujours là (R10, R12).
5. **Couper en plein parcours** : en cours de consultation (par exemple à l'étape « Urgence »), fermer l'application, la rouvrir. La consultation doit pouvoir être **reprise** à la bonne étape (R10).
6. **Rétablir le réseau** : les 3 consultations passent à « Synchronisé », le patient **avant** ses consultations. Sinon, utiliser « Réessayer » (R11).
7. Vérifier dans la console Firebase que seuls des **patients et consultations fictifs** sont arrivés, et **aucun fichier audio**.

Critère de réussite : 3 scénarios sur 3 réussis, sans erreur, sur les 2 téléphones.

---

## 5. Vérifications transverses

| Vérification | Règle | OK |
|---|---|---|
| Aucun enregistrement audio sans consentement accordé | R3 | ☐ |
| Après un **refus** de consentement : pas d'enregistrement, saisie manuelle proposée, refus tracé | R3 | ☐ |
| Le QR du patient ne contient que son identifiant | R2 | ☐ |
| Aucune donnée réelle dans le dépôt, les captures, les vidéos | Guide §7 | ☐ |
| Zones tactiles ≥ 48 dp, urgence jamais par la couleur seule | D-04 | ☐ |
| `flutter analyze` et `flutter test` verts sur la version testée | Guide §6 | ☐ |

---

## 6. Signaler un bug

Une issue GitHub par bug, avec le label `bug`. Modèle :

```
**Titre** : [Scénario B, étape 8] L'urgence n'affiche aucune raison
**Version** : <hash de commit> · Téléphone : <modèle, Android X>
**Réseau** : mode avion / en ligne
**Étapes** : 1. … 2. … 3. …
**Attendu** : …
**Obtenu** : … (capture d'écran si possible, sans donnée réelle)
**Gravité** : bloquant la démo / gênant / cosmétique
```

Gravité : un bug **bloquant la démo** (P0) passe avant tout le reste et se signale au groupe avec le tag `[BLOQUÉ]`.

---

## 7. Compte rendu de recette

À remplir à la fin et à joindre à la PR ou au dossier de soumission.

| | Téléphone 1 | Téléphone 2 |
|---|---|---|
| Modèle / Android | | |
| Version testée (hash) | | |
| Scénario A | ☐ OK ☐ KO | ☐ OK ☐ KO |
| Scénario B | ☐ OK ☐ KO | ☐ OK ☐ KO |
| Scénario C | ☐ OK ☐ KO | ☐ OK ☐ KO |
| Parcours complet en mode avion | ☐ OK ☐ KO | ☐ OK ☐ KO |
| Reprise après fermeture | ☐ OK ☐ KO | ☐ OK ☐ KO |
| Synchronisation au retour du réseau | ☐ OK ☐ KO | ☐ OK ☐ KO |
| Bugs ouverts (numéros d'issues) | | |

**Décision** : ☐ prêt pour la soumission · ☐ corrections nécessaires (lister).
