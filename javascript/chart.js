chart=function(params){
	that={}
	
	//Initialize Defaults
	that.value="CPM";
	that.heightPerc=0.6;
	that.widthPerc=0.90;
	that.curHeight=0;
	that.curWidth=0;
	that.margin = {top: 20, right: 20, bottom: 30, left: 40};
	that.allowResize=true;
	that.drawType="scatter";
	that.maxHMHeight=40;
	that.minHMHeight=15;
	that.topMarg=20;
	that.leftMarg=100;
	that.sortBy={"col":"","dir":""};
	that.display={"herit":true,"controls":true};
	that.filtered={};
	that.filterBy={};
	that.title="";

	
	that.parseOptions=function(params){
		//Initialize from Parameters
		if(params.data){
			that.dataFile=params.data;
		}
		if(params.selector){
			that.select=params.selector;
		}
		if(params.type){
			that.drawType=params.type;
		}
		if(params.width){
			if(params.width.indexOf("%")>0){
				that.widthPerc=params.width.substring(0,params.width.length-1)/100;
			}else{
				that.widthPerc=params.width/$(window).width();
				that.curWidth=params.width;
			}
		}
		if(params.height){
			if(params.height.indexOf("%")>0){
				that.heightPerc=params.height.substring(0,params.height.length-1)/100;
			}else{
				that.heightPerc=params.height/$(window).height();
				that.curHeight=params.height;
			}
		}
		if(params.allowResize===false){
			that.allowResize=params.allowResize;
			if(that.curWidth==0){
				that.curWidth=Math.floor($(window).width()*.5);
			}
			if(that.curHeight==0){
				that.curWidth=Math.floor($(window).heght()*.7);
			}
		}
		if(params.displayHerit===false){
			that.display.herit=false;
		}
		if(params.displayControls===false){
			that.display.controls=false;
		}
		if(params.title){
			that.title=params.title;
		}
		if(that.allowResize){
			$(window).resize(function (){
				that.calcSize();
				that.redraw();
			});
		}
	};
	//Function to perform complete Setup
	that.setup=function(){
		that.calcSize();
		that.setupDiv();
		that.setupUI();
	};
	//Function to append SVG to document
	that.setupDiv=function (){
		that.help=d3.select(that.select).append("div").attr("class","help").style("display","inline-block").style("text-align","center").style("width","100%");
		that.divCtrl = d3.select(that.select).append("div").attr("class","controls").style("width","100%").style("display","block");
		d3.select(that.select).append("br");
		d3.select(that.select).append("br");
		that.imgDiv=d3.select(that.select).append("div").attr("id","imgDiv");
		that.legendSVGTop = that.imgDiv.append("svg").attr("id","legendSVG")
									.attr("width",that.curWidth+that.margin.left+that.margin.right);
		that.legendSVG=that.legendSVGTop.append("g");
		that.imgDiv.append("br");
		that.svgTop = that.imgDiv.append("svg").attr("id","chartSVG")
			    .attr("width", that.curWidth+that.margin.left+that.margin.right)
			    .attr("height", that.curHeight+that.margin.top+that.margin.bottom);
		that.svg=that.svgTop.append("g")
			    .attr("transform", "translate("+that.margin.left+","+that.margin.top+")");
		that.hChartTop = that.imgDiv.append("svg").attr("id","heritSVG")
			    .attr("width", that.curWidth+that.margin.left+that.margin.right)
			    .attr("height", 0);
		that.hChart=that.hChartTop.append("g")
			    .attr("transform", "translate("+that.margin.left+","+that.margin.top+")");
	};
	//Function to setup the UI controls
	that.setupUI=function(){
		if(that.display.controls){
			that.functionBar=that.divCtrl.append("div").attr("class","functionBar")
				.style("float","left");
			//Setup Mouse Default Function Control
			var viewType=that.functionBar.append("div").attr("class","defaultMouse").style("display","inline-block").style("width","66px");
			viewType.append("span").attr("id","plotBtn").style("height","24px").style("display","inline-block")
				.style("cursor","pointer")
				.append("img").attr("class","mouseOpt dragzoom")
				.attr("src","/web/images/icons/plot_dark.png")
				.attr("pointer-events","all")
				.on("click",function(){
					d3.select(this).attr("src","/web/images/icons/plot_light.png");
					d3.select("span#plotBtn").style("background","#989898");
					that.drawType="scatter";
					that.reset();
					d3.select("span#hmBtn img").attr("src","/web/images/icons/hm_dark.png");
					d3.select("span#hmBtn").style("background","#DCDCDC");
					if(ga){
						ga('send','event','clickDragZoom','');
					}
				})
				.on("mouseout",function(){
					if(that.drawType!="scatter"){
						d3.select(this).attr("src","/web/images/icons/plot_dark.png");
						d3.select("span#plotBtn").style("background","#DCDCDC");
					}
				})
				.on("mouseover",function(){
					d3.select(this).attr("src","/web/images/icons/plot_light.png");
					d3.select("span#plotBtn").style("background","#989898");
					d3.select("div.help").html("Display data as scatter plot.");
					//$("#mouseHelp").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
				});
			viewType.append("span").attr("id","hmBtn").style("height","24px").style("display","inline-block")
				.style("cursor","pointer")
				.append("img")
				.attr("class","mouseOpt reorder")
				.attr("src","/web/images/icons/hm_dark.png")
				.attr("pointer-events","all")
				.on("click",function(){
					d3.select(this).attr("src","/web/images/icons/hm_light.png");
					d3.select("span#hmBtn").style("background","#989898");
					that.drawType="heatmap";
					that.reset();
					d3.select("span#plotBtn img").attr("src","/web/images/icons/plot_dark.png");
					d3.select("span#plotBtn").style("background","#DCDCDC");
					if(ga){
						ga('send','event','clickPan','');
					}
				})
				.on("mouseout",function(){
					if(that.drawType!="heatmap"){
						d3.select(this).attr("src","/web/images/icons/hm_dark.png");
						d3.select("span#hmBtn").style("background","#DCDCDC");
					}
					
				})
				.on("mouseover",function(){
					d3.select(this).attr("src","/web/images/icons/hm_light.png");
					d3.select("span#hmBtn").style("background","#989898");
					d3.select("div.help").html("Display data as a heatmap.");
				});
			
			that.functionBar.append("span").attr("class","saveImage control").style("display","inline-block")
				.attr("id","saveBtn")
				.style("cursor","pointer")
				.append("img")//.attr("class","mouseOpt dragzoom")
				.attr("src","/web/images/icons/savePic_dark.png")
				.attr("pointer-events","all")
				.attr("cursor","pointer")
				.on("click",function(){
					
					//console.log("Level #:"+levelID);
					var content=$("div#imgDiv").html();
					content=content+"\n";
					$.ajax({
							url: pathPrefix+"saveBrowserImage.jsp",
			   				type: 'POST',
							contentType: 'text/html',
							data: content,
							processData: false,
							dataType: 'json',
			    			success: function(data2){
			        			var d=new Date();
			        			var datePart=(d.getMonth()+1)+"_"+d.getDate()+"_"+d.getFullYear();
	                            var http="http://";
	                            if (location.protocol === 'https:') {
	                                http="https://";
	                            }
								var url=http+urlprefix+"/tmpData/download/"+data2.imageFile;
								var region=new String($('#geneTxt').val());
								region=region.replace(/:/g,"_");
								region=region.replace(/-/g,"_");
								region=region.replace(/,/g,"");
								var filename = region+"_"+datePart+".png";
								var xhr = new XMLHttpRequest();

								  xhr.open('GET', url);
								  xhr.responseType = 'blob';
								  xhr.send();
								  xhr.onreadystatechange = function(){
									    //ready?
									    if (xhr.readyState != 4)
									        return false;

									    //get status:
									    var status = xhr.status;

									    //maybe not successful?
									    if (status != 200) {
									    	//console.log("xhr status:"+status);
									        //alert("AJAX: server status " + status);
									        return false;
									    }
									    var a = document.createElement('a');
										a.href = window.URL.createObjectURL(xhr.response); // xhr.response is a blob
										a.download = filename; // Set the file name.
										a.style.display = 'none';
										document.body.appendChild(a);
										try{
											a.click();
										}catch(error){
											//$("#"+id).append("<span style='color:#FF0000;'>Your browser will not save the image directly. Image will open in a popup, in the new window right click to save image.</span>");
											$("#mouseHelp").html("<span style='color:#FF0000;'>Your browser will not save the image directly. Image will open in a popup, in the new window right click to save image.</span>");
											window.open(url);
										}
										delete a;
									    return true;
									}
									if(ga){
											ga('send','event','browser','saveBrowserImage');
									}
								  
			    			},
			    			error: function(xhr, status, error) {
			        			console.log(error);
			    			}
						});
					if(ga){
						ga('send','event','saveImage','');
					}
					})
				.on("mouseover",function(){
					d3.select(this).attr("src","/web/images/icons/savePic_white.png");
					d3.select("span#savePic"+that.levelNumber).style("background","#DCDCDC");
					//$(this).css("background","#989898").html("<img src=\"/web/images/icons/savePic_white.png\">");
					$("div.help").html("Click to download a PNG image of the current view.");
				})
				.on("mouseout",function(){
					d3.select(this).attr("src","/web/images/icons/savePic_dark.png");
					d3.select("span#savePic"+that.levelNumber).style("background","#989898");
					//$(this).css("background","#DCDCDC").html("<img src=\"/web/images/icons/savePic_dark.png\">");
					$("div.help").html("Navigation Hints: Hold mouse over areas of the image for available actions.");
				});
			tmpSpan=that.divCtrl.append("span").attr("id","displayCbxs").style("display","inline-block");
			tmpSpan.append("text").style("margin-right","8px").text("Display: ");
			//tmpSpan=tmpSpan.append("div").style("height","100%");
			tmpSpan.append("input").attr("type","checkbox").attr("id","")
				.property("checked","true")
				.on("change",function(){
					sel=d3.select(this).property("checked");
					if(sel){
						delete(that.filterBy.genes);
					}else{
						that.filterBy.genes=1;
					}
					that.reset();
					that.draw();
				});
			tmpSpan.append("text").style("margin-right","8px").text("Genes");
			//tmpSpan.append("br");
			tmpSpan.append("input").attr("type","checkbox")
				.attr("id","")
				.property("checked","true")
				.on("change", function(){
					sel=d3.select(this).property("checked");
					if(sel){
						delete(that.filterBy.trx);
					}else{
						that.filterBy.trx=1;
					}
					that.reset();
					that.draw();
				});
			tmpSpan.append("text").style("margin-right","8px").text("Transcripts");
			tmpSpan.append("input").attr("type","checkbox")
				.attr("id","")
				.property("checked",function(){
					if(that.display.herit){
						return true;
					}
					return false;
				})
				.on("change", function(){
					sel=d3.select(this).property("checked");
					that.display.herit=sel;
					that.reset();
					that.draw();
				});
			tmpSpan.append("text").text("Heritability");

			if(that.drawType=="scatter"){
				that.setupUIScatter();
			}else if(that.drawType=="heatmap"){
				that.setupUIHeatMap();
			}
		}
	};
	that.setupUIScatter=function(){
		
	};
	that.setupUIHeatMap=function(){

	};
	that.calcSize=function(){
		if(that.allowResize){
			that.curHeight=Math.floor(($(window).height()*that.heightPerc)-that.margin.top-that.margin.bottom);
			that.curWidth=Math.floor(($(window).width()*that.widthPerc)-that.margin.left-that.margin.right);
		}
	};
	that.reset=function(){
		if(that.resetProc && that.resetProc.clearTimeout){
			that.resetProc.clearTimeout();
		}
		//that.imgDiv.remove();
		that.svg.remove();
		that.legendSVG.remove();
		that.svgTop.selectAll("g").remove();
		that.hChartTop.selectAll("g").remove();
		that.hChartTop.attr("height",0);
		that.resetProc=setTimeout( function(){
			
			//setTimeout(function(){
				//that.imgDiv=d3.select(that.select).append("div").attr("id","imgDiv");
				that.svgTop.selectAll("g").remove();
				that.legendSVGTop.selectAll("g").remove();
				that.legendSVG=that.legendSVGTop.append("g");
				that.svg=that.svgTop.append("g")
					    .attr("transform", "translate("+that.margin.left+","+that.margin.top+")");
				that.hChartTop.selectAll("g").remove();
				that.hChart=that.hChartTop.append("g")
			    		.attr("transform", "translate("+that.margin.left+","+that.margin.top+")");
				that.calcSize();
				that.draw();
			//},200);
			
		},200);
	};
	that.draw=function(){
		that.filter();
		if(that.drawType=="scatter"){
			that.drawScatterLine();
		}else if(that.drawType=="heatmap"){
			that.drawHeatMap();
		}
	};
	that.filter=function(){
		geneRE=/ENSRNOG/;
		trxRE=/(ENS[A-Z]{3}|PRN[0-9]{1,2})T/;
		that.filteredData=that.data;
		that.filteredGeneIDs=that.geneIDs;
		that.filteredStrains=that.strains;

		//filter all genes
		if(that.filterBy.genes){
			that.filterID(geneRE);
		}
		//filter all transcripts
		if(that.filterBy.trx){
			that.filterID(trxRE);
		}
		//filter a list of gene/trx ids
		if(that.filterBy.gene){

		}
		
	};
	that.filterID=function(regEx){
		tmpGenes=[];
		toFilter={};
		for(var i=0;i<that.filteredGeneIDs.length;i++){
			if(!that.filteredGeneIDs[i].id.match(regEx)){
				tmpGenes.push(that.filteredGeneIDs[i]);
			}else{
				toFilter[that.filteredGeneIDs[i].id]=1;
			}
		}
		that.filteredGeneIDs=tmpGenes;
		tmpData=[];
		for(var i=0;i<that.filteredData.length;i++){
			if(!toFilter[that.filteredData[i].id]){
				tmpData.push(that.filteredData[i]);
			}
		}
		that.filteredData=tmpData;
	};
	//Function to draw initial chart
	that.drawScatterLine=function(){
		that.heritChartW=0;
		if(that.curWidth>1200 && that.display.herit){
			that.heritChartW=200;
		}

		that.x = d3.scalePoint().domain(that.filteredStrains).range([0, that.curWidth-Math.floor(that.heritChartW*1.1)]);
		that.y = d3.scaleLinear().range([that.curHeight, 0]);
		if(that.seriesCount>10){
			that.color = d3.scaleOrdinal(d3.schemeCategory20);
		}else{
			that.color = d3.scaleOrdinal(d3.schemeCategory10);;
		}
		that.xAxis = d3.axisBottom(that.x);
		that.yAxis = d3.axisLeft(that.y);
		that.y.domain([that.yMin,that.yMax]).nice();
		
		that.line = d3.line()
    					.x(function(d) { return that.x(d.strain); })
    					.y(function(d) { return that.y(d.val); });
		that.xAxGUI=that.svg.append("g")
    		.attr("class", "x axis")
    		.attr("transform", "translate(0," + that.curHeight + ")")
    		.call(that.xAxis);
		that.yAxGUI=that.svg.append("g")
      		.attr("class", "y axis")
      		.call(that.yAxis);
		that.yAxGUI.append("text")
      			.attr("class", "label")
      			.attr("transform", "rotate(-90)")
      			.attr("y", -37)
      			.attr("dy", ".71em")
      			.attr("x", -(that.curHeight/2))
      			.style("text-anchor", "end")
      			.text(that.value);
      	that.svg.append("g").attr("id","title")
      		.attr("transform","translate("+((that.curWidth-that.leftMarg-that.heritChartW)/2)+",0)")
      		.append("text")
      		.text(that.title);
      	that.svg.selectAll(".dot")
      		.data(that.filteredData)
    		.enter().append("circle")
    			.attr("class",function(d){return "dot "+d.id;})
	      		.attr("r", 2.5)
	      		.attr("cx", function(d) { return that.x(d.strain); })
	      		.attr("cy", function(d) { return that.y(d.val); })
	      		.style("fill", function(d) { return that.color(d.id); })
	      		.on("mouseover",function(d){

	      		});    	


	   
	    for(i=0;i<that.color.domain().length;i++){
	    	tmpID=that.color.domain()[i];
	    	tmpD=that.svg.selectAll("."+tmpID).data();
			tmpD.sort(that.sortCompStrainOrder);
	    	that.svg.append("path")
      			.attr("class", "line")
      			.attr("id","line"+tmpID)
      			.attr("d", function(d) {return that.line(tmpD);})
      			.style("stroke", function(d) { return that.color(tmpID); })
      			.style("stroke-width", "2px")
          		.style("fill", "none");
	    }

		that.geneScale= d3.scaleBand().domain(that.filteredGeneIDs.map(function(d){return d.id;})).range([0, that.curHeight]);

	    that.drawScatterLineLegend();
	    that.drawHeritabiltiy(barMarg);
	};
	that.drawScatterLineLegend=function(){
		lgdItemWidth=2;
		if(that.curWidth>1600){
			lgdItemWidth=8;
		}else if(that.curWidth>1400){
			lgdItemWidth=7;
		}else if(that.curWidth>1200){
			lgdItemWidth=6;
		}else if(that.curWidth>1000){
			lgdItemWidth=5;
		}else if(that.curWidth>800){
			lgdItemWidth=4;
		}else if(that.curWidth>600){
			lgdItemWidth=3;
		}
		itemW=(that.curWidth-that.margin.left)/lgdItemWidth;
		itemTotal=that.color.domain().length;
		rows=Math.floor(itemTotal/lgdItemWidth)+1;
		lgdH=rows*30;
		that.legendSVG.attr("height",lgdH);
		
	  	that.legend = that.legendSVG.selectAll(".legend")
	     	.data(that.color.domain())
	    	.enter().append("g")
	      	.attr("class", "legend")
	      	.attr("transform", function(d, i) { 
	      		yPos=Math.floor(i/lgdItemWidth)*30;
	      		xPos=(i%lgdItemWidth)*itemW+that.margin.left;
	      		return "translate("+xPos+","+yPos+")"; 
	      	});

	  	that.legend.append("rect")
	  		.attr("class",function(d){ return "legend box "+d;})
	      .attr("x",0)
	      .attr("width", 18)
	      .attr("height", 18)
	      .style("cursor","pointer")
	      .style("fill", that.color)
	      .style("stroke",that.color)
	      .style("stroke-width","1px")
	      .on("click",function(d){
	      	if(d3.select(this).style("fill")==d3.rgb(255,255,255)){
	      		d3.select(this).style("fill",that.color(d));
	      		that.svg.selectAll("#line"+d).style("opacity",100);
	      		that.svg.selectAll(".dot."+d).style("opacity",100);
	      	}else{
	      		d3.select(this).style("fill","#FFFFFF");
	      		that.svg.selectAll("#line"+d).style("opacity",0);
	      		that.svg.selectAll(".dot."+d).style("opacity",0);
	      	}
	      })
	      .on("mouseout",function(){
				d3.select("div.help").html("Click to toggle series on/off.");
			})
	      .on("mouseover",function(){

	      });

	  	that.legend.append("text")
	  		.attr("class","legend text")
	      .attr("x",22)
	      .attr("y", 9)
	      .attr("dy", ".35em")
	      .attr("font-size","1.0em")
	      .style("cursor","pointer")
	      //.style("text-anchor", "end")
	      .text(function(d) { return d; })
	      .on("mousedown",function(d){
	      	/*if(d3.select(".legend.box."+d).style("fill")==d3.rgb(255,255,255)){
	      		d3.select(".legend.box."+d).style("fill",that.color(d));
	      		that.svg.selectAll("#line"+d).style("opacity",100);
	      		that.svg.selectAll(".dot."+d).style("opacity",100);
	      	}else{
	      		d3.select(".legend.box."+d).style("fill","#FFFFFF");
	      		that.svg.selectAll("#line"+d).style("opacity",0);
	      		that.svg.selectAll(".dot."+d).style("opacity",0);
	      	}*/
	      		that.toggleSort(d);
      			that.sortByValueForID(that.sortBy.col,that.sortBy.dir);
      			that.reset();
      			that.draw();
      			//draw triangle
      			/*that.sortIndicator.attr("transform","translate("+?????????????that.x(d)+",0)")
      							.attr("transform", function(){
      								deg=180;
      								if(that.sortBy.dir=="DESC"){
      									deg=0
      								}
      								return "rotate("+deg+")";
      							});*/
	      })
	      .on("mouseout",function(){
				d3.select("div.help").html("Click to sort strains based on the values of this series.");
			})
	      .on("mouseover",function(){

	      });

	};
	that.redrawScatterLine=function(){
		if ( (that.heritChartW==0 && that.curWidth>1200 && that.display.herit) || (that.heritChartW>0 && that.curWidth<1200 && that.display.herit) ){
			that.reset();
		}else{
			that.svgTop.attr("width",that.curWidth+that.margin.left+that.margin.right)
				.attr("height", that.curHeight+that.margin.top+that.margin.bottom);
			that.svg.attr("transform", "translate("+that.margin.left+","+that.margin.top+")");

			that.x.range([0, that.curWidth-Math.floor(that.heritChartW*1.1)]);
			that.y.range([that.curHeight, 0]);

			that.xAxGUI.attr("transform", "translate(0," + that.curHeight + ")")
				.call(that.xAxis);
			that.yAxGUI.call(that.yAxis).select(".label").attr("x", -(that.curHeight/2));

			that.svg.selectAll(".dot")
				.attr("cx", function(d) { return that.x(d.strain); })
		      	.attr("cy", function(d) { return that.y(d.val); });
		    
		    for(i=0;i<that.color.domain().length;i++){
		    	tmpID=that.color.domain()[i];
		    	tmpD=that.svg.selectAll(".dot."+tmpID).data();
		    	tmpD.sort(that.sortCompStrainOrder);
		    	that.svg.select("#line"+tmpID)
	      			.attr("d", function(d) {return that.line(tmpD);});
		    }

		    lgdItemWidth=2
			if(that.curWidth>1600){
				lgdItemWidth=8;
			}else if(that.curWidth>1400){
				lgdItemWidth=7;
			}else if(that.curWidth>1200){
				lgdItemWidth=6;
			}else if(that.curWidth>1000){
				lgdItemWidth=5;
			}else if(that.curWidth>800){
				lgdItemWidth=4;
			}else if(that.curWidth>600){
				lgdItemWidth=3;
			}
			itemW=(that.curWidth-that.margin.left)/lgdItemWidth;
			itemTotal=that.color.domain().length;
			rows=Math.floor(itemTotal/lgdItemWidth)+1;
			lgdH=rows*30;
			that.legendSVG.attr("height",lgdH).attr("width",that.curWidth);
		    that.legendSVG.selectAll("g.legend")
		    	.attr("transform", function(d, i) { 
		      		yPos=Math.floor(i/lgdItemWidth)*30;
		      		xPos=(i%lgdItemWidth)*itemW+that.margin.left;
		      		return "translate("+xPos+","+yPos+")"; 
		      	});
		    if(that.curWidth<500){
		    	that.legendSVG.selectAll(".legend.text")
		    		.attr("y", 9)
		      		.attr("dy", ".35em")
		      		.attr("font-size","0.7em");
		    }else{
		    	that.legendSVG.selectAll(".legend.text")
		    		.attr("y", 9)
		      		.attr("dy", ".35em")
		      		.attr("font-size","1.0em");
		    }
		    that.redrawHeritability(0);
		}
	};

	that.drawHeatMap=function(){
		that.heritChartW=0;
		if(that.curWidth>1200 && that.display.herit){
			that.heritChartW=200;
		}
		itemW=(that.curWidth-that.leftMarg-that.heritChartW)/that.filteredStrains.length;
		itemH=(that.curHeight-that.topMarg)/that.filteredGeneIDs.length;
		barMarg=Math.floor(itemH*0.1);
		if(barMarg<1){
			barMarg=1;
		}
		yRangeMax=that.curHeight-that.topMarg;
		/*if(itemH> that.maxHMHeight){
			itemH=that.maxHMHeight;
			yRangeMax=that.geneIDs.length*itemH;
		}*/
		that.x = d3.scaleBand().domain(that.filteredStrains).range([0, that.curWidth-that.leftMarg-that.heritChartW]);
		that.y = d3.scaleBand().domain(that.filteredGeneIDs.map(function(d){return d.id;})).range([0, yRangeMax]);
		that.geneScale=that.y;
		that.color= d3.scaleLinear().domain([that.yMin,that.yMax]).range([0,255]);
		that.xAxis = d3.axisTop(that.x);
		that.yAxis = d3.axisLeft(that.y);
		that.svg.append("g").attr("id","title").append("text").attr("transform","translate("+((that.curWidth-that.leftMarg-that.heritChartW)/2)+",0)").text(that.title);
		that.xAxGUI=that.svg.append("g")
    		.attr("class", "x axis")
    		.attr("transform", "translate("+that.leftMarg+","+that.topMarg+")")
    		.call(that.xAxis);
    	d3.selectAll("g.x.axis g.tick text")
      		.style("cursor","pointer")
      		.on("click", function(){
      			id=d3.select(this)._groups[0][0].textContent
      			that.toggleSort(id);
      			that.sortByStrain(that.sortBy.col,that.sortBy.dir);
      			that.reset();
      			that.draw();
      			setTimeout(function(){
      				that.sortIndicator.attr("transform", function(){
      					deg=180;
      					dy=10;
      					dx=0;
      					offs=30;
						if(that.sortBy.dir=="DESC"){
							deg=0;
							dy=5;
							dx=10;
						}
						x=that.x(id)+that.leftMarg-dx+offs+(itemW/2)
      					return "translate("+x+","+dy+")rotate("+deg+")";
      				}).style('stroke', 'black');
      			},500);
      			
      		});

		that.yAxGUI=that.svg.append("g")
      		.attr("class", "y axis")
      		.attr("transform", "translate("+that.leftMarg+","+that.topMarg+")")
      		.call(that.yAxis);
      	d3.selectAll("g.y.axis g.tick text")
      		.style("cursor","pointer")
      		.on("click", function(){
      			id=d3.select(this)._groups[0][0].textContent;
      			that.toggleSort(id);
      			that.sortByValueForID(that.sortBy.col,that.sortBy.dir);
      			that.reset();
      			that.draw();
      			//draw triangle
      			setTimeout(function(){
	      			that.sortIndicator.attr("transform",function(){
	      					deg=180;
	      					dy=2;
	      					dx=0;
	      					offs=-30
							if(that.sortBy.dir=="DESC"){
								deg=0;
								dy=-2;
								dx=10;
							}
							x=5-dx+offs;
							dy=dy+that.y(id)+itemH/2+that.topMarg;
	      					return "translate("+x+","+dy+")rotate("+deg+")";
	      					

	      			}).style('stroke', 'black');
	      		},500);

      		});
      	that.svg.selectAll(".box")
      		.data(that.filteredData)
    		.enter().append("rect")
    			.attr("class","box")
	      		.attr("x", function(d) { return that.x(d.strain)+that.leftMarg; })
	      		.attr("y", function(d) { return that.y(d.id)+that.topMarg; })
	      		.attr("width", function(d) { return itemW; })
	      		.attr("height", function(d) { return itemH; })
	      		.style("fill", function(d) { return d3.rgb(that.color(d.val),0,0); })
	      		.on("mouseover",function(d){

	      		});
	    trianglePoints="0,6 10,6 5,0";
	    that.sortIndicator=that.svg.append("g").attr("id","sortIndicator").attr("transform","translate(-50,-50)");
	    that.sortIndicator.append('polyline')
    		.attr('points', trianglePoints)
    		.style('stroke', 'white');

    	that.svgTop.attr("height",itemH*that.filteredGeneIDs.length+that.margin.top+that.margin.bottom+25);

    	//Setup Legend
	    that.legendSVGTop.attr("height",50);
	    grad=that.legendSVG.append("defs").append("linearGradient")
	    					.attr("id","scale")
	    					.attr("x1","0%").attr("y1","0%")
	    					.attr("x2","100%").attr("y2","0%");
	   	grad.append("stop").attr("offset","0%").style("stop-color","rgb(0,0,0)");
	   	grad.append("stop").attr("offset","100%").style("stop-color","rgb(255,0,0)");
	    that.hmScale=d3.scaleLinear().domain([that.yMin,that.yMax]).range([that.leftMarg, that.curWidth-that.heritChartW]);
	    that.cAxis = d3.axisTop(that.hmScale);
	    that.cAxGUI=that.legendSVG.append("g")
    		.attr("class", "c axis")
    		.attr("transform", "translate("+that.margin.left+",30)")
    		.call(that.cAxis);
    	that.legendSVG.append("text").attr("id","legendLbl").attr("transform","translate("+(that.curWidth/2+that.margin.left-20)+",11)").text("Counts (CPM)");
	    
	   	that.legendSVG.append("rect").attr("id","legendRect")
	   					.attr("x",that.leftMarg).attr("y",7)
	   					.attr("width",that.curWidth-that.leftMarg-that.heritChartW)
	   					.attr("height", 20)
	   					.attr("fill","url(\"#scale\")")
	   					.attr("transform","translate("+that.margin.left+",27)");
	   	that.drawHeritabiltiy(barMarg);
	};

	that.redrawHeatMap=function(){
		if ( (that.heritChartW==0 && that.curWidth>1200 && that.display.herit) || (that.heritChartW>0 && that.curWidth<1200 && that.display.herit) ){
			that.reset();
		}else{
			that.leftMarg=100;
			that.topMarg=20;
			itemW=(that.curWidth-that.leftMarg-that.heritChartW)/that.filteredStrains.length;
			itemH=(that.curHeight-that.topMarg)/that.filteredGeneIDs.length;
			barMarg=Math.floor(itemH*0.1);
			if(barMarg<1){
				barMarg=1;
			}
			yRangeMax=that.curHeight-that.topMarg;
			/*if(itemH> that.maxHMHeight){
				itemH=that.maxHMHeight;
				yRangeMax=that.geneIDs.length*itemH;
			}*/
			that.svgTop.attr("width",that.curWidth+that.margin.left+that.margin.right)
				.attr("height", itemH*that.filteredGeneIDs.length+25 +that.margin.top+that.margin.bottom);
			that.svg.attr("transform", "translate("+that.margin.left+","+that.margin.top+")");
			that.x.range([0, that.curWidth-that.leftMarg-that.heritChartW]);
			that.y.range([0, yRangeMax]);
			that.xAxGUI.call(that.xAxis);
			that.yAxGUI.call(that.yAxis);
			that.svg.selectAll(".box")
				.attr("x", function(d) { return that.x(d.strain)+that.leftMarg; })
	      		.attr("y", function(d) { return that.y(d.id)+that.topMarg; })
	      		.attr("width", function(d) { return itemW; })
	      		.attr("height", function(d) { return itemH; });
	      	that.legendSVGTop.attr("width",that.curWidth+that.margin.left+that.margin.right);
	      	that.legendSVG.select("#legendLbl").attr("transform","translate("+(that.curWidth/2+that.margin.left-20)+",11)");
	      	that.hmScale.range([that.leftMarg, that.curWidth-that.heritChartW]);
			that.cAxGUI.call(that.cAxis);
			d3.select("rect#legendRect").attr("width",that.curWidth-that.leftMarg-that.heritChartW);
			that.redrawHeritability(barMarg);
		}
	};


	that.drawHeritabiltiy=function(barMarg){
		if(that.heritChartW>0){//draw to side of heatmap
		   	that.heritScale = d3.scaleLinear().domain([0,1]).range([0,195]);
		   	that.heritAx=d3.axisTop(that.heritScale);
		   	internalHChart=that.svg.append("g").attr("id","internalHChart").attr("transform","translate("+(that.curWidth-that.heritChartW)+",0)");
		   	trianglePoints="0,6 10,6 5,0";
		    that.hSortIndicator=internalHChart.append("g").attr("id","sortIndicator").attr("transform","translate(-50,-50)");
		    that.hSortIndicator.append('polyline')
	    		.attr('points', trianglePoints)
	    		.style('stroke', 'white');
		   	that.hAxGUI=internalHChart.append("g")
	    		.attr("class", "h axis")
	    		.attr("transform","translate(0,"+that.topMarg+")")
	    		.call(that.heritAx);
	    	internalHChart.append("text").attr("transform","translate(75,2)").style("cursor","pointer")
	    		.text("Heritability")
	    		.on("click", function(){ 
	    				that.processSortByHerit();
	    				that.sortIndicator.attr("transform",function(){
							      					deg=180;
							      					dy=2;
							      					
							      					offs=-30
													if(that.sortBy.dir=="DESC"){
														deg=0;
														dy=-2;
														
													}
													x=75+20;
													dy=dy+that.geneScale(id)+itemH/2+that.topMarg;
							      					return "translate("+x+","+dy+")rotate("+deg+")";
      					

      						}).style('stroke', 'black');
	    		});
	    	internalHChart.selectAll(".bar")
	      		.data(that.filteredGeneIDs)
	    		.enter().append("rect")
	    			.attr("class","bar")
		      		.attr("x", function(d) { return 0; })
		      		.attr("y", function(d) { return that.geneScale(d.id)+that.topMarg+barMarg; })
		      		.attr("width", function(d) { return that.heritScale(d.herit); })
		      		.attr("height", function(d) { return itemH-(2*barMarg); })
		      		.style("fill", function(d) { 
		      			color=d3.rgb(0,0,175);
		      			if(that.drawType==="scatter"){
							color=that.color(d.id);
		      			}
		      			return color; 
		      		})
		      		.on("mouseover",function(d){

		      		});
	    }else if (that.display.herit){//draw below heatmap
	    	that.hChartTop.attr("width",that.curWidth+that.margin.left+that.margin.right)
	    				.attr("height",that.curHeight/2+that.margin.top+that.margin.bottom);

	    	that.hChart.attr("transform","translate("+(that.leftMarg+that.margin.left)+",0)");
	    	that.heritScale = d3.scaleLinear().domain([0,1]).range([0, that.curWidth-that.leftMarg]);
		   	that.heritAx=d3.axisTop(that.heritScale);
		   	that.yH = d3.scaleBand().domain(that.filteredGeneIDs.map(function(d){return d.id;})).range([0, Math.floor(yRangeMax/2)]);
		   	that.yhAx=d3.axisLeft(that.yH);
		   	that.hAxGUI=that.hChart.append("g")
	    		.attr("class", "h axis")
	    		.attr("transform","translate(0,"+(that.topMarg+15)+")")
	    		.call(that.heritAx);
	    	that.yhAxGUI=that.hChart.append("g")
	    		.attr("class", "yh axis")
	    		.attr("transform","translate(0,"+(that.topMarg+15)+")")
	    		.call(that.yhAx);
	    	that.hChart.append("text").attr("id","hChartLbl").attr("transform","translate("+(that.curWidth/2)+",10)")
	    		.style("cursor","pointer")
	    		.text("Heritability")
	    		.on("click", that.processSortByHerit);
	    	that.hChart.selectAll(".bar")
	      		.data(that.filteredGeneIDs)
	    		.enter().append("rect")
	    			.attr("class","bar")
		      		.attr("x", function(d) { return 0; })
		      		.attr("y", function(d) { return that.yH(d.id)+that.topMarg+15+barMarg; })
		      		.attr("width", function(d) { return that.heritScale(d.herit); })
		      		.attr("height", function(d) { return Math.floor(itemH/2)-(2*barMarg); })
		      		.style("fill", function(d) { 
		      			color=d3.rgb(0,0,175);
		      			if(that.drawType==="scatter"){
							color=that.color(d.id);
		      			}
		      			return color; 
		      		})
		      		.on("mouseover",function(d){

		      		});
	    }
	};

	that.redrawHeritability=function(barMarg){
		if(that.heritChartW>0 && that.display.herit){
			that.svg.select("g#internalHChart").attr("transform","translate("+(that.curWidth-that.heritChartW)+",0)");
			that.svg.select("g#internalHChart").selectAll("rect.bar")
				.attr("y", function(d) { return that.geneScale(d.id)+that.topMarg+barMarg; })
				.attr("height", function(d) { return itemH-(2*barMarg); });
		}else if (that.display.herit){
			tmpMarg=that.topMarg+15;
			d3.select("#hChartLbl").attr("transform","translate("+(that.curWidth/2)+",10)");
			that.hChartTop.attr("width",that.curWidth+that.margin.left+that.margin.right)
    				.attr("height",that.curHeight/2+that.margin.top+that.margin.bottom);
    		that.hChart.attr("transform","translate("+(that.leftMarg+that.margin.left)+",0)");
    		that.heritScale.range([0, that.curWidth-that.leftMarg]);
    		that.yH.range([0, Math.floor(yRangeMax/2)]);
    		that.hAxGUI.call(that.heritAx);
    		that.yhAxGUI.call(that.yhAx);
    		that.hChart.selectAll("rect.bar")
				.attr("y", function(d) { return that.yH(d.id)+tmpMarg+barMarg; })
				.attr("width", function(d) { return that.heritScale(d.herit); })
				.attr("height", function(d) { return Math.floor(itemH/2)-(2*barMarg); });

		}
	}

	that.redraw=function (){
		if(that.drawType=="scatter"){
			that.redrawScatterLine();
		}else if(that.drawType=="heatmap"){
			that.redrawHeatMap();
		}
	}
	//Data Functions
	that.getData=function(){
		$.ajax({
				url: that.dataFile,
   				type: 'GET',
				data: {},
				dataType: 'json',
    			success: function(data2){
        			if(data2.GENE_ID){
        				that.parseSingleGene(data2);
        			}else if(data2.GENE_LIST){
        				that.parseMultipleGenes(data2);
        			}
        			if(ga){
						ga('send','event','loadChartData',that.dataFile);
					}
    			},
    			error: function(xhr, status, error) {
        			console.log(error);
    			}
			});
	};
	

	that.processSortByHerit = function (){
		that.toggleSort("herit");
      	that.sortByHerit(that.sortBy.col,that.sortBy.dir);
      	that.reset();
      	that.draw();
      	
	};
	that.sortByHerit=function(herit,direction){
		if(direction==="DESC"){
			that.geneIDs.sort(that.sortCompHRev);
		}else{
			that.geneIDs.sort(that.sortCompH);
		}
	};
	that.sortByStrain=function(strain,direction){
		tmpData=[];
		geneHash={};
		for(var i=0;i<that.filteredGeneIDs.length;i++){
			geneHash[that.filteredGeneIDs[i].id]=that.filteredGeneIDs[i];
		}
		for(var i=0;i<that.filteredData.length;i++){
			if(that.filteredData[i].strain===strain){
				tmpData.push(that.filteredData[i]);
			}
		}
		if(direction==="DESC"){
			tmpData.sort(that.sortCompRev);
		}else{
			tmpData.sort(that.sortComp);
		}
		that.geneIDs=[];
		for(var i=0;i<tmpData.length;i++){
			that.geneIDs.push(geneHash[tmpData[i].id]);
		}
	};

	that.sortByValueForID=function(id,direction){
		tmpData=[];
		for(var i=0;i<that.filteredData.length;i++){
			if(that.filteredData[i].id===id){
				tmpData.push(that.filteredData[i]);
			}
		}
		if(direction==="DESC"){
			tmpData.sort(that.sortCompRev);
		}else{
			tmpData.sort(that.sortComp);
		}
		that.strains=[];
		for(var i=0;i<tmpData.length;i++){
			that.strains.push(tmpData[i].strain);
		}
	};
	that.sortCompH= function(a,b){
		if(a.herit<b.herit){
			return -1;
		}
		if(a.herit>b.herit){
			return 1;
		}
		return 0;
	};
	that.sortCompHRev= function(a,b){
		if(a.herit<b.herit){
			return 1;
		}
		if(a.herit>b.herit){
			return -1;
		}
		return 0;
	};
	that.sortComp= function(a,b){
		if(a.val<b.val){
			return -1;
		}
		if(a.val>b.val){
			return 1;
		}
		return 0;
	};
	that.sortCompRev= function(a,b){
		if(a.val<b.val){
			return 1;
		}
		if(a.val>b.val){
			return -1;
		}
		return 0;
	};
	that.sortCompStrainOrder=function(a,b){
		ax=that.x(a.strain);
		bx=that.x(b.strain);
		if(ax<bx){
			return -1;
		}
		if(ax>bx){
			return 1;
		}
		return 0;
	};
	that.toggleSort=function(column){
		if(that.sortBy.col===column){
			if(that.sortBy.dir==="ASC"){
				that.sortBy.dir="DESC";
			}else{
				that.sortBy.dir="ASC";
			}
		}else{
			that.sortBy.col=column;
			that.sortBy.dir="ASC";
		}
	};
	//Parse results from single genes
	that.parseSingleGene=function(d){
		that.strains=[];
		that.geneIDs=[];
		that.data=[];
		id=d.GENE_ID;
		tmp={"id":id};
		if(d.HERIT){
			tmp.herit=d.HERIT;
		}else{
			that.display.herit=false;
		}
		that.geneIDs.push(tmp);
		that.yMin=d.VALUES[0][that.value];
		that.yMax=d.VALUES[0][that.value];
		for(i=0;i<d.VALUES.length;i++){
			that.strains.push(d.VALUES[i].Strain);
			that.data.push({"id":id,"strain":d.VALUES[i].Strain,"val":d.VALUES[i][that.value]});
			if(that.yMin>d.VALUES[i][that.value]){
				that.yMin=d.VALUES[i][that.value];
			}
			if(that.yMax<d.VALUES[i][that.value]){
				that.yMax=d.VALUES[i][that.value];
			}
		}
		for(j=0;j<d.TRXList.length;j++){
			id=d.TRXList[j].TRXID;
			tmp={"id":id};
			if(d.TRXList[j].HERIT){
				tmp.herit=d.TRXList[j].HERIT;
			}
			that.geneIDs.push(tmp);
			for(i=0;i<d.TRXList[j].VALUES.length;i++){
				that.data.push({"id":id,"strain":d.TRXList[j].VALUES[i].Strain,"val":d.TRXList[j].VALUES[i][that.value]});
				if(that.yMin>d.TRXList[j].VALUES[i][that.value]){
					that.yMin=d.TRXList[j].VALUES[i][that.value];
				}
				if(that.yMax<d.TRXList[j].VALUES[i][that.value]){
					that.yMax=d.TRXList[j].VALUES[i][that.value];
				}
			}
		}
		that.seriesCount=d.TRXList.length+1;
		if(that.seriesCount>20){
			that.drawType="heatmap";

		}
		that.draw();
	};
	
	//Parse results from multiple genes
	that.parseMultipleGenes=function(d){
		that.strains=[];
		that.geneIDs=[];
		that.data=[];
		list=d.GENE_LIST;
		that.seriesCount=0;
		that.yMin=list[0].VALUES[0][that.value];
		that.yMax=list[0].VALUES[0][that.value];
		for(var k=0;k<list.length;k++){
			//console.log(k);
			id=list[k].GENE_ID;
			
			tmp={"id":id};
			if(list[k].HERIT){
				tmp.herit=list[k].HERIT;
			}else{
				that.display.herit=false;
			}
			that.geneIDs.push(tmp);
			
			//console.log(list[k].VALUES.length);
			for(i=0;i<list[k].VALUES.length;i++){
				if(k===0){
					that.strains.push(list[k].VALUES[i].Strain);
				}
				that.data.push({"id":id,"strain":list[k].VALUES[i].Strain,"val":list[k].VALUES[i][that.value]});
				if(that.yMin>list[k].VALUES[i][that.value]){
					that.yMin=list[k].VALUES[i][that.value];
				}
				if(that.yMax<list[k].VALUES[i][that.value]){
					that.yMax=list[k].VALUES[i][that.value];
				}
			}
			for(j=0;j<list[k].TRXList.length;j++){
				id=list[k].TRXList[j].TRXID;
				tmp={"id":id};
				if(list[k].TRXList[j].HERIT){
					tmp.herit=list[k].TRXList[j].HERIT;
				}
				that.geneIDs.push(tmp);
				for(i=0;i<list[k].TRXList[j].VALUES.length;i++){
					that.data.push({"id":id,"strain":list[k].TRXList[j].VALUES[i].Strain,"val":list[k].TRXList[j].VALUES[i][that.value]});
					if(that.yMin>list[k].TRXList[j].VALUES[i][that.value]){
						that.yMin=list[k].TRXList[j].VALUES[i][that.value];
					}
					if(that.yMax<list[k].TRXList[j].VALUES[i][that.value]){
						that.yMax=list[k].TRXList[j].VALUES[i][that.value];
					}
				}
			}
		}
		if(that.seriesCount>20){
			that.drawType="heatmap";
		}
		that.draw();
	};

	//Initial Setup
	setTimeout(function(){
		that.parseOptions(params);
		that.getData();
		that.setup();
	},10);
	

	return that;
}