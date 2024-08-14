#! /bin/sh
#WEBHOME=/export/web/webserver/apache/share
WEBHOME=/web/apache
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
# Oracle error finding

#! /bin/sh

ERRDIR=/export/web/webserver/apache/share/htdocs/vendor/oracle/err/8.0.5
echo "
<center>
<b>
<font size=+1 >
<br>
ORACLE 8.0.5 Errors<br>
<br>
</font>
"

ERR=`echo "$Oracle"|sed '
s/ //g
s/++/+/g
s/^+//
s/+$//
s/+/,|^[0]*/g
s/^/^[0]*/
s/$/,/
'`
echo "
<table border=1 >
<b>
<tr>
<td ALIGN=CENTER  BGCOLOR=#CCFFFF >
ERRDB
</td>
<td ALIGN=CENTER  BGCOLOR=#CCFFFF >
DESCRIPTION
</td>
<td ALIGN=CENTER  BGCOLOR=#CCFFFF >
CAUSE/ACTION
</td>
</tr>
</b>
"
for ERRFILE in `find $ERRDIR  -type f -name '*.msg' -print`
do
		BNAME=`basename $ERRFILE`
               awk 'BEGIN      { FOUND=0; }
                /'"$ERR"'/     { FOUND=1;
                                printf "'"$BNAME"'	" ;
                                print ; next;}
                /^\/\//         { if (FOUND)
                                  {
                                        printf "'"$BNAME"'		" ;
                                        print
                                        next
                                  }
                                  else
                                        next;
                                }
                                { if (FOUND)
                                        exit;
                                   else
                                        next;
                                } ' $ERRFILE
done |
sed '
s/  */ /g
s/  *$//
s/^  *//
s/	  */	/g
s/^/<tr><td>\&nbsp;/
/		/{
	s/		/<\/td><td>\&nbsp;<\/td><td>\&nbsp;/
	s/$/<\/td><\/tr>/
}
/	/{
	s/	/<\/td><td>\&nbsp;/
	s/$/<\/td><td>\&nbsp;<\/td><\/tr>/
}
'
echo "</table></center>"


# Print footer

cat <<END
</body>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
</HTML>
END
