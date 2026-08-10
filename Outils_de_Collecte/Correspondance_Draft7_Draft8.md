# Tableau de correspondance — Questionnaire COSO Draft 7 ↔ Draft 8

**Objet :** correspondance item par item entre le `Questionnaire_COSO_Draft_7` (version officielle
courante) et le `Questionnaire_COSO_Draft_8_Proposition` (réécriture méthodologique).
**Date :** 27 juin 2026
**Statut :** document de travail. Le Draft 8 ne remplace pas le Draft 7 ; ce tableau sert à arbitrer
le passage de l'un à l'autre en toute traçabilité.

## Légende des statuts

| Statut | Signification |
|---|---|
| `INCHANGÉ` | Item conservé à l'identique (libellé et logique équivalents) |
| `MODIFIÉ` | Item conservé mais reformulé, borné ou recodé |
| `CORRIGÉ` | Item dont le Draft 7 contenait une **erreur technique** réparée par le Draft 8 |
| `DÉPLACÉ` | Même contenu, code/section différents dans le Draft 8 |
| `AJOUTÉ` | Nouvel item ou module présent uniquement dans le Draft 8 |
| `SUPPRIMÉ` | Item du Draft 7 absent du Draft 8 (généralement fusionné ailleurs) |

---

## A. Gestion des appels

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| A1 | Numéro de tentative (1ère/2e/3e) | A1 | MODIFIÉ | Passe à un entier 1–10 |
| A2 | Date de l'appel | A2 | INCHANGÉ | Date automatique |
| A3 | Heure de l'appel | A3 | MODIFIÉ | Heure de début automatique |
| A4 | Résultat de la tentative (8 modalités) | A4 | MODIFIÉ | 9 modalités, ajout « indisponible durablement », distinction injoignable/mauvais numéro |
| A5 | Date/heure de rappel | A5 | INCHANGÉ | |
| — | — | A6 | AJOUTÉ | Heure de fin → permet de calculer la durée d'entretien |

## B. Localisation, identité et consentement

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| B1–B4 | District / Région / Département / Sous-préfecture | B1–B4 | INCHANGÉ | Préchargés, à confirmer |
| B5 | Milieu de résidence (sans modalités) | B5 | CORRIGÉ | Modalités ajoutées : 1=Urbain / 2=Rural |
| B6 | Salutation + identification du répondant | B6 | MODIFIÉ | Recentré sur l'identification |
| B6B (1er) | « Puis-je parler à la personne ? » | B6A | CORRIGÉ | **Doublon B6B** dans le Draft 7 |
| B6B (2e) | « Puis-je rappeler ? » | B6B | CORRIGÉ | **Doublon B6B** dans le Draft 7 |
| B6C | Date/heure de rappel | B6C | INCHANGÉ | |
| B6D | Consentement (bloc fusionné) | B7 + B8 | DÉPLACÉ | Scindé : B7 consentement à l'étude, B8 consentement à l'enregistrement |
| B6E / B6F | Rappel après refus | — | SUPPRIMÉ | Fonction couverte par A5 / B6C |
| B7 | Nom complet | B9 + B10 | MODIFIÉ | B9 identifiant préchargé non modifiable, B10 nom dans table de contacts séparée |

## C. Profil sociodémographique

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| C1 | Sexe (Homme / Femme) | C1 | MODIFIÉ | Ajout « Autre » et « Préfère ne pas répondre » |
| C2A | Date de naissance (« 9999 si NSP ») | C2 | CORRIGÉ | Codes NSP harmonisés, plus de « 9999 » |
| C2 | Âge « Posez si **B2A**=9999 » | C2A | CORRIGÉ | **Renvoi cassé à B2A** ; D8 : « si année inconnue à C2 », borne 15–40 |
| C3 | Statut matrimonial | C3 | INCHANGÉ | |
| C4 | Niveau d'études (14 modalités) | C4 | MODIFIÉ | Simplifié à 8 modalités (arbitrage durée) |
| C6 | Alphabétisation (si C4=0) | C5 | MODIFIÉ | Posée à tous, échelle 3 niveaux (lecture fonctionnelle) |
| C7 / C8 / C9 | Migration (oui/non + origine + destination) | C6 / C6A | DÉPLACÉ | Fusionné en C6 + C6A |
| — | — | WG1–WG6 | AJOUTÉ | **Washington Group Short Set** (handicap) |

## D. Ménage et actifs

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| D1 | Taille du ménage | D1 | INCHANGÉ | |
| D2 | Membres < 15 ans | D2 | INCHANGÉ | |
| D3 | Lien avec le chef de ménage | D3 | INCHANGÉ | |
| D4 | Membres exerçant une activité rémunérée | D4 | INCHANGÉ | |
| D5 | Biens du ménage (9 items) | D5 | MODIFIÉ | Liste révisée |
| — | — | D6 | AJOUTÉ | Cheptel (bovins/ovins/volailles/porcins) |
| — | — | D7 / D7A | AJOUTÉ | Terres agricoles + superficie |
| — | — | D8 / D9 / D10 | AJOUTÉ | Murs / éclairage / eau de boisson (indice de richesse) |

## E. Statut d'activité

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| E1–E3A | Travail 7 jours / absence / aide familiale / destination | E1–E3A | INCHANGÉ | Libellés équivalents |
| `EMPLOYÉ = D1\|\|D2\|\|(D3&&D3A)` | Variable dérivée employé | `EMPLOYÉ = E1\|E2\|(E3&E3A)` | CORRIGÉ | **Bug majeur** : le D7 référence D1/D2/D3 (questions ménage) au lieu de E1/E2/E3 |
| (non défini) | NON EMPLOYÉ | `NON_EMPLOYÉ = 1-EMPLOYÉ` | CORRIGÉ | **NON EMPLOYÉ jamais défini** dans le Draft 7 |

## F. Emploi principal

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| F1 | Statut dans l'emploi | F1 | INCHANGÉ | |
| — | — | F2 + F2C | AJOUTÉ | Métier (texte) + code métier — absent du Draft 7 |
| F2 | Secteur d'activité | F3 | DÉPLACÉ | Renuméroté |
| F3 | Lieu d'exercice | F4 | DÉPLACÉ | Renuméroté |
| F4 | Ancienneté (catégories) | F5 | MODIFIÉ | MM/AAAA, durée dérivée en continu |

## G. Qualité de l'emploi et temps de travail

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| G1 / G2 | Contrat / couverture sociale | G1 / G2 | INCHANGÉ | |
| G3 | Heures travaillées (sans borne) | G3 | MODIFIÉ | Borné 0–112, confirmation > 84 |
| G4 | Heures habituelles ? | G4 + G4A | MODIFIÉ | G4A capture les heures habituelles si G4=2 |
| G5 / G6 | Autre emploi / heures | G5 / G6 | MODIFIÉ | Contrôle de cohérence G3+G6 |
| G7 | Souhait de travailler plus | G7 | INCHANGÉ | |
| — | — | G8 | AJOUTÉ | Disponibilité (2 semaines) → sous-emploi au sens BIT |

## H. Revenu et caractéristiques de l'entreprise

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| H1 / H2 / H3 | Mode / fréquence / salaire | H1 / H2 / H3 | MODIFIÉ | Recentré sur les montants (30 derniers jours) |
| H4 / H4A | Enregistrement / nombre de salariés | H4 / H4A | INCHANGÉ | |
| H5 | « gagné ou retiré… après dépenses de base » | PR1–PR9 | CORRIGÉ | **H5 mélange profit et retrait** ; D8 : module profit de Mel–McKenzie–Woodruff (profit net, pertes, mois normal/bon/mauvais, CA, autoconsommation, actifs, registre) |

## I. Recherche d'un autre emploi (personnes employées)

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| I1 / I2 / I3 | Recherche / raison / démarche | I1 / I2 / I3 | INCHANGÉ | |

## J. Chômage / recherche d'emploi (personnes non employées)

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| (absent) | Filtre « a entrepris une démarche ? » | J0 | AJOUTÉ | Permet de séparer **chômeur** (cherche) et **inactif** (ne cherche pas) |
| J1 | Démarche (forcée) | J1 | CORRIGÉ | Conditionnée à J0=1 ; le D7 forçait une démarche |
| J2 | Durée de recherche | J2 | INCHANGÉ | |
| J3 | Disponibilité (2 semaines) | J3 | INCHANGÉ | |
| — | — | J4 | AJOUTÉ | Raison de non-recherche (découragé, études, soins…) |

## K. Entrepreneuriat

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| K1–K5 | Création / intention / financement / obstacles | K1–K5 | INCHANGÉ | |
| IGA6 | Formation en entrepreneuriat | K6 | DÉPLACÉ | Code harmonisé |
| IGA7 | Auto-évaluation de gestion | K7 | DÉPLACÉ | Code harmonisé |

## L. Inclusion financière et épargne

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| L1–L9 | Comptes / épargne / dette | L1–L9 | INCHANGÉ | L4 : période précisée (30 derniers jours) |

## M. Statut productif perçu

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| M1–M4 | Rôle économique / aide reçue / perception / projection | M1–M4 | INCHANGÉ | |
| — | — | PSY1–PSY4 | AJOUTÉ | Auto-efficacité et espoir (échelle validée) |

## N. Résilience, chocs et sécurité alimentaire

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| N1 | Choc subi (« si Non → **L6A** ») | N1 | CORRIGÉ | **Saut cassé vers L6A** ; D8 : « 2=Non → N6 » |
| N2–N5 | Type / impact / réponse / délai de récupération | N2–N5 | INCHANGÉ | |
| N6A | Dépense imprévue **250 000 FCFA** | N6 | MODIFIÉ | Seuil ramené à 50 000 FCFA (**à valider**) |
| N7 | Échelle de résilience 1–10 | N7 | MODIFIÉ | Échelle 0–10 |
| — | — | FIES1–FIES8 | AJOUTÉ | Insécurité alimentaire (échelle FIES / FAO) |

## O. Expérience professionnelle et formations

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| O1–O6 | Activité antérieure / âge / formation / domaine / dispensateur / utilité | O1–O6 | MODIFIÉ | Libellés alignés |
| « Code O2 » | Bloc orphelin (16 modalités, code réutilisé) | — | CORRIGÉ | **Bloc orphelin réutilisant le code O2** supprimé |
| — | — | O6A / O7 / O8 | AJOUTÉ | Motif d'abandon / durée / utilité |
| — | — | O9 | AJOUTÉ | Autres programmes reçus → suivi de la **contamination** |

## P. Aspirations professionnelles

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| P1–P3 | Métier visé / type / revenu cible | P1–P3 | INCHANGÉ | |
| P4 | Secteur d'intérêt | P4 | MODIFIÉ | Aligné sur la nomenclature secteur (F3) |
| P5 | Obstacle principal (texte libre) | P5 | MODIFIÉ | Liste fermée → codable |

## Q → R. Cohésion sociale et engagement

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| Q1 / Q2 | Adhésion / temps donné | COH1 / COH2 | DÉPLACÉ | |
| Q3 | Confiance généralisée | COH3 | DÉPLACÉ | |
| Q4 | Confiance jeunes différents | COH4A–COH4D | MODIFIÉ | 4 dimensions : communauté / autre ethnie / autre religion / **allochtones** |
| Q5–Q10 | Confiance institutions | COH6A–COH6C | MODIFIÉ | Regroupé (administration / chefs / forces de sécurité) |
| — | — | COH5 | AJOUTÉ | Réciprocité (portefeuille perdu) |
| — | — | COH7 | AJOUTÉ | Sentiment d'appartenance |
| — | — | COH8A / COH8B | AJOUTÉ | Tolérance à la violence (proxy radicalisation) |
| — | — | COH9 / COH10 | AJOUTÉ | Sécurité perçue / évolution |
| — | — | COH11 | AJOUTÉ | Participation à la résolution de conflit |
| — | — | COH12 | AJOUTÉ | Voix dans les décisions communautaires (**indicateur PAD**) |
| — | — | COH13 / COH14 | AJOUTÉ | Endline : investissements ↔ besoins / confiance (**indicateur PAD**) |

## Module Autonomisation et genre (absent du Draft 7)

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| — | — | GEN1–GEN7 | AJOUTÉ | Module pro-WEAI (décision, mobilité, contrôle du revenu, garde d'enfants) — cible 40–50 % femmes |

## S. Suivi panel et traçage

| Code D7 | Libellé court D7 | Code D8 | Statut | Note |
|---|---|---|---|---|
| R1 / R1A | Meilleur numéro (« Posez si **P1**=2 ») | TRACE1 / TRACE1A | CORRIGÉ | **Filtre renvoyant à P1** ; corrigé en TRACE1=2 |
| R2 / R2A | Autre numéro (« Posez si **P2**=1 ») | TRACE2 | CORRIGÉ | **Filtre renvoyant à P2** |
| R3 / R3A / R3B | WhatsApp (« Posez si **P3…** ») | TRACE3 | CORRIGÉ | **Filtres renvoyant à P3** |
| R4 | Contact d'un tiers | TRACE4 | INCHANGÉ | |
| R5 | Consentement au recontact | TRACE8 | DÉPLACÉ | |
| — | — | TRACE5 / TRACE6 / TRACE7 | AJOUTÉ | 2ᵉ contact (autre ménage) / points de repère / GPS en visite — **dispositif anti-attrition** |

---

## Annexe 1 — Récapitulatif des 9 bugs du Draft 7 corrigés par le Draft 8

| # | Bug du Draft 7 | Item D7 | Correction D8 |
|---|---|---|---|
| 1 | Formule `EMPLOYÉ` référence D1/D2/D3/D3A (questions ménage) au lieu de E1/E2/E3/E3A | bloc E | `EMPLOYÉ = E1=1 ou E2=1 ou (E3=1 et E3A=1)` |
| 2 | `NON EMPLOYÉ` jamais défini | bloc E | `NON_EMPLOYÉ = 1 - EMPLOYÉ` |
| 3 | `J1` force une démarche → chômeur et inactif non séparables | J1 | Filtre `J0` (démarche O/N) en amont + `J4` |
| 4 | `H5` mélange profit et retrait personnel, « dépenses de base » flou | H5 | Module profit MMW `PR1–PR9` |
| 5 | Doublon `B6B` (deux questions sous le même code) | B6B | B6A / B6B / B6C distincts |
| 6 | `C2` renvoie à `B2A` (code inexistant) | C2 | `C2A` « si année inconnue à C2 » |
| 7 | Saut `N1` vers `L6A` (code inexistant) | N1 | « 2=Non → N6 » |
| 8 | Filtres `R1A–R3B` renvoient à `P` (aspirations) | R1A–R3B | Filtres internes TRACE1A…TRACE3 |
| 9 | Bloc orphelin « Code O2 » réutilisant un code déjà pris | après O6 | Bloc O1–O9 propre, codes uniques |

## Annexe 2 — Modules entièrement nouveaux du Draft 8

| Module | Codes | Échelle / source | Finalité |
|---|---|---|---|
| Handicap | WG1–WG6 | Washington Group Short Set | Inclusion handicap |
| Profit indépendant | PR1–PR9 | de Mel–McKenzie–Woodruff | **Outcome primaire** (profit net) |
| Auto-efficacité / espoir | PSY1–PSY4 | Échelle validée | Construit psychologique |
| Sécurité alimentaire | FIES1–FIES8 | FIES / FAO | Bien-être / vulnérabilité |
| Autonomisation / genre | GEN1–GEN7 | pro-WEAI | Cible 40–50 % femmes |
| Actifs étendus | D6–D10 | — | Indice de richesse (contrôles baseline) |
| Cohésion étendue | COH4A–D, COH5, COH7–COH14 | — | **Outcome bailleur** + indicateurs PAD |
| Module endline | END1–END7 | — | Exposition au traitement (LATE / compliance) |
| Variables dérivées | EMPLOYÉ, AUTO_EMPLOI, CHÔMEUR, INACTIF, HEURES_TOTALES, SOUS_EMPLOI, PROFIT_MOIS_NORMAL, FIES_BRUT | — | Préspécification analytique |

## Annexe 3 — Arbitrages restants (≠ bugs)

| Sujet | Draft 7 | Draft 8 | À trancher |
|---|---|---|---|
| Durée d'entretien | ~30 min | 35–45 min | Budget de temps acceptable au téléphone |
| Niveau d'études | 14 modalités | 8 modalités | Granularité vs longueur |
| Dépense imprévue (N6) | 250 000 FCFA | 50 000 FCFA | Seuil discriminant pour la population |

> Les points 1 à 10 de l'« Annexe C » du Draft 8 (plage d'âge, cible femmes, seuil sous-emploi,
> nomenclature métier, langue d'administration, etc.) restent à valider avant programmation.
