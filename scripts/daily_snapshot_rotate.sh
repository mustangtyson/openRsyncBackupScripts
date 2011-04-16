#!/bin/bash

unset PATH	# Unset the path for security

# ------------- system commands used by this script --------------------
ID=/usr/bin/id;
ECHO=/bin/echo;
LOGGER=/usr/bin/logger;
MOUNT=/bin/mount;
RM=/bin/rm;
MV=/bin/mv;
CP=/bin/cp;
TOUCH=/bin/touch;
RSYNC=/usr/bin/rsync;
MKDIR=/bin/mkdir;

# ------------- file locations -----------------------------------------
SNAPSHOT_RW=/root/backups/snapshot;

# ------------- the script itself --------------------------------------
$LOGGER "$0 started"

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit 1; } fi

# step 1: delete the oldest snapshot, if it exists:
if [ -d $SNAPSHOT_RW/daily/daily.7 ] ; then			\
	$RM -rf $SNAPSHOT_RW/daily/daily.7 ;				\
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/daily/daily.6 ] ; then			\
	$MV $SNAPSHOT_RW/daily/daily.6 $SNAPSHOT_RW/daily/daily.7 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily/daily.5 ] ; then			\
	$MV $SNAPSHOT_RW/daily/daily.5 $SNAPSHOT_RW/daily/daily.6 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily/daily.4 ] ; then			\
	$MV $SNAPSHOT_RW/daily/daily.4 $SNAPSHOT_RW/daily/daily.5 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily/daily.3 ] ; then			\
	$MV $SNAPSHOT_RW/daily/daily.3 $SNAPSHOT_RW/daily/daily.4 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily/daily.2 ] ; then			\
	$MV $SNAPSHOT_RW/daily/daily.2 $SNAPSHOT_RW/daily/daily.3 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily/daily.1 ] ; then			\
	$MV $SNAPSHOT_RW/daily/daily.1 $SNAPSHOT_RW/daily/daily.2 ;	\
fi;

if [ -d $SNAPSHOT_RW/daily/daily.0 ] ; then			\
	$MV $SNAPSHOT_RW/daily/daily.0 $SNAPSHOT_RW/daily/daily.1
fi;

# step 3: make a hard-link-only (except for dirs) copy of the latest snapshot,
# if that exists
${MKDIR} -p $SNAPSHOT_RW/daily
${CP} \
	-al \
	$SNAPSHOT_RW/hourly/hourly.3 \
        $SNAPSHOT_RW/daily/daily.0 ;

# step 5: update the mtime of daily.0 to reflect the snapshot time
if [ -d $SNAPSHOT_RW/daily/daily.0 ] ; then                     \
	$TOUCH $SNAPSHOT_RW/daily/daily.0 ;	\
fi;

$LOGGER "$0 done"
exit 0

