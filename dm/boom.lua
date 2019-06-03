package.path = package.path .. ';lua/?.lua;lua/?/init.lua'
print'byond init'
local byond = require'byond'
print'proc init'
local proc = require'proc'
print'loading datum'
require'datum'
print'loading list'
require'list'

print'hooking!'
proc.getProc('/proc/conoutput'):hook(function(original, msg)
	print("Debug: " .. msg)
end)
proc.getProc('/client/proc/hookme'):hook(function(original, usr, src, mob)
	return original(mob) .. src:invoke('/client/proc/myName')
end)
proc.getProc('/client/proc/list_stuff'):hook(function(original, usr, src)
	src.listvar[1] = 15
	src.listvar:append("Hello, world!")
	src:invoke("proccall_print", "test")
end)