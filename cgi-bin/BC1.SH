#! /bin/sh

WEBHOME=/export/web/webserver/apache/share
#cd $WEBHOME/htdocs/vendor/veritas/netbackup
cd $WEBHOME/htdocs/subsystem/netbackup/report

# File name

dt="backup_report_"`date +"%d%m%Y_$$"`
sed '
1,/^$/d
s/  */ /g
s/^ *//
s/ *$//
/^$/d
/Default-/d
/^[^0]/d'|sort -k 2,2 -k 3,3 -k 4,4 -k 6,6|
awk '{
        if( $3 ~ /DB/ || $3 ~ /HOT/ || $3 ~ /COLD/ )
                $3=sprintf "Database:%s",$3
        else
                $3=sprintf "Filesystem:%s",$3
        if( $4 ~ /INCR/ )
                $4="INCR"
        else
                $4="FULL"
        print $6,$2,$3,$4
}'|
sed 's/\.[^ ]* / /'|
sort|uniq -f 1|awk '{ print $2,$3,$4,$1 }' |
(
echo "\
CLIENT|\
APPLICATION|\
PLATFORM/SERVER|\
WHAT IS BACKED UP|\
PRODUCT USED|\
FREQUENCY|\
BACK -UP TYPE|\
TIME OF BACK-UP|\
NUMBER OF EXECUTED SUCCESSFUL BACK-UPS|\
RESTORES REQUESTED SUCCESSFUL/UNSUCCESSFUL"
while read ln
do
        set -- $ln
        egrep "^$1	" ../client_list.txt |
        awk -F" " '{
                OFS="|"
                $4="'"$2"'"
                $7="'"$3"'"
                $8="'"$4"'"
                print $0
        }'
done
)|sed '
s/|*$//
s/  */ /g
' 
exit
| 
tee $dt.txt|
sed 's/|/	/g' | tee $dt.db|
(
# Print html header

echo "
		
<TITLE> SUNSA Backup Information Service </TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY bgcolor="white"> <br><br>
<center>
<b>
<font size=+2 color=\"#000066\">
Netbackup report for:  `date`
</font>
<b><br><br>
</center>
"
# Convert report in to .html format

(
	read header 

	# Print header

	echo "<table border width=\"100%\"><b>"
	echo "$header"| sed '
		s/^/<tr bgcolor="#66ffff"><td align="center">/
		s/$/\&nbsp;<\/td><\/tr>/
		s/	/\&nbsp;<\/td><td align="center">/g'
	echo "</b>"

	# Print body

	sed '
		s/^/<tr align="left" valign="top" ><td>/
		s/$/\&nbsp&<\/td><\/tr>/
		s/	/\&nbsp;<\/td><td>/g
	'
	echo "</table>"
)

# Print footer

cat <<END
<br>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
END
echo "</body></HTML>"
) >$dt.html

# Make index table

(
echo "
		
<TITLE> SUNSA NetBackup reports</TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY bgcolor="white">
<br><br>
<center>
<b>
<font size=+2 color=\"#000066\">
Netbackup reports
</font>
<b><br><br> 
</center>
"
echo "<center>"
echo "<table border=1 >"
echo "<tr align=center >"
echo "<td ><b>Date</td>"
echo "<td ><b>HTML</td>"
echo "<td ><b>Text</td></tr>"

ls -l backup_report*.html|sed 's/\.html//'|
awk '{ 
	# Date
	print "<tr>"
	print "<td>"
	print $6,$7,$8
	print "</td>"
	# Html
	print "<td>"
	printf "<a href=\"%s.html\">%s</a>",$9,$9
	print "</td>"
	# Text
	print "<td>"
	printf "<a href=\"%s.txt\">%s.txt</a>",$9,$9
	print "</td>"
	print "</tr>"
}'
echo "</table>"
echo "</center>"
cat <<END
<br><br> 
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
END
# Print footer
echo "</body></HTML>"
) >report_list.html


