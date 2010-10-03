#!/bin/bash
RSYNC=/usr/bin/rsync
SSH=/usr/bin/ssh
MKDIR=/bin/mkdir

BACKUP_DIR=/mnt/backups/backup #TODO You must set this to your backup path

# . ../config/clients/tsmith@wopr

cd ../config/clients
for file in `dir -d *` ; do
	echo "Back up ${file} started"

	# TODO CLEAR THE VARIABLES

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

