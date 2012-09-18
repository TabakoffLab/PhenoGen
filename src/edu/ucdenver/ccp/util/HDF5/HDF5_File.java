package edu.ucdenver.ccp.util.HDF5;


import java.lang.reflect.Array;
import ncsa.hdf.object.*;     // the common object package
import ncsa.hdf.object.h5.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;



public class HDF5_File extends ncsa.hdf.object.h5.H5File{
    private String path = "";
    private FileFormat fileFormat =
                    FileFormat.getFileFormat(FileFormat.FILE_TYPE_HDF5);
    private H5File h5FFile=null;
    private ArrayList<Group> openGroups=new ArrayList<Group>();
    private ArrayList<ncsa.hdf.object.Dataset> openDatasets=new ArrayList<ncsa.hdf.object.Dataset>();
    private boolean open=false;
    private Group root=null;
    private int compression=0;
    /*private int chunkSize=350000;
    private long[] chunk1dim={chunkSize};
    private long[] chunk2dim={chunkSize,0};*/
    
    

    public HDF5_File(String path,boolean eraseIfExists,int compression) throws Exception{
        this.path=path;
        this.compression=compression;
        try {
            if(eraseIfExists){
                h5FFile=(H5File) fileFormat.createFile(path,FileFormat.FILE_CREATE_DELETE);
            }else{
                h5FFile=(H5File) fileFormat.createFile(path,FileFormat.FILE_CREATE_OPEN);
            }
        } catch (Exception ex) {
            throw ex;
        }
        
    }
    public Group openRoot(){
        Group ret=null;
        if(open){
            root = (Group) ((javax.swing.tree.DefaultMutableTreeNode) h5FFile.getRootNode()).getUserObject();
            //System.out.println("Opened Root"+root);
            openGroups.add(root);
        }
        return root;
    }
    public boolean openFile() throws Exception {
        if(h5FFile!=null){
            int FID=h5FFile.open();
            if(FID>-1){
                open=true;
                root = (Group) ((javax.swing.tree.DefaultMutableTreeNode) h5FFile.getRootNode()).getUserObject();
                //System.out.println("Opened Root"+root);
                openGroups.add(root);
                
            }
        }
        return open;
    }

    public boolean isOpen(){
        return open;
    }
    
    public Group getRoot(){
        return root;
    }
    
    public Group createGroup(String groupName,Group root) throws Exception{
        Group ret=null;
        
            ret = h5FFile.createGroup(groupName, root);
        if(ret!=null){
            openGroups.add(ret);
        }
        return ret;
    }
    public Group openGroupUnderRoot(String name) throws Exception{
        Group ret=null;
        root.getNumberOfMembersInFile();
        List<HObject> list=root.getMemberList();
        for(int i=0;i<list.size()&&ret==null;i++){
            if(list.get(i).getName().equals(name)){
                ret=(Group)list.get(i);
            }
        }
        ret.open();
        
        if(ret!=null){
            openGroups.add(ret);
            //System.out.println("openGroup():"+path+name);
        }else{
            System.out.println("Failed to open "+path+name);
        }
        return ret;
    }
    public Group openGroup(String name, String path,Group parent) throws Exception{
        Group ret=null;
            ret=new H5Group(h5FFile,name,path,parent);
            ret.open();
        if(ret!=null){
            openGroups.add(ret);
            //System.out.println("openGroup():"+path+name);
        }else{
            System.out.println("Failed to open "+path+name);
        }
        return ret;
    }
    
    public Dataset openDataset(String name, String path) throws Exception{
       Dataset ret=null;
       ret=getDatasetIfOpen(name,path);
       if(ret==null){
            ret=new H5ScalarDS(h5FFile,name,path);
            if(ret!=null){
                ret.open();
                ret.init();
                this.openDatasets.add(ret);
            }
       }
        return ret;
    }
    
    public Dataset getDatasetIfOpen(String name,String path){
        Dataset ret=null;
        for(int i=0;i<this.openDatasets.size()&&ret==null;i++){
            Dataset test=openDatasets.get(i);
            if(test.getName().equals(name)&&test.getPath().equals(path)){
                ret=test;
            }
        }
        return ret;
    }
    
    public void closeDataset(Dataset data){
        for(int i=0;i<this.openDatasets.size();i++){
            if(data.equals(openDatasets.get(i))){
                data.close(data.getFID());
                openDatasets.remove(data);
            }
        }
    }
    
    public Dataset createDoubleDataSet(long[] dims,String dsName,Group dsGroup,double[][] data,boolean autoClose) throws Exception{
        return this.createDoubleDataSet(dims, dsName, dsGroup, data, autoClose,null);
    }
    
    public Dataset createDoubleDataSet(long[] dims,String dsName,Group dsGroup,double[][] data,boolean autoClose,long[] maxDims) throws Exception{
        Dataset cData = null;
        Datatype doubleType = h5FFile.createDatatype(Datatype.CLASS_FLOAT, 8, Datatype.NATIVE, Datatype.NATIVE);
        long[] chunk2dim={data.length,data[0].length};
        cData = h5FFile.createScalarDS(dsName, dsGroup, doubleType, dims, maxDims, chunk2dim, compression, data);
        if (cData != null && autoClose) {
            cData.write();
            cData.close(cData.getFID());
            cData = null;
        } else if (cData != null) {
            openDatasets.add(cData);
        } else {
            throw new Exception();
        }

        return cData;
    }
    
    public Dataset createIntDataSet(long[] dims,String dsName,Group dsGroup,int[][] data,boolean autoClose) throws Exception{
        Dataset cData = null;
        Datatype intType = h5FFile.createDatatype(Datatype.CLASS_INTEGER, 4, Datatype.NATIVE, Datatype.NATIVE);
        long[] chunk2dim={data.length,data[0].length};
        cData = h5FFile.createScalarDS(dsName, dsGroup, intType, dims, null, chunk2dim, compression, data);
        if (cData != null && autoClose) {
            cData.write();
            cData.close(cData.getFID());
            cData = null;
        } else if (cData != null) {
            openDatasets.add(cData);
        } else {
            throw new Exception();
        }
        return cData;
    }
    
    public Dataset createStringDataSet(long[] dims,String dsName,Group dsGroup,String[][] data,int len,boolean autoClose) throws Exception{
        Dataset cData=null;
        Datatype stringType = h5FFile.createDatatype(Datatype.CLASS_STRING, len, Datatype.NATIVE, Datatype.NATIVE);
        long[] chunk2dim={data.length,data[0].length};
        cData = h5FFile.createScalarDS(dsName, dsGroup, stringType, dims, null, chunk2dim, compression, data);
        if (cData != null && autoClose) {
            cData.write();
            cData.close(cData.getFID());
            cData = null;
        } else if (cData != null) {
            openDatasets.add(cData);
        } else {
            throw new Exception();
        }
        return cData;
    }
    
    public Dataset createDoubleDataSet(long[] dims,String dsName,Group dsGroup,double[] data,boolean autoClose) throws Exception{
        return this.createDoubleDataSet(dims, dsName, dsGroup, data, autoClose, null);
    }
    
    public Dataset createDoubleDataSet(long[] dims,String dsName,Group dsGroup,double[] data,boolean autoClose,long[] maxDim) throws Exception{
        Dataset cData = null;
        Datatype doubleType = h5FFile.createDatatype(Datatype.CLASS_FLOAT, 8, Datatype.NATIVE, Datatype.NATIVE);
        long[] chunk = {data.length};
        cData = h5FFile.createScalarDS(dsName, dsGroup, doubleType, dims, maxDim, chunk, compression, data);
        if (cData != null && autoClose) {
            cData.write();
            cData.close(cData.getFID());
            cData = null;
        } else if (cData != null) {
            openDatasets.add(cData);
        } else {
            throw new Exception();
        }
        return cData;
    }
    
    public Dataset createIntDataSet(long[] dims,String dsName,Group dsGroup,int[] data,boolean autoClose) throws Exception{
        return this.createIntDataSet(dims, dsName, dsGroup, data, autoClose, null);
    }
    
    public Dataset createIntDataSet(long[] dims,String dsName,Group dsGroup,int[] data,boolean autoClose,long[] maxDim) throws Exception{
        Dataset cData = null;
        Datatype intType = h5FFile.createDatatype(Datatype.CLASS_INTEGER, 4, Datatype.NATIVE, Datatype.NATIVE);
        
            long[] chunk={data.length};
            cData = h5FFile.createScalarDS(dsName, dsGroup, intType, dims, maxDim, chunk, compression, data);
        
        if (cData != null && autoClose) {
            cData.write();
            cData.close(cData.getFID());
            cData = null;
        } else if (cData != null) {
            openDatasets.add(cData);
        } else {
            throw new Exception();
        }
        return cData;
    }
    
    /*public Dataset createSmallIntDataSet(long[] dims,String dsName,Group dsGroup,int[] data,boolean autoClose) throws Exception{
        Dataset cData = null;
        Datatype intType = h5FFile.createDatatype(Datatype.CLASS_INTEGER, 1, Datatype.NATIVE, Datatype.NATIVE);
            long[] chunk={data.length};
            cData = h5FFile.createScalarDS(dsName, dsGroup, intType, dims, null, chunk, compression, data);
        
        if (cData != null && autoClose) {
            cData.write();
            cData.close(cData.getFID());
            cData = null;
        } else if (cData != null) {
            openDatasets.add(cData);
        } else {
            throw new Exception();
        }
        return cData;
    }*/
    
    
    public Dataset createLongDataSet(long[] dims,String dsName,Group dsGroup,long[] data,boolean autoClose) throws Exception{
        
        return this.createLongDataSet(dims, dsName, dsGroup, data, autoClose, null);
    }
    
    public Dataset createLongDataSet(long[] dims,String dsName,Group dsGroup,long[] data,boolean autoClose,long[] maxDim) throws Exception{
        System.out.println("CREATE LONG DS:\ndims:"+dims[0]+"\n DS NAME"+dsName+"\n Data len:"+data.length+"\n DS Group:"+dsGroup);
        Dataset cData = null;
        Datatype intType = h5FFile.createDatatype(Datatype.CLASS_INTEGER, 8, Datatype.NATIVE, Datatype.NATIVE);
        System.out.println("after create datatype");
        long[] chunk={data.length};
        System.out.println("Before create scalar DS");
        cData = h5FFile.createScalarDS(dsName, dsGroup, intType, dims, maxDim, chunk, compression, data);
        System.out.println("after create scalar DS");
        if (cData != null && autoClose) {
            cData.write();
            cData.close(cData.getFID());
            cData = null;
        } else if (cData != null) {
            openDatasets.add(cData);
        } else {
            throw new Exception();
        }
        return cData;
    }
    
    public Dataset createStringDataSet(long[] dims,String dsName,Group dsGroup,String[] data,int len,boolean autoClose) throws Exception{
        Dataset cData=null;
        Datatype stringType = h5FFile.createDatatype(Datatype.CLASS_STRING, len, Datatype.NATIVE, Datatype.NATIVE);
            long[] chunk={data.length};
            
            cData = h5FFile.createScalarDS(dsName, dsGroup, stringType, dims, null, chunk, compression, data);
        
        if (cData != null && autoClose) {
            cData.write();
            cData.close(cData.getFID());
            cData = null;
        } else if (cData != null) {
            openDatasets.add(cData);
        } else {
            throw new Exception();
        }
        return cData;
    }
    
    public void closeAllOpenDatasets() {
        while(!openDatasets.isEmpty()){
            ncsa.hdf.object.Dataset toClose=openDatasets.get(0);
            openDatasets.remove(0);
            try{
                toClose.close(toClose.getFID());
            }catch(Exception e){
                
            }
            
        }
    }
    
    public void closeAllOpenGroups() {
        while(!openGroups.isEmpty()){
            ncsa.hdf.object.Group toClose=openGroups.get(0);
            openGroups.remove(0);
            try{
                toClose.close(toClose.getFID());
            }catch(Exception e){
                
            }
        }
    }
    
    public void closeFile() throws Exception {
        h5FFile.close();
        open=false;
    }
    
    public void closeAll() throws Exception {
        closeAllOpenDatasets();
        closeAllOpenGroups();
        closeFile();
    }
    
    public void clearMemory(){
        closeAllOpenDatasets();
        closeAllOpenGroups();
        System.gc();
    }
    
    public void deleteGroup(Group g) throws Exception{
        if(g!=null){
            h5FFile.delete(g);
        }
    }
    
    public void deleteDataset(Dataset d) throws Exception{
        this.closeDataset(d);
        h5FFile.delete(d);
    }
    
    public boolean datasetExists(String name,Group g){
        boolean ret=false;
        List<HObject> tmp=g.getMemberList();
        for(int i=0;i<tmp.size()&&!ret;i++){
            if(tmp.get(i).getName().equals(name)){
                ret=true;
            }
        }
        return ret;
    }
    
    /*public void writeAttribute(Dataset d){
        d.writeMetadata(d);
    }*/
    public void addToIntDataset(String name,String path,long beginRow,long length,int[] probelist)throws Exception{
        //System.out.println(name+":"+path);
            H5ScalarDS cur=(H5ScalarDS) this.openDataset(name, path);
            int openvalue=cur.open();
            
            //System.out.println("open result:"+openvalue);
            cur.getMetadata();//Required because of a bug where dimensions will not be properly initiallized in H5 objects
            //long[] curDims=cur.getDims();
            //for(int i=0;i<curDims.length;i++){
            //    System.out.println(i+":"+curDims[i]);
            //}
            
            long[] newDim={beginRow+length};
            //System.out.println("NEW DIM:"+newDim[0]);
            cur.extend(newDim);
            int rank = cur.getRank(); // number of dimension of the dataset
            long[] dims = cur.getDims(); // the dimension sizes of the dataset
            long[] selected = cur.getSelectedDims(); // the selected size of the dataet
            long[] start = cur.getStartDims(); // the off set of the selection
            long[] stride = cur.getStride(); // the stride of the dataset
            //System.out.println("selected length"+selected.length);
            selected[0]=length;
            start[0]=beginRow;
            stride[0]=1;
            int[] tmp=(int[])cur.getData();
            for(int i=0;i<length;i++){
                tmp[i]=probelist[i];
            }
            cur.write(tmp);
            this.closeDataset(cur);
    }
    
    public void addToLongDataset(String name,String path,long beginRow,long length,long[] probelist)throws Exception{
        //System.out.println(name+":"+path);
            H5ScalarDS cur=(H5ScalarDS) this.openDataset(name, path);
            int openvalue=cur.open();
            
            //System.out.println("open result:"+openvalue);
            cur.getMetadata();//Required because of a bug where dimensions will not be properly initiallized in H5 objects
            //long[] curDims=cur.getDims();
            //for(int i=0;i<curDims.length;i++){
            //    System.out.println(i+":"+curDims[i]);
            //}
            
            long[] newDim={beginRow+length};
            //System.out.println("NEW DIM:"+newDim[0]);
            cur.extend(newDim);
            int rank = cur.getRank(); // number of dimension of the dataset
            long[] dims = cur.getDims(); // the dimension sizes of the dataset
            long[] selected = cur.getSelectedDims(); // the selected size of the dataet
            long[] start = cur.getStartDims(); // the off set of the selection
            long[] stride = cur.getStride(); // the stride of the dataset
            //System.out.println("selected length"+selected.length);
            selected[0]=length;
            start[0]=beginRow;
            stride[0]=1;
            long[] tmp=(long[])cur.getData();
            for(int i=0;i<length;i++){
                tmp[i]=probelist[i];
            }
            cur.write(tmp);
            this.closeDataset(cur);
    }
    
    public void addToDoubleDataset(String name,String path,long beginRow,long length,double[][] data)throws Exception{
        int samples=data[0].length;
            H5ScalarDS cur=(H5ScalarDS) this.openDataset(name, path);
            int openvalue=cur.open();
            cur.getMetadata();//Required because of a bug where dimensions will not be properly initiallized in Dataset objects
            long[] newDim={beginRow+length,samples};
            cur.extend(newDim);
            //System.out.println("New Dim:"+newDim[0]+":"+newDim[1]);
            int rank = cur.getRank(); // number of dimension of the dataset
            long[] dims = cur.getDims(); // the dimension sizes of the dataset
            long[] selected = cur.getSelectedDims(); // the selected size of the dataet
            long[] start = cur.getStartDims(); // the off set of the selection
            long[] stride = cur.getStride(); // the stride of the dataset
            selected[0]=length;
            start[0]=beginRow;
            stride[0]=1;
            double[] tmp=(double[])cur.getData();
            //System.out.println(beginRow+":"+length+":"+tmp.length+":"+tmp.length/samples);
            long max=length*samples;
            for(int i=0;i<max;i++){
                int row=i/samples;
                int col=i%samples;
                tmp[i]=data[row][col];
            }
            cur.write(tmp);
            this.closeDataset(cur);
    }
    public void addToDoubleDataset(String name,String path,long beginRow,long length,double[] data)throws Exception{
        //System.out.println(name+":"+path);
            H5ScalarDS cur=(H5ScalarDS) this.openDataset(name, path);
            int openvalue=cur.open();
            
            //System.out.println("open result:"+openvalue);
            cur.getMetadata();//Required because of a bug where dimensions will not be properly initiallized in H5 objects
            /*long[] curDims=cur.getDims();
            for(int i=0;i<curDims.length;i++){
                System.out.println(i+":"+curDims[i]);
            }
            */
            long[] newDim={beginRow+length};
            //System.out.println("NEW DIM:"+newDim[0]);
            cur.extend(newDim);
            int rank = cur.getRank(); // number of dimension of the dataset
            long[] dims = cur.getDims(); // the dimension sizes of the dataset
            long[] selected = cur.getSelectedDims(); // the selected size of the dataet
            long[] start = cur.getStartDims(); // the off set of the selection
            long[] stride = cur.getStride(); // the stride of the dataset
            //System.out.println("selected length"+selected.length);
            selected[0]=length;
            start[0]=beginRow;
            stride[0]=1;
            double[] tmp=(double[])cur.getData();
            for(int i=0;i<length;i++){
                tmp[i]=data[i];
            }
            cur.write(tmp);
            this.closeDataset(cur);
    }
    public void copyDataSet(String srcname,String srcpath,Group dstgroup,String dstname)throws Exception{
        H5ScalarDS cur=(H5ScalarDS) this.openDataset(srcname, srcpath);
        int openvalue=cur.open();
        cur.getMetadata();
        long[] dims=cur.getDims();
        cur.copy(dstgroup, dstname, dims, cur.getData());
    }
    public int[] readIntDataset(String name,String path) throws Exception{
        //System.out.println("Open:"+path+name);
        int[] ret=null;
        H5ScalarDS cur=(H5ScalarDS) this.openDataset(name, path);
        int openval=cur.open();
        //System.out.println("OpenVal"+openval);
        cur.init();
        long[] dims = cur.getDims(); // the dimension sizes of the dataset
        long[] selected = cur.getSelectedDims(); // the selected size of the dataet
        long[] start = cur.getStartDims(); // the off set of the selection
        long[] stride = cur.getStride();
        selected[0]=dims[0];
        start[0]=0;
        stride[0]=1;
        int[] read=(int[])cur.read();
        ret=read;
        this.closeDataset(cur);
        return ret;
    }
    public long[] readLongDataset(String name,String path) throws Exception{
        //System.out.println("Open:"+path+name);
        long[] ret=null;
        H5ScalarDS cur=(H5ScalarDS) this.openDataset(name, path);
        int openval=cur.open();
        //System.out.println("OpenVal"+openval);
        cur.init();
        long[] dims = cur.getDims(); // the dimension sizes of the dataset
        long[] selected = cur.getSelectedDims(); // the selected size of the dataet
        long[] start = cur.getStartDims(); // the off set of the selection
        long[] stride = cur.getStride();
        selected[0]=dims[0];
        start[0]=0;
        stride[0]=1;
        long[] read=(long[])cur.read();
        ret=read;
        this.closeDataset(cur);
        return ret;
    }
    public long[] readLongDatasetPart(String name,String path,long beginRow,long length) throws Exception{
        long[] ret=null;
        H5ScalarDS cur=(H5ScalarDS) this.openDataset(name, path);
        cur.init();//Required because of a bug where dimensions will not be properly initiallized in H5 objects
        long[] selected = cur.getSelectedDims(); // the selected size of the dataet
        long[] start = cur.getStartDims(); // the off set of the selection
        long[] stride = cur.getStride(); // the stride of the dataset
        selected[0]=length;
        start[0]=beginRow;
        stride[0]=1;
        long[] read=(long[])cur.read();
        ret=read;
        this.closeDataset(cur);
        return ret;
    }
    public double[] readDoubleDataset(String name,String path) throws Exception{
        //System.out.println("Open:"+path+name);
        double[] ret=null;
        H5ScalarDS cur=(H5ScalarDS) this.openDataset(name, path);
        int openval=cur.open();
        //System.out.println("OpenVal"+openval);
        cur.init();
        long[] dims = cur.getDims(); // the dimension sizes of the dataset
        long[] selected = cur.getSelectedDims(); // the selected size of the dataet
        long[] start = cur.getStartDims(); // the off set of the selection
        long[] stride = cur.getStride();
        selected[0]=dims[0];
        start[0]=0;
        stride[0]=1;
        double[] read=(double[])cur.read();
        ret=read;
        this.closeDataset(cur);
        return ret;
    }
    public String[] readStringDataset(String name,String path) throws Exception{
        //System.out.println("Open:"+path+name);
        String[] ret=null;
        H5ScalarDS cur=(H5ScalarDS) this.openDataset(name, path);
        int openval=cur.open();
        //System.out.println("OpenVal"+openval);
        cur.init();
        long[] dims = cur.getDims(); // the dimension sizes of the dataset
        long[] selected = cur.getSelectedDims(); // the selected size of the dataet
        long[] start = cur.getStartDims(); // the off set of the selection
        long[] stride = cur.getStride();
        selected[0]=dims[0];
        start[0]=0;
        stride[0]=1;
        String[] read=(String[])cur.read();
        ret=read;
        this.closeDataset(cur);
        return ret;
    }
    
    
    /*public void writeAttributeGroupBool(Group cur,String name,boolean value) throws Exception{
        boolean found=false;
        List tmp=cur.getMetadata();
        if(tmp==null){
            tmp=new ArrayList();
        }
        System.out.println("Metadata list size:"+tmp.size());
        for(int i=0;i<tmp.size()&&!found;i++){
            Attribute tmpObj=(Attribute)tmp.get(i);
            if(tmpObj.getName().equals(name)){
                System.out.println(tmpObj.getValue()+":"+tmpObj.getValue().getClass()+"***********************************************************************************************************************");
                int ivalue=0;
                if(value){
                    ivalue=1;
                }
                tmpObj.setValue(ivalue);
                cur.writeMetadata(tmp.toArray());
                found=true;
            }
        }
        if(!found){
            long[] dim=new long[1];
            dim[0]=1;
            Datatype intType = h5FFile.createDatatype(Datatype.CLASS_INTEGER, 4, Datatype.NATIVE, Datatype.NATIVE);
            int ivalue=0;
            if(value){
                ivalue=1;
            }
            Attribute[] newAtt={new Attribute(name,intType,dim,ivalue)};
            cur.writeMetadata(newAtt);
        }
    }*/
}
