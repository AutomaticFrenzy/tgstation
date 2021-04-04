// Info for admins on who is ready or not ready.

/mob/dead/get_status_tab_items()
	. = ..()

	if(SSticker.HasRoundStarted() || !client.holder)
		return

	for(var/mob/dead/new_player/player in GLOB.player_list)
		if (player.ready == PLAYER_READY_TO_PLAY)
			var/job = "no job"

			for (var/datum/job/J in SSjob.occupations)
				if (player.client.prefs.job_preferences[J.title] == JP_HIGH)
					job = J.title
					break

			. += "[player.key]: [player.client.prefs.real_name], [job]"
		else
			. += "[player.key]: NOT READY!"
