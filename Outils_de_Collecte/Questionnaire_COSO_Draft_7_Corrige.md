# QUESTIONNAIRE BASELINE — PROGRAMME JEUNESSE COSO

## Draft 7 — Corrigé (corrections de bugs uniquement)

**Date :** 27 juin 2026
**Base :** `Questionnaire_COSO_Draft_7.docx`
**Portée des modifications :** correction des erreurs techniques documentées dans `MEMOIRE.md`.
**Aucun module, question ou modalité de fond n'a été ajouté.** La structure, la longueur (~30 min)
et le contenu du Draft 7 sont conservés à l'identique en dehors des corrections listées ci-dessous.

## Journal des corrections

| # | Item | Avant (Draft 7) | Après (corrigé) |
|---|---|---|---|
| 1 | **B6B** (1ʳᵉ occurrence) | Code `B6B` utilisé deux fois (doublon) | Renommé en `B6A` ; le filtre « Posez si B6A=2 » de la 2ᵉ question devient valide |
| 2 | **C2** | « Posez si **B2A**=9999 » (code inexistant) | « Posez si **C2A**=9999 » |
| 3 | **Formule EMPLOYÉ** | `EMPLOYÉ = 1 si D1=1 ou D2=1 ou (D3=1 et D3A=1)` (référence aux questions ménage) | `EMPLOYÉ = 1 si E1=1 ou E2=1 ou (E3=1 et E3A=1)` |
| 4 | **NON EMPLOYÉ** | Jamais défini (alors que des filtres l'utilisent) | `NON EMPLOYÉ = 1 − EMPLOYÉ` |
| 5 | **H5** | « combien avez-vous personnellement gagné **ou retiré**… après déduction des dépenses **de base** » (confond profit et prélèvement) | Reformulé en profit net (une seule question, voir bloc H) |
| 6 | **J1** | Force une démarche → impossible de distinguer chômage et inactivité | Ajout de la modalité « Aucune démarche entreprise » |
| 7 | **N1** | « si Non, passer à **L6A** » (code inexistant) | « si Non, passer à **N6A** » |
| 8 | **Bloc « Code O2 »** | Bloc orphelin de 16 modalités réutilisant le code `O2` (déjà pris) | Supprimé |
| 9 | **R1A / R2A / R3A / R3B** | Filtres « Posez si **P1**=2 / **P2**=1 / **P3**=1 / **P3A**=2 » (renvois au bloc P) | « Posez si **R1**=2 / **R2**=1 / **R3**=1 / **R3A**=2 » |

> Observations laissées **inchangées** (hors périmètre « bugs ») : `B5` (milieu de résidence) ne
> comporte pas de modalités explicites ; la numérotation saute `C5` et utilise `IGA6`/`IGA7` au lieu
> de `K6`/`K7`. Aucune de ces remarques ne fausse les données — à arbitrer séparément si souhaité.

---

## GESTION DES TENTATIVES D'APPEL

À tout moment durant cette enquête, si le répondant raccroche, s'absente, ou si l'appel est interrompu, essayez de le rappeler une fois. Si vous n'arrivez pas à reparler au répondant, inscrivez « Répondant a raccroché » ou « -95 » dans tous les champs suivants qui apparaissent. Finalisez et soumettez le formulaire. Effectuez la deuxième et la troisième tentative pour joindre ce répondant conformément aux protocoles établis.

| Code | Question | Modalités / Réponses |
|---|---|---|
| A1 | Numéro de la tentative d'appel en cours | 1. Première tentative · 2. Deuxième tentative · 3. Troisième tentative ou plus |
| A2 | Date de l'appel | Jour / Mois / Année |
| A3 | Heure de l'appel | Heure / Minute |
| A4 | Résultat de cette tentative d'appel | 1. Entretien réalisé (compléter le questionnaire) · 2. Pas de réponse · 3. Numéro invalide ou incorrect · 4. Ligne occupée · 5. Rendez-vous fixé pour un rappel · 6. Le répondant a refusé de participer · 7. Le répondant a raccroché / appel interrompu en cours d'entretien · 8. Autre (préciser) |
| A5 | Posez si A4=5 ou A4=7. Indiquez la date et l'heure prévues pour la prochaine tentative | Date / Heure |

## IDENTIFICATION ET CONSENTEMENT

| Code | Question | Modalités / Réponses |
|---|---|---|
| B1 | District | |
| B2 | Région | |
| B3 | Département | |
| B4 | Sous-préfecture / Commune | |
| B5 | Milieu de résidence | |
| B6 | Bonjour, je m'appelle ______ et je vous appelle dans le cadre d'une étude sur la situation des jeunes candidats au Programme Jeunesse COSO. Suis-je bien en train de parler à {nom de la personne} ? | 1. Oui · 2. Non |
| B6A | Posez si B6=2. Puis-je parler à {nom de la personne} ? | 1. Oui · 2. Non |
| B6B | Posez si B6A=2. Ce n'est peut-être pas le bon moment pour parler à {nom de la personne}. Puis-je rappeler à un moment qui lui conviendrait mieux ? | 1. Oui → B6C · 2. Non → Fin de l'entretien |
| B6C | Posez si B6B=1. Veuillez indiquer la date et l'heure souhaitées pour le rappel | Date / Heure |
| B6D | Posez si B6=1 ou B6A=1. [Nom de l'organisation], en partenariat avec la Banque Mondiale, mène une étude pour mieux comprendre les résultats sur le marché du travail et les aspirations des jeunes ayant également postulé au Programme Jeunesse COSO, afin de nous aider à améliorer le programme. Comme vous êtes l'un(e) des candidat(e)s, nous vous contactons pour vous poser quelques questions et mieux comprendre votre situation. Nous allons enregistrer cet appel pour suivre notre performance et améliorer la conception de l'enquête. Vos réponses resteront confidentielles et anonymes, et ne seront utilisées que dans le cadre de cette enquête. Votre participation est volontaire : en répondant à ces questions, vous consentez à participer à cette étude. Si une question ne vous convient pas, vous n'êtes pas obligé(e) d'y répondre. Vous pouvez également arrêter à tout moment si vous ne souhaitez pas continuer l'enquête. Elle durera environ 30 minutes. Acceptez-vous de répondre aux questions suivantes ? | 1. Oui · 2. Non |
| B6E | Posez si B6D=2. Ce n'est peut-être pas le bon moment. Puis-je rappeler à un moment qui vous conviendrait mieux ? | 1. Oui → B6F · 2. Non → Fin de l'entretien |
| B6F | Posez si B6E=1. Veuillez indiquer la date et l'heure souhaitées pour le rappel | Date / Heure |
| B7 | Veuillez donner votre nom complet svp | |

## PROFIL SOCIODEMOGRAPHIQUE

| Code | Question | Modalités / Réponses |
|---|---|---|
| C1 | Quel est votre sexe ? | Homme · Femme |
| C2A | Quel est votre date de naissance ? (Inscrire 9999 si ne sait pas) | Jour, mois, année |
| C2 | Posez si C2A=9999. Quel âge avez-vous révolu ? | Âge en années |
| C3 | Quel est votre statut matrimonial actuel ? | Célibataire · Marié(e) · Union libre/Concubinage · Divorcé(e) · Veuf(ve) |
| C4 | Quel est le niveau d'études le plus élevé que vous avez atteint ? | 0. Aucun niveau · 1. Préscolaire · 2. Primaire · 3. Secondaire général cycle I · 4. Secondaire technique/professionnel cycle I · 5. Secondaire général cycle II · 6. Secondaire technique/professionnel cycle II · 7. Supérieur cycle court (BAC+1; BP; BTS1; BAC+2; BTS2; DUT) · 8. Licence · 9. Maitrise/Master 1 · 10. Master 2/DEA/DESS · 11. Doctorat · 12. Post Doctorat · 13. Autre (préciser) |
| C6 | Posez si C4=0. Savez-vous lire et écrire dans au moins une langue ? | Oui · Non |
| C7 | Au cours des douze derniers mois, avez-vous effectué un déplacement d'une localité/pays à une autre localité/pays pour vous y installer ? | Oui · Non |
| C8 | Posez si C7=1. Indiquez la localité/pays de départ | |
| C9 | Posez si C7=1. Indiquez la localité/pays d'installation | |

## MENAGE

| Code | Question | Modalités / Réponses |
|---|---|---|
| D1 | Combien de personnes vivent habituellement dans votre ménage ? | Nombre |
| D2 | Combien ont moins de 15 ans ? | Nombre |
| D3 | Quel est votre lien de parenté avec le chef de ménage ? | Chef de ménage · Conjoint du CM · Enfant du CM · Autre parent du CM · Sans lien de parenté avec le CM · Amis du CM · Autre à préciser |
| D4 | Combien de personnes du ménage exercent une activité rémunérée ? | Nombre |
| D5 | Parmi les biens suivants, lesquels sont possédés par votre ménage et qui sont fonctionnels ? | Télévision · Téléphone portable · Moto · Vélo · Brouette · Réfrigérateur/congélateur · Ordinateur · Radio · Ventilateur |

## STATUT D'ACTIVITE

| Code | Question | Modalités / Réponses |
|---|---|---|
| E1 | Au cours des 7 derniers jours, avez-vous travaillé en échange d'un salaire, traitement, profit, commission, pourboire ou autre rémunération, en espèce ou en nature, même si cela n'a duré qu'une heure ? | 1. Oui → EMPLOYÉ · 2. Non |
| E2 | Posez si E1=2. Disposez-vous d'un emploi ou d'une entreprise dont vous êtes temporairement absent(e) (congé, maladie, basse saison) et auquel/à laquelle vous comptez retourner ? | 1. Oui → EMPLOYÉ · 2. Non |
| E3 | Posez si E1=2 et E2=2. Avez-vous aidé, sans rémunération directe, dans une entreprise ou une exploitation familiale (champ, boutique, atelier) ? | 1. Oui · 2. Non |
| E3A | Posez si E3=1. Les produits ou services de cette activité sont-ils destinés principalement à la vente, ou principalement à l'usage du ménage ? | 1. Principalement à la vente → EMPLOYÉ · 2. Principalement à l'usage du ménage |

**Variables dérivées :**

```text
EMPLOYÉ = 1 si E1=1 ou E2=1 ou (E3=1 et E3A=1)
NON EMPLOYÉ = 1 − EMPLOYÉ
```

## EMPLOI PRINCIPAL (Posez si EMPLOYÉ)

| Code | Question | Modalités / Réponses |
|---|---|---|
| F1 | Quel est votre statut dans cet emploi ? | 1. Salarié · 2. Employeur (avec employés) · 3. Travailleur indépendant/à compte propre (sans employés) · 4. Membre d'une coopérative de producteurs · 5. Travailleur familial non rémunéré · 6. Apprenti/stagiaire · 7. Autre |
| F2 | Quel est le secteur de votre activité principale ? [ENQUÊTEUR : lire toutes les options] | 1. Agriculture, élevage, pêche, sylviculture · 2. Industries extractives · 3. Industrie manufacturière · 4. Construction/BTP · 5. Commerce de gros ou de détail · 6. Transport, entreposage, logistique · 7. Hébergement et restauration · 8. Information, communication, services numériques · 9. Activités financières et d'assurance · 10. Administration publique · 11. Éducation · 12. Santé humaine et action sociale · 13. Travail domestique chez un particulier · 14. Autres services (réparation, services personnels, arts/spectacles) · 15. Autre (préciser) |
| F3 | Où exercez-vous principalement ce travail ? | 1. À domicile · 2. Dans une structure attenante/proche du domicile · 3. Au domicile de l'employeur · 4. Lieu fixe hors domicile, en intérieur (bureau, magasin, usine) · 5. Étal/emplacement fixe dans un espace public (stand de marché, kiosque, emplacement de vente autorisé) · 6. Chantier de construction · 7. Champ/exploitation agricole · 8. Mobile/sans emplacement fixe (vente itinérante, porte-à-porte) · 9. Autre (préciser) |
| F4 | Depuis combien de temps travaillez-vous dans cet emploi/cette activité, sans interruption ? | 1. Moins de 6 mois · 2. 6 mois à moins d'1 an · 3. 1 an à moins de 2 ans · 4. 2 ans à moins de 5 ans · 5. 5 ans ou plus |

## QUALITE DE L'EMPLOI (Posez si EMPLOYÉ)

| Code | Question | Modalités / Réponses |
|---|---|---|
| G1 | Disposez-vous d'un contrat de travail ? | 1. Oui, à durée indéterminée (CDI) · 2. Oui, à durée déterminée (CDD) · 3. Accord verbal seulement · 4. Aucun accord |
| G2 | Bénéficiez-vous d'une couverture sociale liée à cet emploi ? | 1. Oui · 2. Non |
| G3 | Combien d'heures avez-vous travaillé dans cet emploi principal la semaine dernière ? | [saisie numérique] |
| G4 | Est-ce le nombre d'heures que vous travaillez habituellement dans cet emploi ? | 1. Oui · 2. Non |
| G5 | Avez-vous un autre emploi ou une autre activité génératrice de revenus en plus de celui-ci ? | 1. Oui · 2. Non |
| G6 | Posez si G5=1. Combien d'heures par semaine consacrez-vous à cet/ces autre(s) emploi(s)/activité(s) ? | [saisie numérique] |
| G7 | En tenant compte de tout votre travail — cet emploi et tout autre — souhaiteriez-vous travailler davantage d'heures si l'occasion se présentait ? | 1. Oui · 2. Non |

## REVENU ET CARACTERISTIQUES DE L'ENTREPRISE (Posez si EMPLOYÉ)

| Code | Question | Modalités / Réponses |
|---|---|---|
| H1 | Posez si F1=Salarié. Comment êtes-vous payé pour cet emploi ? | 1. En espèces uniquement · 2. En nature uniquement · 3. Les deux |
| H2 | Posez si F1=Salarié. À quelle fréquence êtes-vous payé ? | 1. Quotidienne · 2. Hebdomadaire · 3. Toutes les deux semaines · 4. Mensuelle · 5. Irrégulière |
| H3 | Posez si F1=Salarié. Quel a été votre salaire net (valeur en espèces, incluant tout paiement en nature) pour votre dernière période de paie ? | [montant FCFA] |
| H4 | Posez si F1=Employeur, Travailleur indépendant, ou Membre de coopérative. Cette activité/entreprise est-elle enregistrée (par exemple auprès des impôts, du registre de commerce, ou des autorités locales) ? | 1. Oui · 2. Non · 3. Ne sait pas |
| H4A | Posez si F1=Employeur ou Travailleur indépendant. Combien de travailleurs rémunérés avez-vous actuellement, sans vous compter vous-même ? | [saisie numérique] |
| H5 | Posez si F1=Employeur, Travailleur indépendant, ou Membre de coopérative. Quel a été le profit net de cette activité le mois dernier, c'est-à-dire après avoir payé toutes les dépenses de l'activité, mais avant de prélever de l'argent pour vous-même ou votre ménage ? Donnez simplement votre meilleure estimation. | [montant FCFA] |

## RECHERCHE D'UN AUTRE EMPLOI – EN EMPLOI (Posez si EMPLOYÉ)

| Code | Question | Modalités / Réponses |
|---|---|---|
| I1 | Bien que vous travailliez actuellement, recherchez-vous activement un autre emploi ou une autre activité ? | 1. Oui · 2. Non |
| I2 | Posez si I1=1. Quelle est la principale raison ? | 1. Revenu insuffisant dans l'emploi actuel · 2. Emploi actuel instable/temporaire · 3. Je veux un emploi qui correspond mieux à mes compétences · 4. Je veux simplement un meilleur emploi · 5. Autre |
| I3 | Posez si I1=1. Qu'avez-vous fait principalement pour chercher cet autre emploi ? | 1. Candidature spontanée auprès d'employeurs · 2. Réponse à une offre d'emploi (en ligne, journal, affiche) · 3. Inscription auprès d'une agence (Agence Emploi Jeunes, etc.) · 4. Réseau personnel (famille, amis) · 5. Concours/test pour le secteur public · 6. Démarches pour créer sa propre entreprise · 7. Autre |

## CHOMAGE – DUREE ET RECHERCHE D'EMPLOI (Posez si NON EMPLOYÉ)

| Code | Question | Modalités / Réponses |
|---|---|---|
| J1 | Posez si NON EMPLOYÉ. Qu'avez-vous fait principalement au cours des 30 derniers jours pour trouver un emploi ou démarrer une entreprise ? | 1. Candidature spontanée auprès d'employeurs · 2. Réponse à une offre d'emploi (en ligne, journal, affiche) · 3. Inscription auprès d'une agence (Agence Emploi Jeunes, etc.) · 4. Réseau personnel (famille, amis) · 5. Concours/test pour le secteur public · 6. Démarches pour créer sa propre entreprise · 7. Autre · 8. Aucune démarche entreprise au cours des 30 derniers jours |
| J2 | Depuis combien de temps êtes-vous sans emploi et en recherche ? | 1. Moins d'1 mois · 2. 1 mois à moins de 3 mois · 3. 3 mois à moins de 6 mois · 4. 6 mois à moins de 12 mois · 5. 1 an à moins de 2 ans · 6. 2 ans ou plus |
| J3 | Si vous aviez trouvé un emploi la semaine dernière, auriez-vous pu commencer dans les deux semaines suivantes ? | 1. Oui · 2. Non |

## ENTREPRENEURIAT (IGA)

| Code | Question | Modalités / Réponses |
|---|---|---|
| K1 | Avez-vous personnellement déjà créé votre propre activité génératrice de revenus, entreprise ou affaire — qu'elle soit toujours active, qu'elle ait fermé depuis, ou qu'il s'agisse de votre emploi actuel ? | 1. Oui · 2. Non |
| K2 | Posez si K1=2. Souhaiteriez-vous créer votre propre activité génératrice de revenus ou entreprise à l'avenir ? | 1. Oui · 2. Non |
| K3 | Posez si K1=1. Quelle a été la principale source d'argent utilisée pour démarrer cette activité ? | 1. Épargne personnelle · 2. Aide familiale · 3. Microfinance/coopérative d'épargne (COOPEC) · 4. Programme gouvernemental (AGR/Agence Emploi Jeunes) · 5. Prêt bancaire · 6. ONG/organisation humanitaire · 7. Autre |
| K4 | Posez si K1=2 et K2=1. Quelle serait selon vous votre principale source de financement si vous deviez créer cette activité ? | 1. Épargne personnelle · 2. Aide familiale · 3. Microfinance/COOPEC · 4. Programme gouvernemental (AGR/Agence Emploi Jeunes) · 5. Prêt bancaire · 6. ONG/organisation humanitaire · 7. Autre · 8. Ne sait pas |
| K5 | Posez si K1=2 et K2=1. Quelles sont les principales raisons pour lesquelles vous n'avez pas encore créé cette activité ? (Plusieurs réponses possibles) | 1. Manque de capital/financement · 2. Manque de compétences/savoir-faire entrepreneurial · 3. Manque d'équipement ou de local · 4. Manque de marché/demande pour cette idée · 5. Obligations/responsabilités familiales · 6. Peur de l'échec/du risque · 7. Obstacles administratifs/juridiques (permis, enregistrement) · 8. Autre |
| IGA6 | Avez-vous déjà reçu une formation spécifiquement en entrepreneuriat ou en gestion d'entreprise (distincte d'une formation technique/professionnelle) ? | 1. Oui · 2. Non |
| IGA7 | Comment évaluez-vous vos propres compétences pour gérer une activité génératrice de revenus (par exemple : tenue de comptes de base, fixation des prix, gestion de la clientèle) ? | 1. Très faibles · 2. Faibles · 3. Moyennes · 4. Bonnes · 5. Très bonnes |

## INCLUSION FINANCIERE & EPARGNE

| Code | Question | Modalités / Réponses |
|---|---|---|
| L1 | Possédez-vous un compte Mobile Money ? | 1. Oui · 2. Non |
| L2 | Possédez-vous un compte bancaire ? | 1. Oui · 2. Non |
| L3 | Mettez-vous régulièrement de l'argent de côté (épargne) ? | 1. Oui, régulièrement · 2. Oui, occasionnellement · 3. Non, jamais |
| L4 | Posez si L3=1 ou 2. Environ combien mettez-vous de côté dans un mois typique ? | Montant FCFA / Ne sait pas, ça varie |
| L5 | Posez si L3=1 ou 2. Où conservez-vous principalement votre épargne ? | 1. Domicile (cash) · 2. Tontine/AVEC · 3. Compte bancaire · 4. Mobile money · 5. Autre |
| L6 | Avez-vous actuellement un prêt ou une dette en cours — auprès d'une banque, une institution de microfinance, un crédit mobile money, une tontine/AVEC, la famille/des amis, ou toute autre personne ? | 1. Oui · 2. Non |
| L7 | Posez si L6=1. Quelle est la principale source de ce prêt/cette dette ? | 1. Banque · 2. Institution de microfinance/COOPEC · 3. Crédit mobile money · 4. Tontine/AVEC · 5. Famille ou amis · 6. Employeur · 7. Prêteur informel · 8. Autre |
| L8 | Posez si L6=1. Environ combien devez-vous au total actuellement ? | Montant FCFA / Ne sait pas |
| L9 | Posez si L6=1. Quel était le principal motif de ce prêt ? | 1. Démarrer ou développer une activité · 2. Couvrir des besoins quotidiens/du ménage · 3. Éducation/frais de scolarité · 4. Santé/dépenses médicales · 5. Logement · 6. Autre |

## CHANGEMENT DE STATUT

| Code | Question | Modalités / Réponses |
|---|---|---|
| M1 | Comment décririez-vous votre rôle économique actuel ? | 1. Je dépends principalement de l'aide d'autrui · 2. Je suis en transition · 3. Je suis autonome et je produis ma propre valeur |
| M2 | Au cours des 12 derniers mois, avez-vous reçu une aide financière ou matérielle externe (famille, ONG, État) pour couvrir vos besoins de base ? | 1. Oui, régulièrement · 2. Oui, ponctuellement · 3. Non, jamais |
| M3 | Votre entourage (famille, communauté) vous perçoit comme une personne qui contribue économiquement ? | 1. Pas du tout d'accord · 2. Plutôt pas d'accord · 3. Neutre · 4. Plutôt d'accord · 5. Tout à fait d'accord |
| M4 | Si vous deviez vous projeter dans 12 mois, vous voyez-vous plutôt comme producteur autonome de valeur ou comme dépendant d'une aide extérieure ? | 1. Producteur autonome · 2. Entre les deux · 3. Dépendant d'une aide · 4. Ne sait pas |

## RESILIENCE FACE AUX CHOCS

| Code | Question | Modalités / Réponses |
|---|---|---|
| N1 | Au cours des 12 derniers mois, votre ménage a-t-il été affecté par un choc économique/problème ou autre (maladie, mauvaise récolte, perte d'emploi, catastrophe, etc.) ? | Oui · Non → si Non, passer à N6A |
| N2 | Posez si N1=1. Quel a été le choc/problème le plus important subi ? | Maladie/accident · Choc climatique (sécheresse, inondation) · Perte d'activité/emploi · Décès d'un membre du ménage · Hausse des prix · Autre (préciser) |
| N3 | Posez si N1=1. Quel a été l'impact/la conséquence de ce choc sur votre revenu ou votre activité ? | Aucun impact · Impact limité, vite surmonté · Impact important, encore en cours de redressement · Impact très important, activité arrêtée ou fortement réduite |
| N4 | Posez si N1=1. Comment avez-vous principalement fait face à ce choc/problème ? | Épargne personnelle · Vente d'actifs/biens · Emprunt/crédit · Aide familiale ou communautaire · Aide externe (ONG, État) · Réduction de la consommation · Autre |
| N5 | Posez si N1=1. Combien de temps a-t-il fallu pour que votre activité ou votre revenu revienne à son niveau d'avant le choc ? | Moins d'1 mois · 1 à 3 mois · 3 à 6 mois · Plus de 6 mois · Pas encore rétabli |
| N6A | Si vous deviez couvrir une dépense imprévue de 250 000 FCFA demain, seriez-vous en mesure de réunir cette somme sans vous endetter lourdement ni vendre un bien essentiel ? | Oui, facilement · Oui, avec difficulté · Non, pas du tout |
| N7 | Globalement, sur une échelle de 1 à 10, comment évaluez-vous votre capacité actuelle à résister à un choc économique ? | Échelle numérique 1 (très faible) à 10 (très élevée) |

## EXPERIENCE PROFESSIONNELLE ET FORMATIONS

| Code | Question | Modalités / Réponses |
|---|---|---|
| O1 | En dehors de votre activité principale actuelle, avez-vous déjà eu un autre emploi ou une autre activité génératrice de revenus auparavant ? | 1. Oui · 2. Non |
| O2 | Posez si O1=1. À quel âge avez-vous commencé votre tout premier emploi ou votre toute première activité génératrice de revenus ? | [saisie numérique, âge] |
| O3 | Avez-vous suivi une formation professionnelle ou technique, ou un apprentissage (formel ou informel), au cours des 12 derniers mois ? | 1. Oui · 2. Non |
| O4 | Posez si O3=1. Dans quel métier ou domaine portait cette formation ? | [texte libre] |
| O5 | Posez si O3=1. Qui a principalement dispensé cette formation ? | 1. École/centre de formation professionnelle formel · 2. Employeur/entreprise privée · 3. Programme gouvernemental (ex. Agence Emploi Jeunes) · 4. ONG/programme d'alphabétisation ou de compétences de vie · 5. Apprentissage informel (famille/membre de la communauté) · 6. Apprentissage sur le tas/au travail · 7. Autre |
| O6 | Posez si O3=1. Dans quelle mesure cette formation vous a-t-elle été utile pour trouver un emploi ou améliorer vos revenus ? | 1. Pas utile · 2. Plutôt utile · 3. Très utile |

## ASPIRATIONS PROFESSIONNELLES

| Code | Question | Modalités / Réponses |
|---|---|---|
| P1 | Quel métier ou activité souhaiteriez-vous exercer dans les cinq prochaines années ? | Texte |
| P2 | Souhaitez-vous principalement trouver un emploi salarié, créer une entreprise ou développer une activité existante ? | Trouver un emploi salarié · Créer une entreprise · Développer une activité existante |
| P3 | Quel revenu mensuel souhaiteriez-vous atteindre ? | Montant FCFA |
| P4 | Quel secteur d'activité vous intéresse le plus ? | 1. Agriculture, élevage, pêche, sylviculture · 2. Industries extractives · 3. Industrie manufacturière · 4. Construction/BTP · 5. Commerce de gros ou de détail · 6. Transport, entreposage, logistique · 7. Hébergement et restauration · 8. Information, communication, services numériques · 9. Activités financières et d'assurance · 10. Administration publique · 11. Éducation · 12. Santé humaine et action sociale · 13. Travail domestique chez un particulier · 14. Autres services (réparation, services personnels, arts/spectacles) · 15. Autre (préciser) |
| P5 | Quel est selon vous le principal obstacle à la réalisation de vos objectifs professionnels ? | Texte |

## COHESION SOCIALE ET ENGAGEMENT

Je vais maintenant vous poser quelques questions sur votre vie sociale et communautaire — vos relations avec les autres, votre participation à des groupes, et votre niveau de confiance envers différentes personnes. Il n'y a pas de bonne ou de mauvaise réponse, je veux simplement connaître votre expérience personnelle.

| Code | Question | Modalités / Réponses |
|---|---|---|
| Q1 | Êtes-vous actuellement membre d'une association, coopérative, club ou groupe communautaire ? Il peut s'agir d'une équipe de sport, d'une communauté religieuse, d'un club ou d'une association pour les jeunes, d'un réseau professionnel ou d'anciens élèves, d'un groupe communautaire en ligne (WhatsApp, réseaux sociaux), d'une association humanitaire ou artistique, ou d'un syndicat. | Oui · Non |
| Q2 | Au cours des 30 derniers jours, combien de fois avez-vous donné de votre temps libre pour une activité d'intérêt général, comme un nettoyage, une collecte de fonds, ou l'organisation d'un événement ? | |
| Q3 | De manière générale, diriez-vous qu'on peut faire confiance à la plupart des gens, ou qu'il faut être très prudent dans ses relations avec les autres ? | 1. On peut faire confiance à la plupart des gens · 2. Il faut être prudent |
| Q4 | Dans quelle mesure faites-vous confiance aux jeunes d'origine différente de la vôtre (région, religion ou ethnie différente) ? | 1. Pas du tout confiance · 2. Juste un peu confiance · 3. Partiellement confiance · 4. Beaucoup confiance · 9. Ne sait pas |
| Q5 | Dans quelle mesure faites-vous confiance à la police pour agir dans votre intérêt ? | 1. Pas du tout confiance · 2. Juste un peu confiance · 3. Partiellement confiance · 4. Beaucoup confiance · 9. Ne sait pas |
| Q6 | Dans quelle mesure faites-vous confiance aux forces armées de Côte d'Ivoire pour agir dans votre intérêt ? | 1. Pas du tout confiance · 2. Juste un peu confiance · 3. Partiellement confiance · 4. Beaucoup confiance · 9. Ne sait pas |
| Q7 | Dans quelle mesure faites-vous confiance aux chefs traditionnels pour agir dans votre intérêt ? | 1. Pas du tout confiance · 2. Juste un peu confiance · 3. Partiellement confiance · 4. Beaucoup confiance · 9. Ne sait pas |
| Q8 | Dans quelle mesure faites-vous confiance aux chefs religieux pour agir dans votre intérêt ? | 1. Pas du tout confiance · 2. Juste un peu confiance · 3. Partiellement confiance · 4. Beaucoup confiance · 9. Ne sait pas |
| Q9 | Dans quelle mesure faites-vous confiance aux autorités gouvernementales locales (par exemple préfecture, sous-préfecture) pour agir dans votre intérêt ? | 1. Pas du tout confiance · 2. Juste un peu confiance · 3. Partiellement confiance · 4. Beaucoup confiance · 9. Ne sait pas |
| Q10 | Dans quelle mesure faites-vous confiance aux autorités gouvernementales centrales pour agir dans votre intérêt ? | 1. Pas du tout confiance · 2. Juste un peu confiance · 3. Partiellement confiance · 4. Beaucoup confiance · 9. Ne sait pas |

## SUIVI PANEL

| Code | Question | Modalités / Réponses |
|---|---|---|
| R1 | Est-ce que le numéro avec lequel nous vous avons joint aujourd'hui est le meilleur moyen de vous contacter pour les prochaines vagues de cette étude ? | 1. Oui · 2. Non |
| R1A | Posez si R1=2. Quel est le meilleur numéro pour vous contacter à l'avenir ? | [saisie numérique] |
| R2 | Avez-vous un autre numéro que nous pourrions essayer si celui-ci ne fonctionne pas ? | 1. Oui · 2. Non |
| R2A | Posez si R2=1. Quel est ce numéro ? | [saisie numérique] |
| R3 | Utilisez-vous WhatsApp ? | 1. Oui · 2. Non |
| R3A | Posez si R3=1. Ce compte WhatsApp est-il lié au même numéro que nous utiliserons pour vous contacter à l'avenir ? | 1. Oui · 2. Non |
| R3B | Posez si R3A=2. Quel numéro est lié à votre compte WhatsApp ? | [saisie numérique] |
| R4 | Pouvez-vous fournir le contact d'une personne pouvant vous joindre facilement, au cas où nous n'arriverions pas à vous contacter directement ? | Nom et téléphone |
| R5 | Acceptez-vous d'être recontacté(e) pour les prochaines vagues de cette étude ? | 1. Oui · 2. Non |
