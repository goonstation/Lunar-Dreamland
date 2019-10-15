#define BYONDFFI (world.system_type == UNIX ? "byondffi" : "byondffi.dll")
#define HOOKERINO (world.system_type == UNIX ? "hookerino" : "hookerino.dll")

/world
	loop_checks = 0
	fps = 20

world/Topic(T)
	world << T

/client/verb/export()
	world.Export("byond://127.0.0.1:2789?whatever")

var/next_promise_id = 0
/datum/promise
	var/completed = FALSE
	var/result = ""
	var/cb = null
	var/__id = 0

/datum/promise/New()
	__id = next_promise_id++

/datum/promise/proc/__internal_resolve(ref, id)
	//This proc gets rewritten to contain a special opcode which suspends it for a few years, until it gets resumed by byondffi
	world << "This shouldn't happen"
	return 42 //some code to generate opcodes which will be replaced

/datum/promise/proc/__resolve_callback()
	__internal_resolve("\ref[src]", __id)
	call(cb)(result)

/datum/promise/proc/resolve()
	world << "internal resolve \ref[src] [__id]"
	__internal_resolve("\ref[src]", __id)
	world << "internal resolve returned \ref[src] [__id]"
	return result

/proc/call_async()
	var/list/arguments = args.Copy()
	var/datum/promise/P = new
	arguments.Insert(1, "\ref[P]")
	call(BYONDFFI, "call_async")(arglist(arguments))
	return P

/proc/call_async_callback()
	var/list/arguments = args.Copy()
	var/callback = arguments[3]
	arguments.Cut(3, 4)
	var/datum/promise/P = new
	P.cb = callback
	arguments.Insert(1, "\ref[P]")
	call(BYONDFFI, "call_async")(arglist(arguments))
	P.__resolve_callback()
	world << "after callback resolve"

/proc/call_wait()
	return call_async(arglist(args)).resolve()

/proc/print_result(res)
	world << "Result of async call: [res]"

/client/verb/test_ffi_cb()
	world << "Calling async with callback"
	spawn(0)
		call_async_callback("slow.dll", "slow_concat", /proc/print_result, "Hello", ",", " world", "!")
	world << "now we wait!"

/client/verb/test_ffi()
	var/datum/promise/P = call_async("slow.dll", "slow_concat", "Hello", ",", " world", "!")
	world << "Now we wait..."
	world << "Call returned: [P.resolve()]"

/client/verb/do_input()
	var/x = input("sefsdf") as text

/client/verb/make_une_req()
	make_req()

/proc/make_req()
	var/list/http[] = world.Export("http://aa07.ml/test.php")
	world.log << http["CONTENT"]

/client/verb/hol_up()
	world.status = "test"

/client/verb/maptick_load()
	maptick_initialize()

/client/verb/maptick_test()
	world << MAPTICK_LAST_INTERNAL_TICK_USAGE

/client
	var/list/listvar = list(1, "test")

/client/verb/initDLL()
	world << call(HOOKERINO,"BHOOK_Init")()

/client/verb/runLua(var/code as message)
	world << call(HOOKERINO, "BHOOK_RunLua")(code)

/client/verb/unload()
	world << call(HOOKERINO,"BHOOK_Unload")()

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

/client/proc/WorldOutput(var/text)
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
	var/notbuiltinvar = 1
	var/notbuiltinvar2 = 1
	var/notbuiltinvar3 = 1
	var/notbuiltinvar4 = 1
	var/notbuiltinvar5 = 1
	var/notbuiltinvar6 = 1
	var/notbuiltinvar7 = 1
	var/notbuiltinvar8 = 1
	var/notbuiltinvar9 = 1
	var/notbuiltinvar10 = 1
	var/notbuiltinvar11 = 1

var/datum/access_test/test

/proc/peinis(x, y, z)
	world << "peinis"
	world << x
	world << y
	world << z

/client/verb/access_datum_var()
	world << test.name
	world << src.key
	world << test.notbuiltinvar5

/client/verb/print_list()
	for(var/e in listvar)
		world << e

/client/verb/list_append()
	listvar += "a"

/client/proc/proccall_print(sth)
	src << sth

/client/verb/set_something()
	test.name = "sdfsdf"

/client/verb/test_read()

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
	var/time = world.time
	var/mob/type/testing/mob/mtest/M2 = new
	for(var/i=1 to 100000)
		dong = M.name
		dong = M2.name
	world << dong
	world << world.time - time
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

/mob/type/testing/mob/mtest/proc/meme()
	world << "Src is now a mob, woot"

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
	src = M
	call(src, "meme")()
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

/client/proc/ptest(x)
	//asdasd

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
	world << "That was a good sleep"

/client/verb/list_set()
	var/list/x = list(1)
	x[1] = 5

var/global/cats=1
var/init_res = ""
/world/New()
	..()
	test = new
	init_res += call(HOOKERINO,"BHOOK_Init")()
	init_res += call(HOOKERINO, "BHOOK_RunLua")("dofile'boom.lua'")
	call(BYONDFFI, "initialize")()
	//init_res += call("maptick.dll", "initialize")()

/client/New()
	..()
	src << init_res

/proc/add_one(x)
	return x + 1

/client/verb/without_inlining()
	var/x = 0
	for(var/i in 1 to 2)
		x = add_one(x)
	world << x

/client/verb/with_inlining()
	var/x = 0
	for(var/i in 1 to 2)
		x = add_one(x)
	world << x

/client/verb/pauseable_proc()
	world << "before pause!"
	world << "after pause!"

/client/verb/resume_paused()
	//dud

/client/verb/while_paused()
	world << "This was printed while another proc was paused!"

/client/verb/recompilable_verb()
	var/space_1
	var/space_2
	var/space_3
	var/space_4
	var/space_5
	var/space_7
	var/space_6
	var/x = "Before recompilation!"
	world << x

/client/verb/ctest()
	var/list/truth = list("byond", "is", "cool")
	var/name_index = 1
	if(truth[name_index] == "byond")
		to_chat(world, "Hey, it's the best engine!")

	if(name_index == 2)
		to_chat(world, "BYOND #2")
	else
		to_world("BYOND #1!")

/client/verb/recompile_the_verb()
	var/code = input("DM code goes here") as message
	recompile(code)

/client/proc/recompile(code)
	//dud

/client/verb/list_access()
	var/list/x = list(1,2,3)
	var/dong = 1
	world << x[dong]

/client/verb/srcvar()
	var/list/L = list(1, 2, 3)
	//world << L.len
	//world << L
	world << L.Copy()

/client/verb/subvar()
	var/list/L = list()
	world << L.len

/proc/to_chat(x, y)
	x << y

/proc/to_world(x)
	world << x

/mob/proc/test()
	world << "base"

/mob/override/test()
	world << "override"

/client/verb/receive_patch()
	set category = "compiler"
	//hooked by lunar

/client/verb/patchable()
	set category = "compiler"
	world << "Heck"

/client/proc/test_opt()
	var/x = 5 + 5
	world << x/1
	var/q = input() as num
	world << q/1

/client/verb/test_arguments()
	test_arguments_p("You happy now?", 1)

/client/proc/test_arguments_p()
	var/x=1
	var/y=2
	world << x
	world << y

/client/verb/showcase_subvars()
	var/obj/O = new
	to_chat(world, O.name)

/client/var/dyn_callback = /proc/to_world
/client/verb/dyn_call()
	call(dyn_callback)("Dyn call 1")
	call(src, "dyn_callback")("Dyn call 2")
	call("test.dll", "func")("Dyn call 3")

/client/verb/istypetest()
	istype(src, /client)

/client/verb/add_test()
	return 1 + 2

/client/verb/format_test()
	var/x = 1
	var/y = 2
	world << "hello world -> [x] [y]"

/client/verb/strange_syntax()
	var/x = 10
	var/list/L = list(1, 2, 3)
	world.log << "[x in L]"
	world << "[x in 1 to 10]"

/client/verb/aaaaaaaaaadecompiler()
	//test decompiler here

/proc/twelve_locals()
	var/v1 = null
	var/v2 = null
	var/v3 = null
	var/v4 = null
	var/v5 = null
	var/v6 = null
	var/v7 = null
	var/v8 = null
	var/v9 = null
	var/v10 = null
	var/v11 = null
	var/v12 = null

/client/verb/test_patching()
	var/list/L = list(1,2,3)
	L[1][1]

/proc/get_sendmaps_time_raw()

/proc/get_sendmaps_percentage()
	var/time_taken = get_sendmaps_time_raw()
	var/time_per_tick = world.tick_lag
	return (time_taken / time_per_tick) * 100

/client/verb/sendmaps_test()
	world << "SendMaps took [get_sendmaps_percentage()]% of last tick"

/client/verb/set_fps()
	var/f = input("fps") as num
	world.fps = f