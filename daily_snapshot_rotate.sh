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

# ------------- file locations -----------------------------------------
SNAPSHOT_RW=/root/backups/snapshot;

# ------------- the script itself --------------------------------------
# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit 1; } fi

# step 1: delete the oldest snapshot, if it exists:
if [ -d $SNAPSHOT_RW/daily.7 ] ; then			\
	$RM -rf $SNAPSHOT_RW/daily.7 ;				\
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/daily.6 ] ; then			\
	$MV $SNAPSHOT_RW/daily.6 $SNAPSHOT_RW/daily.7 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily.5 ] ; then			\
	$MV $SNAPSHOT_RW/daily.5 $SNAPSHOT_RW/daily.6 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily.4 ] ; then			\
	$MV $SNAPSHOT_RW/daily.4 $SNAPSHOT_RW/daily.5 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily.3 ] ; then			\
	$MV $SNAPSHOT_RW/daily.3 $SNAPSHOT_RW/daily.4 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily.2 ] ; then			\
	$MV $SNAPSHOT_RW/daily.2 $SNAPSHOT_RW/daily.3 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily.1 ] ; then			\
	$MV $SNAPSHOT_RW/daily.1 $SNAPSHOT_RW/daily.2 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily.0 ] ; then			\
	$MV $SNAPSHOT_RW/daily.0 $SNAPSHOT_RW/daily.1
fi;

# step 3: make a hard-link-only (except for dirs) copy of the latest snapshot,
# if that exists
${CP} \
	-al \
	$SNAPSHOT_RW/hourly.3 \
        $SNAPSHOT_RW/daily.0 ;

# step 5: update the mtime of daily.0 to reflect the snapshot time
$TOUCH $SNAPSHOT_RW/daily.0 ;

exit 0

