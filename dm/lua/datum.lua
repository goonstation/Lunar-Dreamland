local ffi = require('ffi')
local signatures = require('signatures')
local t2t = require'type2type'
local consts = require'defines'
local byond = require'byond'
local signatures = require'signatures'
local M = {}--setmetatable(datumM, {__index=datumM})-- datumM.__index = datumM

local meta = {}
M.type = meta
function meta:__index(key)
	local byond_str = t2t.str2val(key)
	return rawget(meta, key) or t2t.toLua( signatures.GetVariable( self.handle.type, self.handle.value, byond_str.value) )
end

--[[function meta:__index(key) --WIP, requires being able to catch exceptions
	local byond_str = t2t.str2val(key)
	local val = signatures.GetVariable( self.handle.type, self.handle.value, byond_str.value)
	if val == some magic bullshit then
		return function( procName, ... )
			procName:gsub("_", " ")
			local args = {...}
			local argv = {}
			for i = 1, #args do
				local v = t2t.toValue(args[i], true)
				if v then table.insert(argv, v) end
			end
			local vals = ffi.new('Value[' .. #argv .. ']', argv)
			return t2t.toLua(signatures.CallProc( 0, 0, 2, t2t.str2val(procName).value, self.handle.type, self.handle.value, vals, #argv, 0, 0 ))
		end
	end
	return rawget(meta, key) or t2t.toLua(val)
end]]

function meta:__newindex(key, val)
	local converted = t2t.toValue(val, true) or M.null
	SetVariable( self.handle.type, self.handle.value, t2t.str2val( key ), converted.type, converted.value )
end


function meta:invoke( procName, ... )
	--[[local proc = byond.getProc( procName )
	if not proc then error('no such proc ' .. procName) end]]
	procName = procName:gsub("_", " ")
	local args = {...}
	local argv = {}
	for i = 1, #args do
		local v = t2t.toValue(args[i], true)
		if v then table.insert(argv, v) end
	end
	local vals = ffi.new('Value[' .. #argv .. ']', argv)
	--return t2t.toLua(signatures.CallGlobalProcEx( 0, 0, 2, proc.id, 0, self.handle.type, self.handle.value, vals, #argv, 0, 0 --[[no callback]] ))
	return t2t.toLua(signatures.CallProc( 0, 0, 2, t2t.str2val(procName).value, self.handle.type, self.handle.value, vals, #argv, 0, 0 --[[no callback]] ))
end

function meta:__eq(b) if not b then return self == M.null end
	if ffi.istype('Value', b) then
		return self.handle == b
	else
		return self.handle == b or self.handle == b.handle
	end
end

function meta:__tostring()
	return ("BYOND %s [0x%x%06x]"):format(types[tonumber(self.handle.type)], self.handle.type, self.handle.value)
end

function meta:ref()
	return ("[0x%x%06x]"):format(self.handle.type, self.handle.value)
end

function M.fromValue(val)
	return setmetatable({handle=val}, meta)
end

for k, v in pairs{consts.Datum, consts.Turf, consts.World, consts.Obj, consts.Image, consts.Client, consts.Area, consts.Mob} do
	t2t.luaHandlers[v] = M.fromValue
end

M.world = setmetatable({handle={type = M.World, value = 0x0}}, meta)
M.global = setmetatable({handle={type = M.World, value = 0x1}}, meta)
return M