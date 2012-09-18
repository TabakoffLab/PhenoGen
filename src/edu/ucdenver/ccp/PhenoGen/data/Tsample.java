package edu.ucdenver.ccp.PhenoGen.data;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import edu.ucdenver.ccp.PhenoGen.util.DbUtils;

import edu.ucdenver.ccp.util.Debugger;

import edu.ucdenver.ccp.util.ObjectHandler;

import edu.ucdenver.ccp.util.sql.Results;

/* for logging messages */
import org.apache.log4j.Logger;

/**
 * Class for handling data related to Tsample
 *  @author  Cheryl Hornbaker
 */

public class Tsample {

	private Logger log=null;

	private DbUtils myDbUtils = new DbUtils();
	private Debugger myDebugger = new Debugger();
	private ObjectHandler myObjectHandler = new ObjectHandler();
	private edu.ucdenver.ccp.PhenoGen.data.Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();
	private ValidTerm myValidTerm = new ValidTerm();

    	private static final String NOT_APPLICABLE = "N/A";

	public Tsample() {
		log = Logger.getRootLogger();
	}

	public Tsample(int tsample_sysuid) {
		log = Logger.getRootLogger();
		this.setTsample_sysuid(tsample_sysuid);
	}


	private int tsample_sysuid;
	private String tsample_id;
	private int tsample_taxid;
	private String tsample_cell_provider;
	private int tsample_sample_type;
	private int tsample_dev_stage;
	private int tsample_age_status;
	private double tsample_agerange_min;
	private double tsample_agerange_max;
	private int tsample_time_unit;
	private int tsample_time_point;
	private int tsample_organism_part;
	private int tsample_sex;
	private int tsample_genetic_variation;
	private String tsample_individual;
	private String tsample_individual_gen;
	private String tsample_disease_state;
	private String tsample_target_cell_type;
	private String tsample_cell_line;
	private String tsample_strain;
	private String tsample_additional;
	private int tsample_separation_tech;
	private int tsample_protocolid;
	private int tsample_growth_protocolid;
	private int tsample_exprid;
	private String tsample_del_status = "U";
	private String tsample_exp_name;
	private String tsample_user;
	private java.sql.Timestamp tsample_last_change;
	private String sortColumn ="";
	private String sortOrder ="A";

	public void setTsample_sysuid(int inInt) {
		this.tsample_sysuid = inInt;
	}

	public int getTsample_sysuid() {
		return this.tsample_sysuid;
	}

	public void setTsample_id(String inString) {
		this.tsample_id = inString;
	}

	public String getTsample_id() {
		return this.tsample_id;
	}

	public void setTsample_taxid(int inInt) {
		this.tsample_taxid = inInt;
	}

	public int getTsample_taxid() {
		return this.tsample_taxid;
	}

	public void setTsample_cell_provider(String inString) {
		this.tsample_cell_provider = inString;
	}

	public String getTsample_cell_provider() {
		return this.tsample_cell_provider;
	}

	public void setTsample_sample_type(int inInt) {
		this.tsample_sample_type = inInt;
	}

	public int getTsample_sample_type() {
		return this.tsample_sample_type;
	}

	public void setTsample_dev_stage(int inInt) {
		this.tsample_dev_stage = inInt;
	}

	public int getTsample_dev_stage() {
		return this.tsample_dev_stage;
	}

	public void setTsample_age_status(int inInt) {
		this.tsample_age_status = inInt;
	}

	public int getTsample_age_status() {
		return this.tsample_age_status;
	}

	public void setTsample_agerange_min(double inDouble) {
		this.tsample_agerange_min = inDouble;
	}

	public double getTsample_agerange_min() {
		return this.tsample_agerange_min;
	}

	public void setTsample_agerange_max(double inDouble) {
		this.tsample_agerange_max = inDouble;
	}

	public double getTsample_agerange_max() {
		return this.tsample_agerange_max;
	}

	public void setTsample_time_unit(int inInt) {
		this.tsample_time_unit = inInt;
	}

	public int getTsample_time_unit() {
		return this.tsample_time_unit;
	}

	public void setTsample_time_point(int inInt) {
		this.tsample_time_point = inInt;
	}

	public int getTsample_time_point() {
		return this.tsample_time_point;
	}

	public void setTsample_organism_part(int inInt) {
		this.tsample_organism_part = inInt;
	}

	public int getTsample_organism_part() {
		return this.tsample_organism_part;
	}

	public void setTsample_sex(int inInt) {
		this.tsample_sex = inInt;
	}

	public int getTsample_sex() {
		return this.tsample_sex;
	}

	public void setTsample_genetic_variation(int inInt) {
		this.tsample_genetic_variation = inInt;
	}

	public int getTsample_genetic_variation() {
		return this.tsample_genetic_variation;
	}

	public void setTsample_individual(String inString) {
		this.tsample_individual = inString;
	}

	public String getTsample_individual() {
		return this.tsample_individual;
	}

	public void setTsample_individual_gen(String inString) {
		this.tsample_individual_gen = inString;
	}

	public String getTsample_individual_gen() {
		return this.tsample_individual_gen;
	}

	public void setTsample_disease_state(String inString) {
		this.tsample_disease_state = inString;
	}

	public String getTsample_disease_state() {
		return this.tsample_disease_state;
	}

	public void setTsample_target_cell_type(String inString) {
		this.tsample_target_cell_type = inString;
	}

	public String getTsample_target_cell_type() {
		return this.tsample_target_cell_type;
	}

	public void setTsample_cell_line(String inString) {
		this.tsample_cell_line = inString;
	}

	public String getTsample_cell_line() {
		return this.tsample_cell_line;
	}

	public void setTsample_strain(String inString) {
		this.tsample_strain = inString;
	}

	public String getTsample_strain() {
		return this.tsample_strain;
	}

	public void setTsample_additional(String inString) {
		this.tsample_additional = inString;
	}

	public String getTsample_additional() {
		return this.tsample_additional;
	}

	public void setTsample_separation_tech(int inInt) {
		this.tsample_separation_tech = inInt;
	}

	public int getTsample_separation_tech() {
		return this.tsample_separation_tech;
	}

	public void setTsample_protocolid(int inInt) {
		this.tsample_protocolid = inInt;
	}

	public int getTsample_protocolid() {
		return this.tsample_protocolid;
	}

	public void setTsample_growth_protocolid(int inInt) {
		this.tsample_growth_protocolid = inInt;
	}

	public int getTsample_growth_protocolid() {
		return this.tsample_growth_protocolid;
	}

	public void setTsample_exprid(int inInt) {
		this.tsample_exprid = inInt;
	}

	public int getTsample_exprid() {
		return this.tsample_exprid;
	}

	public void setTsample_exp_name(String inString) {
		this.tsample_exp_name = inString;
	}

	public String getTsample_exp_name() {
		return this.tsample_exp_name;
	}

	public void setTsample_del_status(String inString) {
		this.tsample_del_status = inString;
	}

	public String getTsample_del_status() {
		return this.tsample_del_status;
	}

	public void setTsample_user(String inString) {
		this.tsample_user = inString;
	}

	public String getTsample_user() {
		return this.tsample_user;
	}

	public void setTsample_last_change(java.sql.Timestamp inTimestamp) {
		this.tsample_last_change = inTimestamp;
	}

	public java.sql.Timestamp getTsample_last_change() {
		return this.tsample_last_change;
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

	public void validateSample_name(String value, int expID, Connection conn) throws DataException, SQLException {
		log.debug("in validateTsample_id. name = "+value);
		if (myObjectHandler.isEmpty(value)) {
			throw new DataException("ERROR: Sample Name must be entered.");
		} else if (!isUnique(value, expID, conn)) {
			throw new DataException("ERROR: All Sample Names in this experiment must be unique.");
		}
	}

	public void validateOrganism(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateOrganism.  = "+value);
		if (myObjectHandler.isEmpty(value)) {
			throw new DataException("ERROR: Organism must be entered.");
		} else if (!myObjectHandler.getAsSet(myArray.getArrayOrganisms("All", "Single", conn), "CountName").contains(value)) {
			throw new DataException("ERROR: Value for Organism is invalid.");
		}
	}

	public void validateSex(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateSex.  = "+value);
		if (myObjectHandler.isEmpty(value)) {
			throw new DataException("ERROR: Sex must be entered.");
		} else if (!myObjectHandler.getAsSet(myValidTerm.getFromValidTerm("SEX", conn), "Value").contains(value)) {
			throw new DataException("ERROR: Value for Sex is invalid.");
		}
	}

	public void validateOrganism_part(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateOrganism_part.  = "+value);
		if (myObjectHandler.isEmpty(value)) {
			throw new DataException("ERROR: Organism Part must be entered.");
		} else if (!myObjectHandler.getAsSet(myValidTerm.getFromValidTerm("ORGANISM_PART", conn), "Value").contains(value)) {
			throw new DataException("WARNING: Value for Organism Part was not one of the suggested values, so it was set to 'other'.  "+
						"The value you entered was saved as well.");
		}
	}

	public void validateSample_type(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateSample_type.  = "+value);
		if (myObjectHandler.isEmpty(value)) {
			throw new DataException("ERROR: Sample Type must be entered.");
		} else if (!myObjectHandler.getAsSet(myValidTerm.getFromValidTerm("SAMPLE_TYPE", conn), "Value").contains(value)) {
			throw new DataException("WARNING: Value for Sample Type was not one of the suggested values, so it was set to 'other'.  "+
						"The value you entered was saved as well.");
		}
	}

	public void validateDev_stage(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateDev_stage.  = "+value);
		if (myObjectHandler.isEmpty(value)) {
			throw new DataException("ERROR: Development Stage must be entered.");
		} else if (!myObjectHandler.getAsSet(myValidTerm.getFromValidTerm("DEVELOPMENTAL_STAGE", conn), "Value").contains(value)) {
			throw new DataException("WARNING: Value for Development Stage was not one of the suggested values, so it was set to 'other'.  "+
						"The value you entered was saved as well.");
		}
	}

	public void validateAge(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateAge.  = "+value);
		if (!myObjectHandler.isEmpty(value) && !myObjectHandler.isValidRange(value)) {
			throw new DataException("ERROR: Age must either be a single number or a range.  "+
					"A range should be entered as a number followed by '-' and another number, with no spaces in between.");
		}
	}

	public void validateAge_time_unit(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateAge_time_unit.  = "+value);
		if (!myObjectHandler.isEmpty(value) && !myObjectHandler.getAsSet(myValidTerm.getFromValidTerm("TIME_UNIT", conn), "Value").contains(value)) {
			throw new DataException("ERROR: Value for Age Time Unit is invalid.");
		}
	}

	public void validateGenetic_variation(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateGenetic_variation.  = "+value);
		if (!myObjectHandler.isEmpty(value) && !myObjectHandler.getAsSet(myValidTerm.getFromValidTerm("GENETIC_VARIATION", conn), "Value").contains(value)) {
			throw new DataException("ERROR: Value for Genetic Modification is invalid.");
		}
	}

	public void validateIndividual_genotype(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateIndividual_genotype.  = "+value);
		if (!myObjectHandler.isEmpty(value) && !myObjectHandler.getAsSet(myArray.getGenotypes("All", "Single", conn), "CountName").contains(value)) {
			throw new DataException("WARNING: Value for Genotype was not one of the suggested values.  "+
						"The value you entered was saved as a new value.");
		}
	}

	public void validateCell_line(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateCell_line.  = "+value);
		if (!myObjectHandler.isEmpty(value) && !myObjectHandler.getAsSet(myArray.getCellLines("All", "Single", conn), "CountName").contains(value)) {
			throw new DataException("WARNING: Value for Selected Line was not one of the suggested values.  "+
						"The value you entered was saved as a new value.");
		}
	}

	public void validateStrain(String value, Connection conn) throws DataException, SQLException {
		log.debug("in validateStrain.  = "+value);
		if (!myObjectHandler.isEmpty(value) && !myObjectHandler.getAsSet(myArray.getStrains("All", "Single", conn), "CountName").contains(value)) {
			throw new DataException("WARNING: Value for Strain was not one of the suggested values.  "+
						"The value you entered was saved as a new value.");
		}
	}

	public void validateCompound(String value, boolean isCompoundDesign, Connection conn) throws DataException, SQLException {
		log.debug("in validateCompound.  = "+value);
		if (!isCompoundDesign && !myObjectHandler.isEmpty(value) && !value.equals(NOT_APPLICABLE)) {
			throw new DataException("ERROR: This experiment must be designated as a 'compound treatment design'"+
							" experiment in order to specify a value in the Compound field.");
		} else if (isCompoundDesign) {
			if (myObjectHandler.isEmpty(value) || value.equals(NOT_APPLICABLE)) {
				throw new DataException("ERROR: Compound must be entered for a 'compound treatment design' experiment.");
			} else if (!myObjectHandler.isEmpty(value) && !value.equals(NOT_APPLICABLE) && 
				!myObjectHandler.getAsSet(myArray.getCompounds("All", "Single", conn), "CountName").contains(value)) {
				throw new DataException("WARNING: Value for Compound was not one of the suggested values.  "+
						"The value you entered was saved as a new value.");
			}
		}
	}

	public void validateDose(String value, boolean isCompoundDesign, Connection conn) throws DataException, SQLException {
		log.debug("in validateDose.  = "+value);
		if (!isCompoundDesign && !myObjectHandler.isEmpty(value) && !value.equals(NOT_APPLICABLE)) {
			throw new DataException("ERROR: This experiment must be designated as a 'compound treatment design'"+
							" experiment in order to specify a value in the Dose field.");
		} else if (isCompoundDesign) {
			if (myObjectHandler.isEmpty(value) || value.equals(NOT_APPLICABLE)) {
				throw new DataException("ERROR: Dose must be entered for a 'compound treatment design' experiment.");
			}
		}
	}

	public void validateDose_unit(String value, boolean isCompoundDesign, Connection conn) throws DataException, SQLException {
		log.debug("in validateDose_unit.  = "+value);
		if (!isCompoundDesign && !myObjectHandler.isEmpty(value) && !value.equals(NOT_APPLICABLE)) {
			throw new DataException("ERROR: This experiment must be designated as a 'compound treatment design'"+
							" experiment in order to specify a value in the Dose Unit field.");
		} else if (isCompoundDesign) {
			if (myObjectHandler.isEmpty(value) || value.equals(NOT_APPLICABLE)) {
				throw new DataException("ERROR: Dose Unit must be entered for a 'compound treatment design' experiment.");
			}
		}
	}

	public void validateTreatment(String value, boolean isCompoundDesign, Connection conn) throws DataException, SQLException {
		log.debug("in validateTreatment.  = "+value);
		if (!isCompoundDesign && !myObjectHandler.isEmpty(value) && !value.equals(NOT_APPLICABLE)) {
			throw new DataException("ERROR: This experiment must be designated as a 'compound treatment design'"+
							" experiment in order to specify a value in the Treatment field.");
		} else if (isCompoundDesign) {
			if (myObjectHandler.isEmpty(value) || value.equals(NOT_APPLICABLE)) {
				throw new DataException("ERROR: Treatment must be entered for a 'compound treatment design' experiment.");
			} else if (!myObjectHandler.isEmpty(value) && !value.equals(NOT_APPLICABLE) && 
				!myObjectHandler.getAsSet(myArray.getTreatments("All", "Single", conn), "CountName").contains(value)) {
				throw new DataException("WARNING: Value for Treatment was not one of the suggested values.  "+
						"The value you entered was saved as a new value.");
			}
		}
	}

	public void validateDuration(String value, boolean isCompoundDesign, Connection conn) throws DataException, SQLException {
		log.debug("in validateDuration.  = "+value);
		if (!isCompoundDesign && !myObjectHandler.isEmpty(value) && !value.equals(NOT_APPLICABLE)) {
			throw new DataException("ERROR: This experiment must be designated as a 'compound treatment design'"+
							" experiment in order to specify a value in the Duration field.");
		} else if (isCompoundDesign) {
			if (myObjectHandler.isEmpty(value) || value.equals(NOT_APPLICABLE)) {
				throw new DataException("ERROR: Duration must be entered for a 'compound treatment design' experiment.");
			}
		}
	}


	public boolean isUnique(String sample_name, int expID, Connection conn) throws DataException, SQLException {
		log.debug("in Tsample isUnique. name = "+sample_name);
		String query = 
			"select tsample_sysuid "+
			"from tsample "+
			"where tsample_exprid = ? "+
			"and tsample_id = ?"; 
	
		Results myResults = new Results(query, new Object[] {expID, sample_name}, conn);

		int existingID = myResults.getIntValueFromFirstRow();

		myResults.close();

		return (existingID == -99 ? true : false);
	}

	/**
	 * Gets all the Tsample
	 * @param experimentID 	the ID of the experiment
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	an array of Tsample objects
	 */
	public Tsample[] getAllTsample(int experimentID, Connection conn) throws SQLException {

		log.debug("In getAllTsample");

		String query = 
			"select "+
			"tsample_sysuid, tsample_id, tsample_taxid, tsample_cell_provider, tsample_sample_type, "+
			"tsample_dev_stage, tsample_age_status, tsample_agerange_min, tsample_agerange_max, tsample_time_unit, "+
			"tsample_time_point, tsample_organism_part, tsample_sex, tsample_genetic_variation, tsample_individual, "+
			"tsample_individual_gen, tsample_disease_state, tsample_target_cell_type, tsample_cell_line, tsample_strain, "+
			"tsample_additional, tsample_separation_tech, tsample_protocolid, tsample_growth_protocolid, tsample_exprid, "+
			"tsample_del_status, tsample_user, to_char(tsample_last_change, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentdetails "+ 
			"where tsample_exprid = ? "+
			"order by tsample_id";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, experimentID, conn);

		Tsample[] myTsample = setupTsampleValues(myResults);

		myResults.close();

		return myTsample;
	}

        /**
         * Gets the records in the Tsample table that are children of Protocol.
         * @param protocol_id       identifier of the Protocol table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public Tsample[] getAllTsampleForProtocol(int protocol_id, Connection conn) throws SQLException {

                log.info("in getAllTsampleForProtocol");

                //Make sure committing is handled in calling method!

                String query =
			"select "+
			"tsample_sysuid, tsample_id, tsample_taxid, tsample_cell_provider, tsample_sample_type, "+
			"tsample_dev_stage, tsample_age_status, tsample_agerange_min, tsample_agerange_max, tsample_time_unit, "+
			"tsample_time_point, tsample_organism_part, tsample_sex, tsample_genetic_variation, tsample_individual, "+
			"tsample_individual_gen, tsample_disease_state, tsample_target_cell_type, tsample_cell_line, tsample_strain, "+
			"tsample_additional, tsample_separation_tech, tsample_protocolid, tsample_growth_protocolid, tsample_exprid, "+
			"tsample_del_status, tsample_user, to_char(tsample_last_change, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentDetails "+ 
                        "where (tsample_protocolid = ? "+
			"or tsample_growth_protocolid = ?) "+
			"and tsample_del_status = 'U' "+
			"order by tsample_id";

                Results myResults = new Results(query, new Object[] {protocol_id, protocol_id}, conn);

		Tsample[] myTsample = setupTsampleValues(myResults);

		myResults.close();

		return myTsample;
        }

	/**
	 * Gets the Tsample object for this tsample_sysuid
	 * @param tsample_sysuid	 the identifier of the Tsample
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	a Tsample object
	 */
	public Tsample getTsample(int tsample_sysuid, Connection conn) throws SQLException {

		log.debug("In getOne Tsample");

		String query = 
			"select "+
			"tsample_sysuid, tsample_id, tsample_taxid, tsample_cell_provider, tsample_sample_type, "+
			"tsample_dev_stage, tsample_age_status, tsample_agerange_min, tsample_agerange_max, tsample_time_unit, "+
			"tsample_time_point, tsample_organism_part, tsample_sex, tsample_genetic_variation, tsample_individual, "+
			"tsample_individual_gen, tsample_disease_state, tsample_target_cell_type, tsample_cell_line, tsample_strain, "+
			"tsample_additional, tsample_separation_tech, tsample_protocolid, tsample_growth_protocolid, tsample_exprid, "+
			"tsample_del_status, tsample_user, to_char(tsample_last_change, 'dd-MON-yyyy hh24:mi:ss'), exp_name "+
			"from experimentdetails "+ 
			"where tsample_sysuid = ?";

		//log.debug("query =  " + query);

		Results myResults = new Results(query, tsample_sysuid, conn);

		Tsample myTsample = setupTsampleValues(myResults)[0];

		myResults.close();

		return myTsample;
	}

	/**
	 * Creates a record in the Tsample table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 * @return	the identifier of the record created
	 */
	public int createTsample(Connection conn) throws SQLException {

		int tsample_sysuid = myDbUtils.getUniqueID("Tsample_seq", conn);

		log.debug("In create Tsample");

		String query = 
			"insert into Tsample "+
			"(tsample_sysuid, tsample_id, tsample_taxid, tsample_cell_provider, tsample_sample_type, "+
			"tsample_dev_stage, tsample_age_status, tsample_agerange_min, tsample_agerange_max, tsample_time_unit, "+
			"tsample_time_point, tsample_organism_part, tsample_sex, tsample_genetic_variation, tsample_individual, "+
			"tsample_individual_gen, tsample_disease_state, tsample_target_cell_type, tsample_cell_line, tsample_strain, "+
			"tsample_additional, tsample_separation_tech, tsample_protocolid, tsample_growth_protocolid, tsample_exprid, "+
			"tsample_del_status, tsample_user, tsample_last_change) "+
			"values "+
			"(?, ?, ?, ?, ?, "+
			"?, ?, ?, ?, ?, "+
			"?, ?, ?, ?, ?, "+
			"?, ?, ?, ?, ?, "+
			"?, ?, ?, ?, ?, "+
			"?, ?, ?)";
		//log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tsample_sysuid);
		pstmt.setString(2, tsample_id);
		pstmt.setInt(3, tsample_taxid);
		pstmt.setString(4, tsample_cell_provider);
		pstmt.setInt(5, tsample_sample_type);
		pstmt.setInt(6, tsample_dev_stage);
		pstmt.setInt(7, tsample_age_status);
		myDbUtils.setDoubleToNullIfZero(pstmt, 8, tsample_agerange_min);
		myDbUtils.setDoubleToNullIfZero(pstmt, 9, tsample_agerange_max);
		pstmt.setInt(10, tsample_time_unit);
		pstmt.setInt(11, tsample_time_point);
		pstmt.setInt(12, tsample_organism_part);
		pstmt.setInt(13, tsample_sex);
		pstmt.setInt(14, tsample_genetic_variation);
		pstmt.setString(15, tsample_individual);
		pstmt.setString(16, tsample_individual_gen);
		pstmt.setString(17, tsample_disease_state);
		pstmt.setString(18, tsample_target_cell_type);
		pstmt.setString(19, tsample_cell_line);
		pstmt.setString(20, tsample_strain);
		pstmt.setString(21, tsample_additional);
		pstmt.setInt(22, tsample_separation_tech);
		myDbUtils.setToNullIfZero(pstmt, 23, tsample_protocolid);
		myDbUtils.setToNullIfZero(pstmt, 24, tsample_growth_protocolid);
		pstmt.setInt(25, tsample_exprid);
		pstmt.setString(26, "U");
		pstmt.setString(27, tsample_user);
		pstmt.setTimestamp(28, now);

		pstmt.executeUpdate();
		pstmt.close();

		this.setTsample_sysuid(tsample_sysuid);

		return tsample_sysuid;
	}

	/**
	 * Updates a record in the Tsample table.
	 * @param conn 	the database connection
	 * @throws SQLException	if an error occurs while accessing the database
	 */
	public void update(Connection conn) throws SQLException {

		String query = 

			"update Tsample "+
			"set tsample_sysuid = ?, tsample_id = ?, tsample_taxid = ?, tsample_cell_provider = ?, tsample_sample_type = ?, "+
			"tsample_dev_stage = ?, tsample_age_status = ?, tsample_agerange_min = ?, tsample_agerange_max = ?, tsample_time_unit = ?, "+
			"tsample_time_point = ?, tsample_organism_part = ?, tsample_sex = ?, tsample_genetic_variation = ?, tsample_individual = ?, "+
			"tsample_individual_gen = ?, tsample_disease_state = ?, tsample_target_cell_type = ?, tsample_cell_line = ?, tsample_strain = ?, "+
			"tsample_additional = ?, tsample_separation_tech = ?, tsample_protocolid = ?, tsample_growth_protocolid = ?, tsample_exprid = ?, "+
			"tsample_del_status = ?, tsample_user = ?, tsample_last_change = ? "+
			"where tsample_sysuid = ?";

		log.debug("query =  " + query);

		java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());

		PreparedStatement pstmt = conn.prepareStatement(query, 
				ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_UPDATABLE);

		pstmt.setInt(1, tsample_sysuid);
		pstmt.setString(2, tsample_id);
		pstmt.setInt(3, tsample_taxid);
		pstmt.setString(4, tsample_cell_provider);
		pstmt.setInt(5, tsample_sample_type);
		pstmt.setInt(6, tsample_dev_stage);
		pstmt.setInt(7, tsample_age_status);
		pstmt.setDouble(8, tsample_agerange_min);
		pstmt.setDouble(9, tsample_agerange_max);
		pstmt.setInt(10, tsample_time_unit);
		pstmt.setInt(11, tsample_time_point);
		pstmt.setInt(12, tsample_organism_part);
		pstmt.setInt(13, tsample_sex);
		pstmt.setInt(14, tsample_genetic_variation);
		pstmt.setString(15, tsample_individual);
		pstmt.setString(16, tsample_individual_gen);
		pstmt.setString(17, tsample_disease_state);
		pstmt.setString(18, tsample_target_cell_type);
		pstmt.setString(19, tsample_cell_line);
		pstmt.setString(20, tsample_strain);
		pstmt.setString(21, tsample_additional);
		pstmt.setInt(22, tsample_separation_tech);
		myDbUtils.setToNullIfZero(pstmt, 23, tsample_protocolid);
		myDbUtils.setToNullIfZero(pstmt, 24, tsample_growth_protocolid);
		pstmt.setInt(25, tsample_exprid);
		pstmt.setString(26, tsample_del_status);
		pstmt.setString(27, tsample_user);
		pstmt.setTimestamp(28, now);
		pstmt.setInt(29, tsample_sysuid);

		pstmt.executeUpdate();
		pstmt.close();

	}


        /**
         * Deletes the record in the Tsample table and also deletes child records in related tables.
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */

        public void deleteTsample(Connection conn) throws SQLException {

                log.info("in deleteTsample");

                //conn.setAutoCommit(false);

                PreparedStatement pstmt = null;
                try {
                        new Tfctrval().deleteAllTfctrvalForTsample(tsample_sysuid, conn);
                        new Tpooled().deleteAllTpooledForTsample(tsample_sysuid, conn);

                        String query =
                                "delete from Tsample " +
                                "where tsample_sysuid = ?";

                        pstmt = conn.prepareStatement(query,
                                ResultSet.TYPE_SCROLL_INSENSITIVE,
                                ResultSet.CONCUR_UPDATABLE);

                        pstmt.setInt(1, tsample_sysuid);
                        pstmt.executeQuery();
                        pstmt.close();

                        //conn.commit();
                } catch (SQLException e) {
                        log.debug("error in deleteTsample");
                        //conn.rollback();
                        pstmt.close();
                        throw e;
                }
                //conn.setAutoCommit(true);
        }

        /**
         * Deletes the records in the Tsample table that are children of Tntxsyn.
         * @param tntxsyn_tax_id        identifier of the Tntxsyn table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTsampleForTntxsyn(int tntxsyn_tax_id, Connection conn) throws SQLException {

                log.info("in deleteAllTsampleForTntxsyn");

                //Make sure committing is handled in calling method!

                String query =
                        "select tsample_sysuid "+
                        "from Tsample "+
                        "where tsample_taxid = ?";

                Results myResults = new Results(query, tntxsyn_tax_id, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Tsample(Integer.parseInt(dataRow[0])).deleteTsample(conn);
                }

                myResults.close();

        }

        /**
         * Deletes the records in the Tsample table that are children of Experiment.
         * @param exp_id       identifier of the Experiment table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTsampleForExperiment(int exp_id, Connection conn) throws SQLException {

                log.info("in deleteAllTsampleForExperiment");

                //Make sure committing is handled in calling method!

                String query =
                        "select tsample_sysuid "+
                        "from Tsample "+
                        "where tsample_exprid = ?";

                Results myResults = new Results(query, exp_id, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Tsample(Integer.parseInt(dataRow[0])).deleteTsample(conn);
                }

                myResults.close();

        }

        /**
         * Deletes the records in the Tsample table that are children of Protocol.
         * @param protocol_id       identifier of the Protocol table
         * @param conn  the database connection
         * @throws            SQLException if an error occurs while accessing the database
         */
        public void deleteAllTsampleForProtocol(int protocol_id, Connection conn) throws SQLException {

                log.info("in deleteAllTsampleForProtocol");

                //Make sure committing is handled in calling method!

                String query =
                        "select tsample_sysuid "+
                        "from Tsample "+
                        "where tsample_protocolid = ?";

                Results myResults = new Results(query, protocol_id, conn);

                String[] dataRow;

                while ((dataRow = myResults.getNextRow()) != null) {
                        new Tsample(Integer.parseInt(dataRow[0])).deleteTsample(conn);
                }

                myResults.close();

        }

	/**
	 * Checks to see if a Tsample with the same tsample_id/tsample_exprid/tsample_del_status combination already exists.
	 * @param myTsample	the Tsample object being tested
	 * @param conn	the database connection
	 * @throws            SQLException if an error occurs while accessing the database
	 * @return	the tsample_sysuid of a Tsample that currently exists
	 */
	public int checkRecordExists(Tsample myTsample, Connection conn) throws SQLException {

		log.debug("in checkRecordExists");

		String query = 
			"select tsample_sysuid "+
			"from Tsample "+
			"where tsample_id = ? "+ 
 			"and tsample_exprid = ? "+ 
 			"and tsample_del_status = 'U'";

		PreparedStatement pstmt = conn.prepareStatement(query,
			ResultSet.TYPE_SCROLL_INSENSITIVE,
			ResultSet.CONCUR_UPDATABLE);

		pstmt.setString(1, tsample_id);
		pstmt.setInt(2, tsample_exprid);
		pstmt.setString(3, tsample_del_status);

		ResultSet rs = pstmt.executeQuery();

		int pk = (rs.next() ? rs.getInt(1) : -1);
		pstmt.close();
		return pk;
	}

	/**
	 * Creates an array of Tsample objects and sets the data values to those retrieved from the database.
	 * @param myResults	the Results object corresponding to a set of Tsample
	 * @return	An array of Tsample objects with their values setup 
	 */
	private Tsample[] setupTsampleValues(Results myResults) {

		//log.debug("in setupTsampleValues");

		List<Tsample> TsampleList = new ArrayList<Tsample>();

		String[] dataRow;

		while ((dataRow = myResults.getNextRow()) != null) {

			//log.debug("dataRow= "); myDebugger.print(dataRow);

			Tsample thisTsample = new Tsample();

			thisTsample.setTsample_sysuid(Integer.parseInt(dataRow[0]));
			thisTsample.setTsample_id(dataRow[1]);
			if (dataRow[2] != null && !dataRow[2].equals("")) {  
				thisTsample.setTsample_taxid(Integer.parseInt(dataRow[2]));
			}
			thisTsample.setTsample_cell_provider(dataRow[3]);
			if (dataRow[4] != null && !dataRow[4].equals("")) {  
				thisTsample.setTsample_sample_type(Integer.parseInt(dataRow[4]));
			}
			if (dataRow[5] != null && !dataRow[5].equals("")) {  
				thisTsample.setTsample_dev_stage(Integer.parseInt(dataRow[5]));
			}
			if (dataRow[6] != null && !dataRow[6].equals("")) {  
				thisTsample.setTsample_age_status(Integer.parseInt(dataRow[6]));
			}
			if (dataRow[7] != null && !dataRow[7].equals("")) {  
				thisTsample.setTsample_agerange_min(Double.parseDouble(dataRow[7]));
			}
			if (dataRow[8] != null && !dataRow[8].equals("")) {  
				thisTsample.setTsample_agerange_max(Double.parseDouble(dataRow[8]));
			}
			if (dataRow[9] != null && !dataRow[9].equals("")) {  
				thisTsample.setTsample_time_unit(Integer.parseInt(dataRow[9]));
			}
			if (dataRow[10] != null && !dataRow[10].equals("")) {  
				thisTsample.setTsample_time_point(Integer.parseInt(dataRow[10]));
			}
			if (dataRow[11] != null && !dataRow[11].equals("")) {  
				thisTsample.setTsample_organism_part(Integer.parseInt(dataRow[11]));
			}
			if (dataRow[12] != null && !dataRow[12].equals("")) {  
				thisTsample.setTsample_sex(Integer.parseInt(dataRow[12]));
			}
			if (dataRow[13] != null && !dataRow[13].equals("")) {  
				thisTsample.setTsample_genetic_variation(Integer.parseInt(dataRow[13]));
			}
			thisTsample.setTsample_individual(dataRow[14]);
			thisTsample.setTsample_individual_gen(dataRow[15]);
			thisTsample.setTsample_disease_state(dataRow[16]);
			thisTsample.setTsample_target_cell_type(dataRow[17]);
			thisTsample.setTsample_cell_line(dataRow[18]);
			thisTsample.setTsample_strain(dataRow[19]);
			thisTsample.setTsample_additional(dataRow[20]);
			if (dataRow[21] != null && !dataRow[21].equals("")) {  
				thisTsample.setTsample_separation_tech(Integer.parseInt(dataRow[21]));
			}
			if (dataRow[22] != null && !dataRow[22].equals("")) {  
				thisTsample.setTsample_protocolid(Integer.parseInt(dataRow[22]));
			}
			if (dataRow[23] != null && !dataRow[23].equals("")) {  
				thisTsample.setTsample_growth_protocolid(Integer.parseInt(dataRow[23]));
			}
			if (dataRow[24] != null && !dataRow[24].equals("")) {  
				thisTsample.setTsample_exprid(Integer.parseInt(dataRow[24]));
			}
			thisTsample.setTsample_del_status(dataRow[25]);
			thisTsample.setTsample_user(dataRow[26]);
			thisTsample.setTsample_last_change(new ObjectHandler().getOracleDateAsTimestamp(dataRow[27]));
			thisTsample.setTsample_exp_name(dataRow[28]);

			TsampleList.add(thisTsample);
		}

		Tsample[] TsampleArray = (Tsample[]) TsampleList.toArray(new Tsample[TsampleList.size()]);

		return TsampleArray;
	}

	/**
	 * Compares Tsample based on different fields.
	 */
	public class TsampleSortComparator implements Comparator<Tsample> {
		int compare;
		Tsample tsample1, tsample2;

		public int compare(Tsample object1, Tsample object2) {
			String sortColumn = getSortColumn();
			String sortOrder = getSortOrder();

			if (sortOrder.equals("A")) {
				tsample1 = object1;
				tsample2 = object2;
				// default for null columns for ascending order
				compare = 1;
			} else {
				tsample2 = object1;
				tsample1 = object2;
				// default for null columns for ascending order
				compare = -1;
			}

			//log.debug("tsample1 = " +tsample1+ "tsample2 = " +tsample2);

			if (sortColumn.equals("tsample_sysuid")) {
				compare = new Integer(tsample1.getTsample_sysuid()).compareTo(new Integer(tsample2.getTsample_sysuid()));
			} else if (sortColumn.equals("tsample_id")) {
				compare = tsample1.getTsample_id().compareTo(tsample2.getTsample_id());
			} else if (sortColumn.equals("tsample_taxid")) {
				compare = new Integer(tsample1.getTsample_taxid()).compareTo(new Integer(tsample2.getTsample_taxid()));
			} else if (sortColumn.equals("tsample_cell_provider")) {
				compare = tsample1.getTsample_cell_provider().compareTo(tsample2.getTsample_cell_provider());
			} else if (sortColumn.equals("tsample_sample_type")) {
				compare = new Integer(tsample1.getTsample_sample_type()).compareTo(new Integer(tsample2.getTsample_sample_type()));
			} else if (sortColumn.equals("tsample_dev_stage")) {
				compare = new Integer(tsample1.getTsample_dev_stage()).compareTo(new Integer(tsample2.getTsample_dev_stage()));
			} else if (sortColumn.equals("tsample_age_status")) {
				compare = new Integer(tsample1.getTsample_age_status()).compareTo(new Integer(tsample2.getTsample_age_status()));
			} else if (sortColumn.equals("tsample_agerange_min")) {
				compare = new Double(tsample1.getTsample_agerange_min()).compareTo(new Double(tsample2.getTsample_agerange_min()));
			} else if (sortColumn.equals("tsample_agerange_max")) {
				compare = new Double(tsample1.getTsample_agerange_max()).compareTo(new Double(tsample2.getTsample_agerange_max()));
			} else if (sortColumn.equals("tsample_time_unit")) {
				compare = new Integer(tsample1.getTsample_time_unit()).compareTo(new Integer(tsample2.getTsample_time_unit()));
			} else if (sortColumn.equals("tsample_time_point")) {
				compare = new Integer(tsample1.getTsample_time_point()).compareTo(new Integer(tsample2.getTsample_time_point()));
			} else if (sortColumn.equals("tsample_organism_part")) {
				compare = new Integer(tsample1.getTsample_organism_part()).compareTo(new Integer(tsample2.getTsample_organism_part()));
			} else if (sortColumn.equals("tsample_sex")) {
				compare = new Integer(tsample1.getTsample_sex()).compareTo(new Integer(tsample2.getTsample_sex()));
			} else if (sortColumn.equals("tsample_genetic_variation")) {
				compare = new Integer(tsample1.getTsample_genetic_variation()).compareTo(new Integer(tsample2.getTsample_genetic_variation()));
			} else if (sortColumn.equals("tsample_individual")) {
				compare = tsample1.getTsample_individual().compareTo(tsample2.getTsample_individual());
			} else if (sortColumn.equals("tsample_individual_gen")) {
				compare = tsample1.getTsample_individual_gen().compareTo(tsample2.getTsample_individual_gen());
			} else if (sortColumn.equals("tsample_disease_state")) {
				compare = tsample1.getTsample_disease_state().compareTo(tsample2.getTsample_disease_state());
			} else if (sortColumn.equals("tsample_target_cell_type")) {
				compare = tsample1.getTsample_target_cell_type().compareTo(tsample2.getTsample_target_cell_type());
			} else if (sortColumn.equals("tsample_cell_line")) {
				compare = tsample1.getTsample_cell_line().compareTo(tsample2.getTsample_cell_line());
			} else if (sortColumn.equals("tsample_strain")) {
				compare = tsample1.getTsample_strain().compareTo(tsample2.getTsample_strain());
			} else if (sortColumn.equals("tsample_additional")) {
				compare = tsample1.getTsample_additional().compareTo(tsample2.getTsample_additional());
			} else if (sortColumn.equals("tsample_separation_tech")) {
				compare = new Integer(tsample1.getTsample_separation_tech()).compareTo(new Integer(tsample2.getTsample_separation_tech()));
			} else if (sortColumn.equals("tsample_protocolid")) {
				compare = new Integer(tsample1.getTsample_protocolid()).compareTo(new Integer(tsample2.getTsample_protocolid()));
			} else if (sortColumn.equals("tsample_growth_protocolid")) {
				compare = new Integer(tsample1.getTsample_growth_protocolid()).compareTo(new Integer(tsample2.getTsample_growth_protocolid()));
			} else if (sortColumn.equals("tsample_exprid")) {
				compare = new Integer(tsample1.getTsample_exprid()).compareTo(new Integer(tsample2.getTsample_exprid()));
			} else if (sortColumn.equals("tsample_del_status")) {
				compare = tsample1.getTsample_del_status().compareTo(tsample2.getTsample_del_status());
			} else if (sortColumn.equals("tsample_user")) {
				compare = tsample1.getTsample_user().compareTo(tsample2.getTsample_user());
			} else if (sortColumn.equals("tsample_last_change")) {
				compare = tsample1.getTsample_last_change().compareTo(tsample2.getTsample_last_change());
			}
			return compare;
		}
	}

	public Tsample[] sortTsample (Tsample[] myTsample, String sortColumn, String sortOrder) {
		setSortColumn(sortColumn);
		setSortOrder(sortOrder);
		Arrays.sort(myTsample, new TsampleSortComparator());
		return myTsample;
	}


	/**
	 * Converts Tsample object to a String.
	 */
	public String toString() {
		return "This Tsample has tsample_sysuid = " + tsample_sysuid;
	}

	/**
	 * Prints Tsample object to the log.
	 */
	public void print() {
		log.debug(toString());
	}


	/**
	 * Determines equality of Tsample objects.
	 */
	public boolean equals(Object obj) {
		if (!(obj instanceof Tsample)) return false;
		return (this.tsample_sysuid == ((Tsample)obj).tsample_sysuid);

	}
}
