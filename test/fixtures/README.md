# Fixtures de test

`consultations.json` (livré par D-03, Membre 5) : textes de consultation FICTIFS en français,
avec le résultat attendu de l'extraction et du niveau d'urgence. Utilisé par les tests de
l'extracteur (C-04), du vérificateur (U-01) et du score d'urgence (U-02).

Format cible d'une entrée :

```json
{
  "id": "scenario-01",
  "patient": { "ageYears": 7, "sex": "M" },
  "transcript": "Texte dicté…",
  "expected": {
    "chiefComplaint": "Fièvre",
    "durationContains": "3 jours",
    "missingCodes": ["allergies"],
    "urgency": "moderate"
  }
}
```
Le fichier réel contient 3 scénarios (faible, modéré, élevé) et plus de champs « expected » que
l'exemple ci-dessus (symptômes, constantes, allergies…). Il est vérifié contre les règles réelles par
`consultations_fixtures_test.dart`. Description lisible : `docs/demo/SCENARIOS.md`.

Aucune donnée réelle de patient. Jamais.
