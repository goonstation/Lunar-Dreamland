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
/datum/access_test
	var/name = "xd"
var/datum/access_test/test
/client/verb/access_datum_var()
	world << test.name
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
/client/verb/var_speed_test()
	var/mob/type/testing/mob/mtest/M = new
	read_test(M)
	//set_test(M)
/client/proc/read_test(mob/M)
	var/dong
	for(var/i=1 to 100000)
		dong = M:notbuiltinvar
	//world << dong
	world << "done"
/client/proc/set_test(mob/M)
	for(var/i=1 to 100000)
		M:notbuiltinvar = 2
	world << "done"
/datum/type/testing/datum/dtest
/mob/type/testing/mob/mtest
	name = "mobtest"
	var/notbuiltinvar = 1
	var/list/asdf = list("ayy" = "lmao")
/obj/type/testing/obj/otest

/obj/type/testing/obj/otest/proc/obj_proc()
	world << "obj proc!"
/obj/type/testing/obj/otest/proc/obj_proc2()
	world << "obj proc!"
/client/verb/test_proccall()
	var/obj/type/testing/obj/otest/O = new
	O.obj_proc()
	O.obj_proc2()
	var/obj/type/testing/obj/otest/O2 = new
	O2.obj_proc(1, 2, 3)
/client/verb/various()
	var/list/L = list(1,2,3,null,5,6,7)
	for(var/obj/type/testing/obj/otest/i in L)
		world << i
/client/verb/test_types()
	var/datum/type/testing/datum/dtest/D = new
	var/mob/type/testing/mob/mtest/M = new
	var/obj/type/testing/obj/otest/O = new(M, 1, 2, 3)
	typetest(D, M, O)
/client/verb/dynamic_vars()
	var/mob/type/testing/mob/mtest/M = new
	world << M.asdf["ayy"]
/client/verb/anewlist()
	var/numero = 5
	var/stringy = "Hello, world!"
	var/list/yep = list(1, 2, 3)
/client/verb/spawntest()
	spawn(10)
		world << "spawned"
	return 2
/client/verb/looptest()
	for(var/i=1 to 10)
		world << i
/client/verb/whileloop()
	var/x = 5
	while(x > 0)
		world << x
		x--
/client/proc/typetest(datum/type/testing/datum/D, mob/type/testing/mob/M, obj/type/testing/obj/O)
	world << "do not optimize me out"
/client/verb/happy_proc()
	var/x = 1
	x--
	return 5
/client/verb/read_list()
	var/list/n = list()
	var/x = n.len
/client/proc/ct()
	var/local_1 = 1
	var/local_2 = 2
	return local_1 + local_2
/client/verb/context_test()
	return ct()
/client/verb/other_file_test()
	return from_another_file(5, 6, 7)
/client/verb/get_set_datum_test()
	var/obj/type/testing/obj/otest/O = new
	var/obj/type/testing/obj/otest/O2 = new
	O2.name = "test"
	world << O2.name
	return from_another_file(5, 6, 7)
/client/verb/sleep_test()
	sleep(10)
var/global/cats=1
var/init_res = ""
/world/New()
	..()
	test = new
	init_res += call("hookerino.dll","BHOOK_Init")()
	init_res += call("hookerino.dll", "BHOOK_RunLua")("dofile'boom.lua'")
/client/New()
	..()
	src << init_res

/client/verb/pauseable_proc()
	world << "before pause!"
	world << "after pause!"
/client/verb/resume_paused()
	//dud
/client/verb/while_paused()
	world << "This was printed while another proc was paused!"