/datum/team/xeno
	name = "Aliens"

//Simply lists them.
/datum/team/xeno/roundend_report()
	var/list/parts = list()
	var/success = SSshuttle.emergency.is_hijacked_by_xenos()
	parts += "<span class='header'>The [name] [success ? "have <span class='greentext'>succeeded!</span>" : "have <span class='redtext'>failed!</span>"]</span>\n"
	parts += "<b>[success ? "The Queen has left the station alive and the colony will continue to spread!" : "The remnants of the colony will wither in isolation"]</b>"
	parts += "The [name] were:"
	parts += printplayerlist(members)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/xeno
	name = "Xenomorph"
	job_rank = ROLE_ALIEN
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	var/datum/team/xeno/xeno_team

/datum/antagonist/xeno/create_team(datum/team/xeno/new_team)
	if(!new_team)
		for(var/datum/antagonist/xeno/X in GLOB.antagonists)
			if(!X.owner || !X.xeno_team)
				continue
			xeno_team = X.xeno_team
			return
		xeno_team = new
	else
		if(!istype(new_team))
			CRASH("Wrong xeno team type provided to create_team")
		xeno_team = new_team

/datum/antagonist/xeno/get_team()
	return xeno_team

//XENO
/mob/living/carbon/alien/mind_initialize()
	..()
	if(!mind.has_antag_datum(/datum/antagonist/xeno))
		mind.add_antag_datum(/datum/antagonist/xeno)
