<style>
div.testToolTip {   
  position: absolute;           
  text-align: center;
  min-width: 100px;
  max-width: 400px;
  min-height:50px;                  
  /*height: 300px;   */              
  padding: 2px;             
  font: 12px sans-serif;        
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
	fill:none;
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
	span.detailMenu,span.selectdetailMenu,span.viewMenu{
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
	span.viewMenu{
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
	
	span.viewMenu{
		background:#AEAEAE;
		color:#000000;
	}
	span.viewMenu.selected{
		background:#DEDEDE;
		color:#000000;
	}
	span.viewMenu:hover{
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
	}
</style>