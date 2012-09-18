<%
        int rowNum = 1;
        int previousPageNum = pageNum - 1;
        int nextPageNum = pageNum + 1;
        int firstPageNum = 0;
        int lastPageNum = numRows/batchSize;
        if (numRows%batchSize == 0) {
                lastPageNum = lastPageNum - 1 ;
        }

        int startBatchNum = 0;
        int endBatchNum = 0;
        int numPageLinks = 5;

        //
        // If the page to be displayed is divisible by the number of page links that are displayed, then start the
        // page links displayed at that number.  Otherwise, start the page links at the page number minus the amount
        // left over from dividing by the number of page links
        //
        if (pageNum%numPageLinks == 0) {
                startBatchNum = pageNum;
        } else {
                startBatchNum = pageNum - (pageNum%numPageLinks);
        }
        endBatchNum = startBatchNum + numPageLinks;
        //
        // If there are not enough pages to print an entire batch of page links, then stop at the last page num
        //
        if (endBatchNum > lastPageNum) {
                endBatchNum = lastPageNum + 1;
        }

        int startRowNum = (pageNum * batchSize) + 1;
        int endRowNum = Math.min(nextPageNum * batchSize, numRows);

        //
        // If the link for "Next" is going to go past the last page number, then set the Next link to the last page number
        //
        if (nextPageNum > lastPageNum) {
                nextPageNum = lastPageNum;
        }

        //log.debug("pageNum = " + pageNum + ", startBatchNum = " + startBatchNum + ", endBatchNum = " + endBatchNum);

%>
