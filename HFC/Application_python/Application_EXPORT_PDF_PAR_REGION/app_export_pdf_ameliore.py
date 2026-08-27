# -*- coding: utf-8 -*-
"""
================================================================================
APPLICATION : Export PDF par groupe depuis Excel
================================================================================
Convertit les données d'un fichier Excel en fichiers PDF regroupés
par valeur d'une colonne choisie (Région, District, Équipe, etc.)
================================================================================
AUTEUR  : mg.kouame
VERSION : 1.0
================================================================================
"""

import os
import sys
import subprocess
import importlib
import importlib.util
import threading
import traceback
from datetime import datetime

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext

# ── Modules optionnels (auto-installés si absents) ───────────────────────────
try:
    import pandas as pd
except ImportError:
    pd = None

try:
    from reportlab.lib.pagesizes import A4, landscape
    from reportlab.lib import colors
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import cm, mm
    from reportlab.platypus import (SimpleDocTemplate, Table, TableStyle,
                                    Paragraph, Spacer, HRFlowable,
                                    KeepTogether, PageBreak)
    from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
    from reportlab.graphics.shapes import Drawing, Rect
    REPORTLAB_OK = True
except ImportError:
    REPORTLAB_OK = False

try:
    from PIL import Image as PILImage
    PIL_OK = True
except ImportError:
    PIL_OK = False

# ==============================================================================
# AUTO-INSTALLATION
# ==============================================================================

MODULES_REQUIS = [
    ("pandas",     "pandas"),
    ("openpyxl",   "openpyxl"),
    ("reportlab",  "reportlab"),
    ("PIL",        "Pillow"),
]

def verifier_connexion():
    import socket
    try:
        socket.setdefaulttimeout(5)
        socket.create_connection(("8.8.8.8", 53))
        return True
    except OSError:
        return False

def installer_module(nom_pip):
    try:
        result = subprocess.run(
            [sys.executable, "-m", "pip", "install", nom_pip,
             "--quiet", "--no-warn-script-location"],
            capture_output=True, text=True, timeout=180
        )
        return result.returncode == 0, result.stderr[:300]
    except Exception as e:
        return False, str(e)

def auto_installer():
    """Vérifie et installe les modules manquants. Retourne la liste des manquants."""
    manquants = [
        (ni, np) for ni, np in MODULES_REQUIS
        if importlib.util.find_spec(ni) is None
    ]
    if not manquants:
        return []

    splash = tk.Tk()
    splash.title("Initialisation")
    splash.geometry("480x300")
    splash.resizable(False, False)
    splash.configure(bg="#0D1117")
    splash.eval('tk::PlaceWindow . center')

    tk.Label(splash, text="⚙️  Initialisation de l'application",
             font=("Segoe UI", 12, "bold"), fg="#79C0FF",
             bg="#0D1117").pack(pady=(18, 4))
    tk.Label(splash,
             text="Installation automatique des modules requis…",
             font=("Segoe UI", 9), fg="#8B949E", bg="#0D1117").pack()

    zone = scrolledtext.ScrolledText(
        splash, font=("Consolas", 8), bg="#161B22", fg="#C9D1D9",
        height=7, relief="flat")
    zone.pack(fill="x", padx=16, pady=8)
    zone.tag_config("ok",  foreground="#56D364")
    zone.tag_config("err", foreground="#F85149")
    zone.tag_config("warn",foreground="#E3B341")

    barre = ttk.Progressbar(splash, mode="determinate",
                            maximum=len(manquants), value=0)
    barre.pack(fill="x", padx=16)
    lbl = tk.Label(splash, text="", font=("Segoe UI", 8),
                   fg="#8B949E", bg="#0D1117")
    lbl.pack(pady=4)

    encore = []

    def _log(msg, tag="info"):
        zone.insert("end", msg + "\n", tag)
        zone.see("end")
        splash.update()

    def _run():
        nonlocal encore
        _log("🌐 Vérification connexion internet…")
        if not verifier_connexion():
            _log("❌ Pas de connexion internet !\n"
                 "   Connectez-vous puis relancez l'application.", "err")
            lbl.config(text="⚠️  Connexion requise", fg="#E3B341")
            tk.Button(splash, text="Fermer",
                      font=("Segoe UI", 9, "bold"),
                      bg="#8B0000", fg="white", relief="flat",
                      command=lambda: (splash.destroy(), sys.exit(1))
                      ).pack(pady=6)
            return
        _log("✅ Connexion OK", "ok")
        for i, (ni, np_) in enumerate(manquants, 1):
            lbl.config(text=f"Installation de '{np_}'… ({i}/{len(manquants)})")
            _log(f"⬇️  Installation de '{np_}'…")
            ok, err = installer_module(np_)
            if ok:
                _log(f"✅ '{np_}' installé.", "ok")
                try:
                    importlib.invalidate_caches()
                    importlib.import_module(ni)
                except Exception:
                    encore.append((ni, np_))
            else:
                _log(f"❌ Erreur : {err}", "err")
                encore.append((ni, np_))
            barre['value'] = i
            splash.update()

        if encore:
            _log(f"⚠️  Modules toujours manquants : "
                 f"{', '.join(p for _,p in encore)}", "warn")
            tk.Button(splash, text="Continuer quand même →",
                      font=("Segoe UI", 9, "bold"),
                      bg="#C0782A", fg="white", relief="flat",
                      command=splash.destroy).pack(pady=6)
        else:
            _log("✅ Tous les modules sont prêts. Lancement…", "ok")
            splash.after(1000, splash.destroy)

    threading.Thread(target=_run, daemon=True).start()
    splash.mainloop()
    return encore

# ==============================================================================
# GÉNÉRATION PDF  (ReportLab)
# ==============================================================================

def creer_pdf_groupe(df_groupe, nom_groupe, colonnes, titre_doc,
                     prefixe, dossier, nom_feuille, logo_path=None,
                     sous_titre=""):
    """
    Génère un PDF soigné pour un groupe de données.
    Retourne le chemin du fichier créé.
    """
    from reportlab.lib.pagesizes import A4, landscape
    from reportlab.lib import colors
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import cm, mm
    from reportlab.platypus import (SimpleDocTemplate, Table, TableStyle,
                                    Paragraph, Spacer, HRFlowable,
                                    KeepTogether, Image)
    from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT

    # Palette de couleurs (définie ici pour garantir que colors est chargé)
    PDF_COULEUR_HEADER  = colors.HexColor("#1A3A5C")
    PDF_COULEUR_HEADER2 = colors.HexColor("#2E6DA4")
    PDF_COULEUR_LIGNE1  = colors.HexColor("#EBF2FA")
    PDF_COULEUR_LIGNE2  = colors.white
    PDF_COULEUR_ACCENT  = colors.HexColor("#E8A020")
    PDF_COULEUR_TEXTE   = colors.HexColor("#1A1A2E")

    # Nom du fichier
    nom_safe = re.sub(r'[\\/*?:"<>|]', "_", str(nom_groupe))
    if prefixe:
        nom_fichier = f"{prefixe}_{nom_safe}.pdf"
    else:
        nom_fichier = f"{nom_safe}.pdf"
    chemin = os.path.join(dossier, nom_fichier)

    page_size = landscape(A4)
    doc = SimpleDocTemplate(
        chemin,
        pagesize=page_size,
        leftMargin=1.2*cm, rightMargin=1.2*cm,
        topMargin=2.8*cm,  bottomMargin=1.8*cm,
        title=f"{titre_doc} — {nom_groupe}",
        author="ENEM — mg.kouame"
    )

    styles = getSampleStyleSheet()

    # Styles personnalisés
    style_titre = ParagraphStyle(
        "MonTitre",
        fontName="Helvetica-Bold",
        fontSize=16,
        textColor=PDF_COULEUR_HEADER,
        alignment=TA_CENTER,
        spaceAfter=2*mm,
        leading=20
    )
    style_sous_titre = ParagraphStyle(
        "MonSousTitre",
        fontName="Helvetica",
        fontSize=10,
        textColor=PDF_COULEUR_HEADER2,
        alignment=TA_CENTER,
        spaceAfter=1*mm
    )
    style_groupe = ParagraphStyle(
        "MonGroupe",
        fontName="Helvetica-Bold",
        fontSize=13,
        textColor=PDF_COULEUR_ACCENT,
        alignment=TA_CENTER,
        spaceAfter=3*mm
    )
    style_meta = ParagraphStyle(
        "MonMeta",
        fontName="Helvetica-Oblique",
        fontSize=8,
        textColor=colors.HexColor("#666677"),
        alignment=TA_RIGHT,
        spaceAfter=2*mm
    )
    style_cell = ParagraphStyle(
        "CellNorm",
        fontName="Helvetica",
        fontSize=8,
        textColor=PDF_COULEUR_TEXTE,
        leading=11
    )
    style_cell_bold = ParagraphStyle(
        "CellBold",
        fontName="Helvetica-Bold",
        fontSize=8,
        textColor=colors.white,
        leading=11,
        alignment=TA_CENTER
    )

    elements = []

    # ── En-tête du document ───────────────────────────────────────────────────
    elements.append(Paragraph(titre_doc or "Rapport", style_titre))
    if sous_titre:
        elements.append(Paragraph(sous_titre, style_sous_titre))
    elements.append(HRFlowable(
        width="100%", thickness=2,
        color=PDF_COULEUR_ACCENT, spaceAfter=3*mm
    ))
    elements.append(Paragraph(f"▌  {nom_groupe}", style_groupe))
    elements.append(Paragraph(
        f"Feuille : {nom_feuille}   •   "
        f"{len(df_groupe)} enregistrement(s)   •   "
        f"Généré le {datetime.now().strftime('%d/%m/%Y à %H:%M')}",
        style_meta
    ))
    elements.append(Spacer(1, 3*mm))

    # ── Tableau de données ────────────────────────────────────────────────────
    # En-têtes
    entetes = [Paragraph(str(c), style_cell_bold) for c in colonnes]
    data = [entetes]

    # Lignes
    for idx, row in df_groupe[colonnes].iterrows():
        ligne = []
        for val in row:
            texte = "" if pd.isna(val) else str(val)
            ligne.append(Paragraph(texte, style_cell))
        data.append(ligne)

    # Largeur des colonnes : répartition proportionnelle
    page_w = page_size[0] - 2.4*cm
    nb_cols = len(colonnes)
    col_w = [page_w / nb_cols] * nb_cols

    table = Table(data, colWidths=col_w, repeatRows=1)

    # Style du tableau
    ts = TableStyle([
        # En-tête
        ("BACKGROUND",   (0, 0), (-1, 0), PDF_COULEUR_HEADER),
        ("TEXTCOLOR",    (0, 0), (-1, 0), colors.white),
        ("FONTNAME",     (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE",     (0, 0), (-1, 0), 8),
        ("ALIGN",        (0, 0), (-1, 0), "CENTER"),
        ("VALIGN",       (0, 0), (-1, 0), "MIDDLE"),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1),
         [PDF_COULEUR_LIGNE1, PDF_COULEUR_LIGNE2]),
        ("GRID",         (0, 0), (-1, -1), 0.4, colors.HexColor("#C0CCE0")),
        ("LINEBELOW",    (0, 0), (-1, 0), 1.5, PDF_COULEUR_ACCENT),
        ("TOPPADDING",   (0, 0), (-1, -1), 3),
        ("BOTTOMPADDING",(0, 0), (-1, -1), 3),
        ("LEFTPADDING",  (0, 0), (-1, -1), 4),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
        ("VALIGN",       (0, 1), (-1, -1), "TOP"),
        # Ligne de séparation renforcée toutes les 5 lignes
        *[("LINEBELOW", (0, r), (-1, r), 0.8, colors.HexColor("#B0C0D8"))
          for r in range(5, len(data), 5)],
    ])
    table.setStyle(ts)
    elements.append(table)

    # ── Pied de page (via canvas) ─────────────────────────────────────────────
    def pied_de_page(canvas, doc):
        canvas.saveState()
        w, h = page_size
        # Bande de pied
        canvas.setFillColor(PDF_COULEUR_HEADER)
        canvas.rect(0, 0, w, 1.2*cm, fill=1, stroke=0)
        # Texte pied
        canvas.setFillColor(colors.white)
        canvas.setFont("Helvetica", 7)
        canvas.drawString(1.2*cm, 0.45*cm,
                          f"{titre_doc}  —  {nom_groupe}")
        canvas.drawRightString(w - 1.2*cm, 0.45*cm,
                               f"Page {doc.page}")
        # Ligne accent en haut
        canvas.setFillColor(PDF_COULEUR_ACCENT)
        canvas.rect(0, h - 0.35*cm, w, 0.35*cm, fill=1, stroke=0)
        canvas.setFillColor(PDF_COULEUR_HEADER)
        canvas.rect(0, h - 0.7*cm, w, 0.35*cm, fill=1, stroke=0)
        canvas.restoreState()

    doc.build(elements,
              onFirstPage=pied_de_page,
              onLaterPages=pied_de_page)
    return chemin

# ==============================================================================
# HELPERS
# ==============================================================================

import re

def get_sheets(filepath):
    return pd.ExcelFile(filepath).sheet_names

def get_columns(filepath, sheet):
    df = pd.read_excel(filepath, sheet_name=sheet, nrows=0)
    return list(df.columns)

def timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# ==============================================================================
# INTERFACE TKINTER
# ==============================================================================

# Palette interface
C_FOND     = "#F4F7FB"
C_TITRE    = "#1A3A5C"
C_SECTION  = "#2E6DA4"
C_ACCENT   = "#E8A020"
C_BTN_OK   = "#1E7A45"
C_BTN_QUIT = "#8B0000"
C_BTN_ANN  = "#5C5C6E"
P_TITRE    = ("Segoe UI", 13, "bold")
P_SECTION  = ("Segoe UI", 10, "bold")
P_NORM     = ("Segoe UI", 9)
P_MONO     = ("Consolas", 9)
P_SMALL    = ("Segoe UI", 8)


class AppExportPDF(tk.Tk):

    def __init__(self):
        super().__init__()
        self.title("Export PDF par groupe — Excel → PDF")
        self.geometry("820x760")
        self.minsize(740, 640)
        self.configure(bg=C_FOND)
        self.resizable(True, True)

        # État
        self._annuler = False
        self._en_cours = False
        self._df_cache = {}           # {(fichier, feuille): DataFrame}
        self._cols_cache = {}         # {(fichier, feuille): [colonnes]}
        self._check_cols = {}         # {nom_col: BooleanVar}
        self._feuilles_vars = {}      # {nom_feuille: BooleanVar}

        # Variables
        self.v_fichier     = tk.StringVar()
        self.v_dossier_out = tk.StringVar()
        self.v_col_groupe  = tk.StringVar()
        self.v_prefixe     = tk.StringVar()
        self.v_titre_doc   = tk.StringVar(value="Rapport de collecte")
        self.v_sous_titre  = tk.StringVar()
        self.v_logo        = tk.StringVar()

        self._build_ui()

    # ── Construction de l'interface ──────────────────────────────────────────

    def _build_ui(self):
        # ── Barre de titre ────────────────────────────────────────────────────
        hdr = tk.Frame(self, bg=C_TITRE, pady=0)
        hdr.pack(fill="x")

        # Bande accent
        tk.Frame(hdr, bg=C_ACCENT, height=4).pack(fill="x")

        inner_hdr = tk.Frame(hdr, bg=C_TITRE, pady=12, padx=20)
        inner_hdr.pack(fill="x")
        tk.Label(inner_hdr,
                 text="📄  EXPORT PDF PAR GROUPE",
                 font=("Segoe UI", 15, "bold"),
                 fg="white", bg=C_TITRE).pack(side="left")
        tk.Label(inner_hdr,
                 text="Excel  →  PDF  •  Regroupement automatique",
                 font=P_SMALL, fg="#AAC8E8", bg=C_TITRE).pack(side="right")

        # ── Notebook ─────────────────────────────────────────────────────────
        style = ttk.Style(self)
        style.theme_use("clam")
        style.configure("Accent.TNotebook.Tab",
                        font=P_SECTION, padding=[14, 5],
                        background="#D8E6F5")
        style.map("Accent.TNotebook.Tab",
                  background=[("selected", C_SECTION)],
                  foreground=[("selected", "white")])

        nb = ttk.Notebook(self, style="Accent.TNotebook")
        nb.pack(fill="both", expand=True, padx=10, pady=8)

        self.tab_config  = tk.Frame(nb, bg=C_FOND)
        self.tab_colonnes= tk.Frame(nb, bg=C_FOND)
        self.tab_export  = tk.Frame(nb, bg=C_FOND)

        nb.add(self.tab_config,   text="  ① Source & Regroupement  ")
        nb.add(self.tab_colonnes, text="  ② Colonnes & Feuilles  ")
        nb.add(self.tab_export,   text="  ③ Export & Progression  ")
        self.nb = nb

        self._build_tab_config()
        self._build_tab_colonnes()
        self._build_tab_export()

        # ── Barre de boutons globale ──────────────────────────────────────────
        bbar = tk.Frame(self, bg=C_FOND, pady=6)
        bbar.pack(fill="x", padx=12)

        tk.Button(
            bbar, text="▶  GÉNÉRER LES PDF",
            font=("Segoe UI", 10, "bold"),
            bg=C_BTN_OK, fg="white",
            padx=18, pady=7, relief="flat", cursor="hand2",
            command=self._lancer_export
        ).pack(side="left", padx=(0, 8))

        self.btn_annuler = tk.Button(
            bbar, text="⏹  Annuler",
            font=P_NORM, bg=C_BTN_ANN, fg="white",
            padx=12, pady=7, relief="flat", cursor="hand2",
            state="disabled",
            command=self._annuler_export
        )
        self.btn_annuler.pack(side="left", padx=(0, 8))

        tk.Button(
            bbar, text="✖  Quitter",
            font=P_NORM, bg=C_BTN_QUIT, fg="white",
            padx=12, pady=7, relief="flat", cursor="hand2",
            command=self._quitter
        ).pack(side="right")

        self.lbl_statut = tk.Label(bbar, text="", font=("Segoe UI", 9, "bold"),
                                   bg=C_FOND)
        self.lbl_statut.pack(side="left", padx=12)

    # ── Onglet 1 : Source & Regroupement ─────────────────────────────────────

    def _build_tab_config(self):
        p = self.tab_config
        canvas = tk.Canvas(p, bg=C_FOND, highlightthickness=0)
        sb = ttk.Scrollbar(p, orient="vertical", command=canvas.yview)
        frame = tk.Frame(canvas, bg=C_FOND)
        frame.bind("<Configure>",
                   lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=frame, anchor="nw")
        canvas.configure(yscrollcommand=sb.set)
        canvas.pack(side="left", fill="both", expand=True)
        sb.pack(side="right", fill="y")

        def section(titre):
            f = tk.LabelFrame(frame, text=f"  {titre}  ",
                              font=P_SECTION, fg=C_SECTION,
                              bg=C_FOND, padx=14, pady=10, relief="groove")
            f.pack(fill="x", padx=14, pady=8)
            return f

        XL = [("Fichiers Excel", "*.xlsx *.xls")]
        IMG = [("Images", "*.png *.jpg *.jpeg")]

        # ── Fichier source ────────────────────────────────────────────────────
        s1 = section("Fichier Excel source")
        tk.Label(s1, text="Sélectionnez le fichier Excel contenant vos données.",
                 font=P_SMALL, fg="#555", bg=C_FOND
                 ).grid(row=0, column=0, columnspan=3, sticky="w")
        e_fich = tk.Entry(s1, textvariable=self.v_fichier,
                          font=P_MONO, width=60)
        e_fich.grid(row=1, column=0, columnspan=2, sticky="ew", pady=3)
        tk.Button(s1, text="📁 Parcourir", font=P_NORM,
                  bg="#E0EAF8", relief="flat", cursor="hand2",
                  command=self._charger_fichier
                  ).grid(row=1, column=2, sticky="w", padx=4)
        s1.columnconfigure(0, weight=1)

        # ── Titre et sous-titre du PDF ────────────────────────────────────────
        s2 = section("Titre et présentation du PDF")
        self._entry_row(s2, "Titre principal du document *",
                        self.v_titre_doc,
                        "Apparaît en grand en haut de chaque PDF.", 0)
        self._entry_row(s2, "Sous-titre (optionnel)",
                        self.v_sous_titre,
                        "Ex: Enquête T1-2026 — Données terrain.", 2)
        self._entry_row(s2, "Préfixe des fichiers PDF",
                        self.v_prefixe,
                        "Ex: 'Rapport_T1' → fichiers nommés Rapport_T1_ABIDJAN.pdf", 4)

        # ── Logo ──────────────────────────────────────────────────────────────
        s3 = section("Logo (optionnel)")
        tk.Label(s3, text="Image PNG/JPG à afficher dans l'en-tête du PDF.",
                 font=P_SMALL, fg="#555", bg=C_FOND
                 ).grid(row=0, column=0, columnspan=3, sticky="w")
        tk.Entry(s3, textvariable=self.v_logo,
                 font=P_MONO, width=55
                 ).grid(row=1, column=0, columnspan=2, sticky="ew", pady=3)
        tk.Button(s3, text="🖼 Parcourir", font=P_NORM,
                  bg="#E0EAF8", relief="flat", cursor="hand2",
                  command=lambda: self._browse(self.v_logo, IMG)
                  ).grid(row=1, column=2, sticky="w", padx=4)
        s3.columnconfigure(0, weight=1)

        # ── Dossier de sortie ─────────────────────────────────────────────────
        s4 = section("Dossier de sortie")
        tk.Label(s4, text="Les fichiers PDF seront enregistrés dans ce dossier.",
                 font=P_SMALL, fg="#555", bg=C_FOND
                 ).grid(row=0, column=0, columnspan=3, sticky="w")
        tk.Entry(s4, textvariable=self.v_dossier_out,
                 font=P_MONO, width=60
                 ).grid(row=1, column=0, columnspan=2, sticky="ew", pady=3)
        tk.Button(s4, text="📁 Parcourir", font=P_NORM,
                  bg="#E0EAF8", relief="flat", cursor="hand2",
                  command=lambda: self._browse_dir(self.v_dossier_out)
                  ).grid(row=1, column=2, sticky="w", padx=4)
        s4.columnconfigure(0, weight=1)

    def _entry_row(self, parent, label, var, aide, row):
        tk.Label(parent, text=label, font=P_NORM,
                 bg=C_FOND, anchor="w"
                 ).grid(row=row, column=0, columnspan=3, sticky="w", pady=(6, 1))
        tk.Entry(parent, textvariable=var, font=P_NORM, width=55
                 ).grid(row=row+1, column=0, columnspan=3, sticky="ew")
        tk.Label(parent, text=aide, font=P_SMALL, fg="#666",
                 bg=C_FOND
                 ).grid(row=row+2, column=0, columnspan=3, sticky="w", pady=(0, 4))
        parent.columnconfigure(0, weight=1)

    # ── Onglet 2 : Colonnes & Feuilles ────────────────────────────────────────

    def _build_tab_colonnes(self):
        p = self.tab_colonnes
        canvas = tk.Canvas(p, bg=C_FOND, highlightthickness=0)
        sb = ttk.Scrollbar(p, orient="vertical", command=canvas.yview)
        self._frame_cols = tk.Frame(canvas, bg=C_FOND)
        self._frame_cols.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=self._frame_cols, anchor="nw")
        canvas.configure(yscrollcommand=sb.set)
        canvas.pack(side="left", fill="both", expand=True)
        sb.pack(side="right", fill="y")

        tk.Label(self._frame_cols,
                 text="⚠️  Chargez d'abord le fichier Excel dans l'onglet ① "
                      "pour voir les feuilles et colonnes disponibles.",
                 font=P_SMALL, fg="#888", bg=C_FOND,
                 wraplength=600, justify="left"
                 ).pack(padx=14, pady=20)

    def _rafraichir_tab_colonnes(self):
        """Reconstruit l'onglet 2 avec les feuilles et colonnes chargées."""
        frame = self._frame_cols
        for w in frame.winfo_children():
            w.destroy()
        self._feuilles_vars = {}
        self._check_cols = {}

        fichier = self.v_fichier.get()
        if not fichier or not os.path.exists(fichier):
            return

        try:
            sheets = get_sheets(fichier)
        except Exception as e:
            tk.Label(frame, text=f"Erreur : {e}", fg="red",
                     bg=C_FOND, font=P_NORM).pack(padx=14, pady=10)
            return

        # ── Feuilles à traiter ────────────────────────────────────────────────
        sf = tk.LabelFrame(frame, text="  Feuilles à traiter (cochez) ",
                           font=P_SECTION, fg=C_SECTION,
                           bg=C_FOND, padx=14, pady=10, relief="groove")
        sf.pack(fill="x", padx=14, pady=(12, 6))

        tk.Label(sf, text="Cochez les feuilles à inclure dans l'export.",
                 font=P_SMALL, fg="#555", bg=C_FOND
                 ).pack(anchor="w")

        feuilles_frame = tk.Frame(sf, bg=C_FOND)
        feuilles_frame.pack(fill="x", pady=4)

        for i, sh in enumerate(sheets):
            v = tk.BooleanVar(value=False)
            self._feuilles_vars[sh] = v
            cb = tk.Checkbutton(
                feuilles_frame, text=sh, variable=v,
                font=P_NORM, bg=C_FOND,
                activebackground=C_FOND,
                command=lambda s=sh: self._on_feuille_change(s)
            )
            cb.grid(row=i // 4, column=i % 4, sticky="w", padx=8, pady=2)

        # ── Colonne de regroupement ───────────────────────────────────────────
        sg = tk.LabelFrame(frame,
                           text="  Colonne de regroupement  ",
                           font=P_SECTION, fg=C_SECTION,
                           bg=C_FOND, padx=14, pady=10, relief="groove")
        sg.pack(fill="x", padx=14, pady=6)

        tk.Label(sg,
                 text="Chaque valeur unique de cette colonne produira un fichier PDF séparé.\n"
                      "Exemple : si vous choisissez 'REGION', vous obtiendrez 1 PDF par région.",
                 font=P_SMALL, fg="#555", bg=C_FOND, justify="left"
                 ).pack(anchor="w")

        # Charger les colonnes de la première feuille cochée
        self._combo_groupe = ttk.Combobox(
            sg, textvariable=self.v_col_groupe,
            width=40, font=P_NORM, state="readonly")
        self._combo_groupe.pack(anchor="w", pady=4)
        self._maj_colonnes_groupe()

        # ── Colonnes à exclure ────────────────────────────────────────────────
        self._frame_excl_outer = tk.LabelFrame(
            frame,
            text="  Colonnes à exclure du PDF (cochez pour exclure)  ",
            font=P_SECTION, fg=C_SECTION,
            bg=C_FOND, padx=14, pady=10, relief="groove")
        self._frame_excl_outer.pack(fill="x", padx=14, pady=6)

        tk.Label(self._frame_excl_outer,
                 text="Les colonnes cochées N'apparaîtront PAS dans les PDF générés.",
                 font=P_SMALL, fg="#555", bg=C_FOND
                 ).pack(anchor="w")

        self._frame_excl = tk.Frame(self._frame_excl_outer, bg=C_FOND)
        self._frame_excl.pack(fill="x", pady=4)
        self._maj_colonnes_excl()

    def _on_feuille_change(self, sheet_name):
        self._maj_colonnes_groupe()
        self._maj_colonnes_excl()

    def _maj_colonnes_groupe(self):
        """Met à jour le combo de la colonne de regroupement."""
        fichier = self.v_fichier.get()
        if not fichier:
            return
        # Prendre la première feuille cochée
        for sh, v in self._feuilles_vars.items():
            if v.get():
                try:
                    cols = get_columns(fichier, sh)
                    self._combo_groupe['values'] = cols
                    if cols and not self.v_col_groupe.get():
                        self._combo_groupe.current(0)
                except Exception:
                    pass
                return

    def _maj_colonnes_excl(self):
        """Reconstruit les checkboxes d'exclusion de colonnes."""
        if not hasattr(self, '_frame_excl'):
            return
        for w in self._frame_excl.winfo_children():
            w.destroy()
        self._check_cols = {}

        fichier = self.v_fichier.get()
        if not fichier:
            return

        cols = []
        for sh, v in self._feuilles_vars.items():
            if v.get():
                try:
                    cols = get_columns(fichier, sh)
                    break
                except Exception:
                    pass

        for i, col in enumerate(cols):
            bv = tk.BooleanVar(value=False)
            self._check_cols[col] = bv
            cb = tk.Checkbutton(
                self._frame_excl, text=col, variable=bv,
                font=P_SMALL, bg=C_FOND, activebackground=C_FOND,
                wraplength=160
            )
            cb.grid(row=i // 4, column=i % 4, sticky="w", padx=6, pady=2)

    # ── Onglet 3 : Export & Logs ──────────────────────────────────────────────

    def _build_tab_export(self):
        p = self.tab_export

        # Barre de progression
        prog_frame = tk.Frame(p, bg=C_FOND, pady=8)
        prog_frame.pack(fill="x", padx=12)

        tk.Label(prog_frame, text="Progression :", font=P_NORM,
                 bg=C_FOND).pack(side="left")

        self.progress = ttk.Progressbar(
            prog_frame, mode="determinate",
            length=420, maximum=100, value=0)
        self.progress.pack(side="left", padx=8)

        self.lbl_pct = tk.Label(prog_frame, text="0%",
                                font=("Segoe UI", 9, "bold"),
                                fg=C_SECTION, bg=C_FOND, width=6)
        self.lbl_pct.pack(side="left")

        # Zone de logs
        self.zone_logs = scrolledtext.ScrolledText(
            p, font=P_MONO, bg="#0D1117", fg="#C9D1D9",
            insertbackground="white", relief="flat", wrap="none"
        )
        self.zone_logs.pack(fill="both", expand=True, padx=10, pady=(0, 4))
        self.zone_logs.tag_config("ok",    foreground="#56D364")
        self.zone_logs.tag_config("err",   foreground="#F85149")
        self.zone_logs.tag_config("warn",  foreground="#E3B341")
        self.zone_logs.tag_config("titre", foreground="#79C0FF",
                                  font=("Consolas", 9, "bold"))
        self.zone_logs.tag_config("info",  foreground="#C9D1D9")

        # Bouton effacer logs
        tk.Button(p, text="🗑  Effacer les logs", font=P_SMALL,
                  bg="#2A2A3A", fg="#C9D1D9", relief="flat", cursor="hand2",
                  command=lambda: self.zone_logs.delete("1.0", "end")
                  ).pack(anchor="e", padx=10)

    # ── Chargement fichier ────────────────────────────────────────────────────

    def _charger_fichier(self):
        f = filedialog.askopenfilename(
            filetypes=[("Fichiers Excel", "*.xlsx *.xls")])
        if not f:
            return
        self.v_fichier.set(f)
        # Dossier de sortie par défaut = même dossier que le fichier
        if not self.v_dossier_out.get():
            self.v_dossier_out.set(os.path.dirname(f))
        self._rafraichir_tab_colonnes()
        self.nb.select(1)  # Aller à l'onglet Colonnes

    def _browse(self, var, types):
        f = filedialog.askopenfilename(filetypes=types)
        if f:
            var.set(f)

    def _browse_dir(self, var):
        d = filedialog.askdirectory()
        if d:
            var.set(d)

    # ── Log ──────────────────────────────────────────────────────────────────

    def _log(self, msg, tag="info"):
        def _w():
            self.zone_logs.insert("end", msg + "\n", tag)
            self.zone_logs.see("end")
        self.after(0, _w)

    def _set_progress(self, pct):
        def _w():
            self.progress['value'] = min(pct, 100)
            self.lbl_pct.config(text=f"{int(pct)}%")
        self.after(0, _w)

    def _set_statut(self, msg, couleur="#333"):
        self.after(0, lambda: self.lbl_statut.config(text=msg, fg=couleur))

    # ── Export ───────────────────────────────────────────────────────────────

    def _lancer_export(self):
        if self._en_cours:
            return

        # Validation
        erreurs = []
        if not self.v_fichier.get() or not os.path.exists(self.v_fichier.get()):
            erreurs.append("Fichier Excel source introuvable.")
        if not self.v_dossier_out.get():
            erreurs.append("Dossier de sortie non défini.")
        if not self.v_col_groupe.get():
            erreurs.append("Colonne de regroupement non sélectionnée.")
        feuilles_cochees = [sh for sh, v in self._feuilles_vars.items() if v.get()]
        if not feuilles_cochees:
            erreurs.append("Aucune feuille sélectionnée.")
        if not REPORTLAB_OK:
            erreurs.append("Le module 'reportlab' n'est pas disponible.")
        if erreurs:
            messagebox.showerror("Paramètres invalides",
                                 "\n".join(f"• {e}" for e in erreurs))
            return

        self._annuler = False
        self._en_cours = True
        self.btn_annuler.config(state="normal")
        self._set_progress(0)
        self._set_statut("⏳ Export en cours…", "#E3B341")
        self.nb.select(2)  # Aller aux logs

        params = {
            'fichier':       self.v_fichier.get(),
            'dossier_out':   self.v_dossier_out.get(),
            'col_groupe':    self.v_col_groupe.get(),
            'prefixe':       self.v_prefixe.get().strip(),
            'titre_doc':     self.v_titre_doc.get().strip(),
            'sous_titre':    self.v_sous_titre.get().strip(),
            'logo':          self.v_logo.get().strip(),
            'feuilles':      feuilles_cochees,
            'cols_exclure':  [c for c, v in self._check_cols.items() if v.get()],
        }

        threading.Thread(
            target=self._run_export, args=(params,), daemon=True
        ).start()

    def _run_export(self, params):
        """Exécution dans un thread séparé."""
        try:
            fichier      = params['fichier']
            dossier_out  = params['dossier_out']
            col_groupe   = params['col_groupe']
            prefixe      = params['prefixe']
            titre_doc    = params['titre_doc']
            sous_titre   = params['sous_titre']
            logo         = params['logo']
            feuilles     = params['feuilles']
            cols_exclure = params['cols_exclure']

            os.makedirs(dossier_out, exist_ok=True)

            sep = "=" * 60
            self._log(sep, "titre")
            self._log("  EXPORT PDF PAR GROUPE", "titre")
            self._log(sep, "titre")
            self._log(f"  Fichier  : {os.path.basename(fichier)}")
            self._log(f"  Feuilles : {', '.join(feuilles)}")
            self._log(f"  Groupe   : {col_groupe}")
            self._log(f"  Sortie   : {dossier_out}")
            self._log("")

            total_pdfs = 0
            total_err  = 0

            # Calculer le nombre total de PDF à produire
            nb_groupes_total = 0
            for feuille in feuilles:
                try:
                    df = pd.read_excel(fichier, sheet_name=feuille, dtype=str)
                    df = df.fillna("")
                    if col_groupe in df.columns:
                        nb_groupes_total += df[col_groupe].nunique()
                except Exception:
                    pass

            fait = 0

            for feuille in feuilles:
                if self._annuler:
                    self._log("\n⏹  Export annulé par l'utilisateur.", "warn")
                    break

                self._log(f"\n📋 Feuille : {feuille}", "titre")

                try:
                    df = pd.read_excel(fichier, sheet_name=feuille, dtype=str)
                    df = df.fillna("")
                    self._log(f"   ✓ {len(df)} lignes chargées", "ok")
                except Exception as e:
                    self._log(f"   ❌ Erreur lecture : {e}", "err")
                    continue

                if col_groupe not in df.columns:
                    self._log(f"   ⚠️  Colonne '{col_groupe}' absente "
                              f"dans cette feuille — ignorée.", "warn")
                    continue

                # Colonnes à garder
                colonnes = [c for c in df.columns if c not in cols_exclure]

                # Créer un sous-dossier par feuille si plusieurs feuilles
                if len(feuilles) > 1:
                    dossier_feuille = os.path.join(dossier_out, feuille)
                    os.makedirs(dossier_feuille, exist_ok=True)
                else:
                    dossier_feuille = dossier_out

                groupes = df[col_groupe].unique()
                self._log(f"   → {len(groupes)} groupe(s) détecté(s) "
                          f"dans '{col_groupe}'")

                for groupe in groupes:
                    if self._annuler:
                        break

                    df_g = df[df[col_groupe] == groupe]
                    self._log(f"   📄 {groupe}  ({len(df_g)} lignes)…")

                    try:
                        chemin = creer_pdf_groupe(
                            df_groupe  = df_g,
                            nom_groupe = groupe,
                            colonnes   = colonnes,
                            titre_doc  = titre_doc,
                            prefixe    = prefixe,
                            dossier    = dossier_feuille,
                            nom_feuille= feuille,
                            logo_path  = logo if logo and os.path.exists(logo) else None,
                            sous_titre = sous_titre,
                        )
                        self._log(f"      ✅ {os.path.basename(chemin)}", "ok")
                        total_pdfs += 1
                    except Exception as e:
                        self._log(f"      ❌ Erreur : {e}", "err")
                        self._log(traceback.format_exc(), "err")
                        total_err += 1

                    fait += 1
                    if nb_groupes_total > 0:
                        self._set_progress(fait / nb_groupes_total * 100)

            # Résumé
            self._log(f"\n{sep}", "titre")
            self._log("  RÉSUMÉ", "titre")
            self._log(sep, "titre")
            self._log(f"  ✅ PDF générés : {total_pdfs}", "ok")
            if total_err:
                self._log(f"  ❌ Erreurs     : {total_err}", "err")
            self._log(f"  📂 Dossier     : {dossier_out}")
            self._log(sep, "titre")

            self._set_progress(100)
            if not self._annuler:
                self._set_statut(
                    f"✅ {total_pdfs} PDF générés !", "#56D364")
                self.after(0, lambda: messagebox.showinfo(
                    "Export terminé",
                    f"{total_pdfs} fichier(s) PDF généré(s) avec succès.\n"
                    f"Dossier : {dossier_out}"))
            else:
                self._set_statut("⏹  Export annulé", "#E3B341")

        except Exception as e:
            self._log(f"\n❌ ERREUR FATALE : {e}", "err")
            self._log(traceback.format_exc(), "err")
            self._set_statut("❌ Erreur fatale", "#F85149")
        finally:
            self._en_cours = False
            self.after(0, lambda: self.btn_annuler.config(state="disabled"))

    def _annuler_export(self):
        self._annuler = True
        self.btn_annuler.config(state="disabled")
        self._set_statut("⏹  Annulation…", "#E3B341")

    def _quitter(self):
        if self._en_cours:
            if not messagebox.askyesno(
                    "Export en cours",
                    "Un export est en cours. Voulez-vous vraiment quitter ?"):
                return
        if messagebox.askyesno("Quitter",
                               "Voulez-vous quitter l'application ?"):
            self.destroy()


# ==============================================================================
# POINT D'ENTRÉE
# ==============================================================================

if __name__ == "__main__":
    # Auto-installation des dépendances
    auto_installer()

    # Recharger après installation
    try:
        import pandas as pd
    except ImportError:
        pd = None
    try:
        from reportlab.lib.pagesizes import A4, landscape
        from reportlab.lib import colors
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import cm, mm
        from reportlab.platypus import (SimpleDocTemplate, Table, TableStyle,
                                        Paragraph, Spacer, HRFlowable,
                                        KeepTogether)
        from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
        REPORTLAB_OK = True
    except ImportError:
        REPORTLAB_OK = False

    app = AppExportPDF()
    app.mainloop()
