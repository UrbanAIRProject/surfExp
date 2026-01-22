#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 host_file plugin_home"
  echo "$0 $PWD/envs/ATOS-Bologna $PWD"
  exit 1
else
  host_file=$1
  plugin_home=$2
fi

[ ! -f $host_file ] && echo "No host_file=$host_file file found" && exit 1
. $host_file

[ "${micromamba_path}" == "" ] && echo "micromamba_path not set" && exit 1
[ ! -d ${micromamba_path}/bin/ ] && echo "${micromamba_path}/bin/ does not exist!" && exit 1
export PATH=${micromamba_path}/bin/:$PATH
cd $plugin_home
poetry install || exit 1

