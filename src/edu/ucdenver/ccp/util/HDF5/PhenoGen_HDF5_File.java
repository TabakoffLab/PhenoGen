package edu.ucdenver.ccp.util.HDF5;


import java.io.*;
import ncsa.hdf.object.*;     // the common object package
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.List;
import ncsa.hdf.hdf5lib.HDF5Constants;





public class PhenoGen_HDF5_File{
    
    public static String LEVEL_VERSION="version";
    public static String LEVEL_FILTER="filter";
    public static String LEVEL_MULTITEST="multitest";
    
    public static String GROUP_FILTER="Filters";
    public static String GROUP_MULTI="MultiTest";
    
    public static String DATASET_MAIN_PROBESET="Probeset";
    public static String DATASET_MAIN_DABGPVAL="DABGPval";
    public static String DATASET_MAIN_DABGPERC="DABGPerc";
    public static String DATASET_MAIN_DATA="Data";
    public static String DATASET_MAIN_SAMPLES="Samples";
    public static String DATASET_MAIN_GROUPING="Grouping";
    
    public static String DATASET_FILTER_PROBESET="fProbeset";
    public static String DATASET_FILTER_DATA="fData";
    public static String DATASET_FILTER_STATS="Statistics";
    public static String DATASET_FILTER_PVAL="Pval";
    //public static String DATASET_FILTER_FILTER="Filter";
    
    public static String DATASET_MULTI_PROBESET="mProbeset";
    public static String DATASET_MULTI_DATA="mData";
    public static String DATASET_MULTI_STATS="mStatistics";
    public static String DATASET_MULTI_PVAL="mPval";
    public static String DATASET_MULTI_ADJPVAL="Adjp";
    
    
    
    

    private Thread waitThread = null;
    private String source = "";
    private String outputDir = "";
    private String arrayType = "";
    private String version="";
    
    Group root;
    Group gCurVer=null;
    Group gGroups=null;
    Group gFilters=null;
    Group gMulti=null;
    Group gFDay=null;
    Group gFTime=null;

    private HDF5_File h5FFile;
    
    public PhenoGen_HDF5_File(String path) throws Exception {
        h5FFile=new HDF5_File(path,false,6);
        h5FFile.openFile();
        root=h5FFile.getRoot();
    }

    public boolean isOpen(){
        return h5FFile.isOpen();
    }
    
    public void openVersion(String ver) throws Exception{
        version=ver;
        gCurVer=h5FFile.openGroup(ver, "/", root);
        //System.out.println("Open curVer:"+gCurVer);
        gFilters = h5FFile.openGroup(GROUP_FILTER,gCurVer.getPath()+gCurVer.getName()+"/", gCurVer);
        //System.out.println("Open filter:"+gFilters);
    }
    public Group openFilterDay(String curDay) throws Exception{
        Group ret=null;
        if(gFDay!=null&&gFDay.getName().equals(curDay)){
            ret=gFDay;
        }else{
            if(this.groupExists(gFilters, curDay)){
                ret=h5FFile.openGroup(curDay, this.getPathGroup(gFilters),gFilters);
                gFDay=ret;
            }else{
                gFDay=h5FFile.createGroup(curDay, gFilters);
                ret=gFDay;
            }
        }
        return ret;
    }
    public Group openFilterTime(String curDay,String curTime) throws Exception{
        Group ret=null;
        if(gFDay==null||!gFDay.getName().equals(curDay)){
            this.openFilterDay(curDay);
        }
        if(gFTime!=null&&gFTime.getName().equals(curTime)){
            ret=gFTime;
        }else{
        if(this.groupExists(gFDay, curTime)){
            ret=h5FFile.openGroup(curTime, this.getPathGroup(gFDay),gFDay);
            gFTime=ret;
        }else{
            gFTime=h5FFile.createGroup(curTime, gFDay);
            ret=gFTime;
        }
        }
        return ret;
    }
    public Group openMulti(String curDay,String curTime) throws Exception{
        Group ret=null;
        this.openFilterTime(curDay,curTime);
        if(gMulti==null){
            if(this.groupExists(gFTime, "Multi")){
                ret=h5FFile.openGroup("Multi", this.getPathGroup(gFTime),gFTime);
                gMulti=ret;
            }else{
                gMulti=h5FFile.createGroup("Multi", gFTime);
                ret=gMulti;
            }
        }else{
            ret=gMulti;
        }
        return ret;
    }
    public void createVersion(String ver) throws Exception{
        gCurVer = h5FFile.createGroup(ver, root);
        gFilters = h5FFile.createGroup(GROUP_FILTER, gCurVer);
    } 
   
    public Dataset openDataset(String ds) throws Exception{
        Dataset ret=null;
        ret=h5FFile.openDataset(ds,getPathDS(ds));
        return ret;
    }
    
    public Dataset openDataset(String ds,String path)throws Exception{
        Dataset ret=null;
        ret=h5FFile.openDataset(ds,path);
        return ret;
    }
    
    public String getPathDS(String ds) throws Exception{
        String ret="/";
        Group tmp=this.getGroupFromDataset(ds);
        if(tmp!=null){
            ret=tmp.getPath()+tmp.getName()+"/";
        }
        return ret;
    }
    public String getPathGroup(Group g) throws Exception{
        String ret="/";
        ret=g.getPath()+g.getName()+"/";
        return ret;
    }
    
    public void deleteGroup(Group g) throws Exception{
        String gName=g.getName();
        h5FFile.deleteGroup(g);
        if(gName.equals(PhenoGen_HDF5_File.GROUP_MULTI)){
            gMulti=null;
        }else if(gName.equals(PhenoGen_HDF5_File.GROUP_FILTER)){
            gFilters=null;
        }
    }
    public void deleteFilter(String ver) throws Exception{
        if(version.equals(ver)){
            h5FFile.clearMemory();
            h5FFile.deleteGroup(this.getGroupFromLevel(this.LEVEL_FILTER));
            this.openVersion(ver);
            gFilters = h5FFile.createGroup(GROUP_FILTER, gCurVer);
        }else{
            throw new Exception();
        }
    }
    
    public void deleteFilterStat(String ver,String curDate,String curTime) throws Exception{
        if(version.equals(ver)){
            h5FFile.clearMemory();
            h5FFile.deleteGroup(this.openFilterTime(curDate, curTime));
            Group tmp=this.openFilterDay(curDate);
            List list=tmp.getMemberList();
            if(list==null||list.isEmpty()){
                h5FFile.deleteGroup(tmp);
            }
        }else{
            throw new Exception();
        }
    }
    
    public void deleteDataset(String name,Group parent)throws Exception{
        Dataset ds=this.openDataset(name,this.getPathGroup(parent));
        h5FFile.deleteDataset(ds);
    }
    
    public void deleteFilterStatProbesets(String ver,String curDate,String curTime) throws Exception{
        if(version.equals(ver)){
            h5FFile.clearMemory();
            Group ct=this.openFilterTime(curDate, curTime);
            if(this.datasetExists(this.DATASET_FILTER_PROBESET, ct)){
                this.deleteDataset(this.DATASET_FILTER_PROBESET,ct);
            }
            /*if(this.datasetExists(this.DATASET_FILTER_DATA,ct)){
                ds=this.openDataset(this.DATASET_FILTER_DATA,this.getPathGroup(ct));
                this.deleteDataset(ds);
            }*/
        }else{
            throw new Exception();
        }
    }
    
    public void deleteFilterData(String ver,String curDate,String curTime) throws Exception{
        if(version.equals(ver)){
            h5FFile.clearMemory();
            Group ct=this.openFilterTime(curDate, curTime);
            if(this.datasetExists(this.DATASET_FILTER_DATA, ct)){
                this.deleteDataset(this.DATASET_FILTER_DATA,ct);
            }
            /*if(this.datasetExists(this.DATASET_FILTER_DATA,ct)){
                ds=this.openDataset(this.DATASET_FILTER_DATA,this.getPathGroup(ct));
                this.deleteDataset(ds);
            }*/
        }else{
            throw new Exception();
        }
    }
    
    public void deleteMultiData(String ver,String curDate,String curTime) throws Exception{
        if(version.equals(ver)){
            h5FFile.clearMemory();
            Group ct=this.openMulti(curDate, curTime);
            if(this.datasetExists(this.DATASET_MULTI_DATA, ct)){
                this.deleteDataset(this.DATASET_MULTI_DATA,ct);
            }
        }else{
            throw new Exception();
        }
    }
    public void deleteMultiProbeset(String ver,String curDate,String curTime) throws Exception{
        if(version.equals(ver)){
            h5FFile.clearMemory();
            Group ct=this.openMulti(curDate, curTime);
            if(this.datasetExists(this.DATASET_MULTI_PROBESET, ct)){
                this.deleteDataset(this.DATASET_MULTI_PROBESET,ct);
            }
        }else{
            throw new Exception();
        }
    }
    public void deleteMultiStats(String ver,String curDate,String curTime) throws Exception{
        if(version.equals(ver)){
            h5FFile.clearMemory();
            Group ct=this.openMulti(curDate, curTime);
            if(this.datasetExists(this.DATASET_MULTI_STATS, ct)){
                this.deleteDataset(this.DATASET_MULTI_STATS,ct);
            }
        }else{
            throw new Exception();
        }
    }
    public void deleteMultiPval(String ver,String curDate,String curTime) throws Exception{
        if(version.equals(ver)){
            h5FFile.clearMemory();
            Group ct=this.openMulti(curDate, curTime);
            if(this.datasetExists(this.DATASET_MULTI_PVAL, ct)){
                this.deleteDataset(this.DATASET_MULTI_PVAL,ct);
            }
        }else{
            throw new Exception();
        }
    }
    
    public void deleteMultiAdjPval(String ver,String curDate,String curTime) throws Exception{
        if(version.equals(ver)){
            h5FFile.clearMemory();
            Group ct=this.openMulti(curDate, curTime);
            if(this.datasetExists(this.DATASET_MULTI_ADJPVAL, ct)){
                this.deleteDataset(this.DATASET_MULTI_ADJPVAL,ct);
            }
        }else{
            throw new Exception();
        }
    }
    public void deleteVersion(String ver) throws Exception{
        if(version.equals(ver)){
            h5FFile.clearMemory();
            this.openVersion(ver);
            h5FFile.deleteGroup(gCurVer);
        }else{
            throw new Exception();
        }
    }
    public boolean filterProbesetExists(String ver,String curDate,String curTime) throws Exception{
        boolean ret=false;
        if(version.equals(ver)){
            Group ct=this.openFilterTime(curDate, curTime);
            if(this.datasetExists(this.DATASET_FILTER_PROBESET, ct)){
                ret=true;
            }
        }
        return ret;
    }
    public boolean datasetExists(String name, Group parent){
        return h5FFile.datasetExists(name,parent);
    }
    public void writeProbeList(long[] probeList,String ds)throws Exception{
        long[] dim={probeList.length};
        h5FFile.createLongDataSet(dim,ds,this.getGroupFromDataset(ds),probeList,true);
    }
    
    public void writeFilteredProbeList(long[] probeList,String curDate,String curTime)throws Exception{
        long[] dim={probeList.length};
        Group curF=this.getGroupFromLevel(this.LEVEL_FILTER);
        Group curD=this.openFilterDay(curDate);
        Group curT=this.openFilterTime(curDate,curTime);
        System.out.println("Cur Time Opened:"+curT.getName());
        h5FFile.createLongDataSet(dim,this.DATASET_FILTER_PROBESET,curT,probeList,true);
    }
    
    public void writeProbeListPart(long[] probeList,long beginRow,int length,String ds)throws Exception{
        if(probeList.length>length){
                long[] old=probeList;
                probeList=new long[length];
                for(int i=0;i<length;i++){
                    probeList[i]=old[i];
                }
            }
        if(beginRow==0){
            long[] maxDim={HDF5Constants.H5S_UNLIMITED};
            long[] dim={length};
            
            h5FFile.createLongDataSet(dim,ds,gCurVer,probeList,true,maxDim);
        }else{
            h5FFile.addToLongDataset(ds,this.getPathDS(ds),beginRow,length,probeList);
        }
    }
    
    public void writeSampleList(String[] data)throws Exception{
        long[] dims={data.length};
        h5FFile.createStringDataSet(dims,DATASET_MAIN_SAMPLES,gCurVer,data,250,true);
    }
    
    public void writeAvgData(double[][] dat,String datasetLoc)throws Exception{
        long[] dims={dat.length,dat[0].length};
        h5FFile.createDoubleDataSet(dims,datasetLoc,this.getGroupFromDataset(datasetLoc),dat,true);
    }
    
    public void writeAvgDataPart(double[][] avgData,long beginRow,int length,String datasetLoc)throws Exception{
        double[][] tmp=avgData;
        if(avgData.length>length&&beginRow<avgData.length){
                tmp=new double[length][avgData[0].length];
                int max=(int)beginRow+length;
                for(int i=(int)beginRow;i<max;i++){
                    int index=(int)((int)i-beginRow);
                    tmp[index]=avgData[i];
                }
        }else if(avgData.length>length&&beginRow>avgData.length){
            tmp=new double[length][avgData[0].length];
                for(int i=0;i<length;i++){
                    tmp[i]=avgData[i];
                }
        }
        if(beginRow==0){
            //long[] maxDim={HDF5Constants.H5S_UNLIMITED,avgData[0].length};
            long[] maxDim={HDF5Constants.H5S_UNLIMITED,HDF5Constants.H5S_UNLIMITED};
            long[] dim={length,avgData[0].length};
            
            h5FFile.createDoubleDataSet(dim,datasetLoc,this.getGroupFromDataset(datasetLoc),tmp,true,maxDim);
        }else{
            //System.out.println("Write AVG Data:"+beginRow+":"+length+":"+avgData.length);
            Group tmpG=this.getGroupFromDataset(datasetLoc);
            h5FFile.addToDoubleDataset(datasetLoc,this.getPathDS(datasetLoc),beginRow,length,tmp);
        }
    }
    
    public void writeFilterAvgData(double[][] dat,String curDate,String curTime)throws Exception{
        long[] dims={dat.length,dat[0].length};
        Group tmpG=this.openFilterTime(curDate, curTime);
        h5FFile.createDoubleDataSet(dims,this.DATASET_FILTER_DATA,tmpG,dat,true);
    }
    
    public void writeFilterAvgDataPart(double[][] avgData,long beginRow,int length,String curDate,String curTime)throws Exception{
        double[][] tmp=avgData;
        Group tmpG=this.openFilterTime(curDate, curTime);
        if(avgData.length>length&&beginRow<avgData.length){
                tmp=new double[length][avgData[0].length];
                int max=(int)beginRow+length;
                for(int i=(int)beginRow;i<max;i++){
                    int index=(int)((int)i-beginRow);
                    tmp[index]=avgData[i];
                }
        }else if(avgData.length>length&&beginRow>avgData.length){
            tmp=new double[length][avgData[0].length];
                for(int i=0;i<length;i++){
                    tmp[i]=avgData[i];
                }
        }
        if(beginRow==0){
            //long[] maxDim={HDF5Constants.H5S_UNLIMITED,avgData[0].length};
            long[] maxDim={HDF5Constants.H5S_UNLIMITED,HDF5Constants.H5S_UNLIMITED};
            long[] dim={length,avgData[0].length};
            
            h5FFile.createDoubleDataSet(dim,this.DATASET_FILTER_DATA,tmpG,tmp,true,maxDim);
        }else{
            //System.out.println("Write AVG Data:"+beginRow+":"+length+":"+avgData.length);
            h5FFile.addToDoubleDataset(this.DATASET_FILTER_DATA,this.getPathGroup(tmpG),beginRow,length,tmp);
        }
    }
    
    public void writeGrouping(int[] grouping)throws Exception{
            long[] dims={grouping.length};
            h5FFile.createIntDataSet(dims,DATASET_MAIN_GROUPING,gCurVer,grouping,true);
    }
    
    public void writeDABGPval(double[][] pval)throws Exception{
        long[] dim={pval.length,pval[0].length};
        h5FFile.createDoubleDataSet(dim,DATASET_MAIN_DABGPVAL,gCurVer,pval,true);
    }
    
    public void writeDABGPvalPart(double[][] pval,long beginRow,int length)throws Exception{
        if(pval.length>length){
                double[][] old=pval;
                pval=new double[length][old[0].length];
                for(int i=0;i<length;i++){
                    pval[i]=old[i];
                }
        }
        if(beginRow==0){
            //long[] maxDim={HDF5Constants.H5S_UNLIMITED,pval[0].length};
            long[] maxDim={HDF5Constants.H5S_UNLIMITED,HDF5Constants.H5S_UNLIMITED};
            long[] dim={length,pval[0].length};
            
            h5FFile.createDoubleDataSet(dim,DATASET_MAIN_DABGPVAL,gCurVer,pval,true,maxDim);
        }else{
            h5FFile.addToDoubleDataset(DATASET_MAIN_DABGPVAL,gCurVer.getPath()+gCurVer.getName()+"/",beginRow,length,pval);
        }
    }
    
    public void writeDABGPerc(double[] percDabg)throws Exception{
        long[] dim={percDabg.length};
            h5FFile.createDoubleDataSet(dim,DATASET_MAIN_DABGPERC,gCurVer,percDabg,true);
    }
    
    public void writeDABGPercPart(double[] percDabg,long beginRow,int length)throws Exception{
        if(percDabg.length>length){
                double[] old=percDabg;
                percDabg=new double[length];
                for(int i=0;i<length;i++){
                    percDabg[i]=old[i];
                }
            }
        if(beginRow==0){
            long[] maxDim={HDF5Constants.H5S_UNLIMITED};
            long[] dim={length};
            
            h5FFile.createDoubleDataSet(dim,DATASET_MAIN_DABGPERC,gCurVer,percDabg,true,maxDim);
        }else{
            h5FFile.addToDoubleDataset(DATASET_MAIN_DABGPERC,gCurVer.getPath()+gCurVer.getName()+"/",beginRow,length,percDabg);
        }
    }
    
    /*public void writeGroups(ArrayList<ArrayList<Integer>> groups,String[] groupNum,int gid)throws Exception{
        long[] dims=new long[1];
        gGroups=h5FFile.createGroup("Groups", gCurVer);
        for(int i=0;i<groups.size();i++){
                ArrayList<Integer> tmpArray=groups.get(i);
                int[] tmpInt=new int[tmpArray.size()];
                for(int j=0;j<tmpInt.length;j++){
                    tmpInt[j]=tmpArray.get(j).intValue();
                }
                dims[0]=tmpArray.size();
                h5FFile.createIntDataSet(dims,groupNum[i],gGroups,tmpInt,true);
        }
    }*/
    
    /*public void writeFilter(int[] filter)throws Exception{
            long[] dims={filter.length};
            h5FFile.createIntDataSet(dims,DATASET_FILTER_FILTER,gFilters,filter,true);
    }
    public void writeDefaultFilter(int probesetlength)throws Exception {
        int[] tmp=new int[probesetlength];
        for(int i=0;i<tmp.length;i++){
            tmp[i]=1;
        }
        this.writeFilter(tmp);
    }*/
    
    public void close()throws Exception{
        h5FFile.closeAll();
    }

    public boolean versionExists(String ver) {
        boolean ret=false;
        if(root!=null){
            List<HObject> list=root.getMemberList();
            if (list != null) {
                for (int i = 0; i < list.size() && !ret; i++) {
                    Group obj = (Group) list.get(i);
                    if (obj.getName().equals(ver)) {
                        ret = true;
                    }
                }
            }
        }
        return ret;
    }
    
    public boolean groupExists(Group parent, String groupName){
        boolean ret=false;
        List<HObject> list=parent.getMemberList();
        if (list != null) {
                for (int i = 0; i < list.size() && !ret; i++) {
                    Group obj = (Group) list.get(i);
                    if (obj.getName().equals(groupName)) {
                        ret = true;
                    }
                }
        }
        return ret;
    }

    public void clearMemory(String ver)throws Exception{
        root=null;
        gGroups=null;
        gFilters=null;
        gCurVer=null;
        h5FFile.clearMemory();
        root=h5FFile.openRoot();
        this.openVersion(ver);
    }
    
    public long[] getDatasetDims(String ds) throws Exception{
        long[] ret=null;
        Group curGroup=this.getGroupFromDataset(ds);
        Dataset curDS=h5FFile.openDataset(ds, curGroup.getPath()+curGroup.getName()+"/");
        curDS.open();
        curDS.getMetadata();
        ret=curDS.getDims();
        return ret;
    }
    
    public long getProbeCount(String path, String ds) throws Exception{
        long[] tmp=null;
        Dataset curDS=h5FFile.openDataset(ds, path);
        curDS.open();
        curDS.getMetadata();
        tmp=curDS.getDims();
        long ret=tmp[0];
        return ret;
    }
    
    public long getSampleCount(String path, String ds) throws Exception{
        long[] tmp=null;
        Dataset curDS=h5FFile.openDataset(ds, path);
        curDS.open();
        curDS.getMetadata();
        tmp=curDS.getDims();
        long ret=tmp[1];
        return ret;
    }
    
    
    public Group getGroupFromLevel(String level_constant) throws Exception{
        Group curGroup=null;
        if(level_constant.equals(LEVEL_VERSION)){
            if(gCurVer==null){
                gCurVer=h5FFile.openGroup(this.LEVEL_VERSION, "/", root);
            }
            curGroup=gCurVer;
        }else if(level_constant.equals(LEVEL_FILTER)){
            if(gFilters==null){
                if(gCurVer==null){
                    gCurVer=this.getGroupFromLevel(this.LEVEL_VERSION);
                }
                gFilters=h5FFile.openGroup(GROUP_FILTER, gCurVer.getPath()+gCurVer.getName()+"/", gCurVer);
            }
            curGroup=gFilters;
        }else if(level_constant.equals(LEVEL_MULTITEST)){
            if(gMulti==null){
                if(gFilters==null){
                    gFilters=this.getGroupFromLevel(this.LEVEL_FILTER);
                }
                gFilters=h5FFile.openGroup(this.GROUP_MULTI, gFilters.getPath()+gFilters.getName()+"/", gFilters);
            }
            curGroup=gMulti;
        }
        
        return curGroup;
    }
    
    private Group getGroupFromDataset(String dataset) throws Exception{
        Group ret=null;
        if(dataset.equals(this.DATASET_MAIN_DABGPERC)||
                dataset.equals(this.DATASET_MAIN_DABGPVAL)||
                dataset.equals(this.DATASET_MAIN_DATA)||
                dataset.equals(this.DATASET_MAIN_GROUPING)||
                dataset.equals(this.DATASET_MAIN_PROBESET)||
                dataset.equals(this.DATASET_MAIN_SAMPLES)
                ){
            ret=this.getGroupFromLevel(this.LEVEL_VERSION);
        }
        else if(dataset.equals(this.DATASET_FILTER_DATA)||
                dataset.equals(this.DATASET_FILTER_PROBESET)||
                dataset.equals(this.DATASET_FILTER_PVAL)||
                dataset.equals(this.DATASET_FILTER_STATS)){
            ret=this.getGroupFromLevel(this.LEVEL_FILTER);
        }
        else if(dataset.equals(this.DATASET_MULTI_ADJPVAL)||
                dataset.equals(this.DATASET_MULTI_PROBESET)||
                dataset.equals(this.DATASET_MULTI_DATA)||
                dataset.equals(this.DATASET_MULTI_PVAL)||
                dataset.equals(this.DATASET_MULTI_STATS)){
            ret=this.getGroupFromLevel(this.LEVEL_MULTITEST);
        }
        return ret;
    }
    
    public long[] readFilteredProbeset(String curDate,String curTime)throws Exception{
        String path=this.getPathGroup(this.getGroupFromDataset(this.DATASET_FILTER_PROBESET))+"/"+curDate+"/"+curTime+"/";
        long[] ret=this.readProbeset(this.DATASET_FILTER_PROBESET,path);
        return ret;
    }
    
    public long[] readMainProbeset(String version)throws Exception{
        long[] ret=new long[0];
        if(version.equals(this.version)){
            String path=this.getPathGroup(this.getGroupFromDataset(this.DATASET_MAIN_PROBESET));
            ret=this.readProbeset(this.DATASET_MAIN_PROBESET,path);
        }
        return ret;
    }
        

    public long[] readProbeset(String Dataset,String path) throws Exception{
        Group curGroup=this.getGroupFromDataset(Dataset);
        long[] ret=h5FFile.readLongDataset(Dataset, path);
        return ret;
    }
    
    public int[] readProbesetFromR(String Dataset,String path) throws Exception{
        Group curGroup=this.getGroupFromDataset(Dataset);
        int[] ret=h5FFile.readIntDataset(Dataset, path);
        return ret;
    }
    
    public long[] readProbesetPart(String Dataset,String path,long begin,long len) throws Exception{
        Group curGroup=this.getGroupFromDataset(Dataset);
        long[] ret=h5FFile.readLongDatasetPart(Dataset, path,begin,len);
        return ret;
    }
    
    public double[] readDABGPerc(String Dataset,String path) throws Exception{
        Group curGroup=this.getGroupFromDataset(Dataset);
        double[] ret=h5FFile.readDoubleDataset(Dataset, path);
        return ret;
    }
    
    public int[] readGrouping(String Dataset,String path) throws Exception{
        Group curGroup=this.getGroupFromDataset(Dataset);
        int[] ret=h5FFile.readIntDataset(Dataset, path);
        return ret;
    }
    
    public String[] readSamples(String Dataset,String path) throws Exception{
        Group curGroup=this.getGroupFromDataset(Dataset);
        String[] ret=h5FFile.readStringDataset(Dataset, path);
        return ret;
    }
    
    /*public void writeFilteredProbeset(int[] includeProbeList) throws Exception {
        long[] dims={includeProbeList.length};
        long[] maxDims={includeProbeList.length};
        h5FFile.createIntDataSet(dims,this.DATASET_FILTER_PROBESET, this.getGroupFromDataset(this.DATASET_FILTER_PROBESET) , includeProbeList, true);
    }*/

    public void writeFilteredData(long[] includeProbeList,String curDate,String curTime) throws Exception {
        System.out.println("start writeFilteredData()");
        Group cur=this.openFilterTime(curDate, curTime);
        //long[] mPS=this.readProbeset(this.DATASET_FILTER_PROBESET,this.getPathGroup(cur));
        
        
        long[] dataDims=this.getDatasetDims(this.DATASET_MAIN_DATA);
        int sampleSize=(int) dataDims[1];
        int processLength=50000;
       
        /*Hashtable incht=new Hashtable();
        for(int i=0;i<includeProbeList.length;i++){
            incht.put(includeProbeList[i], i);
        }*/
        
        //double[][] data=null;
        /*if(includeProbeList.length<processLength){
            Dataset mainDS=this.openDataset(this.DATASET_MAIN_DATA);
            data=new double[includeProbeList.length][sampleSize];
            //process
            for(int i=0;i<mPS.length;i++){
                if(incht.containsKey(mPS[i])){
                    int index=Integer.parseInt(incht.get(mPS[i]).toString());
                    //System.out.println("index"+i);
                    data[index]=(double[]) readRow(mainDS,i);
                    //System.out.println("Row"+data[index][0]+"\t"+data[index][1]+"\t"+data[index][2]+"\t"+data[index][3]);
                }
            }
            this.writeFilterAvgData(data,curDate,curTime);
        }else{*/
        
        /**********PREVIOUS
        int writeCount=0;
            int curWriteCount=0;
            data=new double[includeProbeList.length][sampleSize];
            double[][]mdata=null;
            //process
            for(int i=0;i<mPS.length;i++){
                if(i%processLength==0){
                    //System.out.println("Processing:"+writeCount*processLength);
                    Dataset mainDS=this.openDataset(this.DATASET_MAIN_DATA);
                    curWriteCount=writeCount;
                    int readLen=processLength;
                    if((writeCount*processLength+processLength)>mPS.length){
                        //System.out.println("new readLen");
                        readLen=(int)mPS.length-(writeCount*processLength);
                    }
                    //System.out.println("checking"+(writeCount*processLength+processLength)+":"+mPS.length+":"+readLen);
                    mdata=convertToDoubleArray(this.readRows(mainDS, writeCount*processLength, readLen),readLen,sampleSize);
                    writeCount++;
                    //h5FFile.closeDataset(mainDS);
                    this.clearMemory(version);
                }
                if(incht.containsKey(mPS[i])){
                    int index=Integer.parseInt(incht.get(mPS[i]).toString());
                    //System.out.println("index"+i);
                    data[index]=mdata[(i-(curWriteCount*processLength))];
                    //System.out.println("Row"+data[index][0]+"\t"+data[index][1]+"\t"+data[index][2]+"\t"+data[index][3]);
                }
            }
            this.clearMemory(version);
            //this.writeAvgData(data,this.DATASET_FILTER_DATA);
            for(int i=0;i<data.length;i=i+processLength){
                int writeLen=processLength;
                if((i+processLength)>data.length){
                    writeLen=data.length-i;
                }
                this.writeFilterAvgDataPart(data, i, writeLen, curDate,curTime);
            }****END PREVIOUS**************/
        Dataset mainDS=this.openDataset(DATASET_MAIN_DATA);
        double[][] inData=new double[processLength][sampleSize];
        long[] inProbe=new long[0];
        try{
            inProbe=this.readProbeset(DATASET_MAIN_PROBESET, "/"+version+"/");
        }catch(Exception e){
            int tmp[]=this.readProbesetFromR(DATASET_MAIN_PROBESET, "/"+version+"/");
            inProbe=new long[tmp.length];
            for(int i=0;i<tmp.length;i++){
                inProbe[i]=tmp[i];
            }
        }
        
        long[] sortedIncludeList=new long[includeProbeList.length];
        Hashtable inProbesHT=new Hashtable();
        for(int i=0;i<includeProbeList.length;i++){
            inProbesHT.put(includeProbeList[i], i);
        }
        
        Hashtable probesHT=new Hashtable();
        int sortedInd=0;
        for(int i=0;i<inProbe.length;i++){
            probesHT.put(inProbe[i], i);
            if(inProbesHT.containsKey(inProbe[i])){
                sortedIncludeList[sortedInd]=inProbe[i];
                sortedInd++;
            }
        }
        
        double[][] outData=new double[processLength][sampleSize];
        int inLoc=0;
        int instart=0;
        int inEnd=processLength-1;
        //int inProbeLoc=0;
        if((instart+processLength)>dataDims[0]){
             int tmpLen=(int)dataDims[0]-instart-1;
             inData=new double[tmpLen][sampleSize];
             inEnd=tmpLen-1;
        }
        System.out.println("before data read :"+instart+":"+inData.length+"x"+sampleSize);
        inData=convertToDoubleArray(this.readRows(mainDS, instart, inData.length),inData.length,sampleSize);
        System.out.println("data read");
        int outstart=0;
        int outLoc=0;
        if(sortedIncludeList.length<processLength){
            outData=new double[sortedIncludeList.length][sampleSize];
        }
        
        
        //rewrite sorted probeset list since data will be in this order.
        if(this.datasetExists(this.DATASET_FILTER_PROBESET, cur)){
                this.deleteDataset(this.DATASET_FILTER_PROBESET,cur);
        }
        long[] dim={sortedIncludeList.length};
        h5FFile.createLongDataSet(dim,this.DATASET_FILTER_PROBESET,cur,sortedIncludeList,true);
        
        //this.writeFilteredProbeList(sortedIncludeList, curDate, curTime);
        int cacheMiss=0;
        for(int i=0;i<sortedIncludeList.length;i++){
            //System.out.println("for"+i);
            if(i>0&&(i%processLength)==0){
                //write outData
                this.writeFilterAvgDataPart(outData, outstart, outData.length, curDate,curTime);
                //reset outVars
                outLoc=0;
                if((outstart+(2*processLength))>sortedIncludeList.length){
                    outstart=outstart+processLength;
                    int tmpLen=sortedIncludeList.length-outstart;
                    System.out.println("output dim:"+tmpLen+":"+outstart);
                    outData=new double[tmpLen][sampleSize];
                }else{
                    System.out.println("output dim:"+processLength+":"+outstart);
                    outstart=outstart+processLength;
                }
            }
            int ind=Integer.parseInt(probesHT.get(sortedIncludeList[i]).toString());
            if(ind>=instart&&ind<=inEnd){
                outData[outLoc]=inData[ind-instart];
                cacheMiss=0;
            }else{
                cacheMiss++;
                outData[outLoc]=(double[])this.readRow(mainDS, ind);
            }
            if (cacheMiss > 10) {
                if ((instart + (2 * processLength)) > dataDims[0]) {
                    instart = instart + processLength;
                    int tmpLen = (int) dataDims[0] - instart;
                    inData = new double[tmpLen][sampleSize];
                    inEnd = instart + tmpLen;
                } else {
                    instart = instart + processLength;
                    inEnd = instart + processLength-1;
                }
                System.out.println("before data read :" + instart +":"+inEnd+ ":" + inData.length + "x" + sampleSize);
                inData = convertToDoubleArray(this.readRows(mainDS, instart, inData.length), inData.length, sampleSize);
            }
            outLoc++;
        }
        if(outLoc>0){
            this.writeFilterAvgDataPart(outData, outstart, outData.length, curDate,curTime);
        }
        System.out.println("end writeFilteredData()");
    }
    
    
    public Object readRow(Dataset ds,long row) throws Exception{
        return readRows(ds,row,1);
    }
    public Object readRows(Dataset ds, long beginRow, long length) throws Exception{
        ds.clearData();
        long[] dims=ds.getDims();
        //System.out.println("read begin:"+beginRow+":"+length+":"+dims[0]+":"+dims[1]);
        long[] selected = ds.getSelectedDims(); // the selected size of the dataet
        long[] start = ds.getStartDims(); // the off set of the selection
        long[] stride = ds.getStride(); // the stride of the dataset
        selected[0]=length;
        start[0]=beginRow;
        stride[0]=1;
        return ds.getData();
    }

    private double[][] convertToDoubleArray(Object readRows, int readLength, int samples) {
        double[] tmp=(double[])readRows;
        double[][] ret=new double[readLength][samples];
        int max=readLength*samples;
        for(int i=0;i<max;i++){
            int row=i/samples;
            int col=i%samples;
            ret[row][col]=tmp[i];
        }
        return ret;
    }

    /*public void setFilterAttributeBool(String notYetCreated, boolean b,String curDate,String curTime) throws Exception {
        Group cur=this.openFilterTime(curDate, curTime);
        h5FFile.writeAttributeGroupBool(cur, notYetCreated, b);
    }*/
    
    public void copyVerTo(String curversion,PhenoGen_HDF5_File dest)throws Exception{
        if(curversion==version){
            if (dest.isOpen() && !dest.versionExists(curversion)) {
                dest.createVersion(curversion);
            }
            copyDABGPerc(dest,"/"+curversion+"/");
            copyGrouping(dest,"/"+curversion+"/");
            copyProbeset(dest,"/"+curversion+"/");
            copySamples(dest,"/"+curversion+"/");
            copyDABG(dest);
            this.clearMemory(curversion);
            dest.clearMemory(curversion);
            copyData(dest);
        }
    }
    
    
    private void copyDABG(PhenoGen_HDF5_File dest)throws Exception{
        Dataset dabgPval=this.openDataset(DATASET_MAIN_DABGPVAL);
        dabgPval.init();
        long[] dims=dabgPval.getDims();
        int probeLen=(int)dims[0];
        int sampleLen=(int)dims[1];
        int processLen=50000;
        if(dims[0]<=processLen){
            double[][] dabg=convertToDoubleArray(readRows(dabgPval,0,probeLen),probeLen,sampleLen);
            dest.writeDABGPval(dabg);
        }else{
            long start=0;
            long length=processLen;
            int ilength=processLen;
            while(start<probeLen){
                if((start+processLen)>probeLen){
                    length=probeLen-start-1;
                    ilength=(int)length;
                }
                double[][] tmp=convertToDoubleArray(readRows(dabgPval,start,length),ilength,sampleLen);
                dest.writeDABGPvalPart(tmp,start,ilength);
                System.out.println("DABG Wrote "+start+" to "+(start+ilength));
                start=start+processLen;
            }
        }
    }
    
    private void copyData(PhenoGen_HDF5_File dest)throws Exception{
        Dataset data=this.openDataset(DATASET_MAIN_DATA);
        data.init();
        long[] dims=data.getDims();
        int probeLen=(int)dims[0];
        int sampleLen=(int)dims[1];
        int processLen=50000;
        if(dims[0]<=processLen){
            double[][] datad=convertToDoubleArray(readRows(data,0,probeLen),probeLen,sampleLen);
            dest.writeAvgData(datad,DATASET_MAIN_DATA);
        }else{
            long start=0;
            long length=processLen;
            int ilength=processLen;
            while(start<probeLen){
                if((start+processLen)>probeLen){
                    length=probeLen-start;
                    ilength=(int)length;
                }
                double[][] tmp=convertToDoubleArray(readRows(data,start,length),ilength,sampleLen);
                dest.writeAvgDataPart(tmp,start,ilength,DATASET_MAIN_DATA);
                System.out.println("DATA Wrote "+start+" to "+(start+ilength));
                start=start+processLen;
            }
        }
    }
    
    private void copyProbeset(PhenoGen_HDF5_File dest,String path)throws Exception{
        long[] ps=this.readProbeset(DATASET_MAIN_PROBESET, path);
        System.out.println("read Probeset:"+ps.length);
        dest.writeProbeList(ps, DATASET_MAIN_PROBESET);
        System.out.println("wrote Probeset");
    }
    
    private void copyDABGPerc(PhenoGen_HDF5_File dest,String path)throws Exception {
        double[] ps=this.readDABGPerc(DATASET_MAIN_DABGPERC, path);
        System.out.println("read DABGPerc:"+ps.length);
        dest.writeDABGPerc(ps);
        System.out.println("wrote DABGPerc");
    }
    private void copyGrouping(PhenoGen_HDF5_File dest,String path)throws Exception {
        int[] ps=this.readGrouping(DATASET_MAIN_GROUPING, path);
        System.out.println("read Grouping:"+ps.length);
        dest.writeGrouping(ps);
        System.out.println("wrote Grouping");
    }
    private void copySamples(PhenoGen_HDF5_File dest,String path)throws Exception {
        String[] ps=this.readSamples(DATASET_MAIN_SAMPLES, path);
        System.out.println("read Samples:"+ps.length);
        dest.writeSampleList(ps);
        System.out.println("wrote Samples");
    }
    
    public void outputCSV(String version,String outputFile)throws Exception{
        try{
            BufferedWriter out=new BufferedWriter(new FileWriter(new File(outputFile)));
            //DataOutputStream out=new DataOutputStream(new FileOutputStream(new File(outputFile)));
            Dataset data=this.openDataset(DATASET_MAIN_DATA);
            data.init();
            long[] dims=data.getDims();
            int probeLen=(int)dims[0];
            int sampleLen=(int)dims[1];
            Dataset dabg=this.openDataset(DATASET_MAIN_DABGPVAL);
            data.init();
            this.openVersion(version);
            String header="ProbeSetID";
            String[] sampleNames=this.readSamples(this.DATASET_MAIN_SAMPLES, this.getPathDS(DATASET_MAIN_SAMPLES));
            for(int i=0;i<sampleLen;i++){
                header=header+","+sampleNames[i]+","+sampleNames[i];
            }
            out.write(header+"\n");
            //long[] probeNames=this.readProbeset(this.DATASET_MAIN_PROBESET, this.getPathDS(DATASET_MAIN_PROBESET));
            int processLen=50000;
            if(probeLen<processLen){
                double[][] tmpData=convertToDoubleArray(readRows(data,0,probeLen),probeLen,sampleLen);
                double[][] tmpDabg=convertToDoubleArray(readRows(dabg,0,probeLen),probeLen,sampleLen);
                long[] probeNames=this.readProbesetPart(this.DATASET_MAIN_PROBESET,this.getPathDS(DATASET_MAIN_PROBESET),0,probeLen);
                //StringBuilder sb=new StringBuilder();
                for(int j=0;j<tmpData.length;j++){
                    out.write(Long.toString(probeNames[j]));
                    for(int k=0;k<sampleLen;k++){
                        String pa=",P";
                        if(tmpDabg[j][k]>=0.0001){
                            pa=",A";
                        }
                        out.write(","+tmpData[j][k]+pa);
                    }
                    out.write("\n");
                    /*if(j%5000==0){
                        out.writeBytes(sb.toString());
                        sb=new StringBuilder();
                    }*/
                }
                /*if(sb.length()>0){
                    out.writeBytes(sb.toString());
                }*/
            }else{
                long start=0;
                long length=processLen;
                int ilength=processLen;
                while(start<probeLen){
                    if((start+processLen)>probeLen){
                        length=probeLen-start-1;
                        ilength=(int)length;
                    }
                    double[][] tmpData=convertToDoubleArray(readRows(data,start,length),ilength,sampleLen);
                    double[][] tmpDabg=convertToDoubleArray(readRows(dabg,start,length),ilength,sampleLen);
                    long[] probeNames=this.readProbesetPart(this.DATASET_MAIN_PROBESET,this.getPathDS(DATASET_MAIN_PROBESET),start,length);
                    //StringBuilder sb=new StringBuilder();
                    for(int j=0;j<tmpData.length;j++){
                        out.write(Long.toString(probeNames[j]));
                        for(int k=0;k<sampleLen;k++){
                            String pa=",P";
                            if(tmpDabg[j][k]>0.00001){
                                pa=",A";
                            }
                            out.write(","+tmpData[j][k]+pa);
                        }
                        out.write("\n");
                    }
                    start=start+processLen;
                }
            }
            out.flush();
            out.close();
        }catch(Exception e){
            e.printStackTrace(System.out);
            throw e;
        }
    }
}
