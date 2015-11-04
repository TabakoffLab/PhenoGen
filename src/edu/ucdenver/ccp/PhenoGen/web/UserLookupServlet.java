package edu.ucdenver.ccp.PhenoGen.web;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;

import javax.servlet.http.*;
import javax.servlet.*;

import org.apache.log4j.Logger;

import edu.ucdenver.ccp.PhenoGen.data.User;

public class UserLookupServlet extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Logger log = null;

	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
					
		Connection conn = (Connection)request.getSession().getAttribute("dbConn");
		
		log = Logger.getRootLogger();
		
		String piFirstName = FilterInput.getFilteredInput(request.getParameter("piFirstName"));
		String piLastName = FilterInput.getFilteredInput(request.getParameter("piLastName"));
		
		User user = new User();
				
		User userSearchResult = null;
		long number = 0;
		try {
			number = user.getNumberOfUsersWithNameMatch(piFirstName, piLastName,conn);
			userSearchResult = user.getUserWithNameMatch(piFirstName, piLastName,conn);
		} catch (SQLException e) {
			log.error("SQLException in UserLookupServlet " , e);
		}
		response.setContentType("text/xml");
		response.getWriter().write("<userData>");
		if (userSearchResult != null && number == 1) {
			response.getWriter().write(   "<userID>"     + userSearchResult.getUser_id()      + "</userID>");
			response.getWriter().write(   "<firstName>"  + userSearchResult.getFirst_name()   + "</firstName>");
			response.getWriter().write(   "<lastName>"   + userSearchResult.getLast_name()    + "</lastName>");			
		}
		
		if (userSearchResult == null ) {
			response.getWriter().write(   "<userID>"     + 0      + "</userID>");
		}
		
		if ( number > 1) {
			response.getWriter().write(   "<multipleMatches>true</multipleMatches>");
		}

		response.getWriter().write("</userData>");
		PrintWriter out = response.getWriter();

		out.flush();
		out.close();
		
	}

}

