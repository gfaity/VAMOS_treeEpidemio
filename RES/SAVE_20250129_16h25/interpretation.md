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

- Le **test utilisé** (**testUsed**) : ici toujours “FisherSim”, c’est-à-dire qu'on a utilisé un test exact de Fisher avec simulation Monte-Carlo (pour réduire la complexité des calculs),
- La **p-value** (**pValue**) : la p-value brute,
- La **taille d'effet** (**effectSize(CramerV_or_phi)**) :  
  - $\phi$ si la table est 2×2 (ce qui n'est pas le cas en pratique dans nos valeurs),  
  - **Cramér’s V** sinon (calculé même si la p-value vient de Fisher, pour estimer la force de l’association),
- La **p-value ajustée** (**pValue_adj**) : la p-value ajustée (méthode Benjamini-Hochberg pour un compromis entre conservation et minimisation des faux-négatifs) pour contrôler l’inflation du risque alpha dans les multiples comparaisons.

### Seuil d’interprétation
- On considère **pValue_adj < 0.05** comme **significatif**.  
- On interprète l’effet size selon ces ordres de grandeur ([interpretation de Cohen](https://peterstatistics.com/CrashCourse/2-SingleVar/Nominal/Nominal-2c-Effect-Size.html)) :  
  - ES ≤ 0.1 = négligeable (*negligible*),  
  - 0.1 < ES ≤ 0.3 = faible (*small*),  
  - 0.3 < ES ≤ 0.5 = modéré (*medium*),  
  - 0.5 < ES ≤ 0.7 = fort (*large*),  
  - 0.7 < ES ≤ 0.9 = très fort (*large*),  
  - ES > 0.9 = extrêmement fort (*large*)  

### Interprétation statistique :

1. **Position ~ Device** :  
   - pValue_adj = 0.00020, **<< 0.05** ⇒ association **hautement significative**.  
   - Effet size = **0.93** ⇒ **extrêmement fort**.  
   - $\rightarrow$ Les études utilisent quasi-exclusivement **certains devices** pour **certaines positions** (ex. Axivity ↔ poignet, Lifecorder/Hookie ↔ hanches, etc.).

2. **Device ~ EpochDuration** (pValue_adj = 0.00020, effet 0.78) :  
   - **Très forte** association : on voit des préférences marquées (Actigraph ↔ 60s, Axivity ↔ 10s, etc.).

3. **EpochDuration ~ BoutDuration** (pValue_adj = 0.00020, effet 0.39) :  
   - Association **significative** (modérée).  
   - Descriptif : “Les durées d’epoch courtes (10s) sont plus souvent associées à des bouts courts/modérés (2–5 min, 10–32 s), tandis que 60s plus fréquemment à 1–10 min.”

4. **DropTime ~ BoutDuration** (pValue_adj = 0.00020, effet 0.55) :  
   - **Significatif** et effet **fort**.  
   - Observation notable : “Lorsqu’un DropTime est Yes, ≈93 % des cas choisissent 10 min” (table) — forte cohérence entre un temps de grâce et un long bout.

5. **Device ~ BoutDuration** (pValue_adj = 0.00814, effet 0.42) :  
   - **Significatif**, effet **modéré**.  
   - Ex. “Lifecorder sur 4–6s combine plutôt 2–5 min ou 10–32 s” ; “Actigraph sur 60s combine souvent 10 min ou 1 min”. 

6. **EpochDuration ~ DropTime** (pValue_adj = 0.00814, effet 0.39) :  
   - **Significatif**, effet **modéré**.  
   - On constate que “Yes” (DropTime) apparaît davantage chez les études en 60s, moins en 10s.

### Non significatifs (après ajustement)

- **Device ~ DropTime** (pValue_adj = 0.0529, effet 0.41) : borderline (p = 0.053 après correction, p = 0.038 avant correction). On peut parler de “tendance” : il y a un **effet modéré**, mais la correction multiple fait repasser la p-value au-dessus de 0.05.  
- **Position ~ BoutDuration** (pValue_adj = 0.0909, effet 0.40) : on aperçoit là aussi une tendance (p = 0.076 avant correction), mais non significative.  
- **Position ~ DropTime** (pValue_adj = 0.536, effet 0.20) : **aucune association** claire (p >> 0.05, effet faible).

**En résumé** : La plupart des p-values < 0.05 indiquent que les variables (Position, Device, EpochDuration, DropTime, BoutDuration) **ne sont pas indépendantes** deux à deux.  
**Exceptions** : “Position ~ DropTime” et “Position ~ BoutDuration” ne sont pas (ou pas clairement) associées.

---

## 2. Tableau descriptif (Descriptive_ByPair.csv)

Ce tableau montre pour chaque paire $(v_1, v_2)$ et chaque couple de niveaux `(level1, level2)` :

- `count` : nombre d’articles correspondants.
- `rowPerc` : % ligne, i.e. “parmi tous les articles où `v1 = level1`, x% ont `v2 = level2`”.
- `colPerc` : % colonne, i.e. “parmi tous les articles où `v2 = level2`, x% ont `v1 = level1`”.
- `totPerc` : % du total (par rapport à l’ensemble de l’étude).

Ce tableau sert à **expliquer** comment s’exprime la dépendance entre les variables (quand elle est significative).

### Exemple d’interprétation :

- **`Position = Thigh`** vs. `Device`:  
  - On voit `Device = GENEActiv` → `count = 2` ; `rowPerc ≈ 66.7%`. Cela veut dire “dans 66.7 % des articles où le capteur est sur la cuisse, on utilise GENEActiv”.  
  - `colPerc = 50 %` indique qu’“environ la moitié des études avec GENEActiv sont positionnées à la cuisse”.  
  - `Device = ActivPAL` → `count = 1`, etc.

- **`Device = Axivity`** vs. `EpochDuration`:  
  - On voit souvent `10s` (12 articles sur 14 Axivity → 85.7 %).  
  - Confirme la forte relation “Axivity <-> 10s” déjà suggérée par la p-value très faible.

- **`DropTime = Yes`** vs. `BoutDuration = 10min`** :  
  - `count = 13`, `rowPerc = 92.86%` → “parmi tous les articles où DropTime = Yes, 92.86 % choisissent un BoutDuration = 10min”.  
  - **Cela explique** pourquoi “DropTime” et “BoutDuration” sont fortement associés (p = 0.0003).  
  - Concrètement, si un auteur choisit “Yes” pour DropTime, il y a de fortes chances qu’il fixe un bout à 10 minutes.

---

## 3. Points de discussion

1. **Position et Device** : Effect size **extrêmement fort** (0.93), p < 0.001.  
   - Cela confirme que les équipes de recherche utilisent de façon préférentielle certains dispositifs à certaines positions (ex. Actigraph à la hanche, Axivity au poignet, etc.).  

2. **Durées** :  
   - **Device ~ EpochDuration** (0.78) : Les équipes utilisent des epochs différents selon le device (ex. Axivity souvent 10s, Actigraph 60s).  
   - **EpochDuration ~ BoutDuration** (0.39) et **DropTime ~ BoutDuration** (0.55) : un epoch plus long (60s) et la présence d’un temps de grâce s’accompagnent souvent d’un bout plus long (10 min).  *Interprétation potentielle : Plus on veut caractériser une activité prolongée, plus on choisit un paramétrage large (60s, 10 min) et un dropTime.*

3. **Associations borderline** :  
   - **Device ~ DropTime** (pValue_adj ≈ 0.053), modéré (0.41) : existe une tendance d’association, mais on ne peut pas l’affirmer au seuil 5 % après correction.  
   - **Position ~ BoutDuration** (pValue_adj ≈ 0.091), (0.40) : tendance non confirmée. *On note une tendance non significative à utiliser des bouts plus longs au niveau de la hanche que du poignet, mais sans franchir le seuil statistique de 5 %.*  

4. **Aucun lien** entre **Position ~ DropTime** (pValue_adj = 0.54, effet 0.20).  
   - Où placer l’accéléromètre ne semble pas influencer la décision de laisser un temps de grâce “Yes” vs “No”.  

5. **Conclusion**  
   - **D’un point de vue méthodologique**, de fortes interdépendances existent dans la littérature : le choix du device détermine souvent la position (et réciproquement), le choix de l’epoch s’accompagne d’un certain bout, etc.  
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

---

Cette méthode combine **approche visuelle** (arbre hiérarchique) et **approche statistique** (test d’indépendance). Elle met en évidence comment les études s’organisent selon des **catégories** potentiellement interdépendantes (Position, Device, etc.) et **quantifie** le degré d’association statistique, tout en offrant un **tableau descriptif** pour comprendre **comment** les modalités se répartissent (nombre et pourcentages).