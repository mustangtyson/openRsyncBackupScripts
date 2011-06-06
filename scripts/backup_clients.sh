#!/bin/bash

# TODO Overall ideas
# * log everything to /var/log/messages
# * add the ability to limit bandwith per client (lan, wifi, internet)


source ./OrbUtils.sh

# System executables
RSYNC=/usr/bin/rsync;
SSH=/usr/bin/ssh;
MKDIR=/bin/mkdir;
LOGGER=/usr/bin/logger;

# User editable variables
BACKUP_DIR=/root/backups/backup; #TODO You must set this to your backup path (This should be in a config file


# Make sure that we are not already running
testIfAlreadyRunning


$LOGGER "$0 started"

# Start of the backups
cd ~/openRsyncBackupScripts/config/clients

for file in `dir -d *` ; do
	$LOGGER "Back up ${file} started"

	# CLEAR THE VARIABLES
	unset REMOTE_USER
	unset REMOTE_HOST
	unset REMOTE_PATH
	unset EXCLUDE_PATH

	# Import the files variables
	. ${file}

	# Sanity check the target to be backed up
	if [ ! -z ${REMOTE_HOST} ]
	then
		# Figure out where to save the backup
		LOCAL_PATH=${BACKUP_DIR}/${REMOTE_HOST}

		# Make sure the dir to backup to exists
		${MKDIR} -p ${LOCAL_PATH}${REMOTE_PATH}

		# Perform the backup
		${RSYNC} -avzh --delete --stats -e ${SSH} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH} ${LOCAL_PATH}${REMOTE_PATH}/../

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

