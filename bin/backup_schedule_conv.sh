#! /bin/sh

NAWK=/bin/nawk
CAT=/bin/cat
GREP=/bin/grep
CUT=/bin/cut
CD=cd

WEBHOME=`$GREP "^webadmin:" /etc/passwd|$CUT -f 6 -d":"`
BACKUP_HOME=$WEBHOME/htdocs/subsystem/netbackup/schedule


$NAWK '
	BEGIN{ OFS="	" }
	body != 1 && $1 != "" && $0 ~ /^[Mm]essage-[Ii]d:/{
		split($0,a,"[@>]")
		ofile=a[2]
		print ofile 
	}
	$1 == "" { body=1}
	body == 1 && $1 != "" { 
		print
	}
'|{
	read ofile
	$CAT >${BACKUP_HOME}/${ofile}.db
}
