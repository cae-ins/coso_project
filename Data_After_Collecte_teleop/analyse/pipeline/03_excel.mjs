// 03 — Classeur lisible et filtrable des indicateurs COSO.
import fs from "node:fs/promises";
import path from "node:path";
import { Workbook, SpreadsheetFile } from "@oai/artifact-tool";

const input = process.argv[2];
const output = process.argv[3];
if (!input || !output) throw new Error("Usage: node 03_excel.mjs resultats.json indicateurs_COSO.xlsx");
const data = JSON.parse(await fs.readFile(input, "utf8"));
const wb = Workbook.create();
const navy = "#17324D";
const pale = "#E9F0F6";

function init(name, title, headers, rows, widths) {
  const sh = wb.worksheets.add(name);
  sh.showGridLines = false;
  sh.getRange("A2").values = [[title]];
  sh.getRange("A2").format.font = {name:"Arial",size:15,bold:true,color:navy};
  sh.getRange("A2").format.rowHeight = 30;
  sh.getRangeByIndexes(3,0,1,headers.length).values = [headers];
  if (rows.length) sh.getRangeByIndexes(4,0,rows.length,headers.length).values = rows;
  const last = String.fromCharCode(64 + headers.length);
  sh.getRange(`A4:${last}4`).format = {
    fill:navy,font:{name:"Arial",size:10,bold:true,color:"#FFFFFF"},
    rowHeight:29,verticalAlignment:"center"
  };
  sh.getRange(`A5:${last}${rows.length+4}`).format.font = {name:"Arial",size:10,color:"#263746"};
  sh.getRange(`A5:${last}${rows.length+4}`).format.rowHeight = 23;
  Object.entries(widths).forEach(([col,width]) => sh.getRange(`${col}:${col}`).format.columnWidth = width);
  sh.freezePanes.freezeRows(4);
  return sh;
}

const all = data.resultats;
const total = all.filter(r => r.niveau === "Ensemble");
const pick = (code, label, modalite="") => total.find(r => r.code===code && r.mesure===label && r.modalite===modalite);
const highlights = [
  pick("profil","Candidats retenus"),
  pick("3.1","Statut d'activité observé","En emploi"),
  pick("3.1","Statut d'activité observé","Sans emploi, en recherche"),
  pick("3.3","Heures hebdomadaires principales : médiane"),
  pick("3.4","Salaire net mensuel déclaré : médiane"),
  pick("3.4","Gain net du dernier mois : médiane"),
  pick("3.6","Formation ou apprentissage durant les 12 derniers mois"),
  pick("3.8","Ménage ayant subi un choc"),
  pick("3.8","Capacité déclarée à résister à un choc : médiane"),
  pick("3.9","Autonomie économique actuelle","Autonomie complète"),
  pick("4.2","Membre d'une association"),
].filter(Boolean);
const summaryRows = highlights.map(r => [r.code, r.mesure + (r.modalite ? ` — ${r.modalite}` : ""),
  r.valeur,r.unite,r.effectif,r.denominateur,r.statut,r.precision]);
const summary = init("Synthèse","Résultats des candidats retenus",
  ["Code","Mesure","Valeur","Unité","Effectif","Dénominateur","Statut","Précision"],
  summaryRows,{A:9,B:58,C:14,D:16,E:13,F:17,G:14,H:76});
summary.tabColor = navy;
summary.getRange("A3").values = [[`${data.metadata.n_apures} candidats ; ${data.metadata.n_signalements} points à revoir sur ${data.metadata.n_entretiens_signales} entretiens`]];
summary.getRange(`C5:C${summaryRows.length+4}`).setNumberFormat("#,##0.00");
summaryRows.forEach((r,i) => {
  if (r[3] !== "%") summary.getRange(`C${i+5}`).setNumberFormat("#,##0");
  if (r[6] === "partiel") summary.getRange(`G${i+5}`).format.fill = "#FFF1CF";
});

const territory = all.filter(r => ["District","Région"].includes(r.niveau));
const territoryKeys = [...new Map(territory.filter(r=>r.code==="profil").map(r =>
  [`${r.niveau}|${r.district}|${r.region}`,r])).values()];
const territoryRows = territoryKeys.map(k => {
  const own = territory.filter(r => r.niveau===k.niveau && r.district===k.district && r.region===k.region);
  const get = (code,label,modalite="") => own.find(r=>r.code===code&&r.mesure===label&&r.modalite===modalite)?.valeur ?? null;
  return [k.niveau,k.district,k.region,k.n_groupe,
    get("3.1","Statut d'activité observé","En emploi"),
    get("3.6","Formation ou apprentissage durant les 12 derniers mois"),
    get("3.8","Ménage ayant subi un choc"),
    get("3.9","Autonomie économique actuelle","Autonomie complète"),
    get("4.2","Membre d'une association")];
});
const territories = init("Territoires","Comparaison par district et région",
  ["Niveau","District","Région","Candidats","En emploi (%)","Formation 12 mois (%)",
   "Choc 12 mois (%)","Autonomie complète (%)","Association (%)"],
  territoryRows,{A:15,B:20,C:22,D:15,E:17,F:23,G:20,H:25,I:19});
territories.getRange("A3").values = [["Toutes les valeurs sont descriptives des répondants ; les dénominateurs sont dans l'onglet Résultats."]];
territories.getRange(`E5:I${territoryRows.length+4}`).setNumberFormat("0.0");

const detailRows = all.map(r => [r.niveau,r.district,r.region,r.sexe,r.age_groupe,r.milieu,
  r.n_groupe,r.code,r.mesure,r.modalite,r.valeur,r.unite,r.effectif,r.denominateur,
  r.sans_reponse,r.statut,r.variables,r.precision]);
const detail = init("Résultats","Tous les indicateurs et désagrégations",
  ["Niveau","District","Région","Sexe","Âge","Milieu","N groupe","Code",
   "Mesure","Modalité","Valeur","Unité","Effectif","Dénominateur",
   "Sans réponse","Statut","Variables","Précision"],
  detailRows,{A:18,B:19,C:21,D:14,E:21,F:13,G:14,H:9,I:50,J:34,
              K:14,L:14,M:14,N:17,O:17,P:13,Q:20,R:72});
detail.getRange("A3").values = [["Filtrer Niveau, Région, District, Sexe, Âge ou Milieu. Les cellules sans valeur signalent un dénominateur nul."]];
detail.getRange(`K5:K${detailRows.length+4}`).setNumberFormat("#,##0.00");
detail.freezePanes.freezeColumns(3);
detail.tables.add(`A4:R${detailRows.length+4}`,true,"ResultatsCOSO");

const coverageRows = data.couverture.map(x => [x.code,x.indicateur,x.statut,x.limite]);
const qualityRows = [
  ["Base","Lignes du DTA",data.metadata.n_source,"Entretiens, pas bénéficiaires du projet"],
  ["Filtre","1-COMPLET",data.metadata.n_complet,""],
  ["Filtre","2-QUASI_COMPLET",data.metadata.n_quasi,""],
  ["Filtre","Sans consentement exclu",data.metadata.n_exclus_sans_consentement,""],
  ["Sortie","Candidats apurés",data.metadata.n_apures,"Base apurée utilisée pour tous les calculs"],
  ["Audit","Entretiens signalés",data.metadata.n_entretiens_signales,"Une ligne peut porter plusieurs anomalies"],
  ["Audit","Signalements",data.metadata.n_signalements,"Détails dans la colonne anomalies de base_apuree.csv"],
  ["Âge","Âges invalides",data.metadata.n_age_invalides,"Mis à part dans les groupes d'âge"],
  ["Âge","Année de naissance vérifiable",data.metadata.n_age_annee_comparables,`${data.metadata.n_age_annee_ecarts} écart de plus d'un an`],
  ["Revenu","H3 : salariés / montants exacts",`${data.metadata.n_h3_salaries} / ${data.metadata.n_h3_exacts}`,"Dernière paie, périodicités différentes"],
  ["Revenu","H5 : éligibles / montants exacts",`${data.metadata.n_h5_eligibles} / ${data.metadata.n_h5_exacts}`,`${data.metadata.n_h5_refus} refus ; montants nuls écartés`],
  ...Object.entries(data.metadata.signalements_par_type).map(([k,v]) => ["Anomalie",k,v,""]),
];
const method = init("Méthode","Couverture des 21 indicateurs",
  ["Code","Indicateur","Statut","Source manquante ou limite"],
  coverageRows,{A:10,B:50,C:20,D:88});
method.getRange("A3").values = [["La méthode détaillée figure dans le rapport méthodologique du pipeline."]];
method.getRange("A28:D28").values = [["Type","Contrôle","Nombre","Note"]];
method.getRange("A28:D28").format = {fill:navy,font:{name:"Arial",bold:true,color:"#FFFFFF"}};
method.getRangeByIndexes(28,0,qualityRows.length,4).values = qualityRows;
coverageRows.forEach((r,i) => {
  if (r[2] === "indisponible") method.getRange(`A${i+5}:D${i+5}`).format.fill = pale;
});

wb.recalculate();
const preview = await wb.render({sheetName:"Synthèse",range:"A1:G15",scale:1,format:"png"});
await fs.writeFile(path.join(path.dirname(input),"apercu_excel.png"),new Uint8Array(await preview.arrayBuffer()));
const file = await SpreadsheetFile.exportXlsx(wb);
await file.save(output);
await fs.unlink(`${output}.inspect.ndjson`).catch(error => {
  if (error.code !== "ENOENT") throw error;
});
console.log(JSON.stringify({fichier:output,lignes:detailRows.length,territoires:territoryRows.length}));
