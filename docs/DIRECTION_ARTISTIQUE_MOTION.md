# SŪRA : direction artistique, motion design et voix off

**Le film de 3 minutes** · version 1 · Hackathon FlutterFire Summer Camp 2026 · ODD 3

Ce document est la référence unique pour fabriquer le film de présentation : direction artistique, charte de mouvement, storyboard seconde par seconde, script de voix off, son, liste des captures à faire, garde-fous de véracité et feuille de route de production. Il est écrit pour être lu par l'équipe **et** utilisé comme cahier des charges par un outil de génération de motion (composition de code, logiciel de montage ou autre).

---

## 0. Comment utiliser ce document

| Si vous êtes… | Lisez | Faites |
|---|---|---|
| **La personne qui pilote le film** | §1, §9, §11, §12 | Décidez les points marqués **À DÉCIDER**, verrouillez le script, répartissez les tâches |
| **La personne qui capte l'écran** | §8, §9 | Suivez le protocole de capture (§8), uniquement des données fictives |
| **La personne qui anime (ou l'outil de génération)** | §2, §3, §4, §10 | Construisez chaque scène avec les tokens de mouvement (§3) et la table de scènes (§4) |
| **La voix** | §5, §6 | Lisez le script (§5) avec les indications de jeu (§6) |
| **Le relecteur** | §9 | Cochez la table de preuve : tout ce qui est dit ou montré est vrai |

**Règle d'or du film : montrer l'application réelle.** Le motion design habille, relie et explique ; il ne remplace jamais une démonstration. Chaque promesse du film doit pouvoir être vérifiée dans l'application (§9).

---

## 1. Vue d'ensemble du projet (360°)

### 1.1 En une phrase
SŪRA est une application mobile qui aide un agent de santé de première ligne à documenter une consultation **sans connexion Internet** : *SŪRA propose, l'agent vérifie et valide.* L'application ne pose jamais de diagnostic.

### 1.2 Le problème
Dans les zones isolées, les agents de santé travaillent souvent avec des dossiers papier et une connexion rare ou absente. Les informations se perdent, les consultations sont notées de façon incomplète, et il est difficile de repérer à temps un patient qui a besoin d'une prise en charge urgente.

### 1.3 La solution
| Besoin de l'agent | Réponse de SŪRA |
|---|---|
| Travailler sans réseau | Base locale (Drift / SQLite) ; tout est enregistré d'abord sur le téléphone ; synchronisation automatique au retour du réseau |
| Accéder en sécurité | Connexion en ligne la première fois seulement, puis PIN à 6 chiffres, biométrie facultative, verrouillage manuel |
| Identifier un patient | Identifiant unique `SUR-AAAA-XXXXXXXX`, QR code ne contenant que cet identifiant |
| Respecter le patient | Consentement avant tout enregistrement ; en cas de refus, saisie manuelle et refus consigné |
| Gagner du temps | Voix transcrite localement (Vosk), informations structurées automatiquement, toujours modifiables |
| Ne rien oublier | Informations manquantes signalées, sans jamais bloquer |
| Repérer l'urgence | Niveau proposé ▲ élevé · ◆ modéré · ■ faible, avec ses **raisons** ; l'agent peut le modifier |
| Garder la main | Validation par 5 confirmations ; l'application ne valide jamais seule |

### 1.4 Les 8 étapes d'une consultation (à connaître par cœur)
`Consentement → Enregistrement → Transcription → Informations → Manquantes → Urgence → Récapitulatif → Validation`
En cas de refus du patient : parcours en **6 étapes** (saisie manuelle), avec **estimation d'urgence en direct**.

### 1.5 À qui s'adresse le film
- **Le jury du hackathon** : comprendre en 3 minutes le problème, la solution, la preuve que ça marche, et la maturité technique.
- **Les mentors et partenaires** : percevoir une équipe sérieuse, honnête sur ses limites, capable de livrer.
- **Un public non technique** : le message doit rester compréhensible sans connaître Flutter ni Firebase.

### 1.6 Les critères du hackathon et comment le film y répond

| Critère du hackathon | Ce que le film doit faire sentir | Où |
|---|---|---|
| **Impact local, problème réel** | Un agent, un patient, pas de réseau : un défi quotidien concret en santé | S1, S2, S10 |
| **Architecture et qualité logicielle** | Offline-first, état géré (Riverpod), règles métier testées (76 tests), sécurité Firebase, null safety | S3, S9 |
| **Inclusion et diversité** | Une équipe aux profils variés, un produit pensé pour des agents de première ligne | S10 |
| **Employabilité et incubation** | Une équipe qui sait présenter, s'exprimer, assumer ses limites | S9, S10, S11 |

### 1.7 Ce qui est réel, simulé ou hors périmètre (à ne jamais gonfler)

| | État |
|---|---|
| **Réel** | Parcours complet hors ligne, base locale, synchronisation, profil, consentement et refus, saisie manuelle avec estimation en direct, PIN et biométrie, QR, thème clair/sombre |
| **À présenter avec prudence** | Reconnaissance vocale (qualité moyenne, corrigeable) ; règles d'urgence (valeurs de **démonstration**, non validées cliniquement) ; mode connecté (facultatif, désactivé par défaut) |
| **Hors périmètre / à ne jamais affirmer** | « Chiffré » (le chiffrement de la base n'est pas actif) ; « validé médicalement » ; « diagnostic » ; « 100 % local » quand le mode connecté est actif ; « rien ne quitte le téléphone » (les dossiers validés **sont** synchronisés) |

---

## 2. Direction artistique

### 2.1 Concept : « Le fil qui tient »
Un **fil** (une ligne fine, couleur teal) traverse tout le film. Il relie le patient, l'agent et le dossier.
- Quand le réseau disparaît, le fil **se coupe vers l'extérieur** mais reste **intact sur le téléphone** : le soin est documenté quand même.
- Quand le réseau revient, le fil **se reconnecte** et le dossier part, sans rien perdre.

Cette image porte les trois idées de SŪRA : **continuité** (hors ligne), **confiance** (l'agent garde la main), **lien** (synchronisation).

### 2.2 Ambiance
Sobre, chaleureuse, humaine. Ni froide ni « tech spectaculaire ». Le film parle de soin : il doit inspirer le calme et la fiabilité.
- **Mots-clés** : papier, terre, lumière du jour, clarté, sérieux, respect.
- **À éviter** : néons, fond noir « hacker », circuits et robots, clichés folkloriques, misérabilisme, visages de vrais patients.

### 2.3 Palette (tokens réels de l'application, `lib/core/theme.dart`)

| Token | Hex | Rôle dans le film |
|---|---|---|
| `teal` | `#0F6E6E` | Couleur de marque, le **fil**, boutons, éléments actifs |
| `tealDark` | `#0B5252` | Titres sur fond clair, ombres de marque |
| `tealLight` | `#5CC4C0` | Accents sur fond sombre, lueurs douces |
| `bg` | `#F7F7F5` | Fond principal : le **papier** |
| `bgDark` | `#101A1A` | Fond des scènes sombres (thème sombre, conclusion) |
| `cardDark` | `#182525` | Cartes sur fond sombre |
| `ink` | `#211C17` | Texte principal |
| `grey` | `#625B52` | Texte secondaire |
| `argile` | `#A6512F` | Urgence **élevée** ▲ |
| `ambre` | `#C98A2C` | Urgence **modérée** ◆ (graphisme) |
| `ambreDark` | `#855608` | Urgence modérée quand c'est du **texte** |
| `savane` | `#5F7A52` | Urgence **faible** ■ |
| `error` | `#B42318` | Erreur uniquement (jamais pour décorer) |
| `infoBg` · `warnBg` · `errorBg` | `#DCEDEC` · `#F3E3C2` · `#FDECEA` | Fonds de messages |

**Répartition visuelle recommandée** : 60 % papier (`bg`), 25 % ink et grey (texte), 12 % teal (marque et fil), 3 % couleurs d'urgence (rares, donc lisibles).

**Contrastes** (calculs approximatifs, à revérifier avec un outil avant la version finale) :
| Combinaison | Ratio approx. | Usage |
|---|---|---|
| `ink` sur `bg` | supérieur à 14 | Texte courant ✅ |
| `teal` sur `bg` | environ 5,6 | Titres, boutons ✅ |
| blanc sur `teal` | environ 6 | Texte de bouton ✅ |
| `tealLight` sur `bgDark` | environ 8,5 | Accent sur fond sombre ✅ |
| `argile` sur `bg` | environ 5,1 | Texte ou icône d'urgence élevée ✅ |
| `ambre` sur `bg` | **environ 2,7** | ❌ Jamais pour du texte : utiliser `ambreDark` (environ 5,9) |
| `savane` sur `bg` | environ 4,5 | Graphisme et grand texte seulement |

### 2.4 Typographie
- **Police de marque : Inter** (c'est celle prévue par la charte de l'application).
  Attention : au moment de la rédaction, les fichiers Inter ne sont **pas encore embarqués** dans l'application (le code l'indique en commentaire), donc l'interface affiche la police par défaut d'Android. **À DÉCIDER** : embarquer Inter dans l'application avant les captures (recommandé, cohérence), ou utiliser une police proche dans les écrans de motion.
- **Hiérarchie** (base 1920×1080) :
  | Niveau | Taille | Graisse | Usage |
  |---|---|---|---|
  | Titre de scène | 96 px | 700 | Une idée forte par scène |
  | Sous-titre | 48 px | 600 | Précision |
  | Corps | 36 px | 400 à 500 | Textes courts |
  | Légende / sous-titre vidéo | 40 px | 500 | Sous-titres de la voix off |
  | Mention légale | 24 px | 400 | Sources, avertissements |
- **Règle** : un chiffre ou un mot par écran quand c'est possible. Jamais plus de 2 lignes de texte en motion.
- Écrire **« SŪRA »** avec le macron (Ū) partout.

### 2.5 Logo et marque
- Le logo actuel est le mot **SŪRA** (avec macron) en teal. **À DÉCIDER** : logo final, icône d'application (l'icône par défaut est encore celle de Flutter). Pour le film, prévoir une version **teal sur papier** et une **blanche sur teal / bgDark**.
- Zone de protection : au moins la hauteur du « S » autour du logo.
- Le macron peut devenir un **élément d'animation** : il se « pose » sur le U en fin de révélation du logo.

### 2.6 Formes et langage visuel
- **Coins arrondis** : 16 px sur les cartes, 999 px sur les pastilles (comme l'application).
- **Le fil** : trait de 4 px (1080p), bouts arrondis, teal ; peut former des courbes douces, jamais d'angles durs.
- **Symboles d'urgence (les mêmes que dans l'application, toujours forme + texte + couleur)** :
  | Niveau | Forme | Texte | Couleur |
  |---|---|---|---|
  | Élevé | ▲ triangle | ÉLEVÉ | `argile` |
  | Modéré | ◆ losange | MODÉRÉ | `ambre` / `ambreDark` |
  | Faible | ■ carré | FAIBLE | `savane` |
- **Symboles de synchronisation** : ○ en attente · ⟳ en cours · ✓ synchronisé · ⚠ erreur · ⊘ hors ligne.
- **Papier** : texture très légère (grain subtil, opacité 3 à 5 %), jamais envahissante. Les scènes du « avant » (papier) ont un fond un peu plus chaud ; les scènes SŪRA sont plus nettes.

### 2.7 Iconographie et images
- **Illustrations** vectorielles simples (aplats, 2 à 3 couleurs de la palette). Silhouettes **non réalistes et sans visage identifiable** pour l'agent et le patient.
- **Aucune photo de vrai patient, aucun vrai dossier, aucun vrai nom.** Les noms fictifs autorisés : Aïssatou Ba, Fatou Keïta, Amadou Sow.
- **Téléphone** : cadre Android **générique** (sans marque, sans logo constructeur), sobre, avec un léger relief.
- **Représentation** : montrer des personnes et des contextes africains de façon digne, sans cliché ni pitié (voir §11.3).

### 2.8 Thème clair / sombre
- Corps du film en **thème clair** (papier).
- **Une séquence sombre** (S9, « sous le capot ») et la conclusion (S11) en `bgDark` pour marquer le changement de registre.
- L'application a un thème sombre : on peut le montrer en 2 secondes dans S3 ou S9, mais pas plus.

### 2.9 Accessibilité du film
- Sous-titres français **incrustés** à 100 % de la voix off.
- Contraste de texte d'au moins 4,5:1 (voir §2.3).
- Pas de clignotement supérieur à 3 Hz.
- Vitesse de lecture des sous-titres : 17 caractères par seconde au maximum.
- Le sens ne repose jamais sur la couleur seule (même règle que dans l'application).

---

## 3. Charte de mouvement (motion design)

### 3.1 Principes
1. **Le mouvement explique.** Chaque animation répond à une question : d'où vient cette information ? où va-t-elle ?
2. **Calme et précis.** Pas de rebonds exagérés, pas d'effets de zoom gratuits.
3. **Un seul sujet à la fois.** Une idée = un plan.
4. **Cohérence.** Mêmes durées, mêmes courbes, mêmes entrées/sorties partout.
5. **Le fil est le fil rouge.** Il guide l'œil d'une scène à la suivante.

### 3.2 Tokens de mouvement

**Durées** :
| Token | Durée | Usage |
|---|---|---|
| `xs` | 120 ms | Changement d'état (case cochée, pastille) |
| `s` | 200 ms | Apparition d'un petit élément |
| `m` | 320 ms | Carte, ligne, bouton |
| `l` | 480 ms | Transition de panneau |
| `xl` | 720 ms | Entrée de scène |
| `hero` | 1200 ms | Révélation du logo, moment fort |

**Courbes (CSS cubic-bezier)** :
| Nom | Valeur | Usage |
|---|---|---|
| `standard` | `cubic-bezier(0.2, 0, 0, 1)` | Par défaut |
| `decelerate` | `cubic-bezier(0, 0, 0, 1)` | Entrées |
| `accelerate` | `cubic-bezier(0.3, 0, 1, 1)` | Sorties |
| `spring-soft` | ressort : raideur 170, amortissement 24, masse 1 | Pose du macron, atterrissage d'une carte |

**Rythme** :
- **Décalage en cascade (stagger)** : 60 ms entre éléments d'une liste, 5 éléments au maximum.
- **Tenue minimale** d'un texte à l'écran : 1,2 s + 40 ms par caractère.
- **Coupe entre scènes** : transition portée par le **fil** (il sort d'un plan et entre dans le suivant), durée `l`.
- **Mouvements de caméra** (zoom/recadrage sur l'écran) : 4 % à 12 % d'échelle, jamais plus, courbe `standard`.

### 3.3 Vocabulaire d'animation réutilisable

| Nom | Description | Durées / courbes |
|---|---|---|
| **Le fil trace** | Le trait se dessine de A vers B (longueur 0 à 100 %) | `xl`, `standard` |
| **Le fil se coupe** | Le trait se rompt au milieu côté « extérieur », deux extrémités se rétractent de 24 px et la partie « téléphone » reste tracée ; icône ⊘ apparaît | `m`, `accelerate` |
| **Le fil se reconnecte** | Les deux extrémités se rejoignent, flash doux `tealLight` à 30 %, ✓ apparaît | `l`, `spring-soft` |
| **Le papier devient carte** | Une feuille manuscrite se plie en une carte d'interface propre (rotation 3D légère, 8°) | `xl`, `standard` |
| **Le champ se range** | Un mot de la phrase dictée « vole » vers son champ (motif, durée, température) | `m`, `decelerate`, 60 ms de décalage |
| **Le souffle d'urgence** | La pastille ▲ ◆ ■ apparaît par un léger agrandissement (96 % → 100 %), sans pulsation continue | `s`, `spring-soft` |
| **Raison qui s'allume** | Chaque raison d'urgence s'affiche en liste, puce après puce | `s`, stagger 60 ms |
| **Case qui se coche** | Trait de coche dessiné en 120 ms | `xs`, `standard` |
| **Le macron se pose** | Le macron tombe de 12 px sur le U et se stabilise | `hero`, `spring-soft` |

### 3.4 Règles de composition
- Format **16:9, 1920×1080, 30 images par seconde**.
- Marges de sécurité : 96 px sur les bords.
- Zone de sous-titres : bande basse de 140 px, texte centré, fond `ink` à 60 % si besoin.
- Les captures d'écran du téléphone sont **recadrées sans étirement**, dans un cadre générique, avec ombre douce.
- Les **annotations** (flèches, cercles) sont en teal, trait de 4 px, jamais en rouge.

---

## 4. Storyboard : 11 scènes, 180 secondes

Légende : **Type** = `capture` (écran réel du téléphone), `motion` (graphisme animé), `mixte`.
Chaque scène indique ce qui est vu, l'animation, le texte à l'écran, la voix off, le son et la **preuve** (§9).

| # | Temps | Durée | Titre | Type |
|---|---|---|---|---|
| S1 | 0:00 → 0:12 | 12 s | Le problème | motion |
| S2 | 0:12 → 0:30 | 18 s | La solution | motion |
| S3 | 0:30 → 0:50 | 20 s | Accès et hors ligne | mixte |
| S4 | 0:50 → 1:05 | 15 s | Patient et consentement | mixte |
| S5 | 1:05 → 1:35 | 30 s | De la voix aux informations | mixte |
| S6 | 1:35 → 1:55 | 20 s | Manquantes et urgence | mixte |
| S7 | 1:55 → 2:10 | 15 s | Quand le patient refuse | mixte |
| S8 | 2:10 → 2:25 | 15 s | Validation et synchronisation | mixte |
| S9 | 2:25 → 2:42 | 17 s | Sous le capot, et l'honnêteté | motion |
| S10 | 2:42 → 2:55 | 13 s | L'impact (ODD 3) et l'équipe | motion |
| S11 | 2:55 → 3:00 | 5 s | Clôture | motion |

---

### S1 · Le problème (0:00 → 0:12)
- **Visuel** : fond papier chaud. Un carnet manuscrit sur une table en bois (illustration). À côté, un téléphone dont l'indicateur de réseau est vide ⊘. Une silhouette d'agent de santé face à un patient.
- **Animation** :
  1. 0.0 s : fond papier apparaît (fondu `l`).
  2. 0.5 s : le carnet entre par la gauche (`xl`, `decelerate`), des notes s'écrivent ligne par ligne (`m`, stagger 60 ms).
  3. 4.0 s : l'icône réseau passe de 2 barres à 0 (`m`), ⊘ apparaît.
  4. 7.0 s : quelques notes du carnet **s'estompent** (opacité 100 → 30 % en `l`) : les informations se perdent.
  5. 10.5 s : le **fil** apparaît, fin, hésitant, qui part du carnet vers le haut, s'arrête net (il n'a nulle part où aller).
- **Texte à l'écran** (1,5 s à 3 s chacun) : « Pas de réseau. » · « Un carnet. » · « Des informations qui se perdent. »
- **Voix off** : VO-01 (voir §5).
- **Son** : silence habité (ambiance légère, vent doux), un battement de papier. Pas de musique avant 0:08, puis une note tenue grave.
- **Preuve** : contexte, aucune capture. Aucune statistique chiffrée à afficher sans source.

### S2 · La solution (0:12 → 0:30)
- **Visuel** : le fil reprend de la scène précédente et s'illumine en teal. Le carnet devient la carte d'une application (« le papier devient carte »). Le logo SŪRA se révèle.
- **Animation** :
  1. 12.0 s : le fil se rallume (teal, `m`), traverse l'écran de gauche à droite.
  2. 13.5 s : « le papier devient carte » : la feuille se plie en une carte d'interface propre (`xl`).
  3. 16.0 s : le cadre du téléphone apparaît, la carte s'y loge.
  4. 18.0 s : révélation du logo **SŪRA** (`hero`) ; le macron se pose (`spring-soft`).
  5. 22.0 s : sous-titre « L'IA propose. L'agent décide. » (fondu `m`), puis les mots **propose** et **décide** prennent la couleur teal.
  6. 27.0 s : un petit badge « Hors ligne ⊘ » apparaît sous le logo, comme un atout.
- **Texte à l'écran** : « SŪRA » · « L'application propose. L'agent vérifie et valide. »
- **Voix off** : VO-02.
- **Son** : la musique démarre doucement (voir §7) ; un « clic » discret à la pose du macron.
- **Preuve** : principe de l'application (README, section principe).

### S3 · Accès et hors ligne (0:30 → 0:50)
- **Type** : mixte (captures des écrans de connexion et PIN, puis accueil).
- **Capture requise** : écran de connexion → saisie du PIN → accueil « Bonjour, Prénom » → **mode avion activé** → accueil avec « ⊘ Hors ligne ».
- **Animation** :
  1. 30.0 s : le téléphone se recentre, zoom 8 % (`l`).
  2. 31.0 s : annotation « 1ʳᵉ connexion : en ligne » sur l'écran de connexion (flèche teal).
  3. 36.0 s : le PIN se remplit (6 points), le fil trace du clavier vers l'accueil.
  4. 41.0 s : on tire le panneau, **mode avion** s'active : **le fil se coupe** vers l'extérieur (vers le cloud), mais reste intact sur le téléphone.
  5. 46.0 s : bandeau « ⊘ Hors ligne » surligné ; la mention « Tout est enregistré sur le téléphone » apparaît.
- **Texte à l'écran** : « Une connexion en ligne, la première fois » · « Ensuite : PIN ou empreinte » · « Hors ligne ? Rien ne change. »
- **Voix off** : VO-03.
- **Son** : tapotement doux des touches ; un « tic » net quand le mode avion s'active.
- **Preuve** : connexion Firebase à la première utilisation ; PIN à 6 chiffres ; biométrie facultative ; bandeau « Hors ligne » (README, DEMO §B).

### S4 · Patient et consentement (0:50 → 1:05)
- **Capture requise** : fiche d'un patient fictif avec son **QR code** → « Consulter » → écran de **consentement** → « Le patient accepte ».
- **Animation** :
  1. 50.0 s : la carte patient entre (`m`) ; l'identifiant `SUR-…` s'affiche.
  2. 53.0 s : le QR code apparaît ; texte « Identifiant seulement. Aucune donnée médicale. »
  3. 57.0 s : transition vers le consentement ; le texte à lire à voix haute est mis en valeur.
  4. 61.0 s : le bouton « Le patient accepte » est pressé (`xs`), coche dessinée.
- **Texte à l'écran** : « Un identifiant unique » · « QR : l'identifiant seul » · « Consentement avant tout enregistrement »
- **Voix off** : VO-04.
- **Son** : « tic » de validation.
- **Preuve** : identifiant `SUR-AAAA-XXXXXXXX`, QR opaque, consentement (README).

### S5 · De la voix aux informations (1:05 → 1:35)
- **Capture requise** : écran d'enregistrement (minuteur) → transcription → correction d'un mot → informations extraites (motif, symptômes, durée, température…).
- **Phrase dictée** (identique à la démonstration) : « La patiente a de la fièvre depuis trois jours, elle a mal à la tête et elle tousse. Température trente-neuf degrés. »
- **Animation** :
  1. 65.0 s : onde sonore stylisée (barres teal, mouvement continu doux) pendant que le minuteur défile.
  2. 71.0 s : mention « Sur le téléphone » avec une icône de téléphone ; l'onde ne quitte pas le cadre.
  3. 75.0 s : le texte transcrit apparaît mot à mot (`s`, 40 ms par mot).
  4. 82.0 s : **un mot est corrigé** (curseur, correction) : annotation « L'agent vérifie ».
  5. 88.0 s : « le champ se range » : *fièvre*, *trois jours*, *39 °C* volent vers leurs champs (motif, durée, température), stagger 60 ms.
  6. 96.0 s : chaque champ montre un crayon discret : « Tout est modifiable ».
- **Texte à l'écran** : « La voix est transcrite sur le téléphone » · « L'agent corrige » · « Motif · Symptômes · Durée · Température »
- **Voix off** : VO-05.
- **Son** : ambiance de pièce calme pendant la dictée (la voix de l'agent n'est **pas** entendue en entier, juste suggérée) ; petit « pop » à l'arrivée de chaque champ.
- **Preuve** : transcription locale (Vosk) activée (`kUseRealStt = true`), mode connecté **désactivé** ; qualité moyenne et corrigeable (PITCH). **Ne pas dire « précis » ni « parfait ».**

### S6 · Manquantes et urgence (1:35 → 1:55)
- **Capture requise** : écran « informations manquantes » (alertes non bloquantes) → écran « urgence » avec le niveau et ses raisons → modification possible.
- **Animation** :
  1. 95.0 s : les éléments manquants s'affichent en liste douce (`s`, stagger) : leur ton est « Cette information semble manquer ».
  2. 100.0 s : un bouton « Continuer » est mis en évidence : « Jamais bloquant ».
  3. 104.0 s : arrivée de la pastille **◆ MODÉRÉ** (« le souffle d'urgence »).
  4. 107.0 s : les **raisons** s'allument une à une (« Fièvre à 39 °C », « Fièvre depuis 3 jours »).
  5. 112.0 s : les trois niveaux ▲ ◆ ■ apparaissent côte à côte, en insistant : **forme + texte + couleur**.
  6. 115.0 s : l'agent change le niveau : une main (illustration) sélectionne un autre niveau ; « L'agent décide » en légende.
- **Texte à l'écran** : « Ce qui manque est signalé, jamais imposé » · « ▲ Élevé · ◆ Modéré · ■ Faible » · « Avec ses raisons. L'agent peut modifier. »
- **Voix off** : VO-06.
- **Son** : deux notes montantes douces à l'apparition du niveau (aucun son d'alarme agressif).
- **Preuve** : informations manquantes non bloquantes, urgence par règles de **démonstration** (README). **Le mot « diagnostic » est interdit.**

### S7 · Quand le patient refuse (1:55 → 2:10)
- **Capture requise** : « Le patient refuse » → « Continuer en saisie manuelle » → cocher *Fièvre*, durée *3 jours* → l'estimation en haut passe à ◆ MODÉRÉ → cocher *Convulsion* → ▲ ÉLEVÉ.
- **Animation** :
  1. 115.0 s : la carte « Le patient refuse » s'affiche avec respect (pas de couleur d'erreur).
  2. 118.0 s : la barre de progression passe de 8 à **6 étapes**.
  3. 121.0 s : on coche les symptômes ; l'estimation en haut **se met à jour en direct** (◆ puis ▲).
  4. 126.0 s : mention « Refus consigné ».
- **Texte à l'écran** : « Le patient peut refuser » · « La prise en charge continue » · « L'estimation se met à jour en direct »
- **Voix off** : VO-07.
- **Son** : même univers sonore, très sobre.
- **Preuve** : scénario 2 de la démonstration (DEMO §C).

### S8 · Validation et synchronisation (2:10 → 2:25)
- **Capture requise** : écran de validation (5 cases) → « Enregistrer » → statut ○ En attente → retrait du mode avion → ✓ Synchronisé. Option : ligne du document dans la console (données fictives, **aucune clé visible**).
- **Animation** :
  1. 130.0 s : les 5 cases se cochent une à une (« case qui se coche », stagger 120 ms).
  2. 134.0 s : le bouton « Enregistrer » ; pastille **○ En attente**.
  3. 138.0 s : **le fil se reconnecte** (le réseau revient) ; flash doux, la pastille devient **✓ Synchronisé**.
  4. 143.0 s : le dossier « voyage » le long du fil vers un nuage stylisé (sans logo de marque).
- **Texte à l'écran** : « 5 confirmations avant de valider » · « Enregistré, en attente » · « Réseau de retour : synchronisé »
- **Voix off** : VO-08.
- **Son** : « tic » de coche ×5, puis un accord doux à la reconnexion.
- **Preuve** : validation à 5 points ; statuts ○ ⟳ ✓ ⚠ (README).

### S9 · Sous le capot, et l'honnêteté (2:25 → 2:42)
- **Type** : motion sur fond sombre (`bgDark`). C'est la seule vraie rupture de ton.
- **Animation** :
  1. 145.0 s : transition par le fil vers le fond sombre.
  2. 146.0 s : schéma d'architecture en 4 blocs qui s'assemblent : **Interface Flutter** → **Riverpod** → **Services** → **Drift / SQLite** + **Firebase (Auth + Firestore)**.
  3. 152.0 s : « 76 tests automatiques » en grand chiffre, coche verte discrète.
  4. 157.0 s : carte « Notre honnêteté » : liste en trois lignes, apparition lente :
     - « Prototype de hackathon »
     - « Seuils d'urgence : valeurs de démonstration »
     - « À valider avec des professionnels de santé »
- **Texte à l'écran** : « Flutter · Riverpod · Drift · Firebase » · « 76 tests » · « Ce n'est pas un dispositif médical. »
- **Voix off** : VO-09.
- **Son** : la musique baisse d'un niveau, plus grave, plus de silence.
- **Preuve** : `flutter test` donne 76 tests au moment de la rédaction (**à recompter le jour J**) ; chiffrement **non** actif ; seuils non validés (README, PITCH).

### S10 · L'impact et l'équipe (2:42 → 2:55)
- **Animation** :
  1. 162.0 s : retour au fond papier (fondu `l`).
  2. 163.0 s : l'icône ODD 3 « Bonne santé et bien-être » (**logo officiel de l'ONU, à utiliser en respectant ses règles**) ou, à défaut, un simple « ODD 3 » typographique.
  3. 166.0 s : l'équipe : cinq silhouettes/cartes avec rôle et pays. **[À COMPLÉTER : prénoms, pays, rôles de l'équipe]**
  4. 171.0 s : le fil relie les cinq cartes.
- **Texte à l'écran** : « ODD 3 : bonne santé et bien-être » · « Une équipe, cinq profils » · « [Prénoms · pays] »
- **Voix off** : VO-10.
- **Son** : la musique remonte, plus lumineuse.
- **Preuve** : ODD 3 (README). Ne citer que les pays réels de l'équipe.

### S11 · Clôture (2:55 → 3:00)
- **Visuel** : fond `bgDark` ou papier selon le choix final. Logo SŪRA centré, le fil se pose en soulignement.
- **Animation** : logo (`xl`), baseline « L'IA propose. L'agent décide. » (`m`), tenue 2 s, fondu final (`l`).
- **Texte à l'écran** : « SŪRA · L'IA propose. L'agent décide. » + dépôt/contact **[À COMPLÉTER]**.
- **Voix off** : VO-11.
- **Son** : dernière note tenue, résolution douce.

---

## 5. Script de voix off (version à lire)

**Cible** : 130 à 150 mots par minute. Le total fait **296 mots**, soit environ 2 min 07 de parole à 140 mots par minute : il laisse volontairement près de 50 secondes pour la musique, les respirations et les plans silencieux.

| Id | Scène | Temps visé | Texte |
|---|---|---|---|
| VO-01 | S1 | 0:01 → 0:11 | Dans une zone isolée, un agent de santé reçoit un patient. Pas de réseau. Un cahier. Et, trop souvent, des informations qui se perdent avant d'avoir pu aider quelqu'un. |
| VO-02 | S2 | 0:14 → 0:29 | Voici SŪRA. Une application qui fonctionne sans Internet, pour aider l'agent à documenter chaque consultation. Son principe tient en une phrase : SŪRA propose, l'agent vérifie et valide. Jamais de diagnostic. Toujours l'humain. |
| VO-03 | S3 | 0:31 → 0:49 | Une seule connexion en ligne, la première fois. Ensuite, un code PIN, ou l'empreinte, suffit. Et quand le réseau disparaît, rien ne change : tout est d'abord enregistré sur le téléphone. |
| VO-04 | S4 | 0:51 → 1:04 | Chaque patient reçoit un identifiant unique et un QR code, sans aucune donnée médicale. Avant tout enregistrement, le consentement est demandé. |
| VO-05 | S5 | 1:06 → 1:33 | L'agent parle. SŪRA transcrit la voix directement sur le téléphone : par défaut, l'audio ne le quitte jamais. Le texte reste modifiable, l'agent corrige. Puis les informations sont rangées : motif, symptômes, durée, température. Chaque champ peut être changé. |
| VO-06 | S6 | 1:36 → 1:54 | Ce qui semble manquer est signalé, sans jamais bloquer. Puis SŪRA propose un niveau d'urgence, élevé, modéré ou faible, avec ses raisons, en forme, en couleur et en texte. L'agent peut le modifier. Sa décision prime. |
| VO-07 | S7 | 1:56 → 2:09 | Si le patient refuse l'enregistrement, l'agent saisit à la main. Le refus est consigné, et l'estimation d'urgence se met à jour en direct. |
| VO-08 | S8 | 2:11 → 2:24 | Avant de sauvegarder, cinq confirmations. Le dossier est enregistré, en attente. Dès que le réseau revient, il se synchronise, sans rien perdre. |
| VO-09 | S9 | 2:26 → 2:41 | Flutter, une base locale, Firebase, soixante-seize tests automatiques. Et nous le disons honnêtement : c'est un prototype. Les seuils d'urgence sont des valeurs de démonstration, à faire valider par des professionnels de santé. |
| VO-10 | S10 | 2:43 → 2:54 | SŪRA contribue à l'objectif de développement durable numéro trois : bonne santé et bien-être. Pour que documenter un soin ne dépende plus du réseau. |
| VO-11 | S11 | 2:56 → 2:59 | SŪRA. L'IA propose. L'agent décide. |

### Version courte de secours (si le montage dépasse 3 minutes)
Supprimer VO-04 (le patient et le consentement peuvent se montrer sans voix) et raccourcir VO-05 en : « L'agent parle. SŪRA transcrit sur le téléphone, l'agent corrige, et les informations sont rangées automatiquement. »

### Points à décider ou à vérifier (voix)
- **Prononciation de « SŪRA »** : **À DÉCIDER** par l'équipe, puis la fixer pour tout le film (et l'écrire phonétiquement dans la copie du comédien).
- **« Soixante-seize tests »** : à recompter avec `flutter test` le jour de l'enregistrement. Si le chiffre change, **mettre à jour VO-09 et le texte à l'écran**.
- **« Par défaut, l'audio ne le quitte jamais »** : vrai tant que le mode connecté est **désactivé**. Le vérifier dans Paramètres avant la capture.

---

## 6. Direction de la voix

- **Ton** : calme, posé, humain, chaleureux. Celui d'une personne qui explique à un collègue, pas d'un publicitaire.
- **Rythme** : 130 à 150 mots par minute, avec des **respirations** entre les phrases. Insister sur les mots-clés : *sans Internet*, *propose*, *décide*, *jamais*.
- **Émotion** : sérieux et bienveillance. Aucune dramatisation dans S1.
- **S9** : plus bas, plus lent, sincère. C'est le moment de crédibilité du film.
- **Prise de son** : pièce calme, micro à 15–20 cm, filtre anti-pop, 48 kHz, 24 bits. Tourner une prise de sécurité de chaque phrase.
- **Langue** : français. Prévoir des sous-titres anglais pour un jury non francophone **(À DÉCIDER)**.
- **Alternatives** : voix humaine de l'équipe (recommandé pour l'authenticité) ou voix de synthèse. Dans le second cas, **le dire** et vérifier la licence d'usage.

---

## 7. Son et musique

| Élément | Consigne |
|---|---|
| **Musique** | Instrumentale, tempo 78 à 90 BPM, texture douce (cordes pincées, piano, percussions légères). Évoquer le continent sans folklore ni cliché. **Libre de droits uniquement**, licence conservée dans le dossier de soumission. |
| **Niveau** | Voix à environ −16 LUFS intégrés dans le mix de travail ; musique 18 à 20 dB sous la voix ; export final **−14 LUFS**. |
| **Courbe musicale** | S1 : presque rien · S2 : entrée douce · S3–S8 : lit régulier · S9 : plus grave et plus clairsemé · S10 : remontée lumineuse · S11 : note tenue. |
| **Effets** | « tic » d'interface (tap), « clic » du macron, « pop » des champs, accord doux de reconnexion, bruit de papier en S1. **Aucun son d'alarme** pour l'urgence. |
| **Silence** | Un vrai silence de 0,5 s avant la reconnexion du fil en S8 : c'est un moment fort. |

---

## 8. Protocole de capture des écrans réels

### 8.1 Préparation de l'appareil
- [ ] Téléphone chargé, **Ne pas déranger**, luminosité maximale, aucune notification visible.
- [ ] Thème **clair**.
- [ ] Application en version de démonstration, **mode connecté désactivé** (Paramètres).
- [ ] Compte de démonstration, profil complété (« Bonjour, Prénom »).
- [ ] 2 ou 3 patients **fictifs** (Aïssatou Ba, Fatou Keïta, Amadou Sow).
- [ ] Un enregistrement vocal complet déjà fait avant de filmer (le modèle se décompresse au premier usage).
- [ ] Barre d'état propre : heure standard, batterie pleine, réseau visible quand c'est utile.
- [ ] Console Firebase : **aucune clé, aucun e-mail personnel** visible.

### 8.2 Enregistrement
```bash
adb shell screenrecord --time-limit 180 --size 1080x2400 --bit-rate 12000000 /sdcard/sura-s05.mp4
adb pull /sdcard/sura-s05.mp4
```
Un fichier par scène (limite de 180 s par fichier). Reprendre chaque séquence **3 fois** et garder la meilleure.

### 8.3 Liste des captures par scène

| Fichier | Scène | Contenu | Durée utile |
|---|---|---|---|
| `s03-connexion-pin.mp4` | S3 | Connexion, PIN, accueil, mode avion | 20 s |
| `s04-patient-consentement.mp4` | S4 | Fiche patient, QR, consentement accepté | 15 s |
| `s05-voix-transcription.mp4` | S5 | Enregistrement, transcription, correction, informations | 30 s |
| `s06-manquantes-urgence.mp4` | S6 | Manquantes, urgence et raisons, modification | 20 s |
| `s07-refus-manuel.mp4` | S7 | Refus, saisie manuelle, estimation en direct | 15 s |
| `s08-validation-sync.mp4` | S8 | 5 cases, enregistrement en attente, synchronisation | 20 s |
| `bonus-theme-sombre.mp4` | S9 (option) | 2 s de thème sombre | 5 s |

### 8.4 Règles
- Données **fictives** uniquement ; jamais un vrai audio de patient.
- Ne pas filmer un écran d'erreur par accident ; refaire la prise.
- Garder 2 s de marge avant et après chaque geste pour le montage.
- Plan B : la vidéo de secours (DEMO §G) reste disponible.

---

## 9. Garde-fous de véracité : table de preuve

**Avant l'export final, un relecteur différent de l'auteur coche chaque ligne.**

| Ce que dit ou montre le film | Preuve à vérifier | OK |
|---|---|---|
| L'application fonctionne sans Internet | Parcours complet réalisé en mode avion | ☐ |
| Première connexion en ligne, puis PIN | Test sur appareil | ☐ |
| Le fil reste « intact » sur le téléphone | Les données sont bien dans la base locale en mode avion | ☐ |
| Identifiant unique et QR sans donnée médicale | Fiche patient, contenu du QR | ☐ |
| Consentement avant tout enregistrement | Impossible d'enregistrer sans accepter | ☐ |
| Refus : saisie manuelle et refus consigné | Scénario 2 de la démonstration | ☐ |
| Transcription sur le téléphone, audio non envoyé | Mode connecté **désactivé**, aucun envoi réseau de l'audio | ☐ |
| Le texte et les champs sont modifiables | Corrections faites à l'écran | ☐ |
| Informations manquantes jamais bloquantes | « Continuer » toujours actif | ☐ |
| Niveau d'urgence avec raisons, modifiable | Écran d'urgence | ☐ |
| Validation par 5 confirmations | Impossible de valider avec moins | ☐ |
| Synchronisation au retour du réseau | ○ puis ✓ constaté | ☐ |
| « 76 tests automatiques » | `flutter test` recompté le jour J | ☐ |
| « Prototype, seuils de démonstration » | Cité dans la voix off et à l'écran | ☐ |
| ODD 3 | Libellé et logo de l'ONU respectés | ☐ |
| Noms, pays, rôles de l'équipe | Validés par chaque personne concernée | ☐ |

### Ce qu'il ne faut JAMAIS dire ni montrer
- « Chiffré » ou « données chiffrées » (le chiffrement n'est pas actif).
- « Validé médicalement », « conforme OMS », « certifié ».
- « Diagnostic » : SŪRA propose un **niveau d'urgence**, rien de plus.
- « 100 % local » ou « rien ne quitte le téléphone » : les dossiers **validés sont synchronisés**. Dire plutôt « l'audio reste sur le téléphone par défaut ».
- Une statistique de santé sans source.
- Une clé d'API, un identifiant de compte, un e-mail réel, une console avec des secrets.
- Un vrai patient, une vraie voix de patient, un vrai nom.
- La transcription comme « précise » ou « parfaite ».

> **Remarque pour l'équipe** : la ligne du plan de pitch actuel (`docs/PITCH.md`, section « Sous le capot ») dit « Par défaut, rien ne quitte le téléphone ». Elle est **trop forte** puisque les dossiers validés sont synchronisés avec Firebase. À corriger en « l'audio reste sur le téléphone par défaut ».

---

## 10. Production : méthode et prompt de génération

### 10.1 Ordre de travail
1. **Verrouiller le script** (§5) : une seule version, validée par l'équipe.
2. **Capturer les écrans** (§8) et classer les fichiers.
3. **Créer les assets** : logo, fil, illustrations, cadre de téléphone, icônes ▲ ◆ ■.
4. **Animer scène par scène** (§3, §4), en commençant par S2 (la scène de référence) pour fixer le style.
5. **Enregistrer la voix** (§6), puis caler les animations sur la voix (et non l'inverse).
6. **Mixer** musique, voix et effets (§7).
7. **Sous-titrer** (SRT + incrustation).
8. **Relecture de véracité** (§9), puis corrections.
9. **Exporter** (§10.3) et archiver les sources.

### 10.2 Utiliser un outil de génération de motion
Une approche qui fonctionne bien : décrire chaque scène par du **code ou une timeline** (composition par images, HTML/CSS avec animation par script, ou logiciel de montage), puis régénérer scène par scène.
- Fournir à l'outil : ce document entier, les fichiers de capture, le logo et les illustrations.
- Demander **une scène à la fois**, avec un aperçu, et valider la scène avant de passer à la suivante.
- Toujours vérifier : timings (par rapport à la voix), lisibilité des textes, respect de la palette, absence de texte ou de chiffre inventé.
- Garder le code source et les paramètres (tokens §3.2) dans un dossier versionné.

**Modèle de consigne (à adapter)** :
```
Tu réalises la scène {SCÈNE} du film SŪRA (voir DIRECTION_ARTISTIQUE_MOTION.md).
Format 1920x1080, 30 images par seconde, durée {DURÉE} s.
Respecte la palette (§2.3), la typographie Inter (§2.4) et les tokens de mouvement (§3.2).
Animations à produire, avec leurs temps : {liste de l'étape §4}.
Texte à l'écran : {textes exacts de l'étape}. N'ajoute aucun autre texte ni chiffre.
Sous-titres : {texte VO exact}. Voix off et musique ne font pas partie de ce rendu.
Les écrans de l'application proviennent du fichier {capture}. Ne les redessine pas.
Livre un aperçu, puis liste les écarts éventuels avec la spécification.
```

### 10.3 Spécifications d'export
| Livrable | Spécification |
|---|---|
| **Film principal** | MP4 H.264, 1920×1080, 30 i/s, 12 à 16 Mbit/s, audio AAC 320 kbit/s, −14 LUFS |
| **Sous-titres** | `sura-fr.srt` (+ `sura-en.srt` si décidé) |
| **Version courte** | Teaser d'environ 60 s (57 s) : extraits de S1 (8 s), S2 (14 s), S6 (16 s), S8 (14 s) et S11 (5 s), voix off raccourcie |
| **Version verticale** | 9:16 (1080×1920) pour les réseaux sociaux, mêmes scènes recadrées |
| **Vignette** | PNG 1280×720 : logo, fil, une pastille d'urgence |
| **Sources** | Dossier `sources/` : projet d'animation, polices, voix brute, musique + licence |
| **Nommage** | `sura-film-3min-v1.mp4`, `sura-film-3min-v2.mp4`… |

### 10.4 Timeline machine-lisible (pour l'outil de génération)

```json
{
  "format": { "width": 1920, "height": 1080, "fps": 30, "duration_s": 180 },
  "tokens": {
    "colors": {
      "teal": "#0F6E6E", "tealDark": "#0B5252", "tealLight": "#5CC4C0",
      "bg": "#F7F7F5", "bgDark": "#101A1A", "cardDark": "#182525",
      "ink": "#211C17", "grey": "#625B52",
      "argile": "#A6512F", "ambre": "#C98A2C", "ambreDark": "#855608", "savane": "#5F7A52"
    },
    "durations_ms": { "xs": 120, "s": 200, "m": 320, "l": 480, "xl": 720, "hero": 1200 },
    "easing": {
      "standard": [0.2, 0, 0, 1], "decelerate": [0, 0, 0, 1], "accelerate": [0.3, 0, 1, 1],
      "springSoft": { "stiffness": 170, "damping": 24, "mass": 1 }
    },
    "font": "Inter"
  },
  "scenes": [
    { "id": "S1",  "start": 0,   "end": 12,  "type": "motion",  "voice": "VO-01", "theme": "paper" },
    { "id": "S2",  "start": 12,  "end": 30,  "type": "motion",  "voice": "VO-02", "theme": "paper" },
    { "id": "S3",  "start": 30,  "end": 50,  "type": "mixte",   "voice": "VO-03", "capture": "s03-connexion-pin.mp4" },
    { "id": "S4",  "start": 50,  "end": 65,  "type": "mixte",   "voice": "VO-04", "capture": "s04-patient-consentement.mp4" },
    { "id": "S5",  "start": 65,  "end": 95,  "type": "mixte",   "voice": "VO-05", "capture": "s05-voix-transcription.mp4" },
    { "id": "S6",  "start": 95,  "end": 115, "type": "mixte",   "voice": "VO-06", "capture": "s06-manquantes-urgence.mp4" },
    { "id": "S7",  "start": 115, "end": 130, "type": "mixte",   "voice": "VO-07", "capture": "s07-refus-manuel.mp4" },
    { "id": "S8",  "start": 130, "end": 145, "type": "mixte",   "voice": "VO-08", "capture": "s08-validation-sync.mp4" },
    { "id": "S9",  "start": 145, "end": 162, "type": "motion",  "voice": "VO-09", "theme": "dark" },
    { "id": "S10", "start": 162, "end": 175, "type": "motion",  "voice": "VO-10", "theme": "paper" },
    { "id": "S11", "start": 175, "end": 180, "type": "motion",  "voice": "VO-11", "theme": "dark" }
  ],
  "rules": {
    "onScreenTextOnlyFromSpec": true,
    "noInventedNumbers": true,
    "urgencySymbols": { "high": "▲", "moderate": "◆", "low": "■" },
    "neverShow": ["API keys", "real patient data", "real names"]
  }
}
```

---

## 11. Feuille de route et rôles

### 11.1 Répartition proposée
| Tâche | Qui (proposition) | Dépend de |
|---|---|---|
| Verrouiller script et décisions **À DÉCIDER** | Pilote du film + Lead | — |
| Embarquer la police Inter et l'icône dans l'application | Lead | Décision §2.4 / §2.5 |
| Capturer les écrans (§8) | Un membre avec le téléphone de démonstration | Application stable |
| Illustrations, logo, fil, cadre de téléphone | Personne en charge du design | §2 |
| Animation scène par scène | Pilote + outil de génération | Captures, assets |
| Voix off et mix | Voix choisie + une personne au son | Script verrouillé |
| Relecture de véracité (§9) | Une personne **qui n'a pas écrit** le film | Version complète |
| Export, sous-titres, archivage des sources | Pilote | Tout le reste |

### 11.2 Décisions à prendre (liste unique)
- [ ] Prononciation de « SŪRA » (§5).
- [ ] Logo final et icône d'application (§2.5).
- [ ] Police Inter embarquée dans l'application, oui ou non (§2.4).
- [ ] Voix humaine ou synthétique ; sous-titres anglais (§6).
- [ ] Prénoms, pays et rôles de l'équipe à afficher en S10 (§4).
- [ ] Conclusion sur fond sombre ou clair (S11).
- [ ] Musique retenue et sa licence (§7).
- [ ] Mise à jour du chiffre « 76 tests » le jour J (§5, §9).

### 11.3 Représentation et éthique
- Montrer des agents de santé et des patients africains **avec dignité** : pas de misérabilisme, pas de « sauveur », pas de folklore.
- Aucune personne réelle sans autorisation écrite ; privilégier des illustrations.
- Ne jamais laisser croire que SŪRA remplace un soignant : elle **assiste**.
- Diversité de l'équipe : la valoriser par les rôles (développement, architecture, sécurité, design, présentation), sans en faire un argument de façade.

### 11.4 Critères de réussite du film
- [ ] Dure **3 minutes ou moins** (180 s).
- [ ] Un spectateur non technique comprend le problème, la solution et le principe « l'IA propose, l'agent décide ».
- [ ] On **voit** l'application réelle fonctionner hors ligne puis se synchroniser.
- [ ] Les limites sont dites honnêtement.
- [ ] Table de preuve (§9) entièrement cochée.
- [ ] Sous-titres lisibles, son équilibré, aucune donnée réelle ni secret visible.

---

## 12. Annexe : phrases-clés du film

| Idée | Formulation |
|---|---|
| Principe | « SŪRA propose, l'agent vérifie et valide. » |
| Hors ligne | « Documenter un soin ne devrait pas dépendre du réseau. » |
| Urgence | « Un niveau proposé, avec ses raisons. L'agent décide. » |
| Respect du patient | « Le refus ne bloque pas la prise en charge : il est consigné. » |
| Honnêteté | « C'est un prototype. Les seuils sont des valeurs de démonstration. » |
| Impact | « ODD 3 : bonne santé et bien-être. » |

---

*Document de travail. Toutes les données mentionnées sont fictives. Dernière mise à jour des faits techniques : à vérifier le jour du tournage (nombre de tests, état du mode connecté, version de l'application).*
