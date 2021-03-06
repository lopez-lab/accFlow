#!/bin/bash
#SBATCH -J JOBNAME
#SBATCH -o %A_%a.o				
#SBATCH -e %A_%a.e				
#SBATCH -N 1			
#SBATCH -n 14               			
#SBATCH -p short
#SBATCH --time=24:00:00
#SBATCH --array=1-TOTAL%50 			
#SBATCH --parsable

# array sbatch script for S0 DFT optimization in vacuo

# source config and function files
source_config

gen_slurm_report

#input file to be processed
input_file=$(fetch_input $SLURM_ARRAY_TASK_ID g16_inp.txt)

#name of molecule and out/err files
title="${input_file/.com/}"
inchi_key="${input_file/_S0_SOLV.com/}"
log=$title.log

# check if job is already complete
completed=$(job_finished $log)

# run job if incomplete
if [[ $completed -eq 0 ]]; then
    # execute job
    timeout TIME time g16 $input_file
    timeout_status=$?

    # rename .o and .e files
    rename_slurm_outputs $SLURM_ARRAY_TASK_ID $title

    # termination status (opt successful if termination=1, opt & freq successful if termination=2)
    termination=$(grep 'Normal termination' $log | wc -l)

else
	# job is already coplete
    timeout_status=0
    termination=1
fi

# end of job preparation for next submissions
if [ $timeout_status -eq 124 ]; then		# if the run times out

	# move files to timeouts directory
	mv $title* $S0_SOLV/resubmits/
	cd $S0_SOLV/resubmits/

	# submit restart calc
	restart_opt $title $ACCFLOW_TOOLS/templates/s0_dft-opt_vac_g16_sbatch_re.txt

	
elif [ $termination -eq 1 ]; then		# if the run terminated successfully

	# move files to completed directory
	mv $title* $S0_SOLV/completed/
	cd $S0_SOLV/completed/
	to_all_logs $log

	# make pdb file of DFT optimized S0 (in vacuo) structure
    obabel -i log $log -o pdb -O $inchi_key.pdb &>/dev/null
    mv $inchi_key.pdb $S0_SOLV/opt_pdbs/

	# set up and submit freq calc
	setup_freq $log
	setup_single_point $log

	# make DFT optimization input files
	cd $S0_SOLV/opt_pdbs/
	bash $ACCFLOW_TOOLS/scripts/prep-dft-opts.sh $inchi_key.pdb
	exit 0
else
	# move files to failed_opt directory
	mv $title* failed_opt/
	exit 1
fi
