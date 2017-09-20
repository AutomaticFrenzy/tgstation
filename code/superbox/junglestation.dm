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
	safe = TRUE

	blob_allowed = TRUE
	valid_territory = TRUE

/area/shuttle/elevator
	name = "Space Elevator"

/area/engine/atmos/secondary
	name = "Satellite Atmos"

// ---------- Turfs

// the jungle is in a low twilight
#define JUNGLE_LIGHT_POWER 0.4

/turf/open/floor/jungle
	parent_type = /turf/open/floor/plating/asteroid
	baseturf = /turf/open/chasm/straight_down/jungle_surface

	name = "jungle floor"
	icon_state = "grass"
	floor_tile = null
	broken_states = list("sand")
	flags_1 = NONE

	planetary_atmos = TRUE
	light_power = JUNGLE_LIGHT_POWER
	light_range = MINIMUM_USEFUL_LIGHT_RANGE

/turf/open/floor/jungle/Initialize()
	..()
	update_icon()

/turf/open/chasm/straight_down/jungle_surface
	baseturf = /turf/open/chasm/straight_down/jungle_surface
	planetary_atmos = TRUE
	light_power = JUNGLE_LIGHT_POWER
	light_range = MINIMUM_USEFUL_LIGHT_RANGE

/turf/open/chasm/straight_down/jungle_surface/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	underlay_appearance.icon_state = "grass"

/turf/open/chasm/straight_down/lava_land_surface/jungle
	baseturf = /turf/open/chasm/straight_down/lava_land_surface/jungle
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"

/turf/open/chasm/straight_down/lava_land_surface/jungle/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	underlay_appearance.icon_state = "grass"

// ---------- Mapping Helpers

/obj/effect/baseturf_helper/jungle_surface
	name = "jungle baseturf editor"
	baseturf = /turf/open/chasm/straight_down/jungle_surface

/obj/effect/baseturf_helper/jungle_underground
	name = "jungle underground baseturf editor"
	baseturf = /turf/open/chasm/straight_down/lava_land_surface/jungle

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

// ---------- Storage closets

/obj/item/storage/secure/safe/rcd
	name = "RCD safe"
	max_combined_w_class = 15

/obj/item/storage/secure/safe/PopulateContents()
	new /obj/item/construction/rcd(src)
	for(var/i in 1 to 4)
		new /obj/item/rcd_ammo(src)

// ---------- Atmos z-leveller

GLOBAL_LIST_EMPTY(vertical_pipes)

/obj/machinery/atmospherics/pipe/vertical
	name = "vertical pipe"
	desc = "Transmits gas between levels of the station."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	density = FALSE
	can_unwrench = FALSE // maybe change later
	level = 1

	dir = SOUTH
	initialize_directions = SOUTH
	device_type = UNARY
	can_buckle = FALSE

	var/obj/machinery/atmospherics/pipe/vertical/down = null
	var/obj/machinery/atmospherics/pipe/vertical/up = null

/obj/machinery/atmospherics/pipe/vertical/New()
	GLOB.vertical_pipes += src
	..()

/obj/machinery/atmospherics/pipe/vertical/Destroy()
	GLOB.vertical_pipes -= src
	if (up && up.down == src)
		up.down = null
		QDEL_NULL(up.parent)
		up.build_network()
	if (down && down.up == src)
		down.up = null
		QDEL_NULL(down.parent)
		down.build_network()
	return ..()

/obj/machinery/atmospherics/pipe/vertical/SetInitDirections()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/vertical/pipeline_expansion()
	. = ..()
	if (up)
		. += up
	if (down)
		. += down

/obj/machinery/atmospherics/pipe/vertical/update_icon()
	icon_state = "ladder" + (up ? "1" : "0") + (down ? "1" : "0")

/obj/machinery/atmospherics/pipe/vertical/hide()
	update_icon()

/obj/machinery/atmospherics/pipe/vertical/atmosinit()
	for (var/obj/machinery/atmospherics/pipe/vertical/L in GLOB.vertical_pipes)
		// TODO: restrict Z-levels to prevent shenanigans
		if (L.x == x && L.y == y)
			if (L.z == z + 1)
				down = L
			else if (L.z == z - 1)
				up = L
			if (up && down) // if both connections are filled
				break
	. = ..()
	update_icon()
