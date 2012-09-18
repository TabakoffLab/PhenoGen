
//Progress Bar script- by Todd King (tking@igpp.ucla.edu)
//Modified by JavaScript Kit for NS6, ability to specify duration
//Visit JavaScript Kit (http://javascriptkit.com) for script

var duration=60 // Specify duration of progress bar in seconds
var _progressWidth = 20;	// Display width of progress bar

var _progressBar = new String("xxxxxxxxxxxxxxxxxxxx");
// number of times bar is updated 
var _progressEnd = 10;
var _progressAt = 0;


// Create and display the progress dialog.
// end: The number of steps to completion
function ProgressCreate(end, form) {
	// Initialize state variables
	_progressEnd = end;
	_progressAt = 0;
	duration = form.duration.value;
	//alert('duration = '+duration);

	// Move layer to center of window to show
	if (document.all) {	// Internet Explorer
		progress.className = 'show';
		progress.style.left = (document.body.clientWidth/2) - (progress.offsetWidth/2);
		progress.style.top = document.body.scrollTop+(document.body.clientHeight/2) - (progress.offsetHeight/2) - 180;
	} else if (document.layers) {	// Netscape
		progress.className = 'show';
		document.progress.visibility = true;
		document.progress.left = (window.innerWidth/2) - 100;
		document.progress.top = pageYOffset+(window.innerHeight/2) - 180;
	} else if (document.getElementById) {	// Netscape 6+
		document.getElementById("progress").className = 'show';
		document.getElementById("progress").style.left = (window.innerWidth/2)- 100 +"px";
		document.getElementById("progress").style.top = pageYOffset+(window.innerHeight/2) - 180 + "px";
	} else {
	}

	ProgressUpdate();	// Initialize bar
}

// Hide the progress layer
function ProgressDestroy() {
	//alert('in ProgressDestroy');
	// Move off screen to hide
	if (document.all) {	// Internet Explorer
		progress.className = 'hide';
	} else if (document.layers) {	// Netscape
		document.progress.visibility = false;
	} else if (document.getElementById) {	// Netscape 6+
		document.getElementById("progress").className = 'hide';
	}
}

// Increment the progress dialog one step
function ProgressStepIt() {
	//alert('in ProgressStepIt');
	// Move off screen to hide
	_progressAt++;
	if(_progressAt > _progressEnd) _progressAt = _progressAt % _progressEnd;
	ProgressUpdate();
}

// Update the progress dialog with the current state
function ProgressUpdate() {
	//alert('in ProgressUpdate');
	var n = (_progressWidth / _progressEnd) * _progressAt;
	if (document.all) {	// Internet Explorer
		var bar = dialog.bar;
 	} else if (document.layers) {	// Netscape
		var bar = document.layers["progress"].document.forms["dialog"].bar;
		n = n * 0.55;	// characters are larger
	} else if (document.getElementById){
                var bar=document.dialog.bar
        }
	var temp = _progressBar.substring(0, n);
	bar.value = temp;
}

// Demonstrate a use of the progress dialog.
function Demo(form) {
	//alert('in Demo');
	ProgressCreate(_progressEnd, form);
	window.setTimeout("Click()", duration);
}

function Click() {
	if(_progressAt >= _progressEnd) {
		ProgressDestroy();
		return;
	}
	ProgressStepIt();
	window.setTimeout("Click()", (duration)*1000/10);
}

function CallJS(jsStr) { //v2.0
	//alert('in CallJS');
  return eval(jsStr)
}


// Create layer for progress dialog
document.write("<div id=\"progressDiv\" class=\"progressDiv\"><span id=\"progress\" class=\"hide\">");
	document.write("<FORM name=dialog>");
	document.write("<TABLE class=\"progressBar\" cellspacing=\"20\">");
	document.write("<TR><TD class=\"heading\">");
	document.write("Working...<BR>");
	document.write("<input type=text name=\"bar\" size=\"" + _progressWidth + "\"");
	if(document.all||document.getElementById) 	// Microsoft, NS6
		document.write(" bar.style=\"color:navy;\">");
	else	// Netscape
		document.write(">");
	document.write("</TD></TR>");
	document.write("</TABLE>");
	document.write("</FORM>");
document.write("</span></div>");
ProgressDestroy();	// Hides


        var durationArray = new Array();

        function populateDuration(method, form) {
                for (var i=0; i<durationArray.length; i++) {
			if (durationArray[i].program == method) {
				form.duration.value = durationArray[i].run_time;
				return true;
			} 
                }
        }

        function durationRow(program, run_time) {
                this.program = program;
                this.run_time = run_time;
        }




