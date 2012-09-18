package edu.ucdenver.ccp.PhenoGen.data;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

import java.lang.reflect.Method;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import jxl.Cell;
import jxl.Sheet;
import jxl.Workbook;
import jxl.read.biff.BiffException;
import jxl.read.biff.PasswordException;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;
import jxl.write.WriteException;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;
import edu.ucdenver.ccp.PhenoGen.web.SessionHandler; 

import edu.ucdenver.ccp.util.Debugger;

import edu.ucdenver.ccp.util.FileHandler;
import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to Experiment
 *  @author  Cheryl Hornbaker
 */

public class Experiment {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();
        private PrintWriter writer = null;

	public Experiment() {
		log = Logger.getRootLogger();
	}

	public Experiment(int exp_id) {
		log = Logger.getRootLogger();
		this.setExp_id(exp_id);
	}

	private int exp_id;
	private int subid;
        private String created_by_login;
        private String exp_name;
        private java.sql.Timestamp hold_date;
        private String comp_status;
	private String accno;
	private String exp_description;
  	private String expName;
  	private String expNameNoSpaces;
  	private String platform;
  	private String exp_create_date_as_string;
  	private int num_samples;
  	private int num_files;
  	private int num_arrays;
  	private String proc_status;
  	private String organism;
  	private String array_type;
	private java.sql.Timestamp exp_create_date;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setExp_id(int inInt) {
		this.exp_id = inInt;
	}

	public int getExp_id() {
		return this.exp_id;
	}

	public void setSubid(int inInt) {
		this.subid = inInt;
	}

	public int getSubid() {
		return this.subid;
	}

        public void setCreated_by_login(String inString) {
                this.created_by_login = inString;
        }

        public String getCreated_by_login() {
                return this.created_by_login;
        }

        public void setExp_name(String inString) {
                this.exp_name = inString;
        }

        public String getExp_name() {
                return this.exp_name;
        }

        public void setHold_date(java.sql.Timestamp inTimestamp) {
                this.hold_date = inTimestamp;
        }

        public java.sql.Timestamp getHold_date() {
                return this.hold_date;
        }

        public void setProc_status(String inString) {
                this.proc_status = inString;
        }

        public String getProc_status() {
                return this.proc_status;
        }

        public void setComp_status(String inString) {
                this.comp_status = inString;
        }

        public String getComp_status() {
                return this.comp_status;
        }

	public void setAccno(String inString) {
		this.accno = inString;
	}

	public String getAccno() {
		return this.accno;
	}

	public void setExp_description(String inString) {
		this.exp_description = inString;
	}

	public String getExp_description() {
		return this.exp_description;
	}

  	public void setExpName(String inString) {
    		this.expName = inString;
  	}

  	public String getExpName() {
    		return expName; 
  	}

  	public void setExpNameNoSpaces(String inString) {
    		this.expNameNoSpaces = inString;
  	}

  	public String getExpNameNoSpaces() {
    		return expNameNoSpaces; 
  	}

	public void setExp_create_date(java.sql.Timestamp inTimestamp) {
		this.exp_create_date = inTimestamp;
	}

	public java.sql.Timestamp getExp_create_date() {
		return this.exp_create_date;
	}

  	public void setPlatform(String inString) {
    		this.platform = inString;
  	}

  	public String getPlatform() {
    		return platform;
  	}

  	public void setExp_create_date_as_string(String inString) {
    		this.exp_create_date_as_string = inString;
  	}

  	public String getExp_create_date_as_string() {
    		return exp_create_date_as_string; 
  	}

  	public void setNum_samples(int inInt) {
    		this.num_samples = inInt;
  	}

  	public int getNum_samples() {
    		return num_samples; 
  	}

  	public void setNum_files(int inInt) {
    		this.num_files = inInt;
  	}

  	public int getNum_files() {
    		return num_files; 
  	}

  	public void setNum_arrays(int inInt) {
    		this.num_arrays = inInt;
  	}

  	public int getNum_arrays() {
    		return num_arrays; 
  	}

  	public void setOrganism(String inString) {
    		this.organism = inString;
  	}

  	public String getOrganism() {
    		return organism;
  	}

	/** This is derived by querying the database for the type of arrays used in the dataset. 
	 * @param inString	the type of array used in the dataset
	 */
	public void setArray_type(String inString) {
		this.array_type = inString;
	}

	/** This is derived by querying the database for the type of arrays used in the dataset. 
	 * @return inString	the type of array used in the dataset
	 */
	public String getArray_type() {
		return array_type;
	}

	public void setSortColumn(String inString) {
		this.sortColumn = inString;
	}

	public String getSortColumn() {
		return this.sortColumn;
	}

	public void setSortOrder(String inString) {
		this.sortOrder = inString;
	}

	public String getSortOrder() {
		return this.sortOrder;
	}
	
	private String selectClause = 
			"select "+
			"exp.exp_id, subid, accno, exp_description, "+
			"exp.created_by_login, to_char(exp.exp_create_date, 'mm/dd/yyyy hh12:mi AM'), "+
			"exp.exp_name, "+ 
			"nvl(samples.num_samples, 0) num_samples, "+
			"nvl(files.num_files, 0) num_files, "+
			"exp.proc_status, "+
			"nvl(arrays.num_arrays, 0) num_arrays ";

	private String fromClause = 
			"from experiments exp "+
			"left join "+
				// had to use this nested aggregate function instead of experimentDetails because you can't group by a CLOB 
			"	(select exp_id, "+
			" 	count(file_id) num_files "+
			"	from experimentDetails "+
			"	group by exp_id) files "+
			"	on exp.exp_id = files.exp_id "+
			"left join "+
				// had to use this nested aggregate function instead of experimentDetails because you can't group by a CLOB 
			"	(select exp_id, "+
			" 	count(hybrid_id) num_arrays "+
			"	from experimentDetails "+
			"	group by exp_id) arrays "+
			"	on exp.exp_id = arrays.exp_id "+
			"left join "+
				// had to use this nested aggregate function instead of experimentDetails because you can't group by a CLOB 
				// and experimentDetails assumes all tables are inner joined -- at this point, files may not yet 
				// have been uploaded
			"	(select e.exp_id, "+
			"	count(s.tsample_sysuid) num_samples "+
			"	from experiments e, tsample s "+
			"	where e.exp_id = s.tsample_exprid "+
			"	group by exp_id, tsample_exprid) samples "+
			"	on exp.exp_id = samples.exp_id ";

	private String whereClause = 
			// have no default where clauses, but put this here so all others start with 'and'
                	"where 1=1 ";

	private String orderByClause =
			"order by upper(exp.exp_name)"; 

	/**
	 * Get the protocols that are actually used in an experiment.
	 * @param conn 	the database connection
	 * @return	an array of Protocol objects
	 * @throws SQLException	if an error occurs while accessing the database
	 */

	public Protocol[] getUsedProtocols (Connection conn) throws SQLException{
	
		log.debug("in getUsedProtocols");
		
		String query = 
		"select 0, 0, p.protocol_name, '', '', '', '', vt.value "+ 
		"from experimentdetails, protocols p, valid_terms vt "+ 
		"where exp_id = ? "+
		"and vt.term_id = p.protocol_type "+ 
		"and tsample_protocolid = p.protocol_id "+ 
		"union "+
		"select 0, 0, p.protocol_name, '', '', '', '', vt.value "+ 
		"from experimentdetails, protocols p, valid_terms vt "+ 
		"where exp_id = ? "+
		"and vt.term_id = p.protocol_type "+ 
		"and tsample_growth_protocolid = p.protocol_id "+ 
		"union "+
		"select 0, 0, p.protocol_name, '', '', '', '', vt.value "+ 
		"from experimentdetails, protocols p, valid_terms vt "+ 
		"where exp_id = ? "+
		"and vt.term_id = p.protocol_type "+ 
		"and textract_protocolid = p.protocol_id "+ 
		"union "+
		"select 0, 0, p.protocol_name, '', '', '', '', vt.value "+ 
		"from experimentdetails, protocols p, valid_terms vt "+ 
		"where exp_id = ? "+
		"and vt.term_id = p.protocol_type "+ 
		"and tlabel_protocolid = p.protocol_id "+ 
		"union "+
		"select 0, 0, p.protocol_name, '', '', '', '', vt.value "+ 
		"from experimentdetails, protocols p, valid_terms vt "+ 
		"where exp_id = ? "+
		"and vt.term_id = p.protocol_type "+ 
		"and hybrid_protocol_id = p.protocol_id "+ 
		"union "+
		"select 0, 0, p.protocol_name, '', '', '', '', vt.value "+ 
		"from experimentdetails, protocols p, valid_terms vt "+ 
		"where exp_id = ? "+
		"and vt.term_id = p.protocol_type "+ 
		"and hybrid_scan_protocol_id = p.protocol_id "+ 
		"order by 2";
	
		log.debug("query = "+query);

		Results myResults = new Results(query, new Object[] {this.exp_id, this.exp_id, this.exp_id, this.exp_id, this.exp_id, this.exp_id}, conn);

		log.debug("numRows = "+myResults.getNumRows());
		Protocol[] myProtocols = new Protocol().setupProtocolValues(myResults);

		log.debug("numProtocols = "+myProtocols.length);

		myResults.close();

		return myProtocols;
	}

	/**
	 * Go through the data fields hashtable and validate each field
	 * @param rowNum 	the row being checked
	 * @param thisHash 	a hashtable of data fields
	 * @param className 	the name of the class that contains the validation methods
	 * @param expID 	the identifier of this experiment
	 * @param isCompoundDesign 	true if this experiment is a compound design experiment
	 * @param conn 	the database connection
	 * @return	TRUE if there are no errors, FALSE otherwise
	 */
	private boolean validateData(int rowNum, LinkedHashMap<String, String> thisHash, String className, int expID, boolean isCompoundDesign, Connection conn) {
		log.debug("in validateData for "+className + ".  rowNum = " + rowNum);
		boolean returnVal = true;
		for (Iterator itr=thisHash.keySet().iterator(); itr.hasNext();) {
			String key = (String) itr.next();
			String value = (String) thisHash.get(key);
			log.debug("key is " + key + ", value = " + value);
			try {
				// Using reflection to call appropriate validation method
         			// 1. get a class instance 
         			// 2. get the method (e.g., validateSample_id) with the appropriate parameters
         			// 3. call the method
				Class thisClass = Class.forName(className);
				try {
         				Method thisMethod = thisClass.getDeclaredMethod("validate" + key, new Class[] {String.class, int.class, Connection.class});
         				thisMethod.invoke(thisClass.newInstance(), new Object[] {value, expID, conn});
				} catch (NoSuchMethodException e2) { 
					//log.debug("didn't find 1st class");
					try {
         					Method thisMethod = thisClass.getDeclaredMethod("validate" + key, new Class[] {String.class, Connection.class});
         					thisMethod.invoke(thisClass.newInstance(), new Object[] {value, conn});
					} catch (NoSuchMethodException e3) { 
						//log.debug("didn't find 2nd class");
						try {
         						Method thisMethod = thisClass.getDeclaredMethod("validate" + key, new Class[] {String.class, boolean.class, Connection.class});

         						thisMethod.invoke(thisClass.newInstance(), new Object[] {value, isCompoundDesign, conn});
						} catch (NoSuchMethodException e4) { 
							//log.debug("didn't find 3rd class");
						}
					}
				}
			} catch (Exception e) {
				// don't log the stack trace for exceptions generated by the call  
				if (!e.getClass().getName().equals("java.lang.reflect.InvocationTargetException")) {
					log.debug("error  = ", e);
				}
				//log.debug("before writing line");
				//this.writer.println("Line " + rowNum + ":  " + e.getCause().getMessage());
				if (e.getCause().getMessage() != null) {
					//log.debug("there is a cause and a message.  error  = ", e);
					this.writer.println("Line " + rowNum + ":  " + e.getCause().getMessage());
					if (e.getCause().getMessage().indexOf("ERROR") > -1) {
						returnVal = false;
					}	
				} else {
					//log.debug(" there is only a message, not a cause.  error  = ", e);
					this.writer.println("Line " + rowNum + ":  " + e.getMessage());
					if (e.getMessage().indexOf("ERROR") > -1) {
						returnVal = false;
					}	
				} 
				//log.debug("after writing line");
			}
		} 
		return returnVal;
	}

	public int[] fillInTothers(String value, String type, String user, Connection conn) throws SQLException { 
		log.debug("in fillInTothers. value = " + value + ", and type = " + type);
		int[] answers = new int[2];
		ValidTerm myValidTerm = new ValidTerm();
		if (myObjectHandler.getAsSet(myValidTerm.getFromValidTerm(type, conn), "Value").contains(value)) {
			log.debug("found the value in ValidTerm");
			answers[0] = myValidTerm.getSysuid(value, type, conn);
			answers[1] = -99;
		} else {
			log.debug("did not find the value in ValidTerm, so creating a Tothers record");
			answers[0] = myValidTerm.getSysuid("other", type, conn);
			int tothers_id = -99;
			Tothers tothers = new Tothers();
			tothers.setTothers_id(type);
			tothers.setTothers_value(value);
			tothers.setTothers_descr(value);
			tothers.setTothers_user(user);
			tothers_id = tothers.createTothers(conn);
			answers[1] = tothers_id;
		}
		log.debug("answers = "); myDebugger.print(answers);
		return answers;
	}

	/**
	 * Reads the uploaded spreadsheet
	 * @param spreadsheet 	the spreadsheet
	 * @param userLoggedIn 	the User object of the person logged in
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of String containing the warnings and errors
	 */
	public String[] readSpreadsheet (File spreadsheet, User userLoggedIn, Connection conn) throws SQLException, IOException, BiffException, DataException {

		log.debug("in readSpreadsheet");
		String[] fileContents = null;

		String fileName = spreadsheet.getName();
		String fullFileName = spreadsheet.getPath();
		String expName = fileName.substring(0, fileName.lastIndexOf("."));
                String msgFile = spreadsheet.getParent() + "/" + expName + "_messages.txt";

		log.debug("fileName = "+fileName);
		log.debug("fullfileName = "+fullFileName);
		log.debug("parent = "+spreadsheet.getParent());
		log.debug("expName = "+expName);
		log.debug("msgFile = "+msgFile);

		Experiment myExperiment = new Experiment();
		ValidTerm myValidTerm = new ValidTerm();
		Protocol myProtocol = new Protocol();

		boolean keepGoingThisRow = true;
		boolean keepGoingAllRows = true;
		boolean sampleDataIsOk = true;
		boolean hybridDataIsOk = true;
		boolean extractDataIsOk = true;
		boolean protocolDataIsOk = true;
		boolean labelDataIsOk = true;
		int expID = myExperiment.getExperimentByName(expName, userLoggedIn, conn).getExp_id();
		boolean isCompoundDesign = (myExperiment.isCompoundDesign(expName, conn) != -99 ? true : false); 
log.debug("here in readSpreadsheet just discovered that isCompoundDesign is "+isCompoundDesign);
		String user = userLoggedIn.getUser_name_and_domain();
		log.debug("expID = "+expID);
		log.debug("user = "+user);

		FileHandler myFileHandler = new FileHandler();
		//log.debug("setting up writer");
		this.writer = myFileHandler.openFile(msgFile);
		this.writer.println();

		Workbook workbook = Workbook.getWorkbook(new File(fullFileName));
		Sheet sheet = workbook.getSheet("Template");
		log.debug("Number of rows in this sheet = "+sheet.getRows());

                conn.setAutoCommit(false);
		int rowNum = 0;
		String firstCol, secondCol = "";
		while ((firstCol = sheet.getCell(0,rowNum).getContents().trim()) == null || firstCol.equals("")) {
			rowNum++;
		}
		rowNum++;
		//log.debug("firstCol for rowNum= " + rowNum + " is " + sheet.getCell(0,rowNum).getContents());
		try {
			log.debug("just before reading through the spreadsheet");
			while ((firstCol = sheet.getCell(0,rowNum).getContents().trim()) != null && !firstCol.equals("")) { 
				log.debug("firstCol = xxx" + sheet.getCell(0,rowNum).getContents().trim() + "yyy");

				LinkedHashMap<String,String> hybridizationsHash = new LinkedHashMap<String, String>();
				LinkedHashMap<String,String> tsampleHash = new LinkedHashMap<String, String>();
				LinkedHashMap<String,String> protocolHash = new LinkedHashMap<String, String>();
				LinkedHashMap<String,String> textractHash = new LinkedHashMap<String, String>();
				LinkedHashMap<String,String> tlabelHash = new LinkedHashMap<String, String>();

				hybridizationsHash.put("Hybrid_name", sheet.getCell(0,rowNum).getContents().trim()); 
				log.debug("hybrid_name = " + hybridizationsHash.get("Hybrid_name"));

				tsampleHash.put("Sample_name", sheet.getCell(1,rowNum).getContents().trim()); 
				tsampleHash.put("Organism", sheet.getCell(2,rowNum).getContents().trim()); 
				tsampleHash.put("Sex", sheet.getCell(3,rowNum).getContents().trim()); 
				tsampleHash.put("Organism_part", sheet.getCell(4,rowNum).getContents().trim()); 
				tsampleHash.put("Sample_type", sheet.getCell(5,rowNum).getContents().trim()); 
				tsampleHash.put("Dev_stage", sheet.getCell(6,rowNum).getContents().trim()); 
				tsampleHash.put("Age", sheet.getCell(7,rowNum).getContents().trim()); 
				tsampleHash.put("Age_time_unit", sheet.getCell(8,rowNum).getContents().trim()); 
				tsampleHash.put("Genetic_variation", sheet.getCell(9,rowNum).getContents().trim()); 
				// This field is not validated
				String individual = sheet.getCell(10,rowNum).getContents().trim(); 

				tsampleHash.put("Individual_genotype", sheet.getCell(11,rowNum).getContents().trim()); 
				tsampleHash.put("Cell_line", sheet.getCell(12,rowNum).getContents().trim()); 
				tsampleHash.put("Strain", sheet.getCell(13,rowNum).getContents().trim()); 
				// These fields are not validated
				String target_cell_type = sheet.getCell(14,rowNum).getContents().trim(); 
				String disease_state = sheet.getCell(15,rowNum).getContents().trim(); 
				String additional = sheet.getCell(16,rowNum).getContents().trim(); 

				tsampleHash.put("Compound", sheet.getCell(17,rowNum).getContents().trim()); 
				tsampleHash.put("Dose", sheet.getCell(18,rowNum).getContents().trim()); 
				tsampleHash.put("Dose_unit", sheet.getCell(19,rowNum).getContents().trim()); 
				tsampleHash.put("Treatment", sheet.getCell(20,rowNum).getContents().trim()); 
				tsampleHash.put("Duration", sheet.getCell(21,rowNum).getContents().trim()); 
				protocolHash.put("Treatment_protocol", sheet.getCell(22,rowNum).getContents().trim()); 
				protocolHash.put("Growth_protocol", sheet.getCell(23,rowNum).getContents().trim()); 
				textractHash.put("Extract_name", sheet.getCell(24,rowNum).getContents().trim()); 
				protocolHash.put("Extract_protocol", sheet.getCell(25,rowNum).getContents().trim()); 
				tlabelHash.put("Label_name", sheet.getCell(26,rowNum).getContents().trim()); 
				protocolHash.put("Label_protocol", sheet.getCell(27,rowNum).getContents().trim()); 

				// This field is not validated
				String array_name = sheet.getCell(28,rowNum).getContents().trim(); 

				protocolHash.put("Hybrid_protocol", sheet.getCell(29,rowNum).getContents().trim()); 
				protocolHash.put("Scan_protocol", sheet.getCell(30,rowNum).getContents().trim()); 

				// Add a line to separate errors by line 
				//writer.println();

				sampleDataIsOk = validateData(rowNum + 1, tsampleHash, 
								"edu.ucdenver.ccp.PhenoGen.data.Tsample", expID, isCompoundDesign, conn); 
				log.debug("sampleDataIsOk= " + sampleDataIsOk);
				hybridDataIsOk = validateData(rowNum + 1, hybridizationsHash, 
								"edu.ucdenver.ccp.PhenoGen.data.Hybridization", expID, isCompoundDesign, conn); 
				log.debug("hybridDataIsOk= " + hybridDataIsOk);
				protocolDataIsOk = validateData(rowNum + 1, protocolHash, 
								"edu.ucdenver.ccp.PhenoGen.data.Protocol", expID, isCompoundDesign, conn);
				log.debug("protocolDataIsOk= " + protocolDataIsOk);
				extractDataIsOk = validateData(rowNum + 1, textractHash, 
								"edu.ucdenver.ccp.PhenoGen.data.Textract", expID, isCompoundDesign, conn);
				log.debug("extractDataIsOk= " + extractDataIsOk);
				labelDataIsOk = validateData(rowNum + 1, tlabelHash, 
								"edu.ucdenver.ccp.PhenoGen.data.Tlabel", expID, isCompoundDesign, conn);
				log.debug("labelDataIsOk= " + labelDataIsOk);

				keepGoingThisRow = sampleDataIsOk && hybridDataIsOk && protocolDataIsOk && extractDataIsOk && labelDataIsOk; 

				log.debug("after validation, keepGoingThisRow = "+keepGoingThisRow);
				if (keepGoingThisRow) {
					Tsample myTsample = new Tsample();
					myTsample.setTsample_id(tsampleHash.get("Sample_name")); 
					myTsample.setTsample_taxid(new Tntxsyn().getTaxID(tsampleHash.get("Organism"), conn).getTntxsyn_tax_id()); 
					myTsample.setTsample_sex(myValidTerm.getSysuid(tsampleHash.get("Sex"), "SEX", conn));
					int[] organism_part_val = fillInTothers(tsampleHash.get("Organism_part"), "ORGANISM_PART", user, conn);
					myTsample.setTsample_organism_part(organism_part_val[0]);
					int[] sample_type_val = fillInTothers(tsampleHash.get("Sample_type"), "SAMPLE_TYPE", user, conn);
					myTsample.setTsample_sample_type(sample_type_val[0]);
					int[] dev_stage_val = fillInTothers(tsampleHash.get("Dev_stage"), "DEVELOPMENTAL_STAGE", user, conn);
					myTsample.setTsample_dev_stage(dev_stage_val[0]);

					String age = tsampleHash.get("Age");
					if (age != null && !age.equals("")) {
						if (age.indexOf("-") > -1) { 
							myTsample.setTsample_age_status(myValidTerm.getSysuid("specified", "AGE_STATUS", conn));
							myTsample.setTsample_agerange_min(Double.parseDouble(age.substring(0, age.indexOf("-")))); 
							myTsample.setTsample_agerange_max(Double.parseDouble(age.substring(age.indexOf("-") + 1))); 
						} else {
							myTsample.setTsample_age_status(myValidTerm.getSysuid("specified", "AGE_STATUS", conn));
							myTsample.setTsample_agerange_min(Double.parseDouble(age)); 
						}
					} else {
						myTsample.setTsample_age_status(myValidTerm.getSysuid("unknown", "AGE_STATUS", conn));
					}
					if (!myObjectHandler.isEmpty(tsampleHash.get("Age_time_unit"))) {
						myTsample.setTsample_time_unit(myValidTerm.getSysuid(tsampleHash.get("Age_time_unit"), "TIME_UNIT", conn));
					} else {
						// default to seconds if no time_unit is specified
						myTsample.setTsample_time_unit(myValidTerm.getSysuid("seconds", "TIME_UNIT", conn));
					}
					if (!myObjectHandler.isEmpty(tsampleHash.get("Genetic_variation"))) {
						myTsample.setTsample_genetic_variation(myValidTerm.getSysuid(tsampleHash.get("Genetic_variation"), "GENETIC_VARIATION", conn));
					}
					myTsample.setTsample_individual(individual); 
					if (!myObjectHandler.isEmpty(tsampleHash.get("Individual_genotype"))) {
						myTsample.setTsample_individual_gen(tsampleHash.get("Individual_genotype")); 
					}
					if (!myObjectHandler.isEmpty(tsampleHash.get("Cell_line"))) {
						myTsample.setTsample_cell_line(tsampleHash.get("Cell_line")); 
					}
					if (!myObjectHandler.isEmpty(tsampleHash.get("Strain"))) {
						myTsample.setTsample_strain(tsampleHash.get("Strain")); 
					}
					// These fields are not validated
					myTsample.setTsample_target_cell_type(target_cell_type); 
					myTsample.setTsample_disease_state(disease_state); 
					myTsample.setTsample_additional(additional); 
					// We don't capture these values in the spreadsheet -- they are simply defaulted to 'not applicable'
					myTsample.setTsample_time_point(myValidTerm.getSysuid("not applicable", "AGE_TIME_POINTS", conn));
					myTsample.setTsample_separation_tech(myValidTerm.getSysuid("not applicable", "SEPARATION_TECHNIQUE", conn));

					if (!myObjectHandler.isEmpty(protocolHash.get("Growth_protocol"))) {
						int growthProtocolID = myProtocol.getProtocol_id(protocolHash.get("Growth_protocol"), 
											"SAMPLE_GROWTH_PROTOCOL", conn);
						if (growthProtocolID != -99) {
							myTsample.setTsample_growth_protocolid(growthProtocolID);
						}
					}
					if (!myObjectHandler.isEmpty(protocolHash.get("Treatment_protocol"))) {
						int treatmentProtocolID = 
							myProtocol.getProtocol_id(protocolHash.get("Treatment_protocol"), 
											"SAMPLE_LABORATORY_PROTOCOL", conn);
						if (treatmentProtocolID != -99) {
							myTsample.setTsample_protocolid(treatmentProtocolID);
						}
					}
					myTsample.setTsample_exprid(expID);
					myTsample.setTsample_user(user);
					log.debug("about to create sample.  keepGoingThisRow = "+keepGoingThisRow);
					int sample_id = (keepGoingThisRow ? myTsample.createTsample(conn) : -99);

					log.debug("here org_part_tothers = " + organism_part_val[1]);
					// Now go back to Tothers and update the record with the sample id
					// The value stored in the [1] field of the array contains the sysuid of Tothers
					if (organism_part_val[1] != -99) {
						Tothers thisTothers = new Tothers(organism_part_val[1]);
						thisTothers.setTothers_sampleid(sample_id);
						thisTothers.updateTothers_sampleid(conn);
					} 
					if (sample_type_val[1] != -99) {
						Tothers thisTothers = new Tothers(sample_type_val[1]);
						thisTothers.setTothers_sampleid(sample_id);
						thisTothers.updateTothers_sampleid(conn);
					} 
					if (dev_stage_val[1] != -99) {
						Tothers thisTothers = new Tothers(dev_stage_val[1]);
						thisTothers.setTothers_sampleid(sample_id);
						thisTothers.updateTothers_sampleid(conn);
					} 

					if (isCompoundDesign) {
						int compoundID = myValidTerm.getSysuid("compound", "EXPERIMENTAL_FACTOR", conn);
						int doseID = myValidTerm.getSysuid("dose", "EXPERIMENTAL_FACTOR", conn);
						int treatmentID = myValidTerm.getSysuid("other", "EXPERIMENTAL_FACTOR", conn);

						if (tsampleHash.get("Compound") != null && !tsampleHash.get("Compound").equals("")) {
							Tfctrval myTfctrval = new Tfctrval();
							myTfctrval.setTfctrval_expfctrid(compoundID);
							myTfctrval.setTfctrval_freetext(tsampleHash.get("Compound"));
							myTfctrval.setTfctrval_sampleid(sample_id);
							myTfctrval.setTfctrval_user(user);
							int fctrval_id = (keepGoingThisRow ? myTfctrval.createTfctrval(conn) : -99);
						}
						if (tsampleHash.get("Dose") != null && !tsampleHash.get("Dose").equals("")) {
							Tfctrval myTfctrval = new Tfctrval();
							myTfctrval.setTfctrval_expfctrid(doseID);
							myTfctrval.setTfctrval_freetext(tsampleHash.get("Dose"));
							if (tsampleHash.get("Dose_unit") != null && !tsampleHash.get("Dose_unit").equals("")) {
								myTfctrval.setTfctrval_freetextunit(tsampleHash.get("Dose_unit"));
							}
							myTfctrval.setTfctrval_sampleid(sample_id);
							myTfctrval.setTfctrval_user(user);
							int fctrval_id = (keepGoingThisRow ? myTfctrval.createTfctrval(conn) : -99);
						}
						if (tsampleHash.get("Treatment") != null && !tsampleHash.get("Treatment").equals("")) {
							Tfctrval myTfctrval = new Tfctrval();
							myTfctrval.setTfctrval_expfctrid(treatmentID);
							myTfctrval.setTfctrval_freetext(tsampleHash.get("Treatment"));
							if (tsampleHash.get("Duration") != null && !tsampleHash.get("Duration").equals("")) {
								myTfctrval.setTfctrval_freetextunit(tsampleHash.get("Duration"));
							}
							myTfctrval.setTfctrval_sampleid(sample_id);
							myTfctrval.setTfctrval_user(user);
							int fctrval_id = (keepGoingThisRow ? myTfctrval.createTfctrval(conn) : -99);
						}
					}

					log.debug("setting up extract object");
					Textract myTextract = new Textract();
					myTextract.setTextract_id(textractHash.get("Extract_name"));
					int extractProtocolID = myProtocol.getProtocol_id(protocolHash.get("Extract_protocol"), 
										"EXTRACT_LABORATORY_PROTOCOL", conn);
					if (extractProtocolID != -99) {
						myTextract.setTextract_protocolid(extractProtocolID);
					}
					myTextract.setTextract_user(user);
					int extract_id = (keepGoingThisRow ? myTextract.createTextract(conn) : -99);
					log.debug("textract was successfully created. id = "+extract_id);

					Tpooled myTpooled = new Tpooled();
					myTpooled.setTpooled_sampleid(sample_id);
					myTpooled.setTpooled_extractid(extract_id);
					myTpooled.setTpooled_user(user);
					int pooled_id = (keepGoingThisRow ? myTpooled.createTpooled(conn) : -99);
					log.debug("tpooled was successfully created. id = "+pooled_id);

					Tlabel myTlabel = new Tlabel();
					myTlabel.setTlabel_id(tlabelHash.get("Label_name"));
					int labelProtocolID = myProtocol.getProtocol_id(protocolHash.get("Label_protocol"), 
										"LABEL_LABORATORY_PROTOCOL", conn);
					if (labelProtocolID != -99) {
						myTlabel.setTlabel_protocolid(labelProtocolID);
					}
					myTlabel.setTlabel_extractid(extract_id);
					myTlabel.setTlabel_user(user);
					int label_id = (keepGoingThisRow ? myTlabel.createTlabel(conn) : -99);
					log.debug("tlabel was successfully created. id = "+label_id);

					Hybridization myHybridization = new Hybridization();
					myHybridization.setName(hybridizationsHash.get("Hybrid_name"));
					int hybridProtocolID = myProtocol.getProtocol_id(protocolHash.get("Hybrid_protocol"), 
										"HYBRID_LABORATORY_PROTOCOL", conn);
					if (hybridProtocolID != -99) {
						myHybridization.setProtocol_id(hybridProtocolID);
					}
					int scanProtocolID = myProtocol.getProtocol_id(protocolHash.get("Scan_protocol"), 
								"SCANNING_LABORATORY_PROTOCOL", conn);
					if (scanProtocolID != -99) {
						myHybridization.setScan_protocol_id(scanProtocolID);
					}

					int arrayID = new Array().getArrayID(array_name, user, conn);
					if (arrayID == -99) {
						arrayID = new Tarray().createNewTarray(array_name, user, conn); 
					}
					myHybridization.setArray_id(arrayID);
					myHybridization.setCreated_by_login(user);
					int hybrid_id = (keepGoingThisRow ? myHybridization.createHybridization(conn) : -99);
					log.debug("hybridizatoin was successfully created. id = "+hybrid_id);

					Tlabhyb myTlabhyb = new Tlabhyb();
					myTlabhyb.setTlabhyb_labelid(label_id);
					myTlabhyb.setTlabhyb_hybridid(hybrid_id);
					myTlabhyb.setTlabhyb_user(user);
					int labhyb_sysuid = (keepGoingThisRow ? myTlabhyb.createTlabhyb(conn) : -99);
					log.debug("tlabhyb was successfully created. id = "+labhyb_sysuid);
				} else {
					// Add a line to separate errors 
					writer.println();
					log.debug("keepGoingThisRow is false after reading one of the rows, so rolling back");
					keepGoingAllRows = false;
					conn.rollback();
				}

				rowNum++;
			}
			if (keepGoingAllRows) { 
				log.debug("After reading all the rows, keepGoingAllRows is true, so committing now");
				conn.commit();
			} else {
				log.debug("After reading all the rows, keepGoingAllRows is false, so rolling back now");
				conn.rollback();
			}

		} catch (SQLException e) {
                        log.error("In exception of readSpreadsheet", e);
			//writer.println("ERROR:  " + e.getMessage());
			log.debug("got SQLException while reading spreadsheet, so rolling back");
                        conn.rollback();
                        throw e;
                } finally {
			// Finished - close the workbook and free up memory 
			workbook.close();
			this.writer.close();
                	conn.setAutoCommit(true);
		}

/*
		log.debug("checking error file " + msgFile);
		boolean errorFound = myFileHandler.fileContainsString(new File(msgFile), "ERROR");
*/
		fileContents = myFileHandler.getFileContents(new File(msgFile));
		/*
		for (int i=0; i<fileContents.length; i++) {
			System.out.println(fileContents[i]);
		}
		*/
		return fileContents;
	}

	/**
	 * Gets all the Experiments for a particular user
	 * @param user the login name of the user
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Experiment objects
	 */
	public Experiment[] getAllExperimentsForUser(String user, Connection conn) throws SQLException {

		log.debug("In getAllExperimentsForUser. user = " + user);

		String query = 
			selectClause +
			fromClause +
			whereClause +
			"and created_by_login like ? ||'%' "+ 
			orderByClause;

		//log.debug("query =  " + query);

		Results myResults = new Results(query, user, conn);

		Experiment[] myExperiment = setupExperimentValues(myResults);

		myResults.close();

		return myExperiment;
	}
	
	/**
	 * Gets all the Experiments by experiment Ids using a String object delimited by commas 
	 * @param experimentIds
	 * @param conn
	 * @return array of Experiments
	 * @throws SQLException
	 */
    public Experiment[] getExperimentsByExperimentIds(String experimentIds, Connection conn) throws SQLException {
	   log.debug("In getExperimentsByExperimentIds = " + experimentIds);
	   
       String query = 
                selectClause +
                fromClause +
                whereClause +
                "and exp.exp_id in ("+experimentIds+") "+ 
                orderByClause;

       log.debug("query =  " + query);

       Results myResults;
       
       myResults = new Results(query, conn);
       
       Experiment[] experiments = setupExperimentValues(myResults);
       
       myResults.close();
       
       return experiments;
			
}

	

	/**
	 * Returns one Experiment object from an array of Experiment objects
	 * @param myExperiments	an array of Experiment objects 
	 * @param expID	the expID of the object to return
	 * @return            a Experiment object
	 */
	public Experiment getExperimentFromMyExperiments(Experiment[] myExperiments, int expID) {
        	//
        	// Return the Experiment object that contains the expID from the myExperiments
        	//
		log.debug("in getExperimentFromMyExperiments. expID = "+expID);

		// Decided not to sort and do a binarySearch 'cuz then experimentsForUser is sorted by exprid instead of exp_name
		for (int i=0; i<myExperiments.length; i++) {
			if (myExperiments[i].getExp_id() == expID) {
				return myExperiments[i];
			}
		}

        	return new Experiment(-99);
	}

	/**
	 * Gets the Experiment name for this exp_id
	 * @param exp_id	 the identifier of the Experiment
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a string containing the Experiment name
	 */
	public String getExperimentName(int exp_id, Connection conn) throws SQLException {

		log.debug("in getExperimentName");

		String query = 
			"select "+
			"exp_name "+
			"from experiments "+ 
			"where exp_id = ?";
	
		//log.debug("query = "+query);

		Results myResults = new Results(query, exp_id, conn);

		String expName = myResults.getStringValueFromFirstRow();

		myResults.close();

		return expName;
	}

	/**
	 * Gets the Experiment object for this exp_id
	 * @param exp_id	 the identifier of the Experiment
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Experiment object
	 */
	public Experiment getExperiment(int exp_id, Connection conn) throws SQLException {

		log.debug("In getOne Experiment. exprid = " + exp_id);

		String query = 
			selectClause +
			fromClause +
			whereClause +
			"and exp.exp_id = ? " +
			orderByClause;

		//log.debug("query = "+query);

		Results myResults = new Results(query, exp_id, conn);

		Experiment myExperiment = setupExperimentValues(myResults)[0];

		myResults.close();

		return myExperiment;
	}


	/**
	 * Gets the Experiment object for this experiment name
	 * @param exp_name	the name of the Experiment
         * @param userLoggedIn  the User object of the user logged in
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Experiment object
	 */
	public Experiment getExperimentByName(String exp_name, User userLoggedIn, Connection conn) throws SQLException {
	
		log.debug("in getExperimentByName");

		String query = 
			"select "+
			"exp_id, subid, accno, exp_description, "+
			"created_by_login, to_char(exp_create_date, 'mm/dd/yyyy hh12:mi AM'), "+
			"exp_name "+ 
			"from experiments "+ 
			"where created_by_login like ? "+
			"and exp_name = ?";
	
		//log.debug("query = "+query);

                Results myResults = new Results(query, new Object[] {userLoggedIn.getUser_name(), exp_name}, conn);

		Experiment myExperiment = setupExperimentValues(myResults)[0];

		myResults.close();

		return myExperiment;
	}


	/**
	 * Determines whether Experiment is a compound design type or not
	 * @param expName the name of the Experiment
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	true if it is a compound design
	 */
	public int isCompoundDesign(String expName, Connection conn) throws SQLException {
		log.debug("in Experiment isCompoundDesign. expName=" + expName);

                String query =
                	"select 1 "+
                        "from experiments exp, Texprtyp t, valid_terms val "+
                        "where exp_name = ? "+
                        "and exp.exp_id = t.texprtyp_exprid "+
			"and t.texprtyp_id = val.term_id "+
			"and val.category = 'EXPERIMENT_TYPE' "+
			"and t.texprtyp_del_status = 'U' "+
                        "and val.value = 'compound treatment design'";

		//log.debug("query = "+query);
		Results myResults = new Results(query, expName, conn);
		int value = myResults.getIntValueFromFirstRow();
		log.debug("this Experiment isCompoundDesign. answer =" + value);

		myResults.close();

		return value;
	}

	/**
	 * Checks to see if the design types and factors chosen are in sync
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a message stating what the problem is
	 */
	public List<String[]> getCombinations(Connection conn) throws SQLException {
	
		log.debug("in Experiment getCombinations");

		List<String[]> validCombos = new ArrayList<String[]>();
		validCombos.add(new String[] {"cell type comparison design", "cell type"});
		validCombos.add(new String[] {"compound treatment design", "compound"});
		validCombos.add(new String[] {"compound treatment design", "dose"});
		validCombos.add(new String[] {"disease state design", "disease state"});
		validCombos.add(new String[] {"dose response design", "compound"});
		validCombos.add(new String[] {"dose response design", "dose"});
		validCombos.add(new String[] {"genotyping design", "genotype"});
		validCombos.add(new String[] {"strain or line design", "strain"});

		String query =
			"select dt.term_id, dt.value, f.term_id, f.value "+
			"from valid_terms dt, valid_terms f "+
			"where dt.value = ? "+
			"and f.value = ? "+
			"and dt.category = 'EXPERIMENT_TYPE' "+
			"and f.category = 'EXPERIMENTAL_FACTOR'";
		
		String[] dataRow;
		List<String[]> myCombos = new ArrayList<String[]>();
                Results myResults = null;
		for (Iterator itr = validCombos.iterator(); itr.hasNext();) {
			String[] validCombo = (String[]) itr.next();
			String thisDesignType = validCombo[0];
			String thisFactor = validCombo[1];

                	myResults = new Results(query, new Object[] {thisDesignType, thisFactor}, conn);

                	while ((dataRow = myResults.getNextRow()) != null) {
				String[] thisArray = new String[4];
				for (int i=0; i<dataRow.length; i++) {
                        		thisArray[i] = dataRow[i];
				}
				myCombos.add(thisArray);
                	}
		}

                myResults.close();

		return myCombos;
	}

	/**
	 * Creates an experiment object by inserting records into experiments, Texpfctr, Texprtyp, Tpublic, Tauthor tables
	 * @param userLoggedIn the User object of the person logged into the website
	 * @param fieldValues fieldNames mapped to their values
	 * @param multipleFieldValues fieldNames mapped to their multiple values
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created in the Experiment table
	 */
	public int createExperiment(User userLoggedIn, Hashtable<String, String> fieldValues, 
				HashMap<String, String[]> multipleFieldValues, Connection conn) throws SQLException {
	
		log.debug("in Experiment create with fieldValues and multipleFieldValues");

                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		//log.debug("now = "+now);

		int exp_id = -99;
                conn.setAutoCommit(false);

		try {
			/*
			Tpublic myTpublic = new Tpublic();
                	myTpublic.setTpublic_subid(submis_id);
                	myTpublic.setTpublic_title("");
                	myTpublic.setTpublic_status(new ValidTerm().getDefaultPublicationStatus(conn));
                	//myTpublic.setTpublic_status(Integer.parseInt((String) fieldValues.get("publicationStatus")));
                	myTpublic.setTpublic_publication("");
                	myTpublic.setTpublic_year("");
                	myTpublic.setTpublic_volume("");
                	myTpublic.setTpublic_first_page("");
                	myTpublic.setTpublic_last_page("");
                	myTpublic.setTpublic_user(userLoggedIn.getUser_name_and_domain());
                	myTpublic.createTpublic(conn);
			*/

	                int submis_id = myDbUtils.getUniqueID("submis_seq", conn);
			setSubid(submis_id);
                	setCreated_by_login(userLoggedIn.getUser_name());
                	setExp_name((String) fieldValues.get("experimentName"));
                	//setHold_date(myObjectHandler.getScreenDateAsTimestamp((String) fieldValues.get("dateForRelease")));
                	setHold_date(now);
                	setProc_status("P");
                	setComp_status("U");
			setAccno("");
			setExp_description((String) fieldValues.get("description"));
			setCreated_by_login(userLoggedIn.getUser_name());
			exp_id = createExperiment(conn);

			log.debug("just created Experiment. exp_id = "+exp_id);
	                String[] designTypes = (String[]) multipleFieldValues.get("designTypes");
	                for (int i=0; i<designTypes.length; i++) {
				Texprtyp myTexprtyp = new Texprtyp();
                		myTexprtyp.setTexprtyp_exprid(exp_id);
                		myTexprtyp.setTexprtyp_id(Integer.parseInt(designTypes[i]));
                		myTexprtyp.setTexprtyp_user(userLoggedIn.getUser_name_and_domain());
                		myTexprtyp.createTexprtyp(conn);
				if (!((String)fieldValues.get("otherType")).equals("")) {
				        int otherTypeValue = new ValidTerm().getSysuid("other", "EXPERIMENT_TYPE", conn);
                			myTexprtyp.setTexprtyp_exprid(exp_id);
                			myTexprtyp.setTexprtyp_id(otherTypeValue);
                			myTexprtyp.setTexprtyp_user(userLoggedIn.getUser_name_and_domain());
                			myTexprtyp.createTexprtyp(conn);
			                handleTothers((String) fieldValues.get("otherType"), "EXPERIMENT_TYPE", exp_id, userLoggedIn, conn);
				}
			}
			log.debug("just created Texprtyps");
	                String[] factors = (String[]) multipleFieldValues.get("factors");
	                for (int i=0; i<factors.length; i++) {
				Texpfctr myTexpfctr = new Texpfctr();
                		myTexpfctr.setTexpfctr_exprid(exp_id);
                		myTexpfctr.setTexpfctr_id(Integer.parseInt(factors[i]));
                		myTexpfctr.setTexpfctr_user(userLoggedIn.getUser_name_and_domain());
                		myTexpfctr.createTexpfctr(conn);
				if (!((String)fieldValues.get("otherFactor")).equals("")) {
				        int otherFactorValue = new ValidTerm().getSysuid("other", "EXPERIMENTAL_FACTOR", conn);
                			myTexpfctr.setTexpfctr_exprid(exp_id);
                			myTexpfctr.setTexpfctr_id(otherFactorValue);
                			myTexpfctr.setTexpfctr_user(userLoggedIn.getUser_name_and_domain());
                			myTexpfctr.createTexpfctr(conn);
			                handleTothers((String) fieldValues.get("otherFactor"), "EXPERIMENTAL_FACTOR", exp_id, userLoggedIn, conn);
				}
			}
			log.debug("just created Texpfctrs");

			conn.commit();

		} catch (SQLException e) {
                        log.error("In exception of create Experiment", e);
                        conn.rollback();
                        throw e;
                }
                conn.setAutoCommit(true);
		return exp_id;
		//return -99;
	}



        private void handleTothers (String field, String type, int expID, User userLoggedIn, Connection conn) throws SQLException {
                log.debug("in handleTothers. field = "+field + ", type = " + type + ", exp = "+expID);

                if (field != null && !field.equals("")) {
                        Tothers existingTothers = new Tothers().getTothersForExpByType(expID, type, conn);
                        if (existingTothers != null) {
                                log.debug("one already exists, so deleting it");
                                existingTothers.deleteAndCommit(conn);
                        }
                        Tothers tothers = new Tothers();
                        tothers.setTothers_exprid(expID);
                        tothers.setTothers_id(type);
                        tothers.setTothers_value(field);
                        tothers.setTothers_descr(field);
                        tothers.setTothers_user(userLoggedIn.getUser_name_and_domain());
                        log.debug("just created a new tothers ");
                        tothers.createTothers(conn);
                } else {
                        log.debug("field is null");
                }
        }

	/**
	 * Creates a record in the experiments table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createExperiment(Connection conn) throws SQLException {

		log.debug("in Experiment create");

		int exp_id = myDbUtils.getUniqueID("experiments_seq", conn);

		log.debug("exp_id = " + exp_id);

		String query = 
			"insert into experiments "+
			"(exp_id, subid, exp_name, accno, exp_description, "+
			"hold_date, proc_status, comp_status, created_by_login, exp_create_date) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?, ?, ?, ?)";

		log.debug("query = "+query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, exp_id);
		pstmt.setInt(2, subid);
		pstmt.setString(3, exp_name);
		pstmt.setString(4, accno);
		pstmt.setString(5, exp_description);
		pstmt.setTimestamp(6, hold_date);
		pstmt.setString(7, proc_status);
		pstmt.setString(8, comp_status);
		pstmt.setString(9, created_by_login);
		pstmt.setTimestamp(10, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setExp_id(exp_id);

		return exp_id;
	}

	/**
	 * Updates a record in the experiments table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 
			"update experiments "+
			"set exp_id = ?, subid = ?, exp_name = ?, accno = ?, exp_description = ?, "+
			"hold_date = ?, proc_status = ?, comp_status = ?, created_by_login = ? "+
			"where exp_id = ?";

		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, exp_id);
		pstmt.setInt(2, subid);
		pstmt.setString(3, exp_name);
		pstmt.setString(4, accno);
		pstmt.setString(5, exp_description);
		pstmt.setTimestamp(6, hold_date);
		pstmt.setString(7, proc_status);
		pstmt.setString(8, comp_status);
		pstmt.setString(9, created_by_login);
		pstmt.setInt(10, exp_id);

		pstmt.executeUpdate();
		pstmt.close();

	}

	/**
	 * Deletes the record in the experiments table and also deletes child records in related tables.
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 */

	public void deleteExperiment(Connection conn) throws SQLException {

		log.info("in deleteExperiment");

		conn.setAutoCommit(false);

		PreparedStatement pstmt = null;

		try {
                        new Tpublic().deleteAllTpublicForExperiment(subid, conn);
                        new Texpfctr().deleteAllTexpfctrForExperiment(exp_id, conn);
                        new Texprtyp().deleteAllTexprtypForExperiment(exp_id, conn);
                        new Tsample().deleteAllTsampleForExperiment(exp_id, conn);
                        new Experiment_protocol().deleteAllExperiment_protocolsForExperiment(exp_id, conn);
  			new SessionHandler().deleteSessionActivitiesForExperiment(exp_id, conn);

			String query = 
				"delete from experiments " + 
				"where exp_id = ?";

			pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE, 
				ResultSet.CONCUR_UPDATABLE); 

			pstmt.setInt(1, exp_id);
			pstmt.executeQuery();
			pstmt.close();

			conn.commit();
		} catch (SQLException e) {
			log.debug("error in deleteExperiment");
			conn.rollback();
			pstmt.close();
			throw e;
		}
		conn.setAutoCommit(true);
	}

	/**
	 * Checks to see if an experiment with the same combination already exists.
	 * @param userLoggedIn	the Object of the user that is logged in
	 * @param expName	the name of the experiment
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the exp_id of an experiment that currently exists
	 */
	public int checkRecordExists(User userLoggedIn, String expName, Connection conn) throws SQLException {

		log.debug("in checkRecordExists.user = "+userLoggedIn.getUser_name() + ", and expName = "+expName);

		String query = 
			"select exp_id "+
			"from experiments "+
			"where exp_name = ? "+
			"and created_by_login like ? ||'%'"; 

		log.debug("query = "+query);
		PreparedStatement pstmt = conn.prepareStatement(query,
			ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_UPDATABLE);

		pstmt.setString(1, expName);
		pstmt.setString(2, userLoggedIn.getUser_name());
		ResultSet rs = pstmt.executeQuery();

		int pk = (rs.next() ? rs.getInt(1) : -99);
		pstmt.close();
		log.debug("returning this id from checkRecordExists:  " + pk);
		return pk;
	}

	/**
	 * Creates an array of Experiment objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Experiment
	 * @return	An array of Experiment objects with their values setup 
	 */
	private Experiment[] setupExperimentValues(Results myResults) {

		//log.debug("in setupExperimentValues");

		List<Experiment> experimentList = new ArrayList<Experiment>();

		Object[] dataRowWithClob;

		while ((dataRowWithClob = myResults.getNextRowWithClob()) != null) {

			//log.debug("dataRowWithClob= "); myDebugger.print(dataRowWithClob);

			Experiment thisExperiment = new Experiment();

			thisExperiment.setExp_id(Integer.parseInt((String) dataRowWithClob[0]));
			thisExperiment.setSubid(Integer.parseInt((String) dataRowWithClob[1]));
			thisExperiment.setAccno((String) dataRowWithClob[2]);
			thisExperiment.setExp_description(myResults.getClobAsString(dataRowWithClob[3]));
			thisExperiment.setCreated_by_login((String) dataRowWithClob[4]);
        		thisExperiment.setExp_create_date_as_string((String) dataRowWithClob[5]);
                        thisExperiment.setExp_create_date(myObjectHandler.getDisplayDateAsTimestamp((String) dataRowWithClob[5]));
                        thisExperiment.setExpName((String) dataRowWithClob[6]);
                        thisExperiment.setExpNameNoSpaces(myObjectHandler.removeBadCharacters((String) dataRowWithClob[6]));
			if (dataRowWithClob.length > 7 && dataRowWithClob[7] != null && !((String) dataRowWithClob[7]).equals("")) {
                        	thisExperiment.setNum_samples(Integer.parseInt((String) dataRowWithClob[7]));
			}
			if (dataRowWithClob.length > 8 && dataRowWithClob[8] != null && !((String) dataRowWithClob[8]).equals("")) {
                        	thisExperiment.setNum_files(Integer.parseInt((String) dataRowWithClob[8]));
			}
			if (dataRowWithClob.length > 9 && dataRowWithClob[9] != null && !((String) dataRowWithClob[9]).equals("")) {
                        	thisExperiment.setProc_status((String) dataRowWithClob[9]);
			}
			if (dataRowWithClob.length > 10 && dataRowWithClob[10] != null && !((String) dataRowWithClob[10]).equals("")) {
                        	thisExperiment.setNum_arrays(Integer.parseInt((String) dataRowWithClob[10]));
			}

			experimentList.add(thisExperiment);
		}

		Experiment[] experimentArray = (Experiment[]) experimentList.toArray(new Experiment[experimentList.size()]);

		return experimentArray;
	}

	/**
	 * Compares Experiment based on different fields.
	 */
	public class ExperimentSortComparator implements Comparator<Experiment> {
		int compare;
		Experiment experiment1, experiment2;

		public int compare(Experiment object1, Experiment object2) {
			log.debug("in comparator");
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				experiment1 = object1;
				experiment2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				experiment2 = object1;
				experiment1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			log.debug("experiment1 = " +experiment1+ "experiment2 = " +experiment2);

			if (sortColumn.equals("exp_id")) {
				compare = new Integer(experiment1.getExp_id()).compareTo(new Integer(experiment2.getExp_id()));
			} else if (sortColumn.equals("subid")) {
				compare = new Integer(experiment1.getSubid()).compareTo(new Integer(experiment2.getSubid()));
			} else if (sortColumn.equals("accno")) {
				compare = experiment1.getAccno().compareTo(experiment2.getAccno());
			} else if (sortColumn.equals("exp_description")) {
				compare = experiment1.getExp_description().compareTo(experiment2.getExp_description());
			} else if (sortColumn.equals("exp_create_date")) {
				compare = experiment1.getExp_create_date().compareTo(experiment2.getExp_create_date());
			}
			return compare;
		}
	}

	public Experiment[] sortExperiments (Experiment[] myExperiments, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myExperiments, new ExperimentSortComparator());
		return myExperiments;
	}


	/**
	 * Converts Experiment object to a String.
	 */
	public String toString() {
		return "This Experiment has exp_id = " + exp_id;
	}

	/**
	 * Prints Experiment object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Experiment objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Experiment)) return false;
		return (this.exp_id == ((Experiment)obj).exp_id);

	}
}
