#! /bin/sh
WEBHOME=/export/web/webserver/apache/share

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

		
<TITLE> SUNSA Backup Information Service </TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY bgcolor="white">
"
cmd=`echo $*|sed 's/  */|/g'`

cd $WEBHOME/htdocs/subsystem/netbackup/schedule

ls -l|awk '{ print $0,"<br>"
for db in *.lst
do
	echo "$db<br>"
  	if [ `expr "$cmd" : '[Aa][Ll][Ll]' `  = 3 ] ; then
                cat $db
        else {
		sedcmd=` { cat $db ; echo "-------------------" }|
		egrep -i -n "\-\-\-\-|$cmd" |
		awk -F":" ' BEGIN{ from=1; insec=0; OFS="" ; }
		{
        		if( $2 ~ /-----/ )
                		if( insec == 1 ) { 
					insec=0 ; print from,",",$1,"p" 
			}
                		else from=$1
        		else
                		if( insec == 1 ) next
                		else insec=1
		}
		END { print "d" }'
		`
		{ cat $db ; echo "-------------------" }|
		sed "$sedcmd"|
		sed '
			s/$/<br>/
		'
	fi
done
cat <<END
<br>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
END


# Print footer

echo "</body></HTML>"
