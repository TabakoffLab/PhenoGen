<%--
 *  Author: Aris Tan
 *  Created: Aug, 2010
 *  Description:  This jsp will save the resulting page from clusterImages.jsp in a pdf.
 *  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ page language="java" 
import="com.itextpdf.text.pdf.*"
import="com.itextpdf.text.Document"
import="com.itextpdf.text.Paragraph"
import="com.itextpdf.text.Chunk"
import="com.itextpdf.text.Font"
import="com.itextpdf.text.BaseColor"
import="com.itextpdf.text.Paragraph"
import="com.itextpdf.text.Image"
import="com.itextpdf.text.Font.FontFamily"
import="com.itextpdf.text.Element"

import="edu.ucdenver.ccp.util.sql.Results"

import="java.io.*"
import="java.util.Date"
%>

<jsp:useBean id="myFileHandler" class="edu.ucdenver.ccp.util.FileHandler"/>
<%
    Document document = new Document();
    String filename = (String)request.getParameter("filename") + "ClusterResults";
    response.setContentType("application/pdf");
	response.setHeader("Content-Disposition", "attachment; filename=\""+filename+".pdf\"");
	
	
    PdfWriter.getInstance(document, response.getOutputStream());
    out.clear();
	out = pageContext.pushBody(); 
    document.open();


    String imagesPathFileName = (String) session.getAttribute("imagesPathFileName");
	String analysisPath = (String) session.getAttribute("analysisPath");
	String imageFileNames = (String) session.getAttribute("imageFileNames");
	
	
	Image image = Image.getInstance(imagesPathFileName);
	image.scaleToFit(550f, 550f);
	document.add(image);
	
	if (imageFileNames.equals("Dendogram.png")) {
			
	    Paragraph note = new Paragraph("Note:  The red boxes indicate the most distinct clusters based on the '# of clusters to report' option. "+ "\n\n\n", new
                                            Font(FontFamily.HELVETICA, 10) );
        document.add(note);
	
	}
	
	    PdfPTable table = new PdfPTable(2);
		
		
		PdfPCell cell = 
			new PdfPCell();
		//cell.setColspan(2);
		//cell.setBackgroundColor(BaseColor.BLUE);
		
		if ((imageFileNames.equals("Heatmap.png") || 
		imageFileNames.equals("Dendogram.png")) && new File(analysisPath + "SampleTable.txt").exists()) {
		    Paragraph keys = new Paragraph("Key to Sample Names "+ "\n\n\n", new
                                            Font(FontFamily.HELVETICA, 10) );
			
			keys.setAlignment(Element.ALIGN_CENTER);

            document.add(keys);
			table.addCell("Sample ID");
       		table.addCell("Sample Name");
			
			String [] fileContents = myFileHandler.getFileContents(new File(analysisPath + "SampleTable.txt"));
			for (int i=0; i<fileContents.length; i++) {
				String[] columns = fileContents[i].split("[\\s]");
				
				table.getDefaultCell().setGrayFill((i % 2 == 0) ? 1f : 0.75f); 
				
				table.addCell(columns[0]);
		        table.addCell(columns[1]);
			
				
			}
			
			
		}
		document.add(table);	
		
		PdfPTable clusterTable = new PdfPTable(2);
		
		if ((imageFileNames.equals("Heatmap.png") || 
		     imageFileNames.equals("Dendogram.png")) && new File(analysisPath + "GeneTable.txt").exists()) {
			 
			 
		    Paragraph keys = new Paragraph("\n\n\n" + "Key to Probe Names "+ "\n\n\n", new
                                            Font(FontFamily.HELVETICA, 10) );
											
			keys.setAlignment(Element.ALIGN_CENTER);
            document.add(keys);
		

			clusterTable.addCell("Probe Number");
       		clusterTable.addCell("Probe Name");
			
			
			
			String [] fileContents = myFileHandler.getFileContents(new File(analysisPath + "GeneTable.txt"));
			for (int i=0; i<fileContents.length; i++) {
				String[] columns = fileContents[i].split("[\\s]");
				
				clusterTable.getDefaultCell().setGrayFill((i % 2 == 0) ? 1f : 0.75f); 
				
				clusterTable.addCell(columns[0]);
		        clusterTable.addCell(columns[1]);
			
				
			}
		}

		
		document.add(clusterTable);		
		
		////
		
		

         if (imageFileNames.startsWith("Cluster") && new File(analysisPath + "SampleTable.txt").exists()) {
		    Paragraph keys = new Paragraph("Key to Sample Names "+ "\n\n\n", new
                                            Font(FontFamily.HELVETICA, 10) );
											
			keys.setAlignment(Element.ALIGN_CENTER);
            document.add(keys);
			clusterTable.addCell("Sample ID");
       		clusterTable.addCell("Sample Name");
			
			String [] fileContents = myFileHandler.getFileContents(new File(analysisPath + "SampleTable.txt"));
			for (int i=0; i<fileContents.length; i++) {
				String[] columns = fileContents[i].split("[\\s]");
				
				clusterTable.getDefaultCell().setGrayFill((i % 2 == 0) ? 1f : 0.75f); 
				
				clusterTable.addCell(columns[0]);
		        clusterTable.addCell(columns[1]);
			
				
			}
			document.add(clusterTable);	
			
		}
		
		if (imageFileNames.startsWith("Cluster") && new File(analysisPath + "GeneTable.txt").exists()) {
		    Paragraph keys = new Paragraph("Key to Probe Names "+ "\n\n\n", new
                                            Font(FontFamily.HELVETICA, 10) );
											
			keys.setAlignment(Element.ALIGN_CENTER);
            document.add(keys);
		
        
			clusterTable.addCell("Probe Number");
       		clusterTable.addCell("Probe Name");
			
			
			
			String [] fileContents = myFileHandler.getFileContents(new File(analysisPath + "GeneTable.txt"));
			for (int i=0; i<fileContents.length; i++) {
				String[] columns = fileContents[i].split("[\\s]");
				
				clusterTable.getDefaultCell().setGrayFill((i % 2 == 0) ? 1f : 0.75f); 
				
				clusterTable.addCell(columns[0]);
		        clusterTable.addCell(columns[1]);
			
				
			}
			document.add(clusterTable);	
		}
		
		

	
document.close();


%>