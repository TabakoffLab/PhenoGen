package edu.ucdenver.ccp.PhenoGen.util;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.Experiment;
import edu.ucdenver.ccp.PhenoGen.data.GeneList;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.ObjectHandler;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling the options available on toolbars
 *  @author  Cheryl Hornbaker
 */

public class Toolbar {

	private Logger log=null;

	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();
	public Option[] options = null;
	private String experimentsDir;
	private String qtlsDir;
	private String exonDir;
	private String geneListsDir;
	private String sysBioDir;
	private String datasetsDir;
        private String accessDir;
        private Dataset selectedDataset = null;
        private Dataset.DatasetVersion selectedDatasetVersion = null;
        private Experiment selectedExperiment = null;
        private GeneList selectedGeneList = null;
	private HttpSession session ;

	public Toolbar() {
		log = Logger.getRootLogger();
	}

	
        public Toolbar(HttpSession session) {
                log = Logger.getRootLogger();
		setSession(session); 
		//log.debug("instantiated Toolbar setting session variable");
	}

	public HttpSession getSession() {
		log.debug("in getSession");
		return session;
	}

	public void setSession(HttpSession inSession) {
		//log.debug("in Toolbar.setSession");
		this.session = inSession;
	        this.experimentsDir = (String) session.getAttribute("experimentsDir");
	        this.qtlsDir = (String) session.getAttribute("qtlsDir");
			this.exonDir = (String) session.getAttribute("exonDir");
	        this.geneListsDir = (String) session.getAttribute("geneListsDir");
	        this.sysBioDir = (String) session.getAttribute("sysBioDir");
	        this.datasetsDir = (String) session.getAttribute("datasetsDir");
                this.accessDir = (String) session.getAttribute("accessDir");
                this.selectedDataset = ((Dataset) session.getAttribute("selectedDataset") == null ?
                                new Dataset(-99) :
                                (Dataset) session.getAttribute("selectedDataset"));
                this.selectedDatasetVersion = ((Dataset.DatasetVersion) session.getAttribute("selectedDatasetVersion") == null ?
                                new Dataset(-99).new DatasetVersion(-99) :
                                (Dataset.DatasetVersion) session.getAttribute("selectedDatasetVersion"));

                this.selectedExperiment = ((Experiment) session.getAttribute("selectedExperiment") == null ?
                                new Experiment(-99) :
                                (Experiment) session.getAttribute("selectedExperiment"));

                this.selectedGeneList = ((GeneList) session.getAttribute("selectedGeneList") == null ?
                        new GeneList(-99) :
                        (GeneList) session.getAttribute("selectedGeneList"));

		/*
                log.debug("here selectedDataset = " + selectedDataset.getDataset_id());
                log.debug("here selectedExperiment = " + selectedExperiment.getExp_id());
                log.debug("here selectedDatasetVersion = " + selectedDatasetVersion.getVersion());
                log.debug("here selectedGeneList = " + selectedGeneList.getGene_list_id());
		*/
	}

        public void setOptions(Option[] inOptions) {
                this.options = inOptions;
        }

        public Option[] getOptions() {
                return this.options;
        }

	/**
	 * Gets all the options 
	 * @return	an array of Option objects
	 */
	public Option[] getAllOptions() {

		//log.debug("In getAllOptions");
		
		return new Option().getOptions();

	}

	/**
	 * Gets all the steps for creating an experiment
	 * @return	an array of Option objects
	 */
	public Option[] getStepsForCreateExperiment() {
		List<Option> optionList = new ArrayList<Option>();
        	optionList.add(new Option(experimentsDir + "createExperiment.jsp?expID=" + selectedExperiment.getExp_id(), "createNew.png", "Define New Experiment"));
        	optionList.add(new Option(experimentsDir + "chooseProtocols.jsp?experimentID=" + selectedExperiment.getExp_id(), "selector.png", "Select Protocols"));
        	optionList.add(new Option(experimentsDir + "downloadSpreadsheet.jsp?experimentID=" + selectedExperiment.getExp_id(), "downArrow.png", "Download Empty Spreadsheet"));
        	optionList.add(new Option(experimentsDir + "uploadSpreadsheet.jsp?experimentID=" + selectedExperiment.getExp_id(), "upArrow.png", "Upload Completed Spreadsheet"));
        	optionList.add(new Option(experimentsDir + "uploadCELFiles.jsp?experimentID=" + selectedExperiment.getExp_id(), "upArrow.png", "Upload CEL Files"));
        	optionList.add(new Option(experimentsDir + "reviewExperiment.jsp?experimentID=" + selectedExperiment.getExp_id(), "magnifierPlusPaper.png", "Review Experiment"));
        	optionList.add(new Option("", "closedLock.png", "Finalize Submission"));

		Option[] optionArray = myObjectHandler.getAsArray(optionList, Option.class);
		return optionArray;
	}

	/**
	 * Gets all the steps for creating a dataset
	 * @return	an array of Option objects
	 */
	public Option[] getStepsForCreateDataset() {
		List<Option> optionList = new ArrayList<Option>();
        	optionList.add(new Option(datasetsDir + "basicQuery.jsp", "search.png", "Retrieve Arrays"));
        	optionList.add(new Option(datasetsDir + "selectArrays.jsp", "shoppingCart.png", "Select Arrays"));
        	optionList.add(new Option(datasetsDir + "finalizeDataset.jsp", "closedLock.png", "Finalize Dataset"));
        	optionList.add(new Option(datasetsDir + "", "star.png", "Run Quality Control Checks"));

		Option[] optionArray = myObjectHandler.getAsArray(optionList, Option.class);
		return optionArray;
	}

	/**
	 * Gets all the steps for running quality control checks
	 * @return	an array of Option objects
	 */
	public Option[] getStepsForRunningQC() {
		List<Option> optionList = new ArrayList<Option>();
        	optionList.add(new Option(datasetsDir + "listDatasets.jsp", "chooseNew.png", "Choose Dataset"));
        	optionList.add(new Option(datasetsDir + "qualityControl.jsp", "star.png", "Run Quality Control"));
        	optionList.add(new Option(datasetsDir + "qualityControlResults.jsp", "ribbon.png", "Review & Approve Quality Control Results"));

		Option[] optionArray = myObjectHandler.getAsArray(optionList, Option.class);
		return optionArray;
	}

	/**
	 * Gets all the steps for preparing a dataset for analysis
	 * @return	an array of Option objects
	 */
	public Option[] getStepsForPrepDataset() {
		List<Option> optionList = new ArrayList<Option>();
        	optionList.add(new Option(datasetsDir + "listDatasets.jsp", "chooseNew.png", "Choose Dataset"));
        	optionList.add(new Option(datasetsDir + "groupArrays.jsp", "groupArrays.png", "Group Arrays"));
        	optionList.add(new Option(datasetsDir + "normalize.jsp", "normalize.png", "Normalize Grouped Arrays"));
        	optionList.add(new Option(datasetsDir + "typeOfAnalysis.jsp", "barGraph.png", "Run Analysis"));

		Option[] optionArray = myObjectHandler.getAsArray(optionList, Option.class);
		return optionArray;
	}

	/**
	 * Gets all the steps for running analysis
	 * @return	an array of Option objects
	 */
	public Option[] getStepsForRunAnalysis() {
		List<Option> optionList = new ArrayList<Option>();
        	optionList.add(new Option(datasetsDir + "listDatasets.jsp", "chooseNew.png", "Choose Dataset"));
        	optionList.add(new Option(datasetsDir + "listDatasetVersions.jsp", "chooseNew.png", "Choose Dataset Version"));
        	optionList.add(new Option(datasetsDir + "typeOfAnalysis.jsp", "barGraph.png", "Choose Type of Analysis"));

		Option[] optionArray = myObjectHandler.getAsArray(optionList, Option.class);
		return optionArray;
	}

	/**
	 * Gets all the steps for running a differential expression analysis
	 * @return	an array of Option objects
	 */
	public Option[] getStepsForDifferentialExpression() {
		List<Option> optionList = new ArrayList<Option>();
        	optionList.add(new Option(datasetsDir + "listDatasets.jsp", "chooseNew.png", "Choose Dataset"));
        	optionList.add(new Option(datasetsDir + "listDatasetVersions.jsp", "chooseNew.png", "Choose Dataset Version"));
        	optionList.add(new Option(datasetsDir + "typeOfAnalysis.jsp", "barGraph.png", "Choose Type of Analysis"));
        	optionList.add(new Option(datasetsDir + "filters.jsp", "funnel.png", "Filter Probe(set)s"));
        	optionList.add(new Option(datasetsDir + "statistics.jsp", "calculator.png", "Run Statistical Test"));
        	optionList.add(new Option(datasetsDir + "multipleTest.jsp", "exclamation.png", "Correct for Multiple Testing"));
        	optionList.add(new Option(datasetsDir + "nameGeneListFromAnalysis.jsp", "disk.png", "Save Gene List"));

		Option[] optionArray = myObjectHandler.getAsArray(optionList, Option.class);
		return optionArray;
	}


	/**
	 * Gets all the steps for running a correlation analysis
	 * @return	an array of Option objects
	 */
	public Option[] getStepsForCorrelation() {
		List<Option> optionList = new ArrayList<Option>();
        	optionList.add(new Option(datasetsDir + "listDatasets.jsp", "chooseNew.png", "Choose Dataset"));
        	optionList.add(new Option(datasetsDir + "listDatasetVersions.jsp", "chooseNew.png", "Choose Dataset Version"));
        	optionList.add(new Option(datasetsDir + "typeOfAnalysis.jsp", "barGraph.png", "Choose Type of Analysis"));
        	optionList.add(new Option(datasetsDir + "correlation.jsp", "chooseNew.png", "Choose Phenotype Data"));
        	optionList.add(new Option(datasetsDir + "filters.jsp", "funnel.png", "Filter Probe(set)s"));
        	optionList.add(new Option(datasetsDir + "statistics.jsp", "calculator.png", "Run Statistical Test"));
        	optionList.add(new Option(datasetsDir + "multipleTest.jsp", "exclamation.png", "Correct for Multiple Testing"));
        	optionList.add(new Option(datasetsDir + "nameGeneListFromAnalysis.jsp", "disk.png", "Save Gene List"));

		Option[] optionArray = myObjectHandler.getAsArray(optionList, Option.class);
		return optionArray;
	}


	/**
	 * Gets all the steps for running a cluster analysis
	 * @return	an array of Option objects
	 */
	public Option[] getStepsForCluster() {
		List<Option> optionList = new ArrayList<Option>();
        	optionList.add(new Option(datasetsDir + "listDatasets.jsp", "chooseNew.png", "Choose Dataset"));
        	optionList.add(new Option(datasetsDir + "listDatasetVersions.jsp", "chooseNew.png", "Choose Dataset Version"));
        	optionList.add(new Option(datasetsDir + "typeOfAnalysis.jsp", "barGraph.png", "Choose Type of Analysis"));
        	optionList.add(new Option(datasetsDir + "filters.jsp", "funnel.png", "Filter Probe(set)s"));
        	optionList.add(new Option(datasetsDir + "cluster.jsp", "calculator.png", "Cluster"));
        	optionList.add(new Option(datasetsDir + "allClusterResults.jsp", "magnifierPlusPaper.png", "Review Cluster Results"));
        	optionList.add(new Option(datasetsDir + "nameGeneListFromAnalysis.jsp", "disk.png", "Save Gene List"));

		Option[] optionArray = myObjectHandler.getAsArray(optionList, Option.class);
		return optionArray;
	}


	/**
	 * Gets all the options for a particular toolbar
	 * @param toolbarName the name of the toolbar
	 * @return	an array of Option objects
	 */
	public Option[] getAllOptionsForToolbar(String toolbarName) {

		log.debug("In getAllOptionsForToolbar. toolbar = " + toolbarName);

		Option[] myOptions = null;

		return myOptions;
	}
	
	/**
	 * Class for handling options related to a particular toolbar.
	 */
	public class Option {
        	private String optionName;
        	private String linkTo;
        	private String icon;
        	private String altText;
        	private Toolbar toolbar;

		public Option() {
			log = Logger.getRootLogger();
		}

		public Option(String optionName) {
			log = Logger.getRootLogger();
			setOptionName(optionName);
		}

		/* This is used for upper right toolbar. */
		public Option(String optionName, String linkTo, String icon, String altText) {
			log = Logger.getRootLogger();
			setOptionName(optionName);
			setLinkTo(linkTo);
			setIcon(icon);
			setAltText(altText);
		}

		/* This is used for steps.  Don't need an optionName */
		public Option(String linkTo, String icon, String altText) {
			log = Logger.getRootLogger();
			setLinkTo(linkTo);
			setIcon(icon);
			setAltText(altText);
		}

        	public void setOptionName(String inString) {
                	this.optionName = inString;
        	}

        	public String getOptionName() {
                	return this.optionName;
        	}

        	public void setLinkTo(String inString) {
                	this.linkTo = inString;
        	}

        	public String getLinkTo() {
                	return this.linkTo;
        	}

        	public void setIcon(String inString) {
                	this.icon = inString;
        	}

        	public String getIcon() {
                	return this.icon;
        	}

        	public void setAltText(String inString) {
                	this.altText = inString;
        	}

        	public String getAltText() {
                	return this.altText;
        	}

        	public void setToolbar(Toolbar inToolbar) {
                	this.toolbar = inToolbar;
        	}

        	public Toolbar getToolbar() {
                	return this.toolbar;
        	}

		public Option[] getOptions() {
			List<Option> optionList = new ArrayList<Option>();
        		// Common to many screens
        		optionList.add(new Option("download", "", "downArrow.png", "Download"));
        		optionList.add(new Option("createNewPhenotype", "", "createNew.png", "Create New Phenotype"));
        		// Experiment screens   
        		optionList.add(new Option("chooseNewExperiment", experimentsDir + "listExperiments", "chooseNew.png", "Choose New Experiment"));
        		optionList.add(new Option("createExperiment", experimentsDir + "createExperiment", "createNew.png", "Create New Experiment"));
        		optionList.add(new Option("upload", experimentsDir + "listExperiments", "upArrow.png", "Upload Arrays"));
        		// Dataset screens                              
        		optionList.add(new Option("analyze", datasetsDir + "listDatasets", "wrench.png", "Analyze Datasets"));
        		optionList.add(new Option("chooseNewDataset", datasetsDir + "listDatasets", "chooseNew.png", "Choose New Dataset"));
        		optionList.add(new Option("chooseNewVersion", datasetsDir + "listDatasetVersions", "chooseNew.png", "Choose New Version"));
        		optionList.add(new Option("selectArrays", datasetsDir + "basicQuery", "createNew.png", "Create Dataset"));
        		optionList.add(new Option("approveQC", "", "ribbon.png", "Approve Quality Control Results"));
        		optionList.add(new Option("chooseNewMethod", datasetsDir + "typeOfAnalysis", "barGraph.png", "Choose Analysis Method"));
        		optionList.add(new Option("createNewNormalization", datasetsDir + "normalize", "createNew.png", "Create New Normalized Version"));
        		optionList.add(new Option("createNewGrouping", datasetsDir + "groupArrays", "createNew.png", "Create New Grouping"));
        		optionList.add(new Option("addToDataset", "", "createNew.png", "Add Selected Arrays To Dataset"));
        		optionList.add(new Option("viewFinalizeDataset", "", "closedLock.png", "View/Finalize Dataset"));
        		// Gene List screens
        		optionList.add(new Option("createGeneList", "", "createNew.png", "Create New Gene List"));
                        optionList.add(new Option("linkEmail", accessDir+"linkEmail", "link.png", "Link Email to Session"));
                        optionList.add(new Option("editEmail", "", "link.png", "Edit Linked Email"));
        		optionList.add(new Option("chooseNewGeneList", geneListsDir + "listGeneLists", "chooseNew.png", "Choose New Gene List"));
        		optionList.add(new Option("moreAnnotation", geneListsDir + "advancedAnnotation", "rightArrow.png", "More Annotation"));
        		optionList.add(new Option("basicAnnotation", geneListsDir + "annotation", "leftArrow.png", "Basic Annotation"));
        		optionList.add(new Option("createNewLitSearch", "", "createNew.png", "Run a New Literature Search"));
        		optionList.add(new Option("createNewOpossum", "", "createNew.png", "Run a New oPOSSUM Analysis"));
        		optionList.add(new Option("createNewMeme", "", "createNew.png", "Run a New MEME Analysis"));
        		optionList.add(new Option("createNewUpstream", "", "createNew.png", "Run a New Upstream Extraction"));
        		optionList.add(new Option("createNewPathway", "", "createNew.png", "Run a New Pathway Analysis"));
        		// QTL screens  
        		optionList.add(new Option("chooseNewPhenotype", qtlsDir + "calculateQTLs", "chooseNew.png", "Choose New Phenotype"));
        		// System Biology screens

			Option[] optionArray = myObjectHandler.getAsArray(optionList, Option.class);
			return optionArray;
		}

		/**
	 	* Returns one Option object from an array of Option objects
	 	* @param myOptions	an array of Option objects 
	 	* @param optionName	the name of the option to return 
	 	* @return            an Option object
	 	*/
		public Option getOptionFromMyOptions(Option[] myOptions, String optionName) {
        		//
        		// Return the Option object that contains the hybrid_id from the myOptions
        		//

        		myOptions = sortOptions(myOptions, "optionName");

        		int idx = Arrays.binarySearch(myOptions, new Option(optionName), new OptionSortComparator());
	
        		Option thisOption = myOptions[idx];

        		return thisOption;
		}

		public boolean equals(Object obj) {
			if (!(obj instanceof Option)) return false;
			return this.optionName.equals(((Option)obj).optionName);
		}
        
		public void print(Option myOption) {
			myOption.print();
		}

		public String toString() {
			return "This Option has optionName = " + optionName +
			", icon = " + icon;
		}

		public void print() {
			log.debug("Option = " + toString());
		}

		public Option[] sortOptions (Option[] myOptions, String sortColumn) {
			setSortColumn(sortColumn);
			Arrays.sort(myOptions, new OptionSortComparator());
			return myOptions;
		}

		private String sortColumn;
		public void setSortColumn(String inString) {
			this.sortColumn = inString;
		}

		public String getSortColumn() {
			return sortColumn;
		}

		public class OptionSortComparator implements Comparator<Option> {
			int compare;
			Option option1, option2;

			public int compare(Option option1, Option option2) 	{ 
				//log.debug("in OptionSortComparator. sortOrder = "+getSortOrder() + ", sortColumn = "+getSortColumn());
				//log.debug("option1 optionName = "+option1.getOptionName()+ ", option2 optionName = "+option2.getOptionName());

                		if (getSortColumn().equals("optionName")) {
                        		compare = option1.getOptionName().compareTo(option2.getOptionName());
				}
                		return compare;
        		}
		}
	}
}
