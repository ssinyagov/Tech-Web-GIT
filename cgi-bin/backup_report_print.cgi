#! /bin/sh

sh_commands(){
	NAWK=/bin/nawk
	CAT=/bin/cat
	GREP=/bin/grep
	CUT=/bin/cut
	SED=/bin/sed
	SORT=/bin/sort
	UNIQ=/bin/uniq
	TEE=/bin/tee
	CD=cd
}

sh_commands

WEBHOME=`$GREP "^webadmin:" /etc/passwd|$CUT -f 6 -d":"`
PR_DB=$WEBHOME/bin/pr_db


# Print html header

echo "Content-type: text/html

		
<TITLE> SUNSA Supported  Backup Information Service </TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY>
<BODY bgcolor="white">
<br><br>
<center>
<b>
<font size=+2 color="#000066">
Netbackup reports
</font>
<b><br><br> 
</center>
"

REPORT_HOME=subsystem/netbackup/report
cd $WEBHOME/htdocs/$REPORT_HOME

ls -l *.html|
sed 's/\.html//'|
sort -k 6Mr -k 7nr -k 10r|{
echo "Date	HTML	TEXT"
awk '{ 
	printf "%s %s\t",$6,$7 
	printf "<a href=\"/%s/%s.html\">%s,html</a>\t","'"$REPORT_HOME"'",$9,$9
	printf "<a href=\"/%s/%s.txt\">%s,txt</a>\n","'"$REPORT_HOME"'",$9,$9
}'
}|
$PR_DB 

cat <<END
<br>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
END


# Print footer

echo "</body></HTML>"
