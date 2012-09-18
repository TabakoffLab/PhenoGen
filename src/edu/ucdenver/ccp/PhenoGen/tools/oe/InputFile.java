package edu.ucdenver.ccp.PhenoGen.tools.oe;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

public class InputFile {
    private BufferedReader f = null;
    private boolean errflag;
    private String s = null;
    private String filename;

    public InputFile(String fname) throws IOException {
        errflag = false;

        //open file
        fname =fname.trim();
        f = new BufferedReader(new FileReader(fname));
        filename= fname;
    }
//-----------------------------------------
    public boolean checkErr() {
        return errflag;
    }
//-----------------------------------------
    public String read() {
//read a single field up to a comma or end of line
        String ret = "";
        if (s == null) {          //if no data in string
            s = readLine();      //read next line
        }
        if (s != null) {          //if there is data
            s.trim();              //trim off blanks
            int i = s.indexOf(",");  //find next comma
            if (i <= 0) {
                ret = s.trim();       //if no commas go to end of line
                s = null;             //and null out stored string
            } else {
                ret = s.substring(0, i).trim(); //return left of comma      
                s = s.substring(i+1); //save right of comma
            }
        } else
            ret = null;
        return ret;             //return string
    }
//-----------------------------------------
    public String readLine() {
        //read in a line from the file
        s = null;
        try {
            s = f.readLine();     //could throw error
        } catch (IOException e) {
            errflag = true;
            System.out.println("File read error");
        }
        return s;
    }
//-----------------------------------------
    public void close() {
        try {
            f.close();     //close file
        } catch (IOException e) {
            System.out.println("File close error");
            errflag = true;
        }
    }
//-----------------------------------------
    public String root() {
        int i = filename.lastIndexOf(File.separatorChar);
        String s =filename.substring(i+1);
        i = s.indexOf(".");
        return s.substring(0, i);
    }
}
