# -*- coding: utf-8 -*-
"""Génère la note d'analyse en PDF (.pdf)"""
from fpdf import FPDF

FONT_FILE = "/Library/Fonts/Arial Unicode.ttf"

class NotePDF(FPDF):
    def header(self):
        self.set_font("ArialU", "", 8)
        self.set_text_color(120, 120, 120)
        self.cell(0, 6, "Note d'analyse - Base COSO (collecte telephonique)", align="R")
        self.ln(8)
        self.set_x(self.l_margin)

    def footer(self):
        self.set_y(-15)
        self.set_font("ArialU", "", 8)
        self.set_text_color(120, 120, 120)
        self.cell(0, 10, f"Page {self.page_no()}/{{nb}}", align="C")

    def titres(self, texte):
        self.set_font("ArialU", "", 14)
        self.set_text_color(31, 78, 121)
        self.multi_cell(self.epw, 8, texte)
        self.set_x(self.l_margin)
        self.ln(2)

    def par(self, texte):
        self.set_font("ArialU", "", 10)
        self.set_text_color(30, 30, 30)
        self.multi_cell(self.epw, 6, texte)
        self.set_x(self.l_margin)
        self.ln(2)

    def colonnes(self, entetes, largeurs):
        self.set_font("ArialU", "", 9)
        self.set_fill_color(31, 78, 121)
        self.set_text_color(255, 255, 255)
        for h, l in zip(entetes, largeurs):
            self.cell(l, 7, h, border=1, fill=True)
        self.ln()

    def ligne(self, vals, largeurs, gras=False):
        self.set_font("ArialU", "", 9)
        self.set_text_color(30, 30, 30)
        for v, l in zip(vals, largeurs):
            self.cell(l, 6, v, border=1)
        self.ln()


pdf = NotePDF()
pdf.alias_nb_pages()
pdf.add_font("ArialU", "", FONT_FILE)
pdf.set_auto_page_break(auto=True, margin=18)
pdf.add_page()

# --------------------------------------------------------------- Titre
pdf.set_font("ArialU", "", 18)
pdf.set_text_color(20, 40, 80)
pdf.multi_cell(pdf.epw, 10, "Note d'analyse - Base COSO (collecte telephonique)", align="C")
pdf.set_x(pdf.l_margin)
pdf.set_font("ArialU", "", 10)
pdf.set_text_color(70, 70, 70)
pdf.multi_cell(pdf.epw, 5, "Statuts 60 et 65 consideres comme enquetes terminees", align="C")
pdf.set_x(pdf.l_margin)
pdf.ln(5)

# ------------------------------------------------------------------ 1
pdf.titres("1. Contexte et sources des donnees")
pdf.par(
    "Deux bases de collecte telephonique du questionnaire COSO ont ete fusionnees et "
    "nettoyees. Les 282 menages distincts de la base V4 sont tous retrouves dans V5 "
    "(0 nouveau menage) : un simple concatennage aurait cree des doublons. La base V5 "
    "sert donc de reference et V4 ne sert qu'a remplir les cases vides."
)
pdf.par(
    "Au total, 2921 cellules manquantes ont ete imputees depuis V4 et les zones "
    "geographiques B1 (district) et B2 (region) ont ete completees depuis le fichier "
    "cover (239 et 240 valeurs manquantes ramenees a 0)."
)
pdf.colonnes(["Base", "Lignes", "Colonnes", "Remarque"], [22, 22, 22, 120])
pdf.ligne(["V4", "284", "214", "Plus ancienne, sans cover_id, D5++11, R6, R7"], [22, 22, 22, 120])
pdf.ligne(["V5", "1032", "218", "Base de reference (pas de doublons)"], [22, 22, 22, 120])
pdf.ligne(["Finale (VF)", "1032", "218", "V5 enrichie par V4"], [22, 22, 22, 120])
pdf.ln(4)

# ------------------------------------------------------------------ 2
pdf.titres("2. Hypotheses de travail")
pdf.par(
    "Les statuts issus du serveur de collecte (SuSo) sont les suivants : "
    "100 = Completed (enquete validee et terminee), 65 = Rejected (terminnee mais a "
    "corriger) et 60 = Assigned (assignee a un enqueteur)."
)
pdf.colonnes(["Statut", "Signification", "Effectif"], [22, 130, 34])
pdf.ligne(["100", "Completed - enquete validee et terminee", "524"], [22, 130, 34])
pdf.ligne(["65", "Rejected - enquete terminee mais a corriger", "362"], [22, 130, 34])
pdf.ligne(["60", "Assigned - interview assignee a un enqueteur", "146"], [22, 130, 34])
pdf.ln(2)
pdf.set_font("ArialU", "", 10)
pdf.set_text_color(20, 60, 30)
pdf.multi_cell(
    pdf.epw, 6,
    "Hypothese retenue : les statuts 65 et 60 sont consideres comme des enquetes "
    "TERMINEES. Ainsi, sur les 1032 interviews de la base finale, 1032 (100 %) sont "
    "consideres comme terminees. Deux categories de suivi sont distinguees : "
    "'Enquete terminee' (statut 100, n=524) et 'Non terminee (assignee/rejetee)' "
    "(statuts 60 et 65, n=508).",
)
pdf.set_x(pdf.l_margin)
pdf.ln(3)

# ------------------------------------------------------------------ 3
pdf.titres("3. Resultat des appels (question A4)")
pdf.par(
    "La question A4 enregistre l'issue de chaque appel telephonique. Cette information "
    "permet de qualifier les interviews. Repartition des 1032 interviews :"
)
pdf.colonnes(["Code", "Intitule", "Effectif"], [20, 130, 36])
pdf.ligne(["1", "Entretien realise (questionnaire rempli)", "662"], [20, 130, 36])
pdf.ligne(["2", "Pas de reponse", "64"], [20, 130, 36])
pdf.ligne(["3", "Numero invalide ou incorrect", "53"], [20, 130, 36])
pdf.ligne(["4", "Ligne occupee", "48"], [20, 130, 36])
pdf.ligne(["5", "Rendez-vous fixe pour un rappel", "3"], [20, 130, 36])
pdf.ligne(["6", "Refus de participer", "7"], [20, 130, 36])
pdf.ligne(["7", "Appel interrompu en cours d'entretien", "0"], [20, 130, 36])
pdf.ligne(["8", "Autre (a preciser)", "130"], [20, 130, 36])
pdf.ln(2)
pdf.par(
    "NB : 65 interviews n'ont pas de resultat d'appel renseigne. Une interview peut "
    "etre consideree 'terminee' (statut 100/65/60) meme si le resultat d'appel A4 "
    "indique un echec : la comptabilite depend de la question posee a l'enqueteur."
)

# ------------------------------------------------------------------ 4
pdf.titres("4. Taux de remplissage du questionnaire")
pdf.par(
    "Pour savoir si une interview peut alimenter les analyses, on mesure la proportion "
    "de cellules renseignees sur 170 colonnes de contenu du questionnaire (hors "
    "identifiants techniques et variables cover)."
)
pdf.colonnes(["Groupe", "Effectif", "Taux de remplissage"], [100, 40, 46])
pdf.ligne(["Ensemble des 1032 interviews", "1032", "45,5 %"], [100, 40, 46])
pdf.ligne(["Statut 100 - Completed", "524", "55,8 %"], [100, 40, 46])
pdf.ligne(["Statut 65 - Rejetee", "362", "45,1 %"], [100, 40, 46])
pdf.ligne(["Statut 60 - Assignee", "146", "9,8 %"], [100, 40, 46])
pdf.ligne(["A4 = 1 (entretien realise)", "662", "62,6 %"], [100, 40, 46])
pdf.ligne(["A4 = 2 (pas de reponse)", "64", "13,9 %"], [100, 40, 46])
pdf.ligne(["A4 = 8 (autre)", "130", "19,5 %"], [100, 40, 46])
pdf.ln(2)
pdf.par(
    "Interpretation : toutes les interviews sont considerees terminees, mais leur "
    "remplissage effectif varie fortement. Les interviews de statut 60 (assinees, "
    "n=146) ne sont remplies qu'a 9,8 % : elles comptent dans les 'terminees' mais "
    "contiennent peu de donnees exploitables."
)
pdf.par(
    "En pratique, seules les interviews avec un taux de remplissage eleve (statuts 100 "
    "et 65, ou A4 = 1) peuvent etre utilisees pour des analyses statistiques de fond. "
    "Les autres lignes servent au calcul du taux de realisation et a la cartographie "
    "des echecs de collecte."
)

# ------------------------------------------------------------------ 5
pdf.titres("5. Conclusion et fichiers produits")
pdf.par(
    "Sous l'hypothese retenue, la base exploitable contient 1032 interviews "
    "consideres comme terminees (100 % de la base finale), toutes exportees dans un "
    "fichier dedie a l'analyse. Les deux categories de suivi ('Enquete terminee' et "
    "'Non terminee - assignee/rejetee') sont conservees via la colonne "
    "categorie_statut."
)
pdf.colonnes(["Fichier", "Contenu"], [75, 111])
pdf.ligne(["Questionnaire_COSO_TERMINES.dta",
           "Base des interviews terminees (1032 lignes), prete pour l'analyse"], [75, 111])
pdf.ligne(["Questionnaire_COSO_VF_avec_statut.dta",
           "Base complete avec les colonnes categorie_statut et est_terminee"], [75, 111])
pdf.ligne(["RAPPORT_TRAITEMENT_BASE_COSO.txt",
           "Rapport detaille du traitement (fusion V4/V5, imputations)"], [75, 111])

pdf.output("Note_Analyse_COSO.pdf")
print("Note PDF générée : Note_Analyse_COSO.pdf")