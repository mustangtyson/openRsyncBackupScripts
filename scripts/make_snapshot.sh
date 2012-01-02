#!/bin/bash

source ./OrbUtils.sh
source ../config/orbs.conf

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

# ------------- the script itself --------------------------------------

# Make sure that we are not already running
testIfAlreadyRunning

$LOGGER "$0 started"

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $LOGGER "Sorry, must be root.  Exiting..."; exit 1; } fi

# step 1: delete the oldest snapshot, if it exists:
if [ -d $SNAPSHOT_RW/hourly/hourly.3 ] ; then			\
	$RM -rf $SNAPSHOT_RW/hourly/hourly.3 ;				\
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/hourly/hourly.2 ] ; then			\
	$MV $SNAPSHOT_RW/hourly/hourly.2 $SNAPSHOT_RW/hourly/hourly.3 ;	\
fi;

if [ -d $SNAPSHOT_RW/hourly/hourly.1 ] ; then			\
	$MV $SNAPSHOT_RW/hourly/hourly.1 $SNAPSHOT_RW/hourly/hourly.2 ;	\
fi;

# step 3: make a hard-link-only (except for dirs) copy of the latest snapshot,
# if that exists
if [ -d $SNAPSHOT_RW/hourly/hourly.0 ] ; then			\
	$MV $SNAPSHOT_RW/hourly/hourly.0 $SNAPSHOT_RW/hourly/hourly.1; \
fi;

# step 4: rsync from the system into the latest snapshot (notice that
# rsync behaves like cp --remove-destination by default, so the destination
# is unlinked first.  If it were not so, this would copy over the other
# snapshot(s) too!
$MKDIR -p $SNAPSHOT_RW/hourly/hourly.0;	\

$RSYNC \
	-a \
	-v \
	--delete \
        --link-dest=$SNAPSHOT_RW/hourly/hourly.1 \
	${BACKUP_RW}/ \
        $SNAPSHOT_RW/hourly/hourly.0/ ;

# step 5: update the mtime of hourly.0 to reflect the snapshot time
if [ -d $SNAPSHOT_RW/hourly/hourly.0 ] ; then                   \
	$TOUCH $SNAPSHOT_RW/hourly/hourly.0 ;	\
fi;

$LOGGER "$0 done"
exit 0

