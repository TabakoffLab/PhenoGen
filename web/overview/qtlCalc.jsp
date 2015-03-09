<%@ include file="/web/common/headerOverview.jsp" %>
<%--
 *  Author: Spencer Mahaffey
 *  Created: May, 2013
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

    
	<H2>Calculate bQTLs</H2>
                    <div  style="overflow:auto;height:92%;">
                    	<H3>Demo/Screen Shots</H3>
                        <div style="overflow:auto;display:inline-block;height:33%;width:100%;">
                        	<table>
                            <TR>
                            <TD>
                             <span class="tooltip"  title="First step of calculating bQTLs.  Select the RI panel to use.  If phenotype data is already entered, select it.  If no data is available click Create New Phenotype.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlCalc_step1.jpg" title="First step of calculating bQTLs.  Select the RI panel to use.  If phenotype data is already entered, select it.  If no data is available click Create New Phenotype.">
                                <img src="web/overview/qtlCalc_step1_200.jpg" /></a></span>
                            </TD>
                            <TD>
                        	 <span class="tooltip"  title="Example entering phenotype data for ILSXISS RI Panel.<BR>Click to view a larger image.">
                            <a class="fancybox" rel="fancybox-thumb" href="web/overview/qtlCalc_enterPhen.jpg" title="Example entering phenotype data for ILSXISS RI Panel.">
                                <img src="web/overview/qtlCalc_enterPhen_200.jpg"/></a></span>
                            </TD>
                            </TR>
                            </table>
                            </div>
                    	<H3>Feature List</H3>
                        <div>
                        <ul>
                        	<li>Calculate bQTLs by uploading phenotype data for any number of strains in the RI Panels.</li><BR />
  							Supported RI Panels:
                            	<ul>
                                	<li>Rats</li>
                                    <ul>
                                    	<li>HXB/BXH</li>
                                    </ul>
                                    <li>Mice</li>
                                    <ul>
                                    	<li>BXD</li>
                                        <li>ILSXISS</li>
                                    </ul>
                                </ul>
                            
                        </ul>
                        </div>
                    	<BR /><BR />
                        <div style="text-align:center;width:100%;">
                        	<a href="<%=accessDir%>checkLogin.jsp?url=<%=qtlsDir%>calculateQTLs.jsp" class="button" style="width:170px;color:#666666;">Login to Calculate QTLs</a>
                            <BR />or<BR />
                            <a href="<%=accessDir%>registration.jsp" class="button" style="width:140px;color:#666666;">Register Here</a>
                        </div>
                        
                   </div>

<%@ include file="/web/overview/ovrvw_js.jsp" %>
    