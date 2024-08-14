#! /bin/sh
#@(#) node_lookup ver. 1.2 08/17/00 /homes/dd68df9/src/SCCS/s.node_lookup
#@(#) node_lookup It's program for main page generation for production node search
#@(#) node_lookup (c) Sergey Sinyagov, sinyagov@mail.com
#@(#) node_lookup (c) Sergey Sinyagov, (301) 236-8255 ,sergey.a.sinyagov@bellatlantic.com


WEBHOME=/export/web/webserver/apache/share

display_form() {

cat << EOT
Content-type: text/html




<HTML>
`cat $WEBHOME/htdocs/standard/include/eweb_header.html`

<CENTER>
<HEAD>
<TITLE> SUNSA Supported Node Information Service </TITLE>

<SCRIPT LANGUAGE="JavaScript">
	<!-- HIDE THIS from other Browsers
	 
	function No_Node(form) {
		alert("You must specify a node.");
	}
	
	function display_values(form) {
		var node = form.Node.value ;
	
		alert("The node is:" + node + ":") ;
	}
	
	function Verify_Fields(form) {
		var GOOD = true; 
		 
		if  (form.Node.value == "" ) {
		      GOOD = false; 
		      No_Node(form);
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
SUNSA Supported Node Information Service
</font>

<BR>
</H1>
<HR>


<font color="#CC0000">
<b>
Please enter the searching list separated by space.<br>
It could be any alphanumeric words.<br>
</font>
<font color="blue">
NOTE: Nodes will be searching by SSI context.
<br>
Use "ALL" for ful list getting
<br>
</font>
<BR>
<CENTER>
<FORM METHOD="GET" ACTION="node_list.cgi">
<INPUT NAME="Node" SIZE=40>
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


