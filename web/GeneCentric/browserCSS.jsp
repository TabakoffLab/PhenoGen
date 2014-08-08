<style>
div.testToolTip {   
  position: absolute;           
  text-align: center;
  min-width: 100px;
  max-width: 455px;
  min-height:50px;                  
  /*height: 300px;   */              
  padding: 2px;             
  /*font: 12px sans-serif; */       
  background: #d3d3d3;   
  border: 0px;      
  border-radius: 8px;           
  pointer-events: none;    
  color:#000000;
  text-align:left;     
}
/*table.tooltipTable{
	background:#d3d3d3;
}*/

table.tooltipTable TD{
	background:#d3d3d3;
	text-align:center;
}

.axis path{
	fill:none;
	stroke:black;
	shape-rendering: crispEdges;
}

.tick{
	fill:black;
	stroke: black;
}

.grid .tick {
    stroke: lightgrey;
    opacity: 0.7;
}
/*.grid path {
      stroke-width: 0;
}*/
	div#collapsableReport li{
	color:#000000;
	cursor:pointer;
	}
	div#collapsableReport li.selected{
		background-color:#CCCCCC;
	}
	/*div#collapsableReport td.layout {
		border:1px solid #CECECE;
	}*/
	span.detailMenu,span.selectdetailMenu,span.viewMenu,span.viewDetailTab{
		border-color:#CCCCCC;
		border:solid;
		border-width: 1px 1px 0px 1px;
		border-radius:5px 5px 0px 0px;
		padding-top:2px;
		padding-bottom:2px;
		padding-left:15px;
		padding-right:15px;
		cursor:pointer;
	}
	span.viewMenu,span.viewDetailTab{
		border-color:#000000;
	}
	span.detailMenu{
		background-color:#0b61A4;
		border-color:#000000;
		
	}
	span.detailMenu.selected{
		background-color:#3f92d2;
		/*background:#86C3E2;*/
		color:#FFFFFF;
	}
	span.detailMenu:hover{
		background-color:#3f92d2;
		/*background:#86C3E2;*/
		color:#FFFFFF;
	}
	
	span.selectdetailMenu{
		background-color:#00992D;
		border-color:#000000;
		color:#FFFFFF;
	}
	span.selectdetailMenu.selected{
		background:#47c647;
	}
	span.selectdetailMenu:hover{
		background:#47c647;
	}
	
	span.viewMenu,span.viewDetailTab{
		background:#AEAEAE;
		color:#000000;
	}
	span.viewMenu.selected, span.viewDetailTab.selected{
		background:#DEDEDE;
		color:#000000;
	}
	span.viewMenu:hover,span.viewDetailTab:hover{
		background:#DEDEDE;
		color:#000000;
	}
	
	.regionSubHeader{
		background:#86C3E2;
		color:#FFFFFF;
	}
	table.geneFilter TH {
		background:#86C3E2;
		color:#FFFFFF;
	}
	rect.selected{
		fill:#00FF00;
	}
	.geneReport TD{
		vertical-align:top;
		margin-top: 10px;
	}
	.geneReport TD.header{
		background-color:#67E667;
		font-size:14px;
	}
	.geneReport.header{
		background-color:#67E667;
		font-size:14px;
		color:#000000;
	}
	div.functionBar{
		background:#FFFFFF;
	}
	div.defaultMouse{
		display:inline-block;
		height:24px;
		width:94px;
		background:#DCDCDC;
		border-style:solid;
		border-width:1px;
		border-color:#777777;
		-webkit-border-radius: 5px;
		-khtml-border-radius: 5px;
		-moz-border-radius: 5px;
		border-radius: 5px;
	}

	span#dragzoom0,div#dragzoom1{
		padding-left:1px;
		border-radius: 5px 0px 0px 5px;
		height:100%;
	}
	span#reorder0,div#reorder1{
		border-radius: 0px 5px 5px 0px;
		padding-right:3px;
		height:100%;
	}
	
	span.control{
		background:#DCDCDC;
		margin-left:2px;
		margin-right:2px;
		height:24px;
		/*padding:2px;*/
		display:inline-block;
		width:35px;
		border-style:solid;
		border-width:1px;
		border-color:#777777;
		-webkit-border-radius: 5px;
		-khtml-border-radius: 5px;
		-moz-border-radius: 5px;
		border-radius: 5px;
	}
	span.control:hover{
		background:#989898;
	}
	span.control.selected{
		border-width:2px;
		border-color:#000000;
	}
	
	table.trkSelList tr.odd:hover td,table.trkSelList tr.even:hover td
	{
  		background: #bbbbee;
	}
	
	table.trkSelList tr.odd.selected td,table.trkSelList tr.even.selected td
	{
  		background: #9b9bce;
	}
	
	span.control0,span.control1{
		cursor:pointer;
	}
	
	div#trackSettingDialog{
		position:absolute;
		display:none;
		background-color:#EEEEEE;
		border: 2px solid;
    	border-radius: 25px;
		
		max-height:400px;
		width:300px;
	}
	div#trackSettingContent{
		background-color:#EEEEEE;
		overflow:auto;
		width:93%;
		height:93%;
		margin:3%;
	}
	div#trackSettingContent table{
		width:100%;
	}
	div#trackSettingContent td {
	background-color:#EEEEEE;
	}
</style>