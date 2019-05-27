local t2t = require'type2type'
local consts = require('defines')
local signatures = require('signatures')

local meta = {}

t2t.luaHandlers[consts.List] = function(val)
	return setmetatable({internal_list = signatures.GetListArrayEntry(val.value), handle = val}, meta)
end

-- t2t.toValue NYI
function meta:__len()
	return self.internal_list.length
end

function meta:__index(acc)
	if acc == "length" then
		return self.internal_list.length
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
	if(index >= 1 and index-1 < self.length) then
		self.internal_list.elements[index-1] = t2t.toValue(newval)
	end
end

function meta:append(val)
	local bvalue = t2t.toValue(val)
	signatures.AppendToContainer(consts.List, self.handle.value, bvalue.type, bvalue.value)
end

function meta:remove(val)
	error("Fix signature before calling list.remove()")
	-- local bvalue = t2t.toValue(val)
	-- signatures.RemoveFromContainer(consts.List, self.handle.value, bvalue.type, bvalue.value)
end

local M = {
type = meta,
--new = NYI
}
return M