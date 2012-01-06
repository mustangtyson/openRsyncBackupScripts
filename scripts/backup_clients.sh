#!/bin/bash

# TODO Overall ideas
# * log everything to /var/log/messages and echo
# * add the ability to limit bandwith per client (lan, wifi, internet)

# System executables
RSYNC=/usr/bin/rsync;
SSH=/usr/bin/ssh;
MKDIR=/bin/mkdir;
LOGGER=/usr/bin/logger;
ORBS_UTILS="OrbsUtils.sh"
ORBS_CONF="orbs.conf"

# Start of the backups
$LOGGER "$0 started"

# Get the dirrectory relative to this script
BASE_SCRIPT_DIR="${0%/*}"

# Get OrbsUtils full path
ORBS_UTILS_FULL="${BASE_SCRIPT_DIR}/${ORBS_UTILS}"

# Make sure our shared utils file exists
if [ ! -f ${ORBS_UTILS_FULL} ]
then
	$LOGGER "Cant find ${ORBS_UTILS_FULL}, exiting"
	exit 1
fi

# Source our shared utils file
source ${ORBS_UTILS_FULL}

# Make sure that we are not already running
cd ${BASE_SCRIPT_DIR}
testIfAlreadyRunning

# Get config files full path
ORBS_CONF_FULL="${BASE_SCRIPT_DIR}/../config/${ORBS_CONF}"

# Make sure our config file exists
if [ ! -f ${ORBS_CONF_FULL} ]
then
	$LOGGER "Cant find ${ORBS_CONF_FULL}, exiting"
        exit 1
fi

# Find the location to backup clients to
BACKUP_DIR=`grep 'BACKUP_DIR=' ${ORBS_CONF_FULL} | awk -F"=" '{print $2}'`

# Sanity check configuration file variables
if [ -z ${BACKUP_DIR} ]
then
	$LOGGER "${0} BACKUP_DIR:${BACKUP_DIR} not set in config file, exiting"
	exit 1
fi

# Get the base dir that the clients configuration files are stored under
CLIENT_CONF_BASE="${BASE_SCRIPT_DIR}/../config/clients"

cd ${CLIENT_CONF_BASE}

for file in `dir -d *` ; do
	$LOGGER "Back up ${file} started"

	# CLEAR THE VARIABLES
	unset REMOTE_USER
	unset REMOTE_HOST
	unset REMOTE_PATH
	unset EXCLUDE_PATH
	unset BWLIMIT
	unset BANDWITH_OPT

	# Import the files variables
	. ${file}

	# Sanity check the target to be backed up
	if [ ! -z ${REMOTE_HOST} ]
	then
		# Figure out where to save the backup
		LOCAL_PATH=${BACKUP_DIR}/${REMOTE_HOST}

		# Make sure the dir to backup to exists
		${MKDIR} -p ${LOCAL_PATH}${REMOTE_PATH}

		# Set the bandwith limit
		if [ ! -z ${BWLIMIT} ]
		then
			BANDWITH_OPT="--bwlimit=${BWLIMIT}"
		fi

		# Perform the backup
		${RSYNC} -avzh --delete ${BANDWITH_OPT} --stats -e ${SSH} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH} ${LOCAL_PATH}${REMOTE_PATH}/../

		if [ 0 == $? ]
		then
			$LOGGER "Back up ${file} succeeded"
		else
			$LOGGER "Back up ${file} failed, rsync exited with $?"
		fi
	else
		$LOGGER "Client file variables incorrectly set, not backing up"
        fi

done

$LOGGER "$0 done"

exit 0

