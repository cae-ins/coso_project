# QUESTIONNAIRE BASELINE — PROGRAMME JEUNESSE COSO

## Draft 8 — Proposition méthodologique

**Date :** 27 juin 2026  
**Statut :** document de travail distinct ; ne remplace pas le Draft 7  
**Mode principal :** téléphone, avec certains champs réservés aux visites en personne  
**Population :** candidats éligibles au volet d'insertion  
**Durée cible :** 35–45 minutes selon les branches

## Principes

- Les règles marquées **À VALIDER** sont des propositions méthodologiques.
- Les données d'assignation, formation, kit et suivi proviennent prioritairement du SIG.
- Les codes NSP/refus sont harmonisés : `-98=Ne sait pas`, `-99=Refus`.
- Les montants autorisent zéro lorsque zéro est une réponse réelle.
- Les informations nominatives de traçage sont stockées séparément de la base analytique.

## Script d'introduction et consentement

> Bonjour, je m'appelle [NOM] et je vous appelle pour le compte de [ORGANISATION], dans le cadre d'une étude sur la situation des jeunes ayant candidaté au Programme Jeunesse COSO. L'entretien dure environ 35 à 45 minutes. Votre participation est volontaire. Vos réponses resteront confidentielles et n'affecteront ni votre candidature ni l'appui que vous pourriez recevoir. Vous pouvez refuser une question ou arrêter l'entretien à tout moment.

---

## A. Gestion de l'appel

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| A1 | Tous les appels | Numéro de la tentative | Entier 1–10 |
| A2 | Tous les appels | Date de l'appel | Date automatique |
| A3 | Tous les appels | Heure de début | Heure automatique |
| A4 | Tous les appels | Résultat de la tentative | 1=Entretien complet · 2=Partiel · 3=Refus · 4=Rappel convenu · 5=Pas de réponse · 6=Injoignable/hors service · 7=Mauvais numéro · 8=Répondant indisponible durablement · 9=Autre |
| A5 | Si A4=4 | Date et heure du rappel | Date/heure future |
| A6 | Fin d'appel | Heure de fin | Heure automatique |

---

## B. Localisation, identité et consentement

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| B1 | Préchargé, confirmer | District de résidence | Liste officielle |
| B2 | Préchargé, confirmer | Région | Liste officielle |
| B3 | Préchargé, confirmer | Département | Liste officielle |
| B4 | Préchargé, confirmer | Sous-préfecture/commune | Liste officielle |
| B5 | Tous | Milieu de résidence | 1=Urbain · 2=Rural |
| B6 | Tous | Suis-je bien en train de parler à [NOM PRÉCHARGÉ] ? | 1=Oui → B7 · 2=Non |
| B6A | Si B6=2 | Cette personne est-elle disponible ? | 1=Oui, la passer · 2=Non · 3=Ne connaît pas cette personne/mauvais numéro |
| B6B | Si B6A=2 | Peut-on convenir d'un moment de rappel ? | 1=Oui · 2=Non |
| B6C | Si B6B=1 | Date et heure souhaitées | Date/heure |
| B7 | Répondant identifié | Acceptez-vous de participer à l'étude ? | 1=Oui · 2=Non → fin |
| B8 | Si enregistrement prévu | Acceptez-vous que l'appel soit enregistré uniquement pour le contrôle qualité ? | 1=Oui · 2=Non ; poursuivre sans enregistrer si non |
| B9 | Si B7=1 | Identifiant du candidat | Préchargé, non modifiable |
| B10 | Si B7=1 | Nom complet confirmé | Texte ; fichier de contacts séparé |

---

## C. Profil individuel

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| C1 | Tous | Quel est votre sexe ? | 1=Homme · 2=Femme · 3=Autre/préfère se décrire · 99=Préfère ne pas répondre |
| C2 | Tous | Quelle est votre date de naissance ? | JJ/MM/AAAA · NSP autorisé |
| C2A | Si année inconnue à C2 | Quel âge avez-vous en années révolues ? | 15–40 attendu ; hors plage = contrôle, pas rejet automatique |
| C3 | Tous | Quel est votre statut matrimonial actuel ? | 1=Célibataire · 2=Marié/union · 3=Divorcé/séparé · 4=Veuf/veuve |
| C4 | Tous | Quel est le niveau d'études le plus élevé atteint ? | 0=Aucun · 1=Primaire incomplet · 2=Primaire achevé · 3=Secondaire 1er cycle · 4=Secondaire 2nd cycle · 5=Technique/professionnel · 6=Supérieur · 7=Coranique/autre |
| C5 | Tous | Pouvez-vous lire et comprendre une phrase simple dans une langue que vous utilisez ? | 1=Oui facilement · 2=Avec difficulté · 3=Non |
| C6 | Tous | Au cours des 12 derniers mois, avez-vous changé de localité pour vous y installer ? | 1=Oui · 2=Non |
| C6A | Si C6=1 | D'où êtes-vous parti(e) et où vous êtes-vous installé(e) ? | Localité d'origine + destination |

### C-WG. Handicap — Washington Group Short Set

Préfixe : « Avez-vous des difficultés à… »  
Modalités communes : `1=Aucune · 2=Quelques difficultés · 3=Beaucoup de difficultés · 4=Pas capable du tout`.

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| WG1 | Tous | voir, même avec des lunettes ? | 1–4 |
| WG2 | Tous | entendre, même avec un appareil auditif ? | 1–4 |
| WG3 | Tous | marcher ou monter des marches ? | 1–4 |
| WG4 | Tous | vous souvenir ou vous concentrer ? | 1–4 |
| WG5 | Tous | prendre soin de vous-même, par exemple vous laver ou vous habiller ? | 1–4 |
| WG6 | Tous | communiquer dans votre langue habituelle, comprendre ou être compris(e) ? | 1–4 |

---

## D. Ménage et actifs

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| D1 | Tous | Combien de personnes vivent habituellement dans votre ménage, vous compris(e) ? | Entier ≥1 |
| D2 | Tous | Combien ont moins de 15 ans ? | Entier 0–D1 |
| D3 | Tous | Quel est votre lien avec le chef de ménage ? | 1=Chef · 2=Conjoint · 3=Enfant · 4=Autre parent · 5=Sans lien |
| D4 | Tous | Combien de membres du ménage exercent actuellement une activité rémunérée ? | Entier 0–D1 |
| D5 | Tous | Parmi les biens suivants, lesquels votre ménage possède-t-il et combien sont fonctionnels ? | Moto/tricycle · vélo · téléphone simple · smartphone · téléviseur · réfrigérateur/congélateur · panneau solaire/groupe · charrette · voiture |
| D6 | Tous | Combien d'animaux le ménage possède-t-il actuellement ? | Bovins · ovins/caprins · volailles · porcins ; entiers ≥0 |
| D7 | Tous | Le ménage exploite-t-il des terres agricoles ? | 1=Oui · 2=Non |
| D7A | Si D7=1 | Quelle superficie totale ? | Valeur + unité locale/hectare |
| D8 | Tous | Principal matériau des murs du logement | Ciment/béton · briques · banco amélioré · banco traditionnel · bois/tôle/récupération · autre |
| D9 | Tous | Principale source d'éclairage | Réseau CIE · solaire · groupe · lampe/pile · pétrole · autre |
| D10 | Tous | Principale source d'eau de boisson | Robinet · borne-fontaine · forage · puits · eau de surface · sachet/bouteille · autre |

---

## E. Statut d'activité

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| E1 | Tous | Au cours des 7 derniers jours, avez-vous travaillé au moins une heure contre un salaire, un profit, une commission, un pourboire ou une rémunération en nature ? | 1=Oui → `EMPLOYÉ=1` · 2=Non |
| E2 | Si E1=2 | Aviez-vous un emploi ou une entreprise dont vous étiez temporairement absent(e) et auquel vous allez retourner ? | 1=Oui → `EMPLOYÉ=1` · 2=Non |
| E3 | Si E1=2 et E2=2 | Avez-vous aidé sans rémunération directe dans une entreprise ou exploitation familiale ? | 1=Oui · 2=Non |
| E3A | Si E3=1 | Les produits/services étaient-ils principalement destinés à la vente ou à l'usage du ménage ? | 1=Vente → `EMPLOYÉ=1` · 2=Usage du ménage → `EMPLOYÉ=0` |

**Variable dérivée :**

```text
EMPLOYÉ = 1 si E1=1 ou E2=1 ou (E3=1 et E3A=1)
EMPLOYÉ = 0 si E1=2, E2=2 et [E3=2 ou (E3=1 et E3A=2)]
NON_EMPLOYÉ = 1 - EMPLOYÉ
```

---

## F. Emploi principal

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| F1 | Si EMPLOYÉ=1 | Quel est votre statut dans cet emploi ? | 1=Salarié · 2=Employeur · 3=Indépendant/compte propre · 4=Membre de coopérative · 5=Aide familial non rémunéré · 6=Apprenti/stagiaire · 7=Autre |
| F2 | Si EMPLOYÉ=1 | Quel métier ou travail exercez-vous principalement ? Décrivez les tâches principales. | Texte détaillé ; codification ultérieure |
| F2C | Codification | Code du métier actuel | Nomenclature à valider ; ne pas inventer automatiquement |
| F3 | Si EMPLOYÉ=1 | Quel est le secteur de cette activité ? | Agriculture/élevage/pêche · extraction · industrie · BTP · commerce · transport · hébergement/restauration · information/numérique · finance · administration · éducation · santé · travail domestique · autres services · autre |
| F4 | Si EMPLOYÉ=1 | Où exercez-vous principalement ? | Domicile · proche domicile · employeur · local fixe · marché/kiosque · chantier · champ · mobile · autre |
| F5 | Si EMPLOYÉ=1 | Depuis quel mois et quelle année exercez-vous cette activité sans interruption ? | MM/AAAA ; durée dérivée |

---

## G. Qualité de l'emploi et temps de travail

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| G1 | Si EMPLOYÉ=1 | Disposez-vous d'un contrat ou accord de travail ? | 1=CDI écrit · 2=CDD écrit · 3=Accord verbal · 4=Aucun |
| G2 | Si EMPLOYÉ=1 | Bénéficiez-vous d'une couverture sociale liée à cet emploi ? | 1=Oui · 2=Non |
| G3 | Si EMPLOYÉ=1 | Combien d'heures avez-vous réellement travaillé dans cet emploi au cours des 7 derniers jours ? | 0–112 ; >84 confirmation |
| G4 | Si EMPLOYÉ=1 | Est-ce votre nombre habituel d'heures par semaine ? | 1=Oui · 2=Non |
| G4A | Si G4=2 | Combien d'heures travaillez-vous habituellement par semaine dans cet emploi ? | 0–112 |
| G5 | Si EMPLOYÉ=1 | Avez-vous un autre emploi ou une autre activité génératrice de revenus ? | 1=Oui · 2=Non |
| G6 | Si G5=1 | Combien d'heures y avez-vous travaillé au total au cours des 7 derniers jours ? | 0–112 ; G3+G6≤140 à contrôler |
| G7 | Si EMPLOYÉ=1 | Souhaiteriez-vous travailler davantage d'heures si l'occasion se présentait ? | 1=Oui · 2=Non |
| G8 | Si G7=1 | Seriez-vous disponible pour travailler davantage au cours des deux prochaines semaines ? | 1=Oui · 2=Non |

---

## H. Revenu salarié et caractéristiques de l'entreprise

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| H1 | Si F1=1 | Au cours des 30 derniers jours, combien avez-vous reçu au total pour cet emploi, en espèces et en nature ? | FCFA ≥0 · NSP/refus |
| H2 | Si F1=1 | Ces 30 derniers jours étaient-ils habituels pour votre rémunération ? | 1=Oui · 2=Montant plus élevé · 3=Montant plus faible |
| H3 | Si F1=1 et H2≠1 | Au cours d'un mois habituel, combien recevez-vous au total ? | FCFA ≥0 |
| H4 | Si F1∈{2,3,4} | L'activité est-elle enregistrée auprès d'une administration ou organisation professionnelle ? | 1=Oui · 2=Non · 3=Ne sait pas |
| H4A | Si F1∈{2,3} | Combien de travailleurs rémunérés employez-vous actuellement, sans vous compter ? | Entier ≥0 |

### H-PR. Profit de l'activité indépendante

Univers : `F1∈{2,3,4}`.

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| PR1 | Indépendants | Le mois dernier, quel profit net cette activité a-t-elle généré après avoir payé toutes les dépenses de l'activité, mais avant de retirer de l'argent pour vous ou votre ménage ? | FCFA ; zéro autorisé ; perte saisie séparément |
| PR1A | Si activité en perte | Le mois dernier, l'activité a-t-elle fait une perte ? Si oui, de combien ? | 1=Oui + montant · 2=Non |
| PR2 | Indépendants | Le mois dernier était-il un mois normal, bon ou mauvais pour cette activité ? | 1=Normal · 2=Bon · 3=Mauvais |
| PR3 | Si PR2≠1 | Lors d'un mois normal, quel profit net cette activité génère-t-elle ? | FCFA ; zéro/perte autorisés |
| PR4 | Indépendants | Sur les 12 derniers mois, combien de mois ont été bons, normaux, mauvais ou sans activité ? | Quatre nombres dont la somme=12 |
| PR5 | Indépendants | À combien se sont élevées toutes les dépenses de l'activité le mois dernier ? | FCFA ≥0 |
| PR6 | Indépendants | Quel a été le chiffre d'affaires total du mois dernier ? | FCFA ≥0 |
| PR7 | Indépendants | Quelle est la valeur des produits de l'activité consommés par votre ménage le mois dernier ? | FCFA ≥0 |
| PR8 | Indépendants | Si vous vendiez aujourd'hui le matériel, l'équipement et le stock de l'activité, quelle serait leur valeur totale ? | FCFA ≥0 |
| PR9 | Indépendants | Tenez-vous un cahier ou registre des comptes ? | 1=Oui régulièrement · 2=Oui irrégulièrement · 3=Non |

**Contrôles non bloquants :** comparer `PR6-PR5` à `PR1`, confirmer les montants extrêmes, ne pas corriger automatiquement.

---

## I. Recherche d'un autre emploi — personnes employées

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| I1 | Si EMPLOYÉ=1 | Recherchez-vous activement un autre emploi ou une autre activité ? | 1=Oui · 2=Non |
| I2 | Si I1=1 | Quelle est la principale raison ? | Revenu insuffisant · instabilité · meilleure adéquation · meilleures conditions · autre |
| I3 | Si I1=1 | Quelle démarche principale avez-vous entreprise au cours des 30 derniers jours ? | Employeur · offre · agence · réseau · concours · création d'entreprise · autre |

---

## J. Recherche d'emploi — personnes non employées

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| J0 | Si NON_EMPLOYÉ=1 | Au cours des 30 derniers jours, avez-vous entrepris au moins une démarche active pour trouver un emploi ou démarrer une activité ? | 1=Oui · 2=Non |
| J1 | Si J0=1 | Quelle a été votre principale démarche ? | Employeur · offre · agence · réseau · concours · création d'entreprise · autre |
| J2 | Si J0=1 | Depuis combien de temps cherchez-vous ? | <1 mois · 1–<3 · 3–<6 · 6–<12 · 1–<2 ans · ≥2 ans |
| J3 | Si NON_EMPLOYÉ=1 | Si vous aviez trouvé un emploi la semaine dernière, auriez-vous pu commencer dans les deux semaines ? | 1=Oui · 2=Non |
| J4 | Si J0=2 | Quelle est la principale raison pour laquelle vous n'avez pas cherché ? | Études/formation · tâches familiales/soins · maladie/handicap · découragé · attend saison/résultat · ne souhaite pas travailler · autre |

---

## K. Entrepreneuriat

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| K1 | Tous | Avez-vous déjà créé votre propre activité ou entreprise, qu'elle soit active ou fermée ? | 1=Oui · 2=Non |
| K2 | Si K1=2 | Souhaiteriez-vous en créer une à l'avenir ? | 1=Oui · 2=Non · 3=Ne sait pas |
| K3 | Si K1=1 | Quelle a été la principale source d'argent au démarrage ? | Épargne · famille/amis · tontine/AVEC · banque/microfinance · programme/ONG/État · fournisseur · autre |
| K4 | Si K1=2 et K2=1 | Quelle serait votre principale source de financement ? | Même liste |
| K5 | Si K1=2 et K2=1 | Qu'est-ce qui vous empêche actuellement de démarrer ? | Plusieurs réponses : capital · compétences · équipement/local · marché/clients · responsabilités familiales · autorisation · risque · autre |
| K6 | Tous | Avez-vous déjà reçu une formation en entrepreneuriat ou gestion ? | 1=Oui · 2=Non |
| K7 | Tous | Comment évaluez-vous votre capacité à gérer une activité ? | 1=Très faible … 5=Très bonne |

---

## L. Inclusion financière et épargne

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| L1 | Tous | Possédez-vous un compte Mobile Money personnel ? | 1=Oui · 2=Non |
| L2 | Tous | Possédez-vous un compte bancaire ou de microfinance personnel ? | 1=Oui · 2=Non |
| L3 | Tous | Mettez-vous de l'argent de côté ? | 1=Régulièrement · 2=Occasionnellement · 3=Jamais |
| L4 | Si L3∈{1,2} | Combien avez-vous épargné au total au cours des 30 derniers jours ? | FCFA ≥0 |
| L5 | Si L3∈{1,2} | Où gardez-vous principalement cette épargne ? | Domicile · tontine/AVEC · banque/microfinance · Mobile Money · autre |
| L6 | Tous | Avez-vous actuellement un prêt ou une dette en cours ? | 1=Oui · 2=Non |
| L7 | Si L6=1 | Quelle est la source principale ? | Banque · microfinance · Mobile Money · AVEC · famille/amis · employeur · prêteur informel · autre |
| L8 | Si L6=1 | Combien devez-vous encore rembourser au total ? | FCFA ≥0 |
| L9 | Si L6=1 | Quel était le principal motif ? | Activité · besoins courants · éducation · santé · logement · choc · autre |

---

## M. Statut productif perçu

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| M1 | Tous | Comment décririez-vous votre rôle économique actuel ? | 1=Je dépends principalement de l'aide d'autrui · 2=Je suis en transition · 3=Je suis autonome et produis ma propre valeur |
| M2 | Tous | Au cours des 12 derniers mois, avez-vous reçu une aide externe pour couvrir vos besoins de base ? | 1=Régulièrement · 2=Ponctuellement · 3=Jamais |
| M3 | Tous | « Mon entourage me considère comme une personne qui contribue économiquement. » | 1=Pas du tout d'accord … 5=Tout à fait d'accord |
| M4 | Tous | Dans 12 mois, vous voyez-vous plutôt comme… | 1=Producteur autonome · 2=Entre les deux · 3=Dépendant d'une aide · 4=Ne sait pas |

### M-PSY. Auto-efficacité et espoir

Modalités : `1=Pas du tout d'accord · 2=Plutôt pas d'accord · 3=Plutôt d'accord · 4=Tout à fait d'accord`.

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| PSY1 | Tous | Je peux résoudre la plupart de mes problèmes si je fais les efforts nécessaires. | 1–4 |
| PSY2 | Tous | Quand je rencontre une difficulté, je trouve généralement plusieurs solutions. | 1–4 |
| PSY3 | Tous | J'ai confiance dans ma capacité à améliorer ma situation économique au cours des deux prochaines années. | 1–4 |
| PSY4 | Tous | Je me sens optimiste quant à mon avenir. | 1–4 |

---

## N. Résilience, chocs et sécurité alimentaire

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| N1 | Tous | Au cours des 12 derniers mois, votre ménage a-t-il subi au moins un choc important ? | 1=Oui · 2=Non → N6 |
| N2 | Si N1=1 | Quels chocs avez-vous subis ? | Plusieurs réponses : maladie/accident · décès · sécheresse/inondation · mauvaise récolte · perte d'emploi/activité · hausse forte des prix · vol/insécurité/déplacement · autre |
| N3 | Si N1=1 | Quel a été l'impact du choc le plus important sur le revenu ou l'activité ? | 1=Aucun · 2=Limité · 3=Important, redressement en cours · 4=Très important, activité arrêtée/réduite |
| N4 | Si N1=1 | Qu'avez-vous fait pour y faire face ? | Plusieurs réponses : épargne · vente d'actifs/bétail · emprunt · aide familiale · aide ONG/État · réduction repas/consommation · retrait enfant école · autre · rien |
| N5 | Si N1=1 | Combien de temps a-t-il fallu pour retrouver le niveau d'avant le choc ? | <1 mois · 1–3 · 3–6 · >6 · pas encore rétabli |
| N6 | Tous | Pourriez-vous faire face à une dépense imprévue de 50 000 FCFA dans les 7 prochains jours sans vendre un bien essentiel ? | 1=Oui facilement · 2=Oui difficilement · 3=Non |
| N7 | Tous | Sur une échelle de 0 à 10, comment évaluez-vous votre capacité actuelle à résister à un choc économique ? | 0=Très faible … 10=Très élevée |

### N-FIES. Insécurité alimentaire

Préfixe : « Au cours des 12 derniers mois, faute d'argent ou d'autres ressources, vous est-il arrivé de… »  
Modalités : `1=Oui · 2=Non`.

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| FIES1 | Tous | être inquiet(e) de ne pas avoir assez à manger ? | Oui/Non |
| FIES2 | Tous | ne pas pouvoir manger des aliments sains et nutritifs ? | Oui/Non |
| FIES3 | Tous | manger peu d'aliments variés ? | Oui/Non |
| FIES4 | Tous | sauter un repas ? | Oui/Non |
| FIES5 | Tous | manger moins que nécessaire ? | Oui/Non |
| FIES6 | Tous | être à court de nourriture dans le ménage ? | Oui/Non |
| FIES7 | Tous | avoir faim sans pouvoir manger ? | Oui/Non |
| FIES8 | Tous | passer une journée entière sans manger ? | Oui/Non |

---

## O. Expérience professionnelle, formations et autres appuis

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| O1 | Tous | Avez-vous déjà eu un autre emploi ou une autre activité génératrice de revenus ? | 1=Oui · 2=Non |
| O2 | Si O1=1 | À quel âge avez-vous commencé votre première activité ? | Entier 5–40 ; contrôle avec âge actuel |
| O3 | Tous | Avez-vous suivi une formation professionnelle, technique ou un apprentissage au cours des 12 derniers mois ? | 1=Oui · 2=Non |
| O4 | Si O3=1 | Dans quel métier ou domaine ? | Texte + codification ultérieure |
| O5 | Si O3=1 | Qui l'a principalement dispensée ? | Centre formel · entreprise · programme public · ONG · maître artisan/famille · sur le tas · autre |
| O6 | Si O3=1 | Avez-vous achevé cette formation ? | 1=Oui · 2=Non, en cours · 3=Non, abandonnée |
| O6A | Si O6=3 | Pourquoi avez-vous abandonné ? | Coût · distance · travail · famille/garde · santé · qualité · autre |
| O7 | Si O3=1 | Quelle a été ou sera la durée totale ? | Nombre + jours/semaines/mois |
| O8 | Si O3=1 | Cette formation vous a-t-elle aidé à trouver un emploi ou améliorer vos revenus ? | 1=Pas utile · 2=Un peu · 3=Beaucoup · 4=Trop tôt pour dire |
| O9 | Tous | Au cours des 12 derniers mois, avez-vous reçu d'un autre programme une formation, un kit, une subvention ou un coaching pour l'emploi ? | Plusieurs réponses + nom du programme · Aucun |

---

## P. Aspirations professionnelles

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| P1 | Tous | Quel métier ou activité souhaiteriez-vous exercer dans cinq ans ? | Texte |
| P2 | Tous | Souhaitez-vous principalement… | 1=Emploi salarié · 2=Créer une entreprise · 3=Développer une activité existante |
| P3 | Tous | Quel revenu mensuel souhaiteriez-vous atteindre dans cinq ans ? | FCFA |
| P4 | Tous | Quel secteur vous intéresse le plus ? | Même nomenclature que F3 |
| P5 | Tous | Quel est le principal obstacle à cet objectif ? | Capital · compétences · emploi disponible · marché · équipement/local · famille/garde · mobilité/sécurité · santé/handicap · autre |

---

## Q. Autonomisation et décisions

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| GEN1 | Tous | Qui décide principalement de l'usage de l'argent que vous gagnez ? | 1=Moi seul(e) · 2=Moi et conjoint(e) · 3=Conjoint(e) · 4=Autre membre |
| GEN2 | Tous | Qui décide des dépenses importantes du ménage ? | Même liste |
| GEN3 | Tous | Qui a principalement décidé de votre candidature au programme COSO ? | Même liste |
| GEN4 | Tous | Pouvez-vous vous rendre seul(e) au marché, au centre de santé ou au chef-lieu ? | 1=Oui sans permission · 2=Oui avec permission · 3=Non |
| GEN5 | Tous | Disposez-vous d'un revenu ou d'une somme que vous contrôlez personnellement ? | 1=Oui · 2=Non |
| GEN6 | Tous | « Une femme devrait pouvoir exercer une activité rémunérée hors du foyer. » | 1=Pas du tout d'accord … 5=Tout à fait d'accord |
| GEN7 | Personnes ayant enfant <6 ans | La garde d'enfants limite-t-elle votre possibilité de travailler ou suivre une formation ? | 1=Oui beaucoup · 2=Oui un peu · 3=Non |

---

## R. Cohésion sociale et engagement

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| COH1 | Tous | Êtes-vous membre d'une association, coopérative, club, groupe religieux, AVEC ou groupe communautaire ? | 1=Oui · 2=Non |
| COH2 | Tous | Au cours des 30 derniers jours, combien de fois avez-vous donné du temps à une activité d'intérêt général ? | Entier ≥0 |
| COH3 | Tous | De manière générale, peut-on faire confiance à la plupart des gens ? | Échelle 0=Aucune confiance … 10=Confiance totale |
| COH4A | Tous | Confiance dans les personnes de votre communauté | 0–10 |
| COH4B | Tous | Confiance dans les personnes d'une autre ethnie | 0–10 |
| COH4C | Tous | Confiance dans les personnes d'une autre religion | 0–10 |
| COH4D | Tous | Confiance dans les nouveaux arrivants/allochtones | 0–10 |
| COH5 | Tous | Si vous perdiez un portefeuille dans votre localité, quelle est la chance qu'il vous soit rendu ? | 0=Aucune … 10=Très forte |
| COH6A | Tous | Confiance dans l'administration/l'État | 0–10 |
| COH6B | Tous | Confiance dans les chefs traditionnels ou religieux | 0–10 |
| COH6C | Tous | Confiance dans les forces de sécurité | 0–10 |
| COH7 | Tous | Vous sentez-vous membre à part entière de votre communauté ? | 1=Pas du tout … 5=Tout à fait |
| COH8A | Tous | « La violence est parfois justifiée pour défendre son groupe. » | 1=Pas du tout d'accord … 5=Tout à fait d'accord |
| COH8B | Tous | « Les désaccords dans la communauté doivent se régler uniquement de manière pacifique. » | 1–5 |
| COH9 | Tous | Vous sentez-vous en sécurité en marchant seul(e) la nuit dans votre localité ? | 1=Très en sécurité · 2=Assez · 3=Peu · 4=Pas du tout |
| COH10 | Tous | Au cours des 12 derniers mois, la sécurité s'est-elle… | 1=Améliorée · 2=Stable · 3=Dégradée |
| COH11 | Tous | Avez-vous participé à la résolution d'un conflit ou à un dialogue communautaire au cours des 12 derniers mois ? | 1=Oui · 2=Non |
| COH12 | Tous | Dans quelle mesure estimez-vous avoir votre mot à dire dans les décisions de votre communauté ? | 1=Pas du tout … 5=Beaucoup |
| COH13 | Endline seulement | Les investissements du projet reflètent-ils les besoins de votre communauté ? | 1=Pas du tout … 5=Tout à fait · NSP |
| COH14 | Endline seulement | Les investissements du projet ont-ils contribué à accroître la confiance entre membres de la communauté ? | 1=Pas du tout … 5=Beaucoup · NSP |

---

## S. Suivi panel et traçage

Ces données sont personnelles et doivent être conservées dans une table séparée et sécurisée.

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| TRACE1 | Tous | Le numéro utilisé aujourd'hui est-il le meilleur pour vous recontacter ? | 1=Oui · 2=Non |
| TRACE1A | Si TRACE1=2 | Quel est le meilleur numéro ? | Numéro validé |
| TRACE2 | Tous | Avez-vous un deuxième numéro personnel ? | 1=Oui + numéro · 2=Non |
| TRACE3 | Tous | Utilisez-vous WhatsApp ? | 1=Oui, numéro principal · 2=Oui, autre numéro à préciser · 3=Non |
| TRACE4 | Tous | Pouvez-vous donner le contact d'une personne qui saura vous joindre ? | Nom · lien · téléphone · consentement à contacter |
| TRACE5 | Tous | Pouvez-vous donner un deuxième contact, d'un autre ménage si possible ? | Nom · lien · téléphone |
| TRACE6 | Tous | Décrivez deux points de repère permettant de retrouver votre domicile | Texte |
| TRACE7 | Visite en personne seulement | Coordonnées GPS du domicile habituel | Capture GPS avec précision ; ne pas utiliser le GPS du lieu d'appel |
| TRACE8 | Tous | Acceptez-vous d'être recontacté(e) pour les prochaines vagues ? | 1=Oui · 2=Non |

---

## Annexe A. Module endline de mise en œuvre

À administrer à l'endline et à rapprocher du SIG. Ne pas remplacer le SIG par l'auto-déclaration.

| Code | Univers / filtre | Question | Modalités / validation |
|---|---|---|---|
| END1 | Tous | Avez-vous effectivement commencé une formation COSO ? | Oui/Non + date |
| END2 | Si END1=Oui | L'avez-vous achevée ? | Achevée · en cours · abandonnée + motif |
| END3 | Tous | Avez-vous reçu un kit ou équipement COSO ? | Oui/Non + date + type |
| END4 | Si END3=Oui | Avez-vous démarré l'activité appuyée ? | Oui/Non + date |
| END5 | Si END4=Oui | Cette activité est-elle toujours active ? | Oui/Non + date arrêt + motif |
| END6 | Tous | Combien de visites de coaching avez-vous reçues au cours des 6 derniers mois ? | Entier ≥0 |
| END7 | Tous | Avez-vous reçu un appui similaire d'un autre programme depuis la baseline ? | Formation · kit · argent · coaching · aucun + programme |

---

## Annexe B. Variables dérivées essentielles

```text
EMPLOYÉ = E1=1 ou E2=1 ou (E3=1 et E3A=1)
AUTO_EMPLOI = EMPLOYÉ=1 et F1∈{2,3,4}
CHÔMEUR = EMPLOYÉ=0 et J0=1 et J3=1
INACTIF = EMPLOYÉ=0 et non CHÔMEUR
HEURES_TOTALES = G3 + G6 si G5=1, sinon G3
SOUS_EMPLOI = EMPLOYÉ=1 et heures sous seuil validé et G7=1 et G8=1
PROFIT_MOIS_NORMAL = PR1 si PR2=1, sinon PR3
FIES_BRUT = nombre de Oui parmi FIES1–FIES8
```

Les indices de résilience, statut productif, espoir et cohésion doivent être préspécifiés dans le plan d'analyse avant l'endline.

## Annexe C. Points à valider avant programmation

1. plage d'âge officielle du volet ;
2. cible femmes et dénominateur ;
3. montant de la dépense imprévue (`N6`) ;
4. seuil horaire du sous-emploi ;
5. nomenclature métier/secteur ;
6. durée maximale acceptable au téléphone ;
7. protocole pour questions sensibles et langue d'administration ;
8. séparation technique des contacts et données analytiques ;
9. contenu exact du module endline ;
10. test cognitif et pilote avant déploiement.
