
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
	world << "You are: [usr.name] (\ref[usr])"
	hookme(cat=usr, dog = src)
	world << "However, now you are [usr.name] (\ref[src])"
/proc/WorldOutput(var/text)
	world << text
/client/proc/wtf()
	world << "WTF"
/client/verb/lokayt(var/t as text)
	world << locate(t)
var/global/cats=1