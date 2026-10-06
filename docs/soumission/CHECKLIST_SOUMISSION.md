# SŪRA — Liste de contrôle de soumission (D-06)

À remplir **avant** d'envoyer le dossier. Chaque case se coche avec une preuve (lien, capture, commande lancée). Une case non cochée est un point à régler ou à assumer par écrit.

Date limite initiale : **lundi 5 octobre 2026, 23h59**. Si le délai a changé, notez la nouvelle date ici : `__________`

---

## A. Constats déjà faits sur le dépôt

Contrôle automatique réalisé sur `develop` (commit `d02f2ac`, avant les PR en attente). **À refaire sur la version finale** (voir §F).

| Contrôle | Résultat | |
|---|---|---|
| Fichier audio (`.wav`, `.m4a`, `.aac`, `.mp3`) suivi par Git | Aucun | ✅ |
| Clé privée, compte de service, `.env`, keystore, `key.properties` | Aucun | ✅ |
| Mot de passe écrit en dur dans `lib/` ou `test/` | Aucun | ✅ |
| Numéro de téléphone ou e-mail réel | Aucun (seul `dev@sura.test`, fictif) | ✅ |
| `.gitignore` protège audio, modèles, `.env`, comptes de service | Oui | ✅ |
| Clés API Firebase côté client (`google-services.json`, `firebase_options.dart`) | **Présentes** | 🟡 voir B1 |
| Identifiant de paquet Android | `com.example.sura` | 🟡 voir B2 |
| Signature de l'APK « release » | Clé de **débogage** | 🟡 voir B3 |

---

## B. Points à décider ou à confirmer

**B1. Clés API Firebase dans le dépôt.**
Ce sont des clés de configuration **côté client** : il est normal qu'elles soient dans une application Flutter, et elles ne donnent pas accès aux données par elles-mêmes. La protection vient des **règles Firestore**. Donc :
- [ ] Le Membre 4 confirme que les règles de `firestore.rules` sont **déployées** (`firebase deploy --only firestore:rules`).
- [ ] Un test avec **deux comptes** montre qu'un agent ne lit pas les données d'un autre.
- [ ] (Recommandé) Les clés sont restreintes à l'application Android dans la console Google Cloud.
- [ ] Aucune clé de **compte de service** n'est dans le dépôt (contrôle ci-dessus : aucune trouvée).

**B2. Identifiant de paquet `com.example.sura`.**
Valeur par défaut de Flutter. Acceptable pour une démonstration, mais **il ne doit pas changer au dernier moment** : il est lié à la configuration Firebase (`google-services.json`).
- [ ] L'équipe accepte de le garder tel quel pour la soumission.

**B3. APK signé avec la clé de débogage.**
Suffisant pour installer et montrer l'application, **pas pour une publication** sur un magasin d'applications.
- [ ] Mentionné dans le texte de soumission si une publication est évoquée.

---

## C. Contenu du dossier

| Élément | Fichier ou lien | Prêt |
|---|---|---|
| Lien du dépôt GitHub | https://github.com/rootusr404/sura | ☐ |
| Branche à évaluer | `main`, **à jour** (voir §F) | ☐ |
| APK de la version finale | `build/app/outputs/flutter-apk/app-release.apk` | ☐ |
| Vidéo de démonstration (parcours en mode avion) | lien : `__________` | ☐ |
| Texte de présentation | `docs/demo/PITCH.md`, `README.md` | ☐ |
| Captures d'écran (données fictives) | dossier : `__________` | ☐ |
| Scénarios de démonstration | `docs/demo/SCENARIOS.md` | ☐ |
| Compte rendu de recette rempli | `docs/recette/PLAN_DE_RECETTE.md`, §7 | ☐ |

### Vérifier l'APK
```bash
flutter build apk --release
```
- [ ] L'APK s'installe sur un téléphone **autre** que celui du développement.
- [ ] L'application démarre, la connexion et le PIN fonctionnent.
- [ ] Le parcours s'exécute **en mode avion**.

---

## D. Vérification « rien de réel, rien de secret »

À faire sur **chaque** livrable : dépôt, APK, vidéo, captures, texte.

- [ ] **Vidéo** : revue image par image des écrans montrés. Aucun vrai nom, numéro, village réel ou donnée de patient.
- [ ] **Captures** : seulement les scénarios fictifs (Aïssatou Ba, Fatou Keïta, Amadou Sow).
- [ ] **Console Firebase** : si elle apparaît dans la vidéo, aucun identifiant, clé ni e-mail personnel visible.
- [ ] **Historique Git** : aucun secret n'a été commité puis supprimé. Pour le vérifier :
  ```bash
  git log --all --oneline -- "*.env" "*service-account*" "*.jks" "*.pem"
  ```
  Le résultat doit être **vide**.
- [ ] **Recherche finale** dans les fichiers suivis :
  ```bash
  git grep -nIiE "private_key|BEGIN PRIVATE KEY|client_secret|password *[:=] *['\"]"
  ```
  Aucun résultat inattendu.
- [ ] Aucun audio de patient réel n'a été enregistré dans le dépôt ou les captures.

---

## E. Qualité de la version finale

- [ ] `flutter analyze` : aucun problème.
- [ ] `flutter test` : tous les tests passent. Nombre de tests : `____` (objectif : 20 ou plus).
- [ ] La CI GitHub est **verte** sur `main`.
- [ ] Les 3 scénarios de démonstration réussissent sur 2 téléphones.
- [ ] Le **README** est à jour : le tableau des fonctionnalités ne promet que ce qui marche, les noms de l'équipe sont renseignés, les limites sont énoncées.
- [ ] Aucune PR importante restée ouverte, aucun `[BLOQUÉ]` sans réponse.

---

## F. Avant d'envoyer : synchroniser les branches

Au moment de la rédaction, `main` et `develop` **ne contenaient pas les mêmes fonctionnalités**. Les PR de l'équipe doivent viser `develop`. Avant de soumettre :

- [ ] `develop` contient tout le travail validé, puis il est fusionné dans `main`.
- [ ] Vérification : `git log --oneline origin/main..origin/develop` ne montre rien.
- [ ] Les sections B, D et E ont été **refaites sur `main`** (pas seulement sur `develop`).
- [ ] Un tag de version est posé : `git tag v1.0` puis `git push origin v1.0`.

---

## G. Responsabilités et signature

| Section | Responsable | Date | Vérifié |
|---|---|---|---|
| B1 Règles Firestore | Membre 4 | | ☐ |
| C APK | Membre 1 (Lead) | | ☐ |
| C Vidéo et textes | Membre 5 | | ☐ |
| D Vérification confidentialité | Membre 5 + un relecteur | | ☐ |
| E Tests et recette | Membre 3 | | ☐ |
| F Synchronisation des branches | Membre 1 (Lead) | | ☐ |

**Décision finale** : ☐ prêt à soumettre · ☐ réserves à lister : `__________`
