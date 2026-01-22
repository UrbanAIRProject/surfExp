#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 host-file plugin_home"
  echo "$0 $PWD/envs/ATOS-Bologna $PWD"
  exit 1
else
  echo
  echo "##################################################################" 
  date
  echo "##################################################################" 
  echo

  host_file=$1
  [ ! -f $host_file ] && echo "No $host file found" && exit 1
  . $host_file

  plugin_home=$2
fi

# Experiment
exp="CY49DT_OFFLINE_dt_2_5_2500x2500_control"

# Platform specific variables
[ "$scratch" == "" ] && echo "scratch not set!" && exit 1
[ "$ecf_dir" == "" ] && echo "ecf_dir not set!" && exit 1
[ "$binaries_opt" == "" ] && echo "binaries_opt not set!" && exit 1
[ "$binaries_de" == "" ] && echo "binaries_de not set!" && exit 1
[ "${micromamba_path}" == "" ] && echo "micromamba_path not set" && exit 1
[ -! -d ${micromamba_path}/bin/ ] && echo "${micromamba_path}/bin/ does not exist!" && exit 1
export PATH=${micromamba_path}/bin/:$PATH

# Experiment specific
config="dt_offline_dt_2_5_2500x2500_control.toml"
domain="surfexp/data/config/domains/dt_2_5_2500x2500.toml"

# Staging environment
if [ "$USER" == "sbu" ]; then
  config="dt_offline_dt_2_5_50x60_running.toml"
  domain="surfexp/data/config/domains/DRAMMEN.toml"
  domain_name="DRAMMEN"
  exp="CY49DT_OFFLINE_dt_2_5_50x60_control"
fi

cd $plugin_home
echo $PATH

mods="mods_control.toml"
cat > $mods << EOF

[scheduler.ecfvars]
  ecf_files = "$ecf_dir/ecf_files"
  ecf_files_remotely = "$ecf_dir/ecf_files"
  ecf_home = "$ecf_dir/jobout"
  ecf_jobout = "$ecf_dir/jobout"
  ecf_out = "$ecf_dir/jobout"

[suite_control]
  run_cmd = "$plugin_home/bin/run.sh $host_file $plugin_home"

[system]
   casedir = "$scratch/surfexp/@CASE@"

[platform]
  scratch = "$scratch"

EOF

time poetry run surfExp -o $config \
--case-name $exp \
--plugin-home $plugin_home  \
--troika troika \
surfexp/data/config/configurations/dt.toml \
surfexp/data/config/configurations/dt_control.toml \
surfexp/data/config/domains/dt_2_5_2500x2500.toml \
surfexp/data/config/mods/dev-CY49T2h_deode/dt.toml \
$mods

time poetry run deode start suite --config-file $config || exit 1

