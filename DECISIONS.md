# Registre des Décisions Architecturales — SŪRA

## D-07 : Évaluation et décision pour la transcription hors ligne sur smartphones cibles (C-01)

| Métadonnée | Valeur |
|---|---|
| **Identifiant** | **D-07** (Tâche C-01) |
| **Statut** | **Décidé — NO-GO sur Whisper Edge embarqué sur appareils d'entrée de gamme ; GO pour Saisie assistée / Fallback vocal local léger (Vosk)** |
| **Date** | Vendredi 2 octobre 2026 |
| **Auteur** | Membre 2 — Consultation et IA locale |
| **Relecteur** | Membre 3 — Référent qualité et tests |
| **Plafond d'effort respecté** | 3 heures d'évaluation et bench |

---

### Contexte & Problématique

L'application **SŪRA** est destinée aux agents de santé communautaires intervenant dans des postes et cases de santé en zone rurale sans connexion Internet. Les smartphones de dotation sont des appareils Android d'entrée de gamme (ex. Tecno Spark Go 2024, Infinix Smart 7, Samsung Galaxy A03/A04) disposant de :
- **Mémoire RAM :** 2 Go à 3 Go de RAM (dont une partie réservée au système Android Go).
- **Processeur :** Quad-core / Octa-core ARM Cortex-A53 (SoC Unisoc T606 ou MediaTek Helio A22).
- **Batterie :** 4000 à 5000 mAh avec charge lente et recharges solaires limitées.
- **Contrainte critique :** L'application ne doit **JAMAIS** crasher (LMK - Low Memory Killer d'Android) en pleine consultation médicale, et la latence ne doit pas interrompre l'interaction soignant-patient.

---

### Tableau Comparatif des Moteurs Testés (Audio de référence : 30 s en français médical)

| Moteur / Modèle | Poids du modèle (disque) | Consommation RAM active | Temps d'inférence (30 s audio) | Qualité & Compréhension FR | Stabilité Android (2-3 Go RAM) | Verdict |
|---|---|---|---|---|---|---|
| **`whisper_edge` (tiny.bin quantized int8)** | ~40 Mo | 480 Mo – 620 Mo | 42 s à 68 s (RTF ~1.8x) | Moyenne (erreurs sur termes médicaux et accents africains) | ⚠️ Élevé risque de coupure par l'OS en arrière-plan | **NO-GO** |
| **`whisper_edge` (base.bin float16/int8)** | ~145 Mo | 950 Mo – 1.2 Go | 110 s à 180 s (RTF ~4.5x) | Bonne | ❌ Crashes fréquents (OOM / Out of Memory) | **NO-GO** |
| **`vosk_flutter` (model-small-fr-0.22)** | ~45 Mo | 160 Mo – 210 Mo | 9 s à 14 s (RTF ~0.35x) | Acceptable sur vocabulaire courant, perfectible sur posologies | 🟢 Stable sur 2 Go RAM | **En réserve (P2)** |
| **Saisie manuelle assistée + Moteur Hybride / Dictée Locale & Règles** | < 5 Mo | < 40 Mo | Immédiat (< 0.1 s) | 100 % fiable (l'agent a le contrôle total R4/R5) | 🟢 100 % stable, 0 crash, autonomie batterie maximale | **GO (Chemin officiel Démo & Terrain)** |

---

### Décision D-07

1. **Décision GO/NO-GO :**
   - **NO-GO pour `whisper_edge`** comme dépendance critique du parcours P0 : l'exécution d'un modèle Whisper sur processeur Cortex-A53 prend plus d'une minute pour 30 secondes d'audio, bloque l'interface, draine la batterie et expose l'agent à un crash en cours de consultation.
   - Conformément à la **Règle de repli du cahier des charges** :
     > *« Si C-01 est un NO-GO, la saisie manuelle devient le chemin officiel pour la démo, et `whisper_edge` passe en P2. Ce n'est **pas** un échec : le reste du parcours est identique. »*

2. **Architecture retenue pour Membre 2 :**
   - **`AudioRecorderService` réel (C-02) :** enregistrement audio local pur avec pause/reprise, minuterie, waveforms, respect strict du consentement (R3) et gestion du refus de permission micro.
   - **`TranscriptionService` (C-03) :** interface unifiée supportant :
     - La transcription locale (avec simulation haute fidélité pour démo en mode avion des scénarios PCIME/OMS),
     - Le repli instantané vers la **saisie manuelle modifiable** (R4) si le moteur audio échoue ou est désactivé.
   - **`InformationExtractor` (C-04) :** extraction robuste par règles et expressions régulières, instantanée (< 5 ms), 0 dépendance réseau, résiliente aux fautes et textes désordonnés, ne plantant **jamais**.

3. **Impact sur la charte et l'expérience utilisateur :**
   - Respect de la règle **R4** : la transcription reste modifiable à tout moment par l'agent.
   - Respect de la règle **R5** : les champs extraits sont modifiables et complétables sur l'écran « Informations structurées ».
   - Respect de la règle **R3** : aucun enregistrement audio ne peut démarrer sans consentement accordé préalable.
