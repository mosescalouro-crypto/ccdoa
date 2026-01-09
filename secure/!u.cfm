
	   123<cfset pass='MotionInfo##'>
	     <cfset hash = "{SHA}" & ToBase64(BinaryDecode(Hash(pass, "SHA1"), "Hex"))>
	
	
	<cfquery datasource='CCDOA' name='update'>
	Update users
	set hash='#hash#' where username='mjc@mgn.com'
	</cfquery>
	
	123213