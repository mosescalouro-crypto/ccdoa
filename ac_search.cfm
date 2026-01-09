<cfset returnArray = ArrayNew(1) />
 
<cfquery dataSource="CCDOA" name="result">
    SELECT TOP 34 id, 
        make, 
        model,
        sqft,
        CASE 
          WHEN sqft < 1250 THEN '1S'
          WHEN sqft BETWEEN 1250 AND 1999 THEN '1M'
          WHEN sqft BETWEEN 2000 AND 3499 THEN '2'
          ELSE '3'
        END as parking
    FROM aircraft 
    WHERE make like '%#URL.term#%'
        OR model like '%#URL.term#%'
    ORDER BY make,model
</cfquery>

<cfloop query="result">
    <cfset resultArray = StructNew() />
    <cfset resultArray["make"] = make />
    <cfset resultArray["model"] = model />
    <cfset resultArray["parking"] = parking />
    <cfset resultArray["id"] = id />
    <cfset resultArray["sqft"] = sqft />
    <cfset ArrayAppend(returnArray,resultArray) />
</cfloop>

<cfoutput>
#serializeJSON(returnArray)#
</cfoutput>
