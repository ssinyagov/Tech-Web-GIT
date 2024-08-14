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

