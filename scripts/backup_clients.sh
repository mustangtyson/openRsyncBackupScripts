#!/bin/bash

# TODO Overall ideas
# * log everything to /var/log/messages
# * add the ability to limit bandwith per client (lan, wifi, internet)



# System executables
RSYNC=/usr/bin/rsync
SSH=/usr/bin/ssh
MKDIR=/bin/mkdir

# Lock file to make sure that the script is not running more than once.
lf=/tmp/openRsyncBackupScriptsPidLockFile

# User editable variables
BACKUP_DIR=/root/backups/backup #TODO You must set this to your backup path (This should be in a config file


# Make sure that we are not already running
touch $lf
read lastPID < $lf
[ ! -z "$lastPID" -a -d /proc/$lastPID ] && exit 1

# Start of the backups
cd ~/openRsyncBackupScripts/config/clients

for file in `dir -d *` ; do
	logger "Back up ${file} started"

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
		${RSYNC} -azv -e ${SSH} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH} ${LOCAL_PATH}${REMOTE_PATH}/../
	else
		logger "Client file variables incorrectly set, not backing up"
        fi

	logger "Back up ${file} finished"
done

exit 0

