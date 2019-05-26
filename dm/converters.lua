local ffi = require('cdef')
local def = require('defines')
require('byond_funcs')
require('datum')
require('list')

function ptr(n) return tonumber( ffi.cast('uint64_t', n) ) end

function str2val(str)
	local idx = GetStringTableIndex(str, 0, 1)
	return ffi.new('Value', {type = def.String, value = idx})
end

function value2lua(value)
	local t = value.type
	if t == def.String then
		return ffi.string( GetStringTableIndexPtr(value.value).stringData )
	elseif t == def.Number then
		return tonumber(value.valuef)
	elseif t == def.Null then
		return nil
	elseif t == def.List then
		list_wrapper = {
			internal_list = GetListArrayEntry(value.value),
			id = value.value
		}
		return setmetatable(list_wrapper, listM)
	elseif t == def.Datum or t == def.Turf or t == def.World or t == def.Obj or t == def.Image or t == def.Client or t == def.Area or t == def.Mob then
		return setmetatable( {handle = value, call = datumM.call}, datumM )
	else
		print('??? value2lua type: ' .. value.type )
	end
end
--use refcount if we're assigning or invoking
function lua2value(value, refcount)
	local t = type(value)
	if t == 'string' then
		if refcount then
			local ret = ffi.new('Value', {type=def.String, value=GetStringTableIndex(value, 0, 1)})
			--local entry = 
			return ffi.new('Value', {type=def.String, value=GetStringTableIndex(value, 0, 1)})--nyi
		else
			return ffi.new('Value', {type=def.String, value=GetStringTableIndex(value, 0, 1)})
		end
	elseif t == 'number' then
		return ffi.new('Value', {type=def.Number, valuef=value})
	elseif t == 'nil' then
		return def.null
	elseif t == 'table' then
		if getmetatable(value) == datumM then
			return value.handle
		end
	else print('??? type: ' .. a) end
end

function toLuaString(index)
	local entry = GetStringTableIndexPtr(index)
	if not entry then return end
	return ffi.string( entry.stringData )
end