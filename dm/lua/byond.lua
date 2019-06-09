local ffi = require("ffi")
local type2type = require "type2type"
local signatures = require "signatures"
local M = {}
local getmetatable = getmetatable
--local yolo = hook.sigscan("byondcore.dll", "?? ?? ?? ?? 8B F0 83 C4 04 85 F6 74 5F 0F B7 1E C1 E3 02 53 ")

--local idarr = ffi.cast('uint32_t*', yolo)
--GetIDArrayEntry = ffi.cast('GetIDArrayEntryPtr', idarr[0]+yolo+4)
local function ptr(n)
	return tonumber(ffi.cast("uint64_t", n))
end

local hooks = {}
function M.hook(fn, callback, cbType, errRet) --print('hooking thing', fn)do return end
	if hooks[fn] then
		local hk = hooks[fn]
		hk.func = callback
		return hk
	end

	cbType = ffi.typeof(cbType or fn)
	local entry = {}
	entry.func = callback
	local uCB = function(...)
		local suc, err = pcall(entry.func, entry.trampoline, ...)
		if not suc then
			print("HOOK ERROR: (dangerous!) " .. tostring(err))
			return errRet --[[eek]]
		end
		return err
	end
	--jit.off(uCB)

	entry.cb = ffi.cast(cbType, uCB)
	--jit.off(callback)

	local hook = hook.create(ptr(fn), ptr(entry.cb))
	local tramp = hook:hook()

	if tramp then
		entry.trampoline = ffi.cast(ffi.typeof(fn), tramp)
	else
		return nil
	end
	entry.hook = hook
	hooks[fn] = entry
	return entry
end

M.ptr = ptr
return M
