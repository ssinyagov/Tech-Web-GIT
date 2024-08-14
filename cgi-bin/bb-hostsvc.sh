#!/bin/sh
#
# BIG BROTHER WEB BASED STATUS LOG DISPLAY SCRIPT
# Robert-Andre Croteau
# Version 1.6beta
# Nov 29th, 2000
#
# This program is Copyright (c) 1997-2000
# BB4 Technologies Inc.
# All Rights Reserved
#

# BBHOME IS THE ROOT DIRECTORY OF BIG BROTHER!!!
# YOU MUST SET THE NEXT LINE TO WHERE BB LIVES
BBHOME="/export/home/bb/bb16a"
export BBHOME

if [ "$BBHOME" = "" -o ! -d "$BBHOME" ]
then
        echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>BBHOME IS NOT SET IN bb-hostsvc.sh</H1></BODY>
                </HTML>"
        exit 1
fi

. $BBHOME/etc/bbdef.sh

# Are we called from a web page ?
if [ "$QUERY_STRING" != "" ]
then

    HISTFILE="STATUS_NOT_DEFINED"
    set -f
    QUERY_STRING=`echo "$QUERY_STRING" | $SED 's/[^A-Za-z0-9_,.&=:%-]//g' | $SED 's/[&=][.][.]*//g' | $SED 's/\.\.//g'`
    set `echo "$QUERY_STRING" | $SED 's/[&=]/\ /g' | $SED 's/%2[Cc]/,/g'` >/dev/null 2>&1
    while [ "$#" -ne 0 ]
    do
        case $1 in
	HOSTSVC )
		HOSTSVC=`echo "$2" | $SED 's/[^A-Za-z0-9_,.-]//g'`
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

    if [ "$HOSTSVC" = "" ]
    then
    	echo "Content-type: text/html

		
		<HTML><BODY>
		<H1>ERROR!<BR>bb-hostsvc.sh called with invalid arguments</H1>"
        echo "</BODY></HTML>"   
	exit 1
    fi

    # Thanks to Eric Hines <eric.hines@nuasis.com>
    #          and Safety <Safety@LinuxMaiL.ORG>
    # Make sure that no one tries to peek at other files
    # except those in logs/

    OLDIFS=$IFS
    IFS='/'
    set $HOSTSVC
    IFS=$OLDIFS
    lastarg="\${$#}"
    HOSTSVC=`eval "echo $lastarg"`

    if [ "$HOSTSVC" = "" -o ! -r "$BBLOGS/$HOSTSVC" ]
    then
    	echo "Content-type: text/html

		
		<HTML><BODY>
		<H1>ERROR!<BR>bb-hostsvc.sh called with invalid arguments</H1>"
        echo "</BODY></HTML>"   
	exit 1
    fi

    # Extract host name and service
    OLDIFS=$IFS
    IFS='.'
    set $HOSTSVC
    HOST=$1
    SERVICE=$2
    IFS=$OLDIFS

    # Convert hostname (xxx,yyy,com) to (xxx.yyy.com)
    HOSTDOTS=`echo $HOST | $SED 's/,/\./g'`

    # get the color of the status from the status file
    set `$CAT "$BBLOGS/$HOSTSVC" | $HEAD -1` >/dev/null 2>&1
    BKG="$1"

    echo "Content-type: text/html

"

    cd $BBLOGS
    $BBHOME/bin/dumphostsvc $HOSTSVC hostsvc
    exit 0

else
    	echo "Content-type: text/html

		
		<HTML><BODY>
		<H1>ERROR!<BR>bb-hostsvc.sh called with invalid arguments</H1>"
        echo "</BODY></HTML>"   
	exit 1
fi
