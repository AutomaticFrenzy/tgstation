// ---------- Areas

/area/jungle
	name = "Jungle"
	icon_state = "space"
	has_gravity = TRUE
	outdoors = TRUE
	requires_power = TRUE
	always_unpowered = TRUE
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

	always_unpowered = FALSE
	power_light = TRUE
	blob_allowed = TRUE
	valid_territory = TRUE

/area/shuttle/elevator
	name = "Space Elevator"

/area/shuttle/mech_bay
	name = "Mech Bay Elevator"

/area/engine/atmos/secondary
	name = "Satellite Atmos"

// ---------- Turfs

/turf/open/floor/jungle
	//parent_type = /turf/open/floor/plating/asteroid
	baseturfs = /turf/open/chasm/straight_down/jungle_surface

	name = "jungle floor"
	icon_state = "grass"
	floor_tile = null
	broken_states = list("sand")
	flags_1 = NONE

	planetary_atmos = TRUE

/turf/open/floor/jungle/Initialize()
	..()
	update_icon()

/turf/open/chasm/straight_down/jungle_surface
	icon = 'icons/turf/floors/junglechasm.dmi'
	baseturfs = /turf/open/chasm/straight_down/jungle_surface
	planetary_atmos = TRUE

/turf/open/chasm/straight_down/jungle_surface/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	underlay_appearance.icon_state = "grass"

/turf/open/chasm/straight_down/lava_land_surface/jungle
	icon = 'icons/turf/floors/junglechasm.dmi'
	baseturfs = /turf/open/chasm/straight_down/lava_land_surface/jungle
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"

/turf/open/chasm/straight_down/lava_land_surface/jungle/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	underlay_appearance.icon_state = "grass"

// ---------- Mapping Helpers

/obj/effect/mapping_helpers
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "syndballoon"
	layer = POINT_LAYER

// marks this entire z-level as permanently having gravity
/obj/effect/mapping_helpers/z_gravity
	name = "z-level gravity helper"

/obj/effect/mapping_helpers/z_gravity/Initialize()
	..()
	var/turf/T = get_turf(src)
	if (!GLOB.gravity_generators["[T.z]"])
		GLOB.gravity_generators["[T.z]"] = list()
	GLOB.gravity_generators["[T.z]"] |= "planet"
	return INITIALIZE_HINT_QDEL

/obj/effect/mapping_helpers/z_baseturf
	name = "z-level baseturf editor"
	var/baseturf = null

/obj/effect/mapping_helpers/z_baseturf/Initialize()
	..()
	var/turf/T1 = get_turf(src)
	if (baseturf)
		for (var/turf/T in block(locate(1, 1, T1.z), locate(world.maxx, world.maxy, T1.z)))
			T.PlaceOnBottom(baseturf)
	return INITIALIZE_HINT_QDEL

// ---------- Storage closets

/obj/item/storage/secure/safe/rcd
	name = "RCD safe"
	//max_combined_w_class = 15

/obj/item/storage/secure/safe/PopulateContents()
	new /obj/item/construction/rcd(src)
	for(var/i in 1 to 4)
		new /obj/item/rcd_ammo(src)

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

/obj/machinery/atmospherics/pipe/vertical/attackby(obj/item/W, mob/user, params)
	build_vertical_housing(W, user, params)

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

/obj/machinery/atmospherics/pipe/vertical/proc/vhide(hidden)
	invisibility = hidden ? INVISIBILITY_MAXIMUM : 0
	update_icon()

/obj/machinery/atmospherics/pipe/vertical/atmosinit()
	//ZLEVEL_HELPER(GLOB.vertical_pipes, TRUE)
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
	//ZLEVEL_HELPER(GLOB.vertical_power_conduits)
	merge_with()
	update_icon()

/obj/machinery/power/vertical/Destroy()
	GLOB.vertical_power_conduits -= src
	if (up)
		up.split_from(src)
	if (down)
		down.split_from(src)
	return ..()

/obj/machinery/power/vertical/update_icon()
	//icon_state = "ladder" + (up ? "1" : "0") + (down ? "1" : "0")
	var/turf/T = get_turf(src)
	for (var/obj/structure/vertical_housing/V in T)
		V.update_icon()

/obj/machinery/power/vertical/attackby(obj/item/W, mob/user, params)
	build_vertical_housing(W, user, params)

/obj/machinery/power/vertical/proc/vhide(hidden)
	invisibility = hidden ? INVISIBILITY_MAXIMUM : 0
	update_icon()

/obj/machinery/power/vertical/proc/split_from(obj/machinery/power/vertical/V)
	if (up == V)
		up = null
	else if (down == V)
		down = null
	else
		return

	update_icon()

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

/obj/structure/vertical_housing/Initialize()
	vhide(1)
	update_icon()
	return ..()

/obj/structure/vertical_housing/Destroy()
	vhide(0)
	return ..()

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

/obj/structure/vertical_housing/proc/vhide(hidden)
	var/turf/T = get_turf(src)
	for (var/obj/machinery/atmospherics/pipe/vertical/V in T)
		V.vhide(hidden)
	for (var/obj/machinery/power/vertical/V in T)
		V.vhide(hidden)

/obj/structure/vertical_housing/proc/dismantle()
	playsound(src, 'sound/items/welder.ogg', 100, 1)
	new /obj/item/stack/sheet/metal(get_turf(src), 2)
	qdel(src)

/obj/structure/vertical_housing/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	// get the user's location
	if(!isturf(user.loc))
		return // can't do this stuff whilst inside objects and such

	add_fingerprint(user)

	var/turf/T = user.loc
	if (istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if (WT.use_tool(src, user))
			to_chat(user, "<span class='notice'>You begin slicing through the conduit housing...</span>")
			playsound(src, W.usesound, 100, 1)
			if (do_after(user, 50 * W.toolspeed, target = src))
				if (!src || QDELETED(src) || !user || !WT || !WT.isOn() || !T)
					return 1
				if (user.loc == T && user.get_active_held_item() == WT)
					to_chat(user, "<span class='notice'>You remove the conduit housing.</span>")
					dismantle()
					return 1
	else if (istype(W, /obj/item/gun/energy/plasmacutter))
		to_chat(user, "<span class='notice'>You begin slicing through the conduit housing...</span>")
		playsound(src, W.usesound, 100, 1)
		if (do_after(user, 40 * W.toolspeed, target = src))
			if (!src || QDELETED(src) || !user || !W || !T)
				return 1
			if (user.loc == T && user.get_active_held_item() == W)
				to_chat(user, "<span class='notice'>You remove the conduit housing.</span>")
				dismantle()
				visible_message("The housing was sliced apart by [user]!", "<span class='italics'>You hear metal being sliced apart.</span>")
				return 1

/obj/machinery/proc/build_vertical_housing(obj/item/W, mob/user, params)
	var/obj/item/stack/sheet/S = W
	if (istype(W, /obj/item/stack/sheet/metal))
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two sheets of metal to build a conduit housing!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding plating...</span>")
		if (do_after(user, 40, target = src))
			if (loc == null || S.get_amount() < 2)
				return
			S.use(2)
			to_chat(user, "<span class='notice'>You add the plating.</span>")
			new /obj/structure/vertical_housing(get_turf(src))

// ---------- Door button device for the "toggle" controller

/obj/item/assembly/control/toggle
	name = "toggling blast door controller"

/obj/item/assembly/control/toggle/activate()
	cooldown = 1
	for (var/obj/machinery/door/poddoor/M in GLOB.machines)
		if (M.id == src.id)
			spawn(0)
				if (M)
					if (M.density)
						M.open()
					else
						M.close()
				return
	sleep(10)
	cooldown = 0

// ---------- Compact elevator control console

// Based on shuttle/pod, without the pod-specific stuff
/obj/machinery/computer/shuttle/compact
	name = "compact control computer"
	admin_controlled = 1
	shuttleId = "elevator"
	possible_destinations = "elevator_bottom;elevator_top"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	light_color = LIGHT_COLOR_BLUE
	density = FALSE
	clockwork = TRUE // prevent icon problems if cult'd

/obj/machinery/computer/shuttle/compact/update_icon()
	return

// ---------- Shuttle door interlock controller

// TODO: maybe replace this with a machine and use it for the other shuttles
// (transport, space elevator) too, to control door bolts.

// Combination of poddoor/shuttledock and poddoor/shutters
/obj/machinery/door/poddoor/shuttledock/shutters
	gender = PLURAL
	name = "shutters"
	desc = "Heavy duty metal shutters that open mechanically."
	icon = 'icons/obj/doors/shutters.dmi'
	layer = CLOSED_DOOR_LAYER
	damage_deflection = 20

/obj/machinery/door/poddoor/shuttledock/shutters/New()
	..()
	layer = CLOSED_DOOR_LAYER

/obj/machinery/door/poddoor/shuttledock/shutters/Initialize()
	check()
	. = ..()

/obj/machinery/door/poddoor/shuttledock/shutters/open(ignorepower = 0)
	..()
	layer = CLOSED_DOOR_LAYER

/obj/machinery/door/poddoor/shuttledock/shutters/close(ignorepower = 0)
	..()
	layer = CLOSED_DOOR_LAYER
