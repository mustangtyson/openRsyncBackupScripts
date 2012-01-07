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

# Sanity check configuration file variables
if [ -z ${SNAPSHOT_RW} ]
then
        $LOGGER "${0} SNAPSHOT_RW not set in config file, exiting"
        exit 1
fi

# make sure we're running as root
if (( `$ID -u` != 0 )); then { $LOGGER "Sorry, must be root.  Exiting..."; exit 1; } fi

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
	$SNAPSHOT_RW/hourly/hourly.24 \
        $SNAPSHOT_RW/daily/daily.0 ;

# step 5: update the mtime of daily.0 to reflect the snapshot time
if [ -d $SNAPSHOT_RW/daily/daily.0 ] ; then                     \
	$TOUCH $SNAPSHOT_RW/daily/daily.0 ;	\
fi;

$LOGGER "$0 done"
exit 0

