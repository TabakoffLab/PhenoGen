package edu.ucdenver.ccp.util;

/**
 * This class contains utilities for manipulating files on the file system
 * @author Cheryl Hornbaker 
 *      
 */
import java.io.*;
import java.nio.*;
import java.nio.channels.*;
import java.util.*;
import java.util.zip.*;
import java.util.regex.*;
import javax.servlet.http.*;
import javax.servlet.*;
import edu.ucdenver.ccp.PhenoGen.web.MultipartRequest; 
import java.sql.*;
import edu.ucdenver.ccp.util.sql.*; 
import edu.ucdenver.ccp.util.*; 
import edu.ucdenver.ccp.PhenoGen.data.*; 
import edu.ucdenver.ccp.PhenoGen.driver.*; 
import edu.ucdenver.ccp.PhenoGen.tools.analysis.*; 

/* for logging messages */
import org.apache.log4j.Logger;

public class DirCleanup{

	private String path;
	private File userFilesDir;
	private File propertiesFile;
	private File webRoot;
	private File jSPSourceRoot;
	private String userFilesString;
	private boolean doIt = false;
	private Connection conn;
	private Vector fileNames = new Vector();
	private Vector fileParameterNames = new Vector();
	private Vector parameterNames = new Vector();
	private Vector parameterValues = new Vector();
	private String [] userList = null;
	private R_session myR_session = null;
	private Statistic myStatistic = null;
	private FileHandler myFileHandler = new FileHandler();
	private ObjectHandler myObjectHandler = new ObjectHandler();
	private	Debugger myDebugger = new Debugger();

	private Logger log=null;

	public DirCleanup() {
		log = Logger.getLogger("ReleaseLogger");
		setR_session(new R_session());
	}

	public R_session getR_session() {
		return myR_session; 
	}

	public void setR_session(R_session inR_session) {
		this.myR_session = inR_session;
	}

	public File getWebRoot() {
		return webRoot; 
	}

	public void setWebRoot(File inFile) {
		this.webRoot = inFile;
	}

	public File getJSPSourceRoot() {
		return jSPSourceRoot; 
	}

	public void setJSPSourceRoot(File inFile) {
		this.jSPSourceRoot = inFile;
	}

	public File getPropertiesFile() {
		return propertiesFile; 
	}

	public void setPropertiesFile(File inFile) {
		this.propertiesFile = inFile;
	}

	public File getUserFilesDir() {
		return userFilesDir; 
	}

	public void setUserFilesDir(File inFile) {
		this.userFilesDir = inFile;
	}

	public Connection getConn() {
		return conn; 
	}

	public void setConn(Connection inConnection) {
		this.conn = inConnection;
	}

	public void setUserFilesString(String inString) {
		this.userFilesString = inString;
	}

	public String getUserFilesString() {
		return userFilesString; 
	}

	class weightFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.endsWith("weight.png"));
    		}
	}
	class codelinkImportTxtFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.endsWith("CodeLink.ImportTxt.output.Rdata"));
    		}
	}
	class affyExportBioCFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.endsWith("Affy.ExportOutBioC.output.Rdata"));
    		}
	}
	class xlsNormalizationFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.endsWith("Normalization.output.xls"));
    		}
	}
	class tabNormalizationFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.endsWith("Normalization.output.tab"));
    		}
	}
	class allUsers_Filter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (!name.equals("experiment_datafiles") && !name.equals("Array_datafiles"));
    		}
	}
	class userName_Filter implements FilenameFilter {
		String userName;
		public userName_Filter(String userName) {
			this.userName = userName;
		}
		public boolean accept(File dir, String name) {
		        return (name.equals(userName));
    		}
	}
	class rawFile_Filter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.endsWith(".CEL") || name.endsWith(".txt") || name.endsWith(".gpr"));
    		}
	}
	class CEL_Filter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.endsWith(".CEL"));
    		}
	}
	class nonTestFiles implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (!name.equals("images") &&
				!name.equals("CVS") &&
				!name.equals("include")
				);
    		}
	}
	class NonAnalysisDirFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (!name.endsWith("_Analysis"));
    		}
	}
	class AnalysisDirFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.endsWith("_Analysis"));
    		}
	}
	class PromoterDirFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.endsWith("Promoter_Analysis"));
    		}
	}
	class MasterDirFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.endsWith("_Master"));
    		}
	}
	class GroupingsDirFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.equals("Groupings"));
    		}
	}
	class CorrelationDirFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.equals("CorrelationAnalyses"));
    		}
	}
	class callAffymetrixImportFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.equals("call_Affymetrix.Import"));
    		}
	}
	class callCodeLinkImportFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.equals("call_CodeLink.Import"));
    		}
	}
	class callCodeLinkQCFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.equals("call_CodeLink.QC"));
    		}
	}
	class arrayFilesFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.indexOf("arrayFiles.txt") > 0);
    		}
	}
	class QCImagesFilter implements FilenameFilter {
		public boolean accept(File dir, String name) {
		        return (name.equals("CodeLink.QC.table.txt") || name.equals("MAstats.txt") || name.endsWith(".png"));
    		}
	}
	class VersionDirFilter implements FileFilter {
		public boolean accept(File dir) {
		        return (dir.getPath().indexOf("/v") > 0);
    		}
	}
	public void R2_4Changes() throws SQLException, IOException, RException {
		System.out.println("in R2_4Changes");
		//doIt=true;
		//Delete directories that are no longer valid
		cleanupAllDirs();
		//Delete Correlation Analyses directories == they are no longer used
		//deleteCorrelationAnalysesDirs();
		//Delete Uploaded CEL Files 
		//deleteUploadedCELFiles();
		//Move all files from users' Arrays directories into central Array_datafiles directory
		//moveArrayFiles();
		//Fix call_AffyImport files, **.arrayFiles.txt files, and  -- change location of Array files to ~/userFiles/Array_datafiles
		//fixFiles();
		//Move files from experiment_datafiles sub-directories into the central Array_datafiles directory and create a 'dummy' file in the old location
		//createDummyArrayFiles();
		//See if all files have been accessed
		//didYouTestEverything();
	}
	public void R2_3Changes() throws SQLException, IOException, RException {
		System.out.println("in R2_3Changes");
		//Delete directories that are no longer valid
		//cleanupAllDirs();
		//Run PhenotypeImportTxt for those phenotypes previously created for Public BXD RI Mice and Public HXB/BXH Rats
		//runPhenotypeImportTxt();
		//See if all files have been accessed
		//didYouTestEverything();
	}
	public void R2_2Changes() throws SQLException, IOException, RException {
		System.out.println("in R2_2Changes");
		//Rename Experiments directories to Datasets
		//renameExperimentDirs();
		//Create images sub-directory and move all image files into that directory
		//createImageDirs();
		//Delete directories that are no longer valid
		//cleanupAllDirs();
		//See if all files have been accessed
		//didYouTestEverything();
	}
	public void R2_1Changes() throws SQLException, IOException, RException {
		System.out.println("in R2_1Changes");
		//Move files from ExperimentVersionDir/phenotype directory to Experiments/Groupings/###/user/phenotype directory
		//cleanupPhenotypes();
		//Create probe mask records for all Affy experiments
		//createProbeMaskRecords();
		//Delete directories that are no longer valid
		//cleanupAllDirs();
		//Run Phenotype.ImportTxt.R for all existing phenotypes to create summary graph and summary text file
		//runPhenotypeImportTxt();
		//Change group names to standardize (SHR/O1a->SHR/Ola, C57BL/6->C57BL/6J, BXD##/TyJ->BXD##) 
		//changeGroupNames();
	}
	public void R3_3ToR3_4Changes() throws SQLException, IOException, RException {
		System.out.println("in R3_3ToR3_4Changes");
		 //Move files from GeneLists/GeneList_Promoter_Analysis directory to GeneLists/GeneList/oPOSSUM directory
		//movePromoterFiles();
		// Move files from GeneLists/GeneList_Promoter_Analysis directory to GeneLists/GeneList/oPOSSUM directory
		//renameUpstreamFiles();
		// Copy phenotypeData.txt files to phenotypeValues.txt 
		//createDownloadPhenotypeFiles();
		// Create groups.txt files in each experiment version
		//createGroupFiles();
		// Re-structure group values into grouping tables
		//createGroupRecords();
	}

	public void cleanupAllDirs() throws SQLException, IOException {
		//Delete directories of users that are no longer registered
		cleanupUserDirs();
		//Delete directories of datasets that are no longer valid
		cleanupDatasetDirs();
		//Delete directories of experiment versions that are no longer valid
		cleanupDatasetVersionDirs();
		//Delete directories of gene lists that are no longer valid
		cleanupGeneListDirs();
		//Delete directories of phenotypes that are no longer valid
		cleanupPhenotypeDirs();
		//Delete directories of analyses that are no longer valid
		cleanupAnalysisDirs();
	}

	public void changeGroupNames() throws SQLException, IOException {
/*
		log.debug("in changeGroupNames");

		ParameterValue myParameterValue = new ParameterValue();
		Experiment myExperiment = new Experiment();
		Statistic myStatistic = new Statistic();
		myStatistic.setRFunctionDir(this.getR_session().getRFunctionDir());

		conn.setAutoCommit(false);

		//
		// Run PhenotypeImportTxt and Masking.Missing.Strains for each phenotype whose
		// group name is going to change
		//
                String query = 
			"select distinct "+
			"e.dataset_id, "+
			"u.user_name owner, p.user_name pheno_creator, "+
			"e.exp_name, gp.grouping_id, "+
			"a.parameter_group_id, b.value, "+ 
			"pg.version "+
			"from parameter_values a, parameter_values b, parameter_values c, parameter_groups pg, groups g, groupings gp, experiments e, users u, users p "+
			"where a.parameter = to_char(g.group_number) "+
			"and e.created_by_user_id = u.user_id "+
			"and pg.dataset_id = gp.dataset_id  "+
			"and e.dataset_id = pg.dataset_id "+
			"and pg.parameter_group_id = a.parameter_group_id "+
			"and g.grouping_id = gp.grouping_id "+
			//change all phenotypes that have SHR/O1a for a group name, but only change the group names on public datasets 
			"and (g.group_name like 'SHR%a'  or (u.user_name = 'public' and (g.group_name = 'C57BL/6' or g.group_name like 'BXD%TyJ%'))) "+
			"and a.category = 'Phenotype Group Value' "+
			"and a.parameter_group_id = b.parameter_group_id "+
			"and a.parameter_group_id = c.parameter_group_id "+
			"and b.parameter = 'Name' "+
			"and c.parameter = 'User ID' "+
			"and c.value = to_char(p.user_id) "+
			"union "+
			"select distinct "+
			"e.dataset_id, "+
			"u.user_name owner, p.user_name pheno_creator, "+
			"e.exp_name, gp.grouping_id, "+
			"a.parameter_group_id, b.value, "+ 
			"pg.version "+
			"from parameter_values a, parameter_values b, parameter_values c, parameter_groups pg, groups g, groupings gp, experiments e, users u, users p "+
			"where a.parameter = to_char(g.group_number) "+
			"and e.created_by_user_id = u.user_id "+
			"and pg.dataset_id = gp.dataset_id  "+
			"and e.dataset_id = pg.dataset_id "+
			"and pg.parameter_group_id = a.parameter_group_id "+
			"and g.grouping_id = gp.grouping_id "+
			//change all phenotypes that have SHR/O1a for a group name, but only change the group names on public datasets 
			"and (g.group_name like 'SHR%a' or g.group_name = 'C57BL/6' or g.group_name like 'BXD%TyJ%') "+
			"and e.exp_name like '%Re-normalized%' "+
			"and a.category = 'Phenotype Group Value' "+
			"and a.parameter_group_id = b.parameter_group_id "+
			"and a.parameter_group_id = c.parameter_group_id "+
			"and b.parameter = 'Name' "+
			"and c.parameter = 'User ID' "+
			"and c.value = to_char(p.user_id) "+
			"order by 2, 6 ";
	
		//log.debug("query = "+query);

		// Get the phenotypes to change based on the old group names
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(query);

		// Now change to the new group names
		Hashtable<String, String> values = new Hashtable<String, String>();
		values.put("BXD1/TyJ", "BXD1");
		values.put("BXD11/TyJ", "BXD11");
		values.put("BXD12/TyJ", "BXD12");
		values.put("BXD13/TyJ", "BXD13");
		values.put("BXD14/TyJ", "BXD14");
		values.put("BXD15/TyJ", "BXD15");
		values.put("BXD16/TyJ", "BXD16");
		values.put("BXD18/TyJ", "BXD18");
		values.put("BXD19/TyJ", "BXD19");
		values.put("BXD2/TyJ", "BXD2");
		values.put("BXD21/TyJ", "BXD21");
		values.put("BXD22/TyJ", "BXD22");
		values.put("BXD23/TyJ", "BXD23");
		values.put("BXD24/TyJ", "BXD24");
		values.put("BXD27/TyJ", "BXD27");
		values.put("BXD28/TyJ", "BXD28");
		values.put("BXD29/TyJ", "BXD29");
		values.put("BXD31/TyJ", "BXD31");
		values.put("BXD32/TyJ", "BXD32");
		values.put("BXD33/TyJ", "BXD33");
		values.put("BXD34/TyJ", "BXD34");
		values.put("BXD36/TyJ", "BXD36");
		values.put("BXD38/TyJ", "BXD38");
		values.put("BXD39/TyJ", "BXD39");
		values.put("BXD40/TyJ", "BXD40");
		values.put("BXD42/TyJ", "BXD42");
		values.put("BXD5/TyJ", "BXD5");
		values.put("BXD6/TyJ", "BXD6");
		values.put("BXD8/TyJ", "BXD8");
		values.put("BXD9/TyJ", "BXD9");
		values.put("C57BL/6", "C57BL/6J");

		String update = "update groups g "+
			"set g.group_name = ? "+
			"where g.group_name = ? "+
			"and g.grouping_id in "+
			"(select grouping_id "+
			"from groupings gp, experiments e, users u "+
			"where gp.dataset_id = e.dataset_id "+
			"and (u.user_name = 'public' or (u.user_name != 'public' and e.exp_name like '%Re-normalized%')) "+
			"and (g.group_name like 'SHR%a' or g.group_name = 'C57BL/6' or g.group_name like 'BXD%TyJ%'))";

		//log.debug("update = "+update);

		PreparedStatement pstmt = conn.prepareStatement(update,
                                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                                                ResultSet.CONCUR_UPDATABLE);


                for (Iterator itr=values.keySet().iterator(); itr.hasNext();) {

			String oldVal = (String) itr.next();
			String newVal = (String) values.get(oldVal);
			//log.debug("oldVal = "+oldVal+ ", newVal = "+newVal);
		
			try {
				pstmt.setString(1, newVal);
				pstmt.setString(2, oldVal);

		                pstmt.executeUpdate();
				log.debug("just updated "+oldVal+" to "+newVal);
				//conn.commit();
			} catch (Exception e) {
				log.debug("Error updating group records from "+oldVal+" to "+newVal, e);
				conn.rollback();
			}
		}
		pstmt.close();

		String update1 = "update groups g "+
			"set g.group_name = ? "+
			"where g.group_name = ?";

		//log.debug("update1 = "+update1);

		PreparedStatement pstmt1 = conn.prepareStatement(update1,
                                        ResultSet.TYPE_SCROLL_INSENSITIVE,
                                                ResultSet.CONCUR_UPDATABLE);

		try {
			pstmt1.setString(1, "SHR/Ola");
			pstmt1.setString(2, "SHR/O1a");

			log.debug("just updated SHR/O1a to SHR/Ola");
			pstmt1.executeUpdate();
			//conn.commit();
		} catch (Exception e) {
			log.debug("Error updating group records from SHR/O1a to SHR/Ola", e);
			conn.rollback();
		}
		pstmt1.close();


                while (rs.next()) {
			int dataset_id = rs.getInt(1);
			String experimentOwner = rs.getString(2);
			String phenotypeOwner = rs.getString(3);
			String exp_name = rs.getString(4);
			log.debug("exp_name = "+exp_name);
			int grouping_id = rs.getInt(5); 
			int parameter_group_id = rs.getInt(6); 
			String phenotypeName = myObjectHandler.removeBadCharacters(rs.getString(7));
			int version = rs.getInt(8); 
                        String userMainDir = userFilesString + experimentOwner + "/";
			Experiment thisExperiment = myExperiment.getIniaExperiment(dataset_id, userMainDir, conn);
			//log.debug("has this number of versions: "+thisExperiment.getExperimentVersions().length);
			Experiment.ExperimentVersion thisExperimentVersion = thisExperiment.getExperimentVersion(version); 
			//log.debug("choosing this version: "+thisExperimentVersion.getVersion());
			//log.debug("versionPath = "+thisExperimentVersion.getVersion_path());
			//log.debug("platform = "+thisExperiment.getPlatform());
			String groupingUserPhenotypeDir = thisExperimentVersion.getGroupingUserPhenotypeDir(phenotypeOwner, phenotypeName); 
			//log.debug("groupingUserPhenotypeDir= "+groupingUserPhenotypeDir);

	                String phenotypeDataFileName = thisExperimentVersion.getPhenotypeDataFileName(phenotypeOwner, phenotypeName); 
	                String phenotypeDownloadFileName = thisExperimentVersion.getPhenotypeDownloadFileName(phenotypeOwner, phenotypeName); 
	                String phenotypeDataOutputFileName = thisExperimentVersion.getPhenotypeDataOutputFileName(phenotypeOwner, phenotypeName); 
			//log.debug("phenotypeDataFileName= "+phenotypeDataFileName + "phenotypeDownloadFileName= "+phenotypeDownloadFileName);

			ParameterValue[] thisPhenotypeValues = myParameterValue.getPhenotypeValuesForParameterGroupIDTheOldWay(parameter_group_id, conn);
			//log.debug("thisPhenoVals = "); myDebugger.print(thisPhenotypeValues);
                	String phenotypeHeader = "grp.number\t" + "grp.name\t" + "phenotype\n";
                	String phenotypeVals = "";
                	String phenotypeDownloadVals = "";


	
// First run this method and create the new files.  Do NOT commit the data.  Then run it again and execute the Masking Missing Strains. 
			for (int i=0; i<thisPhenotypeValues.length; i++) {

				if (!thisPhenotypeValues[i].getParameter().equals("Description") &&
					!thisPhenotypeValues[i].getParameter().equals("Name")) {
					String rungroupNumber = myParameterValue.getGroupNumber(
                                			dataset_id, thisExperimentVersion.getVersion(), thisPhenotypeValues[i].getParameter(), conn);
					//log.debug("rungroupNumber = "+rungroupNumber + " for group "+thisPhenotypeValues[i].getParameter());
                                	//
                                	//Start with the rungroup name and the value
                                	//
                                	String row = thisPhenotypeValues[i].getParameter().replaceAll(" ", "_") + "\t" + 
							thisPhenotypeValues[i].getValue();

                                	//
                                	// The first time through, don't add the delimiter
                                	//

                                	if (phenotypeVals.equals("")) {
                                        	phenotypeVals = rungroupNumber + "\t" + row;
						phenotypeDownloadVals = row;
                                	} else {
                                        	phenotypeVals = phenotypeVals + "\n"+
                                                        	rungroupNumber + "\t" + row;
						phenotypeDownloadVals = phenotypeDownloadVals + "\n" + row;
                                	}
                        	}
			}
                	phenotypeVals = phenotypeHeader + phenotypeVals + "\n";
			new FileHandler().writeFile(phenotypeVals, phenotypeDataFileName);
			new FileHandler().writeFile(phenotypeDownloadVals, phenotypeDownloadFileName);
			//log.debug("phenotypeVals now is  "+phenotypeVals);
			//log.debug("phenotypeDownlaodVals now is  "+phenotypeDownloadVals);
			log.debug("just wrote files to "+groupingUserPhenotypeDir); 
                	try {
                        	myStatistic.callPhenotypeImportTxt(groupingUserPhenotypeDir,
                                                                phenotypeDataFileName,
                                                                phenotypeDataOutputFileName);
                	} catch (RException e) {
				log.debug("ERROR in callPhenotypeImportTxt", e);
                	}



                        File maskingFile = new File(groupingUserPhenotypeDir + "call_Masking.Missing.Strains");
                        if (maskingFile.exists()) {
                                if (myObjectHandler.subtractOneDay(myObjectHandler.getNowAsTimestamp()).after(new Timestamp(maskingFile.lastModified()))) {
                                        log.debug(groupingUserPhenotypeDir + "Masking exists and is old"); 
                                        try {
                                                myStatistic.callMaskingMissingStrains(groupingUserPhenotypeDir,
                                                                thisExperiment.getPlatform(),
                                                                thisExperimentVersion.getVersion_path(),
                                                                phenotypeDataOutputFileName);
                                                //myR_session.runR("call_Masking.Missing.Strains", groupingUserPhenotypeDir);
                                        } catch (RException e) {
                                                log.debug("ERROR when running callMaskingMissingStrains. check this directory:" + groupingUserPhenotypeDir, e);
                                        }
                                } else { 
                                        log.debug(groupingUserPhenotypeDir + "Masking exists and is new"); 
                                }
                                //log.debug(" ******  MaskingMissingStrains exists ******  ");
                        } else {
                                //log.debug("MaskingMissingStrains does not exist");
                        }

			if (new File(thisExperiment.getExperimentPath(userMainDir) + "call_Preparing.To.Renormalize").exists()) {
				log.debug(" ******  PreparingToRenormalize exists ******  check this directory:");
				log.debug("experimentPath = " +thisExperiment.getExperimentPath(userMainDir)); 
				String parentExpDir = myExperiment.getPublicExperimentsPath(userFilesString);
				parentExpDir = parentExpDir + 
                                        (thisExperiment.getExp_name().indexOf("BXD RI Mice Re-normalized") > -1 ?
                                                "PublicBXDRIMice_Master" :
                                                (thisExperiment.getExp_name().indexOf("HXB/BXH RI Rats Re-normalized") > -1 ?
                                                "PublicHXB_BXHRIRats_Master" :
                                                (thisExperiment.getExp_name().indexOf("BXD RI and Inbred Mice Re-normalized") > -1 ?
                                                "PublicBXDRIandInbredMice_Master" : 
                                                (thisExperiment.getExp_name().indexOf("Inbred Mice Re-normalized") > -1 ?
                                                "PublicInbredMice_Master" : "")))) + "/"; 
				log.debug("parentExpDir = "+parentExpDir);
                		try {
                        		myStatistic.callPreparingToRenormalize(parentExpDir,
                                                                phenotypeDataOutputFileName,
								thisExperiment.getExperimentPath(userMainDir));
                		} catch (Exception e) {
					log.debug("ERROR when running callPreparingToRenormalize. check this directory:" + groupingUserPhenotypeDir, e);
                		}
			} else {
				//log.debug("PreparingToRenormalize does not exist");
			}

		}
		//conn.commit();
		conn.rollback();
*/
	}

	public void runPhenotypeImportTxt() throws SQLException, IOException {
		//
		// Run PhenotypeImportTxt to create the QTL files for those 
		//

		System.out.println("in runPhenotypeImportTxt");
		log.debug("in runPhenotypeImportTxt");
		ParameterValue myParameterValue = new ParameterValue();

		Statistic myStatistic = new Statistic();
		myStatistic.setRFunctionDir(this.getR_session().getRFunctionDir());
		log.debug("RFunctionDir = " + this.getR_session().getRFunctionDir());

		// 1) Get the 2 public datasets for which we have genotype data, their grouping IDs, and the phenotypes created for them 

		String[] datasets = new String[] {new Dataset().BXDRI_DATASET_NAME, new Dataset().HXBRI_DATASET_NAME};

                String query = 
			"select '" + userFilesString + "'||u.user_name||'/Datasets/'||"+
			"replace(replace(replace(replace(d.name, '''', ''), '&', 'And'), ' ', ''), '/', '_')||"+
			"'_Master/Groupings/'||dv.grouping_id||'/'||u2.user_name||'/'||"+
			"replace(replace(replace(replace(pv.value, '''', ''), '&', 'And'), ' ', ''), '/', '_'), "+
			"u.user_name, d.dataset_id, dv.version, d.name, dv.grouping_id, u2.user_name, pv.value, pg.parameter_group_id,u2.user_id "+ 
			"from users u, datasets d, dataset_versions dv, parameter_groups pg, parameter_values pv, parameter_values pv2, users u2 "+
			"where u.user_id = d.created_by_user_id   "+
			"and d.dataset_id = dv.dataset_id "+
			"and dv.dataset_id = pg.dataset_id "+
			"and dv.version = pg.version "+
			"and pg.parameter_group_id = pv.parameter_group_id "+
			"and pv.category = 'Phenotype Data' "+
			"and pv.parameter = 'Name'    "+
			"and pv2.parameter_group_id = pv.parameter_group_id "+
			"and pv2.category = 'Phenotype Data' and pv2.parameter = 'User ID' "+
			"and pv2.value = u2.user_id "+
			"and d.name = ? "+ 
			"order by u.user_name, d.name, dv.version, pv.parameter_group_id, pv.parameter"; 

		log.debug("query = "+query);
/*
		for (String dataset:datasets) {
			try {
                		Results myResults = new Results(query, dataset, conn);
                		String[] dataRow;
				log.debug("numRows = "+myResults.getNumRows());
				int i=0;
                		dataRow = myResults.getNextRow();
				int dataset_id = Integer.parseInt(dataRow[2]);
                        	String userMainDir = userFilesString + "public" + "/";
// Dec 9, 2010: getDataset will need to be fixed to to use userLoggedIn instead 
				Dataset selectedDataset = new Dataset().getDataset(dataset_id, userMainDir, conn);
				myStatistic.setSelectedDataset(selectedDataset);
				myResults.goToFirstRow();
                		while ((dataRow = myResults.getNextRow()) != null) {
					int version = Integer.parseInt(dataRow[3]);
					Dataset.DatasetVersion selectedDatasetVersion = selectedDataset.getDatasetVersion(version);
					myStatistic.setSelectedDatasetVersion(selectedDatasetVersion);
					String phenotypeCreator = dataRow[6];
					String phenotypeName = dataRow[7];
					int user_id = Integer.parseInt(dataRow[9]);
                			log.debug("phenotypeCreator = "+phenotypeCreator);	
                			log.debug("phenotypeName = "+phenotypeName);	

					myStatistic.setUserLoggedIn(new User(user_id, phenotypeCreator));
                			try {
                        			myStatistic.callPhenotypeImportTxt(phenotypeName, "TRUE");
                			} catch (RException e) {
						log.debug("ERROR running PhenotypeImportTxt", e);
					}
                		}

                		myResults.close();
			} catch (Exception e) {
				log.debug("in exception of runPhenotypeImportTxt", e);
			}
		}
*/
	}

	//Delete directories from Dataset_Master/Groupings/###/user/phenotypes and Dataset_Master/v#/CorrelationAnalyses/user/phenotypes that are no longer valid
	public void cleanupPhenotypeDirs() throws SQLException {

		System.out.println("in cleanupPhenotypeDirs");
		log.debug("in cleanupPhenotypeDirs");

		// 1) Get all the datasets, their grouping IDs, and the phenotypes created for them 

                String query = 
			"select "+
			"'" + userFilesString + "'||u.user_name||'/Datasets/'||"+
			"replace(replace(replace(replace(d.name, '''', ''), '&', 'And'), ' ', ''), '/', '_')||"+
			"'_Master/Groupings/'||dv.grouping_id||'/'||u2.user_name||'/'||"+
			"replace(replace(replace(replace(pv.value, '''', ''), '&', 'And'), ' ', ''), '/', '_'), "+
			"'" + userFilesString + "'||u.user_name||'/Datasets/'||"+
			"replace(replace(replace(replace(d.name, '''', ''), '&', 'And'), ' ', ''), '/', '_')||"+
			"'_Master/v'||dv.version||'/'||'CorrelationAnalyses/'||u2.user_name||'/'||"+
			"replace(replace(replace(replace(pv.value, '''', ''), '&', 'And'), ' ', ''), '/', '_') "+
			"from users u, datasets d, dataset_versions dv, parameter_groups pg, parameter_values pv, parameter_values pv2, users u2 "+
			"where u.user_id = d.created_by_user_id   "+
			"and d.dataset_id = dv.dataset_id "+
			"and dv.dataset_id = pg.dataset_id "+
			"and dv.version = pg.version "+
			"and pg.parameter_group_id = pv.parameter_group_id "+
			"and pv.category = 'Phenotype Data' "+
			"and pv.parameter = 'Name'    "+
			"and pv2.parameter_group_id = pv.parameter_group_id "+
			"and pv2.category = 'Phenotype Data' and pv2.parameter = 'User ID' "+
			"and pv2.value = u2.user_id "+
			"and d.name not like 'Dummy'||dv.version||'%' "+
			"order by u.user_name, d.name, dv.version, pv.parameter_group_id, pv.parameter"; 

		//log.debug("query = "+query);
		try {
                	Results myResults = new Results(query, conn);
                	Set<String> validDirsSet1 = new ObjectHandler().getResultsAsSet(myResults, 0);
			//log.debug("validDirsSet1 = "); myDebugger.print(validDirsSet1);
                	Set<String> validDirsSet2 = new ObjectHandler().getResultsAsSet(myResults, 1);
			//log.debug("validDirsSet2 = "); myDebugger.print(validDirsSet2);

                	myResults.close();

                	File[] groupingsDirs = getAllUserDatasetMasterGroupingsDirs();
                	File[] versionCorrelationDirs = getAllUserDatasetVersionCorrelationDirs();

                        if (groupingsDirs != null && groupingsDirs.length > 0) {
				for (int i=0; i<groupingsDirs.length; i++) {
                			Set<String> allDirsInGroupingsDir = myFileHandler.getLowestDirsBelowThis(groupingsDirs[i]);
					//log.debug("allDirsInGroupingsDir = "); myDebugger.print(allDirsInGroupingsDir);
					for (Iterator itr=allDirsInGroupingsDir.iterator(); itr.hasNext();) {
						File thisDir = new File((String) itr.next());
						//log.debug("thisDir.getPath = "+thisDir.getPath());
						if (thisDir.isDirectory() && !validDirsSet1.contains(thisDir.getPath())) {
							if (doIt) {
								deleteDir(thisDir);
							} else {
								log.debug("need to delete directory " +thisDir);
							}
						}
					}
				}
			}
                        if (versionCorrelationDirs != null && versionCorrelationDirs.length > 0) {
				for (int i=0; i<versionCorrelationDirs.length; i++) {
                			Set<String> allDirsBelowThis = myFileHandler.getLowestDirsBelowThis(versionCorrelationDirs[i]);
					//log.debug("allDirsBelowThis = "); myDebugger.print(allDirsBelowThis);
					for (Iterator itr=allDirsBelowThis.iterator(); itr.hasNext();) {
						File thisDir = new File((String) itr.next());
						//log.debug("thisDir.getPath = "+thisDir.getPath());
						if (thisDir.isDirectory() && !validDirsSet2.contains(thisDir.getPath())) {
							if (doIt) {
								deleteDir(thisDir);
							} else {
								log.debug("need to delete directory " +thisDir);
							}
						}
					}
				}
			}
		} catch (Exception e) {
			log.debug("in exception of cleanupPhenotypeDirs", e);
		}

	}

	//Delete CorrelationAnalyses directories because they are no longer used
	public void deleteCorrelationAnalysesDirs() {
		log.debug("in deleteCorrelationAnalysesDirs");
		try {
                	File[] correlationAnalysesDirs = getAllUserDatasetVersionCorrelationDirs ();

                        if (correlationAnalysesDirs != null && correlationAnalysesDirs.length > 0) {
				for (int i=0; i<correlationAnalysesDirs.length; i++) {
                			Set<String> allDirsBelowThis = myFileHandler.getLowestDirsBelowThis(correlationAnalysesDirs[i]);
					//log.debug("allDirsBelowThis = "); myDebugger.print(allDirsBelowThis);
					for (Iterator itr=allDirsBelowThis.iterator(); itr.hasNext();) {
						File thisDir = new File((String) itr.next());
						//log.debug("thisDir.getPath = "+thisDir.getPath());
						if (thisDir.isDirectory() && thisDir.listFiles() != null && thisDir.listFiles().length > 0) {
							log.debug("this CorrelationAnalyses directory is not empty.  Check it out: "+thisDir);
						} else {
							deleteDir(thisDir);
						}
					}
					if (correlationAnalysesDirs[i].listFiles() != null && correlationAnalysesDirs[i].listFiles().length > 0) {
						deleteDir(correlationAnalysesDirs[i]);
					}
				}
			}
		} catch (Exception e) {
			log.debug("in exception of deleteCorrelationAnalysesDirs", e);
		}
	}

	//Delete directories from GeneLists/XXX_v#_Analysis/DDMONYYYY/HHMISS that are no longer valid
	public void cleanupAnalysisDirs() throws SQLException {
		log.debug("in cleanupAnalysisDirs");

                String query = 
			"select "+
			"gl.path "+
			"from gene_lists gl "+
			"where path is not null "+
			"order by gl.path";

		//log.debug("query = "+query);
		try {
                	Results myResults = new Results(query, conn);
                	Set<String> validDirsSet = new ObjectHandler().getResultsAsSet(myResults, 0);
			//log.debug("validDirsSet = "); myDebugger.print(validDirsSet);

                	myResults.close();

                	File[] analysisDirs = getAllUserGeneListAnalysisDirs();

			for (File thisAnalysisDir : analysisDirs) {
                		Set<String> allDirsBelowThis = myFileHandler.getLowestDirsBelowThis(thisAnalysisDir);
				for (String thisDirName : allDirsBelowThis) {
					File thisDir = new File(thisDirName);
					//log.debug("thisDir.getPath = "+thisDir.getPath());
					if (thisDir.isDirectory() && !validDirsSet.contains(thisDir.getPath())) {
						if (doIt) {
							deleteDir(thisDir);
						} else {
							log.debug("need to delete directory " +thisDir);
						}
					}
				}
			}
		} catch (Exception e) {
			log.debug("in exception of cleanupAnalysisDirs", e);
		}

	}

	//Move files from ExperimentVersionDir/phenotype directory to Experiments/Groupings/###/user/phenotype directory
	public void cleanupPhenotypes() throws SQLException {
/*
		System.out.println("in cleanupPhenotypes");
		log.debug("in cleanupPhenotypes");
		ParameterValue myParameterValue = new ParameterValue();
		Experiment myExperiment = new Experiment();

                String query = "select u.user_name, e.created_by_user_id, e.dataset_id, e.exp_name "+
                        "from users u, experiments e "+
                        "where u.user_id = e.created_by_user_id "+
                        "order by u.user_name, e.exp_name";

		log.debug("query = "+query);

                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(query);

                while (rs.next()) {
			if (rs.getString(4).indexOf("Dummy" + rs.getInt(3)) == -1) {
				String userName = rs.getString(1);
                        	String userMainDir = userFilesString + userName + "/";
				int dataset_id = rs.getInt(3);
				//log.debug("userMainDir = "+userMainDir);
				Experiment thisExperiment = myExperiment.getIniaExperiment(dataset_id, userMainDir, conn);

				// get all the distinct users who have created phenotypes for this experiment
				String query2 = 
				"select distinct pv.value "+
				"from parameter_values pv, "+
				"parameter_groups pg "+
				"where pv.parameter = 'User ID' "+
				"and pg.parameter_group_id = pv.parameter_group_id "+
				"and pg.dataset_id = " + dataset_id;

				//log.debug("query2 = "+query2);

                		Statement stmt2 = conn.createStatement();
                		ResultSet rs2 = stmt2.executeQuery(query2);
                		while (rs2.next()) {
					int phenotypeCreatorID = rs2.getInt(1);
					String phenotypeCreatorName = new User().getUser_name(phenotypeCreatorID, conn); 

					List<ParameterValue[]> myPhenotypeValues = 
						myParameterValue.getPhenotypeValuesForExperiment(
									phenotypeCreatorID, thisExperiment, -99, conn);
					//Go through the list 
                        		for (Iterator itr=myPhenotypeValues.iterator(); itr.hasNext();) {
                                		ParameterValue[] myValues = (ParameterValue[]) itr.next();
						for (int i=0; i<myValues.length; i++) {
							if (myValues[i].getParameter().equals("Name")) {
								String phenotypeName = myValues[i].getValue();
								Experiment.ExperimentVersion thisVersion = thisExperiment.getExperimentVersion(myValues[i].getVersion()); 
								String fromDir = thisVersion.getCorrelationUserPhenotypeDir(phenotypeCreatorName, phenotypeName);
								String groupingsDir = thisExperiment.getGroupingsDir(); 
								String groupingDir = thisVersion.getGroupingDir(); 
								String groupingUserDir = thisVersion.getGroupingUserDir(phenotypeCreatorName);
								String groupingUserPhenotypeDir = thisVersion.getGroupingUserPhenotypeDir(phenotypeCreatorName, phenotypeName); 
								try {
									boolean createGroupingsDir = (new File(groupingsDir)).mkdir();
									boolean createGroupingDir = (new File(groupingDir)).mkdir();
									boolean createGroupingUserDir = (new File(groupingUserDir)).mkdir();
									boolean createGroupingUserPhenotypeDir = (new File(groupingUserPhenotypeDir)).mkdir();
									log.debug("createGroupingsDir = "+createGroupingsDir);
									log.debug("createGroupingDir = "+createGroupingDir);
									log.debug("createGroupingUserDir = "+createGroupingUserDir);
									log.debug("createGroupingUserPhenotypeDir = "+createGroupingUserPhenotypeDir);
								} catch (Exception e) {
									log.debug("got exception creating groupings dirs");
								}
								String toDir = groupingUserPhenotypeDir;
								moveAllFilesInDir(new File(fromDir), new File(toDir));
								//log.debug("fromDir = "+fromDir + " and toDir = "+toDir);
                                                                if (!new File(fromDir + thisExperiment.getPlatform() + 
                                                                        ".ExportOutBioC.output.Rdata").exists()) {
                                                                        log.debug(thisExperiment.getExp_name() + "." + thisVersion.getExp_version() + 
                                                                                "-" + phenotypeCreatorName +  "-" +phenotypeName + "-" +" export file exists " + 
                                                                                new File(fromDir + thisExperiment.getPlatform() + 
                                                                                ".ExportOutBioC.output.Rdata").exists());
                                                                }
							}
						}
					}
				}
			}
		}
*/
	}

	public void createProbeMaskRecords () {
/*
		
		log.info("in DirCleanup.createProbeMaskRecords.");

                String query = "select u.user_id, u.user_name "+
                        "from users u "+
                        "order by u.user_name";

		log.debug("query = "+query);

		ParameterValue myParameterValue = new ParameterValue();
		myParameterValue.setCreate_date();

		try {
                	Results myResults = new Results(query, conn);
                	LinkedHashMap<String, String> userNameHash = new ObjectHandler().getResultsAsLinkedHashMap(myResults);

			for (Iterator itr=userNameHash.keySet().iterator(); itr.hasNext();) {
				String userID = (String) itr.next();
				String userName = (String) userNameHash.get(userID);

				Experiment[] userExperiments = new Experiment().getExperimentsForUser(Integer.parseInt(userID), conn);

				for (int k=0; k<userExperiments.length; k++) {
					if (userExperiments[k].getCreator().equals(userName)) {
						for (int m=0; m<userExperiments[k].getExperimentVersions().length; m++) {
							Experiment.ExperimentVersion thisVersion = 
								userExperiments[k].getExperimentVersions()[m];
							int version = thisVersion.getVersion();
							log.debug("thisVersion PGID = "+thisVersion.getMasterParameterGroupID());
							if (userExperiments[k].getExp_id() != 506 &&
								userExperiments[k].getPlatform().equals("Affymetrix")) {
								log.debug("creating a row for exp "+userExperiments[k].getExp_name() +" and version "+ thisVersion.getVersion());
                        					myParameterValue.setParameter_group_id(thisVersion.getMasterParameterGroupID());

                        					myParameterValue.setCategory("Data Normalization");
                       			 			myParameterValue.setParameter("Probe Mask Applied");
								if (userExperiments[k].getCreator().equals("public") &&
									thisVersion.getVersion() > 5) {
									log.debug("setting it to true!");
			                        			myParameterValue.setValue("T");
								} else {
			                        			myParameterValue.setValue("F");
								}
                       			 			myParameterValue.createParameterValue(conn);
							}
						}
					}
				}
			}
                	myResults.close();
		} catch (Exception e) {
			log.debug("in exception of createProbeMaskRecords", e);
		}
*/
	}

	public void didYouTestEverything () {
		log.info("in DirCleanup.didYouTestEverything.");
                Set<File> allFilesInWebDirs = myFileHandler.getAllFilesBelowThis(getWebRoot(), new nonTestFiles());
                Set<File> allFilesInJSPSourceDirs = myFileHandler.getAllFilesBelowThis(getJSPSourceRoot(), new nonTestFiles());

		//log.debug("allFilesInWebDirs = "); myDebugger.print(allFilesInWebDirs);
		//log.debug("allFilesInJSPSourceDirs = "); myDebugger.print(allFilesInJSPSourceDirs);
		allFilesInWebDirs = removeExtraFromFileNames(allFilesInWebDirs, ".jsp");
		allFilesInJSPSourceDirs = removeExtraFromFileNames(allFilesInJSPSourceDirs, "_jsp.java");
		allFilesInJSPSourceDirs = removeExtraFromFileNames(allFilesInJSPSourceDirs, "_jsp.class");
		//log.debug("now allFilesInWebDirs = "); myDebugger.print(allFilesInWebDirs);
		//log.debug("now allFilesInJSPSourceDirs = "); myDebugger.print(allFilesInJSPSourceDirs);
		allFilesInWebDirs.removeAll(allFilesInJSPSourceDirs);
		//log.debug("after removing JSPSource Files allFilesInWebDirs = "); myDebugger.print(allFilesInWebDirs);
		log.debug("These files have not been tested:");
		for (Iterator itr=allFilesInWebDirs.iterator(); itr.hasNext();) {
			log.debug(itr.next());
		}
	}

	private Set<File> removeExtraFromFileNames (Set<File> mySet, String removeThis) {

		Set<File> newSet = new TreeSet<File>();
		for (Iterator itr=mySet.iterator(); itr.hasNext();) {
			String myString = ((File) itr.next()).getName();
			//log.debug("myString was: " +myString);
			myString = myString.replaceAll(removeThis, "");
			//log.debug("myString now: " +myString);
			newSet.add(new File(myString));
		}
		return newSet;
	}

	public void cleanupUserDirs () {
		
		log.info("in DirCleanup.cleanupUserDirs.");
                File [] userDirs = getAllUserDirs();

                String query = "select u.user_name "+
                        "from users u "+
                        "order by u.user_name";

		//log.debug("query = "+query);

		try {
                	Results myResults = new Results(query, conn);
                	Set userNameSet = new ObjectHandler().getResultsAsSet(myResults, 0);

                	myResults.close();

			for (File thisDir : userDirs) {
				if (thisDir.isDirectory() && !userNameSet.contains(thisDir.getName())) {
					if (doIt) {
						deleteDir(thisDir);
					} else {
						log.debug("need to delete directory " +thisDir);
					}
				}
			}
		} catch (Exception e) {
			log.debug("in exception of cleanupUserDirs", e);
		}
	}


	public void renameExperimentDirs () {
		
		log.info("in DirCleanup.renameExperimentDirs.");
                File [] userExperimentsDirs = getAllUserExperimentsDirs();

		try {
			for (int i=0; i<userExperimentsDirs.length; i++) {
				File userDatasetDir = new File(userExperimentsDirs[i].getParent() + "/Datasets");
				log.debug("need to rename dir " + userExperimentsDirs[i] + " to " + userDatasetDir);
				//userExperimentsDirs[i].renameTo(userDatasetDir);
				//boolean madeDir = userExperimentsDirs[i].mkdir();
				//log.debug("just created new Experiments dir " + madeDir);
				log.debug("about to create new dir " + userExperimentsDirs[i].getPath() + "/uploads");
				//boolean madeUploadDir = new File (userExperimentsDirs[i].getPath() + "/uploads").mkdir();
				//log.debug("just created new Experiments uploads dir " + madeUploadDir);
			}
		} catch (Exception e) {
			log.debug("in exception of renameExperimentDirs", e);
		}
	}

	public void createImageDirs () {
		
		log.info("in DirCleanup.createImageDirs.");
                File[] dirs = getAllUserDatasetMasterDirs();

		try {
			for (int i=0; i<dirs.length; i++) {
				String imagesDir = dirs[i] + "/Images";
				log.debug("about to make dir " + imagesDir);
				//boolean madeDir = (new File(imagesDir)).mkdir();
				File [] pngFiles = dirs[i].listFiles(new QCImagesFilter());
				for (int j=0; j<pngFiles.length; j++) {
					log.debug("about to rename file " + pngFiles[j] + " to " + imagesDir + "/" + pngFiles[j].getName());
					pngFiles[j].renameTo(new File(imagesDir + "/" + pngFiles[j].getName()));
				}
			}
		} catch (Exception e) {
			log.debug("in exception of createImageDirs", e);
		}
	}

	public File getThisUserDir (String userName) {
		//log.debug("in getThisUserDir for user " +userName);
                return getUserFilesDir().listFiles(new userName_Filter(userName))[0];
	}

	public File[] getAllUserDirs () {
                return getUserFilesDir().listFiles(new allUsers_Filter());
	}

	public File[] getAllUserExperimentUploadDirs () {
	
		File[] userExperimentDirs = getAllUserExperimentsDirs();
		List<File> dirList = new ArrayList<File>();

		for (int i=0; i<userExperimentDirs.length; i++) {
			if (userExperimentDirs[i].isDirectory()) { 
				//log.debug("now in user's experiment directory "+userExperimentDirs[i]);
				dirList.add(new File(userExperimentDirs[i] + "/uploads"));
			}
		}

                File[] dirArray = (File[]) myObjectHandler.getAsArray(dirList, File.class);

                return dirArray;
	}

	public File[] getAllUserExperimentsDirs () {
	
		File[] userDirs = getAllUserDirs();
		List<File> dirList = new ArrayList<File>();

		for (File thisDir : userDirs) {
			if (thisDir.isDirectory()) { 
				//log.debug("now in user's directory "+thisDir);
				dirList.add(new File(thisDir + "/Experiments"));
			}
		}

                File[] userExperimentsDirs = (File[]) myObjectHandler.getAsArray(dirList, File.class);
                return userExperimentsDirs;
	}

	public File[] getAllUserArraysDirs () {
	
		File[] userDirs = getAllUserDirs();
		List<File> dirList = new ArrayList<File>();

		for (File thisDir : userDirs) {
			if (thisDir.isDirectory()) { 
				//log.debug("now in user's directory "+thisDir);
				dirList.add(new File(thisDir + "/Arrays"));
			}
		}

                File[] userArraysDirs = (File[]) myObjectHandler.getAsArray(dirList, File.class);
                return userArraysDirs;
	}

	public File getThisUserDatasetDir (String userName) {
		//log.debug("in getThisUserDatasetDir for user "+userName);
		File userDir = getThisUserDir(userName);
		return new File(userDir + "/Datasets");
	}

	public File[] getAllUserDatasetDirs () {
	
		File[] userDirs = getAllUserDirs();
		List<File> dirList = new ArrayList<File>();

		for (File thisDir : userDirs) {
			if (thisDir.isDirectory()) { 
				//log.debug("now in user's directory "+thisDir);
				dirList.add(new File(thisDir + "/Datasets"));
			}
		}

                File[] userDatasetDirs = (File[]) myObjectHandler.getAsArray(dirList, File.class);
                log.debug("there are "+userDatasetDirs.length + " userDatatsetDirs");

                return userDatasetDirs;
	}

	public File[] getAllUserGeneListDirs () {

		log.debug("in getAllUserGeneListDirs");
	
		File[] userDirs = getAllUserDirs();
		List<File> dirList = new ArrayList<File>();

		for (File thisDir : userDirs) {
			if (thisDir.isDirectory()) { 
				//log.debug("now in user's directory "+thisDir);
				dirList.add(new File(thisDir + "/GeneLists"));
			}
		}

                File[] userGeneListDirs = (File[]) myObjectHandler.getAsArray(dirList, File.class);
                log.debug("there are "+userGeneListDirs.length + " userGeneListtDirs");

                return userGeneListDirs;
	}

	public File[] getAllUserGeneListAnalysisDirs() {
		log.debug("in getAllUserGeneListAnalysisDirs");
	
		File[] userGeneListDirs = getAllUserGeneListDirs();
		List<File> dirList = new ArrayList<File>();

		for (int i=0; i<userGeneListDirs.length; i++) {
			File [] analysisDirs = userGeneListDirs[i].listFiles(new AnalysisDirFilter());
                        if (analysisDirs != null && analysisDirs.length > 0) {
                                for (int j=0; j<analysisDirs.length; j++) {
                                        if (analysisDirs[j].isDirectory()) {
                                                dirList.add(analysisDirs[j]);
                                        }
                                }
                        }
		}

                File[] userGeneListAnalysisDirs = (File[]) myObjectHandler.getAsArray(dirList, File.class);

                log.debug("there are "+userGeneListAnalysisDirs.length + " userGeneListtAnalysisDirs");
                return userGeneListAnalysisDirs;
	}

	public File[] getThisUserDatasetMasterDirs(String userName) {
		//log.debug("in getThisUserDatasetMasterDirs for user "+userName);
	
		File userDatasetDir = getThisUserDatasetDir(userName);
		List<File> dirList = new ArrayList<File>();

		File [] masterDirs = userDatasetDir.listFiles(new MasterDirFilter());
		if (masterDirs != null && masterDirs.length > 0) {
                        for (File thisMasterDir : masterDirs) {
                                if (thisMasterDir.isDirectory()) {
                                        dirList.add(thisMasterDir);
				}
			}
		}

                File[] userDatasetMasterDirs = myObjectHandler.getAsArray(dirList, File.class);

                log.debug("there are "+userDatasetMasterDirs.length + " datatsetMasterDirs for this user: " + userName);
                return userDatasetMasterDirs;
	}

	public File[] getAllUserDatasetMasterDirs() {
	
		File[] userDatasetDirs = getAllUserDatasetDirs();
		List<File> dirList = new ArrayList<File>();

		for (File thisDir : userDatasetDirs) {
			File [] masterDirs = thisDir.listFiles(new MasterDirFilter());
                        if (masterDirs != null && masterDirs.length > 0) {
                                for (File thisMasterDir : masterDirs) {
                                        if (thisMasterDir.isDirectory()) {
                                                dirList.add(thisMasterDir);
                                        }
                                }
                        }
		}

                File[] userDatasetMasterDirs = myObjectHandler.getAsArray(dirList, File.class);

                log.debug("there are "+userDatasetMasterDirs.length + " userDatatsetMasterDirs");
                return userDatasetMasterDirs;
	}

	public File[] getAllUserDatasetMasterGroupingsDirs () {
	
		File[] userDatasetMasterDirs = getAllUserDatasetMasterDirs();
		List<File> dirList = new ArrayList<File>();

                if (userDatasetMasterDirs != null && userDatasetMasterDirs.length > 0) {
                        for (int i=0; i<userDatasetMasterDirs.length; i++) {
                                File [] groupingsDirs = userDatasetMasterDirs[i].listFiles(new GroupingsDirFilter());
                                if (groupingsDirs != null && groupingsDirs.length > 0) {
                                        for (int j=0; j<groupingsDirs.length; j++) {
                                                if (groupingsDirs[j].isDirectory()) {
                                                        dirList.add(groupingsDirs[j]);
                                                }
                                        }
                                }
                        }
                }

                File[] userDatasetMasterGroupingsDirs = myObjectHandler.getAsArray(dirList, File.class);

                log.debug("there are "+userDatasetMasterGroupingsDirs.length + " userDatatsetMasterGroupingsDirs");

                return userDatasetMasterGroupingsDirs;
	}

	public File[] getAllUserDatasetVersionDirs () {
	
		File[] userDatasetMasterDirs = getAllUserDatasetMasterDirs();
		List<File> dirList = new ArrayList<File>();

                if (userDatasetMasterDirs != null && userDatasetMasterDirs.length > 0) {
                        for (int i=0; i<userDatasetMasterDirs.length; i++) {
                                File [] versionDirs = userDatasetMasterDirs[i].listFiles(new VersionDirFilter());
                                if (versionDirs != null && versionDirs.length > 0) {
                                        for (int j=0; j<versionDirs.length; j++) {
                                                if (versionDirs[j].isDirectory()) {
                                                        dirList.add(versionDirs[j]);
                                                }
                                        }
                                }
                        }
                }

                File[] userDatasetVersionDirs = myObjectHandler.getAsArray(dirList, File.class);
                log.debug("there are "+userDatasetVersionDirs.length + " userDatatsetVersionDirs");

                return userDatasetVersionDirs;
	}

	public File[] getAllUserDatasetVersionCorrelationDirs () {
	
		File[] userDatasetVersionDirs = getAllUserDatasetVersionDirs();
		List<File> dirList = new ArrayList<File>();

                if (userDatasetVersionDirs != null && userDatasetVersionDirs.length > 0) {
                        for (int i=0; i<userDatasetVersionDirs.length; i++) {
                                File [] versionDirs = userDatasetVersionDirs[i].listFiles(new CorrelationDirFilter());
                                if (versionDirs != null && versionDirs.length > 0) {
                                        for (int j=0; j<versionDirs.length; j++) {
                                                if (versionDirs[j].isDirectory()) {
                                                        dirList.add(versionDirs[j]);
                                                }
                                        }
                                }
                        }
                }

                File[] userDatasetVersionCorrelationDirs = myObjectHandler.getAsArray(dirList, File.class);
                log.debug("there are "+userDatasetVersionCorrelationDirs.length + " userDatatsetVersionCorrelationDirs");

                return userDatasetVersionCorrelationDirs;
	}

	// Don't select any directories from public - 'cuz the Reference Files directory is in there
	public LinkedHashMap<String, String> getUserNameHash (String nonPublic) throws SQLException {
		
		log.info("in DirCleanup.getUserNameHash non-public.");

                String query = "select u.user_id, u.user_name "+
                        "from users u "+
			"where u.user_name != 'public' "+
                        "order by u.user_name";

		//log.debug("query = "+query);

		Results myResults = new Results(query, conn);
                LinkedHashMap<String, String> userNameHash = new ObjectHandler().getResultsAsLinkedHashMap(myResults);
                myResults.close();
		return userNameHash;
	}
		
	public LinkedHashMap<String, String> getUserNameHash () throws SQLException {
		
		log.info("in DirCleanup.getUserNameHash.");

                String query = "select u.user_id, u.user_name "+
                        "from users u "+
                        "order by u.user_name";

		//log.debug("query = "+query);

		Results myResults = new Results(query, conn);
                LinkedHashMap<String, String> userNameHash = new ObjectHandler().getResultsAsLinkedHashMap(myResults);
                myResults.close();
		return userNameHash;
	}

	public void cleanupDatasetDirs () {
		
		log.info("in DirCleanup.cleanupDatasetDirs.");

                String query = 
			"select replace(replace(replace(replace(name, '''', ''), '&', 'And'), ' ', ''), '/', '_')||'_Master' "+
			"from datasets "+
			"where created_by_user_id = ? "+
			"order by name";

		//log.debug("query = "+query);

		try {
                	LinkedHashMap<String, String> userNameHash = getUserNameHash();

			for (Iterator itr=userNameHash.keySet().iterator(); itr.hasNext();) {
				String userID = (String) itr.next();
				String userName = (String) userNameHash.get(userID);
				//log.debug("user = "+userName);
				File [] masterDirs = getThisUserDatasetMasterDirs(userName);

	                	Results myResults = new Results(query, Integer.parseInt(userID), conn);
                		Set dsNameSet = new ObjectHandler().getResultsAsSet(myResults, 0);
				log.debug("dsNameSet for user " + userName + " = "); myDebugger.print(dsNameSet);
                		myResults.close();

				for (File thisDir : masterDirs) {
					//log.debug("thisDir = "+thisDir);
					if (thisDir.isDirectory() && 
						!dsNameSet.contains(thisDir.getName())) {
						if (doIt) {
							deleteDir(thisDir);
						} else {
							log.debug("going to delete directory " + thisDir);
							log.debug("name is " + thisDir.getName());
						}
					}
				}
			}
		} catch (Exception e) {
			log.debug("in exception of cleanupDatasetDirs", e);
		}
	}

	public void cleanupDatasetVersionDirs () {
		
		log.info("in DirCleanup.cleanupDatasetVersionDirs.");

		try {
                	LinkedHashMap<String, String> userNameHash = getUserNameHash();

			for (Iterator itr=userNameHash.keySet().iterator(); itr.hasNext();) {
				String userID = (String) itr.next();
				User thisUser = new User().getUser(Integer.parseInt(userID), conn);
				String userName = (String) userNameHash.get(userID);
				String userMainDir = userFilesString + userName + "/";
				// have to do this so that getPublicDatasetPath works correctly
				thisUser.setUserMainDir(userMainDir);
				log.debug("userID = "+userID + ", and userName = "+userName);
				//log.debug("userMainDir = "+userMainDir);

				Dataset[] userDatasets = new Dataset().getAllDatasetsForUser(thisUser, conn);
				log.debug("userDatasets len = "+userDatasets.length);
				File [] masterDirs = getThisUserDatasetMasterDirs(userName);

				for (File thisDir : masterDirs) {
					//log.debug("thisDir = "+thisDir);
					for (Dataset thisDataset : userDatasets) {
						String thisDirString = thisDir + "/";
						//log.debug("thisDir = "+thisDir);
						//log.debug("expPath = "+thisDataset.getDatasetPath(userMainDir));
						if (thisDir.isDirectory() && 
							thisDirString.equals(thisDataset.getDatasetPath(userMainDir))) {
							File[] versionDirs = thisDir.listFiles();
							for (File thisVersionDir : versionDirs) {
								if (thisVersionDir.isDirectory() && thisVersionDir.getName().startsWith("v")) { 
									boolean goAhead= true;
									for (int m=0; m<thisDataset.getDatasetVersions().length; m++) {
										Dataset.DatasetVersion thisVersion = thisDataset.getDatasetVersions()[m];
										int version = thisVersion.getVersion();
										if (thisVersionDir.getName().equals("v" + version)) {
											//log.debug("versionDir = " + thisVersionDir.getName() + 
											//" equals? " + "v" + thisVersion.getVersion());
											goAhead= false;
											break;
										}
									}
									if (goAhead) {
										// versionDir is something like ~/userFiles/ckh/Datasets/DatasetName_Master/v1
										// analysisDir is something like ~/userFiles/ckh/GeneLists/DatasetName_v1_Analysis
										String analysisDir = 
											thisVersionDir.getPath().replace("Datasets", "GeneLists").replace("Master/", "") + "_Analysis";
										if (doIt) {
											deleteDir(thisVersionDir);
											deleteDir(new File(analysisDir));
										} else {
											log.debug("going to delete directories " + thisVersionDir + " and " + analysisDir);
										}
									}
								}
							}
						}
					}
				}
			}
		} catch (Exception e) {
			log.debug("in exception of cleanupDatasetVersionDirs", e);
		}
	}

	public void cleanupGeneListDirs () {
		
		log.info("in DirCleanup.cleanupGeneListDirs.");
                File [] userDirs = getUserFilesDir().listFiles();

		// Don't select any directories from public - 'cuz the Reference Files directory is in there

                String query = 
			"select distinct replace(replace(replace(replace(gene_list_name, '''', ''), '&', 'And'), ' ', ''), '/', '_') "+
			"from gene_lists gl, user_gene_lists glu "+
			"where (glu.user_id = ? or gl.created_by_user_id = ?) "+
			"and glu.gene_list_id = gl.gene_list_id "+
			"order by 1";

		String query2 = 
			"select replace(replace(replace(replace(ds.name, '''', ''), '&', 'And'), ' ', ''), '/', '_')||'_v'||dv.version||'_Analysis' "+
			"from datasets ds, dataset_versions dv "+
			"where created_by_user_id = ? "+
			"and ds.dataset_id = dv.dataset_id "+
			"order by ds.name, dv.version";

		//log.debug("query = "+query);
		//log.debug("query2 = "+query2);

		try {
                	LinkedHashMap<String, String> userNameHash = getUserNameHash("Non-public");

			for (Iterator itr=userNameHash.keySet().iterator(); itr.hasNext();) {
				String userID = (String) itr.next();
				String userName = (String) userNameHash.get(userID);

	                	Results myResults = new Results(query, new Object[] {Integer.parseInt(userID), Integer.parseInt(userID)}, conn);
                		Set glNameSet = new ObjectHandler().getResultsAsSet(myResults, 0);
                		myResults.close();

	                	Results myResults2 = new Results(query2, new Object[] {Integer.parseInt(userID)}, conn);
                		Set analysisSet = new ObjectHandler().getResultsAsSet(myResults2, 0);
                		myResults2.close();

				for (int i=0; i<userDirs.length; i++) {
					if (userDirs[i].getName().equals(userName)) {
						log.debug("now in user's directory "+userDirs[i]);
						File userGeneListsDir = new File(userDirs[i] + "/GeneLists");
						FilenameFilter nonAnalysisDirFilter = new NonAnalysisDirFilter();
						FilenameFilter analysisDirFilter = new AnalysisDirFilter();
						if (userGeneListsDir.isDirectory()) {
       	         					File [] nonAnalysisDirs = userGeneListsDir.listFiles(nonAnalysisDirFilter);
       	         					File [] analysisDirs = userGeneListsDir.listFiles(analysisDirFilter);
							for (int j=0; j<nonAnalysisDirs.length; j++) {
								if (nonAnalysisDirs[j].isDirectory() && 
									!nonAnalysisDirs[j].getName().equals("uploads") &&
									!nonAnalysisDirs[j].getName().equals("downloads") && 
									!glNameSet.contains(nonAnalysisDirs[j].getName())) {
									if (doIt) {
										deleteDir(nonAnalysisDirs[j]);
									} else {
										log.debug("need to delete non-analysis dir " + nonAnalysisDirs[j]); 
									}
								}
							}
							for (int j=0; j<analysisDirs.length; j++) {
								//log.debug("analysisDirs[j] = "+analysisDirs[j].getName());
								if (analysisDirs[j].isDirectory() && 
									!analysisDirs[j].getName().startsWith("Public") &&
									!analysisSet.contains(analysisDirs[j].getName())) {
									if (doIt) {
										deleteDir(analysisDirs[j]);
									} else {
										log.debug("need to delete analysis dir " + analysisDirs[j]); 
									}
								}
							}
						}
					}
				}
			}
		} catch (Exception e) {
			log.debug("in exception of cleanupGeneListDirs", e);
		}
	}



	public void createGroupRecords() throws SQLException {
/*
		System.out.println("in createGroupRecords");
		log.debug("in createGroupRecords");
		ParameterValue myParameterValue = new ParameterValue();

                String query = "select e.dataset_id, ev.version, pg.parameter_group_id, "+
			"nvl(substr(ev.version_name, "+
			"	instr(ev.version_name, '''') + 1, "+
			"	instr(ev.version_name, '''', 1, 2) - instr(ev.version_name, '''') -1), ev.version_name), "+
			"'Groups based on '||"+
			"nvl(substr(ev.version_name, "+
			"	instr(ev.version_name, ''''), "+
			"	instr(ev.version_name, '''', 1, 2) - instr(ev.version_name, ''''))||'''', ev.version_name) "+
                        "from parameter_groups pg, experiments e, experiment_versions ev "+
                        "where ev.dataset_id = e.dataset_id "+
			"and pg.dataset_id = ev.dataset_id "+
			"and pg.version = ev.version "+
			"and pg.master = 1 "+
                        "order by e.exp_name, ev.version";

		log.debug("query = "+query);
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(query);
		conn.setAutoCommit(false);

                while (rs.next()) {
			log.debug("dataset_id = "+rs.getInt(1) + "version = "+rs.getInt(2) + ", and masterPGID = " + rs.getInt(3));
			OLDExperiment thisExperiment = new OLDExperiment().getIniaExperiment(rs.getInt(1), conn);
log.debug("thisExpement expID = "+thisExperiment.getExp_id());

                        ParameterValue[] myMasterParams = myParameterValue.getParameterValues(rs.getInt(3), conn);
			log.debug("myMasterParams = "); myDebugger.print(myMasterParams);
			LinkedHashMap<String, String> rungroupValues = new LinkedHashMap<String, String>();
			LinkedHashMap<String, String> rungroupLabels = new LinkedHashMap<String, String>();
			for (int i=0; i<myMasterParams.length; i++) {
				if (myMasterParams[i].getCategory().equals("Rungroup")) {
					rungroupValues.put(myMasterParams[i].getParameter(), myMasterParams[i].getValue());
				} else if (myMasterParams[i].getCategory().equals("Rungroup Label")) {
					rungroupLabels.put(myMasterParams[i].getParameter(), myMasterParams[i].getValue());
				}
			}
			rungroupLabels.put("0", "Exclude");
			Experiment newExperiment = new Experiment(rs.getInt(1));
			int groupingID = newExperiment.checkGroupingExists(rungroupValues, conn);
			log.debug("groupingID=  "+groupingID);
			// No grouping was found
			try {
				if (groupingID == -99) { 
					// create a grouping with the version_name as the criterion and also name
					groupingID = newExperiment.createGrouping(rs.getString(4), rs.getString(5), conn);
					//
					// go through the 'Rungroup' parameters and get the group_nums, 
					//create the groups, then create the chip_groups
					//
					for (Iterator itr=rungroupValues.keySet().iterator(); itr.hasNext();) {
						String user_chip_id = (String) itr.next();
						String group_num = (String) rungroupValues.get(user_chip_id);
						int group_id = newExperiment.createGroup(groupingID, Integer.parseInt(group_num), (String) rungroupLabels.get(group_num), conn); 
						newExperiment.createChip_group(Integer.parseInt(user_chip_id), group_id, conn);
					}
				}
                		query = "update experiment_versions "+
                        		"set grouping_id = "+groupingID + " "+
                        		"where dataset_id = "+ rs.getInt(1) + " "+
					"and version = " + rs.getInt(2);

				log.debug("query = "+query);
                		Statement stmt2 = conn.createStatement();
                		stmt2.executeUpdate(query);
                	//	conn.createStatement().executeUpdate(query);
				myParameterValue.deleteParameterValuesByCategory(rs.getInt(3), "Rungroup", conn);
				myParameterValue.deleteParameterValuesByCategory(rs.getInt(3), "Rungroup Label", conn);

                		query = "select pg.parameter_group_id "+
                        		"from parameter_groups pg "+
                        		"where pg.dataset_id = "+ rs.getInt(1) + " "+
					"and pg.version = " + rs.getInt(2) + " "+
					"and pg.master = 0";
				log.debug("query = "+query);
                		Statement stmt3 = conn.createStatement();
                		ResultSet rs2 = stmt3.executeQuery(query);
                		//ResultSet rs2 = conn.createStatement().executeQuery(query);
                		while (rs2.next()) {
					myParameterValue.deleteParameterValuesByCategory(rs2.getInt(1), "Rungroup", conn);
					myParameterValue.deleteParameterValuesByCategory(rs2.getInt(1), "Rungroup Label", conn);
				}
				stmt2.close();
				stmt3.close();
				conn.commit();
			} catch (Exception e) {
				log.debug("Error creating group and grouping records", e);
				System.out.println("UHOH!  There was an ERROR creating group and grouping records for expID = " + rs.getInt(1) +
					" and version = "+rs.getInt(2));
				conn.rollback();
			}
		}
		stmt.close();
*/
	}

	public void createGroupFiles() throws SQLException, IOException, RException {
/*
		System.out.println("in createGroupFiles");
		ParameterValue myParameterValue = new ParameterValue();

                String query = "select u.user_name, e.dataset_id, ev.version, pg.parameter_group_id "+
                        "from users u, experiments e, experiment_versions ev, parameter_groups pg "+
                        "where ev.dataset_id = e.dataset_id "+
			"and u.user_id = e.created_by_user_id "+
			"and pg.dataset_id = ev.dataset_id "+
			"and pg.version = ev.version "+
			"and pg.master = 1 "+
                        "order by u.user_name, e.exp_name, ev.version";

		log.debug("query = "+query);
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(query);

                while (rs.next()) {
			log.debug("dataset_id = "+rs.getInt(2) + "version = "+rs.getInt(3));
                        String userMainDir = userFilesString + rs.getString(1) + "/";
			OLDExperiment thisExperiment = new OLDExperiment().getIniaExperiment(rs.getInt(2), userMainDir, conn);
			OLDExperiment.OLDExperimentVersion thisExperimentVersion = thisExperiment.getExperimentVersion(rs.getInt(3));
                        String experimentDir = thisExperiment.getPath() + "/"; 
			log.debug("creating file for "+ thisExperiment.getExp_name() + "/v"+ thisExperimentVersion.getVersion());
			if (!thisExperimentVersion.getVersion_path().endsWith("-99")) {

                        	ParameterValue[] myGroups = myParameterValue.getParameterValues(rs.getInt(4), conn);
                        	String groupHeader = "grp.number\t" + "grp.name\n";
                        	String groupVals = "";
                        	for (int i=0; i<myGroups.length; i++) {
                                	if (myGroups[i].getCategory().equals("Rungroup Label")) {
                                        	groupVals = groupVals + myGroups[i].getParameter() + "\t" +
                                                        	myGroups[i].getValue().replaceAll("[\\s]", "_") + "\n";
                                	}
                        	}
                        	groupVals = groupHeader + groupVals + "\n";
                        	myFileHandler.writeFile(groupVals, thisExperimentVersion.getVersion_path() + "groups.txt");
			}
                }
*/
	}

	public void createDownloadPhenotypeFiles() throws SQLException, IOException, RException {
/*
		System.out.println("in createDownloadPhenotypeFiles");
		ParameterValue myParameterValue = new ParameterValue();

                String query = "select u.user_name, e.dataset_id, ev.version "+
                        "from users u, experiments e, experiment_versions ev "+
                        "where ev.dataset_id = e.dataset_id "+
			"and u.user_id = e.created_by_user_id "+
                        "order by u.user_name, e.exp_name, ev.version";

		log.debug("query = "+query);
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(query);

                while (rs.next()) {
			log.debug("dataset_id = "+rs.getInt(2) + "version = "+rs.getInt(3));
                        String userMainDir = userFilesString + rs.getString(1) + "/";
			OLDExperiment thisExperiment = new OLDExperiment().getIniaExperiment(rs.getInt(2), userMainDir, conn);
			OLDExperiment.OLDExperimentVersion thisExperimentVersion = thisExperiment.getExperimentVersion(rs.getInt(3));
                        String experimentDir = thisExperiment.getPath() + "/"; 
			log.debug("creating file for "+ thisExperiment.getExp_name() + "/v"+ thisExperimentVersion.getVersion());
			ParameterValue[] myPhenotypeValues = myParameterValue.getPhenotypeValuesForOLDExpVersion(
				thisExperiment.getExp_id(),
				thisExperimentVersion.getVersion(),
				conn);
			String userName = "";
			String phenotypeName = "";
			if (myPhenotypeValues != null) {
				// First get all the unique parameterGroupIDs
				List<String> pgIDs = new ArrayList<String>();
				for (int i=0; i<myPhenotypeValues.length; i++) {
					if (myPhenotypeValues[i].getParameter().equals("User ID")) {	
						pgIDs.add(Integer.toString(myPhenotypeValues[i].getParameter_group_id()));		
					}	
				}
				Iterator itr = pgIDs.iterator();
				while (itr.hasNext()) {
					// This method no longer exists
					ParameterValue[] thisPhenotypeValues = myParameterValue.getPhenotypeValuesForParameterGroup(
						myPhenotypeValues,
						Integer.parseInt((String) itr.next()));
					for (int i=0; i<thisPhenotypeValues.length; i++) {
						if (thisPhenotypeValues[i].getParameter().equals("User ID")) {	
							userName = new User().getUser_name(Integer.parseInt(thisPhenotypeValues[i].getValue()), conn);
						} else if (thisPhenotypeValues[i].getParameter().equals("Name")) {
							phenotypeName = thisPhenotypeValues[i].getValue();
						}	
					}
					File downloadPhenotypeFile = new File(thisExperimentVersion.getPhenotypeDownloadFileName(userName, phenotypeName)); 
					log.debug("creating file "+downloadPhenotypeFile.getPath());
                        		downloadPhenotypeFile.createNewFile();

                        		BufferedWriter fileListingWriter =
                                        		new BufferedWriter(new FileWriter(downloadPhenotypeFile), 10000);

					for (int i=0; i<thisPhenotypeValues.length; i++) {
						if (thisPhenotypeValues[i].getCategory().equals("Phenotype Rungroup Value")) {	
							fileListingWriter.write(thisPhenotypeValues[i].getParameter() + "\t" + 
									thisPhenotypeValues[i].getValue());
                                			fileListingWriter.newLine();
                        			}
					}
                        		fileListingWriter.flush();
                        		fileListingWriter.close();
				}
			}
		}
*/
	}

	public void renameUpstreamFiles() throws SQLException, IOException, RException {
		System.out.println("in renameUpstreamFiles");

                String query = "select u.user_name, to_char(gla.create_date, 'MMddyyyy_hh24miss'), gl.gene_list_name, pv.value "+
                        "from gene_list_analyses gla, users u, gene_lists gl, parameter_values pv "+
                        "where gla.gene_list_id = gl.gene_list_id "+
                        "and gla.user_id = u.user_id "+
			"and pv.parameter_group_id = gla.parameter_group_id "+
			"and pv.parameter = 'Sequence Length' "+
			"and pv.category = 'Upstream Extraction'";

		log.debug("query = "+query);
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(query);

                while (rs.next()) {
			String createDate = rs.getString(2); 
			String glNameNoSpaces = new ObjectHandler().removeBadCharacters(rs.getString(3)); 
			String length = rs.getString(4); 
                        String userUpstreamDir = userFilesString + rs.getString(1) + "/GeneLists/" + 
					glNameNoSpaces + "/UpstreamExtraction/";
			log.debug("userUpstreamDir = "+userUpstreamDir);
			File upstreamFile = new File(userUpstreamDir + glNameNoSpaces + "_" + length + "bp.fasta.txt");
			if (upstreamFile.exists()) {
				String newFileName = userUpstreamDir + glNameNoSpaces + "_" + createDate + "_" + length + "bp.fasta.txt";
				log.debug("file exists.  going to rename it to " + newFileName);
				upstreamFile.renameTo(new File(newFileName));
			} else {
				log.debug("file does not exist.  name is :" + upstreamFile.toString());
			}
		}
	}

	public void fixCodeLinkFiles() throws SQLException, IOException, RException {
/*
		System.out.println("in fixCodeLinkFiles");

                String query = "select u.user_name, e.dataset_id, e.exp_name, e.qc_complete "+
                        "from users u, experiments e "+
                        "where u.user_id = e.created_by_user_id "+
			"and e.create_date < to_date('20-NOV-2007', 'dd-mon-yyyy') "+
                        "and platform = 'CodeLink' "+
                        "order by u.user_name, e.qc_complete";

                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(query);
		edu.ucdenver.ccp.PhenoGen.data.Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();

                while (rs.next()) {
                        String userName = rs.getString(1);
                        String userMainDir = userFilesString + userName + "/";
                        String arrayDir = userMainDir + "Arrays";
			Experiment thisExperiment = new Experiment().getIniaExperiment(rs.getInt(2), userMainDir, conn);
                        String experimentDir = thisExperiment.getPath() + "/"; 
			if (experimentDir.indexOf("SabaL/Experiments/IHASandILASrats_Master") > 0 ||  //ERROR
				experimentDir.indexOf("SabaL/Experiments/Redo(BNLxandSHR)_Master") > 0 || //ERROR
				experimentDir.indexOf("bhaves/Experiments/IHASandILAStestJuly06_Master") > 0 || //ERROR
				experimentDir.indexOf("bhaves/Experiments/IHASandILASTestExptJuly06_Master") > 0  //ERROR
			) {
				log.debug("\n");
				log.debug("Starting " + thisExperiment.getExp_name() + "\n");
	                        String experimentPlatform = thisExperiment.getPlatform(); 
       	                 	String experimentNameNoSpaces = thisExperiment.getExpNameNoSpaces();
				String miameHybridIds = thisExperiment.getExperimentHybridIDs(conn);
				//log.debug("miameHybridIds = "+miameHybridIds);
				edu.ucdenver.ccp.PhenoGen.data.Array[] myArrays = myArray.getMiameArraysForExperiment(miameHybridIds, miameConn);
                        	String fileListing = experimentNameNoSpaces + ".arrayFiles.txt";

                        	log.debug("fileListingName = " + fileListing);
                        	//log.debug("there are " + myArrays.length + " arrays in this experiment ");

                        	File fileListingFile = new File(experimentDir + fileListing);
                        	fileListingFile.createNewFile();

                        	BufferedWriter fileListingWriter =
                                        new BufferedWriter(new FileWriter(fileListingFile), 10000);

                        	for (int i=0; i<myArrays.length; i++) {

                                	String fileName = myArrays[i].getFile_name();
                                	String arrayName = myArrays[i].getHybrid_name().replaceAll("[\\s]", "_");
					fileListingWriter.write(fileName+ "\t" + arrayName);
                                	fileListingWriter.newLine();
                        	}
                        	fileListingWriter.flush();
                        	fileListingWriter.close();
				String[] rErrorMsg = runCodeLinkImport(experimentDir, arrayDir, userName);
				if (rErrorMsg == null || rErrorMsg.length == 0) {
					runCodeLinkQC(experimentDir, arrayDir, userName, rs.getString(4));
					runCodeLinkNormalization(experimentDir, userName);
				}
			} else if (experimentDir.indexOf("SabaL/Experiments/TestingQCforCodeLink_Master") > 0 ||  
				experimentDir.indexOf("SabaL/Experiments/TestingQCforCodeLink_Master") > 0 
			) {  
				continue;
			}
		}
*/
	}

	public String[] runCodeLinkImport (String experimentDir, String arrayDir, String userName) throws IOException, RException {
		File importTxtFile = new File(experimentDir + "call_CodeLink.ImportTxt");
		String [] rErrorMsg = null;
		if (!userName.equals("public") && importTxtFile.exists()) {
			String newImportFileName = experimentDir + "call_CodeLink.Import";
			File newImportFile = new File(newImportFileName);
                        BufferedWriter fileListingWriter =
                                       new BufferedWriter(new FileWriter(newImportFile), 10000);
			String[] fileContents = myFileHandler.getFileContents(importTxtFile);
			for (int i=0; i<fileContents.length; i++) {
				if (fileContents[i].startsWith("CodeLink.ImportTxt")) {
					fileContents[i] = fileContents[i].replaceAll("CodeLink.PhenoData.txt", "arrayFiles.txt"); 
					fileContents[i] = fileContents[i].replaceAll("path", "export.path"); 
					fileContents[i] = fileContents[i].substring(0, fileContents[i].indexOf("arrayDataObject")) +
							"arrayDataObject = 'Combine.BioC.Binary.Rdata', " +
							"import.path = '"+arrayDir + "')";
					int startIdx = fileContents[i].indexOf("export.path = '" + experimentDir);
					int endIdx = fileContents[i].indexOf("phenoDataFile");
					if (startIdx < 0) {
						fileContents[i] = fileContents[i].substring(0, fileContents[i].indexOf("export.path")) +
								"export.path = '" + experimentDir +
								"', " +
								fileContents[i].substring(endIdx);
					}
				}
                                fileContents[i] = fileContents[i].replaceAll("webapps/INIATEST", "webapps/PhenoGenTEST"); 
				fileContents[i] = fileContents[i].replaceAll("CodeLink.ImportTxt", "CodeLink.Import"); 
				fileListingWriter.write(fileContents[i] + "\n");
			}
                        fileListingWriter.flush();
                        fileListingWriter.close();
			log.debug("getting ready to run Import on "+experimentDir);
                	try {
                        	rErrorMsg = myR_session.runR(newImportFileName, experimentDir);
				if (rErrorMsg != null && rErrorMsg.length > 0) {
                                	log.debug("ERROR when running Import on "+experimentDir);
                                        for (int y=0; y<rErrorMsg.length; y++) {
                               			log.debug(rErrorMsg[y]);
                                        }
				}
				return rErrorMsg;

                	} catch (RException e) {
				log.debug("got R ERROR when running ImportFile in " + experimentDir, e);
				throw e;
                	}
		}
		return rErrorMsg;
	}

	public void runCodeLinkQC(String experimentDir, String arrayDir, String userName, String qc_complete) throws IOException, RException {
		File QCFile = new File(experimentDir + "call_CodeLink.QC");
		if (!userName.equals("public") && QCFile.exists()) {
			myFileHandler.copyFile(QCFile, new File(experimentDir + "/" + "call_CodeLink.QC.pre3_4"));
			String newQCFileName = experimentDir + "call_CodeLink.QC.new";
			File newQCFile = new File(newQCFileName);
                        BufferedWriter fileListingWriter =
                                       new BufferedWriter(new FileWriter(newQCFile), 10000);
			String[] fileContents = myFileHandler.getFileContents(QCFile);
			for (int i=0; i<fileContents.length; i++) {
                                fileContents[i] = fileContents[i].replaceAll("webapps/INIATEST", "webapps/PhenoGenTEST"); 
				if (fileContents[i].startsWith("CodeLink.QC")) {
                                       fileContents[i] = "CodeLink.QC(path = '"+
								arrayDir + "', " +
								"InputDataFile = '"+
								experimentDir +
								"Combine.BioC.Binary.Rdata' , "+
								"graphics = " +
								(qc_complete.equals("Y") ? "TRUE" : "FALSE") + 
								")" + 
								"\n";
				}
                                fileListingWriter.write(fileContents[i] + "\n");
			}
                        fileListingWriter.flush();
                        fileListingWriter.close();
			log.debug("getting ready to run QC on "+experimentDir);
                	try {
                        	String[] rErrorMsg = myR_session.runR(newQCFileName, experimentDir);
				if (rErrorMsg != null && rErrorMsg.length > 0) {
                                	log.debug("ERROR when running QC on "+experimentDir);
                                        for (int y=0; y<rErrorMsg.length; y++) {
                               			log.debug(rErrorMsg[y]);
                                        }
				}
                	} catch (RException e) {
				log.debug("got R ERROR when running QC in " + experimentDir, e);
				throw e;
                	}
			newQCFile.renameTo(new File(experimentDir + "call_CodeLink.QC"));
			new File(experimentDir + "call_CodeLink.QC.new.Rout").renameTo(new File(experimentDir + "call_CodeLink.QC.Rout"));
		}
	}
	public void runCodeLinkNormalization (String experimentDir, String userName) throws IOException, RException {
		//log.debug("in runCodeLinkNormalization");
       	        File [] versionDirs = new File(experimentDir).listFiles(new VersionDirFilter());
		//log.debug(" there are " + versionDirs.length + " version directories");
		for (int z=0; z<versionDirs.length; z++) {
			String versionDirName = versionDirs[z].getPath();
			String groupingVar = "";
			File normalizationFile = new File(versionDirName + "/call_CodeLink.Normalization");
			File exportOutFile = new File(versionDirName + "/call_CodeLink.ExportOutBioC");
			if (!userName.equals("public") && normalizationFile.exists() && exportOutFile.exists()) {
				myFileHandler.copyFile(normalizationFile, new File(versionDirName + "/" + "call_CodeLink.Normalization.pre3_4"));
				log.debug(" normalizationFile = " + normalizationFile.getPath());
				String newNormalizationFileName = versionDirName + "/call_CodeLink.Normalization.new";
				File newNormalizationFile = new File(newNormalizationFileName);
                        	BufferedWriter fileListingWriter =
                                       	new BufferedWriter(new FileWriter(newNormalizationFile), 10000);
				String[] fileContents = myFileHandler.getFileContents(normalizationFile);
				String[] exportOutFileContents = myFileHandler.getFileContents(exportOutFile);
				//log.debug("there are "+exportOutFileContents.length + " lines in the export File");
				for (int i=0; i<exportOutFileContents.length; i++) {
					if (exportOutFileContents[i] != null && 
						!exportOutFileContents[i].equals("") && 
						exportOutFileContents[i].startsWith("CodeLink.ExportOut")) {
						String[] functionArgs = exportOutFileContents[i].split(", [\\D]");
						//log.debug("there are "+functionArgs.length + " arguments in the export File");
						//new Debugger().print(functionArgs);
						for (int g=0; g<functionArgs.length; g++) {
							if (functionArgs[g].indexOf("rouping") > -1) {
								groupingVar = "g" + functionArgs[g] + ", ";
							}
						}
						//log.debug("groupingVar for dataset "+versionDirName + " is " + groupingVar);
					}
				}
				//log.debug("there are "+fileContents.length + " lines in the normalization File");
				for (int i=0; i<fileContents.length; i++) {
					//log.debug("fileContents[i] " + fileContents[i]);
					if (fileContents[i].indexOf("norm.para2") > -1) {
						int startIdx = fileContents[i].indexOf("norm.para2");
						int endIdx = fileContents[i].indexOf("output.binary");
                                       		fileContents[i] = fileContents[i].substring(0, startIdx) + 
								groupingVar + 
								fileContents[i].substring(endIdx);
					}
					if (fileContents[i].indexOf("output.excel") > -1) {
						int startIdx = fileContents[i].indexOf("output.excel");
                                       		fileContents[i] = fileContents[i].substring(0, startIdx - 2) + 
								")" + "\n";	
					}
                                       	fileContents[i] = fileContents[i].replaceAll("CodeLink.Normalization.output.Rdata", "CodeLink.ExportOutBioC.output.Rdata"); 
                                       	fileContents[i] = fileContents[i].replaceAll("CodeLink.ImportTxt.output.Rdata", "Combine.BioC.Binary.Rdata"); 
                                       	fileContents[i] = fileContents[i].replaceAll("output.binary", "OutputFile"); 
                                       	fileContents[i] = fileContents[i].replaceAll("output.text", "output.csv"); 
                                       	fileContents[i] = fileContents[i].replaceAll("\\.tab", ".csv"); 
                                	fileContents[i] = fileContents[i].replaceAll("webapps/INIATEST", "webapps/PhenoGenTEST"); 
                                       	fileListingWriter.write(fileContents[i] + "\n");
				}
                        	fileListingWriter.flush();
                        	fileListingWriter.close();
				log.debug("getting ready to run Normalization on "+versionDirName);
                		try {
                        		String[] rErrorMsg = myR_session.runR(newNormalizationFileName, versionDirName);
					if (rErrorMsg != null && rErrorMsg.length > 0) {
                                		log.debug("ERROR when running normalization on "+versionDirName);
                                        	for (int y=0; y<rErrorMsg.length; y++) {
                               				log.debug(rErrorMsg[y]);
                                        	}
					}
                		} catch (RException e) {
					log.debug("got R ERROR when running NormalizationFile in " + versionDirName, e);
					throw e;
                		}
				newNormalizationFile.renameTo(new File(versionDirName + "/" + "call_CodeLink.Normalization"));
				new File(versionDirName + "/" + "call_CodeLink.Normalization.new.Rout").renameTo(new File(versionDirName + "/" + "call_CodeLink.Normalization.Rout"));
			}
		}
	}

	public void runAffymetrixQC(String experimentDir, String userName, String qc_complete) throws IOException, RException {
		File QCSummaryFile = new File(experimentDir + "call_Affy.QC.Summary");
		File QCSummaryFile2 = new File(experimentDir + "call_Affy.affyPLM");
		String newQCSummaryFileName = experimentDir + "call_Affymetrix.QC";
		boolean keepGoing = true;
		if (!userName.equals("public") && QCSummaryFile.exists()) {
			File newQCSummaryFile = new File(newQCSummaryFileName);
                        BufferedWriter fileListingWriter =
                                       new BufferedWriter(new FileWriter(newQCSummaryFile), 10000);
			String[] fileContents = myFileHandler.getFileContents(QCSummaryFile);
			for (int i=0; i<fileContents.length; i++) {
                                       fileContents[i] = fileContents[i].replaceAll("webapps/INIATEST", "webapps/PhenoGenTEST"); 
                                       fileListingWriter.write(fileContents[i].replaceAll("Affy.QC.Summary", "Affymetrix.QC") + "\n");
			}
                        fileListingWriter.flush();
                        fileListingWriter.close();
		} else if (!userName.equals("public") && QCSummaryFile2.exists()) {
			File newQCSummaryFile = new File(newQCSummaryFileName);
                        BufferedWriter fileListingWriter =
                                       new BufferedWriter(new FileWriter(newQCSummaryFile), 10000);
			String[] fileContents = myFileHandler.getFileContents(QCSummaryFile2);
			for (int i=0; i<fileContents.length; i++) {
                                fileContents[i] = fileContents[i].replaceAll("webapps/INIATEST", "webapps/PhenoGenTEST"); 
				fileContents[i] = fileContents[i].replaceAll("Affy.affyPLM", "Affymetrix.QC"); 
				if (fileContents[i].startsWith("Affymetrix.QC")) {
                                	fileContents[i] = fileContents[i].substring(0, fileContents[i].indexOf("pset.binary")) +
								"Summary.Figure = '" +
								experimentDir + "Summary.Figure.png', "+
								"graphics = " +
								(qc_complete.equals("Y") ? "TRUE" : "FALSE") + 
								", MAplotStats = '" + 
								experimentDir + "MAstats.txt')";
				}
				fileListingWriter.write(fileContents[i]+ "\n");
			}
                        fileListingWriter.flush();
                        fileListingWriter.close();
		} else {
			log.debug("ERROR -- no QC.Summary or affy.PLM file found");
			keepGoing = false;
		}
		if (keepGoing) {
			log.debug("getting ready to run QC on "+experimentDir);
                	try {
                        	String[] rErrorMsg = myR_session.runR(newQCSummaryFileName, experimentDir);
				if (rErrorMsg != null && rErrorMsg.length > 0) {
                                	log.debug("ERROR when running QC on "+experimentDir);
                                        for (int y=0; y<rErrorMsg.length; y++) {
                               			log.debug(rErrorMsg[y]);
                                        }
				}
                	} catch (RException e) {
				log.debug("got R ERROR when running QC in " + experimentDir, e);
				throw e;
                	}
		}
	}
	public String[] runAffymetrixImport (String experimentDir, String userName) throws IOException, RException {
		File importCELExportBioCFile = new File(experimentDir + "call_Affy.ImportCELExportBioC");
                String[] rErrorMsg = null;
		if (!userName.equals("public") && importCELExportBioCFile.exists()) {
			String newImportFileName = experimentDir + "call_Affymetrix.Import";
			File newImportFile = new File(newImportFileName);
                        BufferedWriter fileListingWriter =
                                       new BufferedWriter(new FileWriter(newImportFile), 10000);
			String[] fileContents = myFileHandler.getFileContents(importCELExportBioCFile);
			for (int i=0; i<fileContents.length; i++) {
                                       fileContents[i] = fileContents[i].replaceAll("Affy.ImportCELExportBioC", "Affymetrix.Import"); 
                                       fileContents[i] = fileContents[i].replaceAll("CEL.files.txt", "arrayFiles.txt"); 
                                       fileContents[i] = fileContents[i].replaceAll("Datasets", "Arrays"); 
                                	fileContents[i] = fileContents[i].replaceAll("webapps/INIATEST", "webapps/PhenoGenTEST"); 
                                       if (fileContents[i].startsWith("Affymetrix.Import") && fileContents[i].indexOf("RawDataFile") < 0) {
                                                fileContents[i] = fileContents[i].substring(0, fileContents[i].length() - 1) +
                                                                ", RawDataFile = 'Combine.BioC.Binary')";
						int startIdx = fileContents[i].indexOf("export.path = '" + experimentDir);
						int endIdx = fileContents[i].indexOf("FileListing");
						if (startIdx < 0) {
							fileContents[i] = fileContents[i].substring(0, fileContents[i].indexOf("export.path")) +
								"export.path = '" + experimentDir +
								"', " +
								fileContents[i].substring(endIdx);
						}
                                        }
                                       fileListingWriter.write(fileContents[i] + "\n");
			}
                        fileListingWriter.flush();
                        fileListingWriter.close();
			log.debug("getting ready to run Import on "+experimentDir);
                	try {
                        	rErrorMsg = myR_session.runR(newImportFileName, experimentDir);
				if (rErrorMsg != null && rErrorMsg.length > 0) {
                                	log.debug("ERROR when running Import on "+experimentDir);
                                        for (int y=0; y<rErrorMsg.length; y++) {
                               			log.debug(rErrorMsg[y]);
                                        }
				}
				return rErrorMsg;
                	} catch (RException e) {
				log.debug("got R ERROR when running ImportFile in " + experimentDir, e);
				throw e;
                	}
		}
		return rErrorMsg;
	}
	public void runAffymetrixNormalization (String experimentDir, String userName) throws IOException, RException {
		//log.debug("in runAffymetrixNormalization");
       	        File [] versionDirs = new File(experimentDir).listFiles(new VersionDirFilter());
		//log.debug(" there are " + versionDirs.length + " version directories");
		for (int z=0; z<versionDirs.length; z++) {
			String versionDirName = versionDirs[z].getPath();
			String groupingVar = "";
			File bioCNormalizationFile = new File(versionDirName + "/call_Affy.BioC.Normalization");
			//log.debug(" bioCNormalizationFile = " + bioCNormalizationFile.getPath());
			File exportOutFile = new File(versionDirName + "/call_Affy.ExportOutBioC");
			if (!userName.equals("public") && bioCNormalizationFile.exists() && exportOutFile.exists()) {
				//log.debug(" bioCNormalizationFile exists");
				String newNormalizationFileName = versionDirName + "/call_Affymetrix.Normalization";
				File newNormalizationFile = new File(newNormalizationFileName);
                        	BufferedWriter fileListingWriter =
                                       	new BufferedWriter(new FileWriter(newNormalizationFile), 10000);
				String[] fileContents = myFileHandler.getFileContents(bioCNormalizationFile);
				String[] exportOutFileContents = myFileHandler.getFileContents(exportOutFile);
				//log.debug("there are "+exportOutFileContents.length + " lines in the export File");
				for (int i=0; i<exportOutFileContents.length; i++) {
					if (exportOutFileContents[i] != null && 
						!exportOutFileContents[i].equals("") && 
						exportOutFileContents[i].startsWith("Affy.ExportOut")) {
						String[] functionArgs = exportOutFileContents[i].split(", [\\D]");
						//log.debug("there are "+functionArgs.length + " arguments in the export File");
						//new Debugger().print(functionArgs);
						for (int g=0; g<functionArgs.length; g++) {
							if (functionArgs[g].indexOf("rouping") > -1) {
								groupingVar = "g" + functionArgs[g] + ", ";
							}
						}
						//log.debug("groupingVar for dataset "+versionDirName + " is " + groupingVar);
					}
				}
				//log.debug("there are "+fileContents.length + " lines in the normalization File");
				for (int i=0; i<fileContents.length; i++) {
					//log.debug("fileContents[i] " + fileContents[i]);
                                        if (fileContents[i].indexOf("OutputAbsCallFile") > -1) {
                                                int startIdx = fileContents[i].indexOf("OutputAbsCallFile");
                                                int endIdx = fileContents[i].indexOf("OutputTabDelimitedFile");
                                                fileContents[i] = fileContents[i].substring(0, startIdx) +
                                                                fileContents[i].substring(endIdx);
                                        }
					if (fileContents[i].indexOf("OutputExcelFile") > -1) {
						int startIdx = fileContents[i].indexOf("OutputExcelFile");
						int endIdx = fileContents[i].indexOf("normalize.method");
                                       		fileContents[i] = fileContents[i].substring(0, startIdx) + 
								groupingVar + 
								fileContents[i].substring(endIdx); 
						if (fileContents[i].indexOf("FileListing") > -1) {
                                       			fileContents[i] = fileContents[i].substring(0, fileContents[i].indexOf("FileListing")) + 
								"InputDataFile = '"+
								experimentDir +
								"Combine.BioC.Binary.Rdata')";
						}
					}
                                       	fileContents[i] = fileContents[i].replaceAll("Affy.BioC.Normalization.output.Rdata", "Affymetrix.ExportOutBioC.output.Rdata"); 
                                       	fileContents[i] = fileContents[i].replaceAll("Affy.BioC.Normalization", "Affymetrix.Normalization"); 
                                       	fileContents[i] = fileContents[i].replaceAll("OutputCombinedBioCFile", "OutputFile"); 
                                       	fileContents[i] = fileContents[i].replaceAll("OutputTabDelimitedFile", "OutputCSVFile"); 
                                       	fileContents[i] = fileContents[i].replaceAll("\\.tab", ".csv"); 
                                	fileContents[i] = fileContents[i].replaceAll("webapps/INIATEST", "webapps/PhenoGenTEST"); 

					if (fileContents[i].startsWith("Affymetrix.Normalization")) {
						int startIdx = fileContents[i].indexOf("OutputFile = '" + versionDirName);
						int endIdx = fileContents[i].indexOf("OutputCSVFile");
						if (startIdx < 0) {
							fileContents[i] = fileContents[i].substring(0, fileContents[i].indexOf("OutputFile")) +
								"OutputFile = '" + versionDirName +
								"/Affymetrix.ExportOutBioC.output.Rdata', " +
								fileContents[i].substring(endIdx);
						}
						startIdx = fileContents[i].indexOf("OutputCSVFile = '" + versionDirName);
						endIdx = fileContents[i].indexOf("grouping");
						if (startIdx < 0) {
							fileContents[i] = fileContents[i].substring(0, fileContents[i].indexOf("OutputCSVFile")) +
								"OutputCSVFile = '" + versionDirName +
								"/v" + versionDirName.substring(versionDirName.length() -1) +
								"_Affymetrix.Normalization.output.csv', " +
								fileContents[i].substring(endIdx);
						}
					}
                                       	fileListingWriter.write(fileContents[i] + "\n");
				}
                        	fileListingWriter.flush();
                        	fileListingWriter.close();
				log.debug("getting ready to run Normalization on "+versionDirName);
                		try {
                        		String[] rErrorMsg = myR_session.runR(newNormalizationFileName, versionDirName);
					if (rErrorMsg != null && rErrorMsg.length > 0) {
                                		log.debug("ERROR when running normalization on "+versionDirName);
                                        	for (int y=0; y<rErrorMsg.length; y++) {
                               				log.debug(rErrorMsg[y]);
                                        	}
					}
                		} catch (RException e) {
					log.debug("got R ERROR when running NormalizationFile in " + versionDirName, e);
					throw e;
                		}
			} else {
				log.debug("ERROR -- can't find both BioC.Normalization and ExportOutBioC files for "+versionDirName);
			}
		}
	}


	//
	// Find all files that end in '_Image.weight.png' 
	// and rename them to '_Image.weights.png'
	//
	public void rename_weight_files(File userFilesDir){
		log.debug("in rename_weight_files");
		List<File> filesToRename = new ArrayList<File>();
                File [] userDirs = userFilesDir.listFiles();
		for (int i=0; i<userDirs.length; i++) {
			if (userDirs[i].isDirectory()) {
				File userExperimentDir = new File(userDirs[i].getPath() + "/Experiments");
				if (userExperimentDir.isDirectory()) {
					log.debug("userExperimentDir = "+userExperimentDir.getPath());
       	         			File [] masterDirs = userExperimentDir.listFiles(new MasterDirFilter());
					for (int j=0; j<masterDirs.length; j++) {
	       	         			File [] weightFiles = masterDirs[j].listFiles(new weightFilter());
						for (int k=0; k<weightFiles.length; k++) {
							filesToRename.add(weightFiles[k]);
						}
					}
				}
			}
		}
		for (int i=0; i<filesToRename.size(); i++) {
			File thisFile = (File) filesToRename.get(i);
			String fileParent = thisFile.getParent();
			String fileName = thisFile.getName();
			log.debug("about to rename file "+thisFile.toString() + " to " +
				fileParent + "/" + fileName.replaceAll("weight", "weights"));
			//if (i==0) {
				boolean success = thisFile.renameTo(new File(fileParent + "/" + fileName.replaceAll("weight", "weights")));
				log.debug("success = "+success);
			//}
		}
	}
	//
	// Find all files called 'CodeLink.ImportTxt.output.Rdata' 
	// and rename them to 'CodeLink.Comobine.BioC.Binary.Rdata'
	//
	public void renameCodeLinkImportTxtFiles(File userFilesDir){
		log.debug("in rename_CodeLinkImportTxtFiles");
		List<File> filesToRename = new ArrayList<File>();
                File [] userDirs = userFilesDir.listFiles();
		for (int i=0; i<userDirs.length; i++) {
			if (userDirs[i].isDirectory()) {
				File userExperimentDir = new File(userDirs[i].getPath() + "/Experiments");
				if (userExperimentDir.isDirectory()) {
					log.debug("userExperimentDir = "+userExperimentDir.getPath());
       	         			File [] masterDirs = userExperimentDir.listFiles(new MasterDirFilter());
					for (int j=0; j<masterDirs.length; j++) {
	       	         			File [] codelinkFiles = masterDirs[j].listFiles(new codelinkImportTxtFilter());
						for (int k=0; k<codelinkFiles.length; k++) {
							filesToRename.add(codelinkFiles[k]);
						}
					}
				}
			}
		}
		for (int i=0; i<filesToRename.size(); i++) {
			File thisFile = (File) filesToRename.get(i);
			String filePath = thisFile.getPath();
			String fileParent = thisFile.getParent();
			String fileName = thisFile.getName();
			log.debug("about to rename file "+thisFile.toString() + " to " +
				fileParent + "/" + fileName.replaceAll("CodeLink.ImportTxt.output", "Combine.BioC.Binary"));
			//if (i==0) {
				//boolean success = thisFile.renameTo(new File(fileParent + "/" + fileName.replaceAll("CodeLink.ImportTxt.output", "Combine.BioC.Binary")));
			//	log.debug("success = "+success);
			//}
		}
	}
	//
	// Find all files called 'Affy.ExportOutBioC.output.Rdata' 
	// and rename them to 'Affymetrix.ExportOutBioC.output.Rdata'
	//
	public void rename_AffyExportOutBioC_files(File userFilesDir){
		log.debug("in rename_AffyExportOutBioC_files");
		List<File> filesToRename = new ArrayList<File>();
                File [] userDirs = userFilesDir.listFiles();
		for (int i=0; i<userDirs.length; i++) {
			if (userDirs[i].isDirectory()) {
				File userExperimentDir = new File(userDirs[i].getPath() + "/Experiments");
				if (userExperimentDir.isDirectory()) {
					log.debug("userExperimentDir = "+userExperimentDir.getPath());
       	         			File [] masterDirs = userExperimentDir.listFiles(new MasterDirFilter());
					for (int j=0; j<masterDirs.length; j++) {
       	         				File [] versionDirs = masterDirs[j].listFiles(new VersionDirFilter());
						for (int z=0; z<versionDirs.length; z++) {
	       	         				File [] affyFiles = versionDirs[z].listFiles(new affyExportBioCFilter());
							for (int k=0; k<affyFiles.length; k++) {
								filesToRename.add(affyFiles[k]);
							}
						}
					}
				}
			}
		}
		for (int i=0; i<filesToRename.size(); i++) {
			File thisFile = (File) filesToRename.get(i);
			String filePath = thisFile.getPath();
			String fileParent = thisFile.getParent();
			String fileName = thisFile.getName();
			//log.debug("about to rename file "+thisFile.toString() + " to " +
			//	fileParent + "/" + fileName.replaceAll("Affy", "Affymetrix"));
			//if (i==0) {
				boolean success = thisFile.renameTo(new File(fileParent + "/" + fileName.replaceAll("Affy", "Affymetrix")));
				log.debug("just renamed file "+thisFile.toString() + " to " +
					fileParent + "/" + fileName.replaceAll("Affy", "Affymetrix") + ": " + success);
			//	log.debug("success = "+success);
			//}
		}
	}
	//
	// Find all files that end with 'Normalization.output.tab' or 
	// 'Normalization.output.xls' and rename them by adding the 
	// version number to the beginning of the filename
	//
	public void rename_NormalizationFiles(File userFilesDir){
		List<File> normalizationFiles = new ArrayList<File>();
                File [] userDirs = userFilesDir.listFiles();
		for (int i=0; i<userDirs.length; i++) {
			if (userDirs[i].isDirectory()) {
       	         		File [] masterDirs = userDirs[i].listFiles(new MasterDirFilter());
				for (int j=0; j<masterDirs.length; j++) {
       	         			File [] versionDirs = masterDirs[j].listFiles(new VersionDirFilter());
					for (int z=0; z<versionDirs.length; z++) {
	       	         			File [] tabNormalizedFiles = versionDirs[z].listFiles(new tabNormalizationFilter());
						for (int k=0; k<tabNormalizedFiles.length; k++) {
							normalizationFiles.add(tabNormalizedFiles[k]);
						}
	       	         			File [] xlsNormalizedFiles = versionDirs[z].listFiles(new xlsNormalizationFilter());
						for (int k=0; k<xlsNormalizedFiles.length; k++) {
							normalizationFiles.add(xlsNormalizedFiles[k]);
						}
					}
				}
			}
		}
		for (int i=0; i<normalizationFiles.size(); i++) {
			File thisFile = (File) normalizationFiles.get(i);
			String filePath = thisFile.getPath();
			String fileParent = thisFile.getParent();
			String fileName = thisFile.getName();
			int startIdx = filePath.indexOf("/v");
			int endIdx = filePath.indexOf("/", startIdx+1);
			String version = filePath.substring(startIdx+2, endIdx);
			boolean success = thisFile.renameTo(new File(fileParent + "/v" + version + "_" + fileName));
			log.debug("renamed file "+thisFile.toString() + " to " +
				fileParent + "/v" + version + "_" + fileName + ":  "+success);
		}
	}
	
	/** Gets the directories closer to the root.  To get the directory where the file resides, numGenerations should be 0.
	 *
	 */
	public String getAncestors(File thisFile, int numGenerations) {
		//log.debug("in getAncestors. thisFile = "+thisFile + ", and numGenerations = " + numGenerations);
		String filePath = thisFile.getPath();
		String fileParent = thisFile.getParent();
		String fileName = thisFile.getName();
		String ancestor = filePath.substring(0, filePath.lastIndexOf("/"));
		//log.debug("at start ancestor = "+ancestor);
		for (int i=0; i<numGenerations; i++) {
			ancestor = ancestor.substring(0,ancestor.lastIndexOf("/"));
			//log.debug("ancestor = "+ancestor);
		}
		//log.debug("at end ancestor = "+ancestor);
		return ancestor;
	}

	/** 
	 *
	 */
	public void createDummyArrayFiles() throws IOException {
		log.debug("in createDummyArrayFiles");
		File experiment_datafiles_dir = new File(getUserFilesString() + "experiment_datafiles/experiments"); 
		File newArrayDir = new File(getUserFilesString() + "Array_datafiles"); 
                Set<File> rawDataFiles = myFileHandler.getAllFilesBelowThis(experiment_datafiles_dir, new rawFile_Filter());
		log.debug("there are "+rawDataFiles.size() + " rawDataFiles in this directory: "+experiment_datafiles_dir);
		for (File thisFile : rawDataFiles) {
			createDummyFile(thisFile);
			moveFile(thisFile, newArrayDir);
		}
	}

	public void createDummyFile(File thisFile) throws IOException {
		String newFileName = thisFile.getPath() + ".dummy";
		if (doIt) {
			BufferedWriter fileWriter = new BufferedWriter(new FileWriter(new File(newFileName)));

			fileWriter.write("This is an empty file.  Actual file is stored in the " + getUserFilesString() + "Array_datafiles directory");
			fileWriter.newLine();
			fileWriter.close();
		} else { 
			log.debug("goint to create this file: " + newFileName);
		}
	}

	public void moveArrayFiles() {
		log.debug("in moveArrayFiles");
		File newArrayDir = new File(getUserFilesString() + "Array_datafiles"); 
                File [] arrayDirs = getAllUserArraysDirs();
		log.debug("there are "+arrayDirs.length + " array directories");
		for (File thisDir : arrayDirs) {
	       	        File [] files = thisDir.listFiles();
			if (files != null && files.length > 0) {
				log.debug("there are "+files.length + " Array files in this directory: " + thisDir);
				moveAllFilesInDir(thisDir, newArrayDir);
			} else {
				log.debug("There are no Array files in this directory: "+ thisDir);
			}
			if (doIt) {
				deleteDir(thisDir);
			} else {
				log.debug("Will delele this dir: "+thisDir);
			}
		}
	}

	public void fixFiles() {
		log.debug("in fixFiles()");
                File [] masterDirs = getAllUserDatasetMasterDirs();
		File [] files = null;
		for (File thisDir : masterDirs) {
			files = thisDir.listFiles(new callAffymetrixImportFilter());
			fixArrayLocationInFiles(files);
			files = thisDir.listFiles(new arrayFilesFilter());
			fixArrayLocationInFiles(files);
			files = thisDir.listFiles(new callCodeLinkImportFilter());
			fixArrayLocationInFiles(files);
			files = thisDir.listFiles(new callCodeLinkQCFilter());
			fixArrayLocationInFiles(files);
		}
	}

	public void fixArrayLocationInFiles(File[] files) {
		if (files != null && files.length > 0) {
			for (File thisFile : files) {
				replaceString(thisFile, getAncestors(thisFile, 2) + "/" + "Arrays", userFilesString + "Array_datafiles");
			}
		}
	}

	public void deleteUploadedCELFiles() {
                File [] uploadDirs = getAllUserExperimentUploadDirs();
		for (File thisDir : uploadDirs) {
	       	        File [] CEL_files = thisDir.listFiles(new CEL_Filter());
			for (File thisFile : CEL_files) {
				deleteFile(thisFile);
			}
		}
	}

	public void replaceString(File inFile, String oldString, String newString) {

		String line = "";
		String newLine = "";
                BufferedReader br = null;

                try {
                        br = new BufferedReader(new FileReader(inFile));
                } catch(IOException e) {
                        log.debug("in exception of replaceString while setting up Buffered Reader", e);
                }

		boolean fileNeedsFixing = false;
                try {
			int idx = 0;
                        while (((line = br.readLine()) != null)) {
				if (line.indexOf(oldString) > -1) {
					fileNeedsFixing = true;
					log.debug("found this file " + inFile + " needs Fixing at line " + idx);
					break;
				}
				idx++;
			}
			if (fileNeedsFixing) {
				// reset the reader to the beginning of the file
                        	br = new BufferedReader(new FileReader(inFile));
				File outFile = new File(inFile.getParent() + "/" + inFile.getName() + ".NEW");
				BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(outFile));
                		log.debug("in replaceString.  oldString = "+oldString + ", newString = " + newString);
                		log.debug("fileNeedsFixing, outFile = " + outFile.getPath());
                        	while (((line = br.readLine()) != null)) {
					if (line.indexOf(oldString) > -1) {
						line = line.replaceAll(oldString, newString);
					}
					bufferedWriter.write(line);
					bufferedWriter.newLine();
                        	}
				bufferedWriter.close();
				if (doIt) {
					inFile.renameTo(new File (inFile.getParent() + "/" + inFile.getName() + ".OLD"));
					outFile.renameTo(new File (outFile.getParent() + "/" + inFile.getName()));
				}
			}
                } catch(IOException e) {
                        log.debug("in exception of replaceString while reading lines", e);
		}

	}

	public void deleteFile(File inFile) {

		log.info("in DirCleanup.deleteFile.  inFile = " + inFile.getPath()); 
		try {
			if (doIt) {
				log.debug("Deleting file: " + inFile);
				inFile.delete();
			} else {
				log.debug("Need to delete file: " + inFile);
			}
		} 
		catch (Exception e) {
			log.debug("In deleteFile exception", e);
    		}
	}


	/** Deletes a director when doIt is true.  Use this instead of deleteDir in FileHandler in order to see what's going to be deleted first.
	 *
	 */
	public void deleteDir(File dir) {
	
		//log.info("in DirCleanup.deleteDir.  dirName = "+dir.toString());
		try {
			if (doIt) {
				log.debug("Deleting dir: " + dir);
				myFileHandler.deleteAllFilesPlusDirectory(dir);
			} else {
				log.debug("About to delete dir: " + dir);
			}
		}
		catch (Exception e) {
			log.debug("in exception of deleteDir", e);
		}
	}

	public void moveDir(File oldDir, File newDir) {
		
		log.info("in DirCleanup.moveDir.  oldDirName = "+oldDir.getPath() + ", newDirName = " + newDir.getPath());
		String newDirName = newDir.getPath();
		try {
			boolean success = oldDir.renameTo(newDir);
		} catch (Exception e) {
			log.debug("in exception of moveDir", e);
		}
	}

	//
	// Move files from GeneLists/GeneList_Promoter_Analysis directory to GeneLists/GeneList/oPOSSUM directory
	//
	public void movePromoterFiles() {
		log.debug("in movePromoterFiles");
		List filesToRename = new ArrayList();
                File [] userDirs = getAllUserDirs();
		for (int i=0; i<userDirs.length; i++) {
			if (userDirs[i].isDirectory()) {
				File userGeneListsDir = new File(userDirs[i].getPath() + "/GeneLists/");
				if (userGeneListsDir.isDirectory()) {
					log.debug("userGeneListsDir = "+userGeneListsDir.getPath());
       	         			File [] promoterDirs = userGeneListsDir.listFiles(new PromoterDirFilter());
					for (int j=0; j<promoterDirs.length; j++) {
						String dirName = promoterDirs[j].toString();
						String geneListDir = dirName.substring(0,dirName.indexOf("_Promoter_Analysis"))+"/"; 
						String oPOSSUMDir = 
							geneListDir + 
							"oPOSSUM/";
						log.debug("oPOSSUMDir = "+oPOSSUMDir);
	                			myFileHandler.createDir(geneListDir);
	                			myFileHandler.createDir(oPOSSUMDir);
	       	         			moveAllFilesInDir(promoterDirs[j], new File(oPOSSUMDir));
						try {
	                				deleteDir(promoterDirs[j]);
						} catch (Exception e) {
							log.debug("ERROR -- could not delete directory "+promoterDirs[j]);
						}
					}
				}
			}
		}
	}

	/** Move one file from old directory to new directory
	 * 
	 */
	public void moveFile (File thisFile, File newDir) {
		
		//log.info("in DirCleanup.moveFile.");
		String newDirName = newDir.getPath();
		try {
			if (doIt) {
				boolean success = thisFile.renameTo(new File(newDirName + "/" + thisFile.getName()));
				if (!success) { 
					log.debug("ERROR: unable to move "+thisFile + " to " + newDir);
				} else {
					log.debug("successfully moved file " + thisFile + " to " + newDir);
				}
			} else {
				log.debug("planning to move "+thisFile + " to " + newDirName + "/" + thisFile.getName());
			}
		} catch (Exception e) {
			log.debug("in exception of moveFile", e);
		}
	}

	/** Move all files in old directory to new directory
	 * 
	 */
	public void moveAllFilesInDir (File oldDir, File newDir) {
		
		log.info("in DirCleanup.moveAllFilesInDir.  oldDirName = "+oldDir.getPath() + ", newDirName = " + newDir.getPath());
		String newDirName = newDir.getPath();
		try {
			File[] allFiles = oldDir.listFiles();
			log.debug("number of files in directory= "+allFiles.length);
			if (allFiles != null && allFiles.length > 0) {
				for (File thisFile: allFiles) {
					moveFile(thisFile, newDir);
				} 
			}
		} catch (Exception e) {
			log.debug("in exception of moveAllFilesInDir", e);
		}
	}

	public void removeUsername (File dir, String username) {
		
		log.info("in DirCleanup.removeUsername.  dirName = "+dir.getPath());
		try {
			File[] allFiles = dir.listFiles();
			log.debug("number of files in directory= "+allFiles.length);
			for (int i=0; i<allFiles.length; i++) {
				if (allFiles[i].getName().startsWith(username)) {
					boolean success = allFiles[i].renameTo(new File(dir + "/" + 
							allFiles[i].getName().substring(username.length() + 1)));
					log.debug("copied file " + allFiles[i].getName() +" = "+success);
				}
			}
		}
		catch (Exception e) {
			log.debug("in exception of removeUsername", e);
		}
	}


	public void createNewDirectories (File newDir) {
		
		String newDirName = newDir.getPath();
		String newDirStarting = newDirName.substring(0, newDirName.indexOf("GeneLists"));
		String newDirEnding = newDirName.substring(newDirName.indexOf("GeneLists"));
		
		log.info("in DirCleanup.createNewDirectories.  newDirStarting= "+ newDirStarting + ", newDirEnding = "+newDirEnding);
		String[] subDirs = newDirEnding.split("/");

		String newDirString = newDirStarting + "GeneLists";
		try {
			for (int i=1; i<subDirs.length; i++) {
				newDirString = newDirString + "/" + subDirs[i];
				log.debug("newDir = " + newDirString);
				boolean madeDir = (new File(newDirString)).mkdir();
			}
		}
		catch (Exception e) {
			log.debug("in exception of createNewDirectories", e);
		}
	}

        public void createArrayDirectories (File mainDir) {

                File [] subDirs = mainDir.listFiles();

                try {
                        for (int i=0; i<subDirs.length; i++) {
                                String subDirName = subDirs[i].getPath();
                                boolean worked = (new File(subDirName + "/Arrays")).mkdir();
                                System.out.println("just created " + subDirName +  "/Arrays");
				//
				// Move the files from the Datasets directory to the Arrays directory
				moveAllFilesInDir(new File(subDirName + "/Datasets"), new File(subDirName + "/Arrays"));
                        }
                }
                catch (Exception e) {
                        log.debug("in exception of createArrayDirectories", e);
                }
        }

        public void createDatasetDirectories () {

                //File mainDir = new File("/stroma/INIATEST/userFiles");
                File mainDir = new File("/home/cherylh/userFiles");

                File [] subDirs = mainDir.listFiles();

                try {
                        for (int i=0; i<subDirs.length; i++) {
                                String subDirName = subDirs[i].getPath();
                                boolean worked = (new File(subDirName + "/Datasets")).mkdir();
                                log.debug("just created " + subDirName +  "/Datasets");
                        }
                }
                catch (Exception e) {
                        log.debug("in exception of createDatasetDirectories", e);
                }
        }

        public void createExperimentDirectories (File mainDir) {

                File [] userDirs = mainDir.listFiles();

                try {
                        for (int i=0; i<userDirs.length; i++) {
                                String userDirName = userDirs[i].getPath();
                                boolean worked = (new File(userDirName + "/Experiments")).mkdir();
                                log.debug("just created " + userDirName +  "/Experiments");
                                worked = (new File(userDirName + "/Experiments/uploads")).mkdir();
                                log.debug("just created " + userDirName + "/Experiments/uploads");
				FilenameFilter masterDirFilter = new MasterDirFilter();
       	         		File [] masterDirs = userDirs[i].listFiles(masterDirFilter);
				for (int j=0; j<masterDirs.length; j++) {
					String newDir = userDirName + "/Experiments/" + masterDirs[j].getName();
					log.debug("Moving oldDir "+masterDirs[j].getPath() + " to newDir " + newDir);
					moveDir(masterDirs[j], new File(newDir));
				}
                        }
                }
                catch (Exception e) {
                        log.debug("in exception of createExperimentDirectories", e);
                }
        }

	public void checkExperimentNames(File userFilesDir, Connection conn) {

		log.debug("************CHECK EXPERIMENT NAMES HERE ********************");
                String query = "select ds.name, ds.path, u.user_name "+
                        "from datasets ds, users u "+
			"where ds.created_by_user_id = u.user_id "+
                        "order by u.user_name, ds.name";

                Statement stmt = null;
		try {
                	stmt = conn.createStatement();
                	ResultSet rs = stmt.executeQuery(query);

                	while (rs.next()) {
                        	String dsName = rs.getString(1);
				String dsNameNoSpaces = new ObjectHandler().removeBadCharacters(dsName);
                        	String actualPath = rs.getString(2);
                        	String userName = rs.getString(3);
				String expectedPath = userFilesDir + "/"+userName +"/" + dsNameNoSpaces + "_Master";

				if (!expectedPath.equals(actualPath)) {
					log.debug("expectedPath = "+expectedPath+", actualPath = "+actualPath);
				}

/*
                		File [] userDirs = userFilesDir.listFiles();
				for (int i=0; i<userDirs.length; i++) {
					if (userDirs[i].getPath().indexOf(userName) > 0) {
       	         				File [] masterDirs = userDirs[i].listFiles(new MasterDirFilter());
						for (int j=0; j<masterDirs.length; j++) {
							log.debug("masterDirs = "+masterDirs[i].getName());
						}
					}
				}
*/
                	}
        	} catch (Exception e) {
                	System.out.println("in exception of DirCleanup");
                	e.printStackTrace();
        	}
	}




  public static void main(String[] args) {

	try {
		DirCleanup myDirCleanup = new DirCleanup();

		String query="";
                Statement stmt = null;
		ResultSet rs = null;

		// Stan Development Environment
		myDirCleanup.setWebRoot(new File("/usr/share/tomcat/webapps/PhenoGen/web"));
		myDirCleanup.setJSPSourceRoot(new File("/usr/share/tomcat/work/Catalina/localhost/PhenoGen/org/apache/jsp/web"));
		myDirCleanup.setPropertiesFile(new File("/usr/share/tomcat/webapps/PhenoGen/web/common/dbProperties/stan_halDev.properties"));
		myDirCleanup.setUserFilesString("/Users/chornbak/cherylh/userFiles/");
		myDirCleanup.setUserFilesDir(new File(myDirCleanup.getUserFilesString()));
		myDirCleanup.getR_session().setRFunctionDir("/usr/share/tomcat/webapps/PhenoGen/R_src/");

		// Test Environment
/*
		myDirCleanup.setPropertiesFile(new File("/usr/share/tomcat/webapps/PhenoGenTEST/web/common/dbProperties/halTest.properties"));
		//myDirCleanup.setMiamePropertiesFile(new File("/usr/share/tomcat/webapps/PhenoGenTEST/web/common/dbProperties/iniasrvDb_miamexpress.properties"));
		myDirCleanup.setUserFilesString("/stroma/INIATEST/userFiles/");
		myDirCleanup.setUserFilesDir(new File(myDirCleanup.getUserFilesString()));
		myDirCleanup.getR_session().setRFunctionDir("/usr/share/tomcat/webapps/PhenoGenTEST/R_src/");

		// Production Environment
		myDirCleanup.setPropertiesFile(new File("/usr/share/tomcat/webapps/PhenoGen/web/common/dbProperties/halProd.properties"));
		//myDirCleanup.setMiamePropertiesFile(new File("/usr/share/tomcat/webapps/PhenoGen/web/common/dbProperties/iniasrvDb_miamexpress.properties"));
		myDirCleanup.setUserFilesString("/data/userFiles/");
		myDirCleanup.setUserFilesDir(new File(myDirCleanup.getUserFilesString()));
		myDirCleanup.getR_session().setRFunctionDir("/usr/share/tomcat/webapps/PhenoGen/R_src/");
*/

        	myDirCleanup.setConn(new PropertiesConnection().getConnection(myDirCleanup.getPropertiesFile()));

		//myDirCleanup.R3_3ToR3_3_2Changes();
		//myDirCleanup.R3_3ToR3_4Changes();
		//myDirCleanup.R2_1Changes();
		//myDirCleanup.R2_2Changes();
		//myDirCleanup.R2_3Changes();
		myDirCleanup.R2_4Changes();

		System.out.println("*************************************************************************************");
		System.out.println("***************** DON'T FORGET TO CHOWN ON THE USERFILES DIR!!!! ********************");
		System.out.println("*************************************************************************************");

		/***************** DON'T FORGET TO CHOWN ON THE USERFILES DIR!!!! ***********************************/
		System.out.println("done with DirCleanup");


        } catch (Exception e) {
                System.out.println("in exception of DirCleanup");
                e.printStackTrace();
        }
  }
}
