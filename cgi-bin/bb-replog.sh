#!/bin/sh
#
# BIG BROTHER WEB BASED REPORT DISPLAY SCRIPT
# Robert-Andre Croteau
# Version 1.6
# Dec 19th, 2000
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
		<H1>ERROR!<BR>BBHOME IS NOT SET IN bb-replog.sh</H1></BODY>
		</HTML>"
	exit 1
fi

. $BBHOME/etc/bbdef.sh

# Is someone playing games with us...
OFFFILE=/tmp/OFF.$$
NONGRFILE=/tmp/NONGR.$$
TMPFILE="/tmp/BBREPLOG.$$"
$RM -f $OFFFILE
$RM -f $NONGRFILE
$RM -f $TMPFILE
$TOUCH $OFFFILE
$TOUCH $NONGRFILE
$TOUCH $TMPFILE

if [ ! -f $OFFFILE -o ! -f $NONGRFILE -o ! -f $TMPFILE -o ! -w $OFFFILE -o ! -w $NONGRFILE -o ! -w $TMPFILE ]
then
    	echo "Content-type: text/html

		
		<HTML><BODY>
		<H1>ERROR!<BR>bb-replog.sh is being tampered with</H1></BODY>
		</HTML>"
	exit 1
fi
$RM -f $OFFFILE
$RM -f $NONGRFILE
$RM -f $TMPFILE

# Are we called from a web page ?
if [ "$QUERY_STRING" != "" ]
then

    HOSTSVC="HOSTFILE_NOT_DEFINED"
    RED=0
    YEL=0
    GRE=0
    PUR=0
    CLE=0
    BLU=0
    COLOR=clear
    FSTATE=OK
    set -f
    QUERY_STRING=`echo "$QUERY_STRING" | $SED 's/[^A-Za-z0-9_,.&=%-]//g' | $SED 's/[&=][.][.]*//g' | $SED 's/\.\.//g'`
    set `echo "$QUERY_STRING" | $SED 's/[&=]/\ /g' | $SED 's/%2[Cc]/,/g'` >/dev/null 2>&1
    while [ "$#" -ne 0 ]
    do
        case $1 in
	HOSTSVC )	HOSTSVC=`echo "$2" | $SED 's/[^A-Za-z0-9_,.-]//g'`
			shiftnum=2
			;;
	PCT )		PCT=`echo "$2" | $SED 's/[^0-9.]//g'`
			shiftnum=2
			;;
	ST )		ST=`echo "$2" | $SED 's/[^0-9]//g'`
			shiftnum=2
			;;
	END )		END=`echo "$2" | $SED 's/[^0-9]//g'`
			shiftnum=2
			;;
	RED )		RED=`echo "$2" | $SED 's/[^0-9.]//g'`
			shiftnum=2
			;;
	YEL )		YEL=`echo "$2" | $SED 's/[^0-9.]//g'`
			shiftnum=2
			;;
	GRE )		GRE=`echo "$2" | $SED 's/[^0-9.]//g'`
			shiftnum=2
			;;
	PUR )		PUR=`echo "$2" | $SED 's/[^0-9.]//g'`
			shiftnum=2
			;;
	BLU )		BLU=`echo "$2" | $SED 's/[^0-9.]//g'`
			shiftnum=2
			;;
	CLE )		CLE=`echo "$2" | $SED 's/[^0-9.]//g'`
			shiftnum=2
			;;
	COLOR )		COLOR=`echo "$2" | $SED 's/[^a-z]//g'`
			shiftnum=2
			;;
	STYLE )		STYLE="$2"		# SMM
			shiftnum=2
			;;
	FSTATE )	FSTATE="$2"		# RAC - Is hist file valid ?
			shiftnum=2
			;;
	*)		shiftnum=1
			;;
	esac
	if [ "$#" -lt "$shiftnum" ]
	then
		shift
	else
		shift $shiftnum
	fi
    done

    if [ "$HOSTSVC" = "" -o "$HOSTSVC" = "HOSTFILE_NOT_DEFINED" -o "$COLOR" = "" -o "$STYLE" = "" ]
    then
        echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>bb-replog.sh called with invalid arguments</H1>"
        echo "</BODY></HTML>"   
        exit 1
    fi

    # Take the basename only !!!
    # 
    OLDIFS=$IFS
    IFS='/'
    set $HOSTSVC
    IFS=$OLDIFS
    lastarg="\${$#}"
    HOSTSVC=`eval "echo $lastarg"`
    HOSTSVC=`echo "$HOSTSVC" | $SED 's/[^A-Za-z0-9.,_-]//g'`
    HOSTSVC=`echo "$HOSTSVC" | $SED 's/\,/\./g'`
    OLDIFS=$IFS
    IFS='.'
    set $HOSTSVC
    IFS=$OLDIFS
    HOSTDOTS="$1"
    export HOSTDOTS
    HOSTCOMMAS="$1"
    export HOSTCOMMAS
    shift
    while [ "$#" -gt 1 ]
    do
	HOSTDOTS=${HOSTDOTS}.$1
	HOSTCOMMAS=${HOSTCOMMAS},$1
	shift
    done
    FQDNNAME="$HOSTDOTS"
    SERVICE=$1
    export SERVICE

    HOSTSVC=${HOSTCOMMAS}.${SERVICE}

    # 
    # Create text based report
    #
    repname=avail-${HOSTDOTS}-${SERVICE}-$$.txt
    repfile=${BBREP}/${repname}
    $RM -f ${repfile} >/dev/null 2>&1

    $TOUCH ${repfile} >/dev/null 2>&1
    if [ "$?" -ne 0 ]
    then
        echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>bb-replog.sh called with invalid arguments</H1>"
        echo "</BODY></HTML>"   
        exit 1
    fi

    $RM -f ${repfile} >/dev/null 2>&1

    BBIP=`$BBHOME/bin/getipaddr -f $FQDNNAME`
    BBIPNAME=`$BBHOME/bin/getipaddr $FQDNNAME`

    bkgcolor="$COLOR"

    STARTDATE=`$BBHOME/bin/touchtime -c $ST | $AWK '{print $2 " " $3 " " $5}'`
    STARTDATETIME=`$BBHOME/bin/touchtime -c $ST | $AWK '{print $1 " " $2 " " $3 " 00:00:00 " $5}'`
    ENDDATE=`$BBHOME/bin/touchtime -c $END | $AWK '{print $2 " " $3 " " $5}'`
    ENDDATETIME=`$BBHOME/bin/touchtime -c $END | $AWK '{print $1 " " $2 " " $3 " 00:00:00 " $5}'`
    RANGE="$STARTDATE - $ENDDATE"

    # THE RANGE WILL APPEAR AS DEFINED BY THE USER
    # BUT THE ACTUAL END TIME FOR CALCULATION CANNOT BE GREATER
    # THAN NOW 
 
    timenow=`$BBHOME/bin/touchtime -e`
    if [ "$timenow" -lt "$END" ]
    then
        END=$timenow
    fi

    OFFLINE=0
    NONGR=0

    echo "Content-type: text/html

"

    $CAT $BBHOME/web/replog_header | $SED "s/&BBRELDATE/$BBRELDATE/g" | $SED "s/&BBREL/$BBREL/g" |\
        $SED "s/&BBDATE/$RANGE/g" | $SED "s!&BBBACKGROUND!$BBSKIN\/bkg-$bkgcolor.gif!g" |\
	$SED "s/&BBHOST/$HOSTDOTS/g" | $SED "s/&BBSVC/$SERVICE/g" |\
	$SED "s!&BBWEB!$BBWEB!g" | $SED "s!&BBIPNAME!$BBIPNAME!g" | $SED "s!&BBIP!$BBIP!g" |\
	$SED "s!&BBSKIN!$BBSKIN!g"

    if [ -f "$BBHIST/$HOSTSVC" ]
    then

	echo "
<CENTER>
<BR><FONT $MKBBROWFONT><H2>$HOSTDOTS - $SERVICE</H2></FONT>
<TABLE BORDER=0 BGCOLOR=\"#333333\" CELLPADDING=3>
<TR BGCOLOR=\"#000000\">
</TR>
<TR></TR>
<TR>
<TD COLSPAN=6><CENTER><B>Overall Availability: $PCT%</A></CENTER></TD>
</TR>
<TR BGCOLOR=\"#000000\">"
	echo "<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/green.gif\" ALT=\"green\" HEIGHT=16 WIDTH=16 BORDER=0></TD>
<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/yellow.gif\" ALT=\"yellow\" HEIGHT=16 WIDTH=16 BORDER=0></TD>
<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/red.gif\" ALT=\"red\" HEIGHT=16 WIDTH=16 BORDER=0></TD>
<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/purple.gif\" ALT=\"purple\" HEIGHT=16 WIDTH=16 BORDER=0></TD>
<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/clear.gif\" ALT=\"clear\" HEIGHT=16 WIDTH=16 BORDER=0></TD>
<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/blue.gif\" ALT=\"blue\" HEIGHT=16 WIDTH=16 BORDER=0></TD>
</TR>
<TR BGCOLOR=\"#000033\">"

        echo "<TD ALIGN=CENTER><B>${GRE}%</B></TD>
<TD ALIGN=CENTER><B>${YEL}%</B></TD>
<TD ALIGN=CENTER><B>${RED}%</B></TD>
<TD ALIGN=CENTER><B>${PUR}%</B></TD>
<TD ALIGN=CENTER><B>${CLE}%</B></TD>
<TD ALIGN=CENTER><B>${BLU}%</B></TD>
</TR>
<TR BGCOLOR=\"#000000\">
<TD COLSPAN=6 ALIGN=CENTER>
<FONT $MKBBCOLFONT><B>[Total may not equal 100%]</B></TD> </TR>
"
	if [ "$FSTATE" = "NOTOK" ]
	then
		echo "<TR BGCOLOR=\"#000000\">
<TD COLSPAN=6 ALIGN=CENTER>
<FONT $MKBBCOLFONT><B>[History file contains invalid entries]</B></TD> </TR>"
	fi

	echo "
</TABLE>
</CENTER>"

	echo "Availability Report
${RANGE}


				${HOSTDOTS} - ${SERVICE}

				Availability:	${PCT}%

			Red	Yellow	Green	Purple	Clear	Blue
			${RED}%	${YEL}%	${GRE}%	${PUR}%	${CLE}%	${BLU}%


				Event logs for the given period

Event Start			Event End			Status	Seconds	Cause

" >> ${repfile}

      
	echo "<BR><BR>
<CENTER>
<TABLE BORDER=0 BGCOLOR=\"#333333\" CELLSPACING=3>
<TR>
<TD COLSPAN=5><CENTER>Event logs for the given period</CENTER></TD>
</TR>
<TR BGCOLOR=\"#333333\">
<TD ALIGN=CENTER><FONT $MKBBCOLFONT><B>Event Start</B></TD>
<TD ALIGN=CENTER><FONT $MKBBCOLFONT><B>Event End</B></TD>
<TD ALIGN=CENTER><FONT $MKBBCOLFONT><B>Status</B></TD>
<TD ALIGN=CENTER><FONT $MKBBCOLFONT><B>Seconds</B></TD>
<TD ALIGN=CENTER><FONT $MKBBCOLFONT><B>Cause</B></TD></TR>"

	$RM -f $TMPFILE
        $SORT -r -n -k 7 "$BBHIST/$HOSTSVC" > $TMPFILE
        if [ "$?" -ne 0 ]
        then 
            echo "Your SORT command does not seem to support the \"-r -n -k 7\"<BR>"
            echo "option. It probably wants \"-r -n +7\" as the option to SORT<BR>"
            echo "On AIX, use \"-k7nr\"<BR>"
            echo "please fix it in the bb-replog.sh script"
        fi
        $CAT $TMPFILE | $GREP -v green | $AWK '$7 < '$END' && $7 + $8 >= '$ST' { print $0 }'  | \
	while read line
	do 
		set $line > /dev/null

		arg1=$1
		arg2=$2
		arg3=$3
		arg4=$4
		arg5=$5
		color=$6
		eventtime=$7
		eventlen=$8
		numargs=$#

		# SMM FOR DORADO...
		case "$STYLE" in
		crit) 	if test "$color" != "red"
			then
				continue
			fi
			;;
		nongr)	if test "$color" = "green"
			then
				continue
			fi
			;;
		esac

		if test "$BG" = "000000"
		then
			BG="000033"
		else
			BG="000000"
		fi

		hostname=`echo $HOSTDOTS | $SED 's/\./_/g'`
		histlogname=$BBHISTLOGS/$hostname/$SERVICE/${arg1}_${arg2}_${arg3}_${arg4}_${arg5}
		# Can't put the SED that removes the &rec/&ellow here because the return code wil be 0
		causelines=""
		if [ -r "$histlogname" ]
		then
			causelines=`$GREP '^&' $histlogname`
			if [ "$?" -ne 0 ]
			then
				causelines=`$HEAD -1 $histlogname`
				if [ "$?" -ne 0 ]
				then
					causelines=""
				else
					set $causelines >/dev/null
					shift 7
					causelines=$*
				fi
			else
				causelines=`$GREP '^&' $histlogname | $GREP -v green | $SED 's/^&[a-z]*//g' | $SED 'a\\
<BR>'`
			fi
		fi

		# Make sure there's an 8th argument
		# if not the length of time is now - start time of event
		if [ "$numargs" -lt 8 ]
		then
			lapsetime=`$EXPR $END - $eventtime`
		else
			lapsetime=$eventlen
		fi

		# If event started before actual start time
		# The length is calculated from START
		if [ "$eventtime" -lt "$ST" ]
		then
			lapsetime=`$EXPR $eventtime + $lapsetime - $ST`
			begintime=$ST
		else
			begintime=$eventtime
		fi

		# Does the event log ends after END ?
		# THe lenght is calculated 'til END
		finishtime=`$EXPR $begintime + $lapsetime`
		if [ "$finishtime" -gt "$END" ]
		then
			lapsetime=`$EXPR $END - $begintime`
		fi

		STARTEVENT=`$BBHOME/bin/touchtime -c $begintime`
		endtime=`$EXPR $begintime + $lapsetime`
		ENDEVENT=`$BBHOME/bin/touchtime -c $endtime`

		echo "<TR BGCOLOR=$BG><TD ALIGN=LEFT NOWRAP>$STARTEVENT</TD><TD ALIGN=RIGHT NOWRAP>$ENDEVENT</TD><TD ALIGN=CENTER BGCOLOR=\"#000000\">"
		HOSTDIR=`echo $HOSTDOTS | $SED 's/\./_/g'`
		echo "<A HREF=\"$CGIBINURL/bb-histlog.sh?HOST=$HOSTDOTS&SERVICE=$SERVICE&TIMEBUF=${arg1}_${arg2}_${arg3}_${arg4}_${arg5}\">"

		if test "$color" = "red"
		then
			OFFLINE=`$EXPR $OFFLINE + $lapsetime`
			$RM -f $OFFFILE
			echo "$OFFLINE" > $OFFFILE	# UGH - IN CASE OFFIINE IS DITCHED AFTER WHILE IS DONE
		else
			NONGR=`$EXPR $NONGR + $lapsetime`
			$RM -f $OFFFILE
			echo "$NONGR" > $NONGRFILE	# UGH - IN CASE OFFIINE IS DITCHED AFTER WHILE IS DONE
		fi

		echo "<IMG SRC=\"$BBSKIN/$color.gif\" BORDER=0 HEIGHT=16 WIDTH=16 ALT=\"$color\"></A></TD><TD ALIGN=CENTER>$lapsetime</TD><TD>$causelines</TD></TR>"

		#
		# Update text based report
		#
		cause=`echo $causelines | $SED 's/<.*>//g'`
		echo "$STARTEVENT	$ENDEVENT	$color	$lapsetime	$cause" >> ${repfile}
	done

        $RM -f $TMPFILE

	# SMM UGLY
	# I CAN'T SEEM TO ADD UP THE OFFLINE TIME AND KEEP IT ACROSS
	# THE do/done LOOP.  UGH.  AND ANY EFFORT TO WRITE TO A TEMP
	# FILE SCREWS UP THE DISPLAY.  DON'T ASK ME.  REALLY.
	
	day=86400
	hour=3600
	min=60

	for style in crit nongr
	do
		if [ "$style" = "crit" ]
		then
			if test -f $OFFFILE
			then
				OFFLINE=`cat $OFFFILE`
				$RM -f $OFFFILE
			fi
			OFFMSG="Time Critical/Offline:"
		else
			if [ "$STYLE" != "nongr" ]
			then
				continue
			fi

			if test -f $NONGRFILE
			then
				OFFLINE=`cat $NONGRFILE`
				$RM -f $NONGRFILE
			fi
			OFFMSG="Time Non-Critical:"
		fi

		numsecs=$OFFLINE

		DAYS=`$EXPR $numsecs / 86400`
		if [ "$DAYS" -gt 0 ]
		then
			OFFMSG="$OFFMSG $DAYS days"
			numsecs=`$EXPR $numsecs % 86400`
		fi
		
    		HOURS=`$EXPR $numsecs / 3600`
		if [ "$HOURS" -gt 0 -o "$DAYS" -gt 0 ]
		then
			OFFMSG="$OFFMSG $HOURS hours"
			numsecs=`$EXPR $numsecs % 3600`
		fi
		
    		MINS=`$EXPR $numsecs / 60`
		if [ "$MINS" -gt 0 -o "$HOURS" -gt 0 -o "$DAYS" -gt 0 ]
		then
			OFFMSG="$OFFMSG $MINS mins"
			numsecs=`$EXPR $numsecs % 60`
		fi
		
    		SECS=$numsecs
		if [ "$SECS" -gt 0 -o "$MINS" -gt 0 -o "$HOURS" -gt 0 -o "$DAYS" -gt 0 ]
		then
			OFFMSG="$OFFMSG $SECS secs"
		else
			OFFMSG="$OFFMSG none"
		fi
		
		echo "<TR><TD ALIGN=CENTER BGCOLOR="#000033" COLSPAN=3>
			<B>$OFFMSG</B></TD>"
		echo "<TD ALIGN=CENTER NOWRAP>$OFFLINE</TD><TD>&nbsp;</TD></TR>"

		#
		# Update text based report
		#
		echo "


				$OFFMSG" >> ${repfile}

	done
	
	echo "</TABLE>
<BR><BR>"

	echo "<BR><BR><CENTER><FONT COLOR=yellow><A HREF=\"${BBWEB}/rep/${repname}\">Click here for text-based availability report </A></FONT></CENTER><BR><BR>"


	#
	# EXECUTE LOCAL SCRIPTS FROM HERE...
	# SCRIPTS SHOULD LIVE IN $BBHOME/ext/rep DIRECTORY
	# BBREPEXT CONTAINS THE FILENAMES TO EXECUTE
	#
	BBREPEXT=`echo "$BBREPEXT" | $SED 's!\.\./!\./!g'`
	for file in $BBREPEXT
	do
		if [ -x "$BBHOME/ext/rep/$file" ]
		then
			$BBHOME/ext/rep/$file
		else
			echo "<BR><B>bb-replog.sh: $BBHOME/ext/rep/$file can't be executed</B><BR>"
		fi
	done

echo "</CENTER>"

	$CAT $BBHOME/web/replog_footer | $SED "s/&BBRELDATE/$BBRELDATE/g" | $SED "s/&BBREL/$BBREL/g" |\
        	$SED "s/&BBDATE/$RANGE/g" | $SED "s!&BBBACKGROUND!$BBSKIN\/bkg-$bkgcolor.gif!g" |\
		$SED "s/&BBHOST/$HOSTDOTS/g" | $SED "s/&BBSVC/$SERVICE/g" |\
		$SED "s!&BBWEB!$BBWEB!g" | $SED "s!&BBIPNAME!$BBIPNAME!g" | $SED "s!&BBIP!$BBIP!g" |\
		$SED "s!&BBSKIN!$BBSKIN!g"
    else
        echo "<H2>Error reading data file</H2>"
    	echo "</BODY></HTML>"
    fi
    rc=0
else

	echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>bb-replog.sh called with invalid arguments</H1>"
	echo "</BODY></HTML>"   
	rc=1

fi

$RM -f $OFFFILE
$RM -f $NONGRFILE
$RM -f $TMPFILE

exit $rc
