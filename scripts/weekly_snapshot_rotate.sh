#!/bin/bash

unset PATH	# Unset the path for security

# ------------- system commands used by this script --------------------
ID=/usr/bin/id;
ECHO=/bin/echo;
MOUNT=/bin/mount;
RM=/bin/rm;
MV=/bin/mv;
CP=/bin/cp;
TOUCH=/bin/touch;
RSYNC=/usr/bin/rsync;
MKDIR=/bin/mkdir

# ------------- file locations -----------------------------------------
SNAPSHOT_RW=/root/backups/snapshot;

# ------------- the script itself --------------------------------------
# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit 1; } fi

# step 1: delete the oldest snapshot, if it exists:
if [ -d $SNAPSHOT_RW/weekly/weekly.4 ] ; then			\
	$RM -rf $SNAPSHOT_RW/weekly/weekly.4 ;				\
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/weekly/weekly.3 ] ; then			\
	$MV $SNAPSHOT_RW/weekly/weekly.3 $SNAPSHOT_RW/weekly/weekly.4 ;	\
fi;

if [ -d $SNAPSHOT_RW/weekly/weekly.2 ] ; then			\
	$MV $SNAPSHOT_RW/weekly/weekly.2 $SNAPSHOT_RW/weekly/weekly.3 ;	\
fi;

if [ -d $SNAPSHOT_RW/weekly/weekly.1 ] ; then			\
	$MV $SNAPSHOT_RW/weekly/weekly.1 $SNAPSHOT_RW/weekly/weekly.2 ;	\
fi;

if [ -d $SNAPSHOT_RW/weekly/weekly.0 ] ; then			\
	$MV $SNAPSHOT_RW/weekly/weekly.0 $SNAPSHOT_RW/weekly/weekly.1
fi;

# step 3: make a hard-link-only (except for dirs) copy of the latest snapshot,
# if that exists
${MKDIR} -p $SNAPSHOT_RW/weekly
${CP} \
	-al \
	$SNAPSHOT_RW/daily/daily.7 \
        $SNAPSHOT_RW/weekly/weekly.0 ;

# step 5: update the mtime of weekly.0 to reflect the snapshot time
if [ -d $SNAPSHOT_RW/weekly/weekly.0 ] ; then                   \
	$TOUCH $SNAPSHOT_RW/weekly/weekly.0 ;	\
fi;

exit 0

