package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import edu.ucdenver.ccp.util.Debugger;
import edu.ucdenver.ccp.util.sql.Results;
import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling array data.
 * @author Cheryl Hornbaker
 */

public class Array{
	private Logger log=null;
	private Debugger myDebugger = new Debugger();
	private DbUtils myDbUtils = new DbUtils();
	private ObjectHandler myObjectHandler = new ObjectHandler();
	
	private int hybrid_id;
	private String sample_name;
	private String file_name;
	private java.sql.Timestamp create_date;
	private String hybrid_name;
	private String organism;
	private String provider;
	private String otherBiosource_type;
	private String otherOrganismPart;
	private String otherDevStage;
	private String biosource_type;
	private String development_stage;
	private String age_status;
	private double age_range_min;
	private double age_range_max;
	private String age_range_units;
	private String time_point;
	private String organism_part;
	private String gender;
	private String genetic_variation;
	private String individual_identifier;
	private String individual_genotype;
	private String disease_state;
	private String separation_technique;
	private String target_cell_type;
	private String cell_line;
	private String additional;
	private String platform;
	private String experiment_design_types;
	private String experimental_factors;
	private String experiment_name;
	private String submitter;
	private String experiment_path;
	private String array_type;
	private String array_name;
	private String strain;
	private String treatment;
	private String duration;
	private String publicExpID;
	private String growthConditionsProtocol;
	private String growthConditionsProtocolDescription;
	private String sampleTreatmentProtocol;
	private String sampleTreatmentProtocolDescription;
	private String experimentDescription;
	private String textract_id;
	private String extractProtocol;
	private String extractProtocolDescription;
	private String tlabel_id;
	private String labelExtractDescription;
	private String labelExtractProtocol;
	private String labelExtractProtocolDescription;
	private String hybridizationDescription;
	private String hybridizationProtocol;
	private String hybridizationProtocolDescription;
	private String scanningProtocol;
	private String scanningProtocolDescription;
	private String compound;
	private String dose;
	private int exp_id;
	private int submis_id;
	private int owner_user_id;
	private int uploaded_by_user_id;
	private int user_id;
	private int access_approval;
	private int tsample_taxid;
	private int tsample_sex;
	private int tsample_organism_part;
	private int tsample_sample_type;
	private int tsample_dev_stage;
	private int tsample_time_unit;
	private int tsample_genetic_variation;
	private int tsample_protocolid;
	private int tsample_growth_protocolid;
	private int textract_protocolid;
	private int tlabel_protocolid;
	private int hybrid_protocol_id;
	private int hybrid_array_id;
	private int hybrid_scan_protocol_id;
	private int tsample_sysuid;
	private int textract_sysuid;
	private int tlabel_sysuid;
	private int tarray_designid;

	private static final String NULL_VALUE = "--";
	private static final String TREATMENT_TYPE = "SAMPLE_LABORATORY_PROTOCOL";
	private static final String GROWTH_TYPE = "SAMPLE_GROWTH_PROTOCOL";
	private static final String EXTRACT_TYPE = "EXTRACT_LABORATORY_PROTOCOL";
	private static final String LABEL_TYPE = "LABEL_LABORATORY_PROTOCOL";
	private static final String HYBRID_TYPE = "HYBRID_LABORATORY_PROTOCOL";
	private static final String SCAN_TYPE = "SCANNING_LABORATORY_PROTOCOL";
	public static final String MOUSE_EXON_ARRAY_TYPE = "Affymetrix GeneChip Mouse Exon 1.0 ST Array";
	public static final String RAT_EXON_ARRAY_TYPE = "Affymetrix GeneChip Rat Exon 1.0 ST Array";
	public static final String MOUSE430V2_ARRAY_TYPE = "Affymetrix GeneChip Mouse Genome 430 2.0 [Mouse430_2]";
	public static final String CODELINK_RAT_ARRAY_TYPE = "GE Healthcare CodeLink Rat Whole Genome Bioarray";

	public static final String MOUSE430V2_ARRAY_TYPE_SHORT = "Mouse Genome 430 2.0 Array";
	public static final String CODELINK_RAT_ARRAY_TYPE_SHORT = "CodeLink Rat Whole Genome Array";
	public static final String MOUSE_EXON_ARRAY_TYPE_SHORT = "Affymetrix GeneChip Mouse Exon 1.0 ST Array.transcript";
	public static final String RAT_EXON_ARRAY_TYPE_SHORT = "Affymetrix GeneChip Rat Exon 1.0 ST Array.transcript";
	public static final Set<String> EXON_ARRAY_TYPES = new LinkedHashSet<String>() { 
		{
			add(MOUSE_EXON_ARRAY_TYPE);
			add(RAT_EXON_ARRAY_TYPE);
		}
	};
	public static final Set<String> EQTL_ARRAY_TYPES = new LinkedHashSet<String>() { 
		{
			add(MOUSE430V2_ARRAY_TYPE_SHORT);
			add(CODELINK_RAT_ARRAY_TYPE_SHORT);
			add(MOUSE_EXON_ARRAY_TYPE_SHORT);
			add(RAT_EXON_ARRAY_TYPE_SHORT);
		}
	};

	public Array () {
		log = Logger.getRootLogger();
	}

	public Array (int hybrid_id) {
		log = Logger.getRootLogger();
        	this.setHybrid_id(hybrid_id);
	}

	public void setHybrid_id(int inInt) {
    		this.hybrid_id = inInt;
	}

	public int getHybrid_id() {
    		return hybrid_id;
	}

	public void setSample_name(String inString) {
    		this.sample_name = inString;
	}

	public String getSample_name() {
    		return sample_name;
	}

	public void setFile_name(String inString) {
    		this.file_name = inString;
  	}

	public String getFile_name() {
    	return file_name;
  	}

 	public void setCreate_date(java.sql.Timestamp inTimestamp) {
        	this.create_date = inTimestamp;
 	}

 	public java.sql.Timestamp getCreate_date() {
        	return create_date;
 	}

 	public void setHybrid_name(String inString) {
        	this.hybrid_name = inString;
 	}

 	public String getHybrid_name() {
        	return hybrid_name;
 	}

 	public void setOrganism(String inString) {
        	this.organism = inString;
 	}

 	public String getOrganism() {
        	return organism;
 	}

 	public void setProvider(String inString) {
        	this.provider = inString;
 	}

 	public String getProvider() {
        	return (provider == null ? NULL_VALUE : provider);
 	}

 	public void setOtherBiosource_type(String inString) {
        	this.otherBiosource_type = inString;
 	}

 	public String getOtherBiosource_type() {
        	return (otherBiosource_type == null ? NULL_VALUE : otherBiosource_type);
 	}

 	public void setOtherOrganismPart(String inString) {
        	this.otherOrganismPart = inString;
 	}

 	public String getOtherOrganismPart() {
        	return (otherOrganismPart == null ? NULL_VALUE : otherOrganismPart);
 	}

 	public void setOtherDevStage(String inString) {
        	this.otherDevStage = inString;
 	}

 	public String getOtherDevStage() {
        	return (otherDevStage == null ? NULL_VALUE : otherDevStage);
 	}

 	public void setBiosource_type(String inString) {
        	this.biosource_type = inString;
 	}

 	public String getBiosource_type() {
        	//return biosource_type;
        	return (biosource_type == null ? NULL_VALUE : biosource_type);
 	}

 	public void setDevelopment_stage(String inString) {
        	this.development_stage = inString;
 	}

 	public String getDevelopment_stage() {
        	return (development_stage == null ? NULL_VALUE : development_stage);
        	//return development_stage;
 	}

 	public void setAge_status(String inString) {
        	this.age_status = inString;
 	}

 	public String getAge_status() {
        	return (age_status == null ? NULL_VALUE : age_status);
        	//return age_status;
 	}

 	public void setAge_range_min(double inDouble) {
        	this.age_range_min = inDouble;
 	}

 	public double getAge_range_min() {
        	return age_range_min;
 	}

 	public void setAge_range_max(double inDouble) {
        	this.age_range_max = inDouble;
 	}

 	public double getAge_range_max() {
        	return age_range_max;
 	}

 	public void setAge_range_units(String inString) {
        	this.age_range_units = inString;
 	}

 	public String getAge_range_units() {
        	return (age_range_units == null ? NULL_VALUE : age_range_units);
        	//return age_range_units;
 	}
 	public void setTime_point(String inString) {
        	this.time_point = inString;
 	}

 	public String getTime_point() {
        	return (time_point == null ? NULL_VALUE : time_point);
        	//return time_point;
 	}

 	public void setOrganism_part(String inString) {
        	this.organism_part = inString;
 	}

 	public String getOrganism_part() {
        	return (organism_part == null ? NULL_VALUE : organism_part);
        	//return organism_part;
 	}

 	public void setGender(String inString) {
        	this.gender = inString;
 	}

 	public String getGender() {
        	return (gender == null ? NULL_VALUE : gender);
        	//return gender;
 	}

 	public void setGenetic_variation(String inString) {
        	this.genetic_variation = inString;
 	}

 	public String getGenetic_variation() {
        	return (genetic_variation == null ? NULL_VALUE : genetic_variation);
        	//return genetic_variation;
 	}

 	public void setIndividual_identifier(String inString) {
        	this.individual_identifier  = inString;
 	}

 	public String getIndividual_identifier() {
        	return (individual_identifier == null ? NULL_VALUE : individual_identifier);
        	//return individual_identifier;
 	}

 	public void setIndividual_genotype(String inString) {
        	this.individual_genotype = inString;
 	}

 	public String getIndividual_genotype() {
        	return (individual_genotype == null ? NULL_VALUE : individual_genotype);
        	//return individual_genotype;
 	}

 	public void setDisease_state(String inString) {
        	this.disease_state = inString;
 	}

 	public String getDisease_state() {
        	return (disease_state == null ? NULL_VALUE : disease_state);
        	//return disease_state;
 	}

 	public void setSeparation_technique(String inString) {
        	this.separation_technique = inString;
 	}

 	public String getSeparation_technique() {
        	return (separation_technique == null ? NULL_VALUE : separation_technique);
        	//return separation_technique;
 	}

 	public void setTarget_cell_type(String inString) {
        	this.target_cell_type = inString;
 	}

 	public String getTarget_cell_type() {
        	return (target_cell_type == null ? NULL_VALUE : target_cell_type);
        	//return target_cell_type;
 	}

 	public void setStrain(String inString) {
        	this.strain = inString;
 	}

 	public String getStrain() {
        	return (strain == null ? NULL_VALUE : strain);
        	//return strain;
 	}

 	public void setTreatment(String inString) {
        	this.treatment = inString;
 	}

 	public String getTreatment() {
        	return (treatment == null ? "No Treatment" : treatment);
 	}

 	public void setDuration(String inString) {
        	this.duration = inString;
 	}

 	public String getDuration() {
        	return (duration == null ? NULL_VALUE : duration);
 	}

 	public void setPublicExpID(String inString) {
        	this.publicExpID = inString;
 	}

 	public String getPublicExpID() {
        	return publicExpID;
 	}

 	public void setCell_line(String inString) {
        	this.cell_line = inString;
 	}

 	public String getCell_line() {
        	return (cell_line == null ? NULL_VALUE : cell_line);
        	//return cell_line;
 	}

 	public void setAdditional(String inString) {
        	this.additional = inString;
 	}

 	public String getAdditional() {
        	return (additional == null ? NULL_VALUE : additional);
        	//return additional;
 	}

 	public void setExperiment_design_types(String inString) {
        	this.experiment_design_types = inString;
 	}

 	public String getExperiment_design_types() {
        	return experiment_design_types;
 	}

 	public void setExperimental_factors(String inString) {
        	this.experimental_factors = inString;
 	}

 	public String getExperimental_factors() {
        	return experimental_factors;
 	}

 	public void setExperiment_name(String inString) {
        	this.experiment_name = inString;
 	}

 	public String getExperiment_name() {
        	return experiment_name;
 	}

 	public void setSubmitter(String inString) {
        	this.submitter = inString;
 	}

 	public String getSubmitter() {
        	return submitter;
 	}

 	public void setExperiment_path(String inString) {
        	this.experiment_path = inString;
 	}

 	public String getExperiment_path() {
        	return experiment_path;
 	}

	// Not sure if we need this or not -- figure it out!
 	public void setArray_name(String inString) {
        	this.array_name = inString;
 	}

 	public String getArray_name() {
        	return array_name;
 	}

 	public void setArray_type(String inString) {
        	this.array_type = inString;
 	}

 	public String getArray_type() {
        	return array_type;
 	}

 	public void setPlatform(String inString) {
        	this.platform = inString;
 	}

 	public String getPlatform() {
        	return platform;
 	}

 	public void setGrowthConditionsProtocol(String inString) {
        	this.growthConditionsProtocol = inString;
 	}

 	public String getGrowthConditionsProtocol() {
        	return (growthConditionsProtocol == null ? NULL_VALUE : growthConditionsProtocol);
        	//return growthConditionsProtocol;
 	}

 	public void setGrowthConditionsProtocolDescription(String inString) {
        	this.growthConditionsProtocolDescription = inString;
 	}

 	public String getGrowthConditionsProtocolDescription() {
        	return (growthConditionsProtocolDescription == null ? NULL_VALUE : growthConditionsProtocolDescription);
        	//return growthConditionsProtocolDescription;
 	}

 	public void setSampleTreatmentProtocol(String inString) {
        	this.sampleTreatmentProtocol = inString;
 	}

 	public String getSampleTreatmentProtocol() {
        	return (sampleTreatmentProtocol == null ? NULL_VALUE : sampleTreatmentProtocol);
        	//return sampleTreatmentProtocol;
 	}

 	public void setSampleTreatmentProtocolDescription(String inString) {
        	this.sampleTreatmentProtocolDescription = inString;
 	}

 	public String getSampleTreatmentProtocolDescription() {
        	return (sampleTreatmentProtocolDescription == null ? NULL_VALUE : sampleTreatmentProtocolDescription);
        	//return sampleTreatmentProtocolDescription;
 	}

 	public void setExperimentDescription(String inString) {
        	this.experimentDescription = inString;
 	}

 	public String getExperimentDescription() {
        	return (experimentDescription == null ? NULL_VALUE : experimentDescription);
        	//return experimentDescription;
 	}

 	public void setTextract_id(String inString) {
        	this.textract_id = inString;
 	}

 	public String getTextract_id() {
        	return (textract_id == null ? NULL_VALUE : textract_id);
        	//return textract_id;
 	}

 	public void setExtractProtocol(String inString) {
        	this.extractProtocol = inString;
 	}

 	public String getExtractProtocol() {
        	return (extractProtocol == null ? NULL_VALUE : extractProtocol);
        	//return extractProtocol;
 	}

 	public void setExtractProtocolDescription(String inString) {
        	this.extractProtocolDescription = inString;
 	}

 	public String getExtractProtocolDescription() {
        	return (extractProtocolDescription == null ? NULL_VALUE : extractProtocolDescription);
        	//return extractProtocolDescription;
 	}

 	public void setTlabel_id(String inString) {
        	this.tlabel_id = inString;
 	}

 	public String getTlabel_id() {
        	return (tlabel_id == null ? NULL_VALUE : tlabel_id);
        	//return tlabel_id;
 	}

 	public void setLabelExtractProtocol(String inString) {
        	this.labelExtractProtocol = inString;
 	}

 	public String getLabelExtractProtocol() {
        	return (labelExtractProtocol == null ? NULL_VALUE : labelExtractProtocol);
        	//return labelExtractProtocol;
 	}

 	public void setLabelExtractProtocolDescription(String inString) {
        	this.labelExtractProtocolDescription = inString;
 	}

 	public String getLabelExtractProtocolDescription() {
        	return (labelExtractProtocolDescription == null ? NULL_VALUE : labelExtractProtocolDescription);
        	//return labelExtractProtocolDescription;
 	}

 	public void setHybridizationProtocol(String inString) {
        	this.hybridizationProtocol = inString;
 	}

 	public String getHybridizationProtocol() {
        	return (hybridizationProtocol == null ? NULL_VALUE : hybridizationProtocol);
        	//return hybridizationProtocol;
 	}

 	public void setHybridizationProtocolDescription(String inString) {
        	this.hybridizationProtocolDescription = inString;
 	}

 	public String getHybridizationProtocolDescription() {
        	return (hybridizationProtocolDescription == null ? NULL_VALUE : hybridizationProtocolDescription);
        	//return hybridizationProtocolDescription;
 	}

 	public void setScanningProtocol(String inString) {
        	this.scanningProtocol = inString;
 	}

 	public String getScanningProtocol() {
        	return (scanningProtocol == null ? NULL_VALUE : scanningProtocol);
        	//return scanningProtocol;
 	}

 	public void setScanningProtocolDescription(String inString) {
        	this.scanningProtocolDescription = inString;
 	}

 	public String getScanningProtocolDescription() {
        	return (scanningProtocolDescription == null ? NULL_VALUE : scanningProtocolDescription);
        	//return scanningProtocolDescription;
 	}

 	public void setCompound(String inString) {
        	this.compound = inString;
 	}

 	public String getCompound() {
        	return (compound == null ? NULL_VALUE : compound);
        	//return compound;
 	}

 	public void setDose(String inString) {
        	this.dose = inString;
 	}

 	public String getDose() {
        	return (dose == null || dose.equals("") || dose.equals(" ") ? NULL_VALUE : dose);
        	//return dose;
 	}

  	public void setUploaded_by_user_id(int inInt) {
    		this.uploaded_by_user_id = inInt;
  	}

  	public int getUploaded_by_user_id() {
    		return uploaded_by_user_id;
  	}

  	public void setExp_id(int inInt) {
    		this.exp_id = inInt;
  	}

  	public int getExp_id() {
    		return exp_id;
  	}

  	public void setSubmis_id(int inInt) {
    		this.submis_id = inInt;
  	}

  	public int getSubmis_id() {
    		return submis_id;
  	}

  	public void setOwner_user_id(int inInt) {
    		this.owner_user_id = inInt;
  	}

  	public int getOwner_user_id() {
    		return owner_user_id;
  	}

  	public void setUser_id(int inInt) {
    		this.user_id = inInt;
  	}

  	public int getUser_id() {
    		return user_id;
  	}
  	public void setAccess_approval(int inInt) {
    		this.access_approval = inInt;
  	}

  	public int getAccess_approval() {
    		return access_approval;
  	}

  	public void setTsample_taxid(int inInt) {
    		this.tsample_taxid = inInt;
  	}

  	public int getTsample_taxid() {
    		return tsample_taxid;
  	}

  	public void setTsample_sex(int inInt) {
    		this.tsample_sex = inInt;
  	}

  	public int getTsample_sex() {
    		return tsample_sex;
  	}

  	public void setTsample_organism_part(int inInt) {
    		this.tsample_organism_part = inInt;
  	}

  	public int getTsample_organism_part() {
    		return tsample_organism_part;
  	}

  	public void setTsample_sample_type(int inInt) {
    		this.tsample_sample_type = inInt;
  	}

  	public int getTsample_sample_type() {
    		return tsample_sample_type;
  	}

  	public void setTsample_dev_stage(int inInt) {
    		this.tsample_dev_stage = inInt;
  	}

  	public int getTsample_dev_stage() {
    		return tsample_dev_stage;
  	}

  	public void setTsample_time_unit(int inInt) {
    		this.tsample_time_unit = inInt;
  	}

  	public int getTsample_time_unit() {
    		return tsample_time_unit;
  	}

  	public void setTsample_genetic_variation(int inInt) {
    		this.tsample_genetic_variation = inInt;
  	}

  	public int getTsample_genetic_variation() {
    		return tsample_genetic_variation;
  	}

  	public void setTsample_protocolid(int inInt) {
    		this.tsample_protocolid = inInt;
  	}

  	public int getTsample_protocolid() {
    		return tsample_protocolid;
  	}

  	public void setTsample_growth_protocolid(int inInt) {
    		this.tsample_growth_protocolid = inInt;
  	}

  	public int getTsample_growth_protocolid() {
    		return tsample_growth_protocolid;
  	}

  	public void setTextract_protocolid(int inInt) {
    		this.textract_protocolid = inInt;
  	}

  	public int getTextract_protocolid() {
    		return textract_protocolid;
  	}

  	public void setTlabel_protocolid(int inInt) {
    		this.tlabel_protocolid = inInt;
  	}

  	public int getTlabel_protocolid() {
    		return tlabel_protocolid;
  	}

  	public void setHybrid_protocol_id(int inInt) {
    		this.hybrid_protocol_id = inInt;
  	}

  	public int getHybrid_protocol_id() {
    		return hybrid_protocol_id;
  	}

  	public void setHybrid_scan_protocol_id(int inInt) {
    		this.hybrid_scan_protocol_id = inInt;
  	}

  	public int getHybrid_scan_protocol_id() {
    		return hybrid_scan_protocol_id;
  	}

  	public void setHybrid_array_id(int inInt) {
    		this.hybrid_array_id = inInt;
  	}

  	public int getHybrid_array_id() {
    		return hybrid_array_id;
  	}

  	public void setTsample_sysuid(int inInt) {
    		this.tsample_sysuid = inInt;
  	}

  	public int getTsample_sysuid() {
    		return tsample_sysuid;
  	}

  	public void setTextract_sysuid(int inInt) {
    		this.textract_sysuid = inInt;
  	}

  	public int getTextract_sysuid() {
    		return textract_sysuid;
  	}

  	public void setTarray_designid(int inInt) {
    		this.tarray_designid = inInt;
  	}

  	public int getTarray_designid() {
    		return tarray_designid;
  	}

  	public void setTlabel_sysuid(int inInt) {
    		this.tlabel_sysuid = inInt;
  	}

  	public int getTlabel_sysuid() {
    		return tlabel_sysuid;
  	}


	private String getMyCoreWhereClause (String hybridIDs, String channel) {
		String coreWhereClause = getMyCoreWhereClause(channel); 
		
		if (!(hybridIDs.equals("All"))) {
			coreWhereClause = coreWhereClause + 
			"and expDetails.hybrid_id in "+
			hybridIDs + " ";
		}
		
		return coreWhereClause;
	}
	private String getMyCoreWhereClause (String channel) {
		String coreWhereClause = "";

		if (channel.equals("Single")) {
			coreWhereClause = coreWhereClause + 
                	"and (upper(expDetails.path) like '%CEL' or " + 
			"	upper(expDetails.path) like '%TXT') "; 
		} else if (channel.equals("Two")) {
			coreWhereClause = coreWhereClause + 
                	"and (upper(expDetails.path) like '%GPR' or "+
                	"     upper(expDetails.path) like '%SPOT') ";
		}
		return coreWhereClause;
	}

	/**
	 * Updates the experiment accession number so that it can be submitted to Array Express.
	 * @param submisID	the submission ID of the experiment
	 * @param newAccno	the accession number to use
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 */
	public void updateAccno (int submisID, String newAccno, Connection conn) throws SQLException{

        	String query =
                	"update experiments "+
                	"set accno = ? "+
                	"where subid = ?";

        	log.debug("in updateAccno. submisID = "+submisID+" and newAccno = "+newAccno);

        	PreparedStatement pstmt = conn.prepareStatement(query,
                                        	ResultSet.TYPE_SCROLL_INSENSITIVE,
                                        	ResultSet.CONCUR_UPDATABLE);
                pstmt.setString(1, newAccno);
                pstmt.setInt(2, submisID);

                pstmt.executeUpdate();
	}

	/**
	 * Creates a record in the public_experiments table.
	 * @param expID	the ID of the experiment
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 */
	public void createPublicExperiment (int expID, Connection conn) throws SQLException {

        	String query =
                	"insert into PUBLIC_EXPERIMENTS "+
			"(exp_id) values "+
			"(?)";

		log.debug("in createPublicExperiment. expID = "+expID);

        	PreparedStatement pstmt = conn.prepareStatement(query, 
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
                pstmt.setInt(1, expID);

                pstmt.executeUpdate();

	}
	
	/** 
	 * Returns the names of the image files generated by the Affy QC process.
	 * @param arrayName	the hybrid name
	 * @return	a String array of file names
	 */
	public String[] getAffyImageFileNames(String arrayName) {
		return new String[] {
			arrayName.replaceAll("[\\s]", "_") + "_Image.weights.png",
                        arrayName.replaceAll("[\\s]", "_") + "_Image.resids.png",
                        arrayName.replaceAll("[\\s]", "_") + "_Image.pos.resids.png",
                        arrayName.replaceAll("[\\s]", "_") + "_Image.neg.resids.png",
                        arrayName.replaceAll("[\\s]", "_") + "_Image.sign.resids.png"
			};
	}

	/** 
	 * Returns the names of the maplot files generated by the Affy QC process.
	 * @param arrayName	the hybrid name
	 * @return	a String array of file names
	 */
	public String[] getAffyMaplotFileNames(String arrayName) {
		return new String[] {
			arrayName.replaceAll("[\\s]", "_") + "_MAplot.png"
			};
	}

	/** 
	 * Returns the names of the image and maplot files generated by the Affy QC process.
	 * @param arrayName	the hybrid name
	 * @return	a String array of file names
	 */
	public String[] getAffyQCFileNames(String arrayName) {
		List<String> imageFiles = Arrays.asList(getAffyImageFileNames(arrayName));
		List<String> maplotFiles = Arrays.asList(getAffyMaplotFileNames(arrayName));
		List<String> allFilesList = new ArrayList<String>();
		allFilesList.addAll(imageFiles);
		allFilesList.addAll(maplotFiles);
		String[] allFiles = myObjectHandler.getAsArray(allFilesList, String.class);
		return allFiles;
	}

	/** 
	 * Returns the names of the image files generated by the CodeLink QC process.
	 * @param arrayName	the hybrid name
	 * @return	a String array of file names
	 */
	public String[] getCodeLinkImageFileNames(String arrayName) {
		return new String[] {
			arrayName.replaceAll("[\\s]", "_") + ".png"
			};
	}

	/**
	 * Gets all the expression resources
	}

        /**
         * Updates the status of the submission (e.g., from 'curated' to 'in process')
	 * @param submisID the identifier of the submission
	 * @param status the status to update it to
         * @param conn  the database connection
         * @throws SQLException if an error occurs while accessing the database
         */
	public void updateSubmissionStatus (int submisID, String status, Connection conn) throws SQLException {

        	String query =
                	"update experiments "+
			"set proc_status = ? "+
			"where subid = ?";


		log.debug("in updateSubmissionStatus. submisID = "+submisID);

        	PreparedStatement pstmt = conn.prepareStatement(query, 
						ResultSet.TYPE_SCROLL_INSENSITIVE,
						ResultSet.CONCUR_UPDATABLE);
                pstmt.setString(1, status);
                pstmt.setInt(2, submisID);

                pstmt.executeUpdate();
  	}


        /**
         * Updates the hybridization details of an array record 
	 * @param thisArray the Array object to update
	 * @param userLoggedIn User object that is logged in
         * @param conn  the database connection
         * @throws SQLException if an error occurs while accessing the database
         */
        public void updateHybridizationStuff(Array thisArray, User userLoggedIn, Connection conn) throws SQLException {

		log.debug("in updateHybridizationStuff hybrid_id = "+hybrid_id);

                String query = 
                        "update hybridizations "+
                        "set protocol_id = ?, scan_protocol_id = ?, "+
                        "array_id = ? "+
                        //"thybrid_fileid = ?, 
			"where hybrid_id = ? ";

                log.debug("query =  " + query);

		Protocol myProtocol = new Protocol();
                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

                PreparedStatement pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

		Tarray myTarray = new Tarray();
		int designID = thisArray.getTarray_designid();
		int arrayID = myTarray.getTarrayForDesignID(designID, conn).getTarray_sysuid();
		if (arrayID == -99) {
			arrayID = myTarray.createNewTarrayForDesignID(designID, userLoggedIn, conn);
                }
		Protocol hybridProtocol = myProtocol.getProtocol(thisArray.getHybrid_protocol_id(), conn);
		int protocolid = (hybridProtocol != null ? hybridProtocol.getProtocol_id() : 
			myProtocol.createForPublicProtocol(userLoggedIn, 
							thisArray.getHybrid_protocol_id(), HYBRID_TYPE, conn)); 
		log.debug("arrayHybrid_protocolis =" +thisArray.getHybrid_protocol_id());
		log.debug("hybridProtocol is null ?  " +(hybridProtocol != null ? "false" : "true"));
		log.debug("protocolid = " +protocolid);

		Protocol scanProtocol = myProtocol.getProtocol(thisArray.getHybrid_scan_protocol_id(), conn);
		int scanProtocolid = (scanProtocol != null ? scanProtocol.getProtocol_id() : 
			myProtocol.createForPublicProtocol(userLoggedIn, 
							thisArray.getHybrid_scan_protocol_id(), SCAN_TYPE, conn)); 
		log.debug("arrayScan_protocolid =" +thisArray.getHybrid_scan_protocol_id());
		log.debug("scanProtocol is null ?  " +(scanProtocol != null ? "false" : "true"));
		log.debug("scanProtocolid = " +scanProtocolid);

                pstmt.setInt(1, protocolid);
                pstmt.setInt(2, scanProtocolid);
                pstmt.setInt(3, arrayID);
                pstmt.setInt(4, thisArray.getHybrid_id());
                pstmt.executeUpdate();
                pstmt.close();
	}

        /**
         * Updates the protocol details of an array record 
	 * @param thisArray the Array object to update
	 * @param userLoggedIn User object that is logged in
         * @param conn  the database connection
         * @throws SQLException if an error occurs while accessing the database
         */
        public void updateProtocolStuff(Array thisArray, User userLoggedIn, Connection conn) throws SQLException {

		log.debug("in updateProtocolStuff hybrid_id = "+hybrid_id);
		Protocol myProtocol = new Protocol();
                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

                String query = 
                        "update tsample "+
                        "set tsample_growth_protocolid = ?, "+
			"tsample_last_change = ? "+
			"where tsample_sysuid = ?";

                log.debug("query =  " + query);


                PreparedStatement pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);


		int gpid = thisArray.getTsample_growth_protocolid();
		log.debug("gpid = "+gpid);
		// Don't need to do create a new record because there are no public protocols for growth
		//if (gpid != 0) {
		//	Protocol growthProtocol = myProtocol.getProtocol(gpid, conn);
			//gpid = (growthProtocol != null ? growthProtocol.getProtocol_id() : 
			//	myProtocol.createForPublicProtocol(userLoggedIn, 
			//					gpid, GROWTH_TYPE, conn)); 
		//	log.debug("now gpid = "+gpid);
		//}
		myDbUtils.setToNullIfZero(pstmt, 1, gpid);
                pstmt.setTimestamp(2, now);
                pstmt.setInt(3, thisArray.getTsample_sysuid());

                pstmt.executeUpdate();
                pstmt.close();

                query = 
                        "update textract "+
                        "set textract_id = ?, "+
			"textract_protocolid = ?, "+
			"textract_last_change = ? "+
			"where textract_sysuid = ?";

                pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

		int extpid = thisArray.getTextract_protocolid();
		log.debug("extpid = "+extpid);
		Protocol extractProtocol = myProtocol.getProtocol(extpid, conn);
		extpid = (extractProtocol != null ? extractProtocol.getProtocol_id() : 
				myProtocol.createForPublicProtocol(userLoggedIn, 
						extpid, EXTRACT_TYPE, conn)); 
		log.debug("now extpid = "+extpid);

                pstmt.setString(1, thisArray.getTextract_id());
		pstmt.setInt(2, extpid);
                pstmt.setTimestamp(3, now);
                pstmt.setInt(4, thisArray.getTextract_sysuid());

                pstmt.executeUpdate();
                pstmt.close();

                query = 
                        "update tlabel "+
                        "set tlabel_id = ?, "+
			"tlabel_protocolid = ?, "+
			"tlabel_last_change = ? "+
			"where tlabel_sysuid = ?";

                pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

		int labpid = thisArray.getTlabel_protocolid();
		log.debug("labpid = "+labpid);
		Protocol labelProtocol = myProtocol.getProtocol(labpid, conn);
		labpid = (labelProtocol != null ? labelProtocol.getProtocol_id() : 
				myProtocol.createForPublicProtocol(userLoggedIn, 
						labpid, EXTRACT_TYPE, conn)); 
		log.debug("now labpid = "+labpid);

                pstmt.setString(1, thisArray.getTlabel_id());
		pstmt.setInt(2, labpid);
                pstmt.setTimestamp(3, now);
                pstmt.setInt(4, thisArray.getTlabel_sysuid());

                pstmt.executeUpdate();
                pstmt.close();

	}

        /**
         * Updates the treatment details of an array record 
	 * @param thisArray the Array object to update
	 * @param userLoggedIn User object that is logged in
         * @param conn  the database connection
         * @throws SQLException if an error occurs while accessing the database
         */
        public void updateTreatmentStuff(Array thisArray, User userLoggedIn, Connection conn) throws SQLException {

		log.debug("in updateTreatmentStuff hybrid_id = "+hybrid_id);

                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

                String query = 
                        "update tfctrval "+
                        "set tfctrval_freetext = ?, "+
			"tfctrval_last_change = ? "+
			"where tfctrval_expfctrid = "+
			"	(select term_id "+
			"	from valid_terms "+
			"	where value = 'compound' "+
			"	and category = 'EXPERIMENTAL_FACTOR') "+
			"and tfctrval_sampleid = ?";

                log.debug("query =  " + query);


                PreparedStatement pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                pstmt.setString(1, (thisArray.getCompound().equals("None") ? "" : thisArray.getCompound()));
                pstmt.setTimestamp(2, now);
                pstmt.setInt(3, thisArray.getTsample_sysuid());

                pstmt.executeUpdate();
                pstmt.close();

                query = 
                        "update tfctrval "+
                        "set tfctrval_freetext = ?, "+
                        "tfctrval_freetextunit = ?, "+
			"tfctrval_last_change = ? "+
			"where tfctrval_expfctrid = "+
			"	(select term_id "+
			"	from valid_terms "+
			"	where value = 'dose' "+
			"	and category = 'EXPERIMENTAL_FACTOR') "+
			"and tfctrval_sampleid = ?";

                log.debug("query =  " + query);

                pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

		String rawDose = (thisArray.getDose().equals("None") ? "" : thisArray.getDose());
		String dose = (rawDose.equals("") ? "" :rawDose.substring(0, rawDose.indexOf(" ")));
		String doseUnit = (rawDose.equals("") ? "" : rawDose.substring(rawDose.indexOf(" ") + 1));
		log.debug("dose = "+dose);
		log.debug("doseUnit = "+doseUnit);

                pstmt.setString(1, dose); 
                pstmt.setString(2, doseUnit); 
                pstmt.setTimestamp(3, now);
                pstmt.setInt(4, thisArray.getTsample_sysuid());

                pstmt.executeUpdate();
                pstmt.close();

                query = 
                        "update tfctrval "+
                        "set tfctrval_freetext = ?, "+
                        "tfctrval_freetextunit = ?, "+
			"tfctrval_last_change = ? "+
			"where tfctrval_expfctrid = "+
			"	(select term_id "+
			"	from valid_terms "+
			"	where value = 'other' "+
			"	and category = 'EXPERIMENTAL_FACTOR') "+
			"and tfctrval_sampleid = ?";

                log.debug("query =  " + query);

                pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                pstmt.setString(1, (thisArray.getTreatment().equals("No Treatment") ? "" : thisArray.getTreatment()));
                pstmt.setString(2, (thisArray.getDuration().equals("None") ? "" : thisArray.getDuration()));
                pstmt.setTimestamp(3, now);
                pstmt.setInt(4, thisArray.getTsample_sysuid());

                pstmt.executeUpdate();
                pstmt.close();

                query = 
                        "update tsample "+
                        "set tsample_protocolid = ?, "+
			"tsample_last_change = ? "+
			"where tsample_sysuid = ?";

                log.debug("query =  " + query);

                pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);


		int tid = thisArray.getTsample_protocolid();
		log.debug("tid = "+tid);

		myDbUtils.setToNullIfZero(pstmt, 1, tid);
                pstmt.setTimestamp(2, now);
                pstmt.setInt(3, thisArray.getTsample_sysuid());

                pstmt.executeUpdate();
                pstmt.close();
	}

        /**
         * Updates the additional sample details of an array record 
	 * @param thisArray the Array object to update
	 * @param userLoggedIn User object that is logged in
         * @param conn  the database connection
         * @throws SQLException if an error occurs while accessing the database
         */
        public void updateAdditionalSampleStuff(Array thisArray, User userLoggedIn, Connection conn) throws SQLException {

		log.debug("in updateAdditionalSampleStuff hybrid_id = "+hybrid_id);

                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

                String query = 
                        "update tsample "+
                        "set tsample_individual_gen = ?, "+
			"tsample_cell_line = ?, "+
			"tsample_strain = ?, "+
			"tsample_target_cell_type = ?, "+
			"tsample_disease_state = ?, "+
			"tsample_additional = ?, "+
			"tsample_last_change = ? "+
			"where tsample_sysuid = ?";

                log.debug("query =  " + query);

                PreparedStatement pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                pstmt.setString(1, (thisArray.getIndividual_genotype().equals("None") ? "" : thisArray.getIndividual_genotype()));
                pstmt.setString(2, (thisArray.getCell_line().equals("None") ? "" : thisArray.getCell_line()));
                pstmt.setString(3, (thisArray.getStrain().equals("None") ? "" : thisArray.getStrain()));
                pstmt.setString(4, thisArray.getTarget_cell_type());
                pstmt.setString(5, thisArray.getDisease_state());
                pstmt.setString(6, thisArray.getAdditional());
                pstmt.setTimestamp(7, now);
                pstmt.setInt(8, thisArray.getTsample_sysuid());

                pstmt.executeUpdate();
                pstmt.close();

	}

        /**
         * Updates the basic sample details of an array record 
	 * @param thisArray the Array object to update
	 * @param userLoggedIn User object that is logged in
         * @param conn  the database connection
         * @throws SQLException if an error occurs while accessing the database
         */
        public void updateBasicSampleStuff(Array thisArray, User userLoggedIn, Connection conn) throws SQLException {

		log.debug("in updateBasicSampleStuff hybrid_id = "+hybrid_id);

                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

                String query = 
                        "update hybridizations "+
			"set name = ? "+
			"where hybrid_id = ?";

                PreparedStatement pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                pstmt.setString(1, thisArray.getHybrid_name());
                pstmt.setInt(2, thisArray.getHybrid_id());

                pstmt.executeUpdate();
                pstmt.close();

		query =
                        "update tsample "+
                        "set tsample_id = ?, "+
			"tsample_taxid = ?, "+
			"tsample_sex = ?, "+
			"tsample_organism_part = ?, "+
			"tsample_sample_type = ?, "+
			"tsample_dev_stage = ?, "+
			"tsample_agerange_min = ?, "+
			"tsample_agerange_max = ?, "+
			"tsample_time_unit = ?, "+
			"tsample_genetic_variation = ?, "+
			"tsample_individual = ?, "+
			"tsample_last_change = ? "+
			"where tsample_sysuid = ?";

                log.debug("query =  " + query);

                pstmt = conn.prepareStatement(query, 
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                pstmt.setString(1, thisArray.getSample_name());
                pstmt.setInt(2, thisArray.getTsample_taxid());
                pstmt.setInt(3, thisArray.getTsample_sex());
                pstmt.setInt(4, thisArray.getTsample_organism_part());
                pstmt.setInt(5, thisArray.getTsample_sample_type());
                pstmt.setInt(6, thisArray.getTsample_dev_stage());
                pstmt.setDouble(7, thisArray.getAge_range_min());
                pstmt.setDouble(8, thisArray.getAge_range_max());
                pstmt.setInt(9, thisArray.getTsample_time_unit());
                pstmt.setInt(10, thisArray.getTsample_genetic_variation());
                pstmt.setString(11, thisArray.getIndividual_identifier());
                pstmt.setTimestamp(12, now);
                pstmt.setInt(13, thisArray.getTsample_sysuid());

                pstmt.executeUpdate();
                pstmt.close();

		handleTothers(thisArray.getOtherBiosource_type(), "SAMPLE_TYPE", thisArray.getTsample_sysuid(), userLoggedIn, conn);
		handleTothers(thisArray.getOtherOrganismPart(), "ORGANISM_PART", thisArray.getTsample_sysuid(), userLoggedIn, conn);
		handleTothers(thisArray.getOtherDevStage(), "DEVELOPMENTAL_STAGE", thisArray.getTsample_sysuid(), userLoggedIn, conn);
	}


	private void handleTothers (String field, String type, int sampleID, User userLoggedIn, Connection conn) throws SQLException {
		log.debug("in handleTothers. field = "+field + ", type = " + type + ", sample = "+sampleID);

		if (field != null && !field.equals("")) {
			Tothers existingTothers = new Tothers().getTothersForSampleByType(sampleID, type, conn); 
			if (existingTothers != null) {
				log.debug("one already exists, so deleting it");
				existingTothers.deleteAndCommit(conn);
			}
                        Tothers tothers = new Tothers();
			tothers.setTothers_sampleid(sampleID);
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
	 * Creates an array of ArrayCount objects, and sets the attributes to those retrieved in myResults.
	 * @param myResults	a Results object containing values retrieved from a query
	 * @return            an array of ArrayCount objects
	 */
	public ArrayCount[] setupArrayCounts(Results myResults) {
		String[] dataRow;
	
		ArrayCount[] myArrayCounts = new ArrayCount[myResults.getNumRows()];

		int i=0;
        	while ((dataRow = myResults.getNextRow()) != null) {
			if (dataRow.length > 4 && dataRow[4] != null && !dataRow[4].equals("")) {
				myArrayCounts[i] = new ArrayCount(dataRow[0],
						Integer.parseInt(dataRow[1]),
						Integer.parseInt(dataRow[2]),
						Integer.parseInt(dataRow[3]),
						dataRow[4]);
			} else {
				myArrayCounts[i] = new ArrayCount(dataRow[0],
						Integer.parseInt(dataRow[1]),
						Integer.parseInt(dataRow[2]),
						Integer.parseInt(dataRow[3]));
			}
			i++;
		}
		return myArrayCounts;
	}

	/**
	 * Retrieves the number of arrays from the database.  
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getArrayCount(Connection conn) throws SQLException {
		String query = 
			"select 'All', "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id"; 

		log.debug ("in Array.getArrayCount");
		//log.debug("query = "+query);
		Results myResults = new Results(query, conn);

		ArrayCount[] myArrayCounts = setupArrayCounts(myResults);
		myResults.close();

		return myArrayCounts;
	}

	/**
	 * Retrieves the organisms and the number of arrays from the database.  It can be called to display 
	 * organisms from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getArrayOrganisms(String hybridIDs, String channel, Connection conn) throws SQLException {

		//log.debug ("in Array.getArrayOrganisms");
		String query = 
			"select distinct nvl(decode(expDetails.tntxsyn_name_txt, 'Mus musculus', expDetails.tntxsyn_name_txt, "+ 
			"							'Rattus norvegicus', expDetails.tntxsyn_name_txt, "+
			"							'Other'), 'No Value Entered'), "+
			// AAGH!  Have to select this in order to order by it! Also, have to remove the pub and nonpub
			// in order to return only one row for 'Other'
			"decode(expDetails.tntxsyn_name_txt, 'Mus musculus', 1, 'Rattus norvegicus', 2, 3), "+
			"0, "+
			"0 "+
			//"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			//"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			//"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"group by expDetails.tntxsyn_name_txt "+
			"order by decode(expDetails.tntxsyn_name_txt, 'Mus musculus', 1, "+ 
			"		'Rattus norvegicus', 2, "+
			"		3)";

		//log.debug("query = "+query);
		ArrayCount[] myArrayCounts = null;

                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
  	}

	/**
	 * Retrieves the array types and the number of arrays from the database.  It can be called to display 
	 * array types from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getArrayTypes(String hybridIDs, String channel, Connection conn) throws SQLException {

		//log.debug ("in Array.getArrayTypes");
		String query = 
			"select distinct "+ 
			"case when tardesin_design_name is null then ebi_array_description else tardesin_design_name end, "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id, "+
			"TARRAY left join TARDESIN on tarray_designid = tardesin_sysuid "+
			"left join EBI_ARRAY_DESIGNS on tarray_designid*-1 = EBI_ARRAY_SYSUID "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"and tarray_del_status = 'U' "+
			"and expDetails.hybrid_array_id = TARRAY.tarray_sysuid ";

		query = query + 
			"group by case when tardesin_design_name is null then ebi_array_description else tardesin_design_name end "+
			"order by 1";

		//log.debug("query = "+query);
		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
  	}



	/**
	 * Retrieves the the maximum experiment accession number
         * currently in the database and increments it by 1.
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a String ('E-UCOL-' plus the next number)
	 */
  	public String getNextAccno(Connection conn) throws SQLException {

		String query =
                	"select concat('E-UCOL-',substring(max(accno),8) + 1) "+
			"from experiments";

                //log.debug("query = "+query); 

                Results myResults = new Results(query, conn);

		String experimentAccno = "";

                experimentAccno = myResults.getStringValueFromFirstRow();

		if (experimentAccno == null || experimentAccno.equals("")) {
                        experimentAccno = "E-UCOL-1";
                }

                myResults.close();

  		return experimentAccno;

	}

	/**
         * Retrieves the location of the topmost directory for storing arrays
	 * @param userFilesRoot	the topmost directory for storing files
	 * @return            a String containing the directory
	 */
	public String getArrayDataFilesLocation(String userFilesRoot) {
                return userFilesRoot + "Array_datafiles/";
	}

	/**
         * Retrieves the location of the topmost directory for uploading experiments
	 * @param userFilesRoot	the topmost directory for storing files
	 * @return            a String containing the directory
	 */
	public String getExperimentDataFilesLocation(String userFilesRoot) {
                String experimentDataFilesLocation = userFilesRoot + "experiment_datafiles/" + 
						"experiments/";
		//log.debug("experimentDataFilesLocation = "+experimentDataFilesLocation);

		return experimentDataFilesLocation;
	}

	/**
         * Retrieves the location of the raw data files uploaded for experiments
	 * @param userFilesRoot	the topmost directory for storing files
	 * @return            a String containing the full path of the file location
	 */
	public String getRawDataFileLocation(String userFilesRoot) {
                	String rawDataFileLocation = getExperimentDataFilesLocation(userFilesRoot) + 
                                        	this.getSubmitter() + "/" +
                                        	"submission" + this.getSubmis_id() + "/" +
                                        	"hybrid" + this.getHybrid_id() + "/";

		//log.debug("rawDataFileLocation = "+rawDataFileLocation);

		return rawDataFileLocation;
	}


	/**
	 * Checks whether the user has been granted access to this array.
	 * @param userID	the identifier of the user 
	 * @param hybrid_id	the identifier of the array in the database
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            true if this user has been granted access to the array, false otherwise
	 */
	public boolean userHasAccess(int userID, int hybrid_id, Connection conn) throws SQLException {

        	log.debug("in userHasAccess. userID = "+userID+", hybrid_id = "+hybrid_id);

        	String query =
                	"select approved "+
                	"from user_chips uc "+
                	"where user_id = ? "+
			"and hybrid_id = ?";
		//log.debug("query = "+query);

		Results myResults = new Results(query, userID, hybrid_id, conn);
		String[] dataRow;
		boolean userHasAccess = false;

        	while ((dataRow = myResults.getNextRow()) != null) {
			log.debug("dataRow[0] equals"+dataRow[0]);
			if (dataRow[0].equals("1")) {
				userHasAccess = true;
			}
		}
		if (myResults != null) { myResults.close(); }

        	return userHasAccess;
	}

	/**
	 * This query retrieves the names of arrays and the type of access that has been granted.
	 * @param userID	the identifier of the user 
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a Hashtable mapping hybrid_id to approved
	 */
	public Hashtable getMyUniqueArrays(int userID, Connection conn) throws SQLException {

        	String query =
                	"select distinct hybrid_id, approved "+
                	"from user_chips uc "+
                	"where user_id = ? "+
                	"order by 1";

        	log.debug("in getMyUniqueArrays. user_id = "+userID);
		//log.debug("query = "+query);

		Results myResults = new Results(query, userID, conn);
		String[] dataRow;
		Hashtable<String,String> arrayAccess = new Hashtable<String,String>();
                while ((dataRow = myResults.getNextRow()) != null) {
                	arrayAccess.put(dataRow[0], dataRow[1]);
                }

		myResults.close();
        	return arrayAccess;
	}

	/**
	 * Gets all the details about a particular array.
	 * @param arrayID	the hybrid id of the array
	 * @param conn      the PhenoGen database connection
	 * @throws            SQLException if a database error occurs
	 * @return           an Array object 
	 */
	public Array getSampleDetailsForHybridID(int arrayID, Connection conn) throws SQLException {

		log.debug("in getSampleDetailsForHybridID.  arrayID = "+arrayID);

		Array myArray = getArraysByHybridIDs("(" + arrayID + ")", conn)[0];

		// Get experiment design type
		String query = 
			"select distinct a.value "+
			//"from CuratedExperimentDetails expDetails, "+
			//Assume this is correct since querying by hybridID
			"from ExperimentDetails expDetails, "+
			"valid_terms a, "+
			"TEXPRTYP et "+
			"where et.texprtyp_del_status = 'U' "+
			"and et.texprtyp_id = a.term_id "+
			"and expDetails.exp_id = et.texprtyp_exprid "+
			"and a.category = 'EXPERIMENT_TYPE' "+
			"and expDetails.hybrid_id = ? "+
			"order by 1";

        	//log.debug("query = "+query);

                Results myResults = new Results(query, arrayID, conn);

		if (myResults != null) {
			log.debug("setting up experiment design types ");
			myArray.setExperiment_design_types(myObjectHandler.getResultsAsSeparatedString(myResults, ", ", "", 0));
		} else {
			log.debug("no Results for experiment design types");
		}

		myResults.close();

		// Get experimental factors
		query = 
			"select distinct a.value "+
			//"from CuratedExperimentDetails expDetails, "+
			//Assume this is correct since querying by hybridID
			"from ExperimentDetails expDetails, "+
			"valid_terms a, "+
			"TEXPFCTR ef "+
			"where ef.texpfctr_del_status = 'U' "+
			"and ef.texpfctr_id = a.term_id "+
			"and expDetails.exp_id = ef.texpfctr_exprid "+
			"and a.category = 'EXPERIMENTAL_FACTOR' "+
			"and expDetails.hybrid_id = ? "+
			"order by 1";

        	//log.debug("query = "+query);

                myResults = new Results(query, arrayID, conn);

		if (myResults != null) {
			log.debug("setting up experimental factors ");
			myArray.setExperimental_factors(myObjectHandler.getResultsAsSeparatedString(myResults, ", ", "", 0));
		} else {
			log.debug("no Results for experimental factors");
		}
		myResults.close();

        	return myArray;
	}

	/**
	 * Gets the information from the database about the arrays in the submission.
	 * @param submisID	the submission ID
	 * @param conn	the database connection to the PhenoGen database 
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Array objects
	 */
	public Array[] getArraysForSubmission(int submisID, Connection conn) throws SQLException {
		log.debug ("in Array.getArraysForSubmission");
		
		return getArrays("", submisID, conn);
	}

	/**
	 * Gets the information from the database about the arrays contained in the hybridIDs string.
	 * @param hybridIDs	a comma-delimited string of hybrid IDs
	 * @param conn	the database connection to the PhenoGen database 
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Array objects
	 */
	public Array[] getArraysByHybridIDs(String hybridIDs, Connection conn) throws SQLException {
		log.debug ("in Array.getArraysByHybridIDs");

		hybridIDs = (hybridIDs.equals("") ? "()" : hybridIDs);
		return getArrays(hybridIDs, -99, conn);
	}
	
	/**
	 * Gets the information from the database about the arrays contained in the hybridIDs string or the submisID.
	 * The numerous joins to valid_terms retrieve the actual values for the encoded fields. 
	 * @param hybridIDs	a comma-delimited string of hybrid IDs
	 * @param submisID	the submission ID
	 * @param conn	the database connection to the PhenoGen database 
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Array objects
	 */
	public Array[] getArrays(String hybridIDs, int submisID, Connection conn) throws SQLException {

		log.debug ("in Array.getArrays");

		// Split this query into 2 parts, which together run faster than the combined query did
		String query = 
			// cannot select distinct when selecting Clobs
			//"select distinct expDetails.file_id, "+
			"select expDetails.file_id, "+
			"expDetails.hybrid_id, "+
			"expDetails.hybrid_name, "+
			"expDetails.path, "+
			"expDetails.hybrid_id, "+
			"expDetails.subid, "+
			"expDetails.tntxsyn_name_txt, "+
			"expDetails.tsample_cell_provider, "+
			"case when sample_type.value = 'other' then "+
			"otherSampleType.tothers_value else sample_type.value end, "+
			"case when dev_stage.value = 'other' then "+
			"otherDevStage.tothers_value else dev_stage.value end, "+
			"age_status.value, "+
			"expDetails.tsample_agerange_min, "+
			"expDetails.tsample_agerange_max, "+
			"age_unit.value, "+
			"initial_time_point.value, "+
			"case when organism_part.value = 'other' then "+
			"otherOrganismPart.tothers_value else organism_part.value end, "+
			"gender.value, "+
			"genetic_variation.value, "+
			"expDetails.tsample_individual, "+
			"expDetails.tsample_individual_gen, "+
			"expDetails.tsample_disease_state, "+
			"separation_tech.value, "+
			"expDetails.tsample_target_cell_type, "+
			"expDetails.tsample_cell_line, "+
			"expDetails.tsample_additional, "+
                	"case when upper(expDetails.path) like '%CEL' then 'Affymetrix' "+
			"when upper(expDetails.path) like '%GPR' then 'cDNA' "+
			"when upper(expDetails.path) like '%SPOT' then 'cDNA' "+
			"when upper(expDetails.path) like '%TXT' then 'CodeLink' else 'unknown' end, "+
			"expDetails.exp_created_by_login, "+
			"expDetails.subid, "+
			"expDetails.exp_id, "+
			"expDetails.exp_name, "+
			"expDetails.tsample_sysuid, "+
			"expDetails.tsample_strain, "+
			//Did this to make creating groups easier
                        //"substr(expDetails.tsample_strain, 0, instr(expDetails.tsample_strain, 'Te')-2), "+
			"treatment.tfctrval_freetext, "+
			"treatment.tfctrval_freetextunit, "+
			"case when tardesin_design_name is null then ebi_array_description "+
			"else tardesin_design_name end, "+
			"pe.exp_id, "+
			"expDetails.tsample_id "+
			"from experimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			", " + 
			"TSAMPLE sample2 left join TOTHERS otherOrganismPart "+
				"on sample2.tsample_sysuid = otherOrganismPart.tothers_sampleid "+
				"and otherOrganismPart.tothers_id = 'ORGANISM_PART' "+
				"and otherOrganismPart.tothers_del_status = 'U', "+
/*
			"TSAMPLE sample3 left join TOTHERS otherGV "+
				"on sample3.tsample_sysuid = otherGV.tothers_sampleid "+
				"and otherGV.tothers_id = 'GENETIC_VARIATION' "+
				"and otherGV.tothers_del_status = 'U', "+
*/
			"TSAMPLE sample10 left join TOTHERS otherDevStage "+
				"on sample10.tsample_sysuid = otherDevStage.tothers_sampleid "+
				"and otherDevStage.tothers_id = 'DEVELOPMENTAL_STAGE' "+
				"and otherDevStage.tothers_del_status = 'U', "+
			"TSAMPLE sample9 left join TOTHERS otherSampleType "+
				"on sample9.tsample_sysuid = otherSampleType.tothers_sampleid "+
				"and otherSampleType.tothers_id = 'SAMPLE_TYPE' "+
				"and otherSampleType.tothers_del_status = 'U', "+
			"TSAMPLE sample4 left join TFCTRVAL treatment "+
				"on treatment.tfctrval_sampleid = sample4.tsample_sysuid "+
				// hard-coding to experimental factor of 'other', which is where the treatment field is located
				"and treatment.tfctrval_expfctrid = 443 "+
				"and treatment.tfctrval_del_status = 'U', "+
			//"TARRAY left join TARDESIN on tarray_designid = tardesin_sysuid "+
			//"left join EBI_ARRAY_DESIGNS on tarray_designid*-1 = EBI_ARRAY_SYSUID, "+

			"TARRAY left join TARDESIN on tarray_designid = tardesin_sysuid "+
			"left join EBI_ARRAY_DESIGNS on tarray_designid*-1 = EBI_ARRAY_SYSUID, "+
			"valid_terms gender, "+
			"valid_terms sample_type, "+
			"valid_terms dev_stage, "+
			"valid_terms age_status, "+
			"valid_terms age_unit, "+
			"valid_terms initial_time_point, "+
			"valid_terms genetic_variation, "+
			"valid_terms separation_tech, "+
			"valid_terms organism_part "+
			"where expDetails.hybrid_array_id = TARRAY.tarray_sysuid "+
			"and expDetails.tsample_sex = gender.term_id "+
			"and expDetails.tsample_sample_type = sample_type.term_id "+
			"and expDetails.tsample_dev_stage = dev_stage.term_id "+
			"and expDetails.tsample_age_status = age_status.term_id "+
			"and expDetails.tsample_time_unit = age_unit.term_id "+
			"and expDetails.tsample_time_point = initial_time_point.term_id "+
			"and expDetails.tsample_genetic_variation = genetic_variation.term_id "+
			"and expDetails.tsample_separation_tech = separation_tech.term_id "+
			"and expDetails.tsample_organism_part = organism_part.term_id "+
			"and expDetails.tsample_sysuid = sample2.tsample_sysuid "+
			//"and expDetails.tsample_sysuid = sample3.tsample_sysuid "+
			"and expDetails.tsample_sysuid = sample9.tsample_sysuid "+
			"and expDetails.tsample_sysuid = sample10.tsample_sysuid "+
			"and expDetails.tsample_sysuid = sample4.tsample_sysuid ";

			query = query + (submisID == -99 ? 
				"and expDetails.hybrid_id in "+ hybridIDs :
				"and expDetails.subid = ? "); 

			query = query + 
			" order by "+
			"expDetails.hybrid_name";


		String query2 = 
			"select "+
			"expDetails.exp_description, "+
			"expDetails.textract_id, "+
			"expDetails.tlabel_id, "+
			"compounds.tfctrval_freetext, "+ 
			"nvl(doses.tfctrval_freetext||' '||doses.tfctrval_freetextunit, 'No Value Entered'), "+
			"expDetails.tsample_taxid, "+
			"expDetails.tsample_sex, "+
			"expDetails.tsample_organism_part, "+
			"expDetails.tsample_sample_type, "+
			"expDetails.tsample_dev_stage, "+
			"expDetails.tsample_time_unit, "+
			"expDetails.tsample_genetic_variation, "+
			"expDetails.tsample_protocolid, "+
			"expDetails.hybrid_array_id, "+
			"expDetails.textract_sysuid, "+
			"expDetails.tlabel_sysuid, "+
			"nvl(TARRAY.tarray_designid, -99), "+
			"gcprotocol.protocol_name, "+
			"gcprotocol.protocol_description, "+
			"stprotocol.protocol_name, "+
			"stprotocol.protocol_description, "+
			"eprotocol.protocol_name,  "+
			"eprotocol.protocol_description, "+
			"leprotocol.protocol_name, "+ 
			"leprotocol.protocol_description, "+
 			"hprotocol.protocol_name, "+ 
			"hprotocol.protocol_description, "+
 			"sprotocol.protocol_name, "+ 
			"sprotocol.protocol_description, "+
			"expDetails.tsample_growth_protocolid, "+
			"expDetails.textract_protocolid, "+
			"expDetails.tlabel_protocolid, "+
			"expDetails.hybrid_protocol_id, "+
			"expDetails.hybrid_scan_protocol_id "+
			//"from CuratedExperimentDetails expDetails "+
			// Changed this assuming the hybridIDs are retrieved correctly
			"from experimentDetails expDetails, "+
			"TSAMPLE sample5 left join protocols gcprotocol "+
				"on sample5.tsample_growth_protocolid = gcprotocol.protocol_id, "+
			"TSAMPLE sample6 left join protocols stprotocol "+
				"on sample6.tsample_protocolid = stprotocol.protocol_id, "+
 			"TSAMPLE sample7 left join compounds "+
				"on compounds.tfctrval_sampleid = sample7.tsample_sysuid, "+
 			"TSAMPLE sample8 left join doses "+
				"on doses.tfctrval_sampleid = sample8.tsample_sysuid, "+
			//"TARRAY left join TARDESIN on tarray_designid = tardesin_sysuid "+
			//"left join EBI_ARRAY_DESIGNS on tarray_designid*-1 = EBI_ARRAY_SYSUID, "+

			"TARRAY left join TARDESIN on tarray_designid = tardesin_sysuid "+
			"left join EBI_ARRAY_DESIGNS on tarray_designid*-1 = EBI_ARRAY_SYSUID, "+
 			"protocols eprotocol, "+ 
 			"protocols leprotocol, "+ 
			"protocols hprotocol, "+ 
			"protocols sprotocol "+ 
			"where expDetails.hybrid_array_id = TARRAY.tarray_sysuid "+
			"and expDetails.textract_protocolid = eprotocol.protocol_id "+
			"and expDetails.hybrid_protocol_id = hprotocol.protocol_id "+
			"and expDetails.hybrid_scan_protocol_id = sprotocol.protocol_id "+
			"and expDetails.tlabel_protocolid = leprotocol.protocol_id "+
			"and expDetails.tsample_sysuid = sample5.tsample_sysuid "+
			"and expDetails.tsample_sysuid = sample6.tsample_sysuid "+
			"and expDetails.tsample_sysuid = sample7.tsample_sysuid "+
			"and expDetails.tsample_sysuid = sample8.tsample_sysuid ";

			query2 = query2 + (submisID == -99 ? 
				"and expDetails.hybrid_id in "+ hybridIDs :
				"and expDetails.subid = ? "); 

			query2 = query2 + 
			" order by "+
			"expDetails.hybrid_name";

		//log.debug("query = "+query);
		//log.debug("query2 = "+query2);
		Array [] myArrays = null;

                Results myResults = (submisID == -99 ?  new Results(query, conn) :
                		new Results(query, submisID, conn)); 

                Results myResults2 = (submisID == -99 ?  new Results(query2, conn) :
                		new Results(query2, submisID, conn)); 

                myArrays = setupAllArrayValues(myResults, conn);

		int i=0;
		//
		// setup all values not done by setupAllArrayValues
		//
		Object[] dataRow;

		while ((dataRow = myResults2.getNextRowWithClob()) != null) {
			//log.debug("protocol results were not null");
			myArrays[i].setExperimentDescription(myResults2.getClobAsString(dataRow[0]));
			myArrays[i].setTextract_id((String) dataRow[1]);
			myArrays[i].setTlabel_id((String) dataRow[2]);
			myArrays[i].setCompound((String) dataRow[3]);
			myArrays[i].setDose((String)dataRow[4]);
                	if (dataRow[5] != null) {
				myArrays[i].setTsample_taxid(Integer.parseInt((String)dataRow[5]));
			}
                	if (dataRow[6] != null) {
				myArrays[i].setTsample_sex(Integer.parseInt((String)dataRow[6]));
			}
                	if (dataRow[7] != null) {
				myArrays[i].setTsample_organism_part(Integer.parseInt((String)dataRow[7]));
			}
                	if (dataRow[8] != null) {
				myArrays[i].setTsample_sample_type(Integer.parseInt((String)dataRow[8]));
			}
                	if (dataRow[9] != null) {
				myArrays[i].setTsample_dev_stage(Integer.parseInt((String)dataRow[9]));
			}
                	if (dataRow[10] != null) {
				myArrays[i].setTsample_time_unit(Integer.parseInt((String)dataRow[10]));
			}
                	if (dataRow[11] != null) {
				myArrays[i].setTsample_genetic_variation(Integer.parseInt((String)dataRow[11]));
			}
                	if (dataRow[12] != null) {
				myArrays[i].setTsample_protocolid(Integer.parseInt((String)dataRow[12]));
			}
                	if (dataRow[13] != null) {
				myArrays[i].setHybrid_array_id(Integer.parseInt((String)dataRow[13]));
			}
                	if (dataRow[14] != null) {
				myArrays[i].setTextract_sysuid(Integer.parseInt((String)dataRow[14]));
			}
                	if (dataRow[15] != null) {
				myArrays[i].setTlabel_sysuid(Integer.parseInt((String)dataRow[15]));
			}
                	if (dataRow[16] != null) {
				myArrays[i].setTarray_designid(Integer.parseInt((String)dataRow[16]));
			}

			myArrays[i].setGrowthConditionsProtocol((String) dataRow[17]);
			myArrays[i].setGrowthConditionsProtocolDescription(myResults2.getClobAsString(dataRow[18]));
			myArrays[i].setSampleTreatmentProtocol((String) dataRow[19]);
			myArrays[i].setSampleTreatmentProtocolDescription(myResults2.getClobAsString(dataRow[20]));
			myArrays[i].setExtractProtocol((String) dataRow[21]);
			myArrays[i].setExtractProtocolDescription(myResults2.getClobAsString(dataRow[22]));
			myArrays[i].setLabelExtractProtocol((String) dataRow[23]);
			myArrays[i].setLabelExtractProtocolDescription(myResults2.getClobAsString(dataRow[24]));
			myArrays[i].setHybridizationProtocol((String) dataRow[25]);
			myArrays[i].setHybridizationProtocolDescription(myResults2.getClobAsString(dataRow[26]));
			myArrays[i].setScanningProtocol((String) dataRow[27]);
			myArrays[i].setScanningProtocolDescription(myResults2.getClobAsString(dataRow[28]));
                	if (dataRow[29] != null) {
				myArrays[i].setTsample_growth_protocolid(Integer.parseInt((String)dataRow[29]));
			}
                	if (dataRow[30] != null) {
				myArrays[i].setTextract_protocolid(Integer.parseInt((String)dataRow[30]));
			}
                	if (dataRow[31] != null) {
				myArrays[i].setTlabel_protocolid(Integer.parseInt((String)dataRow[31]));
			}
                	if (dataRow[32] != null) {
				myArrays[i].setHybrid_protocol_id(Integer.parseInt((String)dataRow[32]));
			}
                	if (dataRow[33] != null) {
				myArrays[i].setHybrid_scan_protocol_id(Integer.parseInt((String)dataRow[33]));
			}
			i++;
		}

		myResults.close();
		myResults2.close();

		return myArrays;
	}

	/**
	 * **** THIS IS ONLY USED BY THE PHENOGEN ADMIN APPLICATION *** 
	 * Gets the experiments that are not in pending status.
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Experiment objects
	 */
	public Experiment[] getNonPendingExperiments(Connection conn) throws SQLException {

		log.debug("in getNonPendingExperiments");

        	String query =
                	"select exp_id, "+ 
			"exp_name, "+ 
			"created_by_login "+
                	"from experiments "+ 
                	"where proc_status != 'P' "+
			"order by exp_name";

	
		//log.debug("query = "+query);
        	Results myResults = new Results(query, conn);
		List <Experiment> experimentList = new ArrayList<Experiment>();

        	String[] dataRow;

        	while ((dataRow = myResults.getNextRow()) != null) {
        		Experiment thisExperiment = new Experiment();
                	thisExperiment.setExp_id(Integer.parseInt(dataRow[0]));
                	thisExperiment.setExpName(dataRow[1]);
        		thisExperiment.setExpNameNoSpaces(myObjectHandler.removeBadCharacters(dataRow[1]));
                	thisExperiment.setCreated_by_login(dataRow[2]);
			experimentList.add(thisExperiment);
        	}
        	myResults.close();

        	Experiment[] experimentArray = (Experiment[]) experimentList.toArray(
                                new Experiment[experimentList.size()]);

                return experimentArray;
	}

	/**
	 * Gets the valid array design types 
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a LinkedHashMap of ids and array design names
	 */
	public LinkedHashMap getArrayDesignTypes(Connection conn) throws SQLException {

		log.debug("in getArrayDesignTypes");
		String query = 
			"select tardesin_sysuid, "+
			"tardesin_design_name  "+
			"from tardesin "+
			"where tardesin_del_status = 'U' "+
			"and tardesin_design_name is not null "+
			"union "+
			"select ebi_array_sysuid*-1,  "+
			"ebi_array_description  "+
			"from ebi_array_designs "+
			"where ebi_array_description is not null "+
			"order by 2 "; 

		//log.debug("query = "+query);

        	Results myResults = new Results(query, conn);
		LinkedHashMap<String, String> arrayDesignTypes = myObjectHandler.getResultsAsLinkedHashMap(myResults);

                myResults.close();

                return arrayDesignTypes;
	}

	/**
	 * Gets the submitters that have uploaded experiments
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a Set of submitter login ids
	 */
	public Set getSubmitters(String hybridIDs, String channel, Connection conn) throws SQLException {

		log.debug("in getSubmitters");
		String query = 
			"select distinct "+
			"expDetails.exp_created_by_login "+
			"from CuratedExperimentDetails expDetails "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +  
			"order by expDetails.exp_created_by_login"; 

		//log.debug("query = "+query);

        	Results myResults = new Results(query, conn);
		Set<String> submitterSet = myObjectHandler.getResultsAsSet(myResults, 0);

                myResults.close();

                return submitterSet;
	}

	/**
	 * Gets the experiments that were uploaded by the people reporting to the user. 
	 * @param subordinates	a comma-delimited string of user_names that report to the user
	 * @param mageComplete 'Y' if the a MAGE file has already been created for this experiment, otherwise 'N' 	
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Experiment objects
	 */
	public Experiment[] getExperimentsUploadedBySubordinates(String subordinates, String mageComplete, Connection conn) 
									throws SQLException {

		log.debug("in getExperimentsUploadedBySubordinates");

        	String query =
                	"select exp_id, "+ 
			"exp_name, "+ 
			"created_by_login "+
                	"from experiments "+
                	"where created_by_login in "+
			subordinates + 
			" "+ 
                	"and proc_status = 'C' ";
			if (mageComplete.equals("Y")) {
				query = query + "and accno is not null ";
			}
			query = query + 
			"order by exp_name"; 

	
		//log.debug("query = "+query);
        	Results myResults = new Results(query, conn);
		List <Experiment> experimentList = new ArrayList<Experiment>();

        	String[] dataRow;

        	while ((dataRow = myResults.getNextRow()) != null) {
        		Experiment thisExperiment = new Experiment();
                	thisExperiment.setExp_id(Integer.parseInt(dataRow[0]));
                	thisExperiment.setExpName(dataRow[1]);
        		thisExperiment.setExpNameNoSpaces(myObjectHandler.removeBadCharacters(dataRow[1]));
                	thisExperiment.setCreated_by_login(dataRow[2]);
			experimentList.add(thisExperiment);
        	}
        	myResults.close();

        	Experiment[] experimentArray = (Experiment[]) experimentList.toArray(
                                new Experiment[experimentList.size()]);

                return experimentArray;
	}

	/**
	 * Gets the experiments that were uploaded by the people reporting to the user that have not yet been granted open access.
	 * @param subordinates	a comma-delimited string of user_names that report to the user
	 * @param mageComplete 'Y' if the a MAGE file has already been created for this experiment, otherwise 'N' 	
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Experiment objects
	 */
	public Experiment[] getExperimentsUploadedBySubordinatesNotPublic(String subordinates, String mageComplete, Connection conn) 
									throws SQLException {

		log.debug("in getExperimentsUploadedBySubordinatesNotPublic");

        	String query =
                	"select exp.exp_id, "+ 
			"exp.exp_name, "+ 
			"exp.created_by_login, "+
			"to_char(exp.exp_create_date, 'mm/dd/yyyy hh12:mi AM') " +
                	"from experiments exp left join PUBLIC_EXPERIMENTS p on p.exp_id = exp.exp_id "+
                	"where p.exp_id is null "+
			"and created_by_login in "+
			subordinates + 
			" "+ 
                	"and exp.proc_status = 'C' ";
			if (mageComplete.equals("Y")) {
				query = query + "and exp.accno is not null ";
			}
			query = query + 
			"order by exp_name"; 

	
		//log.debug("query = "+query);
        	Results myResults = new Results(query, conn);
		List <Experiment> experimentList = new ArrayList<Experiment>();

        	String[] dataRow;

        	while ((dataRow = myResults.getNextRow()) != null) {
        		Experiment thisExperiment = new Experiment();
                	thisExperiment.setExp_id(Integer.parseInt(dataRow[0]));
                	thisExperiment.setExpName(dataRow[1]);
        		thisExperiment.setExpNameNoSpaces(myObjectHandler.removeBadCharacters(dataRow[1]));
                	thisExperiment.setCreated_by_login(dataRow[2]);
                	thisExperiment.setExp_create_date_as_string(dataRow[3]);
			experimentList.add(thisExperiment);
        	}
        	myResults.close();

        	Experiment[] experimentArray = (Experiment[]) experimentList.toArray(
                                new Experiment[experimentList.size()]);

                return experimentArray;
	}

	/** 
	 * Retrieves the details of an experiment as a Experiment object.
	 * @param expID	the id of the experiment
	 * @param conn	the database connection
	 * @return	a Experiment object
	 * @throws	SQLException if a database error occurs
	 */
	public Experiment getExperiment(int expID, Connection conn) throws SQLException {

        	log.debug("in getExperiment as an Experiment object");

        	String query =
			"select to_char(expDetails.exp_name), "+
			"to_char(expDetails.exp_description), "+
			"expDetails.exp_created_by_login, "+
			"to_char(expDetails.exp_create_date, 'mm-dd-yyyy hh:mi am'), "+
			"count(*), "+
			"expDetails.tntxsyn_name_txt, "+
			"case when upper(expDetails.path) like '%CEL' then 'Affymetrix' "+
			"	when upper(expDetails.path) like '%GPR' then 'cDNA' "+
			"	when upper(expDetails.path) like '%SPOT' then 'cDNA' "+
			"	when upper(expDetails.path) like '%TXT' then 'CodeLink' else 'unknown' end, "+
			"max(case when tardesin_design_name is null then ebi_array_description else tardesin_design_name end), "+
			"expDetails.subid "+
			"from CuratedExperimentDetails expDetails, "+
			"TARRAY left join TARDESIN on tarray_designid = tardesin_sysuid "+
			"left join EBI_ARRAY_DESIGNS on tarray_designid*-1 = EBI_ARRAY_SYSUID "+
			"where expDetails.hybrid_array_id = TARRAY.tarray_sysuid "+
			"and expDetails.exp_id = ? "+
			"group by "+ 
			"to_char(expDetails.exp_name), "+
			"to_char(expDetails.exp_description), "+
			"expDetails.exp_created_by_login, "+
			"to_char(expDetails.exp_create_date, 'mm-dd-yyyy hh:mi am'), "+
			"expDetails.tntxsyn_name_txt, "+
			"case when upper(expDetails.path) like '%CEL' then 'Affymetrix' "+ 
			"	when upper(expDetails.path) like '%GPR' then 'cDNA' "+
			"	when upper(expDetails.path) like '%SPOT' then 'cDNA' "+
			"	when upper(expDetails.path) like '%TXT' then 'CodeLink' else 'unknown' end, "+
			"expDetails.subid "+
			"order by 3";
	
		//log.debug("query = " + query);

        	Results myResults = new Results(query, expID, conn);

        	String[] dataRow = myResults.getNextRow();

        	Experiment myExperiment = new Experiment();
                myExperiment.setExp_id(expID);
                myExperiment.setExpName(dataRow[0]);
        	myExperiment.setExpNameNoSpaces(myObjectHandler.removeBadCharacters(dataRow[0]));
                myExperiment.setExp_description(dataRow[1]);
                myExperiment.setCreated_by_login(dataRow[2]);
                myExperiment.setExp_create_date_as_string(dataRow[3]);
                myExperiment.setNum_samples(Integer.parseInt(dataRow[4]));
                myExperiment.setOrganism(dataRow[5]);
                myExperiment.setPlatform(dataRow[6]);
                myExperiment.setArray_type(dataRow[7]);
                myExperiment.setSubid(Integer.parseInt(dataRow[8]));

        	myResults.close();

        	return myExperiment;
	}

	/**
	 * Creates an array of Array objects, and sets the attributes to those retrieved in myResults.
	 * @param myResults	a Results object containing values retrieved from a query
	 * @param conn	the database connection to the PhenoGen database 
	 * @return            an array of ArrayCount objects
	 */
	public Array[] setupAllArrayValues(Results myResults, Connection conn) throws SQLException {
		Object[] dataRow;
        	Array [] myArrays = new Array[myResults.getNumRows()];

		int i=0;
        	//log.debug("in setupAllArrayValues.");

		while ((dataRow = myResults.getNextRowWithClob()) != null) {
			String hybridID = (String) dataRow[4];
			int submissionID = Integer.parseInt((String) dataRow[5]);
			String submitter = (String) dataRow[26];
			//log.debug("submitter = "+submitter);

			User myUser = new User();
                	int uploaded_by_user_id = myUser.getUser_id(submitter, conn);
                	int owner_user_id = myUser.getPi_user_id(uploaded_by_user_id, conn);

			myArrays[i] = new Array();

                	myArrays[i].setHybrid_id(Integer.parseInt((String) dataRow[1]));
                	myArrays[i].setHybrid_name((String) dataRow[2]);
                	myArrays[i].setFile_name((String) dataRow[3]);
                	myArrays[i].setSubmis_id(submissionID);
                	myArrays[i].setOrganism((String) dataRow[6]);
                	myArrays[i].setProvider((String) dataRow[7]);
                	myArrays[i].setBiosource_type((String) dataRow[8]);
                	myArrays[i].setDevelopment_stage((String) dataRow[9]);
                	myArrays[i].setAge_status((String) dataRow[10]);
                	if ((String) dataRow[11] != null) {
                       	myArrays[i].setAge_range_min(Double.parseDouble((String) dataRow[11]));
                	}
                	if ((String) dataRow[12] != null) {
                		myArrays[i].setAge_range_max(Double.parseDouble((String) dataRow[12]));
                	}
                	myArrays[i].setAge_range_units((String) dataRow[13]);
                	myArrays[i].setTime_point((String) dataRow[14]);
                	myArrays[i].setOrganism_part((String) dataRow[15]);
                	myArrays[i].setGender((String) dataRow[16]);
                	myArrays[i].setGenetic_variation((String) dataRow[17]);
                	myArrays[i].setIndividual_identifier ((String) dataRow[18]);
                	myArrays[i].setIndividual_genotype((String) dataRow[19]);
                	myArrays[i].setDisease_state((String) dataRow[20]);
                	myArrays[i].setSeparation_technique((String) dataRow[21]);
                	myArrays[i].setTarget_cell_type((String) dataRow[22]);
                	myArrays[i].setCell_line((String) dataRow[23]);
                	myArrays[i].setAdditional((String) dataRow[24]);
			myArrays[i].setPlatform((String) dataRow[25]);
                	myArrays[i].setSubmitter(submitter);
                	myArrays[i].setSubmis_id(Integer.parseInt((String) dataRow[27]));
                	myArrays[i].setExp_id(Integer.parseInt((String) dataRow[28]));
                	myArrays[i].setExperiment_name((String) dataRow[29]);
                	myArrays[i].setTsample_sysuid(Integer.parseInt((String) dataRow[30]));
                	myArrays[i].setStrain((String) dataRow[31]);
                	myArrays[i].setTreatment((String) dataRow[32]);
                	myArrays[i].setDuration((String) dataRow[33]);
                	myArrays[i].setArray_type((String) dataRow[34]);
                	if ((String) dataRow[35] != null) {
                		myArrays[i].setPublicExpID((String) dataRow[35]);
			}
			myArrays[i].setSample_name((String) dataRow[36]);
                	myArrays[i].setUploaded_by_user_id(uploaded_by_user_id);
                	myArrays[i].setOwner_user_id(owner_user_id);
			i++;
		}

		return myArrays;

	}

	/**
	 * Creates an array of Array objects, and sets the attributes to those retrieved in myResults.
	 * @param myResults	a Results object containing values retrieved from a query
	 * @return            an array of ArrayCount objects
	 */
	public Array[] setupArrayValues(Results myResults) {
		Array [] myArrays = null;
		String[] dataRow;
	
        	myArrays = new Array[myResults.getNumRows()];
		int i=0;

		while ((dataRow = myResults.getNextRow()) != null) {
			myArrays[i] = new Array();

                	myArrays[i].setHybrid_id(Integer.parseInt(dataRow[0]));
                	myArrays[i].setHybrid_name(dataRow[1]);
                	myArrays[i].setFile_name(dataRow[2]);
                	myArrays[i].setSubmitter(dataRow[3]);
                	myArrays[i].setSubmis_id(Integer.parseInt(dataRow[4]));
                	if (dataRow[5] != null) {
                		myArrays[i].setPublicExpID(dataRow[5]);
			}

			i++;
		}
		return myArrays;

	}

	/** 
	 * Retrieves the hybrid IDs from the database for the submission ID passed in.
	 * @param submisID	the id of the submission
	 * @param conn	the database connection
	 * @return	a comma-delimited list of hybrid ids
	 * @throws	SQLException if a database error occurs
	 */
	public String getHybridIDsForSubmission(int submisID, Connection conn) throws SQLException {

		log.debug ("in Array.getHybridIDsForSubmission passing in submisID");

		String query = 
                	"select distinct "+
                	"expDetails.hybrid_id "+ 
			"from CuratedExperimentDetails expDetails "+
			"where expDetails.subid = ? "+
                	"order by expDetails.hybrid_id"; 

		//log.debug ("query = "+query);

        	Results myResults = new Results(query, submisID, conn);
		String hybridIDs = myObjectHandler.getResultsAsSeparatedString(myResults, ",", "", 0); 
        	hybridIDs = "(" + (hybridIDs.equals("") ? "''" : hybridIDs) +  ")";

        	myResults.close();
        	return hybridIDs;

	}

	/**
	 * Gets the manufacturer's name of the type of array used in an 'in-silico' website experiment
	 * @param arrayName	the name of the array used in the experiment as stored in the database
	 * @param conn	the PhenoGen database connection
	 * @return            a String containing the type of array used
	 * @throws	SQLException if a database error occurs
	 */

	public String getManufactureArrayName(String arrayName, Connection conn) throws SQLException {
		String query = 
                	"select manufacture_array_name "+
                	"from array_types "+
			"where array_name = ?";

		log.debug ("in Array.getManufactureArrayName.");

		Results myResults = new Results(query, arrayName, conn);

                String value = myResults.getStringValueFromFirstRow();

                myResults.close();

		return value;
	}

	/**
	 * Gets the platform of the type of array used in an 'in-silico' website experiment
	 * @param arrayName	the name of the array used in the experiment as stored in the database
	 * @param conn	the PhenoGen database connection
	 * @return            a String containing the platform of array used
	 * @throws	SQLException if a database error occurs
	 */

	public String getPlatform(String arrayName, Connection conn) throws SQLException {
		String query = 
                	"select platform "+
                	"from array_types "+
			"where array_name = ?";

		log.debug ("in Array.getPlatform.");

		Results myResults = new Results(query, arrayName, conn);

                String platform = myResults.getStringValueFromFirstRow();

		myResults.close();

		return platform;
	}

	/**
	 * Gets the id of the array specified for a hybridization 
	 * @param arrayName	the name of the array
	 * @param userName	the name of the user
	 * @param conn	the database connection
	 * @return           the id of the type of array used
	 */
	public int getArrayID(String arrayName, String userName, Connection conn) throws SQLException {

		log.debug ("in Array.getArrayID. arrayName = " + arrayName);
		String query = 
                	"select tarray_sysuid "+
			"from tardesin, tarray "+
			"where tardesin_design_name = ? "+
			"and tardesin_sysuid = tarray_designid "+
			"and tardesin_del_status = 'U' "+
			"and tarray_del_status = 'U' "+
//			"and tardesin_user like ?||'%' "+
			"and tarray_user like ?||'%' ";

                log.debug("query = "+query); 

                //Results myResults = new Results(query, new Object[] {arrayName, userName, userName}, conn);
                Results myResults = new Results(query, new Object[] {arrayName, userName}, conn);

                int arrayID = myResults.getIntValueFromFirstRow();

                myResults.close();
		log.debug("arrayID from 1st query is = "+arrayID);

		if (arrayID == -99) {
			log.debug("arrayID is -99");
			query = 
				"select tarray_sysuid "+
				"from TARRAY left join EBI_ARRAY_DESIGNS on tarray_designid*-1 = EBI_ARRAY_SYSUID "+
				"where ebi_array_description = ? "+
				"and tarray_del_status = 'U'"; 

                	log.debug("query = "+query); 

                	myResults = new Results(query, arrayName, conn);

                	arrayID = myResults.getIntValueFromFirstRow();

                	myResults.close();
		}
		log.debug("now returning arrayID = "+arrayID);
		return arrayID;

	}

	/**
	 * Gets the name of the type of array used in an 'in-silico' website experiment.
	 * @param hybridIDs	a comma-delimited string of hybrid ids used in this experiment
	 * @param conn	the database connection
	 * @return            a String containing the type of array used
	 */
	public String getDatasetArrayType(String hybridIDs, Connection conn) throws SQLException {

		String query = 
                	"select distinct "+
			"case when tardesin_design_name is null then ebi_array_description else tardesin_design_name end "+
			"from CuratedExperimentDetails expDetails "+
			", "+
			"TARRAY left join TARDESIN on tarray_designid = tardesin_sysuid "+
			"left join EBI_ARRAY_DESIGNS on tarray_designid*-1 = EBI_ARRAY_SYSUID "+
			"where expDetails.hybrid_array_id = TARRAY.tarray_sysuid "+
			"and expDetails.hybrid_id in "+
			hybridIDs + 
                	" order by 1"; 

		log.debug ("in Array.getDatasetArrayType.");
		//log.debug("query = "+query);

		Results myResults = new Results(query, conn);
		String[] dataRow;
		String arrayType = "";

		int numRows = myResults.getNumRows();
		if (numRows == 0) {
			arrayType = "Unknown";
		} else if (numRows > 1) {
			log.debug("More than one chip type");
			arrayType = "More than one";
		} else {
			dataRow = myResults.getNextRow();	
			arrayType = dataRow[0];
		}

		myResults.close();
		return arrayType;
	}

	/** 
	 * Retrieves the arrays from the database for a list of hybridIDs.
	 * @param hybridIDs	a comma-separated list of hybrid_ids
	 * @param conn	the database connection
	 * @return	an array of Array objects that contains ONLY the hybrid_id, 
	 *		hybrid name, file name, submitter, and 
	 *		submission id
	 * @throws	SQLException if a database error occurs
	 */
	public Array[] getArraysForDataset(String hybridIDs, Connection conn) throws SQLException {
		String query = 
                	"select distinct "+
                	"expDetails.hybrid_id, "+ 
                	"expDetails.hybrid_name, "+ 
			"expDetails.path, "+
			"expDetails.exp_created_by_login, "+
			"expDetails.subid, "+
			"pe.exp_id "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			"where expDetails.hybrid_id in "+
			hybridIDs + 
                	" order by expDetails.hybrid_name"; 

		log.debug ("in Array.getArraysForDataset passing in hybridIDs");
		//log.debug ("query = "+query);

		Results myResults = new Results(query, conn);
		//log.debug("myResults.getNumRows = "+myResults.getNumRows());

		Array [] myArrays = setupArrayValues(myResults);
		myResults.close();

		return myArrays;

	}

	/**
	 * Gets arrays from the database that match the combination of search criteria
	 * @param hybridIDs	list of comma-separated identifiers for matching on array ids
	 * @param attributes	Hashtable of attributes, along with their values, used for matching chips. Possible values are:
			<TABLE>
				<TH>Key<TH>Examples
				<TR> <TD>Organism</TD><TD>Mus musculus</TD> </TR>
				<TR> <TD>GeneticVariation</TD><TD>inbred strain</TD> </TR>
				<TR> <TD>OrganismPart</TD><TD>amygdala</TD> </TR>
				<TR> <TD>Sex</TD><TD>male</TD> </TR>
				<TR> <TD>Treatment</TD><TD>naive</TD> </TR>
				<TR> <TD>Subordinates</TD><TD>All, Public, bhaves</TD> </TR>
				<TR> <TD>ArrayName</TD><TD>BXD</TD> </TR>
			</TABLE></indent>
	 * @param conn	the PhenoGen database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of Array objects satisfying the selection criteria
	 */
	public Array[] getArraysThatMatchCriteria(String hybridIDs, Hashtable attributes, 
							Connection conn) throws SQLException {

		log.debug ("in Array.getArraysThatMatchCriteria");
		//log.debug("attributes = "); myDebugger.print(attributes);

		String query = 
                	"select distinct expDetails.file_id, "+
                	"expDetails.hybrid_id, "+ 
                	"expDetails.hybrid_name, "+ 
                	"expDetails.path, "+
                	"expDetails.hybrid_id, "+
			"expDetails.subid, "+
                	"expDetails.tntxsyn_name_txt, "+
                	"expDetails.tsample_cell_provider, "+
			"'', "+ 			// sample_type
			"'', "+ 			// dev_stage
			"'', "+ 			// age_status
                	"expDetails.tsample_agerange_min, "+
                	"expDetails.tsample_agerange_max, "+
			"'', "+ 			// agerange_unit
			"'', "+ 			// initial_time_point
			/* Removed to speed up query */
			/* 
			"case when organism_part.value = 'other' then "+
			"otherOrganismPart.tothers_value else organism_part.value end OrganismPart, "+
			*/
			"organism_part.value, "+
			"gender.value, "+
			/* Removed to speed up query */
			/*
			"case when genetic_variation.value = 'other' then "+
			"otherGV.tothers_value else genetic_variation.value end GeneticModification, "+
			*/
			"genetic_variation.value, "+
                	"expDetails.tsample_individual, "+
                	"expDetails.tsample_individual_gen, "+
                	"expDetails.tsample_disease_state, "+
			"'', "+ 			// separation_technique
                	"expDetails.tsample_target_cell_type, "+
                	"expDetails.tsample_cell_line, "+
                	"expDetails.tsample_additional, "+
                	"case when upper(expDetails.path) like '%CEL' then 'Affymetrix' "+ 
                	"when upper(expDetails.path) like '%GPR' then 'cDNA' "+ 
                	"when upper(expDetails.path) like '%SPOT' then 'cDNA' "+ 
                	"when upper(expDetails.path) like '%TXT' then 'CodeLink' else 'unknown' end Platform, "+ 
			"expDetails.exp_created_by_login, "+
			"expDetails.subid, "+
			"expDetails.exp_id, "+ 
                	"expDetails.exp_name, "+ 
			"expDetails.tsample_sysuid, "+ 			
                	"expDetails.tsample_strain, "+
			"treatment.tfctrval_freetext, "+
			"treatment.tfctrval_freetextunit, "+
			"case when tardesin_design_name is null then ebi_array_description "+
			"else tardesin_design_name end, "+
			"pe.exp_id, "+
			"expDetails.tsample_id "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			", "+
			"TSAMPLE sample4 left join TFCTRVAL treatment "+
				"on treatment.tfctrval_sampleid = sample4.tsample_sysuid "+
				// hard-coding to experimental factor of 'other', which is where the treatment field is located
				"and treatment.tfctrval_expfctrid = 443 "+
				"and treatment.tfctrval_del_status = 'U', ";
			/* Removed to speed up query */
			if (attributes.get("OrganismPart") != null && 
				!((String) attributes.get("OrganismPart")).equals("All")) {
				query = query +
				"TSAMPLE sample2 left join TOTHERS otherOrganismPart "+
					"on sample2.tsample_sysuid = otherOrganismPart.tothers_sampleid "+
					"and otherOrganismPart.tothers_del_status = 'U' "+
					"and otherOrganismPart.tothers_id = 'ORGANISM_PART', ";
			}
			if (attributes.get("ExperimentDesignType") != null && 
				!((String) attributes.get("ExperimentDesignType")).equals("All")) {
				query = query +
				"valid_terms edt, "+
				"TEXPRTYP et, ";
			}
			if (attributes.get("GeneticVariation") != null && 
				!((String) attributes.get("GeneticVariation")).equals("All")) {
				query = query +
				"TSAMPLE sample3 left join TOTHERS otherGV "+
				"on sample3.tsample_sysuid = otherGV.tothers_sampleid "+
				"and otherGV.tothers_del_status = 'U' "+
				"and otherGV.tothers_id = 'GENETIC_VARIATION', ";
			}
			if (attributes.get("Compound") != null && 
				!((String) attributes.get("Compound")).equals("All")) {
				query = query +
 				"TSAMPLE sample5 left join compounds "+
				"on compounds.tfctrval_sampleid = sample5.tsample_sysuid, ";
			}
			if (attributes.get("Dose") != null && 
				!((String) attributes.get("Dose")).equals("All")) {
				query = query +
 				"TSAMPLE sample6 left join doses "+
				"on doses.tfctrval_sampleid = sample6.tsample_sysuid, ";
			}

			query = query +
			"valid_terms genetic_variation, "+
			"valid_terms organism_part, "+
			"valid_terms gender, "+
			"TARRAY left join TARDESIN on tarray_designid = tardesin_sysuid "+
			"left join EBI_ARRAY_DESIGNS on tarray_designid*-1 = EBI_ARRAY_SYSUID "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, "") +  
			"and expDetails.hybrid_array_id = TARRAY.tarray_sysuid ";
			/* Removed to speed up query */
			if (attributes.get("OrganismPart") != null && 
				!((String) attributes.get("OrganismPart")).equals("All")) {
				query = query +
				"and expDetails.tsample_sysuid = sample2.tsample_sysuid ";
			}
			if (attributes.get("ExperimentDesignType") != null && 
				!((String) attributes.get("ExperimentDesignType")).equals("All")) {
				query = query +
				"and et.texprtyp_del_status = 'U' "+
				"and et.texprtyp_id = edt.term_id "+
				"and expDetails.exp_id = et.texprtyp_exprid "+
				"and edt.category = 'EXPERIMENT_TYPE' ";
			}
			if (attributes.get("GeneticVariation") != null && 
				!((String) attributes.get("GeneticVariation")).equals("All")) {
				query = query +
				"and expDetails.tsample_sysuid = sample3.tsample_sysuid ";
			}
			if (attributes.get("Compound") != null && 
				!((String) attributes.get("Compound")).equals("All")) {
				query = query +
				"and expDetails.tsample_sysuid = sample5.tsample_sysuid ";
			}
			if (attributes.get("Dose") != null && 
				!((String) attributes.get("Dose")).equals("All")) {
				query = query +
				"and expDetails.tsample_sysuid = sample6.tsample_sysuid ";
			}
			query = query +
			"and expDetails.tsample_sysuid = sample4.tsample_sysuid "+
			"and expDetails.tsample_genetic_variation = genetic_variation.term_id "+
			"and expDetails.tsample_organism_part = organism_part.term_id "+
			"and expDetails.tsample_sex = gender.term_id ";
		
			List <String> parameterValues = new ArrayList<String> ();
			Enumeration hashKeys = attributes.keys();
			while (hashKeys.hasMoreElements()) {
	
				String nextKey = (String) hashKeys.nextElement();
				String nextValue = (String) attributes.get(nextKey);
				//log.debug ("nextKey= "+nextKey + ", nextValue = "+nextValue);

				if (nextKey.equals("All")) {
				} else if (nextKey.equals("Principal Investigator")) {
					if (!nextValue.equals("All")) {
						if (nextValue.equals("Public")) {
							query = query + 
								"and pe.exp_id is not null ";
						} else if (nextValue.equals("NonPublic")) {
							query = query + 
								"and pe.exp_id is null ";
						} else {
							query = query + 
								"and expDetails.exp_created_by_login in " + nextValue + " ";
						}
					}
				} else if (nextKey.equals("Channel")) {
					if (nextValue.equals("Single")) {
						query = query + 
				                	"and (upper(expDetails.path) like '%CEL' or "+
				                	"	upper(expDetails.path) like '%TXT') "; 
					} else if (nextValue.equals("Two")) {
						query = query + 
				                	"and (upper(expDetails.path) like '%GPR' or "+
				                	"	upper(expDetails.path) like '%SPOT') "; 
					}
				} else if (nextKey.equals("ArrayType")) {
					if (!nextValue.equals("All")) {
						query = query + 
						"and ( "+
						"(tardesin_design_name is null and ebi_array_description = ?) "+ 
						"or "+
						"(tardesin_design_name is not null and tardesin_design_name = ?) "+
						") ";
						parameterValues.add(nextValue);
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("Organism")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and decode(expDetails.tntxsyn_name_txt, "+
							"	'Mus musculus', expDetails.tntxsyn_name_txt, "+
							"	'Rattus norvegicus', expDetails.tntxsyn_name_txt, "+
							"	'Other') = ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("Sex")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(gender.value, 'No Value Entered') = ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("OrganismPart")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(case when organism_part.value = 'other' then "+
							"otherOrganismPart.tothers_value else organism_part.value end, "+
							"'No Value Entered') = ? ";
							//"and nvl(organism_part.value,  'No Value Entered') = ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("ExperimentDesignType")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(edt.value, 'No Value Entered') = ? "; 
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("Strain")) {
					if (!nextValue.equals("All")) {
						if (nextValue.equals("All BXD Strains")) {
							query = query + "and nvl(expDetails.tsample_strain, 'No Value Entered') like ? ";
							parameterValues.add("%BXD%");
						} else if (nextValue.equals("C57BL/6 -- All Strains")) {
							query = query + "and nvl(expDetails.tsample_strain, 'No Value Entered') like ? ";
							parameterValues.add("%C57%");
						} else if (nextValue.equals("All BXH Strains")) {
							query = query + "and nvl(expDetails.tsample_strain, 'No Value Entered') like ? ";
							parameterValues.add("%BXH%");
						} else if (nextValue.equals("All HXB Strains")) {
							query = query + "and nvl(expDetails.tsample_strain, 'No Value Entered') like ? ";
							parameterValues.add("%HXB%");
						} else if (nextValue.equals("All ILSXISS Strains")) {
							query = query + "and nvl(expDetails.tsample_strain, 'No Value Entered') like ? ";
							parameterValues.add("%ILSXISS%");
						} else if (nextValue.equals("All BXH/HXB Strains")) {
							query = query + "and (nvl(expDetails.tsample_strain, 'No Value Entered') like '%BXH%' "+
									"	or nvl(expDetails.tsample_strain, 'No Value Entered') like '%HXB%') ";
						} else {
							query = query + "and nvl(expDetails.tsample_strain, 'No Value Entered') = ? ";
							parameterValues.add(nextValue);
						}
					}
				} else if (nextKey.equals("Genotype")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(expDetails.tsample_individual_gen, 'No Value Entered') = ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("Treatment")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(treatment.tfctrval_freetext, 'No Treatment') = ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("Duration")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(treatment.tfctrval_freetextunit, 'No Value Entered') = ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("Compound")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(compounds.tfctrval_freetext, 'No Value Entered') = ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("Dose")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(doses.tfctrval_freetext||' '||doses.tfctrval_freetextunit, "+
							"'No Value Entered') = ? "; 
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("Submitter")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(expDetails.exp_created_by_login, 'No Value Entered') = ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("ArrayName")) {
					if (!nextValue.equals("")) {
						query = query + 
							"and nvl(expDetails.hybrid_name, 'No Value Entered') like ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("ExperimentName")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(expDetails.exp_name, 'No Value Entered') like ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("ExperimentID")) {
					if (!nextValue.equals("")) {
						query = query + 
							"and nvl(expDetails.exp_id, -99) = ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("CellLine")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(expDetails.tsample_cell_line, 'No Value Entered') like ? ";
						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("GeneticVariation")) {
					if (!nextValue.equals("All")) {
						query = query + 
							"and nvl(case when genetic_variation.value = 'other' then "+
							"otherGV.tothers_value else genetic_variation.value end, "+
							"'No Value Entered') = ? ";
							//"and nvl(genetic_variation.value, 'No Value Entered') = ? ";

						parameterValues.add(nextValue);
					}
				} else if (nextKey.equals("GeneticType")) {
						query = query + 
							"and decode(genetic_variation.value, "+ 
							"'none', 'Other', "+
							"'F1', 'Other', "+
							"'congenic strain', 'Other', "+
							"'gene knock out', 'Other', "+
							"'knock down', 'Other', "+
							"'transgenic', 'Other', "+
							"'inbred strain', 'Inbred', "+
							"'recombinant inbred strain', 'Recombinant Inbred', "+
							"'selective breeding', 'Selectively Bred', genetic_variation.value) = ? ";
					parameterValues.add(nextValue);
				} else if (nextKey.equals("Title")) {
					query = query + 
						"and expDetails.exp_name like ? ";
					parameterValues.add(nextValue);
				} else if (nextKey.equals("Description")) {
					query = query + 
						"and expDetails.exp_description like ? ";
					parameterValues.add(nextValue);
				} else if (nextKey.equals("Both")) {
					query = query + 
						"and (expDetails.exp_description like ? or expDetails.exp_name like ?) ";
					parameterValues.add(nextValue);
					parameterValues.add(nextValue);
				}	
			}

			query = query + "order by expDetails.hybrid_name";

		log.debug ("query = "+query);

		Array [] myArrays = null;

		List<Object> parameterList = new ArrayList<Object>();

		for (int i=0; i<parameterValues.size(); i++) {
			parameterList.add((String) parameterValues.get(i));
		//	log.debug("just set parameter value "+ i+" to "+parameterValues.get(i));
		}

		Object[] parameters = (Object[]) parameterList.toArray(new Object[parameterList.size()]);

                Results myResults = new Results(query, parameters, conn); 

		log.debug("numRows =  "+myResults.getNumRows());
                myArrays = setupAllArrayValues(myResults, conn);
		log.debug("returning "+myArrays.length+" rows from MatchCriteria");
		myResults.close();

		return myArrays;
	}

	/**
	 * Retrieves the genetic variations and the number of arrays from the database.  
	 * It can be called to display 
	 * organisms from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */
	public ArrayCount[] getGeneticVariations(String hybridIDs, String channel, Connection conn) throws SQLException {

		String query = 
			"select distinct nvl(case when genetic_variation.value = 'other' "+
			"then otherGV.tothers_value else "+
			"	genetic_variation.value end, 'No Value Entered'), "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			", "+
			"TSAMPLE sample2 left join TOTHERS otherGV "+
			"on sample2.tsample_sysuid = otherGV.tothers_sampleid "+
			"and otherGV.tothers_id = 'GENETIC_VARIATION' "+
			"and otherGV.tothers_del_status = 'U', "+
			"valid_terms genetic_variation "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"and sample2.tsample_sysuid = expDetails.tsample_sysuid "+
			"and expDetails.tsample_genetic_variation = genetic_variation.term_id "+
			"group by case when genetic_variation.value = 'other' "+
			"	then otherGV.tothers_value else genetic_variation.value end "+
			"order by 1";

	
		//log.debug ("in Array.getGeneticVariations");
		//log.debug("query = "+query);
		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);
		myResults.close();

		return myArrayCounts;

	}

	/**
	 * Retrieves the durations and the number of arrays from the database.  It can be called to display 
	 * durations from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */
	public ArrayCount[] getDurations(String hybridIDs, String channel, Connection conn) throws SQLException {

		String query = 
			"select distinct case when "+
				"nvl(treatment.tfctrval_freetextunit, 'No Value Entered') = '-' "+
				"then 'No Value Entered' "+
				"else nvl(treatment.tfctrval_freetextunit, 'No Value Entered') end, "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			", "+
			"TSAMPLE sample2 left join TFCTRVAL treatment "+
			"	on sample2.tsample_sysuid = treatment.tfctrval_sampleid "+
				// hard-coding to experimental factor of 'other', which is where the treatment field is located
				"and treatment.tfctrval_expfctrid = 443 "+
				"and treatment.tfctrval_del_status = 'U' "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"and sample2.tsample_sysuid = expDetails.tsample_sysuid "+
			"group by treatment.tfctrval_freetextunit "+
			"order by 1";

		//log.debug ("in Array.getDurations");
		//log.debug("query = "+query);
		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
	}

	/**
	 * Retrieves the treatments and the number of arrays from the database.  It can be called to display 
	 * treatments from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */
	public ArrayCount[] getTreatments(String hybridIDs, String channel, Connection conn) throws SQLException {

		String query = 
			"select distinct nvl(treatment.tfctrval_freetext, 'No Treatment'), "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			", "+
			"TSAMPLE sample2 left join TFCTRVAL treatment "+
			"	on sample2.tsample_sysuid = treatment.tfctrval_sampleid "+
				// hard-coding to experimental factor of 'other', which is where the treatment field is located
				"and treatment.tfctrval_expfctrid = 443 "+
				"and treatment.tfctrval_del_status = 'U' "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) + 
			"and sample2.tsample_sysuid = expDetails.tsample_sysuid "+
			"group by treatment.tfctrval_freetext "+
			"order by 1";

		//log.debug ("in Array.getTreatments");
		//log.debug("query = "+query);
		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
	}

	/**
	 * Retrieves the experiment names and the number of arrays from the database.  It can be called to display 
	 * experiment names from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getExperimentNames(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select distinct nvl(expDetails.exp_name, 'No Value Entered'), "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) + 
			"group by expDetails.exp_name "+
			"order by 1";

		//log.debug ("in Array.getExperimentNames");
		//log.debug("query = "+query);

		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
	}

	/**
	 * Retrieves the individual genotypes and the number of arrays from the database.  It can be called to display 
	 * individual genotypes from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getGenotypes(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select distinct nvl(expDetails.tsample_individual_gen, 'No Value Entered'), "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) + 
			"group by expDetails.tsample_individual_gen "+
			"order by 1";

		//log.debug ("in Array.getGenotypes");
		//log.debug("query = "+query);

		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
	}

	/**
	 * Retrieves the cell lines and the number of arrays from the database.  It can be called to display 
	 * strains from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getCellLines(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select distinct nvl(expDetails.tsample_cell_line, 'No Value Entered'), "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays,  "+
			"upper(nvl(expDetails.tsample_cell_line, 'No Value Entered')) "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"group by expDetails.tsample_cell_line "+
			"order by 5";

		//log.debug ("in Array.getCellLines");
		//log.debug("query = "+query);


                Results myResults = new Results(query, conn);

		ArrayCount[] myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
	}

	/**
	 * Retrieves the strains and the number of arrays from the database.  It can be called to display 
	 * strains from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getStrains(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select distinct nvl(expDetails.tsample_strain, 'No Value Entered'), "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"group by expDetails.tsample_strain "+
			"order by 1";

		//log.debug ("in Array.getStrains");
		//log.debug("query = "+query);

		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
	}

	/**
	 * Retrieves the dosages and the number of arrays from the database.  It can be called to display the 
	 * dosages from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getDoses(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select distinct case when "+
				"nvl(dose.tfctrval_freetext||' '||dose.tfctrval_freetextunit, 'No Value Entered') = '- -' "+
				"then 'No Value Entered' "+
				"else nvl(dose.tfctrval_freetext||' '||dose.tfctrval_freetextunit, 'No Value Entered') end, "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			", "+
			"valid_terms val, "+
			"TFCTRVAL dose "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"and dose.tfctrval_del_status = 'U' "+
			"and val.term_id = dose.tfctrval_expfctrid "+
			"and dose.tfctrval_sampleid = expDetails.tsample_sysuid "+
			"and val.value = 'dose' "+
			"group by dose.tfctrval_freetext, dose.tfctrval_freetextunit "+
			"order by 1";

		//log.debug ("in Array.getDoses");
		//log.debug("query = "+query);

		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
	}

	/**
	 * Retrieves the combinations of compound and dose from the database.  
	 * It can be called to display the 
	 * compounds from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a List of String arrays containing the 3 values
	 */

	public List<String[]> getCompoundDoseCombos(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select distinct nvl(compound.tfctrval_freetext, 'No Value Entered'), "+
			"nvl(dose.tfctrval_freetext||' '||dose.tfctrval_freetextunit, 'No Value Entered') "+
			"from CuratedExperimentDetails expDetails "+
			", "+
			"valid_terms compound_val, "+
			"TFCTRVAL compound, "+
			"valid_terms dose_val, "+
			"TFCTRVAL dose "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"and compound.tfctrval_del_status = 'U' "+
			"and compound_val.term_id = compound.tfctrval_expfctrid "+
			"and compound.tfctrval_sampleid = expDetails.tsample_sysuid "+
			"and compound_val.value = 'compound' "+
			"and dose.tfctrval_del_status = 'U' "+
			"and dose_val.term_id = dose.tfctrval_expfctrid "+
			"and dose.tfctrval_sampleid = expDetails.tsample_sysuid "+
			"and dose_val.value = 'dose' "+
			"group by compound.tfctrval_freetext, "+ 
			"dose.tfctrval_freetext, "+
			"dose.tfctrval_freetextunit "+
			"order by 1, 2";

		log.debug ("in Array.getCompoundDoseCombos");
		//log.debug("query = "+query);

		List<String[]> myList = new ArrayList<String[]>();
		String[] dataRow;
	
                Results myResults = new Results(query, conn);

        	while ((dataRow = myResults.getNextRow()) != null) {
			String[] thisRow = new String[dataRow.length];
			thisRow = dataRow;
			myList.add(thisRow);
		}

		myResults.close();

		return myList;
	}

	/**
	 * Retrieves the valid combinations for the hierarchical query page
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a List of String arrays containing the 3 values
	 */

	public List<String[]> getQueryCombos(String channel, Connection conn) throws SQLException {
		String orgString = 
				//Mouse is 10090, Rat is 10116, 7227 is Fly, 9606 is Human
				" decode(details.tsample_taxid, 7227, 'Other', "+
				//'Drosophila melanogaster', "+
				"9606, 'Other', "+
				//'Homo sapiens', "+
				"10090, 'Mus musculus', "+
				"10116, 'Rattus norvegicus', details.tsample_taxid) org, ";

		String genModString =
			"decode(gv.value, "+
//			"'none', 'None', "+
			"'none', 'Other', "+
			"'F1', 'Other', "+
/*
			"'congenic strain', 'Genetically Modified', "+
			"'gene knock out', 'Genetically Modified', "+
			"'knock down', 'Genetically Modified', "+
			"'transgenic', 'Genetically Modified', "+
*/
			"'congenic strain', 'Other', "+
			"'gene knock out', 'Other', "+
			"'knock down', 'Other', "+
			"'transgenic', 'Other', "+
			"'inbred strain', 'Inbred', "+
			"'recombinant inbred strain', 'Recombinant Inbred', "+
			"'selective breeding', 'Selectively Bred', gv.value) genmod, ";

		String slgString =
			"decode(gv.value,  "+
				//"'none', 'None', "+
				//"'F1', 'None', "+
				"'congenic strain', details.tsample_individual_gen, "+
				"'gene knock out', details.tsample_individual_gen, "+
				"'knock down', details.tsample_individual_gen, "+
				"'transgenic', details.tsample_individual_gen, "+
				"'inbred strain', details.tsample_strain,  "+
				"'recombinant inbred strain', details.tsample_strain,  "+
				"'selective breeding', details.tsample_cell_line) "; 
				//"gv.value) slg,  ";
				//"'') slg,  ";

		String tissueString =
			"case when tissue.value = 'other' then otherOrganismPart.tothers_value else tissue.value end tissue, ";

		String orderString = 
 				"decode(gv.value, "+
				"'none', 4, "+
				"'F1', 4, "+
				"'congenic strain', 4, "+
				"'gene knock out', 4, "+
				"'knock down', 4, "+
				"'transgenic', 4, "+
				"'inbred strain', 1, "+
				"'recombinant inbred strain', 2,  "+
				"'selective breeding', 3, "+
				"gv.value) ";

		String fromString = 
			"from curatedexperimentdetails details left join arrays a on hybrid_array_id = tarray_sysuid,  "+
			" TSAMPLE sample2 left join TOTHERS otherOrganismPart on sample2.tsample_sysuid = otherOrganismPart.tothers_sampleid "+
			"and otherOrganismPart.tothers_id = 'ORGANISM_PART' "+
			"and otherOrganismPart.tothers_del_status = 'U', "+
			"valid_terms tissue,  "+
			"valid_terms gv ";

		String whereString = 
			"where details.tsample_organism_part = tissue.term_id "+
			"and details.tsample_genetic_variation = gv.term_id "+
			"and details.tsample_sysuid = sample2.tsample_sysuid "+
			"and a.array_name not in ('UTAustin_Mm10_cDNA') ";

		String notInExperimentString = 
			"and exp_name not in ('Interaction of ETOH and Strain on Embryos and  Placenta',  "+
			"'Brain Development in SAKO BKO NeoAKO WT Mice',  "+
			"'AKO BKO  WT  Right Mouse Brain',  "+
			"'AKO BKO and WT  Mouse Brain and Liver')  ";

		String groupByString =
			"group by details.tsample_taxid, gv.value, details.tsample_strain,  "+
			"tissue.value,  "+
			"otherOrganismPart.tothers_value, "+
			"a.array_name, "+
			"details.tsample_individual_gen,  "+
			"details.tsample_cell_line  ";

		String query = 
			"select "+
			orgString +
			genModString +
			slgString + "," +
			tissueString +
			"a.array_name,  "+
			orderString + ", "+
			"count(*)   "+
			fromString +
			whereString +
			notInExperimentString +
			"and "+ slgString + " is not null "+
			groupByString + 
			"union "+
			"select "+
			orgString +
			genModString +
			//Mouse is 10090, Rat is 10116, 7227 is Fly, 9606 is Human
			"decode(details.tsample_taxid, "+
			"	10090, "+
			"		decode(gv.value,  "+
			"			'inbred strain', 'C57BL/6 -- All Strains',  "+
			"			'recombinant inbred strain', 'All BXD Strains'), "+
			"	10116, "+ 
			"		decode(gv.value,  "+
			"			'recombinant inbred strain', 'All BXH Strains')), "+
			tissueString +
			"a.array_name,  "+
			orderString + ", "+
			"count(*)   "+
			fromString +
			whereString +
			notInExperimentString +
			"and "+ slgString + " is not null "+
			"and decode(details.tsample_taxid, "+ 
			"	10090, "+
     			"		decode(gv.value, 'inbred strain', details.tsample_strain, "+
          		"			'recombinant inbred strain', details.tsample_strain), "+
         		"	10116, "+
			"		decode(gv.value, 'recombinant inbred strain', details.tsample_strain)) like "+
 			"decode(details.tsample_taxid, "+
			"	10090, "+
			"		decode(gv.value, 'inbred strain', '%C57%', "+
			"			'recombinant inbred strain', '%BXD%'), "+
			"	10116, "+
			"		decode(gv.value, 'recombinant inbred strain', '%BXH%')) "+
			groupByString + 
			"union "+
			"select "+
			orgString +
			genModString +
			//Mouse is 10090, Rat is 10116, 7227 is Fly, 9606 is Human
			"decode(details.tsample_taxid, "+
			"	10090, "+
				"	decode(gv.value,  "+
				"		'recombinant inbred strain', 'All ILSXISS Strains'), "+
			"	10116, "+
				"	decode(gv.value,  "+
				"		'recombinant inbred strain', 'All HXB Strains')), "+
			tissueString +
			"a.array_name,  "+
			orderString + ", "+
			"count(*)   "+
			fromString +
			whereString +
			notInExperimentString +
			"and "+ slgString + " is not null "+
			"and decode(details.tsample_taxid, "+ 
			"	10090, "+
     			"		decode(gv.value, 'recombinant inbred strain', details.tsample_strain), "+
         		"	10116, "+
			"		decode(gv.value, 'recombinant inbred strain', details.tsample_strain)) like "+
 			"decode(details.tsample_taxid, "+
			"	10090, "+
			"		decode(gv.value, 'recombinant inbred strain', '%ILSXISS%'), "+
			"	10116, "+
			"		decode(gv.value, 'recombinant inbred strain', '%HXB%')) "+
			groupByString + 
			"union "+
			"select "+
			orgString +
			genModString +
			//Mouse is 10090, Rat is 10116, 7227 is Fly, 9606 is Human
			"decode(details.tsample_taxid, " +
			"	10116, "+
			"		decode(gv.value,  "+
			"			'recombinant inbred strain', 'All BXH/HXB Strains')), "+
			tissueString +
			"a.array_name,  "+
			orderString + ", "+
			"count(*)   "+
			fromString +
			whereString +
			notInExperimentString +
			"and "+ slgString + " is not null "+
			"and (decode(details.tsample_taxid, "+ 
         		"	10116, "+
			"		decode(gv.value, 'recombinant inbred strain', details.tsample_strain)) like "+
 			"decode(details.tsample_taxid, "+
			"	10116, "+
			"		decode(gv.value, 'recombinant inbred strain', '%HXB%')) "+
			"or decode(details.tsample_taxid, "+ 
         		"	10116, "+
			"		decode(gv.value, 'recombinant inbred strain', details.tsample_strain)) like "+
 			"decode(details.tsample_taxid, "+
			"	10116, "+
			"		decode(gv.value, 'recombinant inbred strain', '%BXH%'))) "+
			groupByString + 
/*
			"union  "+
			"select "+
			orgString +
			"'Mouse Development' genmod, "+
			slgString + 
			tissueString +
			"a.array_name,  "+
			"count(*)   "+
			fromString +
			whereString +
			"and exp_name in ('Interaction of ETOH and Strain on Embryos and  Placenta',  "+
			"'Brain Development in SAKO BKO NeoAKO WT Mice',  "+
			"'AKO BKO  WT  Right Mouse Brain',  "+
			"'AKO BKO and WT  Mouse Brain and Liver')  "+
			groupByString + 
*/
			"order by 1, "+ 
				"6, "+
				"3, 4, 5";

		log.debug ("in Array.getQueryCombos");
		log.debug("query = "+query);

		List<String[]> myList = new ArrayList<String[]>();
		String[] dataRow;
	
                Results myResults = new Results(query, conn);

        	while ((dataRow = myResults.getNextRow()) != null) {
			String[] thisRow = new String[dataRow.length];
			thisRow = dataRow;
			myList.add(thisRow);
		}

		myResults.close();

		return myList;
	}

	public List<String[]> getSet(List<String[]> theseCombos, int start, int end) {
		log.debug ("in Array.getSet");
		List<String[]> newList = new ArrayList<String[]>();
		Set<String> newSetAsString = new TreeSet<String>();
		for (Iterator itr =  theseCombos.iterator(); itr.hasNext();) {
			String[] thisCombo = (String[]) itr.next();
			String[] smallerCombo = new String[end-start];
			for (int i=0; i<end-start; i++) {
				smallerCombo[i] = thisCombo[start+i];
			}
			//Can't compare String arrays directly, so have to do this. Is this true?
			if (newSetAsString.add(Arrays.toString((Object[])smallerCombo))) {
				//log.debug("adding combo");
				newList.add(smallerCombo);
			} else {
				//log.debug("did not add combo");
			}
		}
		return newList;
	}

	/**
	 * Retrieves the combinations of treatment and durations from the database.  
	 * It can be called to display the 
	 * treatments from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            a List of String arrays containing the 3 values
	 */

	public List<String[]> getTreatmentDurationCombos(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select distinct nvl(treatment.tfctrval_freetext, 'No Treatment'), "+
			"nvl(treatment.tfctrval_freetextunit, 'No Value Entered') "+
			"from CuratedExperimentDetails expDetails "+
			", "+
			"TSAMPLE sample2 left join TFCTRVAL treatment "+
			"	on sample2.tsample_sysuid = treatment.tfctrval_sampleid "+
				// hard-coding to experimental factor of 'other', which is where the treatment field is located
				"and treatment.tfctrval_expfctrid = 443 "+
				"and treatment.tfctrval_del_status = 'U' "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"and sample2.tsample_sysuid = expDetails.tsample_sysuid "+
			"group by treatment.tfctrval_freetext, "+
			"treatment.tfctrval_freetextunit "+
			"order by 1, 2";

		log.debug ("in Array.getTreatmentDurationCombos");
		//log.debug("query = "+query);

		List<String[]> myList = new ArrayList<String[]>();
		String[] dataRow;
	
                Results myResults = new Results(query, conn);

        	while ((dataRow = myResults.getNextRow()) != null) {
			String[] thisRow = new String[dataRow.length];
			thisRow = dataRow;
			myList.add(thisRow);
		}

		myResults.close();

		return myList;
	}

	/**
	 * Retrieves the compounds and the number of arrays from the database.  It can be called to display the 
	 * compounds from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getCompounds(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select distinct nvl(compound.tfctrval_freetext, 'No Value Entered'), "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			", "+
			"valid_terms val, "+
			"TFCTRVAL compound "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"and compound.tfctrval_del_status = 'U' "+
			"and val.term_id = compound.tfctrval_expfctrid "+
			"and compound.tfctrval_sampleid = expDetails.tsample_sysuid "+
			"and val.value = 'compound' "+
			"and compound.tfctrval_freetext != '-' "+
			"group by compound.tfctrval_freetext "+
			"order by 1";

		//log.debug ("in Array.getCompounds");
		//log.debug("query = "+query);

		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
	}

	/**
	 * Retrieves the experiment design types and the number of arrays from the database.  It can be called to display the 
	 * experiment design types from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getExperimentDesignTypes(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select distinct nvl(edt.value, 'No Value Entered'), "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			", "+
			"valid_terms edt, "+
			"TEXPRTYP et "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"and et.texprtyp_del_status = 'U' "+
			"and et.texprtyp_id = edt.term_id "+
			"and expDetails.exp_id = et.texprtyp_exprid "+
			"and edt.category = 'EXPERIMENT_TYPE' "+
			"group by edt.value "+
			"order by 1";

		log.debug ("in Array.getExperimentDesignTypes");
		//log.debug("query = "+query);

		ArrayCount[] myArrayCounts = null;

                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
	}

	/**
	 * Retrieves the sexes and the number of arrays from the database.  It can be called to display 
	 * sexes from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getSexes(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select distinct nvl(sex.value, 'No Value Entered'), "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			", "+
			"valid_terms sex "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"and expDetails.tsample_sex = sex.term_id "+
			"group by sex.value "+
			"order by 1";

		//log.debug ("in Array.getSexes");
		//log.debug("query = "+query);

		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
	}

	/**
	 * Retrieves the organism parts and the number of arrays from the database.  It can be called to display 
	 * organism parts from all arrays or only from those arrays to which the user has been granted access.  
	 * In the second case, a list of the user's hybridIDs must be passed in.
	 * @param hybridIDs	a list of comma-separated hybridIDs enclosed in parentheses or "All".
	 * @param channel	either "Single" or "Two" to indicate the list of valid values to display
	 * @param conn	the database connection
	 * @throws            SQLException if a database error occurs
	 * @return            an array of ArrayCount objects
	 */

	public ArrayCount[] getOrganismParts(String hybridIDs, String channel, Connection conn) throws SQLException {
		String query = 
			"select nvl(case when organism_part.value = 'other' then "+
			"otherOrganismPart.tothers_value else organism_part.value end, 'No Value Entered'), "+
			"count(distinct case when pe.exp_id is not null then expDetails.hybrid_id else null end) as pub, "+
			"count(distinct case when pe.exp_id is null then expDetails.hybrid_id else null end) as nonpub, "+
			"count(distinct expDetails.hybrid_id) as totArrays  "+
			"from CuratedExperimentDetails expDetails "+
			"left join PUBLIC_EXPERIMENTS pe on expDetails.exp_id = pe.exp_id "+
			", " +
			"TSAMPLE sample2 left join TOTHERS otherOrganismPart "+
			"	on sample2.tsample_sysuid = otherOrganismPart.tothers_sampleid "+
			"	and otherOrganismPart.tothers_del_status = 'U' "+
			"	and otherOrganismPart.tothers_id = 'ORGANISM_PART', "+
			"valid_terms organism_part "+
			"where 1 = 1 "+
			getMyCoreWhereClause(hybridIDs, channel) +
			"and sample2.tsample_sysuid = expDetails.tsample_sysuid "+
			"and expDetails.tsample_organism_part = organism_part.term_id "+
			"group by case when organism_part.value = 'other' "+
			"	then otherOrganismPart.tothers_value else organism_part.value end";

		//log.debug ("in Array.getOrganismParts");
		//log.debug("query = "+query);
		ArrayCount[] myArrayCounts = null;
                Results myResults = new Results(query, conn);

		myArrayCounts = setupArrayCounts(myResults);

		myResults.close();
		return myArrayCounts;
  	}

	/**
	 * Gets the unique values for a particular attribute for an array of Array objects
	 * @param myArrays	an array of Array objects
	 * @param column	the name of the column for which the unique values are requested
	 * @return            an array of String objects containing the set of unique values for the column
	 */
	public String[] getUniqueValues (Array[] myArrays, String column) {
		//log.debug("in getUniqueValues. column = "+column);
        	Set <String> values = new TreeSet<String>();
        	DbUtils myDbUtils = new DbUtils();
        	for (int i=0; i<myArrays.length; i++) {
                	if (column.equals("gender")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getGender()));
                	} else if (column.equals("biosource_type")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getBiosource_type()));
                	} else if (column.equals("development_stage")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getDevelopment_stage()));
                	} else if (column.equals("age_status")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getAge_status()));
                	} else if (column.equals("age_range_min")) {
                        	values.add(myDbUtils.setToNoneIfNull(Double.toString(myArrays[i].getAge_range_min())));
                	} else if (column.equals("age_range_max")) {
                        	values.add(myDbUtils.setToNoneIfNull(Double.toString(myArrays[i].getAge_range_max())));
                	} else if (column.equals("time_point")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getTime_point()));
                	} else if (column.equals("organism_part")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getOrganism_part()));
                	} else if (column.equals("genetic_variation")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getGenetic_variation()));
                	} else if (column.equals("individual_genotype")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getIndividual_genotype()));
                	} else if (column.equals("disease_state")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getDisease_state()));
                	} else if (column.equals("separation_technique")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getSeparation_technique()));
                	} else if (column.equals("target_cell_type")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getTarget_cell_type()));
                	} else if (column.equals("cell_line")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getCell_line()));
                	} else if (column.equals("strain")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getStrain()));
                	} else if (column.equals("treatment")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getTreatment()));
                	} else if (column.equals("organism")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getOrganism()));
                	} else if (column.equals("expName")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getExperiment_name()));
                	} else if (column.equals("replicateExperiment")) {
                        	values.add(myDbUtils.setToNoneIfNull(myArrays[i].getExperiment_name()) + " " + 
                        		myDbUtils.setToNoneIfNull(myArrays[i].getStrain()));
                	}
		}
        	return (String[]) values.toArray(new String[values.size()]);
	}

  public boolean isUnique (Array[] myArrays, String column) {
        boolean allUnique = true;
	String[] uniqueValues = getUniqueValues(myArrays, column);

	if (uniqueValues.length > 1) {
		allUnique=false;
	} else {
		allUnique=true;
	}

        return allUnique;
  }

	/**
	 * Gets all of the criteria that have more than one distinct value for the arrays in this experiment.
	 * @param myArrays	an array of Array objects 
	 * @return            a Hashtable in the form of the key and its associated value to be used in a drop-down box
	 */
	public Hashtable getCriteriaList (Array[] myArrays) {
		log.debug("in getCriteriaList");

        	Hashtable<String,String> criteriaList = new Hashtable<String,String>();

        	if (!isUnique(myArrays, "gender")) {
			criteriaList.put("Gender", "gender");
        	}
        	if (!isUnique(myArrays, "biosource_type")) {
			criteriaList.put("Biosource Type", "biosource_type");
        	}
        	if (!isUnique(myArrays, "development_stage")) {
                	criteriaList.put("Development Stage", "development_stage");
        	}
        	if (!isUnique(myArrays, "organism")) {
			criteriaList.put("Organism", "organism");
        	}
        	if (!isUnique(myArrays, "age_range_min")) {
                	criteriaList.put("Minimum Age", "age_range_min");
        	}
        	if (!isUnique(myArrays, "age_range_max")) {
                	criteriaList.put("Maximum Age", "age_range_max");
        	}
        	if (!isUnique(myArrays, "time_point")) {
                	criteriaList.put("Initial Time Point", "time_point");
        	}
        	if (!isUnique(myArrays, "organism_part")) {
                	criteriaList.put("Organism Part", "organism_part");
        	}
        	if (!isUnique(myArrays, "genetic_variation")) {
                	criteriaList.put("Genetic Modification", "genetic_variation");
        	}
        	if (!isUnique(myArrays, "individual_genotype")) {
                	criteriaList.put("Individual Genotype", "individual_genotype");
        	}
        	if (!isUnique(myArrays, "disease_state")) {
                	criteriaList.put("Disease State", "disease_state");
        	}
        	if (!isUnique(myArrays, "separation_technique")) {
                	criteriaList.put("Separation Technique", "separation_technique");
        	}
        	if (!isUnique(myArrays, "target_cell_type")) {
                	criteriaList.put("Target Cell Type", "target_cell_type");
        	}
        	if (!isUnique(myArrays, "cell_line")) {
                	criteriaList.put("Line", "cell_line");
        	}
        	if (!isUnique(myArrays, "strain")) {
                	criteriaList.put("Strain", "strain");
        	}
		if (!isUnique(myArrays, "expName")) {
			criteriaList.put("Experiment Name", "expName");
		}
		if (!isUnique(myArrays, "treatment")) {
			criteriaList.put("Treatment", "treatment");
		}

		return criteriaList;
	}

	/**
	 * Creates a string containing the information about the arrays in the hybridIDs string
	 * @param hybridIDs	the hybrid IDs
	 * @param conn	the database connection
	 * @return            the array information as a string
	 * @throws            SQLException if a database error occurs
	 */
	public String getArrayInfoAsString(String hybridIDs, Connection conn) throws SQLException {
        	log.info("in getArrayInfoAsString, hybridIDs = " + hybridIDs);

        	Array [] myArrays = getArraysByHybridIDs(hybridIDs, conn);
		myArrays = sortArrays(myArrays, "arrayName");
		log.debug("size of myArrays = "+myArrays.length);

        	String arrayInformation = "Organism\t" +
                                	"Genetic Variation\t" +
                                	"Sex\t" +
                                	"Organism Part\t" +
                                	"Array Name\t" +
                                	"Experiment Name\t" +
                                	"Submitter" +
                                	"\r\n";

		for (int i=0; i<myArrays.length; i++) {
			Array thisArray = myArrays[i]; 
                	arrayInformation = arrayInformation + thisArray.getOrganism() + "\t" +
						thisArray.getGenetic_variation() + "\t" +
						thisArray.getGender() + "\t" +
						thisArray.getOrganism_part() + "\t" +
						thisArray.getHybrid_name() + "\t" +
						thisArray.getExperiment_name() + "\t" +
						thisArray.getSubmitter() + "\r\n";
        	}

        	return arrayInformation;
	}

	/**
	 * Returns one Array object from an array of Array objects
	 * @param myArrays	an array of Array objects 
	 * @param hybrid_id	the hybrid id of the object to return
	 * @return            an Array object
	 */
	public Array getArrayFromMyArrays(Array[] myArrays, int hybrid_id) {
        	//
        	// Return the Array object that contains the hybrid_id from the myArrays
        	//

        	myArrays = sortArrays(myArrays, "hybrid_id");

        	int hybridToFindIndex = Arrays.binarySearch(myArrays, new Array(hybrid_id), new ArraySortComparator());
	
        	Array thisArray = myArrays[hybridToFindIndex];

        	return thisArray;
	}

  public boolean equals(Object obj) {
	if (!(obj instanceof Array)) return false;
	return (this.hybrid_id == ((Array)obj).hybrid_id);
  }
        
  public void print(Array myArray) {
	myArray.print();
  }

  public String toString() {
        return "This Array has hybrid_id = " + hybrid_id +
		", organism = " + organism +
		", hybrid name = " + hybrid_name;
  }

  public void print() {
	String arrayString = toString();
	log.debug("Array = " + arrayString);
  }


  public Array[] sortArrays (Array[] myArrays, String sortColumn) {
        setSortColumn(sortColumn);
        Arrays.sort(myArrays, new ArraySortComparator());
        return myArrays;
  }

  public Array[] sortArrays (Array[] myArrays, String sortColumn, String sortOrder) {
        setSortColumn(sortColumn);
        setSortOrder(sortOrder);
        Arrays.sort(myArrays, new ArraySortComparator());
        return myArrays;
  }

  private String sortOrder;
  public void setSortOrder(String inString) {
        this.sortOrder = inString;
  }

  public String getSortOrder() {
        return sortOrder;
  }

  private String sortColumn;
  public void setSortColumn(String inString) {
        this.sortColumn = inString;
  }

  public String getSortColumn() {
        return sortColumn;
  }

  public class ArraySortComparator implements Comparator<edu.ucdenver.ccp.PhenoGen.data.Array> {
        int compare;
        Array array1, array2;

        public int compare(edu.ucdenver.ccp.PhenoGen.data.Array array1, edu.ucdenver.ccp.PhenoGen.data.Array array2) { 
		//log.debug("in ArraySortComparator. sortOrder = "+getSortOrder() + ", sortColumn = "+getSortColumn());
		if (getSortOrder() == null || getSortOrder().equals("") || getSortOrder().equals("A")) {
                	array1 = array1;
                	array2 = array2;
		} else {
                	array1 = array2;
                	array2 = array1;
		}
		//log.debug("array1 HybridId = "+array1.getHybrid_id()+ ", array2 HybridId = "+array2.getHybrid_id());

                if (getSortColumn().equals("organism")) {
                        compare = array1.getOrganism().compareTo(array2.getOrganism());
                } else if (getSortColumn().equals("category") || getSortColumn().equals("genetic_variation")) {
                        compare = array1.getGenetic_variation().compareTo(array2.getGenetic_variation());
                } else if (getSortColumn().equals("sampleName")) {
                        compare = array1.getSample_name().compareTo(array2.getSample_name());
                } else if (getSortColumn().equals("arrayName") || getSortColumn().equals("hybrid_name")) {
                        compare = array1.getHybrid_name().compareTo(array2.getHybrid_name());
                } else if (getSortColumn().equals("arrayName_uppercase") || getSortColumn().equals("hybrid_name_uppercase")) {
                        compare = array1.getHybrid_name().toUpperCase().compareTo(array2.getHybrid_name().toUpperCase());
                } else if (getSortColumn().equals("strain")) {
                        compare = array1.getStrain().compareTo(array2.getStrain());
                } else if (getSortColumn().equals("treatment")) {
                        compare = array1.getTreatment().compareTo(array2.getTreatment());
                } else if (getSortColumn().equals("hybrid_id")) {
                        compare = new Integer(array1.getHybrid_id()).compareTo(new Integer(array2.getHybrid_id()));
                } else if (getSortColumn().equals("gender") || getSortColumn().equals("sex")) {
                        compare = array1.getGender().compareTo(array2.getGender());
                } else if (getSortColumn().equals("organism_part") || getSortColumn().equals("organismPart")) {
                        compare = array1.getOrganism_part().compareTo(array2.getOrganism_part());
                } else if (getSortColumn().equals("arrayType")) {
                        compare = array1.getArray_type().compareTo(array2.getArray_type());
                } else if (getSortColumn().equals("experimentName") || getSortColumn().equals("experiment_name")) {
                        compare = array1.getExperiment_name().compareTo(array2.getExperiment_name());
                } else {
                        compare = new Integer(array1.getHybrid_id()).compareTo(new Integer(array2.getHybrid_id()));
		}
                return compare;
        }

  }
	/**
   	* Gets the set of array counts as select options
	* @param arrayCounts 	an array of ArrayCount objects
   	* @return            a LinkedHashMap of values
   	*/
	public LinkedHashMap<String, String> getAsSelectOptions(ArrayCount[] arrayCounts) {
        	//log.debug("in getAsSelectOptions");

        	LinkedHashMap<String, String> optionHash = new LinkedHashMap<String, String>();

        	for (int i=0; i<arrayCounts.length; i++) {
			if (!arrayCounts[i].getCountName().equals("No Value Entered")) {
                		optionHash.put(arrayCounts[i].getCountName(), arrayCounts[i].getCountName());
			}
        	}
        	return optionHash;
	}

/*
	/** 
	 * Gets the count name as a set.
	 * @param arrayCounts an array of ArrayCount objects
	 * @return	a Set of Strings
	 */
/*
	public Set<String> getAsSet(ArrayCount[] arrayCounts) {
		//log.debug("in getArrayCountsAsSet");
		Set<String> strings = new TreeSet<String>();
	
        	for (int i=0; i<arrayCounts.length; i++) {
			if (!arrayCounts[i].getCountName().equals("No Value Entered")) {
                		strings.add(arrayCounts[i].getCountName());
			}
        	}
        	return strings;
	}
*/

  public class ArrayCount {
	String organism = "";
	String countName = "";
	int publicCount = 0;
	int nonPublicCount = 0;
	int totalCount = 0;

	public ArrayCount (String countName, int publicCount, int nonPublicCount, int totalCount, String organism) {
		setOrganism(organism);
		setCountName(countName);
		setPublicCount(publicCount);
		setNonPublicCount(nonPublicCount);
		setTotalCount(totalCount);
	}
	public ArrayCount (String countName, int publicCount, int nonPublicCount, int totalCount) {
		setCountName(countName);
		setPublicCount(publicCount);
		setNonPublicCount(nonPublicCount);
		setTotalCount(totalCount);
	}

	public void setOrganism(String inString) {
		this.organism = inString;
	}

	public String getOrganism() {
		return organism;
	}
	
	public void setCountName(String inString) {
		this.countName = inString;
	}

	public String getCountName() {
		return countName;
	}
	
	public void setPublicCount(int inInt) {
		this.publicCount = inInt;
	}

	public int getPublicCount() {
		return publicCount;
	}
	
	public void setNonPublicCount(int inInt) {
		this.nonPublicCount = inInt;
	}

	public int getNonPublicCount() {
		return nonPublicCount;
	}
	
	public void setTotalCount(int inInt) {
		this.totalCount = inInt;
	}

	public int getTotalCount() {
		return totalCount;
	}
	
  }



}

