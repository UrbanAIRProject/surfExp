#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 poetry-args"
  exit 1
fi

SOURCE_PATH="${BASH_SOURCE[0]}"
host_file=`dirname $SOURCE_PATH`/../envs/ATOS-Bologna
[ ! -f $host_file ] && echo "No host_file=$host_file file found" && exit 1
. $host_file

[ "${micromamba_path}" == "" ] && echo "micromamba_path not set" && exit 1
[ ! -d ${micromamba_path}/bin/ ] && echo "${micromamba_path}/bin/ does not exist!" && exit 1

PATH=${micromamba_path}/bin/:$PATH
poetry $@
