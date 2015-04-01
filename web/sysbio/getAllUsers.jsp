


<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  This file takes the input from an ajax request and returns a json object with genes.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ page language="java"
import="org.json.*" %>

<%@ include file="/web/common/session_vars.jsp"  %>

<jsp:useBean id="sfiles" class="edu.ucdenver.ccp.PhenoGen.data.internal.SharedFiles" scope="session"> </jsp:useBean>

<%
 User[] list=new User[0];
Connection conn=null;
try{
    conn=pool.getConnection();
    list=(new User()).getAllUsers(conn);
    conn.close();
    conn=null;
}catch(SQLException e){

}finally{
    try{
        if(conn!=null&&!conn.isClosed()){
            conn.close();
            conn=null;
        }
    }catch(SQLException er){

    }
}
boolean first=true;
response.setContentType("application/json");
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setDateHeader("Expires", 0);
%>
[
	<%
        for(int j=0;j<list.length;j++){
            if(!(list[j].getUser_name().equals("public")||list[j].getUser_name().equals("anon"))){%>
                <%if(!first){%>,<%}%>
                {
                    "ID":"<%=list[j].getUser_id()%>",
                    "First":"<%=list[j].getFirst_name()%>",
                    "Last":"<%=list[j].getLast_name()%>",
                    "Institution":"<%=list[j].getInstitution()%>"
                }
            <%first=false;
            }%>
        <%}%> 
]



