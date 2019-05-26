byond = require'byond'

print'hooking'
byond.getProc('/proc/conoutput'):hook(function(original, msg)
	print("Debug: " .. msg)
end)
byond.getProc('/client/proc/hookme'):hook(function(original, usr, src, mob)
	print(usr:invoke('/client/proc/myName'))
	return original() + 234
end)
byond.getProc('/client/proc/list_stuff'):hook(function(original, usr, src)
	src.listvar[1] = 15
	src.listvar.append("Hello, world!")
end)