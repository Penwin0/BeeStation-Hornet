/client/proc/generateArchimundi()
	set name = "Generate Archimundi"
	set desc = "Deletes the Station and Generates Archimundi DO NOT PRESS LIGHTLY"
	set category = "Fun"

	if(!check_rights(R_PERMISSIONS))
		return
	log_admin("[key_name(usr)] Started generating Archimundi.")
	SSzclear.wipe_z_level(2)
	LoadArchimundi()
	log_admin("[key_name(usr)] Generated Archimundi.")

/proc/LoadArchimundi()
	//Don't load archimundi twice in case something happens
	var/static/archimundi_loaded = FALSE
	if(archimundi_loaded)
		return
	var/datum/map_template/template = new("_maps/map_files/RadStation/ArchimundiStation.dmm", "Archimundi")
	template.load_new_z(null, ZTRAITS_STATION)
	archimundi_loaded = TRUE
