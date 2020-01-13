/obj/structure/booth_seating
	name = "booth seating"
	desc = "Comfortable <i>and</i> snazzy."
	icon = 'icons/superbox/booth_seating.dmi'
	icon_state = "booth"
	anchored = TRUE
	can_buckle = 0
	buckle_lying = 0 //you sit in a chair, not lay
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 25
	layer = OBJ_LAYER
	density = TRUE

/obj/structure/booth_seating/end1
	icon_state = "end1"

/obj/structure/booth_seating/end2
	icon_state = "end2"

/obj/structure/booth_seating/Initialize()
	. = ..()
	add_overlay(mutable_appearance(icon, "[icon_state]_overlay", layer=ABOVE_MOB_LAYER))

/obj/structure/booth_seating/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return TRUE
	if(!(get_dir(target, loc) & dir))
		return TRUE

/obj/structure/booth_seating/CheckExit(atom/movable/O, turf/target)
	if(istype(O) && (O.pass_flags & PASSGLASS))
		return TRUE
	if(get_dir(target, O) & dir)
		return !density
	return TRUE
