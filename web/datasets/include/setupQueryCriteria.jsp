<%
                //
                // Fill up the attributes HashMap to get the arrays from the database 
                //
                if ((String) fieldValues.get("organism") != null && !((String) fieldValues.get("organism")).equals("")) {
                        attributes.put("Organism", (String) fieldValues.get("organism"));
                }
                if ((String) fieldValues.get("cellLine") != null && !((String) fieldValues.get("cellLine")).equals("")) {
                        attributes.put("CellLine", (String) fieldValues.get("cellLine"));
                }
                if ((String) fieldValues.get("geneticVariation") != null && !((String) fieldValues.get("geneticVariation")).equals("")) {
                        attributes.put("GeneticVariation", (String) fieldValues.get("geneticVariation"));
                }
                if ((String) fieldValues.get("geneticType") != null && !((String) fieldValues.get("geneticType")).equals("")) {
                        attributes.put("GeneticType", (String) fieldValues.get("geneticType"));
                }
                if ((String) fieldValues.get("sex") != null && !((String) fieldValues.get("sex")).equals("")) {
                        attributes.put("Sex", (String) fieldValues.get("sex"));
                }
                if ((String) fieldValues.get("organismPart") != null && !((String) fieldValues.get("organismPart")).equals("")) {
                        attributes.put("OrganismPart", (String) fieldValues.get("organismPart"));
                }
                if ((String) fieldValues.get("genotype") != null && !((String) fieldValues.get("genotype")).equals("")) {
                        attributes.put("Genotype", (String) fieldValues.get("genotype"));
                }
                if ((String) fieldValues.get("strain") != null && !((String) fieldValues.get("strain")).equals("")) {
                        attributes.put("Strain", (String) fieldValues.get("strain"));
                }
                if ((String) fieldValues.get("treatment") != null && !((String) fieldValues.get("treatment")).equals("")) {
                        attributes.put("Treatment", (String) fieldValues.get("treatment"));
                }
                if ((String) fieldValues.get("compound") != null && !((String) fieldValues.get("compound")).equals("")) {
                        attributes.put("Compound", (String) fieldValues.get("compound"));
                }
                if ((String) fieldValues.get("dose") != null && !((String) fieldValues.get("dose")).equals("")) {
                        attributes.put("Dose", (String) fieldValues.get("dose"));
		}
                if ((String) fieldValues.get("duration") != null && !((String) fieldValues.get("duration")).equals("")) {
                        attributes.put("Duration", (String) fieldValues.get("duration"));
		}
                if ((String) fieldValues.get("arrayName") != null && !((String) fieldValues.get("arrayName")).equals("")) {
                        attributes.put("ArrayName", "%"+(String) fieldValues.get("arrayName")+"%");
                }
                if ((String) fieldValues.get("experimentName") != null && !((String) fieldValues.get("experimentName")).equals("")) {
                        attributes.put("ExperimentName", (String) fieldValues.get("experimentName"));
                }
                if ((String) fieldValues.get("experimentDesignType") != null && !((String) fieldValues.get("experimentDesignType")).equals("")) {
                        attributes.put("ExperimentDesignType", (String) fieldValues.get("experimentDesignType"));
                }
                if ((String) fieldValues.get("arrayType") != null && !((String) fieldValues.get("arrayType")).equals("")) {
                        attributes.put("ArrayType", (String) fieldValues.get("arrayType"));
                }
                if ((String) fieldValues.get("channel") != null && !((String) fieldValues.get("channel")).equals("")) {
                        attributes.put("Channel", (String) fieldValues.get("channel"));
                }
                if ((String) fieldValues.get("publicOrPrivate") != null && !((String) fieldValues.get("publicOrPrivate")).equals("")) {
                        attributes.put("PublicOrPrivate", (String) fieldValues.get("publicOrPrivate"));
                }
                if ((String) fieldValues.get("subordinates") != null && !((String) fieldValues.get("subordinates")).equals("")) {
                        attributes.put("Principal Investigator", (String) fieldValues.get("subordinates"));
                }


		session.setAttribute("attributes", attributes);

%>


