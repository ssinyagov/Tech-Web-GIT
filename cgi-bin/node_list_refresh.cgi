#! /bin/sh
#@(#) node_list ver. 1.1 08/17/00 /homes/dd68df9/src/SCCS/s.node_list
#@(#) node_list This program look for the production servers and information about them
#@(#) node_list (c) Sergey Sinyagov, sinyagov@mail.com
#@(#) node_list (c) Sergey Sinyagov, (301) 236-8255 ,sergey.a.sinyagov@bellatlantic.com

PROGRAM_NAME=$0
Usage="Usage: $PROGRAM_NAME options" 

export PROGRAM_NAME Usage

# Print error and cleanup temporary files/directories

perror(){
	echo "\n\n$PROGRAM_NAME: ERROR: $* "
	[ "${TEMPORARY:-NO}" != NO ]&& rm -rf $TEMPORARY 2>&1 > /dev/null
	exit 2
}

#Variables and setup parameters

SERVERS="is003233 is050929"
DATAFILE=/BA/usr/lib/uploads/archive/node/C/NODEHIER/nodehier.dat
WEBHOME=/usr/local/web/draft
DATA_CASHE=${WEBHOME}/sm/tool/server_lookup/nodehier.dat

# Get options

TOP=YES
[ "`basename $PROGRAM_NAME" = "node_list_refresh.cgi" ]&&{
	CGI_PROGRAM=YES
	set -- '-r'
}

while getopts tra c
do
	case $c in
	t)	TOP=NO ;;
	r)	REFRESH=YES;;
	a)	ACTUIAL=YES;;
	esac
done
shift `expr $OPTIND - 1`

# Get other arguments (after options)

ARGV="$*"

# Check the number of arguments and CGI  options

# If this program was called from WEB

[ "${QUERY_STRING:-NO}" != NO ]&&{
	ARGV=`	echo "$QUERY_STRING"|\
		sed '
			s/Node=//
			s/++*/ /g
			s/%2C/ /g
			s/  */ /g
		'`
	set -- "$ARGV"
}
[ "${REFRESH:-NO}" = NO ]&&
        [ "$#" -lt  1 ]&&{
                echo "$Usage"
                exit
        }


# Check Cashe existance

[ "${ACTUAL:-NO}" = NO ]&&
	[ ! -f $DATA_CASHE ]&& ACTUAL=YES

# Check servers accessibility 

[ "${REFRESH:-NO}" != NO -o "${ACTUAL:-NO}" != NO ]&&{
	for SERVER in $SERVERS
	do
		access=YES
 		ping $SERVER 2>/dev/null >/dev/null ||access=NO
       		 OS=`rsh $SERVER -l root uname 2>/dev/null` || access=NO
		[ "$access" = "YES" ]&&break
	done

	[ "$access" != "YES" ]&&perror "$SERVERS are unrechable" 
}

# Only refresh cashe

[ "${REFRESH:-NO}" != NO ]&&{
	rsh -l root $SERVER "cat $DATAFILE"  >${DATA_CASHE}.tmp &&
		mv ${DATA_CASHE}.tmp ${DATA_CASHE}
	[ "${CGI_PROGRAM:-NO}" != NO ]&&{
cat <<END


<HTML>
<TITLE> DSO Production Node Information Service </TITLE>  
<CENTER>
`cat $WEBHOME/standard/include/eweb_header.html`
</CENTER>
<BODY>
<center>
<br>
<br>
<br>
<br>
<br>
<font size="+2" color="blue">
CACHE WAS REFRESHED <br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
</font>
</center>
</BODY>
`cat $WEBHOME/standard/include/eweb_footer.html`
</HTML>
END


	}
	exit 0
}

# Specify the HTML header

[ "${QUERY_STRING:-NO}" != NO ]&&{
cat <<END


<HTML>
<TITLE> DSO Production Node Information Service </TITLE>  
<CENTER>
`cat $WEBHOME/standard/include/eweb_header.html`
<BODY>
<br>
<br>
		<table BORDER COLS=4 WIDTH="70%" >
		<tr bgcolor="#CCCCCC"> 
		<td align="center"><b>IP address</td>
		<td align="center"><b>Name</td>
		<td align="center"><b>Location</td>
		<td align="center"><b>Application</td>
		</b>
		</tr>
</table>
END
}

# Get data

if [ "${ACTUAL:-NO}" != NO ] ; then
		rsh -l root $SERVER "cat $DATAFILE" 
else		
	cat $DATA_CASHE
fi |
# Search arguments from $ARGV in the data stream
awk '
	BEGIN {
		n_arg=split("'"$ARGV"'",node_to_find," ")
	}
	$1=="SUBMAP_TITLE" { nodegrp=$NF } 
	$1=="NODE" {
		# $3 - IP ADDRESS
		# $4 - FULL SERVER NAME (WITH DOMAIN)
		for(i=1;i<=n_arg;i++){
			if ( index($4,node_to_find[i]) != 0 || index($3,node_to_find[i]) != 0 ) 
			{
				IP=$3
				FNAME=$4
				FOUND="YES"
				break
			}
		}
	}
	$1=="LABEL" {	
		if( FOUND == "YES" ){
			#$2 - SERVER NAME WITH LOCATION
			if( nodegrp == "" )
				nodegrp="---"
			if ( ( n=split($2,name_addr,"_") ) == 1 )
				name_addr[2]="---"
			print IP,nodegrp,name_addr[1],name_addr[2]
		}
		FOUND="NO"
	}
' |
# Remove ",\t and duplicated space from the stream
sed '
s/"//g
s/	/ /g
s/  */ /g
'|
# Analyze and output
if read ln
then
	(
		echo $ln
		cat
	)
else
	echo "N/A N/A N/A N/A"
fi|
#Sort output by application name
sort +1 |
# Format output
if [ "${QUERY_STRING:-NO}" = NO ]; then 	
       	awk '
	BEGIN { 
		if ( "'$TOP'" != "NO" ){
			a="--------------------------------------------"
			printf "\n%-16.16s %-25.25s %-10.10s %-10.10s\n"\
				,"IP","Hostname","Location","Appl"
			printf "%-16.16s %-25.25s %-10.10s %-10.10s\n"\
			,a,a,a,a
		}
	}
	{ 
		printf "%-16.16s %-25.25s %-10.10s %-10.10s\n"\
		,$1,$3,$4,$2 
	}
	' 
else

cat <<END
<table BORDER COLS=4 WIDTH="70%" > 
END
	awk '{ 
		print "<tr>"
		printf "<td>%s</td>\n",$1
		printf "<td>%s</td>\n",$3
		printf "<td>%s</td>\n",$4
		printf "<td>%s</td>\n",$2
		print "</tr>"
	}'
	echo "</table>"
	echo "<br>"
	echo "<br>"
	echo "<br>"
	echo "</CENTER>"
	echo "</BODY>"
	cat $WEBHOME/standard/include/eweb_footer.html
	echo "</HTML>"
fi


# Cleanup temporary files/directories

[ "${TEMPORARY:-NO}" != NO ]&& rm -rf $TEMPORARY 2>&1 > /dev/null
