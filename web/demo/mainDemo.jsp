<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% extrasList.add("index.css"); %>
<%pageTitle="Overview Downloads";%>

<%@ include file="/web/common/header_noMenu.jsp" %>

        <div id="welcome" style="height:575px; width:980px; overflow:auto;">

	<h2>Demos</h2>
    
    
					<video width="640" height="480" controls="controls">
                    	<source src="test.webm" type="video/webm">
  						<source src="test.mp4" type="video/mp4">
                          <object data="test.mp4" width="320" height="240">
                          </object>
                        </video> 

                
                </div> <!-- // end welcome -->
	
<%@ include file="/web/common/footer.jsp" %>
