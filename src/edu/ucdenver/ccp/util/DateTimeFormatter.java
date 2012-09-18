package edu.ucdenver.ccp.util;

import java.io.IOException;
import java.util.Date;
import java.util.GregorianCalendar;




public class DateTimeFormatter {

   public static String getFormattedDate(Date d,String sep){
       String ret="";
       GregorianCalendar gc=new GregorianCalendar();
       gc.setTime(d);
       int m=gc.get(GregorianCalendar.MONTH)+1;
       if(m<=9){
           ret="0"+m;
       }else{
           ret=Integer.toString(m);
       }
       ret=addSep(ret,sep);
       int day=gc.get(GregorianCalendar.DAY_OF_MONTH);
       if(day<=9){
           ret=ret+"0"+day;
       }else{
           ret=ret+day;
       }
       ret=addSep(ret,sep);
       int y=gc.get(GregorianCalendar.YEAR);
       ret=ret+y;
       return ret;
   }
   
   public static String getFormattedTime(Date d, String sep,boolean hr24){
       String ret="";
       GregorianCalendar gc=new GregorianCalendar();
       gc.setTime(d);
       int h=0;
       if(hr24){
               h=gc.get(GregorianCalendar.HOUR_OF_DAY);
       }else{
           h=gc.get(GregorianCalendar.HOUR);
       }
       if(h<=9){
           ret="0"+h;
       }else{
           ret=Integer.toString(h);
       }
       ret=addSep(ret,sep);
       int m=gc.get(GregorianCalendar.MINUTE);
       if(m<=9){
           ret=ret+"0"+m;
       }else{
           ret=ret+m;
       }
       ret=addSep(ret,sep);
       int s=gc.get(GregorianCalendar.SECOND);
       if(s<=9){
           ret=ret+"0"+s;
       }else{
            ret=ret+s;
       }
       return ret;
   }
   
   
   private static String addSep(String dateString, String sep){
       String ret=null;
       if(sep==null){
           ret=dateString;
       }else{
           ret=dateString+sep;
       }
       return dateString;
   }
    
    
}
