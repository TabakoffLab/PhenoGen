<%@ include file="/web/access/include/login_vars.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

                	<H2>Microarray Data</H2>
                    <div id="accordion" style="height:100%;">
                    	<H3>Description</H3>
                        <div>
                        	Mice and Rat arrays are available from multiple tissue on a variety of platforms.  In addition to data generated in this lab, other investigators have made their data publicly available.  If you would like to browse that data simply select Microarray Analysis Tools -> Create a dataset from public and private data(or <a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=accessDir%>checkLogin.jsp?url=<%=datasetsDir%>basicQuery.jsp">click here</a>).  This will allow you to browse the data available.  If the data has not been made public you may request access to it through the site.
                            <BR /><BR />
                            See <a href="<%=commonDir%>selectMenu.jsp?menuURL=<%=contextRoot%>CurrentDataSets.jsp">Current Datasets</a> for a full list of  precompiled microarray data.
                        </div>
                        <H3>Files Available</H3>
                        <div>
                        	<ul>
                            	<li>Raw Expression Values(.cel,.txt depending on array type)</li>
                                <li>Normalized Expression Values(.csv or .txt)</li>
                                <li>eQTLs(.csv or .txt)</li>
                                <li>Heritability(.txt)</li>
                            </ul>
                        </div>
                    </div>
    
    <script src="javascript/indexGraphAccordion.js">
						</script>						

    