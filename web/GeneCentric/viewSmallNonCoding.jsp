<script src="/javascript/processing-1.4.1.min.js"></script>
<div style=" text-align:center;">
<canvas id="sketch"></canvas>

<script type="text/javascript">
						var fileRequest = new window.XMLHttpRequest();
                        fileRequest.open("GET", "/web/GeneCentric/test.pde", false);
                        fileRequest.send(null);
                        var canvas = document.getElementById("sketch");
                        var p = new Processing(canvas, fileRequest.responseText); 
</script>


<div>
<h2>Annotations</h2>
links to annotations if any
</div>

<BR />
<BR />

<table name="items" id="tblViewSMNC" class="list_base" cellpadding="0" cellspacing="0" width="100%">
	<thead>
    	<TR class="col_title">
        	<TH>Sequence</TH>
            <TH>Total Read Counts</TH>
            <TH># Unique Alignments</TH>
        </TR>
	</thead>
    <tbody>
    </tbody>
</table>


</div>

<script type="text/javascript">
	var tblSMNC=$('#tblViewSMNC').dataTable({
	"bPaginate": false,
	"bProcessing": true,
	"sScrollX": "900px",
	"sScrollY": "350px"
	});
	tblSMNC.dataTable().fnAdjustColumnSizing();
</script>