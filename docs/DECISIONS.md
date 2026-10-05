# Journal des décisions

Format : `D-xx · date · décision · porteur · raison`. Ajouter en bas. Ne jamais réécrire l'historique : on ajoute une nouvelle ligne qui remplace l'ancienne.

| ID | Date | Décision | Porteur | Raison |
|---|---|---|---|---|
| D-01 | 01/10 | Architecture feature-first légère, Riverpod, go_router, Drift, QR opaque, Firebase (Auth + Firestore) | Équipe (CDC) | Choix validés dans le cahier des charges |
| D-02 | 01/10 | **Modèles Dart écrits à la main** (pas de `freezed`/`json_serializable`) | Lead | Moins de génération de code = moins de blocages. Drift reste généré. |
| D-03 | 01/10 | **Riverpod sans générateur** (pas de `riverpod_generator`) | Lead | Idem. Mêmes concepts, moins d'outillage. |
| D-04 | 01/10 | **Chiffrement SQLCipher reporté** en P2 (derrière un interrupteur) | Lead | Risque de build Android ; l'application doit d'abord fonctionner. |
| D-05 | 01/10 | **Contrats + fakes** : chacun développe contre des interfaces ; Firebase et transcription réelle branchés ensuite | Lead | Permet le travail en parallèle sans attendre Firebase ni le test STT |
| D-06 | 01/10 | Calendrier compressé du 1er au 5 octobre ; gel du code lundi 12:00 | Lead | Délai réel restant |
| D-07 | ____ | Moteur de transcription : whisper_edge / vosk / saisie manuelle | Membre 2 | Résultat du test C-01 (à renseigner avant le 02/10 18:00) |
