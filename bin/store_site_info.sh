#! /bin/sh

NAWK=/bin/nawk
CAT=/bin/cat
GREP=/bin/grep
CUT=/bin/cut
MKDIR=/bin/mkdir
UUDECODE=/bin/uudecode
UNCOMPRESS=/bin/uncompress
CPIO=/bin/cpio
CD=cd

WEBHOME=`$GREP "^webadmin:" /etc/passwd|$CUT -f 6 -d":"`
INFO_HOME=$WEBHOME/htdocs/site/info


$NAWK '
	BEGIN{ OFS="	" }
	body != 1 && $1 != "" && $0 ~ /^[Ss]ubj[^:]*:/{
		odir=$2
		print  odir
	}
	$1 == "" { body=1}
	body == 1 && $1 != "" { 
		print
	}
'|{
	read odir
	mkdir -p ${INFO_HOME}/$odir >/dev/null 2>&1 
	cd ${INFO_HOME}/$odir &&{
		$CAT | 
		$UUDECODE -p |
		$UNCOMPRESS|
		$CPIO -icdum >/dev/null 2>&1 &&{
			cd ${INFO_HOME}
			mk_site_info.sh $odir
		}
			
	}
}
