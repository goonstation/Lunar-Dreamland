package.path = package.path .. ";lua/?.lua;lua/?/init.lua"
print "byond init"
local byond = require "byond"
print "proc init"
local proc = require "proc"
local signatures = require "signatures"
print "loading datum"
require "datum"
print "loading list"
require "list"
print "loading t2t"
local t2t = require "type2type"
print "loading defines"
local consts = require "defines"
print "loading types"
local types = require "typepath"

local context = require "context"

local T = byond.T

print "hooking!"

byond.set_breakpoint_func(
	function()
		print("Debug breakpoint hit!")
		print("Dumping local variables...")
		c = context.get_context()
		for i = 0, c.local_var_count - 1 do
			print("Var " .. i .. ": ", t2t.toLua(c.local_variables[i]))
		end
		print("Resuming!")
	end
)

proc.getProc("/proc/conoutput"):hook(
	function(original, msg)
		print("Debug: " .. msg)
	end
)
proc.getProc("/client/proc/hookme"):hook(
	function(original, usr, src, mob)
		return original(mob) .. src:invoke("/client/proc/myName")
	end
)
proc.getProc("/client/proc/list_stuff"):hook(
	function(original, usr, src)
		list = src.listvar
		list:append("Hello, world2!")
	end
)
proc.getProc("/client/proc/typetest"):hook(
	function(original, usr, src, d, m, o)
		--[[print("Intial ayy:", m.asdf["ayy"])
		m.asdf["ayy"] = "not lmao"
		m.asdf["nonexistent"] = "or is it?"
		print("Modified ayy:", m.asdf["ayy"])
		print("Formerly nonexistent:", m.asdf["nonexistent"])
		m.asdf = {1, "second", "3th", 4}
		print("Set:", m.asdf[1], m.asdf[2], m.asdf[3], m.asdf[4])
		local start_time = os.clock()
		local bench
		for i = 1, 10000000 do
			bench = byond.istype(d, T "/mob")
		end
		print("Time taken to istype 1 million times: ", os.clock() - start_time)]]
		--[[local bench
		start_time = os.clock()
		local getvar = signatures.GetVariable
		local handle = m.handle
		for i = 1, 100000 do
			getvar(handle, 0x27)
		end
		print("Time taken to get var 100,000 times: ", os.clock() - start_time)]]
		--[[start_time = os.clock()
		for i = 1, 100000 do
			m.notbuiltinvar = 2
		end
		print("Time taken to set var 100,000 times: ", os.clock() - start_time)
		print("istype(datum, /datum/type/testing/datum): ", byond.istype(d, T "/datum/type/testing/datum"))
		print("istype(datum, /datum/type): ", byond.istype(d, T "/datum/type"))
		print("istype(datum, /datum): ", byond.istype(d, T "/datum"))
		print("istype(datum, /mob): ", byond.istype(d, T "/mob"))
		print("Datum type:", d.type.path)
		print("Mob type:", m.type.path)
		print("Obj type:", o.type.path)
		print("Datum parent type:", d.type.parentType.path)
		print("Mob parent type:", m.type.parentType.path)
		print("Obj parent type:", o.type.parentType.path)

		local newthing = byond.new("/mob/type/testing/mob/mtest", m)
		print("New mob name:", newthing.name)
		print("New mob type:", newthing.type.path)
		print("New mob loc:", newthing.loc, newthing.loc.name)]]
	end
)
proc.getProc("/client/verb/context_test"):hook(
	function(original, usr, src)
		print(context.get_context().proc_state)
	end
)

print("Hooked everything")
