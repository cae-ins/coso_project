#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 22 14:39:26 2026

@author: macbookair
"""

import os
import pyreadstat
import pandas as pd

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet

coso_vf, meta = pyreadstat.read_dta(os.path.join(RACINE, "resultats", "QUESTIONNAIRE_VF_SANS_DOUBLON_VF.dta"))
migone_data = pd.read_excel(os.path.join(RACINE, "inputs", "candidats_sans_bonne_fiche_20260922_restreint.xlsx"))
teleop_data = pd.read_excel(os.path.join(RACINE, "inputs", "FICHIER PROJET COSO.xlsx"))

print(coso_vf.columns) 
print(migone_data.columns)

coso_vf_filter_migone = coso_vf[
    coso_vf["interview__key"].isin(migone_data["interview_keys"])
    &
    coso_vf["classe_completude"].isin(["4-INCOMPLET", "5-VIDE"])
]



tcd = pd.pivot_table(
    coso_vf_filter_migone,
    index = "classe_completude",
    aggfunc = "count")

