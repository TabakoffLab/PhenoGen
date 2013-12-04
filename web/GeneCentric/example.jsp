<%@ include file="/web/common/session_vars.jsp" %>
<H2>New SVG Image Navigation Help</H2>
<div style="text-align:center;">
This will only be displayed automatically once from each computer you use.  After that if you would like to see it use the link in the Customize Image menu.
<BR />
Hold your mouse over each area of the image for a description of what you can do.
</div>

<img src="<%=webDir%>images/gb_example.jpg" width="100%" border="0" usemap="#Map" />
<map name="Map" id="Map">
<area class="helpToolTipster" shape="rect" coords="276,0,725,26" href="#" />
<area class="helpToolTipster" shape="rect" coords="261,47,739,65" href="#" />
<area class="helpToolTipster" shape="rect" coords="867,60,993,88" href="#" />
<area class="helpToolTipster" shape="rect" coords="3,104,987,146" href="#" />
<area class="helpToolTipster" shape="rect" coords="1,208,987,289" href="#" />
<area class="helpToolTipster" shape="rect" coords="245,567,753,595" href="#" />
<area class="helpToolTipster" shape="rect" coords="2,617,272,726" href="#" />
<area class="helpToolTipster" shape="rect" coords="-2,607,3,616" href="#" />
</map>