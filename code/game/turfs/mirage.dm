// General purpose "mirage turf"

/turf/open/indestructible/mirage
    name = "mirage turf"
    mouse_opacity = MOUSE_OPACITY_TRANSPARENT
    invisibility = INVISIBILITY_ABSTRACT
    icon_state = "mirage"

    var/turf/partner

/turf/open/indestructible/mirage/Initialize()
    . = ..()
    partner = find_partner()
    if(!partner || istype(partner, /turf/open/indestructible/mirage))
        ChangeTurf(/turf/open/floor/plasteel)
        return

    density = partner.density
    opacity = partner.opacity

    var/range = 7
    if(istype(get_step(src, dir), /turf/open/indestructible/mirage))
        range = 0
    AddComponent(/datum/component/mirage_border, partner, dir, range)

    partner.AddComponent(/datum/component/redirect,
        list(COMSIG_TURF_CHANGE = CALLBACK(src, .proc/update_partner_properties, TRUE)),
        REDIRECT_TRANSFER_WITH_TURF)
    update_partner_properties()

/turf/open/indestructible/mirage/proc/update_partner_properties(delayed)
    if(delayed)
        addtimer(CALLBACK(src, .proc/update_partner_properties), 1)
        return

    density = partner.density
    opacity = partner.opacity

/turf/open/indestructible/mirage/proc/find_partner()
    return null

/turf/open/indestructible/mirage/Entered(atom/movable/AM)
    ..()
    AM.forceMove(partner)

// Multi-Z stairs

/turf/open/indestructible/mirage/stairs_up
    icon_state = "mirage_up"

/turf/open/indestructible/mirage/stairs_up/find_partner()
    return SSmapping.get_turf_above(src)

/turf/open/indestructible/mirage/stairs_down
    icon_state = "mirage_down"

/turf/open/indestructible/mirage/stairs_down/find_partner()
    return SSmapping.get_turf_below(src)
