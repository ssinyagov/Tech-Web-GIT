#! /bin/sh

[ "${QUERY_STRING:-NO}" != NO ]&&{
	ARGV=`	echo "$QUERY_STRING"|\
		sed '
			s/Search=//
			s/++*/ /g
			s/%2C/ /g
			s/  */ /g
		'`
	set -- "$ARGV"
}

# print header

echo "Content-type: text/html

		
		<HTML><BODY>
"
CONTACTDIR=/var/apache/htdocs/contact
# make search string
cmd=`echo $*|sed 's/ /|/g'`
egrep -i "$cmd" $CONTACTDIR/*.db |
sed '/^[^:]*:/s///'|
sort|uniq|
awk 'BEGIN{
	print "<table BORDER>"
}
{
	split($0,par,"	")
	print "<tr>"
	for(i=1;i<=NF;i++){
		print "<td>"
		print par[i]
		print "</td>"
	}
	print "</tr>"
}
END{
	print "</table>"
}'

echo "</body></HTML>"
