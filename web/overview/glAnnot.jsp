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
                	<H2>Annotations</H2>
                    <div id="accordion" style="height:100%;">
                    	<H3>Feature List</H3>
                        <div>
                        	However your gene list was created, we link supported identifiers to other related identifiers and provide links to other sites with futher information about each gene.
                            <BR /><BR />
                            The annotation page will link to the following sources for short lists(< ___) for larger lists you can export associated IDs.
                            <BR /><BR />
                           	Links:
                            <ul>
                            	<li>NCBI</li>
                                <li>Ensembl</li>
                                <li>RGD</li>
                                <li>MGI</li>
                                <li>Jackson Laboratories</li>
                                <li>UCSC Genome Browser</li>
                                <li>Allen Brain Atlas</li>
                            </ul>
                        </div>
                        <h3>Sample Screen Shots</h3>
                        <div style="text-align:center">
                        	Annotation Table for a rat gene list
                        	<img src="web/overview/glAnnot_rat.jpg"  style="width:100%;"/>
                            Annotation Table for a mouse gene list
                        	<img src="web/overview/glAnnot_mouse.jpg"  style="width:100%;"/>
                            Annotation options for a longer gene list
                        	<img src="web/overview/glAnnot_list.jpg"  style="width:100%;"/>
                        </div>
                    </div>
    </div> <!-- // end overview-wrap -->
    
    <script type="text/javascript">
		$('#accordion').accordion({ heightStyle: "fill" });
	</script>

    