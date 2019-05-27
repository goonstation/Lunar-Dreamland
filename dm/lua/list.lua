require('byond_funcs')
local t2t = require'type2type'
local consts = require('defines')
local meta = {}
t2t.toLua[consts.List] = function(val)
	return setmetatable({
		internal_list = signatures.GetListArrayEntry(value.value),
		handle = val
	}, meta)
end
-- t2t.toValue NYI
function meta:__len()
	return self.internal_list.length
end
function meta:__index(acc)
	if acc == "length" then
		return self.internal_list.length
	elseif acc == "insert" then
		return function(val)
			local bvalue = t2t.toLua(val)
			AppendToContainer(consts.List, self.handle.value, bvalue.type, bvalue.value)
		end
	elseif acc == "remove" then
		return function(val)
			local bvalue = lua2value(val)
			RemoveFromContainer(consts.List, self.handle.value, bvalue.type, bvalue.value)
		end
	end
	local x = rawget(meta, acc)
	if x then return x end
	if(acc >= 1 and acc-1 < self.internal_list.length) then
		return t2t.toLua(self.internal_list.elements[acc-1])
	else
		return nil
	end
end

function meta:__newindex(index, newval)
	index = tonumber(index) or error('List index must be a number.')
	if(index > 1 and index-1 < self.length) then
		self.internal_list.elements[index-1] = lua2value(newval)
	end
end

local M = {
type = meta,
--new = NYI
}
return M