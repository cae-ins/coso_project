"""Libellés des variables utilisées par le pipeline des indicateurs.

Généré automatiquement depuis 05_docs/codebook_QUESTIONNAIRE_VF_SANS_DOUBLON_VF.xlsx
(feuille « Valeurs » ; modalités D5/K5 extraites des questions de la feuille
« Variables »). Ne pas éditer à la main : régénérer avec

    python3 libelles_coso.py --codebook ../05_docs/codebook_QUESTIONNAIRE_VF_SANS_DOUBLON_VF.xlsx

Les codes 9 / 99 sont conservés tels quels : leur libellé indique s'il s'agit
d'une modalité réelle (« Autre ») ou d'une non-réponse (« Ne sait pas »).
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

LIBELLES = {
    'A1': {1: 'Première tentative', 2: 'Deuxième tentative', 3: 'Troisième tentative ou plus'},
    'A4': {1: 'Entretien réalisé (compléter le questionnaire)', 2: 'Pas de réponse', 3: 'Numéro invalide ou incorrect', 4: 'Ligne occupée', 5: 'Rendez-vous fixé pour un rappel', 6: 'Le répondant a refusé de participer', 7: 'Le répondant a raccroché / appel interrompu en cours d’entretien', 8: 'Autre (préciser)'},
    'B5': {1: 'Urbain', 2: 'Rural'},
    'C1': {1: 'Homme', 2: 'Femme'},
    'C3': {1: 'Célibataire', 2: 'Marié(e) monogame', 3: 'Marié(e) polygame', 4: 'Union libre/Concubinage', 5: 'Divorcé(e)', 6: 'Veuf(ve)'},
    'C4': {0: 'Aucun niveau', 1: 'Préscolaire', 2: 'Primaire', 3: 'Secondaire général cycle I', 4: 'Secondaire technique/professionnel cycle I', 5: 'Secondaire général cycle II', 6: 'Secondaire technique/professionnel cycle II', 7: 'Supérieur cycle court (BAC+ 1; BP; BTS1; BAC+2; BTS2; DUT)', 8: 'Licence', 9: 'Maitrise/ Master 1', 10: 'Master 2/DEA/DESS', 11: 'Doctorat', 12: 'Post Doctorat'},
    'C5': {1: 'AUCUN', 2: 'CEPE', 3: 'BEPC/BEP/CAP', 4: 'BAC/BT', 5: 'BTS/DEUG 2', 6: 'LICENCE/BACHELOR', 7: 'MASTER/DESS', 8: 'DOCTORATS'},
    'C6': {1: 'Oui', 2: 'Non'},
    'C7': {1: 'Oui', 2: 'Non'},
    'C8': {1: 'Côte d’Ivoire', 2: "Hors Côte d'Ivoire"},
    'D3': {1: 'Chef de ménage', 2: 'Conjoint du CM', 3: 'Enfant du CM', 4: 'Autre parent du CM', 5: 'Sans lien de parenté avec le CM', 6: 'Amis du CM', 7: 'Autre à préciser'},
    'D5__1': {1: 'Télévision'},
    'D5__10': {1: 'Décodeur TNT/ Abonnement canal+/Easy TV/Start Time'},
    'D5__11': {1: 'Aucun des biens ci-dessus'},
    'D5__2': {1: 'Téléphone portable'},
    'D5__3': {1: 'Moto'},
    'D5__4': {1: 'Vélo'},
    'D5__5': {1: 'Brouette'},
    'D5__6': {1: 'Réfrigérateur/congélateur'},
    'D5__7': {1: 'Ordinateur'},
    'D5__8': {1: 'Radio'},
    'D5__9': {1: 'Ventilateur'},
    'E3A': {1: 'Principalement à la vente', 2: "Principalement à l'usage du ménage"},
    'F1': {1: 'Salarié', 2: 'Employeur (avec employés)', 3: 'Travailleur indépendant / à compte propre (sans employés)', 4: 'Membre de coopératives de producteurs', 5: 'Travailleurs familiaux collaborant à l’entreprise familiale', 7: 'Apprenti/Stagiaire', 9: 'Autre (Précisez)'},
    'F2': {1: 'Agriculture, élevage, pêche, sylviculture', 2: 'Industries extractives', 3: 'Industrie manufacturière', 4: 'Construction/BTP', 5: 'Commerce de gros ou de détail', 6: 'Transport, entreposage, logistique', 7: 'Hébergement et restauration', 8: 'Information, communication, services numériques', 9: 'Activités financières et d’assurance', 10: 'Administration publique', 11: 'Éducation', 12: 'Santé humaine et action sociale', 13: 'Travail domestique chez un particulier', 14: 'Autres services (réparation, services personnels, arts/spectacles)', 99: 'Autre (préciser)'},
    'F3': {1: 'À domicile', 2: 'Dans une structure attenante/proche du domicile', 3: 'Au domicile de l’employeur', 4: 'Lieu fixe hors domicile, en intérieur (bureau, magasin, usine)', 5: 'Étal/emplacement fixe dans un espace public (stand de marché, kiosque, emplacement de vente autorisé)', 6: 'Chantier de construction', 7: 'Champ/exploitation agricole', 8: 'Mobile/sans emplacement fixe (vente itinérante, porte-à-porte)', 9: 'Autre (préciser)'},
    'F4': {1: 'Moins de 6 mois', 2: '6 mois à moins d’un an', 3: '1 an à moins de 2 ans', 4: '2 ans à moins de 5 ans', 5: '5 ans ou plus'},
    'G1': {1: 'Oui, à durée indéterminée (CDI)', 2: 'Oui, à durée déterminée (CDD)', 3: 'Oui, consultance', 4: 'Accord verbal seulement', 5: 'Aucun accord'},
    'G2': {1: 'Oui', 2: 'Non'},
    'G4': {1: 'Oui', 2: 'Non'},
    'G5': {1: 'Oui', 2: 'Non'},
    'G7': {1: 'Oui', 2: 'Non'},
    'G7A': {1: 'Oui', 2: 'Non'},
    'H1': {1: 'En espèces uniquement', 2: 'En nature uniquement', 3: 'Les deux'},
    'H2': {1: 'Quotidienne/Jour', 2: 'Hebdomadaire/Semaine', 3: 'Quinzaine/Toutes les deux semaines', 4: 'Mensuelle/Mois', 5: 'Bimestre/Tous les deux mois', 6: 'Trimestre/Tous les trois mois', 7: 'Semestre/Tous les six mois', 8: 'Année', 9: 'Irrégulière', 10: 'Ne veut pas dire'},
    'H3A': {1: 'Moins de 30 000', 2: '[30 000 - 75 000[', 3: '[75 000 - 150 000[', 4: '[150 000 - 300 000[', 5: '[300 000 - 500 000[', 6: '[500 000 - 800 000[', 7: '[800 000 - 1 000 000[', 8: "Plus d'un million"},
    'H4': {1: 'Oui', 2: 'Non', 3: 'Ne sait pas'},
    'H5A': {1: 'Moins de 30 000', 2: '[30 000 - 75 000[', 3: '[75 000 - 150 000[', 4: '[150 000 - 300 000[', 5: '[300 000 - 500 000[', 6: '[500 000 - 800 000[', 7: '[800 000 - 1 000 000[', 8: "Plus d'un million"},
    'I1': {1: 'Oui', 2: 'Non'},
    'I2': {1: 'Revenu insuffisant dans l’emploi actuel', 2: 'Emploi actuel instable/temporaire', 3: 'Je veux un emploi qui correspond mieux à mes compétences', 4: 'Je veux simplement un meilleur emploi', 5: 'Autre'},
    'I3': {1: 'Candidature spontanée auprès d’employeurs', 2: 'Réponse à une offre d’emploi (en ligne, journal, affiche)', 3: 'Inscription auprès d’une agence (Agence Emploi Jeunes, etc.)', 4: 'Réseau personnel (famille, amis)', 5: 'Concours/test pour le secteur public', 6: 'Démarches pour créer sa propre entreprise', 9: 'Autre'},
    'J0': {1: 'Oui', 2: 'Non'},
    'J0A': {1: 'Vous ne pensiez pas en trouver, vous étiez découragé(e)', 2: "Vous pensiez qu'il n'y avait pas d'emploi disponible correspondant à vos compétences dans votre zone", 3: 'Vous suiviez (ou aviez le projet de suivre) des études ou une formation', 4: 'Problèmes de santé ou situation de handicap', 5: 'Obligations familiales (enfants, proches)', 6: 'Vous attendiez le début de la saison agricole', 7: 'Vous attendiez le résultat de démarches antérieures (emploi, concours, programme)', 8: 'Vous avez déjà trouvé un emploi ou une activité qui commencera dans les trois prochains mois', 9: 'Autre (préciser)'},
    'J0B': {1: 'Oui', 2: 'Non'},
    'J1': {1: 'Candidature spontanée auprès d’employeurs', 2: 'Réponse à une offre d’emploi (en ligne, journal, affiche)', 3: 'Inscription auprès d’une agence (Agence Emploi Jeunes, etc.)', 4: 'Réseau personnel (famille, amis)', 5: 'Concours/test pour le secteur public', 6: 'Démarches pour créer sa propre entreprise', 9: 'Autre'},
    'J2': {1: 'Moins d’1 mois', 2: '1 mois à moins de 3 mois', 3: '3 mois à moins de 6 mois', 4: '6 mois à moins de 12 mois', 5: '1 an à moins de 2 ans', 6: '2 ans ou plus'},
    'J3': {1: 'Oui', 2: 'Non'},
    'K1': {1: 'Oui', 2: 'Non'},
    'K2': {1: 'Oui', 2: 'Non'},
    'K3': {1: 'Épargne personnelle', 2: 'Aide familiale', 3: 'Microfinance/coopérative d’épargne (COOPEC)', 4: 'Programme gouvernemental (AGR/Agence Emploi Jeunes)', 5: 'Prêt bancaire', 6: 'ONG/organisation humanitaire', 9: 'Autre'},
    'K4': {1: 'Épargne personnelle', 2: 'Aide familiale', 3: 'Microfinance/coopérative d’épargne (COOPEC)', 4: 'Programme gouvernemental (AGR/Agence Emploi Jeunes)', 5: 'Prêt bancaire', 6: 'ONG/organisation humanitaire', 7: 'Ne sait pas', 9: 'Autre'},
    'K5__1': {1: 'Manque de capital/financement'},
    'K5__2': {1: 'Manque de compétences/savoir-faire entrepreneurial'},
    'K5__3': {1: 'Manque d’équipement ou de local'},
    'K5__4': {1: 'Manque de marché/demande pour cette idée'},
    'K5__5': {1: 'Obligations/responsabilités familiales'},
    'K5__6': {1: 'Peur de l’échec/du risque'},
    'K5__7': {1: 'Obstacles administratifs/juridiques (permis, enregistrement)'},
    'K5__9': {1: 'Autre'},
    'K6': {1: 'Oui', 2: 'Non'},
    'K7': {1: 'Très faibles', 2: 'Faibles', 3: 'Moyennes', 4: 'Bonnes', 5: 'Très bonnes'},
    'L1': {1: 'Oui', 2: 'Non'},
    'L2': {1: 'Oui', 2: 'Non'},
    'L3': {1: 'Oui, régulièrement', 2: 'Oui, occasionnellement', 3: 'Non, jamais'},
    'L5': {1: 'Domicile (cash)', 2: 'Tontine/AVEC', 3: 'Compte bancaire', 4: 'Mobile money', 5: 'Autres  (à préciser)'},
    'L6': {1: 'Oui', 2: 'Non'},
    'L7': {1: 'Banque', 2: 'Institution de microfinance/COOPEC', 3: 'Crédit mobile money', 4: 'Tontine/AVEC', 5: 'Famille ou amis', 6: 'Employeur', 7: 'Prêteur informel', 9: 'Autre'},
    'L9': {1: 'Démarrer ou développer une activité', 2: 'Couvrir des besoins quotidiens/du ménage', 3: 'Éducation/frais de scolarité', 4: 'Santé/dépenses médicales', 5: 'Logement', 9: 'Autre'},
    'M1': {1: 'Je dépends principalement de l’aide d’autrui', 2: 'Je me prends en charge pour certains de mes besoins', 3: 'Je suis capable de me prendre en charge complètement'},
    'M2': {1: 'Oui, régulièrement', 2: 'Oui, ponctuellement', 3: 'Non, jamais'},
    'M3': {1: 'Pas du tout d’accord', 2: 'Plutôt pas d’accord', 3: 'Neutre', 4: 'Plutôt d’accord', 5: 'Tout à fait d’accord'},
    'M4': {1: 'Je dépends principalement de l’aide d’autrui', 2: 'Je me prends en charge pour certains de mes besoins', 3: 'Je suis capable de me prendre en charge complètement'},
    'N1': {1: 'Oui', 2: 'Non'},
    'N2': {1: 'Maladie/accident', 2: 'Choc climatique (sécheresse, inondation)', 3: "Perte d'activité/emploi", 4: "Décès d'un membre du ménage", 5: 'Catastrophe naturelle', 9: 'Autre (préciser)'},
    'N3': {1: 'Aucun impact', 2: 'Impact limité, vite surmonté', 3: 'Impact important, encore en cours de redressement', 4: 'Impact très important, activité arrêtée ou fortement réduite'},
    'N4': {1: 'Épargne personnelle', 2: "Vente d'actifs/biens", 3: 'Emprunt/crédit', 4: 'Aide familiale ou communautaire', 5: 'Aide externe (ONG, État)', 6: 'Réduction de la consommation', 9: 'Autre'},
    'N5': {1: "Moins d'1 mois", 2: '1 à 3 mois', 3: '3 à 6 mois', 4: 'Plus de 6 mois', 5: 'Pas encore rétabli'},
    'N6': {1: 'Oui, facilement', 2: 'Oui, avec difficulté', 3: 'Non, impossible'},
    'N7': {1: '1', 2: '2', 3: '3', 4: '4', 5: '5', 6: '6', 7: '7', 8: '8', 9: '9', 10: '10'},
    'O1': {1: 'Oui', 2: 'Non'},
    'O3': {1: 'Oui', 2: 'Non'},
    'O5': {1: 'École/centre de formation professionnelle formel', 2: 'Employeur/entreprise privée', 3: 'Programme gouvernemental (ex. Agence Emploi Jeunes)', 4: 'ONG/programme d’alphabétisation ou de compétences de vie', 5: 'Apprentissage informel (famille/membre de la communauté)', 6: 'Apprentissage sur le tas/au travail', 9: 'Autre'},
    'O6': {1: 'Pas utile', 2: 'Plutôt utilie', 3: 'Très utile'},
    'P2': {1: 'Trouver un emploi salarié', 2: 'Créer une entreprise', 3: 'Développer une activité existante'},
    'P4': {1: 'Agriculture, élevage, pêche, sylviculture', 2: 'Industries extractives', 3: 'Industrie manufacturière', 4: 'Construction/BTP', 5: 'Commerce de gros ou de détail', 6: 'Transport, entreposage, logistique', 7: 'Hébergement et restauration', 8: 'Information, communication, services numériques', 9: 'Activités financières et d’assurance', 10: 'Administration publique', 11: 'Éducation', 12: 'Santé humaine et action sociale', 13: 'Travail domestique chez un particulier', 14: 'Autres services (réparation, services personnels, arts/spectacles)', 99: 'Autre (préciser)'},
    'Q1': {1: 'Oui', 2: 'Non'},
    'Q10': {1: 'Pas du tout confiance', 2: 'Juste un peu confiance', 3: 'Partiellement confiance', 4: 'Beaucoup confiance', 9: 'Ne sait pas'},
    'Q3': {1: 'On peut faire confiance à la plupart des gens', 2: 'Il faut être prudent'},
    'Q4': {1: 'Pas du tout confiance', 2: 'Juste un peu confiance', 3: 'Partiellement confiance', 4: 'Beaucoup confiance', 9: 'Ne sait pas'},
    'Q5': {1: 'Pas du tout confiance', 2: 'Juste un peu confiance', 3: 'Partiellement confiance', 4: 'Beaucoup confiance', 9: 'Ne sait pas'},
    'Q6': {1: 'Pas du tout confiance', 2: 'Juste un peu confiance', 3: 'Partiellement confiance', 4: 'Beaucoup confiance', 9: 'Ne sait pas'},
    'Q7': {1: 'Pas du tout confiance', 2: 'Juste un peu confiance', 3: 'Partiellement confiance', 4: 'Beaucoup confiance', 9: 'Ne sait pas'},
    'Q8': {1: 'Pas du tout confiance', 2: 'Juste un peu confiance', 3: 'Partiellement confiance', 4: 'Beaucoup confiance', 9: 'Ne sait pas'},
    'Q9': {1: 'Pas du tout confiance', 2: 'Juste un peu confiance', 3: 'Partiellement confiance', 4: 'Beaucoup confiance', 9: 'Ne sait pas'},
}



def _generer(codebook: Path) -> dict:
    import pandas as pd
    var = pd.read_excel(codebook, "Variables")
    v = pd.read_excel(codebook, "Valeurs")
    utilisées = sorted({w for w in v.Variable.unique()
                        if w in LIBELLES or w.startswith(("D5__", "K5__"))})
    lab = {}
    for w in utilisées:
        sub = v[v.Variable == w]
        if len(sub):
            lab[w] = {int(r.Code) if float(r.Code).is_integer() else float(r.Code):
                      str(r.Libelle).strip() for r in sub.itertuples()}
    for w in [f"D5__{i}" for i in range(1, 12)] + [f"K5__{i}" for i in [1, 2, 3, 4, 5, 6, 7, 9]]:
        q = str(var[var.Variable == w].Question.iloc[0])
        m = re.search(r"modalité\s*\d+\s*:\s*(.*?)\s*(?:1 = cochée|\(Plusieurs|\Z)", q, re.I)
        if m:
            lab[w] = {1: m.group(1).strip()}
    return lab


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] != "--codebook":
        raise SystemExit("usage: python3 libelles_coso.py --codebook <xlsx>")
    print(f"{len(_generer(Path(sys.argv[2])))} variables régénérées "
          "(coller le dictionnaire LIBELLES ci-dessus).")
