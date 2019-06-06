local ffi = require("ffi")
local consts = require("defines")
local signatures = require("signatures")

local M = {}
local function ptr(n)
	return tonumber(ffi.cast("uint64_t", n))
end

function M.str2val(str)
	local idx = signatures.GetStringTableIndex(str, 0, 1)
	return ffi.new("Value", {type = consts.String, value = idx})
end

M.luaHandlers = {
	[consts.String] = function(val)
		return M.idx2str(val.value)
	end,
	[consts.Number] = function(val)
		return tonumber(val.valuef)
	end,
	[consts.Null] = function()
		return nil
	end
}

for k, v in pairs {consts.MobType, consts.ObjType, consts.DatumType, consts.ClientType} do
	M.luaHandlers[v] = function(val)
		return M.idx2str(signatures.Path2Text(val.type, val.value))
	end
end

function M.toLua(value)
	local t = M.luaHandlers[tonumber(value.type)]
	if t then
		return t(value)
	else
		print("??? value2lua type: " .. value.type)
	end
end
--use refcount if we're assigning or invoking
function M.toValue(value, refcount)
	local t = type(value)
	if t == "string" then --NYI: port to table accessors
		if refcount then
			idx = signatures.GetStringTableIndex(value, 0, 1)
			ref = signatures.GetStringTableIndexPtr(idx)
			ref.refcount = ref.refcount + 1
			return ffi.new("Value", {type = consts.String, value = idx})
		else
			return ffi.new("Value", {type = consts.String, value = signatures.GetStringTableIndex(value, 0, 1)})
		end
	elseif t == "number" then
		return ffi.new("Value", {type = consts.Number, valuef = value})
	elseif t == "nil" then
		return consts.null
	elseif t == "table" then
		local mt = getmetatable(value)
		if mt == require "datum".type or mt == require "list".type then
			return value.handle
		end
	else
		print("??? type: " .. t)
	end
end

local strcache = {}
function M.idx2str(index)
	if index == 0xFFFF then
		return ""
	end
	--null or blank string not sure which is more proper
	if strcache[tonumber(idx)] then
		return strcache[tonumber(idx)]
	end
	local entry = signatures.GetStringTableIndexPtr(index)
	if entry == ffi.null then
		return
	end
	local cache = ffi.string(entry.stringData)
	strcache[tonumber(index)] = cache
	return cache
end

function M.text2path(text)
	return signatures.Text2Path(signatures.GetStringTableIndex(text, 0, 1))
end

return M
