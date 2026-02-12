
How to update the daily runs
======================================

- Make sure the code is merged to the deode_production branch
- Log into https://github.com/destination-earth-digital-twins/surfExp
- Under Actions, select the workflow: "Install surfExp on ATOS". Click on "Run workflow", and type in a name which will be the tag name installed in /perm/aut6432/DE_surfExp/
- Log in on ATOS-Bologna as aut6432 user and enter /perm/aut6432/DE_surfExp/[tag-name]/surfExp
- Run ./bin/control.sh $PWD/envs/ATOS-Bologna $PWD

This script will replace CY49DT_OFFLINE_dt_2_5_2500x2500_control and replace the variable run_cmd to start the run script from the corresponding experiment. This could also be done manually in the UI by replacing the variable run_cmd=/perm/aut6432/DE_surfExp/[tag-name]/surfExp/bin/run.sh /perm/aut6432/DE_surfExp/[tag-name]/surfExp/envs/ATOS-Bologna /perm/aut6432/DE_surfExp/[tag-name]/surfExp/"

