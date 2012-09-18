package edu.ucdenver.ccp.PhenoGen.tools.location;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.util.LinkedHashSet;
import java.util.Iterator;
import java.text.NumberFormat;
import edu.ucdenver.ccp.PhenoGen.data.Organism;
import edu.ucdenver.ccp.PhenoGen.tools.idecoder.Identifier;

/* for logging messages */
import org.apache.log4j.Logger;
import edu.ucdenver.ccp.util.Debugger;

//450 380-----group 2 rows
//900 180-----group 1 row
//900 100-----horiz chrom

public class Chromosomes extends HttpServlet {

    private Logger log=Logger.getRootLogger();
    private Debugger myDebugger = new Debugger();
    public String color[]={"FFFFFF","000000","E8E8E8","C8C8C8", "F8F8F8", "D8D8D8", "B8B8B8"};

   private String colorn[]={"white","black","gray33","gray66", "gray25", "gray50", "gray75"};

   public void doGet(HttpServletRequest req,HttpServletResponse res) throws IOException {
	log.debug("in doGet of Chromosome.java");
	Color dgreen=new Color(0,128,0), textColor=new Color(0,0,0), scaleColor=new Color(120,120,120);
	String map;
	int i,j,max=0,min=0,numChromosomes=0,wi,space=20;

	//ncol is the number of columns to display.  If wide, then it's the total number of chromosomes
	int bandLower,bandUpper,bandColor=0,width,height,x0,x,y,ncol,wcol,px=300,chromToDisplay;
	String locationRng = req.getParameter("locator");

	LinkedHashSet<String> genesToDisplay = (LinkedHashSet<String>) req.getSession().getAttribute("genesToDisplay");
	LinkedHashSet<String> transToDisplay = (LinkedHashSet<String>) req.getSession().getAttribute("transToDisplay");
	LinkedHashSet<String> regionsToDisplay = (LinkedHashSet<String>) req.getSession().getAttribute("regionsToDisplay");
	Organism.Chromosome[] myChromosomes = (Organism.Chromosome[]) req.getSession().getAttribute("myChromosomes");
	String organismToDisplay = (String) req.getSession().getAttribute("organismToDisplay");
	log.debug(" organismToDisplay " + organismToDisplay);

	//log.debug("myChromosomes[0] = "); myDebugger.print(myChromosomes[0]);
	//log.debug("myChromosomes[21] = "); myDebugger.print(myChromosomes[21]);

      if ( locationRng != null && locationRng.length() > 0 ) {
          transToDisplay = null;
          genesToDisplay = null;
          regionsToDisplay = new LinkedHashSet<String>();

          regionsToDisplay.add( locationRng );
      }

      Color[] bandColors= new Color[color.length];

      double scale;
      int[] co=new int[3];

      width=450;
      height=380;
      ncol=11;

	//If wide is present, display chromosomes in one line, otherwise display in 2 rows
      String wide=req.getParameter("wide");
      String chroms=req.getParameter("chrom");
      chromToDisplay=(chroms!=null)?Integer.parseInt(chroms):0;

      String ws=req.getParameter("width");
      if(ws!=null) width=Integer.parseInt(ws);

      String hs=req.getParameter("height");
      if(hs!=null) height=Integer.parseInt(hs);

      String bps=req.getParameter("bp");

	if(bps!=null) {
		int n=bps.indexOf("-");
		min=Integer.parseInt(bps.substring(0,n));
		max=Integer.parseInt(bps.substring(n+1));
		space=0;
	} else {
		for (i=0; i<myChromosomes.length; i++) {
			if (myChromosomes[i].getLength() > max) max=myChromosomes[i].getLength();
		}
	}

	String horizontal=req.getParameter("horizontal");
	// imageMap is N if html image map is to be included. Otherwise it is Y
	String imageMap = (req.getParameter("imageMap") != null ? (String) req.getParameter("imageMap") : "N");

	////get drawing parameters

	numChromosomes = myChromosomes.length;

         if(wide!=null) {
            if(ws==null) width=900;
            if(hs==null) height=180;
            ncol=numChromosomes;
         }

         if(chromToDisplay>0) {
            if(ws==null) width=(horizontal!=null)?900:100;
            if(hs==null) height=(horizontal!=null)?150:600;
            ncol=1;
            numChromosomes=1;
         }

         wcol=(horizontal!=null&&chromToDisplay>0)?height:(int)(width/((double)ncol+0.5));
         wi=wcol/2;
         px=(horizontal!=null&&chromToDisplay>0)?width-space*2:(height-space*(2+(numChromosomes-1)/ncol))/(1+(numChromosomes-1)/ncol);

	//log.debug("here min = "+min + ", max = "+max + ", px="+px);

////draw chromosomes

      BufferedImage bufferedImage=new BufferedImage(width,height,BufferedImage.TYPE_INT_RGB);
      Graphics image=bufferedImage.getGraphics();
      if(imageMap.equals("N")) {
         image.setColor(new Color(220,255,220));
         image.fillRect(0,0,width,height);
      }

      for(i=0;i<color.length;i++) {
         getColor(color[i],co);
         bandColors[i]=new Color(co[0],co[1],co[2]);
      }

      int[] chromoHeight=new int[numChromosomes];
      for(i=0;i<numChromosomes;i++) chromoHeight[i]=0;

      x0=(horizontal!=null&&chromToDisplay>0)?wcol/4:wcol/2;

	//scale=(double)px/(double)(max);
	scale=(double)px/(double)(max-min);
	int startIndex = (chromToDisplay == 0 ? 0 : chromToDisplay - 1);
	int endIndex = (chromToDisplay == 0 ? myChromosomes.length : chromToDisplay);
	//log.debug("startIndex = "+startIndex); 
	//log.debug("endIndex = "+endIndex); 
	// this displays the scale on the left side
	//log.debug("px = "+px+", space="+space+", ncol="+ncol+", wcol=" + wcol + ", scale ="+scale);
	int scaleX = x0-15;
	int scaleTopHigh = 15; 
	int scaleTopZero = px + space;
	int scaleBottomHigh = px + space + space; 
	int scaleBottomZero = (horizontal!=null&&chromToDisplay>0) ?
			space :
			px+space+((chromToDisplay==0) ?
					(px+space) : 
					space);
	//log.debug("scaleTopZero = "+scaleTopZero+", scaleTopHigh="+scaleTopHigh + 
	//", scaleBottomZero="+scaleBottomZero+", scaleBottomHigh=" + scaleBottomHigh);

	NumberFormat nf = NumberFormat.getInstance();
	Font defaultFont = image.getFont();
	image.setColor(scaleColor);
	image.setFont(new Font("SansSerif",Font.PLAIN,9));
	if (chromToDisplay==0) {
		image.drawString(nf.format(max),scaleX,scaleTopHigh);
		image.drawString("0",scaleX,scaleTopZero);
		image.drawLine(scaleX+1,scaleTopHigh+2,scaleX+1,scaleTopZero-8);
	}
	/*
	if (wide==null) {
		//image.drawString(nf.format(myChromosomes[11].getLength()),scaleX,scaleBottomHigh);
		image.drawString("heightOfBottom",scaleX,scaleBottomHigh);
		image.drawString("0",scaleX,scaleBottomZero);
	}
	*/
	image.setFont(defaultFont);
	for (i=startIndex; i<endIndex; i++) {
		int thisChromo = myChromosomes[i].getDisplay_order() - 1;
		String chrLabel = myChromosomes[i].getName(); 
         	x=x0+((chromToDisplay==0)?wcol*(thisChromo%ncol):0);
		y=(horizontal!=null&&chromToDisplay>0) ?
			space :
			px+space+((chromToDisplay==0) ?
					(px+space)*(thisChromo/ncol) : 
					space);
		Organism.Cytoband[] myCytobands = myChromosomes[i].getCytobands(); 
		if (myCytobands != null && myCytobands.length > 0) {
			for (j=0; j<myCytobands.length; j++) {
                                String bandLabel = myCytobands[j].getLabel();
				int k;
            			for(k=0;k<colorn.length;k++) if(colorn[k].equals(myCytobands[j].getColor())) break;
				if(k<colorn.length) bandColor = k; 

				// first, chop off min (which will be > 0 if a range of base pairs is passed in) 
				// from the cytoband upper and lower
				// if the cytoband start is before the min bp to display (i.e., the difference is < 0)
				// then check the cytoband end.  If that's before the min bp, then skip this cytoband
				// Otherwise, this is the first cytoband to display, so set bandLower = 0;
				//

				bandLower = myCytobands[j].getBp_start(); 
				bandUpper = myCytobands[j].getBp_end(); 
				bandLower-=min;
				bandUpper-=min;
				if (bandLower < 0 ) {
					if (bandUpper < 0) continue;
					else bandLower = 0;
				}

            			bandLower=(int)((double)bandLower*scale);
            			bandUpper=(int)((double)bandUpper*scale);

				// if the cytoband end is after the total number of px 
				// then check the cytoband start.  If that's after the total number of px, skip this cytoband
				// Otherwise, this is the last cytoband to display, so set bandUpper = px;
				//
				if (bandUpper > px ) {
					if (bandLower > px) continue;
					else bandUpper = px;
				}
				//log.debug("bandLabel = "+bandLabel + ", bandColor = "+bandColor + ", lower = "+bandLower + ", upper = "+bandUpper);
				if(imageMap.equals("N")) {
					image.setColor(bandColors[bandColor]);
					if(horizontal!=null&&chromToDisplay>0) image.fillRect(y+bandLower,x,bandUpper-bandLower,wi);
					else image.fillRect(x,(chromToDisplay>0)?bandLower:y-bandUpper,wi,bandUpper-bandLower);
					image.setColor(textColor);
					if(chromToDisplay==0) image.drawString(""+chrLabel,x+5-((thisChromo>8)?2:0),y+13);
				} else {
					int chromoIndex= (chromToDisplay > 0) ? 0 : thisChromo;
					chromoHeight[chromoIndex]=(int)((double)myChromosomes[i].getLength()*scale);
					//if(bandUpper>chromoHeight[chromoIndex]) chromoHeight[chromoIndex]=bandUpper;
				}
			}
		} else {
			bandColor = 1;
			bandLower = min;
			bandUpper = (int)((double)myChromosomes[i].getLength()*scale);
			if(imageMap.equals("N")) {
				image.setColor(bandColors[bandColor]);
				if(horizontal!=null&&chromToDisplay>0) image.fillRect(y+bandLower,x,bandUpper-bandLower,wi);
				else image.fillRect(x,(chromToDisplay>0)?bandLower:y-bandUpper,wi,bandUpper-bandLower);
				image.setColor(textColor);
				if(chromToDisplay==0) image.drawString(""+chrLabel,x+5-((thisChromo>8)?2:0),y+13);
			} else {
				int chromoIndex= (chromToDisplay > 0) ? 0 : thisChromo;
				chromoHeight[chromoIndex]=(int)((double)myChromosomes[i].getLength()*scale);
				//if(bandUpper>chromoHeight[chromoIndex]) chromoHeight[chromoIndex]=bandUpper;
			}
		}
	}

////send mapping page

	if(imageMap.equals("Y")) {
		boolean drawPointersOnly = ( chromToDisplay > 0 && horizontal != null );

		res.setContentType("text/html");
		map = "<map name=\"chrom_map" + ( drawPointersOnly ? "_horizontal" : "" ) + "\">\n";

		if ( !drawPointersOnly ) {
			for(i=0;i<numChromosomes;i++) {
				x=x0+wcol*(i%ncol);
				y=px+space+(px+space)*(i/ncol);
				map+="<area shape=\"Rect\" coords=\""+x+","+(y-chromoHeight[i])+","+(x+wi)+","+y+"\"";
				map+=" href=\"javascript: top.select_chrom("+i+");\">\n";
			}
		}

		////draw marker hot areas here

		if (genesToDisplay != null) {
            		for (Iterator itr=genesToDisplay.iterator(); itr.hasNext();) {
				Identifier id = (Identifier) itr.next();
				String gene = id.getChromosomeMapGeneAnnotation();
				// Each string is something like: "Gnb1(Gnb1) -- 4|||154865479"
				String [] geneInfo=gene.split(" -- ");
				String [] locInfo =geneInfo[1].split("[|]+");
				for(i=0;i<myChromosomes.length;i++) {
					if (locInfo[0].equals(myChromosomes[i].getName())) break;
				}
				int whichChrom=i;
				if(chromToDisplay>0&&(whichChrom+1)!=chromToDisplay) continue;
				int xCoord=x0+((chromToDisplay==0)?wcol*(whichChrom%ncol):0);
				int yCoord=(horizontal!=null&&chromToDisplay>0)?space:px+space+((chromToDisplay==0)?(px+space)*(whichChrom/ncol):space);
				String bpLoc=locInfo[1];
				int numPx=(int)((Double.parseDouble(bpLoc)-min)*scale);
				if(horizontal!=null&&chromToDisplay>0) {
					map+=writeArea(gene,yCoord+numPx,xCoord-4,"genes",organismToDisplay);
				} else {
					map+=writeArea(gene,xCoord-4,(chromToDisplay > 0? numPx :yCoord-numPx),"genes",organismToDisplay);
				}
			}
		}
		if (transToDisplay != null) {
			for (Iterator itr=transToDisplay.iterator(); itr.hasNext();) {
				Identifier id = (Identifier) itr.next();
				String gene = id.getChromosomeMapTransAnnotation();
				//log.debug("in transToDisplay.  this GeneAnnotation = "+id.getChromosomeMapGeneAnnotation() + 
				//	"this TransAnnotation = " + id.getChromosomeMapTransAnnotation());
				// Each string is something like: "Gnb1(Gnb1) -- 4|||154865479, Gnb1(Gnb1) -- 9|||9403820"
				String [] eachTrans = gene.split(", ");
				for (int transIdx=0; transIdx<eachTrans.length; transIdx++) {
					//String [] geneInfo=gene.split(" -- ");
					String [] geneInfo=eachTrans[transIdx].split(" -- ");
					String [] locInfo =geneInfo[1].split("[|]+");
					for(i=0;i<myChromosomes.length;i++) {
						if (locInfo[0].equals(myChromosomes[i].getName())) break;
					}
					int whichChrom=i;
					if(chromToDisplay>0&&(whichChrom+1)!=chromToDisplay) continue;
					int xCoord=x0+((chromToDisplay==0)?wcol*(whichChrom%ncol):0);
					int yCoord=(horizontal!=null&&chromToDisplay>0)?space:px+space+((chromToDisplay==0)?(px+space)*(whichChrom/ncol):space);
					String bpLoc=locInfo[1];
					int numPx=(int)((Double.parseDouble(bpLoc)-min)*scale);
					if(horizontal!=null&&chromToDisplay>0) {
						map+=writeArea(eachTrans[transIdx],yCoord+numPx,xCoord+wi+4,"trans",organismToDisplay);
					} else {
						map+=writeArea(eachTrans[transIdx],xCoord+wi+4,(chromToDisplay > 0? numPx :yCoord-numPx),"trans",organismToDisplay);
					}
				}
			}
		}

         	map+="</map>\n";
         	PrintWriter out=res.getWriter();
         	out.print(map);
         	out.close();
         	return;
	}

	////draw markers

	if (genesToDisplay != null) {
		image.setColor(Color.red);
		for (Iterator itr=genesToDisplay.iterator(); itr.hasNext();) {
			Identifier id = (Identifier) itr.next();
			String gene = id.getChromosomeMapGeneAnnotation();
			// Each string is something like: "Gnb1(Gnb1) -- 4|||154865479"
			String [] geneInfo=gene.split(" -- ");
			String [] locInfo =geneInfo[1].split("[|]+");
			for(i=0;i<myChromosomes.length;i++) {
				if (locInfo[0].equals(myChromosomes[i].getName())) break;
			}
			int whichChrom=i;
			if(chromToDisplay>0&&(whichChrom+1)!=chromToDisplay) continue;
			int xCoord=x0+((chromToDisplay==0)?wcol*(whichChrom%ncol):0);
			int yCoord=(horizontal!=null&&chromToDisplay>0)?space:px+space+((chromToDisplay==0)?(px+space)*(whichChrom/ncol):space);
			String bpLoc=locInfo[1];
			int numPx=(int)((Double.parseDouble(bpLoc)-min)*scale);
			if(horizontal!=null&&chromToDisplay>0) {
				pointer(image,yCoord+numPx,xCoord-1,6,8,1);
			} else {
				pointer(image,xCoord-1,(chromToDisplay > 0? numPx :yCoord-numPx),-6,8,0);
			}
		}
	}
	if (transToDisplay != null) {
		image.setColor(dgreen);
		for (Iterator itr=transToDisplay.iterator(); itr.hasNext();) {
			Identifier id = (Identifier) itr.next();
			String gene = id.getChromosomeMapTransAnnotation();
			// Each string is something like: "Gnb1(Gnb1) -- 4|||154865479, Gnb1(Gnb1) -- 9|||9403820"
			String [] eachTrans = gene.split(", ");
			for (int transIdx=0; transIdx<eachTrans.length; transIdx++) {
				//String [] geneInfo=gene.split(" -- ");
				String [] geneInfo=eachTrans[transIdx].split(" -- ");
				String [] locInfo =geneInfo[1].split("[|]+");
				for(i=0;i<myChromosomes.length;i++) {
					if (locInfo[0].equals(myChromosomes[i].getName())) break;
				}
				int whichChrom=i;
				if(chromToDisplay>0&&(whichChrom+1)!=chromToDisplay) continue;
				int xCoord=x0+((chromToDisplay==0)?wcol*(whichChrom%ncol):0);
				int yCoord=(horizontal!=null&&chromToDisplay>0)?space:px+space+((chromToDisplay==0)?(px+space)*(whichChrom/ncol):space);
				String bpLoc=locInfo[1];
				int numPx=(int)((Double.parseDouble(bpLoc)-min)*scale);
				if(horizontal!=null&&chromToDisplay>0) {
					pointer(image,yCoord+numPx,xCoord+wi+1,-6,8,1);
				} else {
					pointer(image,xCoord+wi+1,(chromToDisplay > 0? numPx :yCoord-numPx),6,8,0);
				}
			}
		}
	}
	if (regionsToDisplay != null) {
		boolean left = false;
		image.setColor(Color.blue);

        	for (Iterator itr=regionsToDisplay.iterator(); itr.hasNext();) {
            		// Each string is something like: "3|||5.0E7-1.000090909E10"
            		String range = (String) itr.next();
            		String [] locInfo =range.split("[|]+");
				for(i=0;i<myChromosomes.length;i++) {
					if (locInfo[0].equals(myChromosomes[i].getName())) break;
				}
            		int whichChrom=i;
            		int indexOfHyphen=locInfo[1].indexOf('-');
            		int rangeStart=(int)((Double.parseDouble(locInfo[1].substring(0,indexOfHyphen))-min)*scale);
            		int rangeEnd=(int)((Double.parseDouble(locInfo[1].substring(indexOfHyphen+1))-min)*scale);
            		
				rangeEnd = Math.min(rangeEnd, (int)(myChromosomes[whichChrom].getLength()*scale));
            		if(chromToDisplay>0&&(whichChrom+1)!=chromToDisplay) continue;
            		int xCoord=x0+((chromToDisplay==0)?wcol*(whichChrom%ncol):0);
            		int yCoord=(horizontal!=null&&chromToDisplay>0)?space:px+space+((chromToDisplay==0)?(px+space)*(whichChrom/ncol):space);
            		if(horizontal!=null&&chromToDisplay>0) {
                		if(left) bracket(image,yCoord+rangeStart,xCoord-1,rangeEnd-rangeStart,-8,1,1);
                		else bracket(image,yCoord+rangeStart,xCoord+wi+1,rangeEnd-rangeStart,8,1,1);
            		} else {
				if(left) bracket(image,xCoord-1,(chromToDisplay > 0? rangeStart : yCoord-rangeEnd),-8,rangeEnd-rangeStart,1,0);
					bracket(image,xCoord+wi+1, (chromToDisplay > 0? rangeStart : yCoord-rangeEnd),8,rangeEnd-rangeStart,1,0);
            		}
		}
	}

////send image

      boolean returnOctet = false;
      if ( req.getParameter( "sendOctet" ) != null )
          returnOctet = req.getParameter( "sendOctet" ).equals( "true" );

      image.dispose();

      if ( returnOctet ) {
          res.setContentType( "application/octet-stream" );
          res.setHeader( "Content-Disposition", "attachment; filename=\"graphic.jpg\"");
      } else {
          res.setContentType("image/jpeg");
      }

      try {
         ImageIO.write(bufferedImage,"jpg",res.getOutputStream());
      } catch(IOException err){
        throw err;
      }

   }



	private void getColor(String s,int[] c) {
		String r,g,b;
		r=s.substring(0,2);
		g=s.substring(2,4);
		b=s.substring(4);
		c[0]=Integer.valueOf(r,16).intValue();
		c[1]=Integer.valueOf(g,16).intValue();
		c[2]=Integer.valueOf(b,16).intValue();
	}

	private void bracket(Graphics image,int x,int y,int dx,int dy,int width,int height) {
		int[] xt=new int[8];
		int[] yt=new int[8];

		if(width<2) {
			if(height==1) {
				image.drawLine(x,y,x,y+dy);
				image.drawLine(x,y+dy,x+dx,y+dy);
				image.drawLine(x+dx,y+dy,x+dx,y);
			} else {
				image.drawLine(x,y,x+dx,y);
				image.drawLine(x+dx,y,x+dx,y+dy);
				image.drawLine(x+dx,y+dy,x,y+dy);
			}
		} else {
			if(height==1) {
				yt[0]=yt[3]=yt[4]=yt[7]=y;
				yt[1]=yt[2]=y+dy;
				yt[5]=yt[6]=y+dy-width;
				xt[0]=xt[1]=x;
				xt[2]=xt[3]=x+dx;
				xt[4]=xt[5]=x+dx-width;
				xt[6]=xt[7]=x+width;
			} else {
				xt[0]=xt[3]=xt[4]=xt[7]=x;
				xt[1]=xt[2]=x+dx;
				xt[5]=xt[6]=x+dx-width;
				yt[0]=yt[1]=y;
				yt[2]=yt[3]=y+dy;
				yt[4]=yt[5]=y+dy-width;
				yt[6]=yt[7]=y+width;
			}
			image.fillPolygon(xt,yt,8);
		}
	}

	private void pointer(Graphics image,int x,int y,int height,int b,int dir) {
		// x is x coordinate
		// y is y coordinate
		// height is height of triangle
		// b is width of base of triangle
		// dir is the direction of the triangle. 0 means pointing to the right,
		//  1 means pointing up

		int[] xt=new int[3];
		int[] yt=new int[3];

		if(dir==0) {
			xt[0]=x;
			xt[1]=xt[2]=x+height;
			yt[0]=y;
			yt[1]=y+b/2;
			yt[2]=y-b/2;
		} else {
			xt[0]=x;
			xt[1]=x+b/2;
			xt[2]=x-b/2;
			yt[0]=y;
			yt[1]=yt[2]=y-height;
		}
		image.fillPolygon(xt,yt,3);
	}

	private String writeArea(String gene,int x,int y,String transOrGenes,String organismToDisplay) {
		NumberFormat nf = NumberFormat.getInstance();
		String s = "";
		String id=gene.substring(0,(gene.indexOf('(') == -1 ? gene.indexOf (" -- ") : gene.indexOf('(')));
		String[] g=gene.split(" -- ");
		String location=nf.format(Double.parseDouble(gene.substring(gene.lastIndexOf('|')+1)));

		s+="<area class=\"pointer\" shape=\"Rect\" coords=\""+(x-5)+","+(y-5)+","+(x+5)+","+(y+5)+"\"";
		if(transOrGenes.equals("genes")){
			s+=" href=\"javascript: top.showData('"+id+"','"+organismToDisplay+"');\" title=\""+g[0]+":"+location+"\">\n";
		}
		else
		{
			s+=" href=\"javascript: top.showTransData('"+id+"','"+organismToDisplay+"');\" title=\""+g[0]+":"+location+"\">\n";
		}
		return s;
	}
}

