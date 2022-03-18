GLOBAL_DATUM_INIT(openspace_backdrop_one_for_all, /atom/movable/openspace_backdrop, new)

/atom/movable/openspace_backdrop
	name			= "openspace_backdrop"

	anchored		= TRUE

	icon            = 'icons/turf/floors.dmi'
	icon_state      = "grey"
	plane           = OPENSPACE_BACKDROP_PLANE
	mouse_opacity 	= MOUSE_OPACITY_TRANSPARENT
	layer           = SPLASHSCREEN_LAYER

/turf/open/transparent/openspace
	name = "open space"
	desc = "Watch your step!"
	icon_state = "transparent"
	baseturfs = /turf/open/transparent/openspace
	CanAtmosPassVertical = ATMOS_PASS_YES
	//mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/can_cover_up = TRUE
	var/can_build_on = TRUE

/turf/open/transparent/openspace/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/transparent/openspace/debug/update_multiz()
	..()
	return TRUE

///No bottom level for openspace.
/turf/open/transparent/openspace/show_bottom_level()
	return FALSE

/turf/open/transparent/openspace/Initialize() // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	is_wall_below()
	vis_contents += GLOB.openspace_backdrop_one_for_all //Special grey square for projecting backdrop darkness filter on it.

/*
Prevents players on higher Zs from seeing into buildings they arent meant to.
*/
/turf/open/transparent/openspace/proc/is_wall_below()
	var/turf/A = SSmapping.get_turf_below(src)
	if(istype(A,/turf/closed/wall))
		opacity = 1
	else
		for(var/obj/O in A.contents)
			if(istype(O,/obj/structure/simple_door))
				opacity = 1

/turf/open/transparent/openspace/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return TRUE
	return FALSE

/turf/open/transparent/openspace/zAirIn()
	return TRUE

/turf/open/transparent/openspace/zAirOut()
	return TRUE

/turf/open/transparent/openspace/zPassIn(atom/movable/A, direction, turf/source)
	return TRUE

/turf/open/transparent/openspace/zPassOut(atom/movable/A, direction, turf/destination)
	if(A.anchored)
		return FALSE
	for(var/obj/O in contents)
		if(O.obj_flags & BLOCK_Z_FALL)
			return FALSE
	return TRUE

/turf/open/transparent/openspace/proc/CanCoverUp()
	return can_cover_up

/turf/open/transparent/openspace/proc/CanBuildHere()
	return can_build_on

/turf/open/transparent/openspace/attackby(obj/item/C, mob/user, params)
	..()
	if(!CanBuildHere())
		return
	if(istype(C, /obj/item/stack/rods))
		var/support
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		var/obj/structure/lattice/catwalk/W = locate(/obj/structure/lattice/catwalk, src)
		if(W)
			to_chat(user, SPAN_WARNING("There is already a catwalk here!"))
			return
		if(L)
			if(R.use(1))
				to_chat(user, SPAN_NOTICE("You construct a catwalk."))
				playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
				new/obj/structure/lattice/catwalk(src)
			else
				to_chat(user, SPAN_WARNING("You need two rods to build a catwalk!"))
			return
		for(var/turf/T in range(2, SSmapping.get_turf_below(src)))
			if(istype(T, /turf/closed))
				support++
				break
		if(support)
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a lattice.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
				ReplaceWithLattice()
			else
				to_chat(user, "<span class='warning'>You need some support under this space to make a lattice.</span>")
		else
			to_chat(user, SPAN_WARNING("You need one rod to build a lattice."))
		return
	if(istype(C, /obj/item/stack/tile/plasteel))
		if(!CanCoverUp())
			return
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
				to_chat(user, SPAN_NOTICE("You build a floor."))
				PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			else
				to_chat(user, SPAN_WARNING("You need one floor tile to build a floor!"))
		else
			to_chat(user, SPAN_WARNING("The plating is going to need some support! Place metal rods first."))

/turf/open/transparent/openspace/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(!CanBuildHere())
		return FALSE

	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
			if(L)
				return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 1)
			else
				return FALSE
	return FALSE

/turf/open/transparent/openspace/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, SPAN_NOTICE("You build a floor."))
			PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
	return FALSE

/turf/open/transparent/openspace/icemoon
	name = "ice chasm"
	baseturfs = /turf/open/transparent/openspace/icemoon
	can_cover_up = TRUE
	can_build_on = TRUE
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/transparent/openspace/icemoon/can_zFall(atom/movable/A, levels = 1, turf/target)
	return TRUE

/turf/open/transparent/openspace/air
	name = "air"
	turf_light_range = 3
	turf_light_power = 0.75
