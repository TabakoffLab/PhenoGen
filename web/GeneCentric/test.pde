String[] sequences=new String[3];
String refSeq="GCCATCGACGTATGTAGTAGCTGGT";
String concSeq="GCCATCGACGTACGTAGTAGCTGGT";
int[] starting=new int[3];
int lengthSeq=25;
int ht=6;
int margin=10;
int rtMargin=60;
int topMargin=70;
int heightNeeded=100;
double widthPerBase=2;
int halfWidth=1;
int startY=0;
int refSeqY=35;
int concSeqY=55;
int numberY=13;

void setup(){
    background(255,255,255);
    noLoop();    
    sequences[0]="ATCGACGTACGTAGTAGCT";
    sequences[1]="CCATCGACGTACGTAGTAGCT";
    sequences[2]="CGACGTACGTAGTAGCTGGT";
    starting[0]=3;
    starting[1]=1;
    starting[2]=5;
    heightNeeded=topMargin+(sequences.length*ht)+((sequences.length+2)*margin)+ht*2;
    size(800,heightNeeded);
    widthPerBase=(width-(margin+rtMargin))/concSeq.length();
    halfWidth=(int)widthPerBase/2;
    startY=ht*2+topMargin+margin;;
}

void draw(){
  //draw reference rectangles
  fill(49,122,255);
  rect(rtMargin,topMargin,(width-(margin+rtMargin)),ht*2);
  //draw read seq rectangles
  fill(30, 100, 39);
  for(int i=0;i<sequences.length;i++){
       int offset=(int)widthPerBase*starting[i];
       int len=(int)widthPerBase*sequences[i].length();
       int curY=startY+(ht*i)+(margin*i);
       rect(rtMargin+offset,curY,len, ht);
    
  }
  //write ref sequence
  fill(49,122,255);
  for(int i=0;i<concSeq.length();i++){
    int x=(int)(rtMargin+halfWidth+widthPerBase*i);
    if(refSeq.charAt(i)==concSeq.charAt(i)){
      fill(49,122,255);
    }else{
      fill(255, 0, 0);
    }
    text(refSeq.charAt(i),x,refSeqY);
    if(i==0||(i+1)%10==0){
        fill(0,0,0);
        text(i+1,x,numberY);
    }
  }
  //Write concensus sequence
  fill(40, 117, 49);
  for(int i=0;i<concSeq.length();i++){
    int x=(int)(rtMargin+halfWidth+widthPerBase*i);
    if(refSeq.charAt(i)==concSeq.charAt(i)){
      fill(40, 117, 49);
    }else{
      fill(255, 0, 0);
    }
    text(concSeq.charAt(i),x,concSeqY);
  }
  //label sequence strings
  fill(0,0,0);
  text("Reference:",0,refSeqY);
  text("RNA-Seq:",0,concSeqY);
}
