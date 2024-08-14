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


# Get serach parameters

[ "${QUERY_STRING:-NO}" != NO ]&&{
	ARGV=`	echo "$QUERY_STRING"|\
		sed '
			s/Node=//
			s/++*/ /g
			s/%2C/ /g
			s/  */ /g
			/^  *$/d
		'`
	set -- "$ARGV"
}

# Print html header

echo "Content-type: text/html

		
<TITLE> SUNSA Supported NT Node Information Service </TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY>
<BODY bgcolor="white">
"
[ "$*" !=  ""   ]&&{
	cd $WEBHOME/htdocs/site/nt
	for db in *.db
	do
		$PR_DB $db $* <$db
	done
}
cat <<END
<br>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
END


# Print footer

echo "</body></HTML>"
