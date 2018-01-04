// Look up levels[z].traits[trait]
/datum/controller/subsystem/mapping/proc/level_trait(z, trait)
	if (!z)
		return null
	var/list/trait_list
	if (z_list)
		var/datum/space_level/S = get_level(z)
		trait_list = S.traits
	else
		var/list/default_map_traits = DEFAULT_MAP_TRAITS
		trait_list = default_map_traits[z][DL_TRAITS]
	return trait_list[trait]

// Check if levels[z] has any of the specified traits
/datum/controller/subsystem/mapping/proc/has_any_trait(z, list/traits)
	for (var/I in traits)
		if (level_trait(z, I))
			return TRUE
	return FALSE

// Check if levels[z] has all of the specified traits
/datum/controller/subsystem/mapping/proc/has_all_traits(z, list/traits)
	for (var/I in traits)
		if (!level_trait(z, I))
			return FALSE
	return TRUE

// Get a list of all z which have the specified trait
/datum/controller/subsystem/mapping/proc/levels_by_trait(z, trait)
	. = list()
	var/list/_z_list = z_list
	for(var/A in _z_list)
		var/datum/space_level/S = A
		if (S.traits[trait])
			. += S.z_value

// Get a list of all z which have any of the specified traits
/datum/controller/subsystem/mapping/proc/levels_by_any_trait(z, list/traits)
	. = list()
	var/list/_z_list = z_list
	for(var/A in _z_list)
		var/datum/space_level/S = A
		for (var/trait in traits)
			if (S.traits[trait])
				. += S.z_value
				break
