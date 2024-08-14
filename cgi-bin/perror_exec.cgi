#! /bin/sh
WEBHOME=/export/web/webserver/apache/share
NEWS_DIR=/export/web/webserver/apache/share/htdocs/news
export WEBHOME NEWS_DIR
NLINE=6
DESCR="YES"


# Get serach parameters

#	
#	ARGV=`	echo "$QUERY_STRING"|\
#		sed '
#			s/Node=//
#			s/++*/ /g
#			s/%2C/ /g
#			s/  */ /g
#		'`
#	set -- "$ARGV"

get_env(){
echo "$QUERY_STRING" |
sed 's/\&/\
/g'
}

#[ "${QUERY_STRING:-NO}" = NO ]&&exit
PRINT_CONFIG=get_env
P_ENV=`
        ${PRINT_CONFIG} |
        awk -F"="  '{
                OFS=""; val=substr($0,index($0,"=")+1,length($0)-index($0,"="))
                if( $1 != "" ){
                        print $1,"=\"",val," $",$1,"\""; print "export ",$1
                }
        } '|
	sed '
	s/  */ /g
	s/= /=/g
	s/ *$//'
`
eval "
$P_ENV
"

# Print html header

echo "Content-type: text/html

		
<TITLE> SunSa Print Error</TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY>
<BODY bgcolor="white">
"
# System Errors finding

[ "${Errno:-NO}" != "NO" -a  "$Errno" != " " ]&&{

echo "
<br>
<center>
<b>
<font size=+1 >
SunSolarts (UNIX) System Errors <br>
</font>
</b>
<br>
<table border=1>
<tr>
<td ALIGN=CENTER  BGCOLOR=#CCFFFF >
Errno
</td>
<td ALIGN=CENTER  BGCOLOR=#CCFFFF >
Description</td>
"
$WEBHOME/cgi-bin/perr.exe `echo $Errno|sed 's/+/ /g'` 2>&1 |
sed '
s/^/<tr><td>/
s/:/<\/td><td>/
s/$/<\/td><\/tr>/
'
echo "</table></center>"
}



# Print footer

cat <<END
</body>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
</html>
END
