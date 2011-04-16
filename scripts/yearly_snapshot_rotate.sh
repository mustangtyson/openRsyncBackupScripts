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
MKDIR=/bin/mkdir

# ------------- file locations -----------------------------------------
SNAPSHOT_RW=/root/backups/snapshot;

# ------------- the script itself --------------------------------------
$LOGGER "$0 started"

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $ECHO "Sorry, must be root.  Exiting..."; exit 1; } fi

# step 1: delete the oldest snapshot, if it exists:
if [ -d $SNAPSHOT_RW/yearly/yearly.12 ] ; then			\
	$RM -rf $SNAPSHOT_RW/yearly/yearly.12 ;				\
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/yearly/yearly.11 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.11 $SNAPSHOT_RW/yearly/yearly.12 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.10 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.10 $SNAPSHOT_RW/yearly/yearly.11 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.9 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.9 $SNAPSHOT_RW/yearly/yearly.10 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.8 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.8 $SNAPSHOT_RW/yearly/yearly.9 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.7 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.7 $SNAPSHOT_RW/yearly/yearly.8 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.6 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.6 $SNAPSHOT_RW/yearly/yearly.7 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.5 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.5 $SNAPSHOT_RW/yearly/yearly.6 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.4 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.4 $SNAPSHOT_RW/yearly/yearly.5 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.3 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.3 $SNAPSHOT_RW/yearly/yearly.4 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.2 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.2 $SNAPSHOT_RW/yearly/yearly.3 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.1 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.1 $SNAPSHOT_RW/yearly/yearly.2 ;	\
fi;

if [ -d $SNAPSHOT_RW/yearly/yearly.0 ] ; then			\
	$MV $SNAPSHOT_RW/yearly/yearly.0 $SNAPSHOT_RW/yearly/yearly.1
fi;

# step 3: make a hard-link-only (except for dirs) copy of the latest snapshot,
# if that exists
${MKDIR} -p $SNAPSHOT_RW/yearly
${CP} \
	-al \
	$SNAPSHOT_RW/monthly/monthly.12 \
        $SNAPSHOT_RW/yearly/yearly.0 ;

# step 5: update the mtime of yearly.0 to reflect the snapshot time
if [ -d $SNAPSHOT_RW/yearly/yearly.0 ] ; then                   \
	$TOUCH $SNAPSHOT_RW/yearly/yearly.0 ;	\
fi;

$LOGGER "$0 done"

exit 0

