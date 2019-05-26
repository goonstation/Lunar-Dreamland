local def = require('defines')
local ffi = require('cdef')
require('byond_funcs')
require('converters')
require('datum')
require('proc')
require('hook')

local M = {}
local getmetatable = getmetatable
--local yolo = hook.sigscan("byondcore.dll", "?? ?? ?? ?? 8B F0 83 C4 04 85 F6 74 5F 0F B7 1E C1 E3 02 53 ")

--local idarr = ffi.cast('uint32_t*', yolo)
--GetIDArrayEntry = ffi.cast('GetIDArrayEntryPtr', idarr[0]+yolo+4)

M.lua2value = lua2value
M.getProc = getProc

local hooks = {}
function M.hook(fn, callback, cbType, errRet)
	if hooks[fn] then
		local hk = hooks[fn]
		hk.func = callback
		return hk
		
	end
	cbType = ffi.typeof(cbType or fn)
	local entry = {}
	entry.func = callback
	entry.cb = ffi.cast(cbType, function(...)
		local suc, err = pcall( entry.func, entry.trampoline, ... )
		if not suc then print("HOOK ERROR: (dangerous!) " .. tostring(err)) return errRet --[[eek]] end
		return err
	end)
	jit.off(callback)
	
	local hook = hook.create( ptr(fn), ptr(entry.cb) )
	local tramp = hook:hook()
	
	if tramp then
		entry.trampoline = ffi.cast( ffi.typeof(fn), tramp )
	else return nil end
	hooks[fn] = entry
	return entry
end

procCallHook = M.hook(CallGlobalProc, function(original, usrType, usrVal, flags, procid, d, srcType, srcVal, argv, argc, callback, callbackVar)
	local theProc = GetProcArrayEntry(procid)
	--if byond.toLuaString(theProc.procPath) == '/proc/conoutput' and argc == 1 then
	--	print('dbg: ' ..byond.toLuaString(argv[0].value))
	--	return byond.null.longlongman
	--end
	if argc == 1 then print(argv[0].type) end
	if prochooks[tonumber(procid)] then
		local luad = {}
		for i = 1, tonumber(argc) do
			luad[i] = value2lua(argv[i-1])--dont skip arguments if they fail conversion
		end
		return lua2value(prochooks[tonumber(procid)](function(...)
			local honk = {}
			for k, v in pairs{...} do
				honk[k] = lua2value(v)
			end
			return value2lua(original(usrType, usrVal, flags, procid, d, srcType, srcVal, ffi.new('Value[' .. #honk .. ']', honk), #honk, 0, 0))
		end, value2lua(ffi.new('Value', {type=usrType, value=usrVal})), value2lua(ffi.new('Value', {type=srcType, value=srcVal})), unpack(luad))).longlongman
	else
		local ret = original(usrType, usrVal, flags, procid, d, srcType, srcVal, argv, argc, callback, callbackVar)
		return ret.longlongman
	end
end, 'long long(*)(char usrType, int usrVal, int const_2, unsigned int proc_id, int const_0, char srcType, int srcVal, Value* argList, unsigned int argListLen, int const_0_2, int const_0_3)', def.null.longlongman)

local errhk = M.hook(ThrowDMError, function(orig, msg)
	print('DM error: ' .. ffi.string(msg))
	return orig(msg)
end, 'ThrowDMErrorPtr', 0)

M.ptr = ptr
return M