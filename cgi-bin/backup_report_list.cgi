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

		
<TITLE> SUNSA Supported SUN Node Information Service </TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY>
<BODY bgcolor="white">
"

[ "$*" !=  ""   ]&&{
	cd $WEBHOME/htdocs/subsystem/netbackup/report
	dblist=`ls -l *.db|sort  -k 6Mr -k 7nr -k 10r|awk '{ print $9 }'`
	for db in `echo "$dblist"`
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
