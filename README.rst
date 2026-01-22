.. _README:

.. image:: https://coveralls.io/repos/github/metno/surfExp/badge.svg?branch=master

https://coveralls.io/github/metno/surfExp


This repository is a setup to create and run offline SURFEX experiments.
=========================================================================

See online documentation in https://metno.github.io/surfExp/

The setup is dependent of pysurfex (https://metno.github.io/pysurfex) and deode workflow (https://github.com/destination-earth-digital-twins/Deode-Workflow).


Update the daily runs in DEODE
-----------------------------------

First create a new tag with a suitable name (e.g. surfExp version). This can be done with git commands or directly from https://github.com/destination-earth-digital-twins/surfExp

The tagging of surfExp will automatically create an installation under /perm/aut6432/DE_surfExp/tag-name/surfExp of the deode_production branch. The installation is local to this experiment. The control suite is not automatically updated and will continue to access the previous experiment, until the run_cmd is changed. This can be achieved by changing this variable directly in ecflow_ui or running the ./bin/control.sh script from the new experiment [recommended].

.. code-block:: bash
 cd /perm/aut6432/DE_surfExp/tag-name/surfExp
 ./bin/control.sh $PWD/envs/ATOS-Bologna $PWD"


Installation
-------------

An environment manager like miniconda or micromamba is recommended to ensure consistency between the packages.
After installing this you need to set it up for the current session or permanently add it to your shell.
Now it is easy to create a suitable environment for surfExp. Below is a recipie for micromamba.


.. code-block:: bash

    # Install micromamba (linux, https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html)
    "${SHELL}" <(curl -L micro.mamba.pm/install.sh)

    # specify a installation location for micromamba and add it to your path afterwards. Default it will install in $HOME/.local/bin
    export PATH=$HOME/.local/bin:$PATH

    # initialize your shell (needed in all shells), e.g:
    eval "$(micromamba shell hook --shell bash)"

    micromamba create env -p /path/to/your/micro/mamba/env python==3.11 poetry gdal ecflow
    export PATH=/path/to/your/micro/mamba/env/bin:$PATH

Now you have installed a suitable environment. To install surfExp the recommended installation method is using poetry which we just installed in the environment. Instead of activating the envronment we only added it to out path so that poetry and needed system libraries will be used from it.

To install the script system first clone https://github.com/metno/surfExp and install it with poetry.

NB: Poetry is also an environment manager. If not installed in a conda environment,
you will need to run either "`poetry env activate`" or "poetry run [cmd]" to execute commands in this environment.


.. code-block:: bash

 cd
 mkdir -p projects
 cd projects

 # Clone the source code
 clone https://github.com/metno/surfExp

 # If not already done, set the path
 export PATH=/path/to/your/micro/mamba/env/bin:$PATH

 # Install the script system
 cd surfExp
 poetry install


Usage
---------------------------------------------

To run a surfExp experiment you will need to create a configuration file.
The configuration is created based on a base configuration, on which you can add modifications (e.g. domain),
and this is created with the entry point surfExp which is installed with the package.
Required arguments are the case name (--case-name), the path to surfExp (--plugin-home) and the path to the config file (--output)
In addition you can add optional arguments like the start and end times and if you are in continuation mode.

The surfex binaries executed from surfExp are of course depending on source code version.
This means the fortran namelists must correspond to the binaries being run.
There are two ways to generate the fortran namelists. Since surfexp is a plugin to deode
the first way is to create the namelists is with the deode namelist generator.
This is achieved by setting ldeode = true for the surfex binary sections.

The other method is using the pysurfex namelist generator and is handled by the keyword blocks in the settings for the different binaries.
Please note that since this is a list, it is not merged between diffentent configuration inputs,
but the last one is the relevant one. This is the so called assemble blocks used by the namelist generator,
which in addition also needs a defintion file for namelists settings.
These two files are source code version dependent, but the resulting namelist will together
with the rest of the configuration determine what to be run.

The configuration input together with the namelist for the binaries determines what surfExp will do.
Most tasks are executed using pysurfex as a base. To reduce maintainance the entry pysurfex points
are called directly from the tasks. This means many of the task can specify command line arguments
from the config file.

.. code-block:: bash

 # First make sure you are in the proper environment
 cd ~/projects/surfExp

 # If not already done, set the path
 export PATH=/path/to/your/micro/mamba/env/bin:$PATH

 # Alternative way of setting up a pre-defined SEKF configuration
 poetry run surfExp -o my_config.toml --case-name SEKF --plugin-home $PWD surfexp/data/config/configurations/sekf.toml

 # Use AROME Arctic branch on PPI together with MET-Norway LDAS
 poetry run surfExp -o my_config.toml --case-name LDAS --plugin-home $PWD surfexp/data/config/configurations/metno_ldas.toml surfexp/data/config/mods/cy46_aa_offline/ppi.toml

 # To start you experiment
 poetry run deode start suite --config-file my_config.toml



Extra environment on PPI-RHEL8 needed to start experiments
---------------------------------------------------------------

.. code-block:: bash

 # use ib-dev queue
 ssh ppi-r8login-b1.int.met.no

 # Get surfExp
 git clone github.com:trygveasp/surfExp.git  --branch feature/deode_offline_surfex surfExp_new_pysurfex

 # Set path to conda environment

 # Install
 poetry install

 `poetry env activate`

 surfExp -o offline_drammen_metno_ldas.toml \
 --case-name METNO_LDAS \
 --plugin-home /home/$USER/projects/surfExp \
 surfexp/data/config/configurations/metno_ldas.toml \
 surfexp/data/config/domains/DRAMMEN.toml \
 surfexp/data/config/scheduler/ecflow_ppi_rhel8-trygveasp.toml \
 surfexp/data/config/mods/cy46_aa_offline/ppi.toml \
 surfexp/data/config/mods/cy46_aa_offline/isba_dif_snow_ass_decade_dirtyp.toml \
 --start-time 2025-04-17T03:00:00Z \
 --end-time 2025-04-17T07:00:00Z \
 --continue

 # MET-Norway LDAS experiment (using netcdf input to PGD)
 mkdir -f exps
 surfExp -o exps/LDAS.toml \
 --case-name LDAS \
 --plugin-home $PWD \
 surfexp/data/config/configurations/metno_ldas.toml \
 surfexp/data/config/domains/MET_NORDIC_1_0.toml \
 surfexp/data/config/mods/cy46_aa_offline/ppi.toml \
 surfexp/data/config/mods/netcdf_input_pgd.toml \
 surfexp/pdata/config/scheduler/ecflow_ppi_rhel8-$USER.toml

 # PPI ECFLOW
 # If your server is not running you should start it!
 module use /modules/MET/rhel8/user-modules/
 module load ecflow/5.8.1
 export ECF_SSL=1

 # Set HOST
 export DEODE_HOST="ppi_rhel8_b1"

 # Start suite (modify dates)
 deode start suite --config-file exps/LDAS.toml

 # MET-Norway LDAS single decade
 surfExp -o exps/LDAS_decade.toml --case-name LDAS_decade \
 --plugin-home $PWD \
 surfexp/data/config/configurations/metno_ldas.toml \
 surfexp/data/config/domains/MET_NORDIC_1_0.toml \
 surfexp/data/config/mods/cy46_aa_offline/ppi.toml \
 surfexp/data/config/mods/cy46_aa_offline/isba_dif_snow_ass_decade_dirtyp.toml \
 surfexp/data/config/scheduler/ecflow_ppi_rhel8-$USER.toml

 # Start the suite
 deode start suite  --config-file exps/LDAS_decade.toml

