# Rapport méthodologique des indicateurs COSO

## 1. Objet et sources

Ce rapport décrit les calculs du pipeline `01` à `04`. Il sert à lire le classeur des indicateurs et le PDF de synthèse, puis à reproduire les résultats à partir du DTA. Les sources sont :

- `base/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta` : réponses téléphoniques ;
- `base/QUESTIONNAIRE_VF_SANS_DOUBLON_VF.xlsx`, feuilles `Codebook` et `Valeurs` : dictionnaire des variables et codes ;
- `docs/Original Questionnaire_COSO_V5.html` : libellés des questions et sauts ;
- `docs/Indicteurs_COSO (1).xlsx` : liste des 21 indicateurs demandés.

Le DTA est une base d'**entretiens avec des candidats**. Il ne couvre pas exhaustivement les personnes enrôlées, sélectionnées ou bénéficiaires. Les mesures tirées du DTA sont descriptives des répondants. Elles ne prouvent ni une participation au projet ni un effet causal de COSO.

Le classeur `Indicteurs_COSO_Analysés.xlsx` a été examiné mais ses correspondances ne sont pas utilisées comme codebook : il attribue notamment la formation à `M1`, alors que `M1` mesure l'autonomie financière et que la formation récente est `O3`. Il présente `M4` comme une durée de formation, alors que `M4` est une projection d'autonomie ; il cite aussi des variables absentes du DTA, comme `A6/A7`, `H6` ou `EN_EMP`.

## 2. Population et apurement : étape `01`

La règle de population est :

```text
classe_completude ∈ {1-COMPLET, 2-QUASI_COMPLET}
ET consentement = 1
```

La complétude fixe le périmètre demandé. Le consentement positif est une condition supplémentaire explicite : dans la source actuelle, une observation quasi complète a `consentement = 0` et n'entre pas dans les calculs. Un identifiant d'entretien absent ou dupliqué arrête le pipeline ; aucune déduplication arbitraire n'est effectuée.

L'étape `01_apurement.py` produit **`base_apuree.csv`**. Elle conserve les réponses nécessaires aux indicateurs et leur identifiant technique `interview__key`, mais exclut les noms, téléphones et autres coordonnées. Le DTA original reste inchangé. Les champs ajoutés sont :

| Champ | Règle |
| --- | --- |
| `district`, `region` | Décodage de `B1` et `B2` avec les modalités du questionnaire ; vérification que la région appartient au district. |
| `sexe`, `milieu` | Décodage de `C1` et `B5`. Rural n'est pas synonyme d'enclavé. |
| `age_valide`, `age_groupe` | Âge de 15 à 120 ans pour le contrôle de vraisemblance ; groupes 15–24, 25–34, 35 ans ou plus. Le seuil n'est pas une condition d'éligibilité au projet. Les âges invalides sont conservés comme tels dans la colonne brute et regroupés séparément. |
| `emploi_calcule` | 1 si `E1 = 1` ou `E2 = 1` ou (`E3 = 1` et `E3A = 1`) ; 0 sinon lorsque `E1` est valide. Comparaison à `EMPLOYE`. |
| `heures_principales`, `heures_secondaires` | `G3` et `G6` valides dans 0–168 heures ; `G3 = 998` est une non-réponse. `G6` n'est utilisé que si `G5 = 1`. |
| `montant_H3`, `gain_net_H5` | `H3` : salaire de dernière paie uniquement pour `F1 = 1`, hors refus `99999`. `H5` : gain net mensuel strictement positif pour `F1 ∈ {2,3,4}` et emploi confirmé, hors refus `999999`. Les valeurs brutes restent visibles. |
| `impact_choc_N3`, `retablissement_N5` | Réponses utilisées seulement si `N1 = 1` (choc subi). Une réponse hors parcours est conservée en brut et signalée. |
| `dispensateur_O5` | Utilisé seulement si `O3 = 1` (formation suivie). |
| `participations_Q2` | Numériques conservés ; `NON/AUCUN/AUNCUN = 0`, `UNE FOIS = 1`, `2 FOIS = 2`. Les formulations ambiguës comme `OUI` ou `PLUSIEURS FOIS` ne sont pas converties en nombre. |
| `anomalies`, `n_anomalies` | Codes des contrôles par entretien et nombre de signalements. Aucun signalement n'entraîne une exclusion automatique de la personne. |

Les contrôles couvrent les âges invraisemblables, la géographie, les contradictions d'emploi, les réponses hors parcours (`F1/F2`, `H2/H5`, `J0`, `G6`, `G7A`, `N3–N5`, `O5/O6`), les heures hors plage, les `H5 = 0` et les réponses `Q2` non quantifiables. Une anomalie est un **point à revoir** : elle peut être une saisie erronée, un problème de routage ou une réponse valable nécessitant une vérification. Les colonnes dérivées portent la règle de calcul ; les réponses originales restent visibles dans la base apurée.

### Résultat de l'audit du DTA

Le DTA comporte **962 entretiens** : 613 complets, 51 quasi complets, 9 moyens, 255 incomplets et 34 vides. Le filtre de complétude retient 664 entretiens ; le refus de consentement en retire 1. La base apurée contient donc **663 candidats**. Aucun autre entretien n'est supprimé. L'audit produit **71 signalements sur 61 entretiens** ; plusieurs types peuvent concerner une même personne.

| Point contrôlé | Résultat | Décision |
| --- | ---: | --- |
| Âge hors 15–120 ans | 7 | Conserver l'entretien ; exclure l'âge des groupes d'âge valides. Deux âges ont la forme d'années de naissance (1993, 1994), trois valent 9999, un vaut 9 et un vaut 0. |
| Âge comparé à l'année de naissance et d'entretien | 510 comparables, 0 écart de plus d'un an | Vérification de cohérence, sans remplacer l'âge déclaré. |
| Géographie district/région invalide | 0 | Les dix régions observées correspondent aux quatre districts. |
| Emploi calculé différent de `EMPLOYE` | 0 | Règle du questionnaire confirmée sur les 663 entretiens. |
| Réponses hors parcours : `F1/F2`, `H2/H5`, `J0`, `G6`, `G7A`, choc, formation | 27 signalements | Ignorer la réponse hors parcours dans les mesures concernées ; conserver le brut et le drapeau pour vérification. |
| `H5 = 0` | 4 | Exclure du montant exact : le questionnaire exige une valeur strictement positive. |
| `Q2` non quantifiable | 33 | Ne pas attribuer de fréquence à un texte ambigu. |
| Heures de travail hors 0–168 hors code spécial | 0 | `G3 = 998` reste une non-réponse, pas 998 heures. |

Le total des signalements porte sur des **contrôles**, pas sur des personnes distinctes. Les codes spéciaux de refus ou « ne sait pas » ne sont pas des anomalies en eux-mêmes. Les questions conditionnelles attendues (`F1/F2` en emploi, `J0` hors emploi, `N5` après choc et `O5` après formation) n'ont pas de réponse manquante dans les populations concernées.

## 3. Calculs : étape `02`

L'étape `02_indicateurs.py` lit **uniquement `base_apuree.csv` pour calculer les valeurs**. Pour chaque proportion :

```text
Part (%) = 100 × nombre de réponses dans la modalité / nombre de réponses valides
```

Le dénominateur est calculé dans la population à laquelle la question s'applique. Par exemple, `F1` ne concerne que les personnes en emploi, et `N5` ne concerne que celles ayant subi un choc. Les réponses sautées, les codes de refus et les codes « ne sait pas » ne sont pas transformés en « non ». Le classeur affiche `effectif`, `dénominateur` et `sans réponse` pour chaque résultat. Les médianes n'ont pas de numérateur ; leur dénominateur est le nombre de valeurs valides.

Les calculs sont répétés pour l'ensemble, **4 districts, 10 régions, le sexe, quatre groupes d'âge dont les âges invalides, le milieu urbain/rural et les croisements région × sexe observés**. Les groupes de moins de 30 réponses valides sont signalés. Les résultats de sous-groupes utilisent les réponses valides du sous-groupe, pas le dénominateur national.

### Définition par indicateur

| Code | Calcul fourni ou source nécessaire | Statut |
| --- | --- | --- |
| **1.1** Jeunes enrôlés | Nombre de personnes distinctes avec statut « enrôlé » dans le registre d'enrôlement à une date d'arrêté. | Indisponible : registre absent. |
| **1.2** Sélectionnés ayant démarré | Personnes distinctes sélectionnées avec début effectif et vérifié de formation. `O3` est une formation générale récente, sans preuve du lien au projet. | Indisponible : registres de sélection et formation absents. |
| **1.3** Part des femmes sélectionnées | Femmes sélectionnées / sélectionnés de sexe connu. `C1` mesure le sexe des répondants, pas le statut de sélection. | Indisponible : statut de sélection absent. |
| **1.4** Part des zones enclavées | Sélectionnés résidant dans une localité officiellement classée enclavée / sélectionnés classables. `B5 = rural` n'est pas une mesure d'enclavement. | Indisponible : statut de sélection et référentiel absents. |
| **1.5** Formation achevée | Personnes distinctes ayant satisfait le critère officiel d'achèvement. | Indisponible : suivi de formation absent. |
| **1.6** Taux d'achèvement | Formations achevées / formations démarrées dans la même cohorte dont la fin prévue est passée. | Indisponible : suivi de formation absent. |
| **1.7** Kits remis | Nombre de kits remis sur justificatif ; distinguer kits et bénéficiaires distincts. | Indisponible : registre de remise absent. |
| **2.1** MAF mobilisés | Maîtres artisans formateurs distincts ayant assuré une séance vérifiée. | Indisponible : registre MAF absent. |
| **2.2** Chambre des métiers | Bénéficiaires distincts avec preuve d'enregistrement. `H4` mesure un enregistrement d'activité général. | Indisponible : preuve spécifique absente. |
| **2.3** AVEC | Bénéficiaires avec adhésion effective et datée. `L5/L7` indiquent un lien financier possible, pas une adhésion. | Indisponible : registre AVEC absent. |
| **3.1** Statut d'activité | `emploi_calcule = 1` ; sinon `J0 = 1` : sans emploi en recherche ; `J0 = 2` : sans emploi sans recherche. Part de chaque catégorie parmi les statuts déterminés. La disponibilité des chercheurs n'est pas demandée. | Partiel : aucun taux de chômage normatif. |
| **3.2** Type et secteur | Distributions de `F1` et `F2` parmi les personnes en emploi avec réponse valide. | Calculé. |
| **3.3** Durée du travail | Médiane de `heures_principales` parmi les personnes en emploi ; part déclarant une autre activité (`G5 = 1`). Les heures secondaires valides restent disponibles dans la base apurée. | Calculé pour ces mesures. |
| **3.4** Revenus | Médiane du salaire exact `H3` parmi les salariés (`F1 = 1`), puis parmi les salariés payés mensuellement (`H2 = 4`) ; médiane du gain net mensuel exact et positif `H5` parmi les employeurs, indépendants et coopératives (`F1 ∈ {2,3,4}`). Populations séparées. Aucun chiffre d'affaires brut n'est mesuré. Les tranches `H3A/H5A` ne sont pas imputées par leur centre. | Partiel. |
| **3.5** Recherche et contraintes | Part des personnes en emploi cherchant autre chose (`I1 = 1`) ; distributions des motifs `I2` et `J0A` dans leurs populations respectives. | Calculé pour les réponses disponibles. |
| **3.6** Formation ou AGR | Part avec formation ou apprentissage au cours des 12 derniers mois (`O3 = 1`) ; part ayant déjà créé une activité (`K1 = 1`). Le questionnaire ne permet pas d'attribuer ces réponses à COSO. | Partiel. |
| **3.7** Chômage / sous-emploi | Part des personnes en emploi souhaitant plus d'heures (`G7 = 1`). Aucun taux normatif n'est publié : disponibilité des chercheurs absente, seuil d'heures de sous-emploi non fixé. | Partiel. |
| **3.8** Résilience | Part ayant subi un choc (`N1 = 1`), médiane de la capacité déclarée (`N7`, 1–10), distribution de la capacité de mobiliser 250 000 FCFA (`N6`) et du délai de rétablissement (`N5`) parmi les ménages touchés. Aucun score composite arbitraire. | Partiel. |
| **3.9** Statut socio-économique perçu | Distributions de l'autonomie actuelle (`M1`), de la contribution économique perçue (`M3`) et de l'autonomie anticipée (`M4`). Aucun score unique. | Calculé par dimension. |
| **4.1** Exclusion / perte d'espoir | Les questions disponibles ne mesurent pas directement ces deux concepts. | Indisponible. |
| **4.2** Cohésion sociale | Appartenance associative (`Q1`), participation quantifiable au cours des 30 derniers jours (`Q2`), confiance générale (`Q3`) et part répondant 3 ou 4 sur `Q4–Q10` après exclusion de `9 = ne sait pas`. Le 3 signifie « partiellement confiance » : le libellé est donc « confiance partielle ou forte ». Aucun indice global. | Partiel. |

## 4. Sorties : étapes `03` et `04`

`03_excel.mjs` produit `indicateurs_COSO.xlsx` avec quatre feuilles :

1. **Synthèse** : principales mesures de l'ensemble ;
2. **Territoires** : comparaison courte des districts et régions ;
3. **Résultats** : toutes les mesures et modalités, avec les désagrégations filtrables, effectifs et dénominateurs ;
4. **Méthode** : statut des 21 indicateurs et décompte des contrôles d'apurement.

`04_rapport.py` génère le LaTeX du PDF de synthèse à partir du **même calcul intermédiaire** que l'Excel. Le PDF présente la population, les mesures principales, les quatre districts, les dix régions et les limites. Le LaTeX intermédiaire n'est pas conservé parmi les livrables finaux. Aucune cellule « indisponible » n'est publiée comme zéro.

## 5. Lecture approfondie des résultats

Parmi les 21 indicateurs du fichier de cadrage, **4 sont calculés sur les dimensions mesurées**, **6 sont partiels** et **11 restent indisponibles**. Les indisponibilités correspondent surtout aux activités du projet qui demandent ses registres administratifs. Le classeur n'attribue aucun résultat du questionnaire à COSO sans lien individuel vérifié.

### Résultats d'ensemble et dénominateurs

| Mesure descriptive | Calcul | Résultat | Lecture |
| --- | ---: | ---: | --- |
| En emploi | 600 / 663 | 90,5 % | Statut selon `E1/E2/E3/E3A` ; la base interroge des candidats, sans plan de sondage représentatif fourni. |
| Sans emploi et en recherche | 23 / 663 | 3,5 % | Ce n'est pas un taux de chômage : la disponibilité n'est pas mesurée. |
| Souhaitant plus d'heures, parmi les personnes en emploi | 422 / 600 | 70,3 % | Une composante de sous-emploi, sans seuil horaire ni disponibilité. |
| Heures de l'activité principale | 573 valeurs exactes sur 600 personnes en emploi | médiane 45 h/semaine | 27 réponses `998 = ne sait pas` exclues. |
| Formation ou apprentissage durant les 12 derniers mois | 135 / 663 | 20,4 % | Aucune attribution possible à une formation COSO. |
| Ménage ayant subi un choc | 271 / 663 | 40,9 % | Déclaration au questionnaire. |
| Autonomie économique complète actuelle | 229 / 663 | 34,5 % | Modalité `M1 = 3`, pas un indice synthétique. |
| Membre d'une association | 448 / 663 | 67,6 % | Modalité `Q1 = 1`. |
| Participation communautaire au moins une fois en 30 jours | 378 / 612 | 61,8 % | 18 réponses absentes et 33 textes non quantifiables exclus. |

La complétude de l'entretien n'implique pas que chaque question ait une valeur exploitable. Pour `H3`, 25 des 30 salariés ont un montant exact : la médiane de la dernière paie est **50 000 FCFA**, mais les fréquences de paie diffèrent. Chez les 19 salariés payés mensuellement, 17 montants exacts donnent aussi **50 000 FCFA/mois** ; cet effectif est faible. Pour `H5`, 318 des 447 personnes éligibles ont un montant exact strictement positif : **38 500 FCFA/mois** de gain net médian. Les 129 autres comprennent 126 refus et 3 valeurs nulles. Les deux médianes portent sur des activités et populations distinctes ; elles ne doivent pas être fusionnées, annualisées ou interprétées comme chiffre d'affaires.

### Désagrégations utiles

Les quatre districts et les dix régions figurent dans l'onglet `Territoires` ; l'onglet `Résultats` fournit aussi le sexe, l'âge, le milieu et les croisements région × sexe, avec les dénominateurs exacts. Les effectifs territoriaux sont très inégaux : de **14 au Bafing** à **166 au Gontougo**. Les proportions de petites régions, dont Bafing (14) et Bagoué (18), peuvent varier fortement avec quelques réponses.

Deux contrastes descriptifs méritent vérification sur le terrain. Dans le district des Savanes, le choc est déclaré par **34/140 (24,3 %) au Poro** et **57/103 (55,3 %) au Tchologo**. L'autonomie complète est déclarée par **40/227 femmes (17,6 %)** et **189/436 hommes (43,4 %)**. Ces différences sont brutes : la composition des répondants, le secteur d'activité, l'âge et d'autres facteurs peuvent intervenir. Aucun effet du territoire ou du sexe n'est estimé ici.

## 6. Interprétation et prochaines données à joindre

Pour transformer les indicateurs d'activités et de produits en résultats officiels, il faudra un identifiant commun entre la base d'enquête et les registres de sélection, formation, kits, MAF, chambre des métiers et AVEC, ainsi qu'une cohorte et une date d'arrêté. Pour 1.4, il faudra un référentiel daté des localités enclavées. Pour 3.7, une règle de disponibilité et un seuil horaire devront être validés. Pour 3.8, 4.1 et 4.2, les indices composites exigent une définition des dimensions, des poids et de la gestion des non-réponses avant codage.
