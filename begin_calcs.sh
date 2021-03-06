#!/bin/bash

# script for starting workflow
# execute anywhere in workflow directory tree

# source config and function files
source_config

echo -e "\nCommencing accelerated workflow [Version $FLOW_VERSION]"

cd $UNOPT_PDBS
# determine charge info for each molecule
get_charge_info

# convert pdbs to G16 input files for PM7 optimization
total_pdbs=$(ls -f *.pdb | wc -l)
current=1
echo -e "\nCreating PM7 input files..."
for file in *.pdb; do
	inchi_key="${file:0:27}"
	charge=$(get_charge $inchi_key)
	progress_bar 100 0 $current $total_pdbs
	bash $ACCFLOW_TOOLS/scripts/make-com.sh -i=$file -r='#p pm7 opt' -c=$charge -l=$PM7 -f
	current=$((current + 1))
done
echo ""

# submit PM7 optimization array
cd $PM7
PM7_ID=$(submit_array "$TITLE\_PM7" "g16_inp.txt" "com" "$ACCFLOW_TOOLS/templates/array_g16_pm7.sbatch" $PM7_TIME)
echo "PM7 array submitted with job ID $PM7_ID"

# submit RM1-D submitter which submits after PM7 array completes
cd $RM1_D
RM1_ID=$(sed "s/PM7_ID/$PM7_ID/g" "$ACCFLOW_TOOLS/templates/rm1-d_submitter.sbatch" | sbatch)
echo -e "RM1-D_submitter queued with job ID $RM1_ID\n"

