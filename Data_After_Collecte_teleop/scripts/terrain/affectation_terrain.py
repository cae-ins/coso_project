# -*- coding: utf-8 -*-
"""Affectation des candidats COSO aux enqueteurs terrain.

Repartit les candidats de chaque region entre les enqueteurs de cette
region (repartition equitable, groupes par localite), en planifiant
3 entretiens par enqueteur et par jour, puis estime la duree.

Deux fichiers produits :
  1. AFFECTATION_COSO_TERRAIN_PLANIFIEE.xlsx : BOUNKANI sans enqueteur,
     marque "A PLANIFIER ULTERIEUREMENT".
  2. AFFECTATION_COSO_TERRAIN_BOUNKANI_TCHOLOGO.xlsx : les 110 BOUNKANI
     sont affectes aux enqueteurs du TCHOLOGO.
"""

import os
import math
import pandas as pd

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet
SOURCE = os.path.join(RACINE, "inputs", "AFFECTATION COSO TERRAIN.xlsx")
DEST1 = os.path.join(RACINE, "MIGONE", "outputs", "AFFECTATION_COSO_TERRAIN_PLANIFIEE.xlsx")
DEST2 = os.path.join(RACINE, "MIGONE", "outputs", "AFFECTATION_COSO_TERRAIN_BOUNKANI_TCHOLOGO.xlsx")

ENTRETIENS_PAR_ENQUETEUR_PAR_JOUR = 3
REGION_BOUNKANI = "BOUNKANI"
REGION_SUPPORT = "TCHOLOGO"


def nettoyer_candidats(cands):
    cands = cands.copy()
    cands.columns = [str(c).strip() for c in cands.columns]
    cands["REGION"] = cands["REGION"].astype(str).str.strip()
    return cands


def nettoyer_enqueteurs(xl):
    enq = pd.read_excel(xl, sheet_name="enqueteurs", header=4)
    enq = enq[["NOM", "ROLE", "EMAIL", "CONTACT", "REGION"]].dropna(subset=["NOM"])
    enq.columns = ["nom", "role", "email", "contact", "region"]
    enq["nom"] = enq["nom"].astype(str).str.strip()
    enq["role"] = enq["role"].astype(str).str.strip()
    enq["region"] = enq["region"].astype(str).str.strip()
    enq["region"] = enq["region"].str.upper().str.strip().str.replace("  +", " ", regex=True)
    return enq


def affecter(cands, enq_total, bounkani_sur_tchologo=False):
    """Repartit les candidats. Si bounkani_sur_tchologo, la region BOUNKANI
    est affectee aux enqueteurs de REGION_SUPPORT apres leur charge locale ;
    sinon elle est mise de cote."""
    res_affect = []
    plan_lignes = []

    remap = {REGION_BOUNKANI: REGION_SUPPORT} if bounkani_sur_tchologo else {}
    # ordre de traitement : BOUNKANI en dernier quand il est remappe (au dela
    # de la charge locale des enqueteurs TCHOLOGO)
    regions = [r for r in cands["REGION"].unique()]
    if bounkani_sur_tchologo and REGION_BOUNKANI in regions:
        regions = [r for r in regions if r != REGION_BOUNKANI] + [REGION_BOUNKANI]

    # compteur de sequençage par enqueteur (rang et jour cumules sur toutes ses
    # affectations) pour ne jamais depasser ENTRETIENS_PAR_ENQUETEUR_PAR_JOUR
    seq = {}

    for region in regions:
        grp = cands[cands["REGION"] == region]
        region_eq = remap.get(region, region)
        penq = enq_total[enq_total["region"] == region_eq]
        n_cand = len(grp)

        if not penq.empty:
            n_enq = len(penq)
            # repartition equitable : chaque enqueteur recoit base + reste
            base, reste = divmod(n_cand, n_enq)
            quotas = [base + 1 if i < reste else base for i in range(n_enq)]
            # tri par localite pour regrouper les villages voisins chez un meme enqueteur
            grp = grp.sort_values(["LOCALITE", "ID"]).reset_index(drop=True)
            cum = 0
            for (_, row_enq), quota in zip(penq.iterrows(), quotas):
                bloque = grp.iloc[cum:cum + quota]
                cum += quota
                for _, row in bloque.iterrows():
                    enq = row_enq["nom"]
                    q = seq.get(enq, {"rang": 0})
                    q["rang"] += 1
                    seq[enq] = q
                    jours_region_ok = (q["rang"] - 1) // ENTRETIENS_PAR_ENQUETEUR_PAR_JOUR + 1
                    res_affect.append({
                        **row.to_dict(),
                        "N_ENQUETEUR": enq,
                        "ROLE": row_enq["role"],
                        "EMAIL_ENQUETEUR": row_enq["email"],
                        "CONTACT_ENQUETEUR": row_enq["contact"],
                        "RANG_ENQUETEUR": q["rang"],
                        "JOUR": jours_region_ok,
                    })
            jours = math.ceil(n_cand / (n_enq * ENTRETIENS_PAR_ENQUETEUR_PAR_JOUR))
            if region == REGION_BOUNKANI and bounkani_sur_tchologo:
                statut = "AFFECTE (BOUNKANI -> TCHOLOGO, apres charge locale)"
            else:
                statut = "AFFECTE"
            plan_lignes.append({
                "REGION": region, "CANDIDATS": n_cand, "ENQUETEURS": n_enq,
                "JOURS": jours, "CAPACITE_JOUR": n_enq * ENTRETIENS_PAR_ENQUETEUR_PAR_JOUR,
                "STATUT": statut,
            })
        else:
            # region sans enqueteur : non affectee
            for _, row in grp.iterrows():
                res_affect.append({
                    **row.to_dict(),
                    "N_ENQUETEUR": "A PLANIFIER (pas d'enqueteur)",
                    "ROLE": "", "EMAIL_ENQUETEUR": "", "CONTACT_ENQUETEUR": "",
                    "RANG_ENQUETEUR": None, "JOUR": None,
                })
            plan_lignes.append({
                "REGION": region, "CANDIDATS": n_cand, "ENQUETEURS": 0,
                "JOURS": None, "CAPACITE_JOUR": 0,
                "STATUT": "A PLANIFIER ULTERIEUREMENT",
            })

    affect = pd.DataFrame(res_affect)
    plan = pd.DataFrame(plan_lignes)

    # jour debut/fin de chaque region derives des candidats affectes
    for i, ligne in plan.iterrows():
        region = ligne["REGION"]
        jo = affect.loc[(affect["REGION"] == region) & affect["JOUR"].notna(), "JOUR"]
        if not jo.empty:
            plan.at[i, "JOUR_DEBUT"] = int(jo.min())
            plan.at[i, "JOUR_FIN"] = int(jo.max())

    return affect, plan


def nom_feuille(nom):
    """Nom de feuille Excel valide (<=31 car., sans caracteres interdits)."""
    nom = str(nom).replace("/", "-").replace("\\", "-").replace("?", "")
    nom = nom.replace("*", "").replace("[", "(").replace("]", ")").replace(":", "-")
    nom = nom.strip()[:31]
    if not nom:
        nom = "Sans nom"
    return nom


def ecrire(dest, affect, plan):
    with pd.ExcelWriter(dest, engine="openpyxl") as w:
        affect.to_excel(w, sheet_name="Affectation", index=False)
        plan.to_excel(w, sheet_name="Planning", index=False)

        # sous-total par enqueteur
        tot_enq = (affect[affect["N_ENQUETEUR"] != "A PLANIFIER (pas d'enqueteur)"]
                   .groupby(["REGION", "N_ENQUETEUR", "ROLE", "EMAIL_ENQUETEUR"])
                   .agg(NOMBRE=("ID", "count"), JOURS=("JOUR", "max"))
                   .reset_index().sort_values(["REGION", "N_ENQUETEUR"]))
        tot_enq["ENTRETIENS_JOUR"] = ENTRETIENS_PAR_ENQUETEUR_PAR_JOUR
        tot_enq.to_excel(w, sheet_name="Par_enqueteur", index=False)

        # une feuille par enqueteur realisant des entretiens
        cols_aff = (["ID", "NOM ET PRENOM DU (DE LA) CANDIDATE / NOM DU GROUPEMENT",
                     "REGION", "DISTRICT", "LOCALITE", "TELEPHONE", "SEXE", "AGE",
                     "A REFAIRE", "MOTIF REFAIRE", "RANG_ENQUETEUR", "JOUR"] +
                    [c for c in affect.columns
                     if c not in ["ID", "NOM ET PRENOM DU (DE LA) CANDIDATE / NOM DU GROUPEMENT",
                                  "REGION", "DISTRICT", "LOCALITE", "TELEPHONE", "SEXE", "AGE",
                                  "A REFAIRE", "MOTIF REFAIRE", "RANG_ENQUETEUR", "JOUR"]])
        for (region, enq), grp in affect[affect["N_ENQUETEUR"] != "A PLANIFIER (pas d'enqueteur)"].groupby(["REGION", "N_ENQUETEUR"]):
            grp = grp.sort_values("RANG_ENQUETEUR")[cols_aff]
            feuille = nom_feuille(f"{region} - {enq}")
            grp.to_excel(w, sheet_name=feuille, index=False)

    plan_aff = plan[plan["STATUT"].str.startswith("AFFECTE")]
    duree_max = int(plan_aff["JOUR_FIN"].max())
    dtotal = int(plan_aff["CANDIDATS"].sum())
    print(f"ECRIT -> {dest}")
    print(f"Candidats affectes : {dtotal}")
    print()
    print("PLANNING PAR REGION (3 entretiens/enqueteur/jour) :")
    print(plan.to_string(index=False))
    print()
    print(f"DUREE AU TOTAL (regions en parallele) : {duree_max} jours ouvrés")
    print(f"Charge totale : {dtotal} candidats = {dtotal / ENTRETIENS_PAR_ENQUETEUR_PAR_JOUR:.0f} "
          f"journées-enqueteur")
    print("=" * 60)


# ------------------------------------------------------------------ main
xl = pd.ExcelFile(SOURCE)
enq_total = nettoyer_enqueteurs(xl)
cands = nettoyer_candidats(pd.read_excel(xl, sheet_name="enquetés"))

print(f"Enqueteurs : {len(enq_total)} ({len(enq_total[enq_total['role']=='Facilitateur'])} "
      f"facilitateurs, {len(enq_total[enq_total['role']=='Supervision'])} superviseurs)")
print()

# Version 1 : BOUNKANI mis de cote
affect1, plan1 = affecter(cands, enq_total, bounkani_sur_tchologo=False)
ecrire(DEST1, affect1, plan1)

# Version 2 : BOUNKANI affecte aux enqueteurs du TCHOLOGO
affect2, plan2 = affecter(cands, enq_total, bounkani_sur_tchologo=True)
ecrire(DEST2, affect2, plan2)