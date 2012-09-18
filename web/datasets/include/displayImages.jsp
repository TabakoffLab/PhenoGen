<%--
 *  Author: Cheryl Hornbaker
 *  Created: Sep, 2008
 *  Description:  This file formats the within-array check graphic
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%
	//log.debug("in displayImages");

	for (int i=0; i<imageFileNames.length; i++) {
        	File imageFile = new File(imagesPath + imageFileNames[i]);
		//log.debug("imageFile = "+imageFile);
		//log.debug("relativePath + image name= "+relativePath+imageFileNames[i]);
		if (imageFile.exists()) {
			//log.debug("imageFileexists = ");
			%><img src="<%=request.getContextPath()%><%=relativePath%><%=imageFileNames[i]%>" height="<%=imageHeight%>" width="<%=imageWidth%>" alt="<%=imageFileNames[i]%>"><%
		}
	}
%>

