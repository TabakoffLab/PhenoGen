<%--
 *  Author: Spencer Mahaffey
 *  Created: August, 2012
 *  Description:  
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% 	//extrasList.add("jquery-ui-1.8.23.min.js");
	//extrasList.add("/smoothness/jquery-ui.1.11.3.min.css");
	extrasList.add("normalize.css");
	extrasList.add("index.css"); 

%>
<%pageTitle="Demonstrations";%>

<%@ include file="/web/common/header_noBorder.jsp" %>

<%
	Demo demo=new Demo();
	ArrayList<String> categories=demo.getAllDemoCategories(dbConn);
	HashMap demoHashMap=demo.getAllDemos(dbConn);
	Demo defaultVideo=null;
	for(int i=0;i<categories.size()&&defaultVideo==null;i++){
		ArrayList<Demo> demoList=(ArrayList<Demo>)demoHashMap.get(categories.get(i));
		for(int j=0;j<demoList.size();j++){
			Demo curDemo=demoList.get(j);
			if(curDemo.isDefaultVideo()){
				defaultVideo=curDemo;
			}
		}
	}
%>
<style>
    .ui-accordion .ui-accordion-content{
        padding: 0.5em 0.5em;
    }
</style>
<script type="text/javascript">
    $("#wait1").hide();
</script>
    <h2>Demonstrations</h2>
    <table>
        <TR><TD>
            <div id="accordion" style="width:340px;  display:inline-block;height: 100%;">
                <%for(int i=0;i<categories.size();i++){
                                ArrayList<Demo> demoList=(ArrayList<Demo>)demoHashMap.get(categories.get(i));
                                %>
                    <h3><%=categories.get(i)%></h3>
                    <div style="text-align:left;">
                        <table name="items" class="list_base" style="text-align:left; width:100%;">
                            <thead><TR class="col_title" >
                                <TH>Title</TH>
                                <TH>Duration</TH>
                                <TH>Description</TH>
                            </TR>
                            </thead>
                                <%for(int j=0;j<demoList.size();j++){
                                                        Demo curDemo=demoList.get(j);%>
                                <TR id="<%=curDemo.getFileBase()+":::"+curDemo.getTitle()+" ("+curDemo.getTime()+")"+":::"+curDemo.getDescription()%>">
                                    <TD class="<%if(curDemo==defaultVideo){%>selected<%}%>"><%=curDemo.getTitle()%></TD>
                                    <TD class="<%if(curDemo==defaultVideo){%>selected<%}%>"><%=curDemo.getTime()%></TD>
                                    <TD class="<%if(curDemo==defaultVideo){%>selected<%}%>"><%=curDemo.getDescription()%></TD>
                                </TR>
                            <%}%>
                        </table>
                    </div>
                <%}%>
            </div>
            </TD>
            <TD>
                    <div id="leftDiv" style="display:inline-block;width:620px;">
                        <div id="videoTitle" style="display:inline-block; text-align:center; width:100%;">
                            <%=defaultVideo.getTitle()+" ("+defaultVideo.getTime()+")"%>
                        </div><BR />
                        <div id="videoDiv" style="display:inline-block;">
                                                            <video id="video" width="640" height="480" controls="controls" autoplay="true">
                                            <source id="videoWebm" src="<%=defaultVideo.getFileBase()%>.webm" type="video/webm">
                                                                    <source id="videoMp4" src="<%=defaultVideo.getFileBase()%>.mp4" type="video/mp4">
                                              <object id="videoObj" data="<%=defaultVideo.getFileBase()%>.mp4" width="320" height="240">
                                              </object>
                                            </video> 
                                            <!--<div id="description" style="width:640px; height:200px; overflow:auto;">
                                                    Description of the above video.
                                            </div>-->
                            </div><BR />
                        <div id="videoDesc" style="display:inline-block;">
                            <%=defaultVideo.getDescription()%>
                        </div>
                        <BR>
                        <a id="largerView" href="" target="_blank">Larger View</a>
                        </span>
                    </div>
            </TD>
        </TR>
    </table>
    

    

	

<script type="text/javascript">
$(document).ready(function() {
	
	$( "#accordion" ).accordion({heightStyle: "fill"});
	
	var tableRows = getRows();
	hoverRows(tableRows);
	tableRows.each(function(){
		//---> click functionality
		$(this).find("td").click( function() {
			tableRows.find("td").removeClass('selected');
			$(this).parent("tr").find("td").addClass('selected');
			var full = $(this).parent("tr").attr("id");
			var list=full.split(":::");
			$('#videoDiv').html("<video id=\"video\" width=\"640\" height=\"480\" controls=\"controls\" autoplay=\"true\"><source id=\"videoWebm\" src=\""+list[0]+".webm\" type=\"video/webm\"><source id=\"videoMp4\" src=\""+list[0]+".mp4\" type=\"video/mp4\"><object id=\"videoObj\" data=\""+list[0]+".mp4\" width=\"320\" height=\"240\"></object></video>");
			$('#videoTitle').html(list[1]);
			$('#videoDesc').html(list[2]);
			$('#video').load();
                        $('#largerView').attr("href","<%=webDir%>demo/largerDemo.jsp?demoPath=<%=webDir%>demo/"+list[0]);
			return false;
		});

		
	});
});
</script>

	
<%@ include file="/web/common/footer.jsp" %>
