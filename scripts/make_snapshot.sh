#!/bin/bash

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
ORBS_UTILS="OrbsUtils.sh"
ORBS_CONF="orbs.conf"

# ------------- the script itself --------------------------------------
$LOGGER "$0 started"

# Get the dirrectory relative to this script
BASE_SCRIPT_DIR="${0%/*}"

# Get OrbsUtils full path
ORBS_UTILS_FULL="${BASE_SCRIPT_DIR}/${ORBS_UTILS}"

# Make sure our shared utils file exists
if [ ! -f ${ORBS_UTILS_FULL} ]
then
        $LOGGER "Cant find ${ORBS_UTILS_FULL}, exiting"
        exit 1
fi

# Source our shared utils file
source ${ORBS_UTILS_FULL}

# Make sure that we are not already running
cd ${BASE_SCRIPT_DIR}
testIfAlreadyRunning

# Get config files full path
ORBS_CONF_FULL="${BASE_SCRIPT_DIR}/../config/${ORBS_CONF}"

# Make sure our config file exists
if [ ! -f ${ORBS_CONF_FULL} ]
then
        $LOGGER "Cant find ${ORBS_CONF_FULL}, exiting"
        exit 1
fi

# Read in config file values
SNAPSHOT_RW=`grep 'SNAPSHOT_RW=' ${ORBS_CONF_FULL} | awk -F"=" '{print $2}'`
BACKUP_RW=`grep 'BACKUP_RW=' ${ORBS_CONF_FULL} | awk -F"=" '{print $2}'`

# Sanity check configuration file variables
if [ -z ${SNAPSHOT_RW} ]
then
        $LOGGER "${0} SNAPSHOT_RW not set in config file, exiting"
        exit 1
fi

if [ -z ${BACKUP_RW} ]
then
        $LOGGER "${0} BACKUP_RW not set in config file, exiting"
        exit 1
fi

# Debug
$LOGGER "Snapshoting From:${BACKUP_RW}"
$LOGGER "Snapshoting To:${SNAPSHOT_RW}"

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $LOGGER "Sorry, must be root.  Exiting..."; exit 1; } fi

# step 1: delete the oldest snapshot, if it exists:
if [ -d $SNAPSHOT_RW/hourly/hourly.3 ] ; then			\
	$RM -rf $SNAPSHOT_RW/hourly/hourly.3 ;				\
fi;

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
$MKDIR -p $SNAPSHOT_RW/hourly/hourly.0;

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

