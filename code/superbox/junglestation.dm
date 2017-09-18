// ---------- Areas

/area/jungle
	name = "Jungle"
	icon_state = "space"
	has_gravity = TRUE
	outdoors = TRUE
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

	blob_allowed = FALSE
	valid_territory = FALSE

/area/jungle/within_compound
	name = "Jungle Compound"
	icon_state = "green"
	blob_allowed = TRUE
	safe = TRUE

	blob_allowed = TRUE
	valid_territory = TRUE

// ---------- Turfs

/turf/open/floor/jungle
	name = "jungle floor"
	//desc = "You can't tell if this is real grass or just cheap plastic imitation."
	icon_state = "grass"
	floor_tile = null
	broken_states = list("sand")
	flags_1 = NONE
	planetary_atmos = TRUE

	// the jungle is in a low twilight
	light_power = 0.4
	light_range = MINIMUM_USEFUL_LIGHT_RANGE

/turf/open/floor/jungle/Initialize()
	..()
	update_icon()

// ---------- Objects

// marks this entire z-level as permanently having gravity
/obj/effect/mapping_helpers/planet_gravity
	name = "planet gravity helper"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "syndballoon"
	layer = POINT_LAYER

/obj/effect/mapping_helpers/planet_gravity/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	if (!GLOB.gravity_generators["[T.z]"])
		GLOB.gravity_generators["[T.z]"] = list()
	GLOB.gravity_generators["[T.z]"] |= "planet"
	qdel(src)
