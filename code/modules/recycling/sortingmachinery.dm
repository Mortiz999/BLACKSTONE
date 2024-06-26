/obj/structure/bigDelivery
	name = "large parcel"
	desc = ""
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = TRUE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/giftwrapped = FALSE
	var/sortTag = 0
	var/obj/item/paper/note

/obj/structure/bigDelivery/interact(mob/user)
	playsound(src.loc, 'sound/blank.ogg', 50, TRUE)
	qdel(src)

/obj/structure/bigDelivery/Destroy()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.forceMove(T)
	return ..()

/obj/structure/bigDelivery/contents_explosion(severity, target)
	for(var/atom/movable/AM in contents)
		AM.ex_act()

/obj/structure/bigDelivery/examine(mob/user)
	. = ..()
	if(note)
		if(!in_range(user, src))
			. += "There's a [note.name] attached to it. You can't read it from here."
		else
			. += "There's a [note.name] attached to it..."
			. += note.examine(user)

/obj/structure/bigDelivery/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/destTagger))
		var/obj/item/destTagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, span_notice("*[tag]*"))
			sortTag = O.currTag
			playsound(loc, 'sound/blank.ogg', 100, TRUE)

	else if(istype(W, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, span_notice("I scribble illegibly on the side of [src]!"))
			return
		var/str = copytext(sanitize(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(!str || !length(str))
			to_chat(user, span_warning("Invalid text!"))
			return
		user.visible_message(span_notice("[user] labels [src] as [str]."))
		name = "[name] ([str])"

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(3))
			user.visible_message(span_notice("[user] wraps the package in festive paper!"))
			giftwrapped = TRUE
			icon_state = "gift[icon_state]"
		else
			to_chat(user, span_warning("I need more paper!"))

	else if(istype(W, /obj/item/paper))
		if(note)
			to_chat(user, span_warning("This package already has a note attached!"))
			return
		if(!user.transferItemToLoc(W, src))
			to_chat(user, span_warning("For some reason, you can't attach [W]!"))
			return
		user.visible_message(span_notice("[user] attaches [W] to [src]."), span_notice("I attach [W] to [src]."))
		note = W
		if(giftwrapped)
			add_overlay(copytext("[icon_state]_note",5))
			return
		add_overlay("[icon_state]_note")

	else
		return ..()

/obj/structure/bigDelivery/relay_container_resist(mob/living/user, obj/O)
	if(ismovableatom(loc))
		var/atom/movable/AM = loc //can't unwrap the wrapped container if it's inside something.
		AM.relay_container_resist(user, O)
		return
	to_chat(user, span_notice("I lean on the back of [O] and start pushing to rip the wrapping around it."))
	if(do_after(user, 50, target = O))
		if(!user || user.stat != CONSCIOUS || user.loc != O || O.loc != src )
			return
		to_chat(user, span_notice("I successfully removed [O]'s wrapping !"))
		O.forceMove(loc)
		playsound(src.loc, 'sound/blank.ogg', 50, TRUE)
		qdel(src)
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("I fail to remove [O]'s wrapping!"))


/obj/item/smallDelivery
	name = "package"
	desc = ""
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverypackage3"
	item_state = "deliverypackage"
	var/giftwrapped = 0
	var/sortTag = 0
	var/obj/item/paper/note

/obj/item/smallDelivery/contents_explosion(severity, target)
	for(var/atom/movable/AM in contents)
		AM.ex_act()

/obj/item/smallDelivery/attack_self(mob/user)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	for(var/X in contents)
		var/atom/movable/AM = X
		user.put_in_hands(AM)
	playsound(src.loc, 'sound/blank.ogg', 50, TRUE)
	user.visible_message(span_warning("[user] opens [src]."))
	qdel(src)

/obj/item/smallDelivery/attack_self_tk(mob/user)
	if(ismob(loc))
		var/mob/M = loc
		M.temporarilyRemoveItemFromInventory(src, TRUE)
		for(var/X in contents)
			var/atom/movable/AM = X
			M.put_in_hands(AM)
	else
		for(var/X in contents)
			var/atom/movable/AM = X
			AM.forceMove(src.loc)
	playsound(src.loc, 'sound/blank.ogg', 50, TRUE)
	qdel(src)

/obj/item/smallDelivery/examine(mob/user)
	. = ..()
	if(note)
		if(!in_range(user, src))
			. += "There's a [note.name] attached to it. You can't read it from here."
		else
			. += "There's a [note.name] attached to it..."
			. += note.examine(user)
	if(mailer)
		. += "It's from [mailer], addressed to [mailedto].</a>"

/obj/item/smallDelivery/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/destTagger))
		var/obj/item/destTagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(GLOB.TAGGERLOCATIONS[O.currTag])
			to_chat(user, span_notice("*[tag]*"))
			sortTag = O.currTag
			playsound(loc, 'sound/blank.ogg', 100, TRUE)

	else if(istype(W, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, span_notice("I scribble illegibly on the side of [src]!"))
			return
		var/str = copytext(sanitize(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(!str || !length(str))
			to_chat(user, span_warning("Invalid text!"))
			return
		user.visible_message(span_notice("[user] labels [src] as [str]."))
		name = "[name] ([str])"

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(1))
			icon_state = "gift[icon_state]"
			giftwrapped = 1
			user.visible_message(span_notice("[user] wraps the package in festive paper!"))
		else
			to_chat(user, span_warning("I need more paper!"))

/*	else if(istype(W, /obj/item/paper))
		if(note)
			to_chat(user, span_warning("This package already has a note attached!"))
			return
		if(!user.transferItemToLoc(W, src))
			to_chat(user, span_warning("For some reason, you can't attach [W]!"))
			return
		user.visible_message(span_notice("[user] attaches [W] to [src]."), span_notice("I attach [W] to [src]."))
		note = W
		if(giftwrapped)
			add_overlay(copytext("[icon_state]_note",5))
			return
		add_overlay("[icon_state]_note")*/

/obj/item/destTagger
	name = "destination tagger"
	desc = ""
	icon = 'icons/obj/device.dmi'
	icon_state = "cargotagger"
	var/currTag = 0 //Destinations are stored in code\globalvars\lists\flavor_misc.dm
	var/locked_destination = FALSE //if true, users can't open the destination tag window to prevent changing the tagger's current destination
	w_class = WEIGHT_CLASS_TINY
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT

/obj/item/destTagger/borg
	name = "cyborg destination tagger"
	desc = ""

/obj/item/destTagger/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins tagging [user.p_their()] final destination! It looks like [user.p_theyre()] trying to commit suicide!"))
	if (islizard(user))
		to_chat(user, span_notice("*HELL*"))//lizard nerf
	else
		to_chat(user, span_notice("*HEAVEN*"))
	playsound(src, 'sound/blank.ogg', 100, TRUE)
	return BRUTELOSS

/obj/item/destTagger/proc/openwindow(mob/user)
	var/dat = "<tt><center><h1><b>TagMaster 2.2</b></h1></center>"

	dat += "<table style='width:100%; padding:4px;'><tr>"
	for (var/i = 1, i <= GLOB.TAGGERLOCATIONS.len, i++)
		dat += "<td><a href='?src=[REF(src)];nextTag=[i]'>[GLOB.TAGGERLOCATIONS[i]]</a></td>"

		if(i%4==0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [currTag ? GLOB.TAGGERLOCATIONS[currTag] : "None"]</tt>"

	user << browse(dat, "window=destTagScreen;size=450x350")
	onclose(user, "destTagScreen")

/obj/item/destTagger/attack_self(mob/user)
	if(!locked_destination)
		openwindow(user)
		return

/obj/item/destTagger/Topic(href, href_list)
	add_fingerprint(usr)
	if(href_list["nextTag"])
		var/n = text2num(href_list["nextTag"])
		currTag = n
	openwindow(usr)
