
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
/client/verb/globalProc()
	var/test = 0
	conoutput("setting local var")
	test = 123
	test:cats = 123
	conoutput("setting client var")
	cats = test
	world << test
/proc/WorldOutput(var/text)
	world << text