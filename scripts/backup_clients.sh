#!/bin/bash
# System executables
RSYNC=/usr/bin/rsync
SSH=/usr/bin/ssh
MKDIR=/bin/mkdir

# Lock file to make sure that the script is not running more than once.
lf=/tmp/openRsyncBackupScriptsPidLockFile

# User editable variables
BACKUP_DIR=/root/backups/backup #TODO You must set this to your backup path


# Make sure that we are not already running
touch $lf
read lastPID < $lf
echo "$lastPID"
[ ! -z "$lastPID" -a -d /proc/$lastPID ] && exit 1

# Start of the backups
cd ~/openRsyncBackupScripts/config/clients

for file in `dir -d *` ; do
	echo "Back up ${file} started"

	# CLEAR THE VARIABLES
	# TODO

	# Import the files variables
	. ${file}

	# Figure out where to save the backup
	LOCAL_PATH=${BACKUP_DIR}/${REMOTE_HOST}

	# Make sure the dir to backup to exists
	${MKDIR} -p ${LOCAL_PATH}${REMOTE_PATH}

	# Perform the backup
	${RSYNC} -az -e ${SSH} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH} ${LOCAL_PATH}${REMOTE_PATH}/../

	echo "Back up ${file} finished"
done

exit 0

