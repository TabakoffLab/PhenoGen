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

    
	<div style="width:100%; height:100%;">
                	<H2>Compare/Share</H2>
                    <div id="accordion" style="height:100%;">
                    	<H3>Feature List</H3>
                        <div>
                        	<ul>
                        		<li>Share Lists with any other registered user.</li>
                            	<li>Compare lists with any of your accessible gene lists.</li>
                                <ul>
                            		<li>Look for any of your lists that also contain a given gene</li>
                                	<li>Find the Intersection, Union, Subtract one list from another </li>
                                </ul>
                            </ul>
                        </div>
                        <h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                   			
                        </div>
                    </div>
    </div> <!-- // end overview-wrap -->
    
    <script type="text/javascript">
		$('#accordion').accordion({ heightStyle: "fill" });
	</script>