# -*- coding: utf-8 -*-
"""Cree la base CANDIDAT_ENQUETE_TERRAIN.xlsx (les 1024 candidats
sans fiche COMPLET/QUASI), a partir de Base_Candidats_COSO_contactes."""

import os
import pandas as pd

ICI = os.path.dirname(os.path.abspath(__file__))
RACINE = os.path.dirname(os.path.dirname(ICI))     # racine du projet
SOURCE = os.path.join(RACINE, "inputs", "Base_Candidats_COSO_contactés.xlsx")
DEST = os.path.join(RACINE, "MIGONE", "outputs", "CANDIDAT_ENQUETE_TERRAIN.xlsx")

base = pd.read_excel(SOURCE, sheet_name="Base complète")
print(f"Source : {len(base)} candidats")

base.to_excel(DEST, index=False, sheet_name="Enquete terrain")
print(f"Créé : {DEST} ({len(base)} lignes)")