package edu.ucdenver.ccp.PhenoGen.tools.oe;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.List;

/**A private class used by IniFile*/
public class IniParagraph {
    
  //added by pratik bhavsar
  public List getSortedTags()
  {
  Enumeration chipEnum = getTags();
  
  ArrayList list=new ArrayList();
  
  while (chipEnum.hasMoreElements()) {
  			list.add((String)chipEnum.nextElement());
  		}
  
  Collections.sort(list);
  
  return list;
  }
  //---------------------->>>>>>>>>>>>>>>>>>>>>>>>
  
    private String paragraph_name;
    private InputFile f;
    private Hashtable tags;
    private String line;
    private boolean error_flag;
    private boolean eof;
    private int index = -1;
    //----------------------------------
    public IniParagraph(InputFile fl) {
        f = fl;
        eof = false;
        String s = getNextLine();
        read_to_nextparagraph(s);
    }
    //----------------------------------
    public Enumeration getTags() {
        return tags.keys();
    }
    public Hashtable getHash() {
        return tags;
    }
    //----------------------------------
    public void setValue(String tag, String value) {
        tags.put(tag.toLowerCase(), value);  //may replace old value
        Enumeration e = tags.elements();
    }
    //----------------------------------
    private void read_to_nextparagraph(String s) {
        error_flag = false;
        tags = new Hashtable();

        //The while loop looks for [paragraph] line.
        while ((s != null) && (! s.startsWith("[")))
            s = getNextLine();

        //remove brackets
        if (s != null) {
            s = s.substring(1); //all but first char
            int i = s.indexOf("]");
            if (i > 0) {
                s = s.substring(0, i);
                store_paragraph(s);
            } else {
                error_flag = true;
            }
        } else {
            eof = true;
            error_flag = false;
        }
    }
    //----------------------------------
    public String getName() {
        return paragraph_name.toLowerCase();
    }
    //----------------------------------
    public String tagValue(String tagname) {
        String ans;

        ans = (String)tags.get(tagname.toLowerCase());
        if (ans == null)
            return "";
        else
            return ans;
    }
    //----------------------------------
    private void store_paragraph(String s) {
        String next;
        IniElement ini;
        paragraph_name = s;
        next = getNextLine();
        while ((next != null) && (! next.startsWith("["))) {
            //Added by Purvesh to allow commenting of the
            //config file. Original code does not permit the comments.
            if(next.startsWith("#"))//skip the lines beginning with #.
            {
              next = getNextLine();
              continue;
            }
            ini = new IniElement(next);
            if (! ini.error()) {
               //I do not want to print the properties.
               //System.out.println(ini.tagName ()+" "+ini.valueName ());

                //put the property read in the hash table.
                tags.put(ini.tagName(), ini.valueName());
            }
            next = getNextLine();
        }
        if (tags.size()>0)
            error_flag = false;
    }
    //----------------------------------
    public IniParagraph(InputFile fl, String pname) {
        f = fl;
        read_to_nextparagraph(pname);
    }
    //----------------------------------
    public IniParagraph(String pname)  {
        //call this constructor to create a new paragraph
        tags = new Hashtable();
        paragraph_name = pname;
    }
    //----------------------------------
    private String getNextLine() {
        line = f.readLine();
        while ((line != null) && (line.length() <1))
            line = f.readLine();
        if (line == null)
            error_flag = true;
        else
            line = line.trim();
        return line;
    }
    //----------------------------------
    public boolean error() {
        return error_flag;
    }
    //----------------------------------
    public String nextLine() {
        return line;
    }
}

