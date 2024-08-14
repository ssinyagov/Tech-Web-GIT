#! /bin/sh

WEBHOME=/web/apache/htdocs

display_form() {

cat << EOT




<HTML>
<CENTER>
`cat $WEBHOME/standard/include/eweb_header.html`
<HEAD>
<TITLE> System Administration Personal Contact services</TITLE>

<SCRIPT LANGUAGE="JavaScript">
	<!-- HIDE THIS from other Browsers
	 
	function No_Serach(form) {
		alert("You must specify what to search");
	}
	
	function display_values(form) {
		var search = form.Search.value ;
	
		alert("The search is:" + search + ":") ;
	}
	
	function Verify_Fields(form) {
		var GOOD = true; 
		 
		if  (form.Search.value == "" ) {
		      GOOD = false; 
		      No_Search(form);
		} 
		
		if ( GOOD == true) {
		    form.submit(form) ;
		}
		
	
	}
	
	function My_Clear(form) {
	   form.reset(form) ;
	   form.Search.value = ""; 
	}

	function Refresh_Cashe(form) {
		form.submit(form);
	}
	
	// STOP HIDING from other browsers  -->
</SCRIPT>
 


</HEAD>

<BODY bgcolor="white">
<CENTER>
<H1>
<font color="#CC0000">
System Administration Personal Contact services
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
NOTE: Contact will be searching by any fields
Output will be sorted by names.<br>
</font>
<BR>
<CENTER>
<FORM METHOD="GET" ACTION="contact_search.cgi">
<INPUT NAME="Search" SIZE=40>
<br>
<INPUT TYPE="button" VALUE="Get Info" onClick="Verify_Fields(this.form);">
<INPUT TYPE="button" VALUE="Clear Form" onClick="My_Clear(this.form);" >
</FORM>
<FORM ACTION="node_list_refresh.cgi">
<INPUT TYPE="button" VALUE="Refresh Cache" onClick="Refresh_Cashe(this.form);" >
</FORM>
</CENTER>

<BR>
`cat $WEBHOME/standard/include/eweb_footer.html`
EOT




} # display_form



################### Main ################

display_form


