/*
Emplacement reserve aux corrections explicitement validees.

Pour chaque correction future, documenter :
  - identifiant de regle ;
  - source de la decision ;
  - date de validation ;
  - condition avant correction ;
  - count if avant replace ;
  - replace deterministe ;
  - controle apres correction.

Aucune correction n'est validee dans cette premiere version.
*/

use "$working_base", clear
save_working_safe
display as text "Corrections validees appliquees : 0"
