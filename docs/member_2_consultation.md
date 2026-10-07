# Membre 2 — Consultation : Enregistrement, Transcription, Structuration

Ce module regroupe l'ensemble des travaux de **Membre 2** pour l'assistant médical intelligent hors ligne **SŪRA** (Hackathon FlutterFire Summer Camp 2026).

---

## 1. Synthèse des Tâches et Livrables

| ID | Priorité | Tâche | Livrable | Statut |
|---|---|---|---|---|
| **C-01** | **P0** | **Test de transcription hors ligne & Décision** | Tableau comparatif des moteurs (Whisper vs Vosk vs Saisie assistée) sur téléphones cibles (2-3 Go RAM). Décision **D-07** consignée dans [`DECISIONS.md`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/DECISIONS.md) et [`docs/decisions.md`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/docs/decisions.md). | **Terminé (D-07 validé)** |
| **C-02** | **P0** | **Enregistrement audio** | [`AudioRecorderService`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/lib/services/ai_local/audio_recorder_service.dart) réel avec `record` · Écran [`AudioRecordingScreen`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/lib/features/consultation/presentation/screens/audio_recording_screen.dart) (minuteur MM:SS, waveforms animées, pause, arrêt) · Permission micro (refus F7 → message + repli saisie manuelle) · **Refuse formellement de démarrer sans consentement accordé (Règle R3)** · Fichier local uniquement. | **Terminé** |
| **C-03** | **P0** | **Transcription hors ligne & Mode Avion** | [`TranscriptionService`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/lib/services/ai_local/transcription_service.dart) · Écran [`TranscriptionScreen`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/lib/features/consultation/presentation/screens/transcription_screen.dart) avec texte **modifiable** (**Règle R4**), progression fluide, 100 % hors ligne / mode avion · Réécoute audio locale · **Repli : saisie manuelle** automatique ou guidée si le moteur échoue. | **Terminé** |
| **C-04** | **P0** | **Extraction des champs médicaux** | [`InformationExtractor`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/lib/services/ai_local/information_extractor.dart) par règles/RegExp : motif, symptômes, durée, température, pouls, fréquence respiratoire, allergies, médicaments, antécédents, âge, grossesse, poids. Écran [`StructuredInfoScreen`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/lib/features/consultation/presentation/screens/structured_info_screen.dart) **modifiable** (**Règle R5**). **Ne plante jamais** sur texte vide ou incohérent. ≥ 6 tests avec fixtures D-03. | **Terminé** |

---

## 2. Décision D-07 (C-01) — Benchmark Transcription Hors Ligne

Sur smartphone d'entrée de gamme (Tecno Spark Go, Infinix Smart 7, Samsung Galaxy A03/A04 - 2 à 3 Go RAM) :
- `whisper_edge` int8 : inférence de 42 s à 68 s pour 30 s d'audio, consommation de 480 à 620 Mo de RAM, risque élevé de Low Memory Killer (LMK) d'Android tuant l'application en consultation. **Décision : NO-GO en P0**.
- **Règle de repli appliquée** : la saisie manuelle et la transcription assistée deviennent le chemin officiel pour la démo, et `whisper_edge` passe en P2. Le reste du parcours est strictement identique.

---

## 3. Architecture et Fichiers Livrés

```
lib/
├── app/
│   └── theme.dart                     # Charte SŪRA (Teal #0F6E6E, Sable #F7F7F5, Encre #211C17)
├── core/
│   └── models/
│       └── consultation_data.dart     # Modèle partagé de consultation (Section 6)
├── services/
│   └── ai_local/
│       ├── audio_recorder_service.dart # Service AudioRecorder réel avec règle R3
│       ├── transcription_service.dart  # Service de transcription hors ligne & repli
│       └── information_extractor.dart  # Moteur d'extraction par règles & RegExp (ne plante jamais)
├── features/
│   └── consultation/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── audio_recording_screen.dart   # Écran 21 (Minuteur, Stop, waveforms, F7)
│       │   │   ├── transcription_screen.dart     # Écran 22 (Texte modifiable R4, écoute)
│       │   │   ├── structured_info_screen.dart   # Écran 23 (Champs modifiables R5, constantes)
│       │   │   └── consultation_flow_screen.dart # Parcours intégré avec consentement (R3)
│       │   └── widgets/
│       │       ├── audio_waveform.dart           # Visualiseur d'ondes audio animées
│       │       ├── editable_field_tile.dart      # Tuile de champ modifiable / manquant
│       │       └── step_header.dart              # En-tête 11 étapes conforme à la maquette
│       └── providers/
│           └── consultation_providers.dart       # Riverpod providers (Section 6)
└── main.dart                                     # Point d'entrée Flutter avec ProviderScope
```

---

## 4. Tests et Fixtures Cliniques

- [`test/fixtures/clinical_transcripts.dart`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/test/fixtures/clinical_transcripts.dart) : fixtures cliniques réalistes (D-03 Fatou Keïta, Amadou Sow PCIME, Diarrhée nourrisson, Grossesse, Bruit, Texte vide).
- [`test/services/ai_local/information_extractor_test.dart`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/test/services/ai_local/information_extractor_test.dart) : 9 tests unitaires exhaustifs (résilience texte vide/bruit, extraction motif/durée/constantes/médicaments/antécédents, gestion des négations, sérialisation JSON).
- [`test/services/ai_local/audio_recorder_service_test.dart`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/test/services/ai_local/audio_recorder_service_test.dart) : tests unitaires d'enregistrement et vérification stricte de la règle R3 (blocage sans consentement).
- [`test/services/ai_local/transcription_service_test.dart`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/test/services/ai_local/transcription_service_test.dart) : tests de transcription locale, émission de progression, et repli gracieux d'erreur.
- [`test/features/consultation/consultation_flow_test.dart`](file:///Users/maccephasadzimah/Desktop/FFSC_Final_Hackaton/sura/test/features/consultation/consultation_flow_test.dart) : tests de widgets et d'intégration du flux complet.
