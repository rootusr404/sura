# SŪRA — Scénarios de démonstration (D-03)

Trois consultations **fictives**, une par niveau d'urgence. Elles servent à la démonstration, à la recette (U-05) et aux tests automatiques.

- Aucune donnée réelle : les noms, villages et chiffres sont inventés.
- Les données lisibles par les tests sont dans `test/fixtures/consultations.json`.
- Le test `test/fixtures/consultations_fixtures_test.dart` fait tourner les règles réelles (informations manquantes, urgence) sur ces scénarios. Si une règle change et qu'un résultat attendu n'est plus vrai, le test échoue.

Comment lire un scénario : on lit le **texte dicté** à voix haute (ou on le saisit à la main si la transcription n'est pas disponible), puis on compare l'écran de SŪRA au **résultat attendu**.

---

## Scénario 1 : cas bénin (urgence faible)

**Patient** : Aïssatou Ba, 28 ans, F, Village-Test-A.

**Texte dicté**
> Consultation de madame Aïssatou Ba, 28 ans, du village de Test A. Elle vient pour un rhume. Le nez coule et elle éternue beaucoup depuis 2 jours. Elle a aussi une toux légère. Elle n'a pas de fièvre, la température est de 36,8 degrés. Le pouls est à 76. Elle n'a aucune allergie connue. Elle ne prend aucun médicament. Elle n'a pas d'antécédents particuliers. Elle mange et boit normalement. Je lui conseille du repos et de boire beaucoup d'eau.

**Résultat attendu**

| Élément | Attendu |
|---|---|
| Motif | Rhume |
| Symptômes | nez qui coule, éternuements, toux légère |
| Durée | 2 jours |
| Température / pouls | 36,8 °C / 76 |
| Allergies / médicaments / antécédents | aucune / aucun / aucun |
| Informations manquantes | **aucune** |
| Urgence | **Faible** : « Aucun signe de gravité détecté… » |

À montrer : le cas où tout va bien. « Rien ne semble manquer » et une urgence faible.

---

## Scénario 2 : fièvre de 3 jours chez une adulte (urgence modérée)

**Patient** : Fatou Keïta, 34 ans, F, Village-Test-B.

**Texte dicté**
> Consultation de madame Fatou Keïta, 34 ans, du village de Test B. Elle vient pour de la fièvre. Cela dure depuis 3 jours. Elle a aussi de violents maux de tête et une toux sèche. La température mesurée est de 39,4 degrés. Le pouls est à 98. Elle allaite son enfant de 8 mois. Elle n'a aucune allergie connue. Elle a pris du paracétamol hier sans amélioration. Elle n'a pas d'antécédents. Elle boit bien et marche normalement.

**Résultat attendu**

| Élément | Attendu |
|---|---|
| Motif | Fièvre |
| Symptômes | fièvre, maux de tête, toux sèche |
| Durée | 3 jours |
| Température / pouls | 39,4 °C / 98 |
| Allergies / médicaments / antécédents | aucune / paracétamol / aucun |
| Informations manquantes | **aucune** |
| Urgence | **Modérée** : « Fièvre depuis 3 jours » |

À montrer : une urgence qui s'explique par une **raison lisible**, et le changement du niveau par l'agent avec un **motif obligatoire**.

---

## Scénario 3 : convulsion chez un enfant (urgence élevée)

**Patient** : Amadou Sow, 4 ans, M, Village-Test-C.

**Texte dicté**
> Consultation de l'enfant Amadou Sow, 4 ans, du village de Test C, amené par sa mère. Il a de la fièvre depuis 2 jours avec des frissons. Ce matin, il a fait une convulsion. La température mesurée est de 40,1 degrés. Le pouls est à 110. Il respire vite, 34 par minute. Il pèse 14 kilos. Il est drépanocytaire, c'est un antécédent connu. Il est allergique à la pénicilline. Il refuse de manger. Il faut le référer rapidement.

**Résultat attendu**

| Élément | Attendu |
|---|---|
| Motif | Fièvre avec convulsion |
| Symptômes | fièvre, frissons, convulsion |
| Durée | 2 jours |
| Température / pouls | 40,1 °C / 110 |
| Allergies / antécédents | pénicilline / drépanocytose |
| Médicaments | **non précisés dans le texte** |
| Informations manquantes | **les médicaments en cours** |
| Urgence | **Élevée** : « Convulsions signalées », température très élevée |

À montrer : une urgence élevée, une **information manquante** signalée sans bloquer la suite (R6), et la validation par l'agent (R8).

---

## Remarques

- Les champs « Informations manquantes » et « Urgence » viennent des règles de l'application (U-01 et U-02). Ce sont des règles simples et ne remplacent pas un avis médical.
- Les champs extraits du texte (motif, symptômes, température…) dépendent de l'extraction du Membre 2 (C-04). Si l'extraction donne un résultat un peu différent, notez l'écart dans une issue plutôt que de modifier ce document.
- Si la transcription automatique n'est pas disponible, saisissez le texte à la main : le reste du parcours est identique.
