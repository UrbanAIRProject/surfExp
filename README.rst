.. _README:


This repository is a setup to create and run offline SURFEX experiments.
=========================================================================

See online documentation in https://metno.github.io/surfExp/

The setup is dependent of pysurfex (https://metno.github.io/pysurfex) and deode workflow (https://github.com/destination-earth-digital-twins/Deode-Workflow).


Installation
-------------

An environment manager like miniforge or micromamba is recommended to ensure consistency between the packages.

On ECMWF-ATOS you can use the existing micromamba environment installed under the operational account.

Below is a recipie for micromamba if you need to install it (NB! Not needed on ECMWF-ATOS). After installing this you need to set it up for the current session or permanently add it to your shell.
Now it is easy to create a suitable environment for surfExp. 

.. code-block:: bash

    # Install micromamba (linux, https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html)
    "${SHELL}" <(curl -L micro.mamba.pm/install.sh)

    # specify a installation location for micromamba and add it to your path afterwards. Default it will install in $HOME/.local/bin
    export PATH=$HOME/.local/bin:$PATH

    # initialize your shell (needed in all shells), e.g:
    eval "$(micromamba shell hook --shell bash)"

    # Install the surfExp depencies in a micromamba environment
    micromamba create env -p /path/to/micromamba-installation/envs/env-name --file environment.yml


Now you have installed a suitable environment. To install surfExp the recommended installation method is using poetry which we just installed in the environment.

To install the script system first clone https://github.com/destination-earth-digital-twins/surfExp and install it with poetry. There is a help script for this (./bin/install.sh) called which can be executed:

.. code-block:: bash

 # On ECMWF ATOS
 mkdir -p /perm/$USER/DE_surfExp/

 # Clone the source code
 git clone https://github.com/destination-earth-digital-twins/surfExp my_exp

 cd my_exp

 # Install in experiment
 ./bin/install.sh $PWD/envs/ATOS-Bologna $PWD


To install in a custom location (not using support scripts and no defined platform) use the local micromamba environment like this

.. code-block:: bash

 # Clone the source code
 git clone https://github.com/destination-earth-digital-twins/surfExp my_exp

 cd my_exp

 # Set path to environment
 export PATH=/path/to/micromamba-installation/envs/env-name/bin:$PATH
 
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
 cd /perm/$USER/DE_surfExp/my_exp

 # Set your PATH based on system micromamba installation
 . $PWD/envs/ATOS-Bologna
 export PATH=$micromamba_path/bin:$PATH

 # Set up an experiment (Pan-European domain, PREP from namelist values, CY49)
 poetry run surfExp -o my_config.toml \
 --case-name MY_CASE \
 --plugin-home $PWD \
 --troika troika  \
 surfexp/data/config/configurations/dt.toml \
 surfexp/data/config/domains/dt_2_5_2500x2500.toml \
 surfexp/data/config/mods/dev-CY49T2h_deode/dt.toml \
 surfexp/data/config/mods/dev-CY49T2h_deode/dt_prep_from_namelist.toml \
 --start-time 2025-01-01T00:00:00Z \
 --end-time 2025-01-03T00:00:00Z

 # To start you experiment
 deode start suite --config-file my_config.toml

For easier usage, there exist some help scripts for usage for a given HOST environment.

.. code-block:: bash
 
 # Run poetry in proper environment on ATOS
 ./bin/atos_poetry.sh

 # Print virtual environment
 ./bin/env.sh

 # Installs locally
 ./bin/install.sh

 # Create climate files only
 ./bin/climate.sh

 # Compile (normally not done, using DEODE binaries)
 ./bin/compile.sh

 # Set up control suite for dailly runs. Specifies run command
 ./bin/control.sh

 # Run dailly run
 ./bin/run.sh

 # Run experiment with DT
 ./bin/run_exp_dt.sh
