<cfquery datasource='CCDOA' name="mis_admins">
    SELECT id,username
    FROM users
    where email like '%motioninfo.com'
        OR email like '%mgn.com'
        OR email like '%maritimeinfosystems.com'
</cfquery>

<cfquery datasource="CCDOA" name="userList">
  SELECT * from users
  WHERE 0=0
  --AND id not in (#valueList(mis_admins.id)#)
  order by id desc
</cfquery>

<cfoutput query="userList">
    <tr id="user-#id#"<cfif !len(trim(username))> class="warning"</cfif>>
        <td><cfif len(last_name)>#last_name#, #first_name#</cfif></td>
        <td>#username#</td>
        <td>#email#</td>
        <cfif userList.admin EQ 1> 
    		<td>Yes</td>
        <cfelse>
            <td>No</td>
        </cfif>
        <td>#datetimeformat(lastLogin)#</td>
        <td align=right><a href="##" title="Edit User" data-toggle="modal" data-target="##userModal" data-userID="#id#"><i class="glyphicon glyphicon-cog text-info" aria-hidden="true"></i></a></td>
    </tr>
</cfoutput>