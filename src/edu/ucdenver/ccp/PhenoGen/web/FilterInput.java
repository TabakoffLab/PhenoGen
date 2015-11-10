// Spencer Mahaffey
// Oct, 2015
// Filter all user input prior to further processing

package edu.ucdenver.ccp.PhenoGen.web;



/* for logging messages */
import java.util.ArrayList;
import java.util.regex.Pattern;
import org.apache.log4j.Logger;

public class FilterInput {
  
  public static String getFilteredInput(String in){
      String out=in;
      ArrayList<String> list= new ArrayList<String>();
      list.add("CRLF");
      list.add("Script");
      list.add("SQL");
      list.add("Amp");
      list.add("Markup");
      list.add("URL");
      out=getFilteredInput(out,list,"");
      return out;
  }
  
  public static String getFilteredInputEmail(String in){
      String out=in;
      ArrayList<String> list= new ArrayList<String>();
      list.add("CRLF");
      list.add("Script");
      list.add("SQL");
      list.add("Amp");
      list.add("Markup");
      out=getFilteredInput(out,list,"");
      return out;
  }
  
  public static String getFilteredInput(String in,ArrayList<String> list,String host){
      String out=in;
      for(int i=0;i<list.size();i++){
          out=applyFilter(out,list.get(i),host);
      }
      return out;
  }
  
  /*
  * Removes crlf/scripts from url but allows urls
  */
  public static String getFilteredURLInput(String url){
      String out=url;
       ArrayList<String> list= new ArrayList<String>();
      list.add("CRLF");
      list.add("Script");
      list.add("SQL");
      list.add("Markup");
      out=getFilteredInput(out,list,"");
      return out;
  }
  

  /*
  * Removes crlf/scripts from url but allows urls
  */
  public static String getFilteredLocalURLInput(String url,String host){
      String out=url;
       ArrayList<String> list= new ArrayList<String>();
      list.add("CRLF");
      list.add("Script");
      list.add("SQL");
      list.add("Markup");
      list.add("localURL");
      out=getFilteredInput(out,list,host);
      return out;
  }
  
  
  public static String applyFilter(String in,String type,String host){
      String out=in;
      if(type.equals("CRLF")){
          out=filterCRLF(out);
      }else if(type.equals("Script")){
          out=filterScript(out);
      }else if(type.equals("SQL")){
          out=filterSQL(out);
      }else if(type.equals("Markup")){
          out=filterMarkup(out);
      }else if(type.equals("URL")){
          out=filterURL(out);
      }else if(type.equals("Amp")){
          out=filterAmpersand(out);
      }else if(type.equals("localURL")){
          out=filterLocalURL(out,host);
      }
      return out;
  }
  public static String filterCRLF(String in){
      String out=in;
      out=out.replaceAll("\r","");
      out=out.replaceAll("(?i)"+Pattern.quote("%0A"), "");
      out=out.replaceAll("\n", "");
      out=out.replaceAll("(?i)"+Pattern.quote("%0D"), "");
      return out;
  }
  public static String filterSQL(String in){
      String out=in;
      out=out.replaceAll("(?i)"+Pattern.quote("select"),"");
      out=out.replaceAll("(?i)"+Pattern.quote("from"),"");
      out=out.replaceAll("(?i)"+Pattern.quote("update"),"");
      out=out.replaceAll("(?i)"+Pattern.quote("insert"),"");
      out=out.replaceAll("(?i)"+Pattern.quote("delete"),"");
      out=out.replaceAll("(?i)"+Pattern.quote("join"),"");
      out=out.replaceAll("(?i)"+Pattern.quote("left"),"");
      out=out.replaceAll("(?i)"+Pattern.quote("right"),"");
      out=out.replaceAll("(?i)"+Pattern.quote("outer"),"");
      out=out.replaceAll("(?i)"+Pattern.quote("inner"),"");
      out=out.replaceAll("(?i)"+Pattern.quote("where"),"");
      return out;
  }
  public static String filterScript(String in){
      String out=in;
      out=out.replaceAll("(?i)<\\s*"+Pattern.quote("script")+"[\"a-z=\\s]*>","");
      out=out.replaceAll("(?i)</\\s*"+Pattern.quote("script")+"\\s*>","");
      out=out.replaceAll("(?i)"+Pattern.quote("var")+" [a-zA-Z]+","");
      return out;
  }
  public static String filterAmpersand(String in){
      String out=in;
      out=out.replaceAll(Pattern.quote("&"),"");
      out=out.replaceAll(Pattern.quote("%26"), "");
      return out;
  }
  /*public static String filterSemiColon(String in){
      String out=in;
      out=out.replaceAll(Pattern.quote(";"),"");
      out=out.replaceAll(Pattern.quote(""), "");
      return out;
  }*/
  public static String filterURL(String in){
      String out=in;
      out=out.replaceAll("(?i)(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})","");
      out=out.replaceAll("\n", "");
      return out;
  }
  public static String filterLocalURL(String in,String host){
      String out=in;
      if(out.contains("(?i)http")){
          if(out.toLowerCase().contains("http://"+host.toLowerCase()+"/") || out.toLowerCase().contains("https://"+host.toLowerCase()+"/")){
              // a local reference is fine
          }else{
              // a reference to another domain is not redirect to 404 error.
              out="/web/error/404.html";
          }
      }else{
          
      }
      return out;
  }
  public static String filterMarkup(String in){
      String out=in;
      out=out.replaceAll("\\<","");
      out=out.replaceAll("(?i)"+Pattern.quote("%3C"),"");
      out=out.replaceAll("\\>","");
      out=out.replaceAll("(?i)"+Pattern.quote("%3E"),"");
      return out;
  }
}
