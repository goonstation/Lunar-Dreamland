
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
/proc/hookme(var/mob/thing)
	return 1000
/client/verb/globalProc()
	world << "You are: [usr.name]"
	hookme(usr)
	world << "However, now you are [usr.name]"
/proc/WorldOutput(var/text)
	world << text
/client/proc/wtf()
	world << "WTF"