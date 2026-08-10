# Questionnaire COSO — Addendum au Draft 7

**Questions à ajouter pour la mesure du chômage et du sous-emploi**
*Alignement sur l'Enquête Nationale sur l'Emploi (ENEM 2025) et les normes BIT (19e CIST)*
Version du 2 juillet 2026 — à joindre à la Note de revue du questionnaire.

Le présent addendum introduit quatre questions (J0, J0A, J0B, G7A) et une reformulation recommandée
(G7). Ces ajouts rendent calculables le taux de chômage et le taux de sous-emploi au sens du BIT,
ainsi que les quatre indicateurs de sous-utilisation de la main-d'œuvre (LU1 à LU4). Les libellés
sont adaptés de l'Enquête Nationale sur l'Emploi, ce qui garantit la comparabilité directe des
résultats de l'évaluation avec les statistiques officielles publiées par l'ANStat. Durée
additionnelle estimée : environ une minute par entretien.

---

## 1. CHÔMAGE – DURÉE ET RECHERCHE D'EMPLOI (Posez si NON EMPLOYÉ) — section modifiée

Les questions J0, J0A et J0B sont nouvelles et se placent en tête de section. J1 et J2 sont
conservées à l'identique mais ne sont plus posées qu'aux personnes en recherche (J0=1). J3 reste
posée à tous les non-employés.

| Code | Question | Modalités / Réponses |
|---|---|---|
| **J0** *(nouvelle)* | *Posez si NON EMPLOYÉ.* Au cours des 30 derniers jours, avez-vous cherché un emploi salarié ou indépendant, ou essayé de démarrer une activité génératrice de revenus (petit commerce, atelier, exploitation agricole, etc.) ? | 1. Oui → J1 / 2. Non → J0A |
| **J0A** *(nouvelle)* | *Posez si J0=2.* Quelle est la principale raison pour laquelle vous n'avez pas cherché d'emploi ni essayé de démarrer une activité au cours des 30 derniers jours ? | 1. Vous ne pensiez pas en trouver, vous étiez découragé(e) / 2. Vous pensiez qu'il n'y avait pas d'emploi disponible correspondant à vos compétences dans votre zone / 3. Vous suiviez (ou aviez le projet de suivre) des études ou une formation / 4. Problèmes de santé ou situation de handicap / 5. Obligations familiales (enfants, proches) / 6. Vous attendiez le début de la saison agricole / 7. Vous attendiez le résultat de démarches antérieures (emploi, concours, programme) / 8. Vous avez déjà trouvé un emploi ou une activité qui commencera dans les trois prochains mois / 9. Autre (préciser) |
| **J0B** *(nouvelle)* | *Posez si J0=2.* À l'heure actuelle, souhaiteriez-vous travailler ? | 1. Oui / 2. Non |
| **J1** *(filtre modifié)* | *Posez si J0=1.* Qu'avez-vous fait principalement au cours des 30 derniers jours pour trouver un emploi ou démarrer une entreprise ? *(libellé et modalités inchangés)* | 1–7 (Draft 7) |
| **J2** *(filtre modifié)* | *Posez si J0=1.* Depuis combien de temps êtes-vous sans emploi et en recherche ? *(libellé et modalités inchangés)* | 1–6 (Draft 7) |
| **J3** *(inchangée)* | *Posez si NON EMPLOYÉ (tous, y compris J0=2).* Si vous aviez trouvé un emploi la semaine dernière, auriez-vous pu commencer dans les deux semaines suivantes ? | 1. Oui / 2. Non |

## 2. QUALITÉ DE L'EMPLOI (Posez si EMPLOYÉ) — section modifiée

G7 est reformulée pour introduire la période de référence et la condition de rémunération
(formulation ENE/BIT). G7A est nouvelle et se place immédiatement après G7.

| Code | Question | Modalités / Réponses |
|---|---|---|
| **G7** *(reformulée)* | Au cours des 30 derniers jours, auriez-vous voulu travailler plus d'heures par semaine que d'habitude, à condition que ces heures supplémentaires soient payées ? *(remplace la formulation « …si l'occasion se présentait »)* | 1. Oui / 2. Non |
| **G7A** *(nouvelle)* | *Posez si G7=1.* Auriez-vous pu commencer à travailler plus d'heures au cours des deux prochaines semaines ? | 1. Oui / 2. Non |

## 3. VARIABLES DÉRIVÉES ET INDICATEURS CALCULABLES

| Variable / indicateur | Définition |
|---|---|
| **CHOMEUR** | NON_EMPLOYE et [ (J0=1 et J3=1) ou (J0A=8 et J3=1) ] — chômeurs BIT, y compris « future starters » (emploi trouvé commençant sous 3 mois) |
| **MOP** | NON_EMPLOYE, non CHOMEUR, et [ (J0=1 et J3=2) ou (J0=2 et J0B=1 et J3=1) ] — main-d'œuvre potentielle |
| **DECOURAGE** | J0=2 et J0A=1 — travailleurs découragés |
| **SOUS_EMPLOI** | EMPLOYÉ et (G3 + G6 si G5=1) < 40 h et G7=1 et G7A=1 — sous-emploi horaire (seuil 40 h, identique ENE) |
| **LU1** | CHOMEUR / (EMPLOYÉ + CHOMEUR) — taux de chômage |
| **LU2** | (CHOMEUR + SOUS_EMPLOI) / (EMPLOYÉ + CHOMEUR) |
| **LU3** | (CHOMEUR + MOP) / (EMPLOYÉ + CHOMEUR + MOP) |
| **LU4** | (CHOMEUR + SOUS_EMPLOI + MOP) / (EMPLOYÉ + CHOMEUR + MOP) |
| **INACTIF** | NON_EMPLOYE, non CHOMEUR, non MOP — hors main-d'œuvre élargie |

## 4. CORRESPONDANCE AVEC L'ENQUÊTE NATIONALE SUR L'EMPLOI

| COSO | ENE (ENEM 2025) | Rôle |
|---|---|---|
| J0 | SRH1 + SRH2 + SRH2A (fusionnées) | Critère de recherche active (cascade ENE fusionnée pour le format téléphonique) |
| J0A | SRH7 (condensée, 27 → 9 modalités) | Motif de non-recherche : découragés (mod. 1 ↔ SRH7=1), future starters (mod. 8 ↔ SRH7=18 & SRH8≤3 mois) |
| J0B | SRH6 (copie) | Souhait de travailler (composante MOP de LU3/LU4) |
| J1 | SRH3 | Méthodes de recherche, posée aux seuls chercheurs |
| J3 | SRH11 (copie) | Critère de disponibilité du chômage |
| G7 | WKI4 (copie) | Critère de souhait du sous-emploi |
| G7A | WKI5 (copie) | Critère de disponibilité du sous-emploi |
| Seuil 40 h | `hor_eff < 40` | Seuil horaire des tabulations ENE |

---

*Note — Ces quatre questions traitent la mesure du statut d'activité. Les autres points de la Note
de revue (séquence profit de l'activité indépendante, corrections de filtres restantes) font l'objet
de recommandations distinctes.*
