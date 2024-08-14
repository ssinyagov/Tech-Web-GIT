#! /bin/sh
#@(#) node_lookup ver. 1.2 08/17/00 /homes/dd68df9/src/SCCS/s.node_lookup
#@(#) node_lookup It's program for main page generation for production node search
#@(#) node_lookup (c) Sergey Sinyagov, sinyagov@mail.com
#@(#) node_lookup (c) Sergey Sinyagov, (301) 236-8255 ,sergey.a.sinyagov@bellatlantic.com


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
NEWS_DIR=$WEBHOME/htdocs/news

export WEBHOME NEWS_DIR
PR_DB=$WEBHOME/bin/pr_db




display_form() {

cat << EOT
Content-type: text/html




<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`
<CENTER>
<HEAD>
<TITLE>SUNSA Supported News Service </TITLE>

<SCRIPT LANGUAGE="JavaScript">
	<!-- HIDE THIS from other Browsers
	 
	function No_Group(form) {
		alert("You must specify a group(s).");
	}

	
	function display_values(form) {
		var node = form.Node.value ;
	
		alert("The node is:" + node + ":") ;
	}
	
	function Verify_Fields(form) {
		var GOOD = true; 
		 
		if  (form.Group.value == "" ) {
		      GOOD = false; 
		      No_Group(form);
		} 
		
		if ( GOOD == true) {
		    form.submit(form) ;
		}
		
	
	}
	
	function My_Clear(form) {
	   form.reset(form) ;
	   form.Node.value = ""; 
	}

	
	// STOP HIDING from other browsers  -->
</SCRIPT>
 


</HEAD>

<BODY bgcolor="white">
<CENTER>
<H1>
<font color="blue">
SUNSA Supported News Service
</font>

<BR>
</H1>
<HR>


<font>
<b>
Please enter the searching list separated by space.<br>
It could be any alphanumeric words.<br>
</font>
<BR>
<CENTER>
`echo "$group_list <br>"`
<FORM METHOD="GET" ACTION="news_to_web_exec.cgi">
<table>
<tr>
<td>
<b><font color="blue"> Group:</font></b>
</td>
<td>
<INPUT NAME="Group" SIZE=40><br>
</td>
</tr>
<tr>
<td>
</td>
<td>
<SELECT NAME="Group" SIZE=6 MULTIPLE>
`cd $NEWS_DIR
find . -type d -print|
sed '
s/\.\///g
s/\.//g
s/\//\./g
s/ /\
/g
/^$/d'|
sort|
sed 's/^/<OPTION>/'`
</SELECT>
</td>
</tr>
<tr>
<td>
<b><font color="blue">Serach for string:</font></b>
</td>
<td>
<INPUT NAME="Node" SIZE=40>
</td>
</tr>
<tr>
<td>
<b><font color="blue">Search for days:</font></b>
</td>
<td>
<INPUT NAME="Days" SIZE=2 value=2><br>
</td>
</tr>
</table>
<br>
<INPUT TYPE="button" VALUE="Get Info" onClick="Verify_Fields(this.form);">
<INPUT TYPE="button" VALUE="Clear Form" onClick="My_Clear(this.form);" >
</FORM>
</CENTER>

<BR>
`cat $WEBHOME/htdocs/standard/include/eweb_footer.html`
EOT




} # display_form



################### Main ################

display_form


