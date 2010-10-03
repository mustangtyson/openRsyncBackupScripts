#!/bin/bash
RSYNC=/usr/bin/rsync
SSH=/usr/bin/ssh
MKDIR=/bin/mkdir

BACKUP_DIR=/mnt/backups/backup #TODO You must set this to your backup path

# Figure out where to save the backup
LOCAL_PATH=${BACKUP_DIR}/${RHOST}/

# Make sure the dir to backup to exists
${MKDIR} -p ${LOCAL_PATH}

# Perform the backup
${RSYNC} -az -e ${SSH} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH} ${LOCAL_PATH}

exit 0
