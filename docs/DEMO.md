# SŪRA : guide de démonstration

Durée visée : **5 minutes**. Ce qui est écrit « attendu » est à vérifier lors de la répétition.

## A. Préparation (la veille, puis 30 minutes avant)
- [ ] Téléphone chargé, « Ne pas déranger », luminosité maximale.
- [ ] APK installé ; **un enregistrement vocal complet déjà fait** (le modèle se décompresse au premier usage).
- [ ] Compte de démonstration créé, PIN connu, **profil complété** (l'accueil affiche « Bonjour, Prénom »).
- [ ] 2 ou 3 patients de test (noms fictifs) ; le QR d'un patient visible dans son dossier.
- [ ] `kUseFirebase = true` ; console Firestore ouverte sur l'ordinateur (`agents/{uid}`).
- [ ] **Mode connecté désactivé** (Paramètres), sauf si vos crédits RODI sont confirmés et testés.
- [ ] Salle calme ; phrase de test prête.
- [ ] **Plan B :** APK debug de secours, vidéo d'une démonstration complète, `kUseRealStt = false` si la voix est instable.

## B. Scénario 1, nominal : consultation hors ligne puis synchronisée (≈ 2 min 30)
1. Connexion → PIN → Accueil. « Internet n'est requis qu'à la première connexion. »
2. **Mode avion.** L'Accueil affiche « ⊘ Hors ligne ».
3. **Consulter** → patient (ou scan du QR) → **« Le patient accepte »**.
4. **Enregistrement** : *« La patiente a de la fièvre depuis trois jours, elle a mal à la tête et elle tousse. Température trente-neuf degrés. »*
5. **Transcription** : montrer le texte, corriger un mot (« l'agent vérifie »).
6. **Informations** extraites → **manquantes** (alertes non bloquantes) → **Urgence** : ◆ MODÉRÉ avec ses raisons ; montrer qu'on peut la modifier.
7. **Récapitulatif**, **Validation** (5 cases) → « Enregistrer » : ○ En attente.
8. **Désactiver le mode avion** : statut ✓ Synchronisé ; montrer le document dans Firestore.

## C. Scénario 2, refus du patient : saisie manuelle (≈ 1 min 30)
1. Nouvelle consultation → **« Le patient refuse »** → « Continuer en saisie manuelle » (barre à **6 étapes**).
2. Cocher **Fièvre**, durée **3 jours** : l'**estimation en haut passe à ◆ MODÉRÉ** en direct. Cocher **⚠ Convulsion** : ▲ ÉLEVÉ.
3. Allergies « Aucune connue », traitement « Aucun » (une touche chacun) → l'étape « manquantes » se vide.
4. Urgence → même proposition ; validation : case **« Refus de consentement consigné »**.

Dire : « Le refus ne bloque pas la prise en charge, il est tracé, et les symptômes saisis alimentent l'estimation de l'urgence. »

## D. Scénario 3, robustesse et sécurité (≈ 1 min)
- Dossier en attente (○) dans Paramètres → Synchronisation : reprise automatique, « Réessayer ».
- **Paramètres → Verrouiller maintenant** : retour à l'écran PIN sans déconnexion (biométrie si activée).
- *(Option, uniquement en vidéo préparée)* échec d'envoi provoqué par des règles Firestore temporairement restrictives ; **rétablir les règles ensuite**.

## E. Mode connecté (facultatif, seulement si les crédits sont confirmés)
Paramètres → activer « Mode connecté (IA distante) » → avec Internet, refaire un enregistrement : le consentement affiche « ⚠ l'audio est envoyé à un service d'IA externe ». Comparer au texte local. **Dire clairement que ce mode est facultatif et soumis à consentement.**

## F. Si quelque chose ne marche pas
| Problème | Réaction |
|---|---|
| Voix instable ou texte vide | « Saisir à la main » (mode prévu) ; ou `kUseRealStt = false` |
| Mode connecté : « Crédits RODI insuffisants » | Le désactiver ; la reconnaissance locale prend le relais |
| Pas de réseau pour la synchro | Montrer ○ En attente comme preuve du hors ligne ; la vidéo montre la synchro |
| Blocage de l'application | APK debug de secours, puis vidéo |

## G. Vidéo de secours
```bash
adb shell screenrecord --time-limit 180 /sdcard/demo.mp4
adb pull /sdcard/demo.mp4 ~/Desktop/sura-demo.mp4
```
Une vidéo par scénario (nominal, refus).

## H. Après la démonstration
Rétablir les règles Firestore d'origine, **révoquer la clé Rodium**, supprimer les comptes et données de test.
