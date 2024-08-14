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

		
<TITLE> SunSa supported News Service</TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY>
<BODY bgcolor="white">
"
Days=${Days:-1}

GROUP_LIST=`echo "$Group"|sed '
s/\./\//g
s/++*/+/g
s/+/ /g'`

[ "$Node" != " " ]&&SEARCH_LIST=`echo "$Node"|sed '
s/\./\//g
s/++*/+/g
s/+/ /g
s/ /|/g'`

#--------------------------------------------------------------------

NLINE=6
DESCR="YES"

for GROUP in $GROUP_LIST
do
	[ ! -d $NEWS_DIR/$GROUP ]&&{
		GROUP=`echo $GROUP|sed 's/\//\./g'`
		echo "<font color=red > Group <b>$GROUP</b> doens't exist<br>"
		echo "See valid group list:</font><br>"
		echo "<table border=1><tr><td>"
		cd $NEWS_DIR
		find . -type d -print|
		sed '
		s/\.\///g
		s/\.//g
		s/\//\./g'
		echo "</td></tr></table>"
		echo "<br>"
		continue
	}
cat <<END
	<br>
	<font size=+1" >
	Group: `echo $GROUP|sed 's/\//\./g'` <br>
	For days: $Days <br>
	String for search: $SEARCH_LIST<br>
	<br>
	</font>
END
	echo "<table WIDTH=\"100%\" NOSAVE >"
		
	cd $NEWS_DIR/$GROUP
	if [ ${SEARCH_LIST:-NO} != NO  ]; then
		find * -prune -mtime -$Days -type f -name '[0-9]*' \
			-exec egrep -si "$SEARCH_LIST" {} \; \
			-ls
	else
		find * -prune -mtime -$Days -type f -name '[0-9]*' -ls
	fi|
	while read ln
	do
		set -- $ln
		shift
		dt="$7 $8 $9"
		dts="$7 $8"
		shift
		i=$9
		cat $i|
		awk 'BEGIN{
			nline=0
			print "<tr ALIGN=LEFT VALIGN=TOP NOSAVE>"
			print "<font face="Arial, Helvetica, sans-serif" size=\"-2\">"
			while ( getline ) {
  				if( NF == 0 )
    					break
  				if( $1 ~ /^[Ss]ubject/){
					n=index($0,":")
					subject=substr($0,n+1,length($0)-n)
  				}
  				if( $1 ~ /^[Ff]rom:/){
					n=index($0,":")
					from=substr($0,n+1,length($0)-n)
  				}
			}
			descr="<br>"
			while ( getline ){
        			if(nline++ >  '"$NLINE"')break
        			if( $1 == "" ){
                			nline--
                			continue
        			}
        			descr=sprintf("%s %s",descr,$0)
			}

			print "<td ALIGN=LEFT VALIGN=TOP WIDTH=\"65%\" NOSAVE>"
			print "<font face="Arial, Helvetica, sans-serif" size=\"-2\">"
			print "<b>"
			print "<a href=\"/news/'"$GROUP/$i"'\">"
			print subject
			print "</a>"
			if( "'"$DESCR"'"  == "YES" ){
				print "</b>"
				print descr
			}
			print "</font></td>"

			print "<td ALIGN=LEFT VALIGN=TOP WIDTH=\"25%\" NOSAVE>"
			print "<font face="Arial, Helvetica, sans-serif" size=\"-2\">"
			print from
			print "</font></td>"

			print "<td ALIGN=LEFT VALIGN=TOP WIDTH=\"10%\" NOSAVE>"
			print "<font face="Arial, Helvetica, sans-serif" size=\"-2\">"
			if( "'"$DESCR"'"  == "YES" )
				print "'"$dt"'"
			else
				print "'"$dts"'"
			print "</font></td>"

			print "</font>"
			print "</tr>"
		}'
	done
	echo "</table>"
done


# Print footer

cat <<END
</body>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
</HTML>
END
