#!/bin/sh
#
# BIG BROTHER WEB BASED MANUAL NOTIFICATION ACKNOWLEDGEMENT SCRIPT
# Sean MacGuire - BB4 Technologies Inc.
# Version 1.6a
# Dec 21st, 2000
#
# This program is Copyright (c) 1997-2000
# BB4 Technologies Inc.
# All Rights Reserved
#

#
# ************* NOTICE!!! ************
# BBHOME MUST BE SET CORRECTLY FOR THIS TO WORK

BBHOME="/export/home/bb/bb16a"
export BBHOME
if [ "$BBHOME" = "" -o ! -d "$BBHOME" ]
then
	echo "Content-type: text/html


		<HTML><BODY>
		<H1>ERROR!<BR>BBHOME IS INVALID IN bb-ack.sh</H1></BODY>
		</HTML>"
	exit 1
fi

# Save the arguments for later use
ARG1="$1"
ARG2="$2"
ARG3="$3"

. $BBHOME/etc/bbdef.sh


# Are we called from a web page ?
if [ "$QUERY_STRING" != "" ]
then


    set -f
    QUERY_STRING=`echo "$QUERY_STRING" | $SED 's/[^A-Za-z0-9_,.&=:%-]//g' | $SED 's/[&=][.][.]*//g' | $SED 's/\.\.//g'`
    set `echo "$QUERY_STRING" | $SED "s/[&=]/\ /g"` >/dev/null 2>&1
    while [ "$#" -ne 0 ]
    do
        case $1 in
	ACTION )	ACTION=`echo "$2" | $SED 's/[^A-Za-z]//g'`  
			shift 2
			;;
	NUMBER )	NUMBER=`echo "$2" | $SED 's/[^0-9]//g'`
			if test "$NUMBER" != "DELAY"
			then
				shift 2
			else 
				NUMBER=""
				shift
			fi
			;;
	DELAY )		DELAY=`echo "$2" | $SED 's/[^0-9]//g'`
			if test "$DELAY" = ""
			then
				DELAY=60	# DUMB DEFAULT
			fi
			shift
			;;
	MESSAGE )
		# MESSAGE MIGHT BE NULL
		case "$2" in
		NUMBER | DELAY )
			MESSAGE=""
			shift
			;;
		* )
			MESSAGE=`echo "$2" | $SED 's/[${}\\]//g'`
			shift 2
			;;
		esac
		;;
	*)		shift
			;;
	esac
    done

    if [ "$ACTION" = "" ]
    then
	echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>bb-ack.sh called with invalid arguments</H1>"
	echo "</BODY></HTML>"   
	exit 1
    fi

    echo "Content-type: text/html

<HTML>
<HEAD>

<!-- 
        Big Brother - 1.6a  (Thu, 21 Dec 2000 23:00:00 GMT)
        Copyright 1997-2000 BB4 Technologies Inc. - All Rights Reserved 
        From: http://bb4.com/
        Contact: info@bb4.com
        BODY WAS FFFFCC
-->

<TITLE>Big Brother - Contact</TITLE>
</HEAD>

<BODY BGCOLOR=\"red\" BACKGROUND=\"$BBSKIN/bkg-red.gif\" FONT=\"Arial, Helvetica\" TEXT=\"silver\" LINK=\"#00FFAA\" VLINK=\"#FFFF44\">

<CENTER>

<TABLE WIDTH=100% BORDER=0>
<TR>
<TD VALIGN=TOP ALIGN=LEFT>
<A HREF=\"http://bb4.com\"><IMG SRC=\"$BBSKIN/bb.gif\" ALT=\"Big Brother\"
BORDER=0></A><BR>
<A HREF=\"$BBWEB/bb.html\">
<IMG SRC=\"$BBSKIN/bbnav2.gif\" ALT=\"View\" BORDER=0></A>
<A HREF=\"$BBWEB/help/bb-help.html\">
<IMG SRC=\"$BBSKIN/bbnav3.gif\" ALT=\"Help\" BORDER=0></A>
</TD>

<TD VALIGN=TOP ALIGN=RIGHT>
<FONT FACE=\"Arial, Helvetica\" SIZE=+1 COLOR=\"silver\">
<B>contact</B><BR>
<IMG SRC=\"$BBSKIN/bbnav1.gif\" ALT=\"Ack\" BORDER=0>
</TD></TR></TABLE>
<FONT FACE=\"Arial, Helvetica\" SIZE=+1 COLOR=\"silver\">
<BR><BR><BR><BR>"

else
    if [ "$#" -lt 2 -o "$#" -gt 3 ]
    then
	echo "usage: bb-ack.sh <ticket #> <delay> [message]"
	exit 1
    fi
    NUMBER=`echo "$ARG1" | $SED 's/[^0-9]//g'`
    DELAY=`echo "$ARG2" | $SED 's/[^0-9]//g'`
    MESSAGE="$3"
    ACTION="Ack"
fi

if [ "$ACTION" = "Ack" ]
then
	if [ "$NUMBER" != "" ]
	then
		CHKNUM=`$EXPR "$NUMBER" + 0 2>/dev/null`
	else
		CHKNUM=""
	fi
	if [ "$NUMBER" != "$CHKNUM"  -o "$CHKNUM" = "" ]
	then
	    	# Are we called from a web page ?
    		if [ "$QUERY_STRING" != "" ]
    		then
        		echo "Invalid security code<BR><BR>Try again."
        		echo "</I></H2></BODY></HTML>"
    		else
        		echo "usage: bb-ack.sh <ticket #> <delay> [message]"
    		fi
    		exit 1
	fi

	if [ "$DELAY" != "" ]
	then	
		CHKDELAY=`$EXPR "$DELAY" + 0 2>/dev/null`
	else
		CHKDELAY=""
	fi
	if [ "$DELAY" != "$CHKDELAY" -o "$CHKDELAY" = "" ]
	then
    		# Are we called from a web page ?
    		if [ "$QUERY_STRING" != "" ]
    		then
			echo "Invalid delay<BR>"
			echo "</I></H2></BODY></HTML>"
    		else
        		echo "usage: bb-ack.sh <ticket #> <delay> [message]"
    		fi
    		exit 1
	fi
	
    	if [ "$QUERY_STRING" != "" ]
	then
		BREAK="<BR>"
	fi

	$BB $BBPAGE "ack ack_event ${NUMBER} ${DELAY} ${MESSAGE}"
	
	echo "Acknowledgement Sent. <BR><BR>Notification event ${NUMBER} $BREAK <BR>${DELAY} minute delay"

elif [ "$ACTION" = "Page" ]
then
	if test "$MESSAGE" = ""
	then
		echo "Empty message.<BR><BR>No page sent"
	else
		# Don't change the notify-admin.pagehelp name or suffer the consequences !
		$BB $BBPAGE "page notify-admin.pagehelp ${MESSAGE} User has requested your help.  Call ${MESSAGE}"
		echo "Page sent.<BR><BR>You will be contacted shortly!"
	fi
else
	if [ "$QUERY_STRING" != "" ]
	then
		echo "Invalid ACTION type"
	fi
fi

exit 0
