#!/bin/sh
#
# BIG BROTHER WEB BASED HISTORY STATUS LOG DISPLAY SCRIPT
# Robert-Andre Croteau
# Version 1.6
# Dec 19th, 2000
#
# This program is Copyright (c) 1997-2000
# BB4 Technologies Inc.
# All Rights Reserved
#
# Bits also from Nick Metrowsky <nmetro@colorado.edu>, thanks Nick !
#

# BBHOME IS THE ROOT DIRECTORY OF BIG BROTHER!!!
# YOU MUST SET THE NEXT LINE TO WHERE BB LIVES
BBHOME="/export/home/bb/bb16a"
export BBHOME

if [ "$BBHOME" = "" -o ! -d "$BBHOME" ]
then
        echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>BBHOME IS NOT SET IN bb-histlog.sh</H1></BODY>
                </HTML>"
        exit 1
fi

. $BBHOME/etc/bbdef.sh

# Are we called from a web page ?
if [ "$QUERY_STRING" != "" ]
then

    HISTFILE="HISTFILE_NOT_DEFINED"
    set -f
    QUERY_STRING=`echo "$QUERY_STRING" | $SED 's/[^A-Za-z0-9_,.&=:%-]//g' | $SED 's/[&=][.][.]*//g' | $SED 's/\.\.//g'`
    set `echo "$QUERY_STRING" | $SED 's/[&=]/\ /g' | $SED 's/%2[Cc]/,/g'` >/dev/null 2>&1
    while [ "$#" -ne 0 ]
    do
        case $1 in
	TIMEBUF )
		TIMEBUF=`echo "$2" | $SED 's/\.\.//g' | $SED 's/[^A-Za-z0-9_:-]//g'`
		shiftnum=2
		;;
	HOST )
		HOST=`echo "$2" | $SED 's/\.\.//g' | $SED 's/[^A-Za-z0-9._-]//g'`
		shiftnum=2
		;;

	SERVICE )
		SERVICE=`echo "$2" | $SED 's/[^A-Za-z0-9_-]//g'`
		shiftnum=2
		;;
	*)
		shiftnum=1
		;;
	esac
	if [ "$#" -lt "$shiftnum" ]
	then
		shift
	else
		shift $shiftnum
	fi
    done

    if [ "$HOST" = "" -o "$SERVICE" = "" -o "$TIMEBUF" = "" ]
    then
    	echo "Content-type: text/html

		
		<HTML><BODY>
		<H1>ERROR!<BR>bb-histlog.sh called with invalid arguments</H1>"
        echo "</BODY></HTML>"   
	exit 1
    fi
fi

# Take the basename only !!!
# Make sure nobody's playing games
OLDIFS=$IFS
IFS='/'
set $HOST
HOST=$1
set $SERVICE
SERVICE=$1
IFS=$OLDIFS

HOSTDOTS=$HOST
HOSTCOMMAS=`echo "$HOST" | $SED 's/\./,/g'`
HOST=`echo "$HOST" | $SED 's/\./_/g'`
FNAME="$TIMEBUF"
LOGTIME=`echo "$TIMEBUF" | $SED 's/_/ /g'`
export LOGTIME

FILENM=${HOSTCOMMAS}.${SERVICE}
TMPFILE=$BBREP/$FILENM

$RM -f $TMPFILE >/dev/null 2>&1
# If we can't touch the file, something's fishy
$TOUCH $TMPFILE >/dev/null 2>&1
if [ ! -f $TMPFILE -o ! -w $TMPFILE ]
then
	echo "Content-type: text/html


                <HTML><BODY>
                <H1><BLINK><BR>bb-histlog.sh is being tampered with<BLINK></H1>"
	echo "</BODY></HTML>"   
	exit 1
fi

$RM -f $TMPFILE

if [ "$BBHISTLOGS/$HOST/$SERVICE" = "$BBHISTLOGS//" -o ! -d "$BBHISTLOGS/$HOST/$SERVICE" -o ! -r "$BBHISTLOGS/$HOST/$SERVICE/$FNAME" ]
then
	echo "red `date` <BR><CENTER>Historical status log not available</CENTER>" > $TMPFILE
else
	$CP -p "$BBHISTLOGS/$HOST/$SERVICE/$FNAME" $TMPFILE
fi

cd $BBREP

echo "Content-type: text/html

"

$BBHOME/bin/dumphostsvc $FILENM histlog

$RM -f $TMPFILE

exit 0
