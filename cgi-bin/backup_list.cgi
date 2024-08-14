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

cd $WEBHOME/htdocs/vendor/veritas/netbackup

for db in *.db
do
	read header <$db

	tail +2 $db|
  	if [ `expr "$cmd" : '[Aa][Ll][Ll]' `  = 3 ] ; then
                cat
        else
		/bin/egrep -i "$cmd" 
	fi| 
	{
		if read ln ; then (
			# Print header
			echo "<br><b>$db</b><br>"
			echo "<table border width=\"100%\"><b>"
			echo "$header"| sed '
				s/  */ /g
				s/ 	/	/g
				s/	 /	/g
				s/^ //
				s/ $//
				s/^/<tr bgcolor="#66ffff"><td align="center">/
				s/$/\&nbsp;<\/td><\/tr>/
				s/	/\&nbsp;<\/td><td align="center">/g'
			echo "</b>"
			# Print body
  			( echo "$ln" ; cat )|
			sed '
				s/  */ /g
				s/ 	/	/g
				s/	 /	/g
				s/^ //
				s/ $//
				s/^/<tr align="left" valign="top" ><td>/
				s/$/\&nbsp&<\/td><\/tr>/
				s/	/\&nbsp;<\/td><td>/g
			'
			echo "</table>"
		)
		fi
	}
done
cat <<END
<br>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
END


# Print footer

echo "</body></HTML>"
