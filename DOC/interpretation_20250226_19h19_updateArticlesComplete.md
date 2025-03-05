---
title: "Interpretation VAMOS epidemio"
format:
  html:
    self-contained: true
    embed-resources: true
    toc: true
    highlight-style: pygments
---

Ci-dessous vous trouverez une **interprétation globale** des résultats, en se basant à la fois sur le fichier `Associations_Epi.csv` (tests d’association par p-value) et le fichier `Descriptive_ByPair.csv` (statistiques descriptives détaillées).

---

## 1. Tableau d’associations (Associations_Epi.csv)

Le tableau **Associations_Epi.csv** liste, pour chaque paire de variables :

- **testUsed** : ici toujours "FisherSim", c’est-à-dire un test exact de Fisher avec **simulation Monte-Carlo**,  
- **pValue** : la p-value brute (non ajustée),  
- **effectSize(CramerV_or_phi)** :  
  - $\phi$ si la table était 2×2 (non le cas ici),  
  - **Cramér’s V** sinon (même si la p-value vient de Fisher, on l’emploie pour évaluer la force de l’association),  
- **pValue_adj** : la p-value **après correction** (méthode **Benjamini-Hochberg**) pour limiter l’inflation du risque alpha en comparaisons multiples.

### Seuil d’interprétation
- On considère **pValue_adj < 0.05** comme **significatif**.  
- On interprète l’effect size selon les seuils suivants ([interprétation de Cohen](https://peterstatistics.com/CrashCourse/2-SingleVar/Nominal/Nominal-2c-Effect-Size.html)) :  
  - ES ≤ 0.1 = négligeable (*negligible*),  
  - 0.1 < ES ≤ 0.3 = faible (*small*),  
  - 0.3 < ES ≤ 0.5 = modéré (*medium*),  
  - 0.5 < ES ≤ 0.7 = fort (*large*),  
  - 0.7 < ES ≤ 0.9 = très fort (*very large*),  
  - ES > 0.9 = extrêmement fort (*extremely large*)  

### Interprétation statistique :

1. **Position ~ Device**  
   - **pValue_adj = 0.0002**, effet = **0.93** → *significatif*, effet **extrêmement fort**.  
   - Les études utilisent quasi-exclusivement certains *devices* pour certaines *positions* (p. ex. Axivity ↔ poignet, Lifecorder/Hookie ↔ hanche, etc.).

2. **Position ~ EpochDuration**  
   - **pValue_adj = 0.0002**, effet = **0.50** → *significatif*, effet **modéré**.  
   - Indique que la position du capteur et la durée d’epoch sont modérément liées (ex. poignet plus souvent en 10s, hanche en 60s, etc.).

3. **Position ~ DropTime**  
   - **pValue_adj = 0.161**, effet = 0.27 → *non significatif* (effet faible).  
   - Où placer l’accéléromètre ne semble pas influencer la décision d’utiliser ou non un temps de grâce (Yes/No).

4. **Position ~ BoutDuration**  
   - **pValue_adj = 0.109**, effet = 0.33 → *non significatif* (effet modéré).  
   - Une tendance émerge mais on reste bien au-dessus de 0.05.

5. **EpochDuration ~ DropTime**  
   - **pValue_adj = 0.026**, effet = **0.35** → *significatif*, effet **modéré**.  
   - “Yes” pour DropTime apparaît plus souvent chez les études en 60s que 10s.

6. **EpochDuration ~ BoutDuration**  
   - **pValue_adj = 0.0002**, effet = **0.48** → *significatif*, effet **modéré**.  
   - Les durées d’epoch courtes (10s, 4–6s) s’associent fréquemment à des bouts plus courts (2–5min, 10–32s), tandis que 60s est souvent associé à 1 ou 10 min.

7. **EpochDuration ~ Device**  
   - **pValue_adj = 0.0002**, effet = **0.73** → *significatif*, effet **très fort**.  
   - Des préférences marquées (p. ex. Actigraph ↔ 60s, Axivity ↔ 10s).

8. **DropTime ~ BoutDuration**  
   - **pValue_adj = 0.0002**, effet = **0.53** → *significatif*, effet **fort**.  
   - Lorsqu’un DropTime est “Yes”, ~94 % des cas adoptent un bout ≥ 10min (cohérence temporelle).

9. **DropTime ~ Device**  
   - **pValue_adj = 0.027**, effet = **0.42** → *significatif*, effet **modéré**.  
   - Certains dispositifs ont plus souvent un temps de grâce.

10. **BoutDuration ~ Device**  
   - **pValue_adj = 0.028**, effet = **0.43** → *significatif*, effet **modéré**.  
   - Par ex., Lifecorder ou Axivity sur des bouts plutôt courts, Actigraph souvent couplé à 10min ou 1min.

La plupart des associations sont donc confirmées **significatives**. Seuls “Position ~ DropTime” et “Position ~ BoutDuration” n’atteignent pas p<0.05.  

#### Nouveau facteur : `StartYear`
  
11. **Position ~ StartYear**  
   - **pValue_adj = 0.0002**, effet = **0.50** → *significatif*, effet **fort**.  
   - Certain positionnements sont associés à certaines périodes de test.  
   - Par exemple, sur la période 2000-2004, ~100 % des études utilisent la position hanche. La position hanche subsiste ensuite sur toutes les périodes suivantes.  
   - La position poignet apparaît dans la période 2005-2009 mais se développe vraiment dans la période 2010-2014.  

12. **EpochDuration ~ StartYear**  
   - **pValue_adj = 0.0002**, effet = **0.43** → *significatif*, effet **modéré**.  
   - Les années plus récentes montrent davantage d’epochs courts (30s dès 2005-2009, puis 10s dès 2010-2014), alors qu’en 2000–2004, c’était uniquement sur des epochs de 60s.  

13. **Device ~ StartYear**  
   - **pValue_adj = 0.0002**, effet = **0.80** → *significatif*, effet **très fort**.  
   - Les anciens articles (ex. 2000–2004) utilisent exclusivement Actigraph ou Actical ; plus récemment, on voit d’autres dispositifs apparaître (Actiheart, Axivity, ActivPAL, SenseWear à partir de 2005-2009 ; GENEActiv, Hookie à partir de 2010-2014 ; Activestyle à partir de 2015-2019).  

14. **DropTime ~ StartYear**  
   - **pValue_adj = 0.003**, effet = **0.38** → *significatif*, effet **modéré**.  
   - Certaines périodes (2000-2004 et 2015-2019) ont davantage d'études avec période de grâce (33%) que les autres périodes.  

15. **BoutDuration ~ StartYear**  
   - **pValue_adj = 0.004**, effet = **0.37** → *significatif*, effet **modéré**.  
   - Analyse sur bouts inférieurs à la minute rendu possible à partir de 2005 car les durées d'epoch se diversifient (et certaines passent en dessous de la minute).  

En résumé, **StartYear** est associé à tous les facteurs étudiés (**Position**, **EpochDuration**, **Device**, **DropTime** et **BoutDuration**). On peut l'intérpréter comme une influence de la date de début des mesures sur les dispositifs utilisés et donc sur la position mais également sur la durée de l'epoch et du bout (et donc sur l'inclusion d'un dropTime) avec une durée et de bout d'epoch qui diminue et se diversifie au fur et à mesure du temps.  

On notera que certaines pValue_adj sont similaires malgré une taille d'effet parfois différente. C'est normal et provient de la correction de B-H.  

---

## 2. Tableau descriptif (Descriptive_ByPair.csv)

Ce tableau montre pour chaque paire $(v_1, v_2)$ et chaque couple de niveaux `(level1, level2)` :

- `count` : nombre d’articles correspondants.
- `rowPerc` : % ligne, i.e. “parmi tous les articles où `v1 = level1`, x% ont `v2 = level2`”.
- `colPerc` : % colonne, i.e. “parmi tous les articles où `v2 = level2`, x% ont `v1 = level1`”.
- `totPerc` : % du total (par rapport à l’ensemble de l’étude).

Ce tableau **illustre concrètement** les relations mises en évidence par les tests. Par exemple :

- **Position = Thigh** vs **Device = GENEActiv** : `count = 2`, `rowPerc ~ 33 %` → dans 33 % des articles où le capteur est sur la cuisse, on trouve GENEActiv.  
- **Device = Axivity** vs **EpochDuration = 10s** : `count = 11` sur 13 Axivity → ~85 %. Confirme la forte liaison Axivity ↔ 10s.  
- **DropTime = Yes** et **BoutDuration = 10min** : `count = 15`, `rowPerc = 94 %` → confirme l’association forte.

---

## 3. Points de discussion

1. **Position & Device**  
   - Effet “extrêmement fort” (0.93).  
   - Les équipes de recherche privilégient tel dispositif à telle position. P. ex., Actigraph = hanche/taille, Axivity = poignet.

2. **Durées et choix de DropTime**  
   - **EpochDuration ~ BoutDuration** (modéré = 0.48), **DropTime ~ BoutDuration** (fort = 0.53) et **EpochDuration ~ DropTime** (modéré = 0.35).  
   - Paramétrages plus longs (60s, 10min, DropTime = Yes) s’observent ensemble pour caractériser des activités prolongées.

3. **StartYear** : évolution temporelle  
   - **StartYear influence tous les paramètres étudiés** (**Position, EpochDuration, Device, DropTime, BoutDuration**).  
   - **Device ~ StartYear** (0.80), **Position ~ StartYear** (0.50) et **EpochDuration ~ StartYear** (0.43) indiquent une **transition** :  
     - Dans les années 2000–2004, les analyses se faisaient exclusivement à la hanche (Hip/Waist) avec les devices Actigraph/Actical et avec une durée d'epoch de 60s.  
     - Avec le temps, de la diversité est apparue avec des durées d'epochs plus courtes (30s dès 2005-2009, puis 10s ou moins dès 2010-2014).  
     - Dès la période 2005-2009, on observe une diversification massive des devices utilisés en combinaison avec de nouvelles positions (Wrist avec Axivity, Thigh avec ActivPAL, Upperarm avec SenseWear, Chest avec Actiheart).  
     - Au fil du temps les études sur l'Actical disparaissent (dernière en 2005-2009) mais celles sur l'Actigraph continuent (au moins jusqu'à la période 2010-2014), toujours à la hanche.  

4. **Non significatif**  
   - **Position ~ BoutDuration** (p-adj=0.109, effet 0.33) → malgré un effet “modéré”, la p-value reste > 0.05. On ne conclut pas à une dépendance.
   - **Position ~ DropTime**  (p-adj=0.161, effet 0.27 = faible → l’emplacement du capteur ne semble pas influencer la présence d’un temps de grâce “Yes”/“No”.

5. **Conclusion**  
   - **D’un point de vue méthodologique**, de fortes interdépendances existent dans la littérature : le choix du device détermine souvent la position (et réciproquement), le choix de l’epoch s’accompagne d’un certain bout, etc.  
   - On notera un effet de **l'historique de la discipline**, l'évolution technologique permettant de diminuer les durées d'epoch pour des analyses plus fines et de varier les positions de port avec l'apparition de nouveaux dispositifs.  
   - Ces **corrélations** peuvent influer sur la **comparabilité** des études : par exemple, on ne compare pas aisément un set “Axivity + 10s + no DropTime” à un set “Actigraph + 60s + yes DropTime”.  
   - Les **chercheurs** doivent être conscients de ces “packages méthodologiques” implicitement standardisés dans la communauté, et peut-être **mieux harmoniser** les protocoles pour faciliter la comparaison inter-études.

---

## Méthodes

---

### 1. Constitution des données
Nous avons recensé un ensemble de méthodes (n = 84) utilisées dans des articles traitant de la mesure de l’activité physique à l’aide d’accéléromètres. Pour chaque article, nous avons relevé différentes **variables catégorielles** décrivant la méthode utilisée :

- **Position** : la localisation du capteur (poignet, hanche, cuisse, etc.).
- **Device** : le nom du dispositif (Actigraph, Axivity, etc.).
- **EpochDuration** : la durée d’enregistrement retenue (ex. 10s, 60s).
- **DropTime** : l’éventuelle présence d’un temps de grâce (“Yes”/“No”), permettant de gérer les transitions courtes.
- **BoutDuration** : la durée minimale d’activité (ex. 1 min, 10 min) pour considérer un “bout” d’activité.
- **StartYear** : année de début de la collecte de données (regroupé par périodes: 2000-2004, 2005-2009, 2010-2014, 2015-2019).

**Regroupements de modalités**  
Lorsque plusieurs modalités étaient très proches (p. ex. “Hip” et “Waist”), nous les avons fusionnées (“Hip / Waist”) afin d’augmenter les effectifs par cellule et faciliter l’analyse. De même, certaines durées très spécifiques ont été rassemblées dans des classes plus larges (“10–32s”, “2–5 min”, etc.). Ces regroupements assurent une meilleure robustesse des tests statistiques, en limitant les cellules à très faible effectif.

### 2. Construction de l’arbre de classification
Pour **visualiser** la répartition des études selon ces variables, nous avons construit un **arbre hiérarchique** :

1. On a **défini un ordre** de variables (par exemple : *Position* → *Device* → *EpochDuration* → *DropTime* → *BoutDuration* → *StudyID*).  
2. On a converti cette structure en **format Newick**, puis lu la chaîne Newick via `ape::read.tree()`.  
3. L’affichage s’est fait via le package **ggtree**, offrant une représentation arborescente où chaque **nœud** interne correspond à une modalité (ex. “Wrist”), et chaque **feuille** à un article.

**Choix esthétiques** :  
- Les branches de l’arbre sont en layout “rectangular”.  
- Les **labels internes** sont colorés en fonction des niveaux pour faciliter la lecture (ex. Axivity en bleu clair, Actigraph en gris).  

### 3. Analyse statistique des associations
Pour **vérifier** si deux variables (ex. “Device” et “Position”) étaient **indépendantes** ou non, nous avons procédé comme suit :

1. **Table de contingence** : pour chaque paire $(v_1, v_2)$, nous avons construit la table $\text{table}(v_1, v_2)$ recensant le nombre d’articles dans chaque combinaison de modalités.  
2. **Test d’association** :  
   - Nous avons d’abord estimé la **proportion de cellules** dont l’**effectif attendu** (sous l’hypothèse d’indépendance) était **< 5**.  
   - Si la table était un **2×2** (ex. DropTime Yes/No × Bout court/long), nous avons appliqué un **test exact de Fisher** (souvent plus exact que le Chi-2 pour les petites tables).  
   - Si la table dépassait 2×2, mais que plus de 20 % des effectifs attendus étaient < 5, nous avons recouru au **test exact de Fisher par simulation** (argument `simulate.p.value=TRUE` dans `fisher.test()`).  
   - Sinon, nous avons utilisé le **test du Chi-2**.
   - *En pratique, seul le test exact de Fisher (avec simulation Monte-Carlo) a été utilisé ici (puisque aucun 2x2 et plus de 20 % des effectifs attendus étaient < 5).*  
3. **Mesure de l’association: taille de l’effet** :  
   - Nous avons calculé **Cramer’s V** pour les tables de contingence dépassant 2×2, et **$\phi$** pour les tables 2×2. Pour cela, nous avons systématiquement estimé la statistique $\chi^2$ via la fonction `chisq.test()`. Même lorsque la p-value provenait d’un test de Fisher exact (tables à faibles effectifs), la **statistique $\chi^2$** a été utilisée uniquement pour le calcul de la taille d’effet (phénomène parfois qualifié d’“approximation”). Les valeurs de Cramer’s V ou de $\phi$ indiquent l’intensité de l’association (0 = aucune; 1 = maximale).  
   - *En pratique, seul le Cramer’s V fut utilisé puisque toujours supérieur à 2x2.*
4. **Seuil de significativité** :  
   - Nous avons retenu un seuil de p-value à 0,05 pour considérer une association significative.  
5. **Comparaisons multiples** :  
   - Étant donné que nous testons plusieurs paires de variables (Position, Device, etc.), nous avons appliqué une **correction de Benjamini-Hochberg** aux p-values pour contrôler la probabilité d’erreur de type I globale. Les p-values ajustées (\(p_{\text{adj}}\)) sont rapportées dans le tableau final, et nous considérons un seuil de 0,05 sur la p-value ajustée pour définir la significativité.  

Le résultat final est un **tableau** listant, pour chaque paire de variables, la **p-value**, le **test utilisé** (Fisher vs. Chi-2) et, le cas échéant, le **Cramer’s V**.

### 4. Descriptifs par contingence (statistiques “post-hoc”)
Pour **interpréter** les associations, un simple test (p < 0.05) ne suffit pas. Un **deuxième tableau “descriptif”** a donc été produit indiquant, pour chaque paire $(v_1, v_2)$ et chaque couple de modalités $(\text{level1}, \text{level2})$ :

- Le **nombre brut** (count) d’articles,
- Les **pourcentages** en ligne (row %), en colonne (col %) et dans le total (tot %).

Par exemple, si “Device = Axivity” et “EpochDuration = 10s” représentent 12 articles, cela pourra correspondre à 85 % des Axivity (row%) et 70 % de tous les “10s” (col%), etc. Ces pourcentages **explicitent** la répartition des études et clarifient pourquoi certaines associations ressortent fortement significatives.

### 5. Export et rapport
- Nous avons exporté la figure de l’arbre en haute résolution (“Arbre_Descriptif_Publication.png”).  
- Nous avons généré deux fichiers CSV :
  1. **“Associations_Epi.csv”** : les p-values des tests d’association pour chaque paire.  
  2. **“Descriptive_ByPair.csv”** : la répartition détaillée (counts, pourcentages) par couple de modalités, pour discussion des résultats.

Ces **deux** sorties permettent à la fois une **vue d’ensemble** des dépendances (test statistique) et une **analyse fine** (pourcentages) justifiant les interprétations dans la discussion.

### 6. Sankey Diagram : Visualisation des relations entre variables
Afin de **visualiser les interactions** entre les différentes variables catégorielles (Position, Device, Epoch Duration, Drop Time, Bout Duration), nous avons utilisé un **diagramme de Sankey**. Ce type de diagramme permet de représenter les **flux de données** entre plusieurs variables et d’identifier les tendances majeures dans l’utilisation des paramètres d’accélérométrie.

1. **Données utilisées**  
   - Le diagramme Sankey repose sur les mêmes données catégorielles que l’analyse statistique (`Position`, `Device`, `EpochDuration`, `DropTime`, `BoutDuration`).  
   - Chaque étude constitue une **observation unique** et ses paramètres définissent un **chemin dans le Sankey**, reliant une catégorie à une autre.  

2. **Agrégation des fréquences**  
   - Pour chaque combinaison unique de niveaux (`Position -> Device -> Epoch Duration -> Drop Time -> Bout Duration`), nous avons compté le **nombre d’articles** ayant cette configuration.  
   - Une table récapitulative a été construite en comptant ces occurrences (`Freq` = nombre d’articles partageant la même séquence).  
   
3. **Construction du Sankey**  
   - Nous avons utilisé la bibliothèque `ggalluvial` dans R, qui permet de générer des **diagrams de Sankey basés sur ggplot2**.  
   - Les **flux entre variables** sont représentés par `geom_alluvium()`, et les **catégories** par `geom_stratum()`.  
   - Chaque flux est **colorié** en fonction du **premier facteur** de la séquence (par ex., `Device` dans un Sankey `Device → Position → Epoch Duration`, ou `Epoch Duration` dans un Sankey `Epoch Duration → Drop Time → Bout Duration`).

4. **Mise en forme et lisibilité**  
   - Les **noms des variables** ont été clarifiés (`EpochDuration → Epoch Duration`, etc.).  
   - L’**ordre des niveaux a été inversé** sur l’axe vertical pour correspondre à l’organisation du tableau descriptif.  
   - Un **fond blanc a été ajouté** aux étiquettes (`geom_label()`) pour améliorer la lisibilité des catégories.  
   - Nous avons choisi la palette **Accent** de `RColorBrewer`, avec l’ajout manuel d’un **vert foncé** pour éviter les couleurs transparentes lorsque le nombre de niveaux dépasse la palette par défaut.

**Interprétation et intérêt du Sankey**
- Contrairement aux tests d’association, qui mesurent la **force statistique des relations** entre variables, le Sankey **représente directement** les flux les plus fréquents dans les études.  
- Il permet de **visualiser des tendances** sans avoir à interpréter des coefficients de corrélation :  
  - On observe par exemple **qu’un même Device est souvent utilisé avec une même Position et une même durée d’epoch**.  
  - On note que **certaines combinaisons de paramètres apparaissent de manière privilégiée** (ex. 60s associé plus souvent à 10min de bout).  
- Cela complète l’approche analytique en offrant une **perspective descriptive intuitive**.

---

Cette méthode combine **approche visuelle** (arbre hiérarchique) et **approche statistique** (test d’indépendance). Elle met en évidence comment les études s’organisent selon des **catégories** potentiellement interdépendantes (Position, Device, etc.) et **quantifie** le degré d’association statistique, tout en offrant un **tableau descriptif** pour comprendre **comment** les modalités se répartissent (nombre et pourcentages).