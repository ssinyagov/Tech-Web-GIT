#!/bin/sh

# bb-rep.sh
# SHELL SCRIPT TO MAKE A REPORT
# Sean MacGuire - BB4 Technologies Inc.
# Version 1.6a
# Dec 21st 2000
#
# This program is Copyright (c) 1997-2000
# BB4 Technologies Inc
# All Rights Reserved

# BBHOME IS THE ROOT DIRECTORY OF BIG BROTHER!!!
# YOU MUST SET THE NEXT LINE TO WHERE BB LIVES
BBHOME="/export/home/bb/bb16a"
export BBHOME

if [ "$BBHOME" = "" -o ! -d "$BBHOME" ]
then
        echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>BBHOME IS NOT SET IN bb-hist.sh</H1></BODY>
                </HTML>"
        exit 1
fi

if [ ! -w "$BBHOME/www/rep" ]
then
        echo "Content-type: text/html


                <HTML><BODY>
                <H3>ERROR!<BR>Your web server lacks the permissions to write into the BBHOME/www/rep directory<BR>Please change the group id of the BBHOME/www/rep directory to your web server's group id.<BR>Also make sure that the directory is group writable.</H3></BODY>
                </HTML>"
        exit 1
fi


. $BBHOME/etc/bbdef.sh          # INCLUDE STANDARD DEFINITIONS

REPDATA="/tmp/REP.$$"; export REPDATA	# WHERE ALL STATS ARE WRITTEN...

# Is someone playing funny with us ?
$RM -f $REPDATA
$TOUCH $REPDATA
if [ ! -f $REPDATA -o ! -w $REPDATA ]
then
	echo "Content-type: text/html
    

                <HTML><BODY> 
                <H1>ERROR!<BR>bb-rep.sh is being tampered with</H1>"       
	echo "</BODY></HTML>"
	exit 1
fi
$RM -f $REPDATA

# Are we called from a web page ?
if [ "$QUERY_STRING" != "" ]
then

    set -f
    QUERY_STRING=`echo "$QUERY_STRING" | $SED 's/[^A-Za-z0-9&=%-]//g' | $SED 's/[&=][.][.]*//g' | $SED 's/\.\.//g'`
    set `echo "$QUERY_STRING" | $SED "s/[&=]/\ /g"` >/dev/null 2>&1
    while [ "$#" -ne 0 ]
    do
        case $1 in
	start-mon)	STMON="$2"
			STMON=`echo "$STMON" | $SED 's/[^a-zA-Z]//g'`
			;;
	start-day)	STDAY="$2"
			STDAY=`echo "$STDAY" | $SED 's/[^0-9]//g'`
			;;
	start-yr)	STYR="$2"
			STYR=`echo "$STYR" | $SED 's/[^0-9]//g'`
			;;
	end-mon)	ENDMON="$2"
			ENDMON=`echo "$ENDMON" | $SED 's/[^a-zA-Z]//g'`
			;;
	end-day)	ENDDAY="$2"
			ENDDAY=`echo "$ENDDAY" | $SED 's/[^0-9]//g'`
			;;
	end-yr)		ENDYR="$2"
			ENDYR=`echo "$ENDYR" | $SED 's/[^0-9]//g'`
			;;
	style)		STYLE="$2";
			STYLE=`echo "$STYLE" | $SED 's/[^a-zA-Z0-9 ]//g'`
			export STYLE
			;;
	esac
	shift;
    done

    if [ "$STMON" = "" -o "$STDAY" = "" -o "$STYR" = "" -o "$ENDMON" = "" -o "$ENDDAY" = "" -o "$ENDYR" = "" -o "$STYLE" = "" ]
    then
	echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>bb-rep.sh called with invalid arguments</H1>"
	echo "</BODY></HTML>"   
	exit 1
    fi
else
	echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>bb-rep.sh called with invalid arguments</H1>"
	echo "</BODY></HTML>"   
	exit 1
fi

START="$STMON $STDAY $STYR"
END="$ENDMON $ENDDAY $ENDYR"
NOW=`$BBHOME/bin/touchtime -e`

THESTART=`$BBHOME/bin/touchtime -x "$START"`
THEEND=`$BBHOME/bin/touchtime -x "$END"`

if test "$THEEND" -gt "$NOW"
then
	END=`date "+%b %d %Y"` 
	THEEND=`$BBHOME/bin/touchtime -x "$END"`
fi

if test "$THESTART" -gt "$THEEND"
then
	echo "START: $THESTART END: $THEEND"
	START="$END"
fi

RANGE="$START - $END"; export RANGE

echo "Content-type: multipart/mixed;boundary=bbrep$$

--bbrep$$
Content-type: text/html

"

# RESET THE tmp DIRECTORY to www/rep
# THIS WAY WE CAN RUN mkbb.sh FOR BOTH STATUS AND REPORTING
BBTMP=$BBREP
export BBTMP

bkgcolor="blue"

ORIGBBWEB=$BBWEB
#BBWEB=`echo $BBWEB | $SED 's/\//\\\\\//g'`
#export BBWEB

$CAT $BBHOME/web/bbrep_header | $SED "s/&BBRELDATE/$BBRELDATE/g" | $SED "s/&BBREL/$BBREL/g" |\
        $SED "s/&BBDATE/$RANGE/g" | $SED "s/&BBBACKGROUND/$bkgcolor/g" |\
	$SED "s!&BBWEB!$BBWEB!g" | $SED "s!&CGIBINURL!$CGIBINURL!g" |\
	$SED "s!&BBSKIN!$BBSKIN!g"

echo "
<CENTER><A NAME=begindata>
<BR><BR><BR><BR>
<H3>Generating report for the period: $START - $END ($STYLE)<BR>
<P><P>"

#
# NOW CLEAN UP ALL THE LEFTOVERS LATER THAN "now"
#
# echo "Tidying up...<P></H3><H6><PRE>"

$BBHOME/bin/touchtime $BBREP/.later

$FIND $BBREP -type f ! -newer ${BBREP}/.later -exec $RM -f {} \;

#
# GATHER THE STATS
#
echo "</PRE><H3>Gathering statistics...</H3><H6><PRE>"
$BBHOME/web/bb-report.sh "$START" "$END"

#
# GENERATE THE REPORT...
#
echo "</PRE><H3><P>Generating report...<P>"

$RM -f $BBREP/rep-$$.html
$BBHOME/web/mkbb.sh > $BBREP/rep-$$.html

$RM -f $REPDATA

echo "Done...<P></BODY></HTML>"

#
# NOW GO OFF THERE...
#
echo "--bbrep$$

Content-type: text/html

<HTML><HEAD>
<META HTTP-EQUIV=\"REFRESH\" CONTENT=\"0; URL=${BBWEB}/rep/rep-$$.html\">
</HEAD><BODY BGCOLOR=\"000000\"></BODY></HTML>

--bbrep$$--"
