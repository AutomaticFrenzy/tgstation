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

// ---------- Z-leveller helper

#define ZLEVEL_HELPER(rest...) \
	var/list/_zlevel_helper = zlevel_helper(up, down, ##rest); \
	up = _zlevel_helper[1]; \
	down = _zlevel_helper[2];

/obj/proc/zlevel_helper(up, down, list/obj/others, requires_dir = FALSE)
	var/static/list/allowed_zlevels = list(2, 3)
	if (!(z in allowed_zlevels) || (up && down))
		return

	for (var/obj/O in others)
		if ((!requires_dir || O.dir == dir) && O.x == x && O.y == y && O.z in allowed_zlevels)
			if (O.z == z + 1)
				down = O
			else if (O.z == z - 1)
				up = O
			if (up && down)
				break
	return list(up, down)

// ---------- Ladder which matches behavior with the rest of this stuff

/obj/structure/ladder/jungle
	anchored = TRUE

/obj/structure/ladder/jungle/LateInitialize()
	ZLEVEL_HELPER(GLOB.ladders)
	update_icon()

// ---------- Atmos z-leveller

GLOBAL_LIST_EMPTY(vertical_pipes)

/obj/machinery/atmospherics/pipe/vertical
	name = "vertical pipe"
	desc = "Transmits gas between levels of the station."
	icon = 'icons/obj/junglestation/vertical-piping.dmi'
	icon_state = "pipe01"
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
	icon_state = "pipe" + (up ? "1" : "0") + (down ? "1" : "0")
	var/turf/T = get_turf(src)
	for (var/obj/structure/vertical_housing/V in T)
		V.update_icon()

/obj/machinery/atmospherics/pipe/vertical/hide()
	update_icon()

/obj/machinery/atmospherics/pipe/vertical/atmosinit()
	ZLEVEL_HELPER(GLOB.vertical_pipes, TRUE)
	. = ..()
	update_icon()

// ---------- Powernet z-leveller

GLOBAL_LIST_EMPTY(vertical_power_conduits)

/obj/machinery/power/vertical
	name = "vertical power conduit"
	desc = "A length of inflexible, insulated cabling for moving power between levels of the station."
	icon = 'icons/obj/junglestation/vertical-wiring.dmi'
	icon_state = "map"
	density = FALSE
	layer = WIRE_TERMINAL_LAYER

	var/obj/machinery/power/vertical/down = null
	var/obj/machinery/power/vertical/up = null

/obj/machinery/power/vertical/Initialize(mapload)
	GLOB.vertical_power_conduits += src
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/power/vertical/LateInitialize()
	ZLEVEL_HELPER(GLOB.vertical_power_conduits)
	merge_with()
	update_icon()

/obj/machinery/power/vertical/Destroy()
	GLOB.vertical_power_conduits -= src
	if (up && up.down == src)
		up.split_from(src)
		up.down = null
		up.update_icon()
	if (down && down.up == src)
		down.split_from(src)
		down.up = null
		down.update_icon()
	return ..()

/obj/machinery/power/vertical/update_icon()
	//icon_state = "ladder" + (up ? "1" : "0") + (down ? "1" : "0")
	var/turf/T = get_turf(src)
	for (var/obj/structure/vertical_housing/V in T)
		V.update_icon()

/obj/machinery/power/vertical/proc/split_from(obj/machinery/power/vertical/V)
	// TODO
	return

/obj/machinery/power/vertical/proc/merge_with()
	if (up)
		if (!up.powernet)
			var/datum/powernet/newPN = new()
			newPN.add_machine(up)
		if (powernet)
			merge_powernets(powernet, up.powernet)
		else
			up.powernet.add_machine(src)

	if (down)
		if (!down.powernet)
			var/datum/powernet/newPN = new()
			newPN.add_machine(down)
		if (powernet)
			merge_powernets(powernet, down.powernet)
		else
			down.powernet.add_machine(src)

/obj/machinery/power/vertical/connect_to_network()
	. = ..()
	if (.)
		merge_with()

/obj/machinery/power/vertical/disconnect_from_network()
	// TODO: is this method needed
	. = ..()
	if (.)
		merge_with()

// ---------- Cosmetic z-leveller for housing vertical conduits

/obj/structure/vertical_housing
	name = "vertical conduit housing"
	desc = "A sturdy metal housing for multilevel conduits."
	icon = 'icons/obj/junglestation/vertical-housing.dmi'
	icon_state = "map"
	layer = 3
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/structure/vertical_housing/Initialize()
	update_icon()

/obj/structure/vertical_housing/update_icon()
	icon_state = "short"
	var/turf/T = get_turf(src)
	for (var/obj/machinery/atmospherics/pipe/vertical/V in T)
		if (V.up)
			icon_state = "tall"
			return
	for (var/obj/machinery/power/vertical/V in T)
		if (V.up)
			icon_state = "tall"
			return
