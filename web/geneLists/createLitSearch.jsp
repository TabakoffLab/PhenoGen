<%--
 *  Author: Cheryl Hornbaker
 *  Created: June, 2004
 *  Description:  The web page created by this file allows the user to select values
 *	for searching literature.
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %> 

<jsp:useBean id="myLitSearch" class="edu.ucdenver.ccp.PhenoGen.data.LitSearch"> </jsp:useBean>
<jsp:useBean id="thisIDecoderClient" class="edu.ucdenver.ccp.PhenoGen.tools.idecoder.IDecoderClient"> </jsp:useBean>

<%
	log.debug("caller = " + caller);
	log.info("in createLitSearch.jsp. user = " + user);

        if (userLoggedIn.getUser_name().equals("guest")) {
                //Error - "Feature not allowed for guests"
                session.setAttribute("errorMsg", "GST-004");
                response.sendRedirect(commonDir + "errorMsg.jsp");
        }

	log.debug("action = "+action);
	formName = "createLitSearch.jsp";
	request.setAttribute( "selectedTabId", "literature" );

	Thread thread = null;
        //Set iDecoderResult = null;
	HashMap ids = new HashMap();

        if ((action != null) && action.equals("Submit Literature Search")) {

		LinkedHashMap<String, String[]> categories = new LinkedHashMap<String, String[]>();

		for (int i=0; i<5; i++) {
			if (!((String) request.getParameter("category"+i)).equals("None")) {
				String category = (String) request.getParameter("category"+i);
				log.debug("category = " + category);
				List keywordList = new ArrayList();
				for (int j=0; j<5; j++) {
					if (!((String) request.getParameter("keyword_"+i+"_"+j)).equals("")) {
						String keyword = (String) request.getParameter("keyword_"+i+"_"+j);
						keywordList.add(keyword); 
					}
				}
				String[] keywordArray = (String[]) keywordList.toArray(new String[keywordList.size()]); 
				categories.put(category, keywordArray);
			}
		}

		String description = (String)request.getParameter("description");

		Iterator itr = iDecoderSet.iterator();
                while (itr.hasNext()) {
                	Identifier thisIdentifier = (Identifier) itr.next();
			Set identifierValuesSet = thisIDecoderClient.getValues((Set) thisIdentifier.getRelatedIdentifiers());
			String[] identifierValues = (String[]) identifierValuesSet.toArray(new String[identifierValuesSet.size()]); 
			ids.put(thisIdentifier.getIdentifier(), identifierValues);
		}

		//log.debug("ids = "); myDebugger.print(ids);

		myLitSearch.setIds(ids);
		myLitSearch.setGene_list_id(selectedGeneList.getGene_list_id());
		myLitSearch.setUser_id(userID);
		myLitSearch.setDescription(description);
		myLitSearch.setCategories(categories);

		myLitSearch.createLitSearch(myLitSearch, dbConn);
		myLitSearch.setLitSearchGeneList(selectedGeneList);

		mySessionHandler.createGeneListActivity("Created Literature Search: " + description, pool);

        	thread = new Thread(new AsyncLitSearch(
                	myLitSearch,
                	session));

        	log.debug("Starting first thread "+ thread.getName());

        	thread.start();

		//Success - "Lit search started"
		session.setAttribute("successMsg", "GLT-005");
		response.sendRedirect(commonDir + "successMsg.jsp");
		}
%>
<%@ include file="/web/common/headTags.jsp" %>



	<form   method="post"
        	action="createLitSearch.jsp"
		onSubmit="return IsLitSearchFormComplete(litSearch)"
        	enctype="application/x-www-form-urlencoded"
        	name="litSearch"> 
	<BR>
	
	<div class="title">Fill in the form below to run a new literature search <BR>
	<i>Note: You can group your keywords by 'categories'</i>
	</div>
      	<table name="items" class="list_base" cellpadding="0" cellspacing="3" >
		<tr class="title">
			<th colspan="100%"> Search Criteria
		</tr>
		<tr class="col_title">
			<td> Categories: </td>
			<td> Keywords: </td>			
		</tr>
		<% for (int i=0; i<5; i++) { %>
			<tr>
			<td> 	
			<%
			selectName="category" + i; 
			onChange = "";
			%>
			<%@ include file="/web/geneLists/include/litSearchCategoryOptions.jsp" %>
			<%@ include file="/web/common/selectBox.jsp" %>
			</td>
			<% for (int j=0; j<5; j++) { %>
				<td><input type="text" NAME="keyword_<%=i%>_<%=j%>" size=11 value=""> </td>
			<% } %>
			</tr>
		<% } %>
		<tr><td>&nbsp;</td></tr>
		<tr>
		<td colspan=6> 
			<b>Literature Search Name:<%=twoSpaces%></b> <input type="text" size=50 name="description" value=""> 
		</td>
		</tr>
		<tr><td>&nbsp;</td></tr>
	</table>
	<BR>
	<center>
		<button type="button" onclick="clearAllFields(litSearch)">Clear Fields</button><%=fiveSpaces%>
		<input type="submit" name="action" value="Submit Literature Search">
	</center>
	<input type="hidden" name="geneListID" value="<%=selectedGeneList.getGene_list_id()%>">
	</form>

