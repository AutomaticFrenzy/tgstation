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

// ---------- Objects

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

/obj/item/storage/secure/safe/rcd
	name = "RCD safe"
	max_combined_w_class = 15

/obj/item/storage/secure/safe/PopulateContents()
	new /obj/item/construction/rcd(src)
	for(var/i in 1 to 4)
		new /obj/item/rcd_ammo(src)
