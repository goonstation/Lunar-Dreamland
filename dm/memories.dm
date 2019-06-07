/world
	loop_checks = 0
/client
	var/list/listvar = list(1, "test")
/client/verb/initDLL()
	world << call("hookerino.dll","BHOOK_Init")()
/client/verb/runLua(var/code as message)
	world << call("hookerino.dll", "BHOOK_RunLua")(code)
/client/verb/unload()
	world << call("hookerino.dll","BHOOK_Unload")()
/client/verb/runLuaFile()
	runLua("dofile'boom.lua'")
/client/var/cats
/proc/conoutput(var/msg)
	//dud
/client/proc/myName()
	return src.key
/client/proc/hookme(var/mob/cat)
	return cat.name
/client/verb/globalProc()
	world << hookme(usr)
/proc/WorldOutput(var/text)
	world << text
/client/proc/wtf()
	world << "WTF"
/client/verb/lokayt(var/t as text)
	world << locate(t)
/client/proc/list_stuff()
	//hook
/client/verb/do_list_stuff()
	list_stuff()
/client/verb/print_list()
	for(var/e in listvar)
		world << e
/client/verb/list_append()
	listvar += "a"
/client/proc/proccall_print(sth)
	src << sth
/client/verb/istypespeed()
	var/mob/type/testing/mob/mtest/M = new
	var/x
	for(var/i=1 to 10000000)
		x = istype(M, /datum)
	return x
/datum/type/testing/datum/dtest
/mob/type/testing/mob/mtest
/obj/type/testing/obj/otest
/client/verb/test_types()
	var/datum/type/testing/datum/dtest/D = new
	var/mob/type/testing/mob/mtest/M = new
	var/obj/type/testing/obj/otest/O = new
	typetest(D, M, O)
/client/proc/typetest(datum/type/testing/datum/D, mob/type/testing/mob/M, obj/type/testing/obj/O)
	//dud
var/global/cats=1
var/init_res = ""
/world/New()
	..()
	init_res += call("hookerino.dll","BHOOK_Init")()
	init_res += call("hookerino.dll", "BHOOK_RunLua")("dofile'boom.lua'")
/client/New()
	..()
	src << init_res