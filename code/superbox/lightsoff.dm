//! System for turning off the lights of roundstart unoccupied areas.

SUBSYSTEM_DEF(lightsoff)
	name = "Lights Off"
	init_order = -50
	wait = 10
	runlevels = RUNLEVEL_GAME
	var/datacore_len = -1

/datum/controller/subsystem/lightsoff/fire(resumed)
	if (GLOB.data_core.general.len != datacore_len)
		datacore_len = GLOB.data_core.general.len
		message_admins("Lightsoff debug: crew manifest contains [datacore_len] entries")
		return
	message_admins("Lightsoff debug: matched previous, turning off lights")

	// Fires once after roundstart, due to the default runlevel.
	can_fire = FALSE

	var/list/info = GLOB.lightsoff_info[SSmapping.config.map_name]
	if (!info)
		return

	// combine all candidates into a list
	var/list/lightsoff_areas = list()
	var/list/job_mappings = list()

	for(var/key in info)
		var/value = info[key]
		for(var/job in key)
			job_mappings[job] = value
		lightsoff_areas |= value

	for(var/datum/data/record/record in GLOB.data_core.general)
		var/rank = record.fields["rank"]
		var/datum/job/J = SSjob.GetJob(rank)
		lightsoff_areas -= job_mappings[J?.type]

	for(var/obj/machinery/door/poddoor/M in GLOB.machines)
		if(M.id in lightsoff_areas)
			INVOKE_ASYNC(M, /obj/machinery/door/poddoor.proc/close)

	for(var/area_path in lightsoff_areas)
		var/area/area = GLOB.areas_by_type[area_path]
		if (area)
			area.lightswitch = !area.lightswitch
			area.updateicon()
			for(var/obj/machinery/light_switch/L in area)
				L.update_icon()
			area.power_change()

GLOBAL_LIST_INIT(lightsoff_info, list(
	"SB Station" = list(
		// unconditional
		list() = list(
			/area/maintenance/department/electrical,
			/area/maintenance/disposal,
			/area/security/courtroom,
		),
		// security
		list(/datum/job/hos, /datum/job/officer, /datum/job/warden) = list(
			/area/crew_quarters/heads/hos,
			/area/security/main,
			/area/security/brig,
			"brigfront",
		),
		// cargo
		list(/datum/job/qm, /datum/job/cargo_tech, /datum/job/mining) = list(
			/area/quartermaster/miningdock,
			/area/quartermaster/storage,
		),
		// medical
		list(/datum/job/cmo, /datum/job/doctor, /datum/job/chemist, /datum/job/geneticist) = list(
			/area/crew_quarters/heads/cmo,
			/area/medical/chemistry,
			/area/medical/morgue,
			/area/medical/genetics,
		),
		// science
		list(/datum/job/rd, /datum/job/scientist, /datum/job/roboticist) = list(
			/area/crew_quarters/heads/hor,
			/area/science/research,
			/area/science/server,
			/area/science/xenobiology,
			/area/science/lab,
			/area/science/robotics/lab,
			/area/science/robotics/mechbay,
		),
		// service
		list(/datum/job/bartender, /datum/job/hydro, /datum/job/cook) = list(
			/area/hydroponics,
			/area/crew_quarters/kitchen,
			"kitchen",
		),
		// engineering
		list(/datum/job/chief_engineer, /datum/job/engineer, /datum/job/atmos) = list(
			/area/crew_quarters/heads/chief,
			/area/engine/engineering,
			/area/engine/atmos,
			"ceblast",
		),
		// private offices
		list(/datum/job/lawyer) = list(
			/area/lawoffice,
			"lawyer_blast",
		),
		list(/datum/job/detective) = list(
			/area/security/detectives_office,
			"kanyewest",
		),
		list(/datum/job/janitor) = list(
			/area/janitor,
		),
		list(/datum/job/chaplain) = list(
			/area/chapel/main,
		),
		list(/datum/job/hop) = list(
			/area/crew_quarters/heads/hop,
			"hopline",
		),
		list(/datum/job/captain) = list(
			/area/crew_quarters/heads/captain,
			"captainhall",
		),
	)
))
