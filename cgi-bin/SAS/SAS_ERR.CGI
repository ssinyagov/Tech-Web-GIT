#! /bin/sh
WEBHOME=/export/web/webserver/apache/share
NEWS_DIR=/export/web/webserver/apache/share/htdocs/news
export WEBHOME NEWS_DIR
NLINE=6
DESCR="YES"


# Get serach parameters

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
ERRDIR=/export/web/webserver/apache/share/htdocs/application/sas/sas_server/error
ERR=`echo "$Saserr"|sed '
s/ //g
s/++/+/g
s/^+//
s/+$//
s/+/|/g
'`
[ "${ERR:-NO}" != "NO" -a "$ERR" != " " -a "$ERR" != "" ]&&{

echo "
<center>
<b>
<font size=+1 >
<br>
SAS Server Errors<br>
<br>
</font>
"

echo "
<table border=1 >
<b>
<tr>
<td ALIGN=CENTER  BGCOLOR=#CCFFFF >
ERRDB
</td>
<td ALIGN=CENTER  BGCOLOR=#CCFFFF >
ERROR
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
               sed 's///g' $ERRFILE|
		awk -F"	" 'BEGIN      { FOUND=0; }
                $1 ~ /ERROR/ { FOUND=0 }
                $1 ~ /'"$ERR"'/ { FOUND=1;
                  	printf "<tr><td>&nbsp;'"$BNAME"'</td><td>&nbsp;" ;
			for(i=1;i< split($0,a,"	");i++)
                        	printf "%s</td><td>&nbsp;",a[i]
			print a[i],"</td><tr>"
                        next
		}
                FOUND ==  1 {
                  	printf "<tr><td>&nbsp;'"$BNAME"'</td><td>&nbsp;" ;
			for(i=1;i< split($0,a,"	");i++)
                        	printf "%s</td><td>&nbsp;",a[i]
			print a[i],"</td><tr>"
                        next
                  } '
done
echo "</table></center>"

}

# Print footer

cat <<END
</body>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
</HTML>
END
