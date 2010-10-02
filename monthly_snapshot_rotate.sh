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
if [ -d $SNAPSHOT_RW/monthly/monthly.12 ] ; then			\
	$RM -rf $SNAPSHOT_RW/monthly/monthly.12 ;				\
fi ;

# step 2: shift the middle snapshots(s) back by one, if they exist
if [ -d $SNAPSHOT_RW/monthly/monthly.11 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.11 $SNAPSHOT_RW/monthly/monthly.12 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.10 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.10 $SNAPSHOT_RW/monthly/monthly.11 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.9 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.9 $SNAPSHOT_RW/monthly/monthly.10 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.8 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.8 $SNAPSHOT_RW/monthly/monthly.9 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.7 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.7 $SNAPSHOT_RW/monthly/monthly.8 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.6 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.6 $SNAPSHOT_RW/monthly/monthly.7 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.5 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.5 $SNAPSHOT_RW/monthly/monthly.6 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.4 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.4 $SNAPSHOT_RW/monthly/monthly.5 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.3 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.3 $SNAPSHOT_RW/monthly/monthly.4 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.2 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.2 $SNAPSHOT_RW/monthly/monthly.3 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.1 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.1 $SNAPSHOT_RW/monthly/monthly.2 ;	\
fi;

if [ -d $SNAPSHOT_RW/monthly/monthly.0 ] ; then			\
	$MV $SNAPSHOT_RW/monthly/monthly.0 $SNAPSHOT_RW/monthly/monthly.1
fi;

# step 3: make a hard-link-only (except for dirs) copy of the latest snapshot,
# if that exists
${MKDIR} -p $SNAPSHOT_RW/monthly
${CP} \
	-al \
	$SNAPSHOT_RW/weekly/weekly.4 \
        $SNAPSHOT_RW/monthly/monthly.0 ;

# step 5: update the mtime of monthly.0 to reflect the snapshot time
$TOUCH $SNAPSHOT_RW/monthly/monthly.0 ;

exit 0

