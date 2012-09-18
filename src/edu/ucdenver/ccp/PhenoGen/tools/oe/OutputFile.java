package edu.ucdenver.ccp.PhenoGen.tools.oe;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

//Output file class
public class OutputFile {
    private BufferedWriter f;
    private PrintWriter p;
    private boolean errflag;
    private int tabcolumn;
    private int width;
//-----------------------------------
    /**Create output file
    @param filename complete path and name of file
    */
    public OutputFile(String filename) throws IOException {
        errflag = false;
        tabcolumn = 0;
        width = 0;
        filename = filename.trim();
        System.out.println(filename);
        f= new BufferedWriter(new FileWriter(filename));
        p = new PrintWriter(f);
    }
//-----------------------------------
    /**insert a tab into thee file*/
    public void tab() {
        p.print("\t");
    }
//-----------------------------------
    /**insert spaces into the file
    @param n the number of spaces to insert
    */
    public String space(int n) {
        StringBuffer sb = new StringBuffer(n);
        //put spaces into string buffer
        for (int i=0; i < n; i++) {
            sb.insert(i, ' ');
        }
        return sb.toString();
    }
//-----------------------------------
/**tab over to column
@param tb the column to tab over to
Inserts spaces to move up to tab column or starts a new line
*/    
    public void tab(int tb) {
        if (tb > tabcolumn) {
            print(space(tb - tabcolumn));
        } else
            println("");
    }
//-----------------------------------
    public void println(String s) {
        p.println(s);
        tabcolumn = 0;
    }
//-----------------------------------
    public void println(int i) {
        p.println(i);
        tabcolumn = 0;
    }
//-----------------------------------
    public void println(double d) {
        tabcolumn = 0;
        p.println(d);
    }
//-----------------------------------
    public void print(String s) {
        p.print(s);
        tabcolumn += s.length();
    }
//-----------------------------------
    public void print(int i) {
        String s=new Integer(i).toString();
        if (s.length() < width)
            print(space(width-s.length()) );
        print(s);
    }
//-----------------------------------
    public void print(float f) {
        String s=new Float(f).toString();
        print(s);
    }
//-----------------------------------
    public void print(double d) {
        String s=new Double(d).toString();
        print(s);
    }
//-----------------------------------
    public void close() {
        p.close();
    }
//-----------------------------------
    public void finalize() {
        close();
    }
//-----------------------------------
}
