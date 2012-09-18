/* --------------------------------------------------------------------------------
 *
 *  specific functions for cluster.jsp
 *
 * -------------------------------------------------------------------------------- */
/* * *
 *  Sets up the "Save" button to save cluster results
/*/
function setupSaveButton() {
	$("div#saveClusterResults").click(function(){
		var previousAction = $("input[name='action']").val();
		$("input[name='action']").val("Save Cluster Results");
		$("form[name='cluster']").submit();
		$("input[name='action']").val(previousAction);
	});
}

/* * *
 *  sets up the save genelist modal
/*/
function setupSaveGeneList() {
	// setup save gene list button
	$("div[id='saveGeneList']").click(function(){
		var previousAction = $("input[name='action']").val();
		$("input[name='action']").val("Save Gene List");
		$("form[name='clusterResults']").submit();
		$("input[name='action']").val(previousAction);
	});
}

/* * *
 *  sets up the save new genelist for a cluster modal
/*/
function setupSaveClusterGeneList() {
	var newList;
	// setup save new gene list button
	$("div[name='saveClusterGeneList']").click(function(){
        	if ( newList == undefined ) {
			newList = createDialog("div.saveClusterList" , {width: 600, height: 400, title: "<center>Save Gene List</center>"});
		}
		var clusterNumber = $(this).attr("id");
		var datasetID = $("input[name='datasetID']").val();
		var datasetVersion = $("input[name='datasetVersion']").val();
		var clusterGroupID = $("input[name='newParameterGroupID']").val();
		var numGroups = $("input[name='numGroups']").val();
		var parameters = {clusterNumber: clusterNumber, 
				datasetID: datasetID,
				datasetVersion: datasetVersion,
				numGroups: numGroups,
				clusterGroupID: clusterGroupID};

		// Need to do path like this ==> otherwise ajax will log out of session
        	$.get(contextPath + "/web/datasets/saveClusterGeneList.jsp", 
			parameters, 
			function(data){
				newList.dialog("open").html(data);
				closeDialog(newList);
        	});
	});
}

// Display valid values for cluster object based on choice for group or sample means
function displayClusterObject() {
	var duration_method = $("select[name='cluster_method']").val();
	var cluster_method = $("select[name='cluster_method']").val();
	var clusterObjectHierarchField = $("select[name='clusterObjectHierarch']");
	var clusterObjectKmeansField = $("select[name='clusterObjectKmeans']");
	var groupMeansHierarchField = $("select[name='groupMeansHieararch']");
	var groupMeansKmeansField = $("select[name='groupMeansKmeans']");

	if (cluster_method == 'hierarch') { 
		$("div#hierarchic_div").show();
        	$("div#kmeans_div").hide();
		duration_method = duration_method + clusterObjectHierarchField.val();
	} else {
		$("div#hierarchic_div").hide();
        	$("div#kmeans_div").show();
		duration_method = duration_method + clusterObjectKmeansField.val();
	}
	populateDuration(duration_method, document.cluster);
	var clusterObjectField;
	var groupMeansField;
        if (cluster_method == 'hierarch') {
		clusterObjectField = clusterObjectHierarchField; 
		groupMeansField = groupMeansHierarchField; 
	} else { 
		clusterObjectField = clusterObjectKmeansField; 
		groupMeansField = groupMeansKmeansField; 
	}
	if (clusterObjectField.val() == 'groups') {
		if (groupMeansField.val() != 'NA') { 
			groupMeansField.val('TRUE');
		}
	} else if (clusterObjectField.val() == 'samples') {
		if (groupMeansField.val() != 'NA') {
			groupMeansField.val('FALSE');
		}
	}
}

// show the number of groups field
function displayNumberOfClusters() {
	var numClusters = $("input[name='numClustersHierarch']");
	var clusterObjectHierarch = $("select[name='clusterObjectHierarch']");
        if (clusterObjectHierarch.val() == 'both') {
        	numClusters.val('N/A');
		disableField(numClusters);
	} else {
		if (numClusters.val() == 'N/A') {
        		numClusters.val('');
		}
		enableField(numClusters);
	}
}

function displayOnLoad(){
	$("div#top_cluster_div").show();
	var cluster_method = $("select[name='cluster_method']").val();
	if (cluster_method == "hierarch") {
		$("div#hierarchic_div").show();
        	$("div#kmeans_div").hide();
	} else {
        	$("div#kmeans_div").show();
		$("div#hierarchic_div").hide();
	}
	// Don't want this because it removes previously-selected values
	//displayClusterObject();
	displayNumberOfClusters();
}

function IsClusterFormComplete(){
        if (document.cluster.cluster_method.value == 'hierarch') { 
		var numClustersField = document.cluster.numClustersHierarch;
		var clusterObject = document.cluster.clusterObjectHierarch;
		var groupMeans = document.cluster.groupMeansHierarch;
	} else {
		var numClustersField = document.cluster.numClustersKmeans;
		var clusterObject = document.cluster.clusterObjectKmeans;
		var groupMeans = document.cluster.groupMeansKmeans;
	}
	var numClusters = numClustersField.value;
	var number_of_arrays = document.cluster.number_of_arrays.value - document.cluster.number_of_excluded_arrays.value;
	var number_of_groups = document.cluster.number_of_groups.value;
	var number_of_probes = document.cluster.number_of_probes.value;
	if (numClusters == parseInt(numClusters)) {
		numClusters = parseInt(numClusters);
		if (numClusters <= 1) { 
			alert('You must enter a value greater than 1 for the number of clusters.')
	        	numClustersField.focus();
			return false; 
		} else {
			if (clusterObject.value == 'samples' && numClusters >= number_of_arrays) {
				alert('Since you are clustering on samples, the number of clusters must be less than ' +
					number_of_arrays + ', the number of samples.')
	        		numClustersField.focus();
				return false; 
			} else if (clusterObject.value == 'groups' && numClusters >= number_of_groups) {
				alert('Since you are clustering on groups, the number of clusters must be less than ' +
					number_of_groups + ', the number of groups.');
	        		numClustersField.focus();
				return false; 
			} else if (clusterObject.value == 'genes' && number_of_probes > 5000) {
				alert('Due to system limitations, you cannot cluster on probes if you have '+
					'more than 5000 probes.  You may reduce the number of probes by applying '+
					'another filter or instead cluster by samples or groups');
	        		numClustersField.focus();
				return false; 
			} else if (clusterObject.value == 'genes' && numClusters >= number_of_probes) {
				alert('Since you are clustering on probes, the number of clusters must be less than ' +
					number_of_probes + ', the number of probes.')
	        		numClustersField.focus();
				return false; 
			}
		}
	} else {
		if (clusterObject.value == 'both') {
			if (number_of_probes > 2000) {
				alert('Due to system limitations, you cannot cluster on \'both\' if you have '+
						'more than 2000 probes.  You may reduce the number of probes by applying '+
						'another filter or instead cluster by samples or groups');
	        		clusterObject.focus();
				return false; 
			}
		} else {
			alert('You must enter an integer value greater than 0 for the number of clusters.')
	        	numClustersField.focus();
			return false; 
		}
	}
	if (number_of_probes < 2) {
		alert('You must have at least 2 probes in order to perform a cluster analysis.')
		return false; 
	} 
	CallJS('Demo(document.cluster)');
	return true;
}

