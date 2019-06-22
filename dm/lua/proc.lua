local t2t = require "type2type"
local ffi = require("ffi")
local signatures = require "signatures"
local constants = require "defines"

local M = require "byond"
M.procHooks = {}
local typecache = {
	procs = {}
}

local procMeta = {}
procMeta.__index = procMeta
function procMeta:__tostring()
	return "[BYOND Proc #" .. self.id .. "]: " .. self.path
end

function procMeta:hook(callback)
	print("proc hook added: " .. self.name)
	M.procHooks[self.id] = callback
end

function procMeta:__call(...)
	local args = {...}
	local argv = {}
	for i = 1, #args do
		local v = t2t.toLua(args[i], true)
		if v then
			table.insert(argv, v)
		end
	end
	local vals = ffi.new("Value[" .. #argv .. "]", argv)
	return t2t.toLua(
		signatures.CallGlobalProc(0, 0 --[[no src]], 2, self.id, 0, 0, 0, vals, #argv, 0, 0 --[[no callback]])
	)
end

M.proc_setup_table_length = (signatures.AlmostTotalProcs + 1)[0]

local setup_meta = {}

function setup_meta.__newindex(self, key, val)
	if key == "local_var_count" then
		signatures.ProcSetupTable[self.__proc.proc.local_var_count_idx][0].local_var_count = val
	elseif key == "bytecode" then
		signatures.ProcSetupTable[self.__proc.proc.bytecode_idx][0].bytecode = val
	end
end

function setup_meta.__index(self, key)
	if key == "local_var_count" then
		return signatures.ProcSetupTable[self.__proc.proc.local_var_count_idx][0].local_var_count
	elseif key == "bytecode" then
		return signatures.ProcSetupTable[self.__proc.proc.bytecode_idx][0].bytecode
	elseif key == "bytecode_len" then
		return signatures.ProcSetupTable[self.__proc.proc.bytecode_idx][0].local_var_count --if you look up the proc by bytecode index, the local_var_count holds the length of the bytecode
	end
end

function M.getProcSetupInfo(path)
	local proc = M.getProc(path)
	return setmetatable(
		{
			__proc = proc
		},
		setup_meta
	)
end

for i = 0, 0xFFFFFF do
	local entry = signatures.GetProcArrayEntry(i)
	if entry ~= ffi.null then
		local built =
			setmetatable(
			{
				id = i,
				proc = entry,
				path = t2t.idx2str(entry.procPath),
				name = t2t.idx2str(entry.procName),
				category = t2t.idx2str(entry.procCategory),
				desc = t2t.idx2str(entry.procDesc),
				flags = tonumber(entry.procFlags)
			},
			procMeta
		)
		typecache.procs[i] = {id = i, proc = entry}
		typecache.procs[built.path] = built
	else
		print("Ran out of procs to hook")
		break
	end
end

function M.getProc(path)
	local ret = typecache.procs[path]
	if not ret then
		error("ERROR: " .. path .. " is not a valid proc!")
	end
	return ret
end

M.callGlobalProcHook =
	M.hook(
	signatures.CallGlobalProc,
	function(original, usrType, usrVal, flags, procid, d, srcType, srcVal, argv, argc, callback, callbackVar)
		--print("this message means code is working")
		--local theProc = signatures.GetProcArrayEntry(procid)
		--if byond.toLuaString(theProc.procPath) == '/proc/conoutput' and argc == 1 then
		--	print('dbg: ' ..byond.toLuaString(argv[0].value))
		--	return byond.null.longlongman
		--end
		if M.procHooks[tonumber(procid)] then
			local luad = {}
			for i = 1, tonumber(argc) do
				luad[i] = t2t.toLua(argv[i - 1])
				--dont skip arguments if they fail conversion
			end
			return t2t.toValue(
				M.procHooks[tonumber(procid)](
					function(...)
						local honk = {}
						for k, v in pairs {...} do
							honk[k] = t2t.toValue(v)
						end
						return t2t.toLua(
							original(
								usrType,
								usrVal,
								flags,
								procid,
								d,
								srcType,
								srcVal,
								ffi.new("Value[" .. #honk .. "]", honk),
								#honk,
								0,
								0
							)
						)
					end,
					t2t.toLua(ffi.new("Value", {type = usrType, value = usrVal})),
					t2t.toLua(ffi.new("Value", {type = srcType, value = srcVal})),
					unpack(luad)
				)
			).longlongman
		else
			local ret = original(usrType, usrVal, flags, procid, d, srcType, srcVal, argv, argc, callback, callbackVar)
			return ret.longlongman
		end
	end,
	"long long(*)(char usrType, int usrVal, int const_2, unsigned int proc_id, int const_0, char srcType, int srcVal, Value* argList, unsigned int argListLen, int const_0_2, int const_0_3)",
	constants.null.longlongman
)

signatures.CallGlobalProcEx = signatures.CallGlobalProcEx or signatures.CallGlobalProc
signatures.CallGlobalProc = M.callGlobalProcHook.trampoline

return M
