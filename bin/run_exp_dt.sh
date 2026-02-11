#!/bin/bash

if [ $# -ne 2 -a $# -ne 4 -a $# -ne 5 ]; then
  echo "Usage: $0 host-file plugin_home [prep iso-date [iso-end-date]]"
  echo "$0 $PWD/envs/ATOS-Bologna $PWD true 2025-01-01T00:00:00Z 2025-01-02T00:00:00Z"
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
  do_prep="true"
  [ $# -gt 2 ] && do_prep="$3"
  if [ $# -gt 3 ]; then
    start_time=$4
  else
    start_time=`date -d "today" '+%Y-%m-%d'`"T00:00:00Z"
  fi
  end_time=$start_time
  if [ $# -gt 4 ]; then
    end_time=$5
  fi
fi

# Experiment
exp="CY49DT_OFFLINE_dt_2_5_2500x2500_EXP_DT"

# Platform specific variables
[ "$scratch" == "" ] && echo "scratch not set!" && exit 1
[ "$ecf_dir" == "" ] && echo "ecf_dir not set!" && exit 1
[ "$binaries_opt" == "" ] && echo "binaries_opt not set!" && exit 1
[ "$binaries_de" == "" ] && echo "binaries_de not set!" && exit 1
[ "${micromamba_path}" == "" ] && echo "micromamba_path not set" && exit 1
[ ! -d ${micromamba_path}/bin/ ] && echo "${micromamba_path}/bin/ does not exist!" && exit 1
export PATH=${micromamba_path}/bin/:$PATH

# Experiment specific
config="dt_offline_dt_2_5_2500x2500_exp_dt.toml"
domain="surfexp/data/config/domains/dt_2_5_2500x2500.toml"
domain_name="DT_2_5_2500x2500"

set -x
cd $plugin_home

mods="mods_run.toml"
cat > $mods << EOF
[general]
  max_tasks = 60

[general.times]
  start = "$start_time"
  end = "$end_time"

[system]
   casedir = "$scratch/surfexp/@CASE@"

[platform]
  scratch = "$scratch"

[scheduler.ecfvars]
  ecf_files = "$ecf_dir/ecf_files"
  ecf_files_remotely = "$ecf_dir/ecf_files"
  ecf_home = "$ecf_dir/jobout"
  ecf_jobout = "$ecf_dir/jobout"
  ecf_out = "$ecf_dir/jobout"

[suite_control]
  create_static_data = true
  create_time_dependent_suite = true
  do_archiving = true
  do_cleaning = true
  do_extractsqlite = true
  do_marsprep = true
  do_pgd = false
  do_PrefetchMars = true
  do_prep = $do_prep

[submission]
  bindir = "$binaries_de"
[submission.task_exceptions.Forecast]
  bindir = "$binaries_de"
[submission.task_exceptions.Pgd]
  bindir = "$binaries_de"
[submission.task_exceptions.Prep]
  bindir = "$binaries_opt"
[submission.task_exceptions.QualityControl.MODULES]
  PRGENV = ["load", "prgenv/gnu"]

EOF

time poetry run surfExp -o $config \
--case-name $exp \
--plugin-home $plugin_home  \
--troika troika \
surfexp/data/config/configurations/dt.toml \
$domain \
surfexp/data/config/mods/dev-CY49T2h_deode/dt.toml \
surfexp/data/config/mods/dev-CY49T2h_deode/dt_prep_from_namelist.toml \
$mods \
--start-time $start_time \
--end-time $end_time

time poetry run deode start suite --config-file $config || exit 1
