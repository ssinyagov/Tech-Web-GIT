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

		
<TITLE> SUNSA Supported server DR info</TITLE>
<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<BODY>
<BODY bgcolor="white">
"
[ "$*" !=  ""   ]&&{
	cd $WEBHOME/htdocs/site/info
	list=`find * -prune -type d`
	cmd="$*"

	if [ "$cmd" = "" ]; then
       		 cmd="^"
	else
       		 cmd=`echo "$*"|sed '
       		 s/  */|/g
       		 s/\./\\\./g
       		 '|tr "[a-z]" "[A-Z]"`
	fi

	if [ "$cmd" = "ALL" ]; then
       		 cmd="^"
	fi
	(
	echo "DR Full info	DR info	SSI"
	
	echo "$list"|egrep -i "$cmd" |sed '
		s/.*/&\/full.html"> DR_FULL: & <\/a>	<a href="\/site\/info\/&\/index.html" > DR: & <\/a>	<a href="\/cgi-bin\/node_list.cgi\?Node=&" > SSI: & <\/a>/
		s/^/<a href="\/site\/info\//
	'
	)|$PR_DB "DR description" "all"
}
cat <<END
<br>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
END


# Print footer

echo "</body></HTML>"
