GLOBAL_LIST_EMPTY(hivehosts)
GLOBAL_LIST_EMPTY(avessels)
/datum/game_mode/hivemind
	name = "Assimilation"
	config_tag = "hivemind"
	report_type = "hivemind"
	antag_flag = ROLE_HIVE
	false_report_weight = 5
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	restricted_jobs = list("Cyborg","AI")
	required_players = 24
	required_enemies = 2
	recommended_enemies = 3
	reroll_friendly = 1
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "The hosts of several psionic hiveminds have infiltrated the station and are looking to assimilate the crew!\n\
	<span class='danger'>Hosts</span>: Expand your hivemind and complete your objectives at all costs!\n\
	<span class='notice'>Crew</span>: Prevent the hosts from getting into your mind!"

	var/list/hosts = list()

/proc/is_hivehost(mob/living/M)
	if(!M || !M.mind)
		return
	return M.mind.has_antag_datum(/datum/antagonist/hivemind)

/mob/living/proc/is_real_hivehost()
	for(var/datum/antagonist/hivemind/hive as() in GLOB.hivehosts)
		if(!hive.owner?.spell_list)
			continue
	return FALSE

/mob/living/proc/get_real_hivehost() //Returns src
	var/mob/living/M = src
	if(!M)
		return
	if(!is_hivehost(M) || is_real_hivehost(M))
		return M

	return M

/proc/is_hivemember(mob/living/L)
	if(!L)
		return FALSE
	var/datum/mind/M = L.mind
	if(!M)
		return FALSE
	for(var/datum/antagonist/hivemind/H as() in GLOB.hivehosts)
		if(H.hivemembers.Find(M))
			return TRUE
	return FALSE

/proc/remove_hivemember(mob/living/L) //Removes somebody from all hives as opposed to the antag proc remove_from_hive()
	var/datum/mind/M = L?.mind
	if(!M)
		return
	for(var/datum/antagonist/hivemind/H as() in GLOB.hivehosts)
		if(H.hivemembers.Find(M))
			H.hivemembers -= M
			H.calc_size()
	var/datum/antagonist/hivevessel/V = L.is_wokevessel()
	if(V && M)
		M.remove_antag_datum(/datum/antagonist/hivevessel)

/datum/game_mode/hivemind/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		restricted_jobs += GLOB.command_positions

	var/num_hosts = max( 1 , rand(0,1) + min(8, round(num_players() / 8) ) ) //1 host for every 8 players up to 64, with a 50% chance of an extra

	for(var/j = 0, j < num_hosts, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/host = antag_pick(antag_candidates, ROLE_HIVE)
		hosts += host
		host.special_role = ROLE_HIVE
		host.restricted_roles = restricted_jobs
		log_game("[key_name(host)] has been selected as a hivemind host")
		antag_candidates.Remove(host)

	if(hosts.len < required_enemies)
		setup_error = "Not enough host candidates"
		return FALSE
	else
		return TRUE


/datum/game_mode/hivemind/post_setup()
	for(var/datum/mind/i in hosts)
		i.add_antag_datum(/datum/antagonist/hivemind)
	return ..()

/datum/game_mode/hivemind/generate_report()
	return "Reports of psychic activity have been showing up in this sector, and we believe this may have to do with a containment breach on \[REDACTED\] last month \
		when a sapient hive intelligence displaying paranormal powers escaped into the unknown. They present a very large risk as they can assimilate people into \
		the hivemind with ease, although they appear unable to affect mindshielded personnel."

/datum/game_mode/hivemind/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	for(var/datum/antagonist/hivemind/H as() in GLOB.hivehosts)
		if(H.hiveID == "Hivemind")
			continue
		round_credits += "<center><h1>Hive [H.hiveID]:</h1>"
		len_before_addition = round_credits.len
		round_credits += "<center><h2>[H.name] as the Hivemind Host</h2>"
		for(var/datum/antagonist/hivevessel/V as() in GLOB.hivehosts)
			if(V.hiveID == H.hiveID)
				round_credits += "<center><h2>[V.name] as an Awakened Vessel</h2>"
		if(len_before_addition == round_credits.len)
			round_credits += list("<center><h2>Hive [H.hiveID] couldn't withstand the competition!</h2>")
		round_credits += "<br>"

	round_credits += ..()
	return round_credits
