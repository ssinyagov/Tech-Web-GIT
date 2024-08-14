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

		
<TITLE> SUNSA Monitored Node Information Service </TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY>
<BODY bgcolor="white">
"
cmd=`echo $*|sed '
s/  */|/g
s/\./\\\./g
'`

	rsh rksunsa10.rkv.nasd.com "cat /export/home/bb/bb/etc/bb-hosts"|	
	sed '
		s/^[ \t]*//
		s/		*/ /g
		s/	/ /g
		s/  */ /g
		/^#/d
		/^[^0-9p]/d
	'|
 	if [ `expr "$cmd" : '[Aa][Ll][Ll]' `  = 3 ] ; then
		egrep -i "^page|^[0-9]"
	else
		egrep -i "^page|$cmd"
	fi|
	while read ln
	do
		set -- $ln
		if [ "$1" = "page" ]; then
       			page=$1
        		ref=$2
        		shift ; shift
        		echo "<b>$page <a href=\"http://rksunsa10.rkv.nasd.com/bb/${ref}.html\">${*}</a></b><br>"
		else
        		echo "$* <br>"
		fi
	done

cat <<END
<br>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
END


# Print footer

echo "</body></HTML>"
