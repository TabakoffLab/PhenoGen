package edu.ucdenver.ccp.PhenoGen.web.mail;    

import java.io.IOException;
import java.io.PrintWriter;
import java.net.UnknownHostException;
import java.util.Properties;

import javax.mail.*;
import javax.mail.internet.*;
import javax.servlet.*;
import javax.servlet.http.*;

/* for logging messages */
import org.apache.log4j.Logger;

public class Email  {

	//defaults
	private final static String DEFAULT_CONTENT = "Unknown content";
	private final static String DEFAULT_SUBJECT= "Unknown subject";
	//private static String DEFAULT_SERVER = "mail.ucdenver.pvt";
	// This is one of the ip addresses for mail.ucdenver.pvt
	private static String DEFAULT_SERVER = "140.226.189.75";
	//private static String DEFAULT_SERVER = "kona.uchsc.edu";
	private static String DEFAULT_TO = null;
	private static String DEFAULT_FROM = "phenogen@ucdenver.edu";
	//private static String administratorEmail = "inia.help@uchsc.edu";
	//private static String ADMINISTRATOR_EMAIL = "Spencer.Mahaffey@ucdenver.edu";
	//private static String ADMINISTRATOR2_EMAIL = "Laura.Clemens@ucdenver.edu";
        private static String defaultAdmin="Spencer.Mahaffey@ucdenver.edu,Laura.Clemens@ucdenver.edu";
	private Logger log = null;


	//JavaBean properties
	private String smtpHost;
	private String to;
	private String from;
	private String content;
	private String subject;
 
	public Email() {
		log = Logger.getRootLogger();
	}
    
	public void sendEmail() throws MessagingException, SendFailedException {
     
		log.info("in Email.sendEmail");
		setSmtpHost("");
		setFrom("");
		Properties properties = System.getProperties();

		//populate the 'Properties' object with the mail
		//server address, so that the default 'Session'
		//instance can use it.
		//properties.put("mail.ucdenver.pvt", smtpHost);
		properties.put("mail.smtp.host", smtpHost);
		
		Session session = Session.getDefaultInstance(properties);
		Message mailMsg = new MimeMessage(session);//a new email message
		InternetAddress[] addresses = null;
		try {
			if (to != null) {
				//throws 'AddressException' if the 'to' email address
				//violates RFC822 syntax
				addresses = InternetAddress.parse(to, false);
				mailMsg.setRecipients(Message.RecipientType.TO, addresses);
			} else {
				log.debug("throwing new MessagingException about requiring a 'To' address"); 
				throw new MessagingException("The mail message requires a 'To' address.");
			}
			if (from != null) {
				mailMsg.setFrom(new InternetAddress(from));
			} else {
				log.debug("throwing new MessagingException about requiring a 'From' address"); 
				throw new MessagingException( "The mail message requires a valid 'From' address.");
			} 
			if (subject != null) {
				mailMsg.setSubject(subject);
			}
			if (content != null) {
				mailMsg.setText(content);
			}
        
			//Finally, send the mail message; throws a 'SendFailedException' 
			//if any of the message's recipients have an invalid address
			//log.debug("right before sending message");
			Transport.send(mailMsg);
			log.debug("right after sending message");
		} catch (MessagingException e) {
			log.error("MessagingException caught while sending message.  Here is the exception: ", e);
			if (e instanceof SendFailedException ) {  
				log.error("e is an instanceof SendFailedException");
				SendFailedException sfex =  (SendFailedException) e; 
				Address[] invalid = sfex.getInvalidAddresses(); 
				if (invalid != null) {
					log.error("No message sent to the following invalid addresses:");
					for (int i = 0; i<invalid.length; i++) {   
						log.error(" "+invalid[i]) ; 
					}  
				}  
				Address[] validUnsent = sfex.getValidUnsentAddresses(); 
				if (validUnsent != null) {
					log.error("No message sent to the following valid addresses:");
					for (int i = 0; i<validUnsent.length; i++) {   
						log.error(" "+validUnsent[i]) ; 
					}  
        			}  
				Address[] validSent = sfex.getValidSentAddresses(); 
				if (validSent != null) {
					log.error("Message sent to the following valid addresses:");
					for (int i = 0; i<validSent.length; i++) {   
						log.error(" "+validSent[i]) ; 
					}  
        			}  
			} else {
				log.error("e is NOT an instanceof SendFailedException");
			}
			log.error("the next exception is "+e.getNextException());
			boolean couldNotConnect = false;
			if (e.getNextException() instanceof MessagingException) {
				log.error("this next exception was an instance of MessagingException"); 
				MessagingException eChain = e;
				while (eChain instanceof MessagingException) {
					log.error("the next error in the chain is of type "+eChain.getNextException().getClass());
					if (eChain.getNextException() instanceof java.net.ConnectException) {
						log.error("this error is a connection error");
						couldNotConnect = true;
						break;
					} else if (eChain.getNextException() instanceof MessagingException) {
						log.error("since the next error is a MessagingException, then set eChain to it and go again");
						eChain = (MessagingException) eChain.getNextException();
                                	} else {
                                        	log.error("got a different type of exception.  It is " + eChain.getNextException().getClass());
                                        	break;

					}
				}
			} else if (e.getNextException() instanceof java.net.ConnectException) {
				log.error("this next exception was an instance of ConnectException"); 
				couldNotConnect = true;
			}
			log.error("here couldNotConnect = "+couldNotConnect);
			if (couldNotConnect) {
				log.error("there was a problem connecting to the email host.  Sleeping for 5 seconds and then trying again");
				try {
					Thread.sleep(5000);	
					this.sendEmail();
				} catch (InterruptedException ie) {
					log.error("Got an InterruptedException when sleeping while waiting to deliver an email", ie);
					this.sendEmailToAdministrator(defaultAdmin);
				}
			} else {
				log.error("there was something besides a connection error, so throwing the MessagingException", e);
				//throw new SendFailedException();
				throw e;
			}
		}
	}

	public void sendEmailToAdministrator(String adminEmail) throws MessagingException, SendFailedException {
		log.debug("in sendEmailToAdministrator");
                String[] adminEmails=null;
                if(adminEmail.length()>0){
                    adminEmails=adminEmail.split(",");
                }else{
                    adminEmails=this.defaultAdmin.split(",");
                }
                java.net.InetAddress localMachine =null;
                try{
                    localMachine = java.net.InetAddress.getLocalHost();
                }catch(UnknownHostException ex){
                    log.error("Unknown host exception while sending email.", ex);
                }
		this.content = "From Host:"+localMachine+"\nNOTE: This email was only sent to the administrator \n\n" +this.content;
                this.subject = localMachine+"::"+this.subject;
                for(int i=0;i<adminEmails.length;i++){
                    if(adminEmails[i].indexOf("@")>0){
                        this.to = adminEmails[i];
                        sendEmail();
                    }
                }
		log.debug("just sent email");
	}
    
	public void setSmtpHost(String host){
        	if (check(host)){
        		this.smtpHost = host;
        	} else {
    			this.smtpHost = Email.DEFAULT_SERVER;
        	}
	}
    
	public void setTo(String to){
        	if (check(to)){
       			this.to = to;
        	} else {
	    		this.to = Email.DEFAULT_TO;
        	}
	}
    
	public void setFrom(String from){
        	if (check(from)){
        		this.from = from;
        	} else {
    			this.from = Email.DEFAULT_FROM;
        	}
	}
    
	public void setContent(String content){
        	if (check(content)){
        		this.content = content;
        	} else {
    			this.content = Email.DEFAULT_CONTENT;
        	}
	}
    
	public void setSubject(String subject){
        	if (check(subject)){
        		this.subject = subject;
        	} else {
    			this.subject = Email.DEFAULT_SUBJECT;
        	}
	}
    
	private boolean check(String value){
        	if(value == null || value.equals("")) {
            		return false;
		}
		return true;
	}


	public static void main (String [] args) {
	}

}
