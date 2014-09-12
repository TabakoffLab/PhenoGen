<%@ include file="/web/common/anon_session_vars.jsp" %>
<style>
.popup{
  background:#fafafa;
  border:1px solid #444;
  border-radius:6px;
  padding:10px;
  position:absolute;
  display:none;
  width:250px;
}
</style>

<H2>New SVG Image Navigation Help</H2>
<div style="text-align:center;">
This will only be displayed automatically once from each computer you use.  After that if you would like to see it use the link in the Customize Image menu.
<BR />
Hold your mouse over each area of the image for a description of what you can do.
</div>

<img src="../images/gb_example.jpg" width="800px" border="0" usemap="#Map" />
<map name="Map" id="Map"><area shape="rect" coords="221,-5,579,20" href="#" alt="view" /><area shape="rect" coords="208,37,590,51" href="#" alt="button" /><area shape="rect" coords="694,48,794,70" href="#" /><area shape="rect" coords="2,84,789,115" href="#" /><area shape="rect" coords="2,166,790,231" href="#" /><area shape="rect" coords="195,451,603,476" href="#" /><area shape="rect" coords="0,491,219,581" href="#" /></map>

<div id="view" style="display:none;">
	This is the view.
</div>

<div id="button" style="display:none;">
	button
</div>

<div class="popup"></div>
<script type="text/javascript">
	var $popup = $('.popup');
    $('area').on({
      mouseover : function(e){
        var $this = $(this),
            $obj = $('#'+$this.prop('alt'));
        $popup.text($obj.text()).css({
          top: e.pageY + 25,
          left: e.pageX - ($popup.width()/2),
        }).show();
      },
      mouseout: function(){
        var $this = $(this),
            $obj = $('#'+$this.prop('alt'));          
        $popup.hide(0).empty();
      }
    });
</script>