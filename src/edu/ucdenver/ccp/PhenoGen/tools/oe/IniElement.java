package edu.ucdenver.ccp.PhenoGen.tools.oe;

/**A private class used by IniFile*/

public class IniElement {
    private String tag, val;
    private boolean error_flag;

//parses one element of an ini-file
//into a tag and a value

    public IniElement(String s)  {
        error_flag = false;
        int i = s.indexOf("=");
        if (i >0) {
            tag = s.substring(0, i).trim().toLowerCase();
            val = s.substring(i + 1);
        } else
            error_flag = true;
    }
    public boolean error() {
        return error_flag;
    }
    public String tagName(){
        return tag;
    }
    public String valueName() {
        return val;
    }
}    

