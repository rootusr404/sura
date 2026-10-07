# SŪRA : plan du pitch (5 minutes)

## Fil conducteur
**Problème → solution → démonstration → ce qui est fait et ce qui reste → impact.** Ton sobre, honnête, concret.

## Déroulé minuté
| Min | Contenu | Message |
|---|---|---|
| 0:00-0:40 | **Le problème** : en zone isolée, l'agent note sur papier, sans réseau ; le suivi se perd | « Documenter un soin ne devrait pas dépendre du réseau. » |
| 0:40-1:20 | **La solution** : application mobile hors ligne ; la voix devient un dossier structuré ; l'agent vérifie et valide | « L'IA propose, l'agent décide. » |
| 1:20-4:00 | **Démonstration** (voir `docs/DEMO.md`) | Hors ligne, refus du patient avec saisie manuelle, synchronisation |
| 4:00-4:40 | **Sous le capot** : Flutter, base locale, Firebase, voix locale, 76 tests unitaires | « Par défaut, rien ne quitte le téléphone ; un mode connecté facultatif, avec consentement, améliore la transcription quand Internet est disponible. » |
| 4:40-5:00 | **Impact et suite** : ODD 3, feuille de route | Chiffrement, validation clinique, langues locales |

## Diapositives (6 maximum)
1. Titre et problème. 2. Le parcours en 8 étapes (image). 3. « IA propose, humain valide » (urgence ▲ ◆ ■ : couleur, forme et texte).
4. Architecture. 5. Réel et simulé (honnêteté). 6. Suite.

## Dire clairement (et ne pas gonfler)
- **Réel :** parcours complet hors ligne, base locale, synchronisation, profil, consentement et refus, saisie manuelle avec estimation en direct.
- **À présenter avec prudence :** reconnaissance vocale (qualité moyenne, corrigeable) ; règles d'urgence (démonstration) ; mode connecté (facultatif).
- **À ne jamais affirmer :** « chiffré » (pas encore), « validé médicalement », « diagnostic », « 100 % local » quand le mode connecté est actif.

## Questions probables du jury
1. **La transcription est-elle fiable ?** Pas parfaitement : modèle local léger, d'où la correction par l'agent. Un mode connecté facultatif peut l'améliorer avec Internet.
2. **Pourquoi pas un service cloud pour la voix ?** Il faut du réseau, et l'audio d'un patient ne devrait pas voyager sans nécessité. Notre choix : local par défaut ; mode connecté facultatif, désactivé par défaut, avec consentement explicite.
3. **L'IA fait-elle un diagnostic ?** Non. Elle propose un niveau d'urgence avec ses raisons ; l'agent décide.
4. **Les seuils d'urgence sont-ils validés ?** Non : valeurs de démonstration, à valider avec des professionnels de santé et les protocoles OMS.
5. **Et la sécurité ?** PIN, biométrie, verrouillage manuel, règles Firestore par agent, QR sans donnée médicale. Chiffrement local prévu, pas encore actif.
6. **Téléphone perdu ?** PIN ; données envoyées déjà sur le serveur. Le chiffrement complétera la protection.
7. **Si le patient refuse ?** Saisie manuelle, refus consigné, symptômes pris en compte dans l'estimation.
8. **Doublons de dossiers hors ligne ?** Identifiants uniques de 8 caractères ; contrôle d'unicité à renforcer à la synchronisation.
9. **Pourquoi Vosk plutôt que Whisper ?** Plus léger et plus rapide à intégrer dans le délai ; l'interface permet de changer de moteur.
10. **Et après le hackathon ?** Chiffrement, validation clinique, langues locales, constantes vitales, vue pour les structures de référence.
11. **Comment avez-vous testé ?** 76 tests unitaires sur les règles métier, validateurs et profil ; tests manuels sur téléphone, y compris en mode avion.

## Conseils pratiques
Répéter **trois fois** avec chronomètre ; annoncer le plan B ; décider qui parle et qui manipule le téléphone.
