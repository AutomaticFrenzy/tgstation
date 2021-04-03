//! System for turning off the lights of roundstart unoccupied areas.

SUBSYSTEM_DEF(lightsoff)
	name = "Lights Off"
	init_order = -50
	wait = 10
	runlevels = RUNLEVEL_GAME

/datum/controller/subsystem/lightsoff/fire(resumed)
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
			area.update_icon()
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
		list(/datum/job/head_of_security, /datum/job/officer, /datum/job/warden, /datum/job/prisoner) = list(
			/area/command/heads_quarters/hos,
			/area/security/warden,
			/area/security/brig,
			"brigfront",
			"hoslock",
		),
		// cargo
		list(/datum/job/quartermaster, /datum/job/cargo_technician, /datum/job/mining) = list(
			/area/cargo/miningdock,
			/area/cargo/storage,
		),
		// medical
		list(/datum/job/chief_medical_officer, /datum/job/doctor, /datum/job/chemist, /datum/job/geneticist) = list(
			/area/command/heads_quarters/cmo,
			/area/medical/chemistry,
			/area/medical/morgue,
			/area/science/genetics,
		),
		// science
		list(/datum/job/research_director, /datum/job/scientist, /datum/job/roboticist) = list(
			/area/command/heads_quarters/rd,
			/area/science/research,
			/area/science/server,
			/area/science/xenobiology,
			/area/science/lab,
			/area/science/robotics/lab,
			/area/science/robotics/mechbay,
		),
		// service
		list(/datum/job/bartender, /datum/job/hydro, /datum/job/cook) = list(
			/area/service/hydroponics,
			/area/service/kitchen,
			"kitchen",
		),
		// engineering
		list(/datum/job/chief_engineer, /datum/job/engineer, /datum/job/atmos) = list(
			/area/command/heads_quarters/ce,
			/area/engineering/main,
			/area/engineering/atmos,
			"ceblast",
		),
		// private offices
		list(/datum/job/lawyer) = list(
			/area/service/lawoffice,
			"lawyer_blast",
		),
		list(/datum/job/detective) = list(
			/area/security/detectives_office,
			"kanyewest",
		),
		list(/datum/job/janitor) = list(
			/area/service/janitor,
		),
		list(/datum/job/chaplain) = list(
			/area/service/chapel/main,
		),
		list(/datum/job/head_of_personnel) = list(
			/area/command/heads_quarters/hop,
			"hopline",
			"hopblast",
		),
		list(/datum/job/captain) = list(
			/area/command/heads_quarters/captain,
			"captainhall",
		),
	)
))
