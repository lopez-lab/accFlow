#!/bin/bash

# script for setting up DFT optimizations after completion of S0 DFT optimization in vacuo

# source config and function files
source_config

pdb_file=$1
inchi="${pdb_file/_S0_SOLV.pdb/}"
charge=$(get_charge $inchi)

# setup S0 DFT optimization (in solvent)
#bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r='#p M06/6-31+G(d,p) SCRF=(Solvent=Acetonitrile) opt' -c=$charge -t=$inchi\_S0_solv -l=$S0_SOLV

# make single-point TD-DFT .com file and move to sp_td-dft directory
bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r='#p CAM-B3LYP/6-31+G(d) td=50-50 SCRF=(Solvent=Acetonitrile)' -c=$charge -t=$inchi\_SP-TDDFT -l=$SP_TDDFT

# setup S1 DFT optimization (in solvent)
bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r="#p B3LYP/4-31G* EmpiricalDispersion=GD3BJ SCRF=(Solvent=Acetonitrile) opt td=root=1" -c=$charge -t=$inchi\_S1_SOLV -l=$S1_SOLV

# setup T1 DFT optimization (in solvent)
#bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r='#p B3LYP/4-31G* EmpiricalDispersion=GD3BJ SCRF=(Solvent=Acetonitrile) opt' -t=$inchi\_T1_SOLV -c=$charge -s=3 -l=$T1_SOLV

# setup cation radical DFT optimization (in solvent)
bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r='#p B3LYP/4-31G* EmpiricalDispersion=GD3BJ SCRF=(Solvent=Acetonitrile) opt' -t=$inchi\_CAT-RAD_SOLV -c=$(($charge + 1)) -s=2 -l=$CAT_RAD_SOLV

# setup cation radical DFT optimization (in vacuo)
#bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r='#p B3LYP/4-31G* EmpiricalDispersion=GD3BJ opt' -t=$inchi\_CAT-RAD_VAC -c=$(($charge + 1)) -s=2 -l=$CAT_RAD_VAC
