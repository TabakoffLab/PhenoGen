<%--
*  Author: Cheryl Hornbaker
*  Created: Dec, 2010
*  Description:  This file establishes the session variables that are common to login_vars.jsp
*    and session_vars.jsp
*
*  Todo:
*  Modification Log:
*
--%>
<%

	//use to enable and disable loggin in.  All pages requiring a log in even anonymous login are disabled when false.
	boolean loginEnabled=true;



	String formName = "";
	String actionForm = "";

	User userLoggedIn = (User) session.getAttribute("userLoggedIn");

	boolean loggedIn = ((String) session.getAttribute("userID") != null ? true: false);

        log.debug("in common_vars " + 
			//" host = " + (String) session.getAttribute("host") + 
			//", caller = " + caller +
                        //", RemoteAddr = "+request.getRemoteAddr() +
                        ", RemoteHost = "+request.getRemoteHost() + 
			", userLoggedIn = " + (userLoggedIn == null ? "is null" : userLoggedIn.getUser_name()));

	// Used for select boxes and radio buttons
	Iterator optionItr = null;
	LinkedHashMap optionHash = null;
	LinkedHashMap optGroupHash = null;
        int optionCount=0;
        boolean firstOptGroup = true;
	String selectName = "";
	String radioName = "";
	String onChange = "";
	String tabindex = "";
	String onClick = "";
	String selectedOption = "";
	String style = "";
        TableHandler th = new TableHandler();
	LinkedHashSet columnSet = new LinkedHashSet();
	String sortOrder = "";
	String sortColumn = "";
	String sortPic = "";

	// Used to store the values input or selected by the user
	List<String> fieldNames = new ArrayList<String>();
	List<String> multipleFieldNames = new ArrayList<String>();
	Hashtable<String, String> fieldValues = new Hashtable<String, String>();
	HashMap<String, String[]> multipleFieldValues = new HashMap<String, String[]>();

	// Used to load specific css and javascript files 
	ArrayList extrasList = new ArrayList();
	request.setAttribute("extrasList",extrasList);
	ArrayList optionsList = new ArrayList();
	request.setAttribute("optionsList",optionsList);
	ArrayList optionsListModal = new ArrayList();
	request.setAttribute("optionsListModal",optionsListModal);
	boolean alertMsgExists = (session.getAttribute("errorMsg") != null || session.getAttribute("successMsg") != null);
	String alertMsg = "";

	String twoSpaces = "&nbsp;&nbsp;";
	String fiveSpaces = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
	String tenSpaces = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"; 
	String twentySpaces = tenSpaces + tenSpaces; 
	String twentyFiveSpaces = twentySpaces + fiveSpaces; 

        String chosenOption = request.getAttribute( "chosenOption" ) == null ? "" : (String) request.getAttribute( "chosenOption" );

	Dataset selectedDataset = ((Dataset) session.getAttribute("selectedDataset") == null ? 
				new Dataset(-99) :
				(Dataset) session.getAttribute("selectedDataset"));
	Dataset.DatasetVersion selectedDatasetVersion = 
		((Dataset.DatasetVersion) session.getAttribute("selectedDatasetVersion") == null ? 
			new Dataset(-99).new DatasetVersion(-99) :
			(Dataset.DatasetVersion) session.getAttribute("selectedDatasetVersion"));

	Experiment selectedExperiment = ((Experiment) session.getAttribute("selectedExperiment") == null ? 
				new Experiment(-99) :
				(Experiment) session.getAttribute("selectedExperiment"));

	GeneList selectedGeneList = ((GeneList) session.getAttribute("selectedGeneList") == null ? 
			new GeneList(-99) :
			(GeneList) session.getAttribute("selectedGeneList"));

        Toolbar.Option[] optionChoices = new Toolbar.Option[]{};
	
	Connection dbConn=null;
	DataSource pool=null;
	
%>
