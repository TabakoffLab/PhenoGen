<%@ include file="/web/geneLists/include/geneListHeader.jsp"  %>

<jsp:useBean id="myTsample" class="edu.ucdenver.ccp.PhenoGen.data.Tsample"> </jsp:useBean>

<%

	if ((action != null) && action.equals("Create")) {
		int tsample_sysuid = Integer.parseInt((String) request.getParameter("tsample_sysuid"));
		String tsample_id = (String) request.getParameter("tsample_id");
		int tsample_taxid = Integer.parseInt((String) request.getParameter("tsample_taxid"));
		String tsample_cell_provider = (String) request.getParameter("tsample_cell_provider");
		int tsample_sample_type = Integer.parseInt((String) request.getParameter("tsample_sample_type"));
		int tsample_dev_stage = Integer.parseInt((String) request.getParameter("tsample_dev_stage"));
		int tsample_age_status = Integer.parseInt((String) request.getParameter("tsample_age_status"));
		String tsample_agerange_min = (String) request.getParameter("tsample_agerange_min");
		String tsample_agerange_max = (String) request.getParameter("tsample_agerange_max");
		int tsample_time_unit = Integer.parseInt((String) request.getParameter("tsample_time_unit"));
		int tsample_time_point = Integer.parseInt((String) request.getParameter("tsample_time_point"));
		int tsample_organism_part = Integer.parseInt((String) request.getParameter("tsample_organism_part"));
		int tsample_sex = Integer.parseInt((String) request.getParameter("tsample_sex"));
		int tsample_genetic_variation = Integer.parseInt((String) request.getParameter("tsample_genetic_variation"));
		String tsample_individual = (String) request.getParameter("tsample_individual");
		String tsample_individual_gen = (String) request.getParameter("tsample_individual_gen");
		String tsample_disease_state = (String) request.getParameter("tsample_disease_state");
		String tsample_target_cell_type = (String) request.getParameter("tsample_target_cell_type");
		String tsample_cell_line = (String) request.getParameter("tsample_cell_line");
		String tsample_strain = (String) request.getParameter("tsample_strain");
		String tsample_additional = (String) request.getParameter("tsample_additional");
		int tsample_separation_tech = Integer.parseInt((String) request.getParameter("tsample_separation_tech"));
		int tsample_protocolid = Integer.parseInt((String) request.getParameter("tsample_protocolid"));
		int tsample_growth_protocolid = Integer.parseInt((String) request.getParameter("tsample_growth_protocolid"));
		int tsample_exprid = Integer.parseInt((String) request.getParameter("tsample_exprid"));
		String tsample_del_status = (String) request.getParameter("tsample_del_status");
		String tsample_user = (String) request.getParameter("tsample_user");
		java.sql.Timestamp tsample_last_change = (String) request.getParameter("tsample_last_change");

		myTsample.setTsample_sysuid(tsample_sysuid);
		myTsample.setTsample_id(tsample_id);
		myTsample.setTsample_taxid(tsample_taxid);
		myTsample.setTsample_cell_provider(tsample_cell_provider);
		myTsample.setTsample_sample_type(tsample_sample_type);
		myTsample.setTsample_dev_stage(tsample_dev_stage);
		myTsample.setTsample_age_status(tsample_age_status);
		myTsample.setTsample_agerange_min(tsample_agerange_min);
		myTsample.setTsample_agerange_max(tsample_agerange_max);
		myTsample.setTsample_time_unit(tsample_time_unit);
		myTsample.setTsample_time_point(tsample_time_point);
		myTsample.setTsample_organism_part(tsample_organism_part);
		myTsample.setTsample_sex(tsample_sex);
		myTsample.setTsample_genetic_variation(tsample_genetic_variation);
		myTsample.setTsample_individual(tsample_individual);
		myTsample.setTsample_individual_gen(tsample_individual_gen);
		myTsample.setTsample_disease_state(tsample_disease_state);
		myTsample.setTsample_target_cell_type(tsample_target_cell_type);
		myTsample.setTsample_cell_line(tsample_cell_line);
		myTsample.setTsample_strain(tsample_strain);
		myTsample.setTsample_additional(tsample_additional);
		myTsample.setTsample_separation_tech(tsample_separation_tech);
		myTsample.setTsample_protocolid(tsample_protocolid);
		myTsample.setTsample_growth_protocolid(tsample_growth_protocolid);
		myTsample.setTsample_exprid(tsample_exprid);
		myTsample.setTsample_del_status(tsample_del_status);
		myTsample.setTsample_user(tsample_user);
		myTsample.setTsample_last_change(tsample_last_change);
		myTsample.createTsample(dbConn);
		mySessionHandler.createExperimentActivity("Created sample record", dbConn); 
		session.setAttribute("successMsg", "XXX-XXX");
		response.sendRedirect(commonDir + "successMsg.jsp");
	}
%>

<%@ include file="/web/common/headTags.jsp"%>

	<form method="post"
		name="Tsample"
		action="createTsample.jsp"
		enctype="application/x-www-form-urlencoded">

	<div class="page-intro">
		<p>Fill in the form below to create a new Tsample.
		</p>
	</div> <!-- // end page-intro -->
	<div class="brClear"></div>

	<table name="items" class="list_base" cellpadding="0" cellspacing="3" >
		<tr>
			<td valign="top"> <strong>Tsample sysuid:</strong> </td>
			<td> <input type="text" name="tsample_sysuid"> </td>
		</tr>
			<td valign="top"> <strong>Tsample id:</strong> </td>
			<td> <input type="text" name="tsample_id"> </td>
		</tr>
			<td valign="top"> <strong>Tsample taxid:</strong> </td>
			<td> <input type="text" name="tsample_taxid"> </td>
		</tr>
			<td valign="top"> <strong>Tsample cell provider:</strong> </td>
			<td> <input type="text" name="tsample_cell_provider"> </td>
		</tr>
			<td valign="top"> <strong>Tsample sample type:</strong> </td>
			<td> <input type="text" name="tsample_sample_type"> </td>
		</tr>
			<td valign="top"> <strong>Tsample dev stage:</strong> </td>
			<td> <input type="text" name="tsample_dev_stage"> </td>
		</tr>
			<td valign="top"> <strong>Tsample age status:</strong> </td>
			<td> <input type="text" name="tsample_age_status"> </td>
		</tr>
			<td valign="top"> <strong>Tsample agerange min:</strong> </td>
			<td> <input type="text" name="tsample_agerange_min"> </td>
		</tr>
			<td valign="top"> <strong>Tsample agerange max:</strong> </td>
			<td> <input type="text" name="tsample_agerange_max"> </td>
		</tr>
			<td valign="top"> <strong>Tsample time unit:</strong> </td>
			<td> <input type="text" name="tsample_time_unit"> </td>
		</tr>
			<td valign="top"> <strong>Tsample time point:</strong> </td>
			<td> <input type="text" name="tsample_time_point"> </td>
		</tr>
			<td valign="top"> <strong>Tsample organism part:</strong> </td>
			<td> <input type="text" name="tsample_organism_part"> </td>
		</tr>
			<td valign="top"> <strong>Tsample sex:</strong> </td>
			<td> <input type="text" name="tsample_sex"> </td>
		</tr>
			<td valign="top"> <strong>Tsample genetic variation:</strong> </td>
			<td> <input type="text" name="tsample_genetic_variation"> </td>
		</tr>
			<td valign="top"> <strong>Tsample individual:</strong> </td>
			<td> <input type="text" name="tsample_individual"> </td>
		</tr>
			<td valign="top"> <strong>Tsample individual gen:</strong> </td>
			<td> <input type="text" name="tsample_individual_gen"> </td>
		</tr>
			<td valign="top"> <strong>Tsample disease state:</strong> </td>
			<td> <input type="text" name="tsample_disease_state"> </td>
		</tr>
			<td valign="top"> <strong>Tsample target cell type:</strong> </td>
			<td> <input type="text" name="tsample_target_cell_type"> </td>
		</tr>
			<td valign="top"> <strong>Tsample cell line:</strong> </td>
			<td> <input type="text" name="tsample_cell_line"> </td>
		</tr>
			<td valign="top"> <strong>Tsample strain:</strong> </td>
			<td> <input type="text" name="tsample_strain"> </td>
		</tr>
			<td valign="top"> <strong>Tsample additional:</strong> </td>
			<td> <input type="text" name="tsample_additional"> </td>
		</tr>
			<td valign="top"> <strong>Tsample separation tech:</strong> </td>
			<td> <input type="text" name="tsample_separation_tech"> </td>
		</tr>
			<td valign="top"> <strong>Tsample protocolid:</strong> </td>
			<td> <input type="text" name="tsample_protocolid"> </td>
		</tr>
			<td valign="top"> <strong>Tsample growth protocolid:</strong> </td>
			<td> <input type="text" name="tsample_growth_protocolid"> </td>
		</tr>
			<td valign="top"> <strong>Tsample exprid:</strong> </td>
			<td> <input type="text" name="tsample_exprid"> </td>
		</tr>
			<td valign="top"> <strong>Tsample del status:</strong> </td>
			<td> <input type="text" name="tsample_del_status"> </td>
		</tr>
			<td valign="top"> <strong>Tsample user:</strong> </td>
			<td> <input type="text" name="tsample_user"> </td>
		</tr>
			<td valign="top"> <strong>Tsample last change:</strong> </td>
			<td> <input type="text" name="tsample_last_change"> </td>
		</tr>
<input type="submit" name="action" value="Create">
</form>
