function SetupAnonSession(){
    that={}
    that.setupSession=function (pageSetup){
        that.pageSetup=pageSetup;
        that.local=that.testLocalStorage();
        that.setupUUID();
    };
    that.setupUUID=function(){
        var uuid=that.checkUUID();
        console.log("cur UUID:"+uuid);
        $('#createGeneList').hide();
        $('#linkEmail').hide();
        if(typeof uuid ==="string" && uuid.length>0){
            that.UUID=uuid;
            that.setupAnonUserSession();
            
        }else{
            that.getNewUUID();
        }
    };
    that.setupAnonUserSession=function(){
        console.log("request session:"+that.UUID);
        $.ajax({
            url: contextRoot+"web/access/setupSessionUUID.jsp",
            type: 'GET',
            cache: false,
            data: { uuid:that.UUID },
            dataType: 'json',
            success: function(data2){
                that.pageSetup();
                $('#createGeneList').show();
                $('#linkEmail').show();
            },
            error: function(xhr, status, error) {
                console.log("ERROR:"+error);
                setTimeout(that.setupUUID,2000);
            }
        });
    };
    that.getNewUUID=function(){
        $.ajax({
            url: contextRoot+"web/access/generateUUID.jsp",
            type: 'GET',
            cache: false,
            data: {},
            dataType: 'json',
            success: function(data2){
                var uuid=JSON.stringify(data2.uuid);
                that.UUID=uuid;
                that.saveUUID();
                that.pageSetup();
                $('#createGeneList').show();
                $('#linkEmail').show();
            },
            error: function(xhr, status, error) {
                console.log("ERROR:"+error);
                setTimeout(that.getNewUUID,2000);
            }
        });
    };
    that.saveUUID=function(){
        if(that.local){
            localStorage.setItem("phenogenAnonUUID",that.UUID);
        }else{
            $.cookie("phenogenAnonUUID",that.UUID);
        }
    };
    that.checkUUID=function(){
        var uuid="";
        if(that.local && localStorage.getItem("phenogenAnonUUID")!==null){
            uuid=localStorage.getItem("phenogenAnonUUID").replace(/\"/g, "");
        }else if($.cookie("phenogenAnonUUID")){
            uuid=$.cookie("phenogenAnonUUID");
        }
        return uuid;
    };
    
    /*
     * Test for localStorage support in browser.
     */
    that.testLocalStorage=function (){
	   var test = 'test';
        try {
                localStorage.setItem(test, test);
                localStorage.removeItem(test);
                return true;
        } catch(e) {
                return false;
        }
    };
    
    return that;
};

