#!/bin/bash
#SBATCH -J least-energy-extractor
#SBATCH -o least-energy-extractor.o
#SBATCH -e least-energy-extractor.e
#SBATCH -N 1                                    
#SBATCH -n 14
#SBATCH -p short
#SBATCH --time=24:00:00
#SBATCH --mail-user=EMAIL
#SBATCH --mail-type=END
#SBATCH --parsable
#SBATCH --dependency=afterany:SP_DFT_ID

# source config and function files
source_config

gen_slurm_report

cd $SP_DFT/completed/

rm $SP_DFT/lowest-energy-conformers.txt
touch $SP_DFT/lowest-energy-conformers.txt


for conf in $UNOPT_PDBS/*_0.pdb; do
	name=$(echo $(basename $conf) | sed "s/_0.pdb//")
	inchi_key="${name:0:27}"
	lowest=$(bash $ACCFLOW_TOOLS/scripts/get_lowest_conf_sp-dft.sh $name 2)
	
    # do not create input files if all conformers are not optimized
    if [[ $lowest -eq -1 ]]; then
        continue
    fi

	output_file="$lowest\_sp.log"
	to_all_logs $output_file
	pdb=$lowest.pdb
	cd $RM1_D/opt_pdbs/

	charge=$(get_charge $inchi_key)	

	# make single-point TD-DFT .com file and move to sp_td-dft directory
	#bash $ACCFLOW_TOOLS/scripts/make-com.sh -i=$pdb -r='#p CAM-B3LYP/6-31+G(d) td=50-50 SCRF=(Solvent=Acetonitrile)' -c=$charge -t=$name\_sp-tddft -l=$SP_TDDFT

    # make DFT S0 optimization .com file and move to dft_opt_s0 directory
	bash $ACCFLOW_TOOLS/scripts/make-com.sh -i=$pdb -r='#p B3LYP/4-31G* EmpiricalDispersion=GD3BJ opt SCRF=(Solvent=Acetonitrile)' -c=$charge -t=$name\_S0_SOLV -l=$S0_SOLV
	
	echo $lowest >> $SP_DFT/lowest-energy-conformers.txt
	cd $SP_DFT/completed/
done
