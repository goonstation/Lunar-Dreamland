package.path = package.path .. ';lua/?.lua;lua/?/init.lua'
print'byond init'
local byond = require'byond'
print'proc init'
local proc = require'proc'
require'datum'
print'hooking!'
proc.getProc('/proc/conoutput'):hook(function(original, msg)
	print("Debug: " .. msg)
end)
proc.getProc('/client/proc/hookme'):hook(function(original, usr, src, mob)
	return original(mob) .. src:invoke('/client/proc/myName')
end)
proc.getProc('/client/proc/list_stuff'):hook(function(original, usr, src)
	src.listvar[1] = 15
	src.listvar.append("Hello, world!")
end)