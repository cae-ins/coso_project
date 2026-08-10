# Matrice d'indicateurs — Évaluation d'impact COSO Nord

**Volet « Appel à projet d'insertion des jeunes » — sous-composante 1.3, 4 districts Nord**
Version du 2 juillet 2026. Ancrée sur le **Questionnaire Draft 7 (version du 01/07/2026)** complété
par l'**Addendum chômage/sous-emploi** (`Outils_de_Collecte/Addendum_Draft7_Chomage_SousEmploi.md`)
et sur la **Théorie du Changement** (`Ressources/théorie du changement revu _AIMON__revu.docx`).

---

## 0. Cadre d'estimation commun

- **Design** : RCT à 2 bras, randomisation individuelle ; ≈600 traités (package 2,5 M FCFA :
  formation 18 mois + kit + suivi post-installation) vs liste d'attente.
- **Estimateur principal (ITT)** : ANCOVA à l'endline —
  `Y_EL = α + β·T + γ·Y_BL + δ'strates + ε`, erreurs robustes. β est l'effet reporté pour **tous**
  les indicateurs d'effets et d'impact ci-dessous ; la colonne « Formule » donne la construction de Y.
- **Estimateur secondaire (LATE)** : IV/2SLS, instrument = assignation, traitement = package complet
  reçu (SIG : formation achevée **et** kit remis, indicateur B1×B2).
- **Conventions** : montants en FCFA winsorisés p1/p99 et transformés IHS (asinh) ; « Ne sait pas »
  (9, 9998, 9999) → valeur manquante ; indices composites = indice d'Anderson (pondération par
  covariance inverse, standardisé sur le bras témoin) ; α de Cronbach documenté à la baseline.
- **Tests multiples** : 2 outcomes **primaires** (C9 profit ; D6 indice de cohésion) testés sans
  correction ; les secondaires corrigés par Romano-Wolf **au sein de chaque famille** (D, C.1 … C.5).
- **Désagrégations préspécifiées (CATE)** : sexe (C1), âge (C2A/C2), district (B1q), niveau
  d'instruction (C4), secteur (F2).

**Chaîne TOC → familles d'indicateurs.** Activités (A) → Produits (B) → Effets (C : autonomie
financière C.2, insertion C.1, entrepreneuriat C.3, changement de statut C.4, résilience C.5) →
Impact (D : cohésion sociale).

---

## D. IMPACT — Cohésion sociale *(outcome phare du bailleur)*

| Code | Indicateur | Définition | Pertinence (TOC & évaluation) | Formule | Calcul à partir des variables |
|---|---|---|---|---|---|
| D1 | Participation associative | Est membre d'au moins une association, coopérative, club ou groupe communautaire (y compris en ligne) | TOC : « restaurer le sentiment d'appartenance » ; la sortie de l'oisiveté passe par la réinsertion dans les réseaux sociaux | Proportion ; ITT = β ANCOVA | `part_asso = (Q1==1)` |
| D2 | Volontariat communautaire | Nombre de participations à une activité d'intérêt général au cours des 30 derniers jours | Manifestation **comportementale** (pas seulement perçue) de la contribution à la communauté | Moyenne, winsorisée p99 | `volont = Q2` (numérique ; NSP→missing) |
| D3 | Confiance généralisée | Part déclarant qu'« on peut faire confiance à la plupart des gens » | Mesure standard (WVS/Afrobaromètre) → comparabilité externe ; base du capital social | Proportion | `conf_gen = (Q3==1)` |
| D4 | Confiance intergroupe | Confiance envers les jeunes d'origine différente (région, religion, ethnie), échelle 1–4 | Cœur du mandat COSO : ce sont les tensions **intercommunautaires** qui définissent la fragilité des zones Nord | Score standardisé (z, réf. témoin) | `conf_inter = z(Q4)` avec `Q4==9 → missing` |
| D5 | Confiance institutionnelle | Indice de confiance envers 6 institutions : police, armée, chefs traditionnels, chefs religieux, autorités locales, autorités centrales | TOC : « un jeune inséré est un rempart contre l'instabilité » ; la défiance institutionnelle est le marqueur de fragilité ciblé par le PAD | Moyenne des z-scores des 6 items (α Cronbach à vérifier) | `conf_inst = mean(z(Q5),z(Q6),z(Q7),z(Q8),z(Q9),z(Q10))`, `9→missing` item par item |
| **D6** | **Indice de cohésion sociale** 🟥 **PRIMAIRE** | Indice composite agrégeant D1–D5 | Outcome phare du bailleur ; un indice unique **préspécifié** protège contre les tests multiples et le picorage de résultats | Indice d'Anderson ; effet exprimé en σ | `idx_cohesion = anderson(part_asso, volont_std, conf_gen, conf_inter, conf_inst)` |

> ⚠️ **Limite V7** : le sentiment d'appartenance, la sécurité perçue, la participation au règlement
> des conflits et la **voix dans les décisions communautaires** (indicateurs du cadre de résultats
> PAD) ne sont pas couverts par Q1–Q10 — cf. Note de revue §4. Si ces questions sont ajoutées, les
> intégrer à D6 et le documenter dans le PAP **avant** l'endline.

---

## C.1 EFFETS — Insertion sur le marché du travail

| Code | Indicateur | Définition | Pertinence (TOC & évaluation) | Formule | Calcul à partir des variables |
|---|---|---|---|---|---|
| C1 | Taux d'emploi | En emploi au sens BIT : travail rémunéré ≥1 h (7 jours), ou absence temporaire d'un emploi, ou aide familiale orientée vers la vente | Première marche de la chaîne TOC « de l'oisiveté à l'activité » ; définition identique à l'ENE → comparable aux chiffres ANStat | Proportion | `EMPLOYE = (E1==1) \| (E2==1) \| (E3==1 & E3A==1)` |
| C2 | Emploi indépendant | En emploi avec statut d'employeur ou de travailleur à compte propre | Le package installe des **micro-entrepreneurs** : c'est le statut visé, pas l'emploi salarié | Proportion | `indep = EMPLOYE & F1 ∈ {2,3}` |
| C3 | Taux de chômage (LU1) | Sans emploi + recherche active (30 j) + disponible (2 sem.), y compris « future starters » | Le chômage est le premier terme du « système de fragilité » décrit par la TOC ; comparable ENE | `CHOMEUR / (EMPLOYE + CHOMEUR)` | `CHOMEUR = NON_EMPLOYE & ((J0==1 & J3==1) \| (J0A==8 & J3==1))` *(requiert l'addendum)* |
| C4 | Sous-emploi horaire | En emploi, < 40 h/sem toutes activités, souhaite et est disponible pour travailler plus | L'insertion **de qualité** ne se réduit pas à l'emploi : capte l'insertion incomplète (activités démarrées mais tournant à vide) | Proportion parmi les employés | `sous_emp = EMPLOYE & heures<40 & G7==1 & G7A==1` avec `heures = G3 + G6·(G5==1)` |
| C5 | Sous-utilisation composite (LU4) | Chômeurs + sous-employés + main-d'œuvre potentielle, rapportés à la main-d'œuvre élargie | Résumé le plus complet ; **robuste aux déplacements entre catégories** (un programme peut réduire le chômage en décourageant la recherche : LU4 ne s'y trompe pas) | `(CHOMEUR + sous_emp + MOP) / (EMPLOYE + CHOMEUR + MOP)` | `MOP = NON_EMPLOYE & !CHOMEUR & ((J0==1 & J3==2) \| (J0==2 & J0B==1 & J3==1))` |
| C6 | Heures travaillées | Volume horaire hebdomadaire total (toutes activités) | Marge intensive de l'insertion, complément de C1 (marge extensive) | Moyenne, winsorisée p99 | `heures = G3 + G6·(G5==1)` |
| C7 | Formalisation | Activité enregistrée (impôts, registre du commerce ou autorités locales) | Produit explicite du package (« appui à l'enregistrement à la chambre des métiers ») → doit bouger si l'accompagnement fonctionne | Proportion parmi les indépendants | `formel = (H4==1)` si `F1 ∈ {2,3,4}` |
| C8 | Pérennité de l'activité | Activité principale exercée sans interruption depuis ≥ 12 mois (à l'endline) | TOC : « prospérer **durablement** » ; croise le taux de survie SIG (B3) avec la déclaration du jeune | Proportion | `perenne = EMPLOYE & F4 ∈ {3,4,5}` |

---

## C.2 EFFETS — Revenus et autonomie financière

| Code | Indicateur | Définition | Pertinence (TOC & évaluation) | Formule | Calcul à partir des variables |
|---|---|---|---|---|---|
| **C9** | **Profit mensuel net** 🟥 **PRIMAIRE** | Profit de l'activité indépendante sur un **mois ordinaire**, après toutes les dépenses de l'activité, avant tout prélèvement personnel (méthode de Mel–McKenzie–Woodruff) | Outcome primaire économique : la TOC promet des micro-entreprises « qui génèrent des revenus dès le lancement » ; le profit — pas le chiffre d'affaires ni les retraits — mesure la création de valeur | Moyenne, winsorisée p1/p99 + IHS ; zéro pour les sans-activité (effet non conditionnel) | **V7 actuel** : `H5` ⚠️ amalgame profit/prélèvements — inutilisable en l'état. **Requiert la séquence MMW** (Note de revue §2.1) : `H5A` profit net dernier mois → `H5B` type de mois (bon/ordinaire/mauvais) → `H5C` profit d'un mois ordinaire ⇒ `profit = H5C` |
| C10 | Revenu salarial mensualisé | Salaire net de la dernière période de paie, ramené au mois | Une partie des jeunes s'insérera en emploi salarié ; nécessaire pour l'effet revenu global | `sal_mens = H3 × k(H2)` ; wins. + IHS | `k = 26 si H2==1 (quotidien) ; 4,33 si H2==2 ; 2,17 si H2==3 ; 1 si H2==4 ; H2==5 (irrégulier) → flag qualité` |
| C11 | Revenu du travail | Revenu mensuel du travail toutes activités (salarié ou indépendant) | Agrège C9 et C10 en un effet revenu unique, quel que soit le mode d'insertion | Wins. + IHS ; zéro si sans emploi | `rev_travail = sal_mens si F1==1 ; profit si F1 ∈ {2,3,4} ; 0 si NON_EMPLOYE` |
| C12 | Épargne | Épargne régulière ou occasionnelle ; montant d'un mois typique | TOC : « capacité d'épargne » explicitement visée comme composante de l'autonomie financière | Proportion ; montant wins. + IHS | `epargne = L3 ∈ {1,2}` ; `mt_epargne = L4` (« ça varie »→missing, flag) |
| C13 | Inclusion financière | Possède un compte mobile money ou bancaire | Canal de sécurisation des revenus et condition de l'investissement | Proportion | `inclus_fin = (L1==1) \| (L2==1)` |
| C14 | Crédit productif | A un emprunt en cours dont le motif principal est de démarrer ou développer une activité | « Accès quasi impossible au financement » = contrainte n°1 du diagnostic TOC | Proportion | `credit_prod = (L6==1) & (L9==1)` |

---

## C.3 EFFETS — Entrepreneuriat et capacités *(mécanismes)*

| Code | Indicateur | Définition | Pertinence (TOC & évaluation) | Formule | Calcul à partir des variables |
|---|---|---|---|---|---|
| C15 | Création d'activité | A déjà créé sa propre AGR/entreprise (active, fermée ou actuelle) | Marge extensive entrepreneuriale : le geste de création est l'acte central du package | Proportion | `crea = (K1==1)` |
| C16 | Compétences de gestion perçues | Auto-évaluation des compétences de gestion (comptes, prix, clientèle), 1–5 | Mécanisme TOC « renforcement de capacités » : médiateur attendu entre formation et profit | z-score | `comp_gest = z(IGA7)` |
| C17 | Formation entrepreneuriale reçue | A reçu une formation en entrepreneuriat/gestion distincte de la formation technique | Vérification d'exposition (« premier stade » côté enquête) du volet gestion du package | Proportion | `form_entr = (IGA6==1)` |
| C18 | Formation professionnelle (12 mois) | A suivi une formation technique/professionnelle ou un apprentissage dans les 12 derniers mois | Premier stade côté enquête du volet technique ; ⚠️ ne distingue pas COSO des autres programmes (cf. Note de revue) → croiser avec le SIG ; `O5==3` (programme gouvernemental) en resserrement | Proportion | `form_pro = (O3==1)` ; variante `form_pro_gov = (O3==1) & (O5==3)` |
| C26 | Statut d'employeur | En emploi avec le statut d'employeur (a des employés) | Passage de l'auto-emploi à la création d'emplois : le haut de la trajectoire entrepreneuriale visée par la TOC | Proportion | `employeur = EMPLOYE & (F1==2)` |
| C27 | Emplois rémunérés créés | Nombre de travailleurs rémunérés employés actuellement par le jeune (hors lui-même) | Multiplicateur d'emploi du programme : la TOC promet un jeune « acteur participant au développement dans sa propre localité » — effet au-delà du bénéficiaire ; clé pour le coût-efficacité (coût par emploi créé) | Moyenne, winsorisée p99 ; zéro si non-indépendant (effet non conditionnel) | `emplois_crees = H4A si F1 ∈ {2,3} ; 0 sinon (y compris NON_EMPLOYE)` |

---

## C.4 EFFETS — Changement de statut (« demandeur d'aide » → « producteur de valeur »)

| Code | Indicateur | Définition | Pertinence (TOC & évaluation) | Formule | Calcul à partir des variables |
|---|---|---|---|---|---|
| C19 | Indépendance vis-à-vis de l'aide | N'a reçu **aucune** aide financière ou matérielle externe pour ses besoins de base (12 mois) | TOC : « substituer à la dépendance financière une capacité d'auto-prise en charge » ; question **factuelle** → ancre la plus crédible de la famille | Proportion | `sans_aide = (M2==3)` |
| C20 | Rôle économique autonome (perçu) ⚠️ | Se décrit comme « autonome, produisant sa propre valeur » | Traduction mot à mot du maillon TOC « demandeur d'aide → producteur de valeur » ; ⚠️ formulation calquée sur le discours du programme → **fort risque d'effet de désirabilité/demande différentiel entre bras** (surestime l'ITT) — interpréter à l'aune de C19 | Proportion | `autonome = (M1==3)` |
| C21 | Reconnaissance sociale (perçue) ⚠️ | Degré d'accord : l'entourage me perçoit comme contribuant économiquement (1–5) | Charnière entre l'économique et la cohésion ; ⚠️ perceptuel, même réserve de désirabilité que C20 | z-score | `reconn = z(M3)` |
| C22 | Indice de changement de statut | Indice composite : indépendance de l'aide (factuel), autonomie perçue, reconnaissance, projection 12 mois (M4) | Résume la famille en un test unique ; ⚠️ 3 des 4 composantes sont perceptuelles → **reporter systématiquement C19 (factuel) à côté de l'indice** ; ne pas conclure sur l'indice seul s'il diverge de C19 | Indice d'Anderson | `idx_statut = anderson(sans_aide, autonome, reconn, (M4==1))` |

---

## C.5 EFFETS — Résilience

| Code | Indicateur | Définition | Pertinence (TOC & évaluation) | Formule | Calcul à partir des variables |
|---|---|---|---|---|---|
| C23 | Capacité d'absorption | Pourrait réunir 250 000 FCFA demain sans s'endetter lourdement ni vendre un bien essentiel | TOC : « absorber des chocs économiques sans retomber dans la pauvreté » — c'est LA définition opérationnelle de la promesse | Proportion (« facilement ») ; ordinal 1–3 en robustesse | `resil_dep = (N6A==1)` ; robustesse `N6A ∈ {1,2}` |
| C24 | Résilience perçue | Capacité auto-évaluée à résister à un choc économique, 1–10 | Complément subjectif de C23 ; sensible à l'effet « filet de sécurité » psychologique du package | z-score | `resil_percue = z(N7)` |
| C25 | Stratégies d'adaptation coûteuses | Parmi les ménages ayant subi un choc : a répondu principalement par la vente d'actifs ou la réduction de consommation | Qualité de la réponse au choc ; ⚠️ **conditionné à N1=1** (sous-échantillon endogène) → à reporter comme descriptif/secondaire, pas comme effet causal | Proportion conditionnelle | `strat_neg = N4 ∈ {2,6}` si `N1==1` |
| — | Exposition aux chocs | A subi un choc au cours des 12 derniers mois | **Covariable** (équilibre baseline, hétérogénéité), pas un outcome : à l'endline, l'exposition déclarée peut être endogène au traitement | — | `choc = (N1==1)` ; type `N2` |

---

## B. PRODUITS — Mise en œuvre *(SIG, suivi continu — non expérimental)*

| Code | Indicateur | Définition | Pertinence (TOC & évaluation) | Formule | Calcul à partir des variables |
|---|---|---|---|---|---|
| B1 | Complétion de la formation | Part des assignés au traitement achevant les 18 mois de formation | **Premier stade du LATE** ; la TOC suppose la complétion — c'est la première hypothèse vérifiable | % (SIG) | SIG : `complet = (statut_formation=="achevée")` |
| B2 | Kits remis et installation | Part des formés recevant kit/fonds de roulement et installés | Intégrité du package : sans kit, le mécanisme central saute | % (SIG) | SIG : `kit = (kit_remis==1 & installe==1)` ; **traité effectif LATE** = `complet & kit` |
| B3 | Survie de l'activité à 6 / 12 mois | Part des activités installées encore actives à 6 puis 12 mois | Pilier TOC n°3 : « garantir que l'entreprise ne s'arrête pas après la remise du kit » | % (SIG/suivi) | SIG : `survie_6m`, `survie_12m` |
| B4 | Fidélité de l'accompagnement | Visites de suivi réalisées / prévues (2/mois M1–6 ; 1/mois M7–12, soit 18 prévues) | Dose d'accompagnement : source d'hétérogénéité de mise en œuvre entre districts | Ratio (SIG) | SIG : `fidelite = visites_realisees / 18` |
| B5 | Intégration AVEC | Part des installés intégrés à un groupement AVEC | Produit explicite du package ; canal financier et social | % (SIG) | SIG : `avec = (avec_integre==1)` |

---

## A. ACTIVITÉS — Ciblage *(SIG)*

| Code | Indicateur | Définition | Pertinence (TOC & évaluation) | Formule | Calcul à partir des variables |
|---|---|---|---|---|---|
| A1 | Candidats enrôlés | Nombre de candidats du vivier | Détermine le bras témoin disponible ; base de sondage baseline | # (SIG) | SIG (≈1 688) |
| A2 | Bénéficiaires tirés au sort | Nombre d'assignés au traitement / au témoin, par strate | Trace la randomisation (unité, strates, ratio, date) — **à documenter comme protocole** | # (SIG + procès-verbal de tirage) | SIG : `T = (assigne==1)` |
| A3 | Part de femmes sélectionnées | Femmes / bénéficiaires | Pilier TOC « ciblage inclusif » ; cible PAD 40 % vs cible volet 50 % — **dénominateur à arbitrer** | % (SIG) | SIG croisé `C1` baseline |

---

## T. QUALITÉ DE L'ÉVALUATION *(transversal)*

| Code | Indicateur | Définition | Pertinence (TOC & évaluation) | Formule | Calcul à partir des variables |
|---|---|---|---|---|---|
| T1 | Taux de réponse endline par bras | Interviews complètes / assignés, par bras | **Menace n°1** (joignabilité 46 %) ; si différentiel significatif → bornes de Lee sur C9 et D6 | % par bras + test de différence ; Lee bounds si p<0,05 | Module A (résultat d'appel `A4==1`) ; traçage `R1–R5` de la baseline |
| T2 | Exposition du témoin | Part des témoins ayant reçu une formation ou un kit d'un programme (COSO ou autre) | Contamination → dilution de l'ITT ; à documenter pour interpréter β | % bras témoin | `(O3==1 & O5==3)` + croisement SIG |
| T3 | Équilibre baseline | Différences T–C sur les covariables préspécifiées | Validité interne de la randomisation | Test t par variable + F joint | `C1, C2A/C2, C3, C4, D1–D5, EMPLOYE, heures, H5/H3, L1–L3, N1, Q1–Q10` |

---

## Notes et dépendances

1. **Dépendances au questionnaire** : C3–C5 requièrent l'**Addendum** (J0/J0A/J0B/G7A) ; **C9 requiert
   la séquence profit MMW** (Note de revue §2.1) — sans elle, l'outcome primaire économique n'est pas
   mesurable proprement ; D6 s'enrichirait des dimensions cohésion manquantes (Note de revue §4).
2. **Ce que la V7 ne permet pas** (assumé, hors matrice) : FIES (insécurité alimentaire), Washington
   Group (handicap — désagrégation PAD), pro-WEAI (autonomisation des femmes), PHQ-2 (détresse
   psychologique), NEET strict. Ces modules figurent dans le Draft 8 Proposition ; les réintégrer si
   l'arbitrage de durée le permet, sinon documenter leur absence dans le PAP.
3. **Baseline = avant tirage ou au pire avant remise des kits** ; tous les indicateurs C et D sont
   mesurés BL + EL ; A et B en continu (SIG).
4. **Endline ≥ 12 mois après l'installation** (formation de 18 mois → ≈30 mois après démarrage), sans
   quoi C8, C9 et B3 mesureraient des activités pas encore à régime.
5. À réconcilier avec le cadre de résultats officiel du PAD une fois le rattachement institutionnel
   du volet clarifié (question ouverte — cf. `MEMOIRE.md`).
