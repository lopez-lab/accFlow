# Accelerated Workflow 

**Phase 1** S0 ground state in solvent, with B3LYP-D3BJ/4-31G*

**Phase 2** S1 optimization in solvent, with B3LYP-D3BJ/4-31G*

**Phase 3** Cation optimization in solvent, with B3LYP-D3BJ/4-31G*

**Phase 4** A single point energy calculation on each geometry, in solvent, with CAM-B3LYP/6-31+G(d)

**Phase 5** A VEE calculation with CAM-B3LYP/6-31+G(d)

#### Changes
##### Edits in bashrc 

In your ~/.bashrc add **ACCFLOW=loc_of_new_flow**

Also in your ~/.bashrc make sure you are sourcing the functions.sh script from the new accFlow.

That means changing "set -a; source /home/username/loc_of_old_flow/functions.sh; set +a" to

  **"set -a; source /home/username/loc_of_new_flow/functions.sh; set +a"**

##### Ensure permissions for rungms 
 Make sure the right permissions are allowed for rumgms, to do this run 
 
 *chmod 777 /loc_of_new_flow/utils/rungms*

#### Start Calculations 

Use _git clone https://github.com/lopez-lab/accFlow.git_ to copy the directory to your home directory

In your SCRATCH directory run "$ACCFLOW/utils/setup_flow.sh name_of_flow" to setup the workflow 

To begin calculations run "$ACCFLOW/begin_calcs.sh" in the directory of the workflow

#### Updates 
To update run *"git pull origin master"*
