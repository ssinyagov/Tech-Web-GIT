#! /bin/sh
WEBHOME=`grep "^webadmin:" /etc/passwd|cut -f 6 -d":"`

# Get serach parameters

[ "${QUERY_STRING:-NO}" != NO ]&&{
	ARGV=`	echo "$QUERY_STRING"|\
		sed '
			s/Node=//
			s/++*/ /g
			s/%2C/ /g
			s/  */ /g
		'`
	set -- "$ARGV"
}

# Print html header

echo "Content-type: text/html

		
<TITLE> SUNSA Backup Schedule Information Service </TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY bgcolor="white">
"
cmd=`echo $*|sed 's/  */|/g'`

cd $WEBHOME/htdocs/subsystem/netbackup/schedule

for db in *.db
do
	dt=`ls -l $db|awk '{ print $6,$7,$8 }'`
	echo "<br><b>DataBase: $db , Last Update: $dt</b><br>"
        if [ `expr "$cmd" : '[Aa][Ll][Ll]' `  = 3 ] ; then
		cat $db |sed '
		s/</ /g
		s/>/ /g'
	else 	
	{
                sedcmd=` ( 

			cat $db |sed '
			s/</ /g
			s/>/ /g'
			 echo "-------------------" )|
                egrep -i -n "\-\-\-\-|$cmd" |
                awk -F":" ' BEGIN{ from=1; insec=0; OFS="" ; }
                {
                        if( $2 ~ /-----/ )
                                if( insec == 1 ) {
                                        insec=0 ; print from,",",$1,"p"
					from=$1
                        	}
                                else from=$1
                        else
                                if( insec == 1 ) next
                                else insec=1
                }
                END { 
			print "/^/d" 
		}'
		`

                ( cat $db ; echo "-------------------" )|
                sed "$sedcmd"
	}

	fi|{
#		echo "<font size=-1 face=\"Courier New, Courier, mono\">"
                sed '
			/-----/s/.*/<hr>/
                        /: /s/^/<b>/
                        /:$/s/^/<b>/
                        /: /s/:/:<\/b>/
                        /:$/s/:/:<\/b>/
                        s/ /\&nbsp;/g
			s/^/<font size=-1 face="Courier New, Courier, mono">/
			s/$/<\/font>/
                        s/$/<br>/
                ' 
	}
done

echo "</font>"

cat <<END
<br>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
END


# Print footer

echo "</body></HTML>"
