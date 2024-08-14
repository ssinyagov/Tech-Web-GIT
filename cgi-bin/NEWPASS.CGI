#! /bin/sh
WEBHOME=/export/web/webserver/apache/share

# Print html header

echo "Content-type: text/html

		
<TITLE> SUNSA Create Password Utility  </TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY bgcolor="white">
<br>
<center>
<font size=+2 ><b>
"
$WEBHOME/cgi-bin/newpass.exe 
cat <<END
</b>
</font>
<br>
</center>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
END


# Print footer

echo "</body></HTML>"
