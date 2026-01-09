<cfcomponent
    displayname="CCDOA"
    output="true"
    hint="Handle the application.">
 
    <!--- Set up the application. --->
    <cfset THIS.Name = "CCDOA" />
    <cfset THIS.ApplicationTimeout = CreateTimeSpan( 0, 0, 1, 0 ) />
    <cfset THIS.SessionManagement = false />
    <cfset THIS.SetClientCookies = false />

    <!--- Define the page request properties. --->
    <cfsetting
        requesttimeout="20"
        showdebugoutput="false"
        enablecfoutputonly="false"
        />
 
    <cffunction
        name="OnApplicationStart"
        access="public"
        returntype="boolean"
        output="false"
        hint="Fires when the application is first created.">

        <!--- Return out. --->
        <cfreturn true />
    </cffunction>

    <cffunction name="onRequestStart"> 
        <cfscript>
                setLocale("English (US)");
        </cfscript>
    </cffunction>
 
</cfcomponent>