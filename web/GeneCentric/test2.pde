ArrayList sequences;
ArrayList variants;
String refSeq="";
int lengthSeq=0;
int ht=6;
int margin=10;
int rtMargin=40;
int topMargin=85;
int heightNeeded=100;
double widthPerBase=2;
int halfWidth=1;
int startY=0;
int refSeqY=39;
int coordY=13;
int numberY=26;
int genomeStart=0;
int genomeStop=0;
String chr="";

Sequence addSequence(int offset, String sequence, int num) {
    Sequence s = new Sequence(offset,sequence,num);
     sequences.add(s);
     return s;
}

Variant addVariant(int coord, String sequence, String strain) {
    int sOffset=56;
    if(strain.equals("SHRH")){
      sOffset=70;
    }
    Variant v = new Variant(coord,sequence,sOffset);
     variants.add(v);
     return v;
}

void setRefSeq(String ref){
    refSeq=ref;
    lengthSeq=refSeq.length();
}

void setGenomeCoord(int start,int stop,String chrom){
    genomeStart=start;
    genomeStop=stop;
    chr="chr"+chrom;
}

void setup(){
    sequences=new ArrayList();
    variants=new ArrayList();
    background(255,255,255);
    noLoop();    
    heightNeeded=topMargin+(sequences.size()*ht)+((sequences.size()+2)*margin)+ht*2;
    size(850,heightNeeded);
    startY=ht*2+topMargin+margin;
}

void draw(){
  if(lengthSeq>0){
    widthPerBase=(width-(margin+rtMargin)*1.0)/lengthSeq;
  }else{
    widthPerBase=2;
  }
  halfWidth=(int)widthPerBase/2;
  if(sequences.size()>15){
    ht=(int)ht/2;
    margin=(int)margin/2;
    startY=ht*2+topMargin+margin;
  }
  heightNeeded=topMargin+(sequences.size()*ht)+((sequences.size()+2)*margin)+ht*2;
  size(850,heightNeeded);
  
  //draw reference rectangles
  fill(49,122,255);
  rect(rtMargin+halfWidth,topMargin,widthPerBase*lengthSeq-halfWidth,ht*1.5);
  
  //draw read seq rectangles
  for(int p=0, end=sequences.size(); p<end; p++) {
      Sequence s=(Sequence)sequences.get(p);
      s.draw();
  }
  
  //write ref sequence
  for(int i=0;i<refSeq.length();i++){
    int x=(int)(rtMargin+halfWidth+widthPerBase*i);
    fill(49,122,255);
    text(refSeq.charAt(i),x,refSeqY);
    if(i==0||(i+1)%10==0){
        fill(0,0,0);
        text(i+1,x,numberY);
    }
  }
  //draw variants
  for(int p=0, end=variants.size(); p<end; p++) {
      Variant v=(Variant)variants.get(p);
      v.draw();
  }
  
  //label sequence strings
  fill(0,0,0);
  String tmp=genomeStop+"bp";
  text(genomeStart+"bp",rtMargin+halfWidth,coordY);
  text(genomeStop+"bp",width-(margin+7*tmp.length()),coordY);
  text(chr,width/2,coordY);
  text("BNLX:",0,56);
  text("SHRH:",0,70);
}

class Sequence {
  int offset;
  String seq;
  int vertNum=0;
  Sequence(int offset,String seq,int num){
      this.offset=offset;
      this.seq=seq;
      this.vertNum=num;
  }
  void draw(){
      fill(98, 139, 97);
         int os=(int)widthPerBase*offset;
         int len=(int)widthPerBase*seq.length()-halfWidth;
         int curY=startY+(ht*vertNum)+(margin*vertNum);
         rect(rtMargin+halfWidth+os,curY,len, ht);
  }
}

class Variant {
    int coord;
    int offsetX;
    int offsetY;
    String seq;
    
    Variant(int coord,String seq,int offsetY){
      this.coord=coord;
      this.seq=seq;
      this.offsetY=offsetY;
      this.offsetX=coord-genomeStart;
    }
    
    void draw(){
      int x=(int)(rtMargin+halfWidth+widthPerBase*offsetX);
      fill(255,0,0);
      text(seq,x,offsetY);
    }
}
