/**
 * Title:        Onto-Express Web Site
 * Description:
 * Copyright:    Copyright (c) 2001
 * Company:      Wayne State University
 * @author Purvesh Khatri
 * @version 2.5
 */

package edu.ucdenver.ccp.PhenoGen.tools.oe;

import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.Enumeration;
import java.util.Properties;

public class HttpMessage
{
  URL servlet = null;
  String args = null;

  public HttpMessage(URL servlet) {
    this.servlet = servlet;
  }

  public InputStream sendGetMessage() throws IOException {
    return sendGetMessage(null);
  }

  public InputStream sendGetMessage(Properties args) throws IOException {
    String argString = "";
    if(args != null) {
      argString = "?" + toEncodedString(args);
    }
    URL url = new URL(servlet.toExternalForm() + argString);
    URLConnection con = url.openConnection();
    con.setUseCaches(false);
    return con.getInputStream();
  }

  public InputStream sendPostMessage() throws IOException {
    return sendPostMessage(null);
  }

  public InputStream sendPostMessage(Properties args) throws IOException {
    String argString = "";
    if(args != null) {
      argString = toEncodedString(args);
    }

    URLConnection con = servlet.openConnection();
    con.setDoInput(true);
    con.setDoOutput(true);
    con.setUseCaches(false);
    con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

    DataOutputStream out = new DataOutputStream(con.getOutputStream());
    out.writeBytes(argString);
    out.flush();
    out.close();

    return con.getInputStream();
  }

  public InputStream sendPostMessage(Serializable obj) throws IOException  {
    URLConnection con = servlet.openConnection();
    con.setDoInput(true);
    con.setDoOutput(true);
    con.setUseCaches(false);
    con.setRequestProperty("Content-Type", "java-internal/" + obj.getClass().getName());

    ObjectOutputStream out = new ObjectOutputStream(con.getOutputStream());
    out.writeObject(obj);
    out.flush();
    out.close();
    return con.getInputStream();
  }

  private String toEncodedString(Properties args) {
	StringBuffer buf = new StringBuffer();
	Enumeration names = args.propertyNames();
	while(names.hasMoreElements()) {
		String name = (String) names.nextElement();
		String value = args.getProperty(name);
		String unic = "UTF-8";
	
		try {
			buf.append(URLEncoder.encode(name, unic) + "=" + URLEncoder.encode(value, unic));
		}
		catch (Exception e) {
		}
		if(names.hasMoreElements()) {
			buf.append("&");
		}
	}
	return buf.toString();
  }
}

