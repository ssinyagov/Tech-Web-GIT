#!/bin/sh
#
# BIG BROTHER WEB BASED HISTORY DISPLAY SCRIPT
# Robert-Andre Croteau
# Version 1.6
# Dec 18th, 2000
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
		<H1>ERROR!<BR>BBHOME IS NOT SET IN bb-hist.sh</H1></BODY>
		</HTML>"
	exit 1
fi


. $BBHOME/etc/bbdef.sh


# Are we called from a web page ?
if [ "$QUERY_STRING" != "" ]
then

    HISTFILE="HISTFILE_NOT_DEFINED"
    ENTRIES=50
    set -f
    QUERY_STRING=`echo "$QUERY_STRING" | $SED 's/[^A-Za-z0-9_,.&=:%-]//g' | $SED 's/[&=][.][.]*//g' | $SED 's/\.\.//g'`
    set `echo "$QUERY_STRING" | $SED 's/[&=]/\ /g' | $SED 's/%2[Cc]/,/g'` >/dev/null 2>&1
    while [ "$#" -ne 0 ]
    do
        case $1 in
	HISTFILE )	HISTFILE="$2"
			shiftnum=2
			;;
	ENTRIES )
			if [ "$2" = "all" ]
			then
				ENTRIES=all
			else
				ENTRIES=`echo "$2" | $SED 's/[^0-9]//g'`
			fi
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

    if [ "$HISTFILE" = "HISTFILE_NOT_DEFINED" -o "$HISTFILE" = "" -o "$ENTRIES" = "" ]
    then
	echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>bb-hist.sh called with invalid arguments</H1>"
	echo "</BODY></HTML>"   
	exit 1
    fi

    # Take the basename only !!!
    # 
    OLDIFS=$IFS
    IFS='/'
    set $HISTFILE
    IFS=$OLDIFS
    lastarg="\$$#"
    HISTFILE=`eval "echo $lastarg"`
    HISTFILE=`echo "$HISTFILE" | $SED 's/[^A-Za-z0-9.\,_-]//g'`
    HOSTFILE=`echo "$HISTFILE" | $SED 's/\,/\./g'`
    OLDIFS=$IFS
    IFS='.'
    set $HOSTFILE
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

    BBIP=`$BBHOME/bin/getipaddr -f $FQDNNAME`
    BBIPNAME=`$BBHOME/bin/getipaddr $FQDNNAME`

    if [ -r "$BBLOGS/${HISTFILE}" ]
    then
	set `$CAT "$BBLOGS/${HISTFILE}" | $HEAD -1`
	bkgcolor="$1"
    else
	bkgcolor="clear"
    fi

    echo "Content-type: text/html

"

    # Is someone playing funny with us ?
    TMPFILE="/tmp/BBHIST.$$"
    $RM -f $TMPFILE
    $TOUCH $TMPFILE
    if [ ! -f $TMPFILE -o ! -w $TMPFILE ]
	then
	echo "<H1><BLINK>ERROR!<BR>bb-hist.sh is being tampered with<BLINK></H1>"
	TMPFILE=/dev/null
    else
	$RM -f $TMPFILE
    fi

    BBWEB=`echo $BBWEB | $SED 's/\//\\\\\//g'`
    export BBWEB

    $CAT $BBHOME/web/hist_header | \
	$SED -e "s/&BBRELDATE/$BBRELDATE/g" -e "s/&BBREL/$BBREL/g" \
        	-e "s/&BBDATE/`$DATE`/g" -e "s!&BBBACKGROUND!$BBSKIN\/bkg-$bkgcolor.gif!g" \
		-e "s/&BBHOST/$HOSTDOTS/g" -e "s/&BBSVC/$SERVICE/g" \
		-e "s!&BBWEB!$BBWEB!g" -e "s!&BBIPNAME!$BBIPNAME!g" -e "s!&BBIP!$BBIP!g" \
		-e "s!&BBSKIN!$BBSKIN!g"

    if [ -f "$BBHIST/$HISTFILE" ]
    then
        nowtick=`$BBHOME/bin/touchtime -e`
	daytick=`$EXPR $nowtick - 86400`
        prevcolor="green"
        prevline=""
        firstday=TRUE
	lastline=`$TAIL -1 "$BBHIST/$HISTFILE"`
	set $lastline >/dev/null
        lastlinecolor=$6
	lastlinetick=$7
        echo "<CENTER>
<BR>
<TABLE WIDTH=\"100%\" BORDER=0 BGCOLOR=666666>
<TR><TD>
<TABLE WIDTH=\"100%\" BORDER=1 BGCOLOR=\"\#000033\">
<TR>
<TD WIDTH=\"50%\" ALIGN=LEFT><B>`$BBHOME/bin/touchtime -a -1440`</B></TD>
<TD WIDTH=\"50%\" ALIGN=RIGHT><B>`$BBHOME/bin/touchtime -a`</B></TD>
</TR>
</TABLE>
<TABLE WIDTH=\"100%\" BORDER=0 BGCOLOR=\"\#000033\">"
        starthr=`$DATE +"%H"`
        if [ "$starthr" -eq 23 ]
        then
            starthr=0
        else
            starthr=`$EXPR $starthr + 1`
        fi
        #i=0
	i=""
        echo "<TR>"
        minmod=`$EXPR $nowtick % 3600 / 60`
        quarters=`$EXPR \( $minmod / 15 \) + 1`
        startquarters=`$EXPR 4 - $quarters`
        if [ "$startquarters" -gt 0 ]
        then
            starthr=`$EXPR $starthr - 1`
            if [ "$starthr" -eq -1 ]
            then
                starthr=23
            fi
            echo "<TD WIDTH=${startquarters}%><B>&nbsp</B></TD>"
            starthr=`$EXPR \( $starthr + 1 \) % 24`
            #i=`$EXPR $i + 1`
	    i="."
        fi
        if [ "$startquarters" -eq 0 ]
        then
            #loops=23
	    loops="......................."
        else
            #loops=24
	    loops="........................"
        fi
        #while [ "$i" -lt $loops ]
	while [ "$i" != "$loops" ]
        do
            echo "<TD WIDTH=4% ALIGN=LEFT><B>$starthr</B></TD>"
            starthr=`$EXPR \( $starthr + 1 \) % 24`
            #i=`$EXPR $i + 1`
	    i="${i}."
        done
        quarters=`$EXPR "$quarters" + 1`
        echo "<TD WIDTH=${quarters}% ALIGN=LEFT><B>$starthr</B></TD>"
        echo "</TR>"
        echo "</TABLE>"
        echo "<TABLE WIDTH=100% BORDER=0 BGCOLOR=\"\#000033\">"
        echo "<TR>"
        greenticks=0
        yellowticks=0
        redticks=0
        purpleticks=0
        whiteticks=0
	blueticks=0
        if [ "$lastlinetick" -lt "$daytick" ]
        then
	    alldaycolor=$bkgcolor
	    if [ "$alldaycolor" = "clear" ]
	    then
		alldaycolor=white
	    fi
            echo "<TD WIDTH=\"100%\" BGCOLOR=\"$alldaycolor\" NOWRAP>&nbsp</TD>"
            evalstr="${lastlinecolor}ticks=86400"
            eval "$evalstr"
        else
	$CAT "$BBHIST/$HISTFILE" | \
		$AWK 'BEGIN { i=0 } { if( $7 < '$daytick') {line[i] = $0}  else { i++; line[i] = $0 } } \
		  END { for (j=0;j <= i;++j) print line[j] }' | $GREP -v "^$" | \
        while read line
        do
            set $line >/dev/null
            if [ "$#" -ge 7 ]
            then
                if [ "$6" = "clear" ]
                then
                    color=white
                else
                    color=$6
                fi
                if [ "$7" -ge "$daytick" ]
                then
                    if [ "$firstday" = TRUE ]
                    then
			headdayticks=`$EXPR $7 - $daytick`
                        firstday=FALSE
                        if [ "$headdayticks" -ne 0 ]
                        then
                            perc=`$EXPR 100 \* $headdayticks / 86400`
                            if [ "$perc" -eq 0 ]
                            then
                                perc=1
                            fi
                            evalstr="${prevcolor}ticks=\`$EXPR \$${prevcolor}ticks + $headdayticks\`"
                            eval "$evalstr"
                            echo "<TD WIDTH="$perc%" BGCOLOR=$prevcolor NOWRAP>&nbsp</TD>"
                        fi
                    fi
                    if [ "$#" -gt 7 ]
                    then
                        headdayticks=$8
                    else
                        headdayticks=`$EXPR $nowtick - $7`
                    fi
                    perc=`$EXPR 100 \* $headdayticks / 86400`
                    if [ "$perc" -eq 0 ]
                    then
                        perc=1
                    elif [ "$perc" -gt 10 ]
                    then
                        perc=`$EXPR "$perc" - 1` # hack to readjust colored blocks
                    fi
                    evalstr="${color}ticks=\`$EXPR \$${color}ticks + $headdayticks\`"
                    eval "$evalstr"
                    echo "<TD WIDTH="$perc%" BGCOLOR=$color NOWRAP>&nbsp</TD>"
                    if [ "$#" -eq 7 ]
                    then
			if [ "$TMPFILE" != "/dev/null" ]
			then
			        $RM -f $TMPFILE
			fi
                        echo "${greenticks} ${yellowticks} ${redticks} ${purpleticks} ${whiteticks} ${blueticks}" > $TMPFILE
                    fi
                fi
	        prevline="$line"
                prevcolor=$color
            fi
        done
	#exec <&0
        fi
        echo "</TR>
</TABLE>

</TD></TR></TABLE>

<BR><FONT $MKBBROWFONT><H2>$HOSTDOTS - $SERVICE</H2></FONT>
<TABLE BORDER=0 BGCOLOR=\"#333333\" CELLPADDING=3>
<TR BGCOLOR=\"#000000\">
<TD ALIGN=CENTER COLSPAN=6><B>Last 24 Hours</B></TD>
</TR>
<TR BGCOLOR=\"#000000\">"
	echo "<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/green.gif\" ALT=\"green\" HEIGHT=$DOTHEIGHT WIDTH=$DOTWIDTH BORDER=0></TD>
<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/yellow.gif\" ALT=\"yellow\" HEIGHT=$DOTHEIGHT WIDTH=$DOTWIDTH BORDER=0></TD>
<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/red.gif\" ALT=\"red\" HEIGHT=$DOTHEIGHT WIDTH=$DOTWIDTH BORDER=0></TD>
<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/purple.gif\" ALT=\"purple\" HEIGHT=$DOTHEIGHT WIDTH=$DOTWIDTH BORDER=0></TD>
<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/clear.gif\" ALT=\"clear\" HEIGHT=$DOTHEIGHT WIDTH=$DOTWIDTH BORDER=0></TD>
<TD ALIGN=CENTER><IMG SRC=\"$BBSKIN/blue.gif\" ALT=\"blue\" HEIGHT=$DOTHEIGHT WIDTH=$DOTWIDTH BORDER=0></TD>
</TR>
<TR BGCOLOR=\"#000033\">"
        if [ -f "$TMPFILE" ]
        then
            evalstr=`$CAT "${TMPFILE}" | $SED 's/[^0-9 ]//g'`
            if [ "$TMPFILE" != "/dev/null" ]
	    then
	        $RM -f $TMPFILE
	    fi
	    set $evalstr >/dev/null
	    greenticks=$1
	    yellowticks=$2
	    redticks=$3
            purpleticks=$4
            whiteticks=$5
	    blueticks=$6
        fi
	timespan=86400
	if [ "$BBHIST_IGNOREBLUE" = TRUE ]
	then
		timespan=`$EXPR 86400 - "$blueticks"`
		if [ "$?" -ne 0 ]
		then
			timespan=86400
		fi
		if [ "$timespan" -lt 0 ]
		then
			timespan=0
		fi
	fi
        if [ "$greenticks" -ne 0 ]
        then
            greenperc=`$EXPR $greenticks \* 100 / $timespan`
            if [ "$greenperc" -eq 0 ]
            then
                greenperc=1
            fi
        else
            greenperc=0
        fi
        if [ "$yellowticks" -ne 0 ]
        then
            yellowperc=`$EXPR $yellowticks \* 100 / $timespan`
            if [ "$yellowperc" -eq 0 ]
            then
                yellowperc=1
            fi
        else
            yellowperc=0
        fi
        if [ "$redticks" -ne 0 ]
        then
            redperc=`$EXPR $redticks \* 100 / $timespan`
            if [ "$redperc" -eq 0 ]
            then
                redperc=1
            fi
        else
            redperc=0
        fi
        if [ "$purpleticks" -ne 0 ]
        then
            purpleperc=`$EXPR $purpleticks \* 100 / $timespan`
            if [ "$purpleperc" -eq 0 ]
            then
                purpleperc=1
            fi
        else
            purpleperc=0
        fi
        if [ "$whiteticks" -ne 0 ]
        then
            clearperc=`$EXPR $whiteticks \* 100 / $timespan`
            if [ "$clearperc" -eq 0 ]
            then
                clearperc=1
            fi
        else
            clearperc=0
        fi
        if [ "$blueticks" -ne 0 ]
        then
            blueperc=`$EXPR $blueticks \* 100 / $timespan`
            if [ "$blueperc" -eq 0 ]
            then
                blueperc=1
            fi
        else
            blueperc=0
        fi

	if [ "$ENTRIES" = "all" ]
	then
		entriestitle="All log entries"
	else
		entriestitle="Last $ENTRIES log entries"
	fi

        echo "<TD ALIGN=CENTER><B>${greenperc}%</B></TD>
<TD ALIGN=CENTER><B>${yellowperc}%</B></TD>
<TD ALIGN=CENTER><B>${redperc}%</B></TD>
<TD ALIGN=CENTER><B>${purpleperc}%</B></TD>
<TD ALIGN=CENTER><B>${clearperc}%</B></TD>
<TD ALIGN=CENTER><B>"

	if [ "$BBHIST_IGNOREBLUE" = TRUE -a "$blueperc" -gt 0 ]
	then
		echo "ignored"
	else
		echo "${blueperc}%"
	fi

	echo "</B></TD>
</TR>
<TR BGCOLOR=\"#000000\">
<TD COLSPAN=6 ALIGN=CENTER>
<FONT $MKBBCOLFONT><B>[Total may not equal 100%]</B></TD> </TR>
</TABLE>
</CENTER>"
    
	if [ -d $BBHOME/www/hist ]
	then
		TEXTLOG="<A HREF=\"$BBWEB/hist/$HISTFILE\"> (Full text log) </A>"
	else
		TEXTLOG=""
	fi
 
	echo "<BR><BR>
<CENTER>
<TABLE BORDER=0 BGCOLOR=\"#333333\" CELLSPACING=3>
<TR BGCOLOR=\"#000000\">
<TD ALIGN=CENTER COLSPAN=3><B>$entriestitle</B>$TEXTLOG<A HREF=\"$CGIBINURL/bb-hist.sh?HISTFILE=$HISTFILE&ENTRIES=all\"> (Full HTML log) </A></TD>
</TR>
<TR BGCOLOR=\"#333333\">
<TD ALIGN=CENTER><FONT $MKBBCOLFONT><B>Date</B></TD>
<TD ALIGN=CENTER><FONT $MKBBCOLFONT><B>Status</B></TD>
<TD ALIGN=CENTER><FONT $MKBBCOLFONT><B>Seconds</B></TD></TR>"

        if [ "$TMPFILE" != "/dev/null" ]
	then
	        $RM -f $TMPFILE
	fi
        $SORT -r -n -k 7 "$BBHIST/$HISTFILE" > $TMPFILE
        if [ "$?" -ne 0 ]
        then 
            echo "Your SORT command does not seem to support the \"-r -n -k 7\"<BR>"
            echo "option. It probably wants \"-r -n +7\" as the option to SORT<BR>"
            echo "On AIX, use \"-k7nr\"<BR>"
            echo "please fix it in the bb-hist.sh script"
        fi
	if [ "$ENTRIES" = "all" ]
	then
		maxentries=999999999
	else
		maxentries="$ENTRIES"
	fi
        tablesize=1
        $CAT $TMPFILE | \
	while read line
	do 
		if test "$BG" = "000000"
		then
			BG="000033"
		else
			BG="000000"
		fi
		set $line > /dev/null
		echo "<TR BGCOLOR=$BG><TD ALIGN=LEFT>$1 $2 $3 $4 $5</TD><TD ALIGN=CENTER BGCOLOR=\"#000000\">"
		HOSTDIR=`echo $HOSTDOTS | $SED 's/\./_/g'`
		echo "<A HREF=\"$CGIBINURL/bb-histlog.sh?HOST=$HOSTDOTS&SERVICE=$SERVICE&TIMEBUF=${1}_${2}_${3}_${4}_${5}\">"
		echo "<IMG SRC=\"$BBSKIN/$6.gif\" BORDER=0 HEIGHT=$DOTHEIGHT WIDTH=$DOTWIDTH ALT=\"$6\"></A></TD><TD ALIGN=CENTER>$8</TD></TR>"
		# The -gt MUST be between integers... both tests in if are done regardless of 1st test :(
                if [ "$ENTRIES" != "all" -a "$tablesize" -gt "$maxentries" ]
                then
                    break
                else
                    tablesize=`$EXPR "$tablesize" + 1`
                fi
	done

	# Only delete if no funnies happening
	if [ "$TMPFILE" != "/dev/null" ]
	then
	        $RM -f $TMPFILE
	fi

	echo "</TABLE>
<BR><BR>"

	#
	# EXECUTE LOCAL SCRIPTS FROM HERE...
	# SCRIPTS SHOULD LIVE IN $BBHOME/ext/hist DIRECTORY
	# BBHISTEXT CONTAINS THE FILENAMES TO EXECUTE
	#
	BBHISTEXT=`echo "$BBHISTEXT" | $SED 's!\.\./!\./!g'`
	for file in $BBHISTEXT
	do
		if [ -x "$BBHOME/ext/hist/$file" ]
		then
			$BBHOME/ext/hist/$file
		else
			echo "<BR><B>bb-hist.sh: $BBHOME/ext/hist/$file can't be executed</B><BR>"
		fi
	done

echo "</CENTER>"

	$CAT $BBHOME/web/hist_footer | \
		$SED -e "s/&BBRELDATE/$BBRELDATE/g" -e "s/&BBREL/$BBREL/g"  \
			-e "s/&BBDATE/`$DATE`/g" -e "s!&BBBACKGROUND!$BBSKIN\/bkg-$bkgcolor.gif!g" \
			-e "s/&BBHOST/$HOSTDOTS/g" -e "s/&BBSVC/$SERVICE/g" \
			-e "s!&BBWEB!$BBWEB!g" -e "s!&BBIPNAME!$BBIPNAME!g" -e "s!&BBIP!$BBIP!g" \
			-e "s!&BBSKIN!$BBSKIN!g"
    else
        echo "<H2>Error reading history file</H2>"
    	echo "</BODY></HTML>"
    fi

    exit 0

else
	echo "Content-type: text/html


                <HTML><BODY>
                <H1>ERROR!<BR>bb-hist.sh called with invalid arguments</H1>"
	echo "</BODY></HTML>"   
	exit 1
fi
