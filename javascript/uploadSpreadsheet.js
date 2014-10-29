/* --------------------------------------------------------------------------------
 *
 *  specific functions for uploadSpreadsheet.jsp
 *
 * -------------------------------------------------------------------------------- */

function IsUploadSpreadsheetFormComplete(){
        var fileNameField = $("input[name='filename']");
        var fileNameValue = fileNameField.val();
        if (fileNameValue == '') { 
                alert('You must specify a file to upload.');
                fileNameField.focus();
                return false;
        } else if (fileNameValue != '' && !isExcelFile(fileNameValue)) {
                alert('The file you are uploading should have an extension of ".xls".  Provide an Excel file to upload.');
                fileNameField.focus();
                return false; 
        }
        return true;
}

