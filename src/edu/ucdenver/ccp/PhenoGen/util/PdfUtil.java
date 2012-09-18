package edu.ucdenver.ccp.PhenoGen.util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.itextpdf.text.BadElementException;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.ExceptionConverter;
import com.itextpdf.text.Font;
import com.itextpdf.text.Font.FontFamily;
import com.itextpdf.text.Image;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.PdfTemplate;
import com.itextpdf.text.pdf.PdfWriter;

import edu.ucdenver.ccp.PhenoGen.data.Array;
import edu.ucdenver.ccp.PhenoGen.data.Dataset;
import edu.ucdenver.ccp.PhenoGen.data.LitSearch;
import edu.ucdenver.ccp.PhenoGen.data.User;
import edu.ucdenver.ccp.util.sql.Results;
import edu.ucdenver.ccp.util.FileHandler;

/* for logging messages */
import org.apache.log4j.Logger;

public class PdfUtil extends PdfPageEventHelper {

  	private Logger log=Logger.getRootLogger();
	
	public static final String PUBMED_URL = "http://view.ncbi.nlm.nih.gov/pubmed/";
	
	/** The PdfTemplate that contains the total number of pages. */
	protected PdfTemplate total;
 
	/** The font that will be used. */
	protected BaseFont helv;
 
	/**
	 * @see com.itextpdf.text.pdf.PdfPageEvent#onOpenDocument(com.itextpdf.text.pdf.PdfWriter,
	 *      com.itextpdf.text.Document)
	 */
	public void onOpenDocument(PdfWriter writer, Document document) {
		log.debug("in onOpenDocument");
		total = writer.getDirectContent().createTemplate(100, 100);
		total.setBoundingBox(new Rectangle(-20, -20, 100, 100));
		try {
			helv = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED);
		} catch (Exception e) {
			throw new ExceptionConverter(e);
		}
	}
 
	/**
	 * @see com.itextpdf.text.pdf.PdfPageEvent#onEndPage(com.itextpdf.text.pdf.PdfWriter,
	 *      com.itextpdf.text.Document)
	 */
	public void onEndPage(PdfWriter writer, Document document) {
		log.debug("in onEndPage");
		PdfContentByte cb = writer.getDirectContent();
		cb.saveState();
		String text = "Page " + writer.getPageNumber() + " of ";
		float textBase = document.bottom() - 20;
		float textSize = helv.getWidthPoint(text, 12);
		cb.beginText();
		cb.setFontAndSize(helv, 12);
		
		cb.setTextMatrix(document.left(), textBase);
		cb.showText(text);
		cb.endText();
		cb.addTemplate(total, document.left() + textSize, textBase);
		

		cb.restoreState();
	}
 
	/**
	 * @see com.itextpdf.text.pdf.PdfPageEvent#onCloseDocument(com.itextpdf.text.pdf.PdfWriter,
	 *      com.itextpdf.text.Document)
	 */
	public void onCloseDocument(PdfWriter writer, Document document) {
		log.debug("in onCloseDocument");
		total.beginText();
		total.setFontAndSize(helv, 12);
		total.setTextMatrix(0, 0);
		total.showText(String.valueOf(writer.getPageNumber() - 1));
		total.endText();
	}
 
	/**
	 * Generates the pdf using the data in request and response objects.
	 * 
	 * @param request the request object
	 * @param response the response object 
	 * @param allAbstracts a Results object containing the abstract text 
	 * @throws DocumentException 
	 * @throws IOException 
	 * @throws SQLException            
	 */
	public  void createReport(HttpServletRequest request, HttpServletResponse response, List<Results> allAbstracts ) throws DocumentException, IOException, SQLException{
		log.debug("in createReport");
				
        	LitSearch myLitSearch = new LitSearch();
		
		java.sql.Connection dbConn = (java.sql.Connection)request.getSession().getAttribute("dbConn");

		Object previousClobKey = null;
		Object[] dataRowWithClob = null;;
		
		String  category    = (String) ((String) request.getSession().getAttribute("category")==null?"":request.getSession().getAttribute("category"));
		
		String itemIDString = (String) request.getSession().getAttribute("itemID")==null?"-99":(String) request.getSession().getAttribute("itemID");
		int itemID = Integer.parseInt(itemIDString);
		
		String corefIDString = (String) request.getSession().getAttribute("corefID")==null?"-99": (String) request.getSession().getAttribute("corefID");
		int corefID = Integer.parseInt(corefIDString);
		
		String litSearchName = (String) request.getParameter("litSearchName");
		String geneListName = (String) request.getParameter("geneListName");
		String createDate = (String) request.getParameter("createDate");
		
		Document document = new Document();	
		PdfWriter writer = PdfWriter.getInstance(document, response.getOutputStream());
		writer.setPageEvent(new PdfUtil());
			
		document.open();
			
		Font linkFont = new Font();
		linkFont.setColor(BaseColor.BLUE);
		linkFont.setStyle(Font.UNDERLINE);		
		linkFont.setSize(10);

		String [] alternateIDs = null;
		String [] keywords = null;
		
			
		Paragraph header = new Paragraph(geneListName + " " + litSearchName + " " + createDate + "\n\n\n", new
		                                            Font(FontFamily.HELVETICA, 10) );
		document.add(header);
		for (Results result : allAbstracts) {    
			int rowNum = 1;
			while (rowNum <= result.getNumRows() && 
					(dataRowWithClob = result.getNextRowWithClobInBatches(rowNum, result.getNumRows(), 0)) != null) {

				if (previousClobKey == null || (previousClobKey != null && !dataRowWithClob[0].equals(previousClobKey))) {
			
					//
					// If this is not a co-reference link, then split the first value returned from the 
					// query into two values based on '|||'.  If it is a co-reference link, split the first
					// value returned into a set of values based on '+' as a delimiter.
					//	
					//
					// Split the first column returned into the gene id and the category
					//
					String [] keySplit  = ((String) dataRowWithClob[0]).split("[|]+");
						
					Paragraph p = new Paragraph(keySplit[0]+" " + keySplit[1], new
		        						Font(FontFamily.HELVETICA, 10, Font.BOLDITALIC, new BaseColor(0, 0, 255)) );
						
					document.add(p);

					if (corefID == -99) {
						//
						// Get all the alternateIDs for this gene_id, so they can be highlighted in the abstract
						//
						alternateIDs = myLitSearch.getAlternateIdentifiersUsedInLitSearch(
											keySplit[0], itemID, dbConn);
							
						keywords = myLitSearch.getKeywordsUsedInLitSearch(itemID, category, dbConn);

					} 
				} 
					
				for (int i=2; i<dataRowWithClob.length; i++) {
					if (i==3) {
						String newClobAsString = new Results().getClobAsString((Object) dataRowWithClob[3]);
						if (!newClobAsString.equals("")) {
							Paragraph p = new Paragraph(newClobAsString + "\n\n\n", new Font(FontFamily.HELVETICA, 10) );
							document.add(p);	
						} else {
							document.add(new Chunk("No Abstract"));						 
						}
					} else {
						String newTitle =(String)dataRowWithClob[2];
						document.add(new Paragraph());
						document.add(new Paragraph(
				                                	new Chunk(newTitle, linkFont)
				                                     	.setAnchor(PUBMED_URL+ dataRowWithClob[1])));
					}
				}
				previousClobKey = dataRowWithClob[0];
				rowNum++;
			}
		}
		document.close();
	}
	
	public void createPdfForImages(Dataset selectedDataset, HttpServletRequest request, String[] pseudoFiles, String[] maFiles) throws 
		DocumentException, MalformedURLException, IOException{

		log.debug("in createPdfForImages");
		
        	Document document = new Document();	
        	User userLoggedIn    = (User) request.getSession().getAttribute("userLoggedIn");
        	PdfWriter.getInstance(document, new FileOutputStream(selectedDataset.getDownloadsDir()+"/ImageFiles.pdf"));

        	document.open();
        
        	if (selectedDataset.getPlatform().equals(Dataset.AFFYMETRIX_PLATFORM) && maFiles !=null) {
            	document.add(new Paragraph("MA Plots"));	
             	List<Image> images = getMAPlotImages(selectedDataset, request, maFiles);
             		for (Image image : images) {
                   		document.add(image);
             		}
        	}
        
        	document.newPage();
        	document.newPage();
        
        	if (pseudoFiles != null) {
        		document.add(new Paragraph("Pseudo Images"));	
        		document.add(getPseudoImages(selectedDataset, request, pseudoFiles));
        	}

		document.close();
	}
	
	
	public List<Image> getMAPlotImages(Dataset selectedDataset, HttpServletRequest request,  String[] arrayNames) throws 
		BadElementException, MalformedURLException, IOException {
		log.debug("in getMAPlotImages");
		
		edu.ucdenver.ccp.PhenoGen.data.Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();
        	List<Image> images = new ArrayList<Image>();		
                String imagePath = new FileHandler().getPathFromUserFiles(selectedDataset.getImagesDir());
		log.debug("imagePath = " +imagePath);

        	for (String arrayName : arrayNames) {
			String[] imageFileNames = myArray.getAffyMaplotFileNames(arrayName);

            		for (String fileName : imageFileNames) {
                  		Image image = Image.getInstance(request.getScheme() + "://" +
								request.getServerName() + request.getContextPath() + 
								imagePath + 
								fileName);						
                  		image.scaleToFit(450f, 450f);
                  		images.add(image);
            		}
        	}
		return images;
	}
	
	public PdfPTable getPseudoImages(Dataset selectedDataset, HttpServletRequest request, String[] arrayNames) throws 
						BadElementException, MalformedURLException, IOException {

		edu.ucdenver.ccp.PhenoGen.data.Array myArray = new edu.ucdenver.ccp.PhenoGen.data.Array();

		log.debug("in getPseudoImages");
                String imagePath = new FileHandler().getPathFromUserFiles(selectedDataset.getImagesDir());
		log.debug("imagePath = " +imagePath);

        	String[] imageFileNames = null;
        	PdfPTable clusterTable =  null;
        
    		if (selectedDataset.getPlatform().equals(Dataset.AFFYMETRIX_PLATFORM)) {
			clusterTable  = new PdfPTable(5);
		} else if (selectedDataset.getPlatform().equals(Dataset.CODELINK_PLATFORM)) {
			clusterTable  = new PdfPTable(arrayNames.length);
		}

		for (String arrayName : arrayNames)  {
        		if (selectedDataset.getPlatform().equals(Dataset.AFFYMETRIX_PLATFORM)) {
				imageFileNames = myArray.getAffyImageFileNames(arrayName);
			} else if (selectedDataset.getPlatform().equals(Dataset.CODELINK_PLATFORM)) {
				imageFileNames = myArray.getCodeLinkImageFileNames(arrayName);
			}
			for (String fileName : imageFileNames) {
				Image image = Image.getInstance(request.getScheme() + "://" +
								request.getServerName() +
								request.getContextPath() +
								imagePath +
								fileName);
				clusterTable.addCell(setupCellAttributes(image));
			}
		}
		return clusterTable;
	}
    
	public PdfPCell setupCellAttributes(Image image) {
		log.debug("in setupCellAttributes");
		image.scaleToFit(90f, 90f);
		PdfPCell cell = new PdfPCell(image, false);
		cell.setBorderWidth(0.0f);
	    	return cell;
	}
}
