#!/bin/bash

# script for setting up DFT optimizations after completion of S0 DFT optimization in vacuo

# source config and function files
source_config

pdb_file=$1
inchi="${pdb_file/_S0_SOLV.pdb/}"
charge=$(get_charge $inchi)

# setup S0 DFT optimization (in solvent)
bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r='#p B3LYP/4-31G* EmpiricalDispersion=GD3BJ SCRF=(Solvent=Acetonitrile) opt' -t=$inchi\_S0_SOLV -c=$charge -l="$S0_SOLV/resubmits"
cd "$S0_SOLV/resubmits" && setup_sbatch "$inchi\_S0_solv.com" "$ACCFLOW/templates/single_g16_dft-opt.sbatch"

# setup S1 DFT optimization (in solvent)
bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r='#p B3LYP/4-31G* EmpiricalDispersion=GD3BJ SCRF=(Solvent=Acetonitrile) opt td=root=1' -t=$inchi\_S1_SOLV -c=$charge -l="$S1_SOLV/resubmits"
cd "$S1_SOLV/resubmits" && setup_sbatch "$inchi\_S1_solv.com" "$ACCFLOW/templates/single_g16_dft-opt.sbatch"

# setup T1 DFT optimization (in solvent)
bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r='#p B3LYP/4-31G* EmpiricalDispersion=GD3BJ SCRF=(Solvent=Acetonitrile) opt' -t=$inchi\_T1_SOLV -c=$charge -s=3 -l="$T1_SOLV/resubmits"
cd "$T1_SOLV/resubmits" && setup_sbatch "$inchi\_T1_solv.com" "$ACCFLOW/templates/single_g16_dft-opt.sbatch"

# setup cation radical DFT optimization (in solvent)
bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r='#p B3LYP/4-31G* EmpiricalDispersion=GD3BJ SCRF=(Solvent=Acetonitrile) opt' -t=$inchi\_CAT-RAD_SOLV -c=$(($charge + 1)) -s=2 -l="$CAT_RAD_SOLV/resubmits"
cd "$CAT_RAD_SOLV/resubmits" && setup_sbatch "$inchi\_cat-rad_solv.com" "$ACCFLOW/templates/single_g16_dft-opt.sbatch"

# setup cation radical DFT optimization (in vacuo)
bash $ACCFLOW/scripts/make-com.sh -i=$pdb_file -r='#p B3LYP/4-31G* EmpiricalDispersion=GD3BJ opt' -t=$inchi\_CAT-RAD_VAC -c=$(($charge + 1)) -s=2 -l="$CAT_RAD_VAC/resubmits"
cd "$CAT_RAD_VAC/resubmits" && setup_sbatch "$inchi\_cat-rad_vac.com" "$ACCFLOW/templates/single_g16_dft-opt.sbatch"
