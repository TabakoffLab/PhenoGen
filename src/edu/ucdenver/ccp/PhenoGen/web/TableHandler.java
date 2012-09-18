package edu.ucdenver.ccp.PhenoGen.web;

/* for logging messages */
import org.apache.log4j.Logger;
import edu.ucdenver.ccp.util.sql.Results;
import edu.ucdenver.ccp.util.Debugger;
import java.util.LinkedHashMap;

/**
 * Class for defining HTML tables.
 *  <br> Authors:  Cheryl Hornbaker
 */

public class TableHandler{

	private Logger log=null;
	private Debugger myDebugger = new Debugger();
	private String linkText;
	public TableHandler() {
		log = Logger.getRootLogger();
	}
	public TableHandler(String formName) {
		log = Logger.getRootLogger();
		
		setLinkText("<a href=\"" + formName + 
			"?action=sort&amp;pageNum=PutPageNumberHere&amp;sortOrder=PutSortOrderHere&amp;sortColumn=PutSortColumnHere");
	}
	public TableHandler(String formName, int geneListID) {
		log = Logger.getRootLogger();
		
		setLinkText("<a href=\"" + formName + 
			"?geneListID="+geneListID+"&amp;action=sort&amp;pageNum=PutPageNumberHere&amp;sortOrder=PutSortOrderHere&amp;sortColumn=PutSortColumnHere");
	}

	public String getLinkText() {
		return linkText;
	}

	public void setLinkText(String inString) {
		this.linkText = inString;
	}

	public class Column{
		public Column() {
			log = Logger.getRootLogger();
		}
	}

	public class ColumnHeader{

		private String columnName;
		private String sortColumnName;
		private int width;
		private boolean sortable;
	
		public ColumnHeader() {
			log = Logger.getRootLogger();
		}

		public ColumnHeader(String columnName) {
			log = Logger.getRootLogger();
			setColumnName(columnName);
			setSortable(false);
		}

		public ColumnHeader(String columnName, int width) {
			log = Logger.getRootLogger();
			setColumnName(columnName);
			setWidth(width);
			setSortable(false);
		}

		public ColumnHeader(String columnName, String sortColumnName, int width) {
			log = Logger.getRootLogger();
			setColumnName(columnName);
			setSortColumnName(sortColumnName);
			setWidth(width);
			setSortable(true);
		}

		public String getColumnName() {
			return columnName;
		}

		public void setColumnName(String inString) {
			this.columnName = inString;
		}

		public String getSortColumnName() {
			return sortColumnName;
		}

		public void setSortColumnName(String inString) {
			this.sortColumnName = inString;
		}

		public int getWidth() {
			return width;
		}

		public void setWidth(int inInt) {
			this.width = inInt;
		}

		public boolean getSortable() {
			return sortable;
		}

		public void setSortable(boolean inBoolean) {
			this.sortable = inBoolean;
		}

	
	}
}
	

