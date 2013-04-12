<%--
 *  Author: Cheryl Hornbaker
 *  Created: Mar, 2009
 *  Description:  The web page created by this file displays all of the datasets
 *		available to the user 
 *  Todo: 
 *  Modification Log:
 *      
--%>

<% 
	//Re-set this to reflect asynchronous process finishing
	session.setAttribute("privateDatasetsForUser", null);
	//Re-set to reflect analysis being performed on a dataset
	session.setAttribute("publicDatasets", null);
 %>

<%@ include file="/web/datasets/include/datasetHeader.jsp"  %>

<%
	extrasList.add("listDatasets.js");
	extrasList.add("downloadDataset.js");
	optionsList.add("selectArrays");
	optionsList.add("upload");
	session.setAttribute("dummyDataset", null);
	session.setAttribute("selectedDataset", null);
	session.setAttribute("selectedDatasetVersion", null);

	log.debug("action = "+action); 

        mySessionHandler.createSessionActivity(session.getId(), "Viewed all datasets", dbConn);
%>
<%pageTitle="Analyze Dataset";%>
	<%@ include file="/web/common/microarrayHeader.jsp" %>


    <div class="page-intro">
	<p>Click on a dataset to select it for analysis.</p>
    </div> <!-- // end page-intro -->

    <form name="tableList" action="chooseDataset.jsp" method="get">
	<div class="brClear"> </div>
	<% String datasetClass = "public"; %>
	<%@ include file="/web/datasets/include/datasetTitle.jsp"%>
		<%
		for (Dataset dataset : publicDatasets) {
			%><%@ include file="/web/datasets/include/datasetContents.jsp"%><%
		}
		%>
		</tbody>
	</table>
	<div class="brClear"> </div>
	<% datasetClass = "private"; %>

	<%@ include file="/web/datasets/include/datasetTitle.jsp"%>
<%
	if (privateDatasetsForUser != null && privateDatasetsForUser.length > 0) {
                for (Dataset dataset : privateDatasetsForUser) {
			%><%@ include file="/web/datasets/include/datasetContents.jsp"%><%
		}
	} else { %>
		<tr id="-99"><td colspan="100%" align="center"><h2>No private datasets have been created.  Click 'Create New Dataset' in the Options menu to create a new dataset.</h2></td></tr> <% 
	}
%>
		</tbody>
	</table>
	<BR>

	<input type="hidden" name="datasetID" value=""/>
	<input type="hidden" name="action" value="">
   </form>

  <div class="createNewDataset"></div>
  <div class="itemDetails"></div>
  <div class="deleteItem"></div>
  <div class="downloadItem"></div>

  <script type="text/javascript">
    $(document).ready(function() {
        setupPage();
	setTimeout("setupMain()", 100); 
    });
  </script>

<%@ include file="/web/common/footer.jsp"%>
