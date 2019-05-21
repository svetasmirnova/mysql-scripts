#!/bin/bash

VERSION="build_once_per_week v0.1 (March 31 2015)"

BASEDIR=$(dirname $0)

log_dir="$HOME/logs"
log_base_name=buildlog
last_build_filename=lastbuild

mkdir -p "$log_dir"

if [ ! -f "$log_dir/$last_build_filename" ] || [ `find "$log_dir/$last_build_filename" -mtime +7` ]
then
	touch "$log_dir/$last_build_filename"
	"$BASEDIR/build.sh" >"$log_dir/${log_base_name}-mysql-"`date +%Y-%m-%d-%H-%M`.log 2>"$log_dir/${log_base_name}-mysql-"`date +%Y-%m-%d-%H-%M`.err
	"$BASEDIR/build.sh" -g percona-server -p "ps-" -b 5.5 -b 5.6 -b 5.7 -b 8.0 >"$log_dir/${log_base_name}-ps-"`date +%Y-%m-%d-%H-%M`.log 2>"$log_dir/${log_base_name}-ps-"`date +%Y-%m-%d-%H-%M`.err 
fi

