package edu.ucdenver.ccp.PhenoGen.tools.oe;

import java.io.File;
import java.io.IOException;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Set;

/** 
	* This class handles Windows ini-files. 
	* <br> They should be of the form:
	* <br><pre>
[paragraphname]
key1=value1
key2=value2
[another_paragraphname]
keyx = vals
tag=foo
etc.
it will, however, work on any platform

</pre>
	* <br> Todo:
	*/

public class IniFile {
    private String filename, path, fullpath;
    private Hashtable paragraphs;
    private IniParagraph para;
    private InputFile f;
//-----------------------------------------------------
    /**Opens an existing IniFile
    If it does not exist, an empty one is created and opened
    @param pathname
    @param fname , usually xxx.ini
    */
    public IniFile (String pathname, String fname) throws IOException {
        filename = fname;
        path = pathname;
        if (path.length()==0)
            fullpath= filename;
        else
            fullpath = path +File.separator + filename;
        checkFile(fullpath);
        f = new InputFile(fullpath);
        getParagraphs();
    }
    //-----------------------------------------------------
    private void checkFile(String fname) throws IOException {
        
        File fl = new File(fname);
        if(! fl.exists ()) {
            OutputFile outf = new OutputFile(fname);
            outf.close ();
        }
    }
    //-----------------------------------------------------
    /**Opens an ini file in the current directory
    @param fname , usually xxx.ini
    */
    public IniFile(String fname) throws IOException {
        filename = fname;
        path ="";
        fullpath = filename;
        checkFile(fullpath);
        f = new InputFile(filename);
        getParagraphs();
    }
    
    //-----------------------------------------------------    
    private synchronized void getParagraphs() {
        paragraphs = new Hashtable(10);        //make room for object table
        if (! f.checkErr()) {
            para = new IniParagraph(f); 

            if (! para.error()) {
                paragraphs.put (para.getName (), para);
                while ((para.nextLine()!=null)&&(para.nextLine().length() > 0)) {
                    para = new IniParagraph(f, para.nextLine());
                    paragraphs.put(para.getName (), para);
                }
            }
            f.close();
        }
    }
    //----------------------------------------------------
    /**Returns an iniParagraph instance for the given paraName.
     * @param paraName
     * @return An iniParagraph reference, if paraName is found, else null. 
     */
    public IniParagraph getParagraph(String paraName)
    {
      return (IniParagraph) paragraphs.get(paraName);
    }
    
    //----------------------------------------------------
    /**Returns a set of all paragraph names.
     * @return java.util.Set containing all paragraph sections.
     */
    public Set getParagraphNames()
    {
      return paragraphs.entrySet();
    }
    
    //----------------------------------------------------
    private synchronized void putParagraphs() throws IOException {
        OutputFile f = new OutputFile(fullpath);
        Enumeration nextone = paragraphs.elements ();
        while(nextone.hasMoreElements ())   {
            IniParagraph p = (IniParagraph)nextone.nextElement ();
            f.println("["+ p.getName() + "]");


            Enumeration e = p.getTags();
            while (e.hasMoreElements()) {
                String tag = (String)e.nextElement();
                f.println(tag.toLowerCase()+"="+p.tagValue(tag));
            }
        }
        f.close();
    }
    //-----------------------------------------------------
    /**Gets a profile string from an ini file
    @param para -  paragraph name in any case
    @param entry - name of entry in any case
    @return String value of this entry
    */
    public String getProfile(String para, String entry) {
        IniParagraph ini = null;
        int i =0;
        boolean found = false;
        ini = (IniParagraph)paragraphs.get (para.toLowerCase ());
        if (ini != null)  //now look for entry in that paragraph  
            return ini.tagValue(entry).trim();
        else
            return "";
    }
    //-----------------------------------------------------
    /**Gets a profile string from an ini file 
    returns default value if no such entry exists
     @param para -  paragraph name in any case pattern
     @param entry - name of entry in any case pattern
     @param defalt - default value for parameter
     @return String value of this entry
     */

    public String getProfile(String para, String entry, String defalt) {
        String value = getProfile(para, entry);
        if (value.length()<1)
            value = defalt;
        return value.trim();   
    }
    //-----------------------------------------------------
    /**Puts a profile entry into the ini file
    @param para -paragraph name
    @param tag - name of entry
    @param value - value of entry
    */
    public void putProfile(String para, String tag, String value) throws IOException {
        int i = 0;
        boolean found =false;
        IniParagraph p = null;
        // joal: changed name from 'enum' to 'nextone'
        Enumeration nextone = paragraphs.elements ();
        while (nextone.hasMoreElements () && ! found) {
            p =(IniParagraph)nextone.nextElement ();
            found =(para.equalsIgnoreCase( p.getName()));
        }
        if (found) {
            p.setValue(tag, value);   
        } else {
            p = new IniParagraph(para);
            paragraphs.put (p.getName (), p);
            p.setValue(tag.toLowerCase(), value);
        }
        putParagraphs();    //rewrite entire ini-file
    }
}    
