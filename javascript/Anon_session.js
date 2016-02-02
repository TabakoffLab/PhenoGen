function SetupAnonSession(){
    that={}
    that.setupSession=function (pageSetup){
        that.pageSetup=pageSetup;
        that.local=that.testLocalStorage();
        that.setupUUID();
    };
    that.setupUUID=function(){
        var uuid=that.checkUUID();
        console.log(typeof uuid);
        if(typeof uuid ==="string" && uuid.length>0){
            that.UUID=uuid;
            alert("saved:"+that.UUID);
            that.pageSetup();
        }else{
            that.getNewUUID();
        }
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
                alert(uuid);
                that.UUID=uuid;
                that.saveUUID();
                that.pageSetup();
            },
            error: function(xhr, status, error) {
                console.log("ERROR:"+error);
                setTimeout(getNewUUID,2000);
            }
        });
    };
    that.saveUUID=function(){
        if(that.local){
            localStorage.setItem("phenogenAnonUUID",that.UUID);
        }else{
            $.cookie("phenogenAnonUUID",that.UUID);
        }
    }
    that.checkUUID=function(){
        var uuid="";
        if(that.local){
            uuid=localStorage.getItem("phenogenAnonUUID");
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

var PhenogenAnonSession=SetupAnonSession();