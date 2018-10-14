#!/bin/bash


while getopts ":c:h:a" o; do
	case "${o}" in
		c)
			conf_file=${OPTARG};;
		a)
		  Backup_ID_from_CLI=${OPTARG};;
		h)
			echo -e 'Usage: -c $conf_file_path -a $snapshot_id. \nSample of the config file:

			some bla bla help
			'
			exit 0;;
	esac
done
if [ -z $conf_file ]; then
	echo 'ERROR: Config file path is missing. Usage: -c $conf_file_path. Use -h option for help'
	exit 1
fi

