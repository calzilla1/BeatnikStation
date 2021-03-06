//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:
RCD
*/
/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build and deconstruct walls and floors."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0
	flags = CONDUCT
	force = 10
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = 3
	materials = list(MAT_METAL=100000)
	origin_tech = "engineering=4;materials=2"
	var/max_matter = 100
	var/matter = 0
	var/working = 0
	var/mode = 1
	var/canRwall = 0
	var/menu = 1
	var/door_type = /obj/machinery/door/airlock
	var/door_name = "airlock"
	req_access = list(access_engine)
	var/list/door_accesses = list()
	var/list/door_accesses_list = list()
	var/one_access
	var/locked = 1
	var/list/allowed_door_types = list(/obj/machinery/door/airlock = "Standard",
		/obj/machinery/door/airlock/command = "Command", /obj/machinery/door/airlock/security = "Security",
		/obj/machinery/door/airlock/engineering = "Engineering", /obj/machinery/door/airlock/medical = "Medical",
		/obj/machinery/door/airlock/maintenance = "Maintenance", /obj/machinery/door/airlock/external = "External",
		/obj/machinery/door/airlock/glass = "Standard (Glass)", /obj/machinery/door/airlock/freezer = "Freezer",
		/obj/machinery/door/airlock/glass_command = "Command (Glass)", /obj/machinery/door/airlock/glass_engineering = "Engineering (Glass)",
		/obj/machinery/door/airlock/glass_security = "Security (Glass)", /obj/machinery/door/airlock/glass_medical = "Medical (Glass)",
		/obj/machinery/door/airlock/mining = "Mining", /obj/machinery/door/airlock/atmos = "Atmospherics",
		/obj/machinery/door/airlock/research = "Research", /obj/machinery/door/airlock/glass_research = "Research (Glass)",
		/obj/machinery/door/airlock/glass_mining = "Mining (Glass)", /obj/machinery/door/airlock/glass_atmos = "Atmospherics (Glass)")

/obj/item/weapon/rcd/New()
	desc = "An RCD. It currently holds [matter]/[max_matter] matter-units."
	rcd_list += src
	door_accesses_list = list()
	for(var/access in get_all_accesses())
		door_accesses_list[++door_accesses_list.len] = list("name" = get_access_desc(access), "id" = access, "enabled" = (access in door_accesses))
	return ..()

/obj/item/weapon/rcd/Destroy()
	rcd_list -= src
	return ..()

/obj/item/weapon/rcd/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/rcd_ammo))
		var/loadamt = 10
		if(istype(W, /obj/item/weapon/rcd_ammo/large))
			loadamt = 30 //makes lyfe easier
		var/obj/item/weapon/rcd_ammo/R = W
		if(matter >= max_matter)
			matter = max_matter
			user << "<span class='danger'>The [src] is full!</span>"
			return
		if(R.ammoamt < loadamt && max_matter - matter >= R.ammoamt)
			loadamt = R.ammoamt
			R.ammoamt -= R.ammoamt
			qdel(W)
		else if(max_matter - matter < loadamt)
			loadamt = max_matter - matter
			R.ammoamt -= max_matter - matter
			R.desc = "Highly compressed matter for the RCD. It currently has [R.ammoamt] units left."
		else
			R.ammoamt -= loadamt
			R.desc = "Highly compressed matter for the RCD. It currently has [R.ammoamt] units left."
		if(R.ammoamt <= 0)
			qdel(W)
		matter += loadamt
		user << "<span class='notice'>You load [loadamt] units into the RCD. It now holds [matter]/[max_matter] matter-units.</span>"
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		desc = "An RCD. It currently holds [matter]/[max_matter] matter-units."
		SSnano.update_uis(src)
		return


/obj/item/weapon/rcd/attack_self(mob/user)
	//Change the mode
	ui_interact(user)

/obj/item/weapon/rcd/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/list/data = list()
	data["mode"] = mode
	data["door_type"] = door_type
	data["menu"] = menu
	data["matter"] = matter
	data["max_matter"] = max_matter
	data["one_access"] = one_access
	data["locked"] = locked
	data["door_name"] = door_name

	if(menu == 2)
		var/list/door_types_list = list()
		for(var/type in allowed_door_types)
			door_types_list[++door_types_list.len] = list("name" = allowed_door_types[type], "type" = type)
		data["allowed_door_types"] = door_types_list

		data["door_accesses"] = door_accesses_list

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "rcd.tmpl", "[name]", 430, 400)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/item/weapon/rcd/Topic(href, href_list, nowindow, state)
	if(..())
		return 1

	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
		. = 1

	if(href_list["door_type"])
		var/new_door_type = text2path(href_list["door_type"])
		if(!(new_door_type in allowed_door_types))
			message_admins("RCD HREF exploit attempted by [key_name(usr, usr.client)]!")
			return
		door_type = new_door_type
		var/list/split_text = list()
		split_text = splittext(href_list["door_type"], "/")
		for(var/N in split_text)
			door_name = N
		. = 1

	if(href_list["menu"])
		menu = text2num(href_list["menu"])
		. = 1
	if(href_list["login"])
		if(istype(usr,/mob/living/silicon))
			locked = 0
		else
			var/obj/item/I = usr.get_active_hand()
			if(istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			var/obj/item/weapon/card/id/ID = I
			if(istype(ID) && ID && check_access(ID))
				locked = 0
		. = 1

	if(href_list["logout"])
		locked = 1
		. = 1

	if(href_list["toggle_one_access"] && !locked)
		one_access = !one_access
		. = 1

	if(href_list["toggle_access"] && !locked)
		var/href_access = text2num(href_list["toggle_access"])
		if(href_access in door_accesses)
			door_accesses -= href_access
		else
			door_accesses += href_access
		door_accesses_list = list()
		for(var/access in get_all_accesses())
			door_accesses_list[++door_accesses_list.len] = list("name" = get_access_desc(access), "id" = access, "enabled" = (access in door_accesses))
		. = 1

/obj/item/weapon/rcd/proc/activate()
	playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)


/obj/item/weapon/rcd/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return 0
	if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
		return 0
	if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/window)))
		return 0

	switch(mode)
		if(1)
			if(istype(A, /turf/space))
				if(useResource(1, user))
					user << "Building Floor..."
					activate()
					var/turf/AT = A
					AT.ChangeTurf(/turf/simulated/floor/plating)
					return 1
				return 0

			if(istype(A, /turf/simulated/floor))
				if(checkResource(3, user))
					user << "Building Wall ..."
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 20, target = A))
						if(!useResource(3, user)) return 0
						activate()
						var/turf/AT = A
						AT.ChangeTurf(/turf/simulated/wall)
						return 1
				return 0

		if(2)
			if(istype(A, /turf/simulated/floor))
				if(checkResource(10, user))
					user << "Building Airlock..."
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50, target = A))
						if(!useResource(10, user)) return 0
						activate()
						var/obj/machinery/door/airlock/T = new door_type(A)
						T.autoclose = 1
						if(one_access)
							T.req_one_access = door_accesses
						else
							T.req_access = door_accesses
						return 1
					return 0
				return 0

		if(3)
			if(istype(A, /turf/simulated/wall))
				if(istype(A, /turf/simulated/wall/r_wall) && !canRwall)
					return 0
				if(checkResource(5, user))
					user << "Deconstructing Wall..."
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 40, target = A))
						if(!useResource(5, user)) return 0
						activate()
						var/turf/AT = A
						AT.ChangeTurf(/turf/simulated/floor/plating)
						return 1
				return 0

			if(istype(A, /turf/simulated/floor))
				if(checkResource(5, user))
					user << "Deconstructing Floor..."
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50, target = A))
						if(!useResource(5, user)) return 0
						activate()
						var/turf/AT = A
						AT.ChangeTurf(/turf/space)
						return 1
				return 0

			if(istype(A, /obj/machinery/door/airlock))
				if(checkResource(20, user))
					user << "Deconstructing Airlock..."
					playsound(loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50, target = A))
						if(!useResource(20, user)) return 0
						activate()
						qdel(A)
						return 1
				return	0

			if(istype(A, /obj/structure/window)) // You mean the grille of course, do you?
				A = locate(/obj/structure/grille) in A.loc

			if(istype(A, /obj/structure/grille))
				if(!checkResource(2, user))
					return 0
				user << "Deconstructing window..."
				playsound(loc, 'sound/machines/click.ogg', 50, 1)
				if(!do_after(user, 20, target = A))
					return 0
				if(!useResource(2, user))
					return 0
				activate()
				var/turf/T1 = get_turf(A)
				qdel(A)
				A = null
				for(var/obj/structure/window/W in T1.contents)
					W.disassembled = 1
					W.density = 0
					qdel(W)
				for(var/cdir in cardinal)
					var/turf/T2 = get_step(T1, cdir)
					if(!(locate(/obj/structure/grille) in T2.contents))
						continue
					for(var/obj/structure/window/W in T2.contents)
						if(W.dir == turn(cdir, 180))
							W.disassembled = 1
							W.density = 0
							qdel(W)
						if(istype(W, /obj/structure/window/fulltile) || istype(W, /obj/structure/window/reinforced/fulltile)) //no extra window for you
							return
					var/obj/structure/window/reinforced/W = new(T2)
					W.dir = turn(cdir, 180)
				return 1
			return 0
		if(4)
			if(istype(A, /turf/simulated/floor))
				if(locate(/obj/structure/grille) in contents)
					return 0 // We already have window
				if(!checkResource(2, user))
					return 0
				user << "Constructing window..."
				playsound(loc, 'sound/machines/click.ogg', 50, 1)
				if(!do_after(user, 20, target = A))
					return 0
				if(locate(/obj/structure/grille) in A.contents)
					return 0 // We already have window
				if(!useResource(2, user))
					return 0
				activate()
				new /obj/structure/grille(A)
				for(var/obj/structure/window/W in contents)
					W.disassembled = 1 // Prevent that annoying glass breaking sound
					W.density = 0
					qdel(W)
				new /obj/structure/window/reinforced/fulltile(A) // Spawns a reinforced window.
				var/turf/AT = A
				AT.ChangeTurf(/turf/simulated/floor/plating) // Platings go under windows.
				return 1
		else
			user << "ERROR: RCD in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin."
			return 0

	SSnano.update_uis(src)

/obj/item/weapon/rcd/proc/useResource(var/amount, var/mob/user)
	if(matter < amount)
		return 0
	matter -= amount
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	SSnano.update_uis(src)
	return 1

/obj/item/weapon/rcd/proc/checkResource(var/amount, var/mob/user)
	return matter >= amount
/obj/item/weapon/rcd/borg/useResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:use(amount * 160)

/obj/item/weapon/rcd/borg/checkResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:charge >= (amount * 160)

/obj/item/weapon/rcd/borg/New()
	..()
	desc = "A device used to rapidly build and deconstruct walls and floors."
	canRwall = 1

/obj/item/weapon/rcd/combat
	name = "combat RCD"
	max_matter = 500
	matter = 500
	canRwall = 1

/obj/item/weapon/rcd_ammo
	var/ammoamt = 50
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD. It currently has  units left."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	w_class = 2
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	materials = list(MAT_METAL=16000, MAT_GLASS=8000)

/obj/item/weapon/rcd_ammo/New()
	desc = "Highly compressed matter for the RCD. It currently has [ammoamt] units left."

/obj/item/weapon/rcd_ammo/large
	name = "large compressed matter cartridge"
	ammoamt = 100
	materials = list(MAT_METAL=28000, MAT_GLASS=16000)
