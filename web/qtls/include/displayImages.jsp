<%--
 *  Author: Cheryl Hornbaker
 *  Created: Oct, 2009
 *  Description:  This file displays the QTL images
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%
	String imagesPath = myFileHandler.getPathFromUserFiles(groupingUserPhenotypeDir);
	//log.debug("imagesPath = "+imagesPath);

	for (int i=0; i<imageFileNames.length; i++) {
        	File imageFile = new File(groupingUserPhenotypeDir + imageFileNames[i]);
		//log.debug("imageFile = "+imageFile);
		if (imageFile.exists()) {
			//log.debug("imageFile exists ");
			%><img src="<%=contextPath%><%=imagesPath%><%=imageFileNames[i]%>" height="<%=imageHeight%>" width="<%=imageWidth%>" alt="<%=imageFileNames[i]%>"><%
		} else {
			log.debug("imageFile does not exist");
		}
	}
%>

