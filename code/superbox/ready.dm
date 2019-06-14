// Info for admins on who is ready or not ready.

/mob/dead/Stat()
	..()
	if(!statpanel("Status") || SSticker.HasRoundStarted() || !client.holder)
		return

	for(var/mob/dead/new_player/player in GLOB.player_list)
		if (player.ready == PLAYER_READY_TO_PLAY)
			var/job = "no job"

			for (var/datum/job/J in SSjob.occupations)
				if (player.client.prefs.job_preferences[J.title] == JP_HIGH)
					job = J.title
					break

			stat("[player.key]", "[player.client.prefs.real_name], [job]")
		else
			stat("[player.key]", "NOT READY!")
