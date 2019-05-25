
local ffi = require'ffi'
byond = require'byond'

-- --local asd = Text2PathPtr(GetStringTableIndex("/proc/WorldOutput", 0, 1))
print'hooking'
byond.getProc('/proc/conoutput'):hook(function(original, msg)
	print("Debug: " .. msg)
end)
byond.getProc('/client/proc/hookme'):hook(function(original, usr, src, mob)
	print(usr:invoke('/client/proc/myName'))
	return original() + 234
end)