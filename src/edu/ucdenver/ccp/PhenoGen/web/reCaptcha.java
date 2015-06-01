package edu.ucdenver.ccp.PhenoGen.web;
/*
*    Implementation of method to submit an HTTP POST to Google to check reCaptcha verification
*    Spencer Mahaffey
*    5/22/2015
*/
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.HttpEntity;
import org.apache.http.util.EntityUtils;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.log4j.Logger;


public class reCaptcha {
    private Logger log=null;
    
    public reCaptcha(){
        log = Logger.getRootLogger();
    }
    
    public boolean checkResponse(String secret,String gResponse, String requestIPAddr){
        boolean verified=false;
        CloseableHttpClient httpclient = HttpClients.createDefault();
        try{
            HttpPost httppost = new HttpPost("https://www.google.com/recaptcha/api/siteverify");
            httppost.removeHeaders("Accept-Encoding");
            httppost.setHeader("Accept-Encoding", "");
            // Request parameters and other properties.
            List<NameValuePair> params = new ArrayList<NameValuePair>(3);
            params.add(new BasicNameValuePair("secret", secret));
            params.add(new BasicNameValuePair("response", gResponse));
            params.add(new BasicNameValuePair("remoteip", requestIPAddr));
            httppost.setEntity(new UrlEncodedFormEntity(params, "UTF-8"));

            //Execute and get the response.
            CloseableHttpResponse response = httpclient.execute(httppost);
            HttpEntity entity = response.getEntity();
            String jsonResult="None";
            if (entity != null) {
                //long len = entity.getContentLength();
                //if (len != -1 && len < 8192) {
                    jsonResult=EntityUtils.toString(entity);
                    log.debug(jsonResult);
                /*} else {
                    // Stream content out
                    log.debug("entity len="+len);
                }*/
                //InputStream instream = entity.getContent();
//                try {
//                    if
////                    byte[] b=new byte[256];
////                    Date start=new Date();
////                    // do something useful
////                    while(instream.available()==0){
////                        Date now=new Date();
////                        if(now.getTime()-start.getTime()>15000){
////                            break;
////                        }
////                    }
//                    while(instream.available()>0){
//                        sb.append(EntityUtils.toString(entity))
//                        /*int read=instream.read(b);
//                        String tmp="";
//                        if(read>0){
//                            tmp=new String(b,0,read);
//                            sb.append(tmp);
//                        }*/
//                    }
//                } finally {
//                    instream.close();
//                }
                
                log.debug("jsonResult:\n"+jsonResult);
                if(jsonResult.indexOf("\"success\":")>-1){
                    int start=jsonResult.indexOf("\"success\":")+10;
                    int end=jsonResult.indexOf(",",start);
                    String valid="";
                    if(end==-1){
                        valid=jsonResult.substring(start);
                    }else{
                        valid=jsonResult.substring(start,end);
                    }
                    if(valid.toLowerCase().contains("true")){
                        verified=true;
                    }
                }
            }
            else{
                log.debug("null HttpResponse.Entity");
            }
        }catch(Exception e){
            log.error("Error POST to verify reCaptcha\n",e);
        }
        return verified;
    }
}
