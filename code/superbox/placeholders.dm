// Placeholders for objects which have been deleted upstream but may eventually
// return.

/obj/structure/cable
	var/category = 0

/obj/structure/cable/white
	// actually green
	color = list(
		1, 0, 0, 0,
		-2, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	)

/obj/structure/cable/yellow
	category = 1
	// actually red
	color = list(
		1, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	)

/obj/item/stack/cable_coil/white
