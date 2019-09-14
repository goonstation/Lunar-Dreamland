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

local disasm = require "disassembler"

local T = byond.T

local ffi = require "ffi"

local compiler = require "compiler"

local json = require "json"

local debugger = require "debugger"
print "hooking!"

--[[ new code:
var/x = 1
breakpoint
return x
]]
--[[local new_bytecode = {0x50, 0x01, 0x34, 0xFFDA, 0x00, 0x1337, 0x33, 0xFFDA, 0x00, 0x12}
local new_varcount = 1 -- This will be supplied by the compiler
local cnew_bytecode = ffi.new("int[?]", #new_bytecode, new_bytecode)

print("Original proc:")
disasm.disassemble(proc_to_recompile.bytecode, proc_to_recompile.bytecode_len)

proc_to_recompile.bytecode = cnew_bytecode
proc_to_recompile.local_var_count = new_varcount

print("")
print("Recompiled:")
disasm.disassemble(proc_to_recompile.bytecode, proc_to_recompile.bytecode_len)
]]
--proc.getProc("/client/verb/various"):set_breakpoint()
--local p = proc.getProcSetupInfo("/client/proc/test_opt")
--disasm.disassemble(p.bytecode, p.bytecode_len)
--[[local new_bytecode = {
	0x33,
	0xFFE5,
	0x60,
	0x06,
	t2t.str2index("Before pause!"),
	0x3,
	0x1338,
	0x33,
	0xFFE5,
	0x60,
	0x06,
	t2t.str2index("After pause!"),
	0x03,
	0x00
}
local new_varcount = 0
local cnew_bytecode = ffi.new("int[?]", #new_bytecode, new_bytecode)

local p = proc.getProcSetupInfo("/client/verb/pauseable_proc")

p.bytecode = cnew_bytecode
p.local_var_count = new_varcount

p = proc.getProcSetupInfo("/client/verb/resume_paused")

local new_bytecode2 = {0x1339, 0x00}
local cnew_bytecode2 = ffi.new("int[?]", #new_bytecode2, new_bytecode2)
p.bytecode = cnew_bytecode2]]
--[[byond.set_breakpoint_func(
	function(ctx)
		print("Debug breakpoint hit!")
		print("Dumping local variables...")
		for i = 0, ctx.local_var_count - 1 do
			print("Var " .. i .. ": ", t2t.toLua(ctx.local_variables[i]))
		end
		print("Resuming!")
	end
)]]
--[[compiler.compile_disassemble([[
var/x = "After recompilation!"
world << x
]]
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
		local a = t2t.toLua(signatures.RadicalGetVariable(0x21, 0x00, 0x27))
		print(a)
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
		local getvar = signatures.RadicalGetVariable
		local type = m.handle.type
		local id = m.handle.value
		local xd = t2t.str2index("name")
		for i = 1, 100000 do
			bench = getvar(type, id, xd)
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
		local all_procs = {}
		for _, p in ipairs(proc.allProcs()) do
			print(p.path)
			local setup = proc.getProcSetupInfo(p.path)
			print(setup.bytecode_len)
			local disassembly = disasm.disassemble(setup.bytecode, setup.bytecode_len)
			table.insert(all_procs, {procName = p.path, procInfo = {rows = disassembly}})
		end
		all_procs = json.encode(all_procs)
		local f = io.open("\\\\.\\pipe\\DMDBG", "w")
		f:write(all_procs)
		f:write("\n")
		f:flush()
		f:close()
	end
)

ffi.cdef [[
	void run_ffi(SetVariablePtr setvar, GetStringTableIndex gsti, int promise_id, const char* dllname, const char* funcname, int n_args, const char** args)
]]

local byondffi = ffi.load("byondffi")

--[[proc.getProc("/datum/ffi/proc/__call"):hook(
	function(original, usr, src, args)
		local args = args:as_table()
		local dll_name = ffi.new("const char*", table.remove(args, 1))
		local promise_id = ffi.new("int", tonumber(string.sub(table.remove(args, 1), 6, -2), 16))
		local func_name = ffi.new("const char*", table.remove(args, 1))
		local n_args = #args
		args = ffi.new("const char*[?]", #args, args)
		byondffi.run_ffi(signatures.SetVariable, signatures.GetStringTableIndex, promise_id, dll_name, func_name, n_args, args)
	end
)]]

--[[proc.getProc("/client/proc/recompile"):hook(
	function(original, usr, src, newcode)
		p = byond.getProcSetupInfo("/client/verb/recompilable_verb")
		local new = compiler.compile(newcode)
		if new then
			print("setting")
			p.bytecode = new
		end
	end
)]]

print("Hooked everything")
--[[print(proc.getProc("/proc/conoutput").id)
print(proc.getProc("/proc/to_chat").id)
print(t2t.toValue("space_1").value)
print(t2t.toValue("space_2").value)
print(t2t.toValue("space_3").value)
print(t2t.toValue("space_4").value)
for i = 0x125, 0x15C do
	print(t2t.idx2str(i))
end
print(t2t.idx2str(0xA0))
for i = 0x15D, 0x16A do
	print(t2t.idx2str(i))
end
proc.getProc("/client/verb/receive_patch"):hook(
	function(original, usr, src)
		local f = io.open("\\\\.\\pipe\\dmcompiler", "r")
		local req = json.decode(f:read())
		compiler.patch(req["path"], req["bytecode"], req["strings"], req["local_count"])
		proc.getProc("/proc/to_world")("<b><tt>Received patch for " .. req["path"] .. "<tt></b>")
	end
)]]

--[[recipient = proc.getProcSetupInfo("/client/verb/with_inlining")
donor = proc.getProcSetupInfo("/proc/add_one")
new_bytecode = {}
r_offset = 0
d_offset = 4

print(recipient.bytecode)


recipient_len = recipient.bytecode_len
recipient_var_count = recipient.local_var_count
ret_jump = 0
while r_offset < recipient.bytecode_len do
	if recipient.bytecode[r_offset] == 0x30 then
		table.insert(new_bytecode, 0x0F)
		table.insert(new_bytecode, recipient_len)
		table.insert(new_bytecode, 0x1337) --padding
		r_offset = r_offset + 3
		ret_jump = r_offset
	else
		table.insert(new_bytecode, recipient.bytecode[r_offset])
		r_offset = r_offset + 1
	end
end


table.insert(new_bytecode, 0x34)
table.insert(new_bytecode, 0xFFDA)
table.insert(new_bytecode, 0x02)
while d_offset < donor.bytecode_len-1 do
	if donor.bytecode[d_offset] == 0xFFD9 then
		table.insert(new_bytecode, 0xFFDA)
		table.insert(new_bytecode, 0x02)
		d_offset = d_offset + 2
		--r_offset = r_offset + 2
	elseif donor.bytecode[d_offset] == 0x12 then
		--table.insert(new_bytecode, 0x33)
		--table.insert(new_bytecode, 0xFFDA)
		--table.insert(new_bytecode, 0x02)
		table.insert(new_bytecode, 0x0F)
		table.insert(new_bytecode, ret_jump)
		d_offset = d_offset + 1
	else
		table.insert(new_bytecode, donor.bytecode[d_offset])
		d_offset = d_offset + 1
		--r_offset = r_offset + 1
	end
end
table.insert(new_bytecode, 0x60)
table.insert(new_bytecode, 0x00)
table.insert(new_bytecode, 0x00)
table.insert(new_bytecode, 0x0F)
table.insert(new_bytecode, ret_jump)
table.insert(new_bytecode, 0x00)

local l = #new_bytecode
pnew_bytecode = ffi.new("int[?]", l, new_bytecode)
print(pnew_bytecode)
byond.new_bytecode = pnew_bytecode
recipient.bytecode = pnew_bytecode
recipient.local_var_count = 16]]
--recipient = proc.getProcSetupInfo("/client/verb/with_inlining")
--print(recipient.bytecode)
--recipient.bytecode_len = 67
--recipient.local_var_count = 3]]


--[[ffi.cdef [[
	__declspec(dllexport) void __cdecl pass_shit(const char** proc_names, int* proc_ids, short* varcounts, short* bytecode_lens, int** bytecodes, ProcSetupEntry** setup_entries, int number_of_procs, ExecutionContext** execContext, GetStringTableIndexPtr woo, GetStringTableIndex wahoo, unsigned short* benis, unsigned short* benis2, ProcArrayEntry* killme);
	__declspec(dllexport) void breakpoint_hit(int* bytecode, int offset);
]]
--[[
local dmdis = ffi.load("dmdism")
local proc_names = {}
local proc_ids = {}
local varcounts = {}
local bytecode_lens = {}
local bytecodes = {}
local setup_entries = {}
local varcount_indices = {}
local bytecode_indices = {}
v = proc.allProcs()[0] --god damn it lua
table.insert(proc_names, v.path)
table.insert(proc_ids, v.id)
p = proc.getProcSetupInfo(v.path)
table.insert(varcounts, p.local_var_count)
table.insert(bytecode_lens, p.bytecode_len)
table.insert(bytecodes, p.bytecode)
table.insert(varcount_indices, v.proc.local_var_count_idx)
table.insert(bytecode_indices, v.proc.bytecode_idx)
--table.insert(setup_entries, signatures.ProcSetupTable[p.__proc.proc.bytecode_idx])
for _, v in ipairs(proc.allProcs()) do
	table.insert(proc_names, v.path)
	table.insert(proc_ids, v.id)
	p = proc.getProcSetupInfo(v.path)
	table.insert(varcounts, p.local_var_count)
	table.insert(bytecode_lens, p.bytecode_len)
	table.insert(bytecodes, p.bytecode)
	table.insert(varcount_indices, v.proc.local_var_count_idx)
	table.insert(bytecode_indices, v.proc.bytecode_idx)
	--print(v.proc.local_var_count_idx)
	--table.insert(setup_entries, signatures.ProcSetupTable[p.__proc.proc.bytecode_idx])
	--if v.path == "/client/verb/patchable" then
	--	print(p.bytecode)
	--end
end

local lprocs = #proc_names
proc_names = ffi.new("const char*[?]", #proc_names, proc_names)
proc_ids = ffi.new("int[?]", #proc_ids, proc_ids)
varcounts = ffi.new("short[?]", #varcounts, varcounts)
bytecode_lens = ffi.new("short[?]", #bytecode_lens, bytecode_lens)
bytecodes = ffi.new("int*[?]", #bytecodes, bytecodes)
setup_entries = ffi.new("ProcSetupEntry*[?]", #setup_entries, setup_entries)
bytecode_indices = ffi.new("unsigned short[?]", #bytecode_indices, bytecode_indices)
varcount_indices = ffi.new("unsigned short[?]", #varcount_indices, varcount_indices)
dmdis.pass_shit(
	proc_names,
	proc_ids,
	varcounts,
	bytecode_lens,
	bytecodes,
	signatures.ProcSetupTable,
	lprocs,
	signatures.CurrentExecutionContext,
	signatures.GetStringTableIndexPtr,
	signatures.GetStringTableIndex,
	varcount_indices,
	bytecode_indices,
	signatures.GetProcArrayEntry(0)
)
byond.set_breakpoint_func(debugger.debug_hook)
]]