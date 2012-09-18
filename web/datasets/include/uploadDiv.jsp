                <div id="upload_div">
                        <p style="margin:10px 70px;"><strong>Note:</strong> The phenotype data file should be a tab-delimited text file
                         with no column headers.  The first column should contain the strain name and the second column
                        should contain the mean phenotype value for that strain.  
			<% if (callingForm.equals("calculateQTLs")) { %> 
			If variance is included, it should be in the third column.
			<% } %>
			The strain names should
                        <i><b>exactly</b></i> match the group names shown below.<BR><BR>
                                <strong>File Containing Phenotype Data:</strong>
                                <input type="file" name="filename" size="20">
                        </p>
                </div>

