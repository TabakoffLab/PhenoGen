<%--
 *  Author: Cheryl Hornbaker
 *  Created: February, 2007
 *  Description:  The web page created by this file displays information on citing the website tools for reference
 *
 *  Todo: 
 *  Modification Log:
 *      
--%>

<%@ include file="/web/access/include/login_vars.jsp" %>

<% 	extrasList.add("normalize.css");
	extrasList.add("index.css"); %>

<%pageTitle="Citations";
pageDescription="Citation information for PhenoGen and additional software";%>

<%@ include file="/web/common/header.jsp" %>

        <div id="overview-content">
        <div id="welcome" style="height:780px; width:946px; overflow:auto;">

	<h2>If you use this website in your research, please cite the following references:</h2>
	<p>Website:</p>
	<p class="indent"> Please cite both of the following sources for this website: </p>
	<p class="indent">(1) The PhenoGen informatics website: Tools for analyses of complex traits.<BR>
		Sanjiv V Bhave, Cheryl Hornbaker, Tzu L Phang, Laura Saba, Razvan Lapadat, Katherina Kechris, Jeanette Gaydos, 
		Daniel McGoldrick, Andrew Dolbey, Sonia Leach, Brian Soriano, Allison Ellington, Eric Ellington, Kendra Jones, 
		Jonathan Mangion, John K Belknap, Robert W Williams, Lawrence E Hunter, Paula L Hoffman, and Boris Tabakoff, 
		BMC Genetics Aug, 2007&nbsp;&nbsp;&nbsp;<a href="http://www.biomedcentral.com/1471-2156/8/59" target="Citation">BioMed Central</a></p> 

	<p class="indent">(2) PhenoGen Website [Internet]. Aurora (CO): University of Colorado and Denver Health Sciences Center. 
		PhenoGen Informatics, 2005 - [cited (insert date of access)].  
		Available from <a href="http://phenogen.ucdenver.edu"> http://phenogen.ucdenver.edu</a> 
	</p>. 

	<p>Promoter (oPOSSUM):</p> 
	<p class="indent">oPOSSUM: Identification of over-represented transcription factor binding sites in co-expressed genes. <BR>
		Ho-Sui SJ, Mortimer J, Arenillas DJ, Brumm J, Walsh CJ, Kennedy BP and Wasserman WW. 
		Nucleic Acids Res. 2005 Jun 2;33(10):3154-64&nbsp;
		<a href="http://www.ncbi.nlm.nih.gov/pubmed/15933209" target="Citation">PubMed </a>
	</p> <BR>
	<p class="indent">JASPAR: an open access database for eukaryotic transcription factor binding profiles. <BR>
		Albin Sandelin, Wynand Alkema, Pär Engström, Wyeth Wasserman and Boris Lenhard
		Nucleic Acids Res. 2004 Jan; 32(1) Database Issue&nbsp;
		<a href="http://www.ncbi.nlm.nih.gov/pubmed/14681366" target="Citation">PubMed </a>
	</p><BR>


	<p>Promoter (MEME):</p>
	<p class="indent">Fitting a mixture model by expectation maximization to discover motifs in biopolymers<BR> 
		Timothy  L. Bailey  and Charles Elkan,  Proceedings of the Second International Conference on Intelligent Systems 
		for Molecular Biology, (28-36), AAAI Press, 1994.&nbsp;
		<a href="http://www.ncbi.nlm.nih.gov/pubmed/7584402" target="Citation">PubMed </a>
	</p><BR>

	<p>INIA West eQTL Data:</p>
	<p class="indent">QTL Reaper <BR>
		QTL Reaper Project&nbsp;<a href="http://qtlreaper.sourceforge.net/" target="Citation">View </a>
	</p><BR>

	<p>R (used for statistical analysis):</p>
	<p class="indent"> R: A language and environment for statistical computing<BR> 
		R Development Core Team, R Foundation for Statistical Computing, Vienna, Austria, 2005&nbsp;
		<a href="http://www.R-project.org" target="Citation">Website </a>
	</p><BR>

	<p>Bioconductor (used for statistical analysis):</p>
	<p class="indent"> Bioconductor: Open software development for computational biology and bioinformatics <BR> 
		Gentleman RC, Carey VJ, Bates DM, Bolstad B, Dettling M, Dudoit S, Ellis B, Gautier L, Ge Y, Gentry J, 
		Hornik K, Hothorn T, Huber W, Iacus S, Irizarry R, Leisch F, Li C, Maechler M, Rossini AJ, Sawitzki G, Smith C, 
		Smyth G, Tierney L, Yang JYH, and Zhang J (2004).  Genome Biology 5:R80&nbsp;
		<a href="http://www.ncbi.nlm.nih.gov/pubmed/15461798" target="Citation">PubMed </a>
	</p><BR>
        
        <p>CIRCOS:</p>
        <p class="indent"> Circos: An information aesthetic for comparative genomics<BR>
            Martin I Krzywinski, Jacqueline E Schein, Inanc Birol, Joseph Connors, Randy Gascoyne, Doug Horsman, Steven J Jones, and Marco A Marra
Genome Res. Published in Advance June 18, 2009.&nbsp;
            <a href="http://www.ncbi.nlm.nih.gov/pubmed/19541911" target="Citation">PubMed</a>&nbsp;&nbsp;&nbsp;
            <a href="http://circos.ca/" target="Citation">Website</a>
        </p><BR>
        
	<p>Allen Brain Atlas:</p>
	<p class="indent"> Genome-wide atlas of gene expression in the adult mouse brain <BR> 
		Lein ES, Hawrylycz MJ, Ao N, Ayres M, Bensinger A, Bernard A, Boe AF, Boguski MS, Brockway KS, Byrnes EJ, 
		Chen L, Chen L, Chen TM, Chin MC, Chong J, Crook BE, Czaplinska A, Dang CN, Datta S, Dee NR, Desaki AL, Desta T, 
		Diep E, Dolbeare TA, Donelan MJ, Dong HW, Dougherty JG, Duncan BJ, Ebbert AJ, Eichele G, Estin LK, Faber C, Facer BA, 
		Fields R, Fischer SR, Fliss TP, Frensley C, Gates SN, Glattfelder KJ, Halverson KR, Hart MR, Hohmann JG, Howell MP, 
		Jeung DP, Johnson RA, Karr PT, Kawal R, Kidney JM, Knapik RH, Kuan CL, Lake JH, Laramee AR, Larsen KD, Lau C, Lemon TA, 
		Liang AJ, Liu Y, Luong LT, Michaels J, Morgan JJ, Morgan RJ, Mortrud MT, Mosqueda NF, Ng LL, Ng R, Orta GJ, 
		Overly CC, Pak TH, Parry SE, Pathak SD, Pearson OC, Puchalski RB, Riley ZL, Rockett HR, Rowland SA, Royall JJ, 
		Ruiz MJ, Sarno NR, Schaffnit K, Shapovalova NV, Sivisay T, Slaughterbeck CR, Smith SC, Smith KA, Smith BI, Sodt AJ, 
		Stewart NN, Stumpf KR, Sunkin SM, Sutram M, Tam A, Teemer CD, Thaller C, Thompson CL, Varnam LR, 
		Visel A, Whitlock RM, Wohnoutka PE, Wolkey CK, Wong VY, Wood M, Yaylaoglu MB, Young RC, Youngstrom BL, Yuan XF, 
		Zhang B, Zwingman TA, Jones AR. Nature 445: 168-176 (2007)&nbsp; 
		<a href="http://www.ncbi.nlm.nih.gov/pubmed/17151600" target="Citation">PubMed </a>
	</p><BR>

	<p class="indent">If you download specific materials from the website, please add the following citation:</p>
	<p class="indent">(2) Allen Brain Atlas [Internet] Seattle (WA):Allen Institute for Brain Science. © 
		2004-[cited insert date of access]. <BR>Available from: <a href="http://www.brain-map.org">http://www.brain-map.org</a>
	</p><BR> 
	
<%@ include file="/web/common/footer.jsp" %>
