--local t2t = require'type2type'
local consts = require('defines')
local signatures = require('signatures')
print('Meta created')
listMeta = {}

-- t2t.toValue NYI
function listMeta:__len()
	return self.internal_list.length
end
function listMeta:__index(acc)
	if acc == "length" then
		return self.internal_list.length
	elseif acc == "append" then --it's append damn it
		return function(val)
			local bvalue = toValue(val)
			signatures.AppendToContainer(consts.List, self.handle.value, bvalue.type, bvalue.value)
		end
	elseif acc == "remove" then
		return function(val)
			local bvalue = toValue(val)
			signatures.RemoveFromContainer(consts.List, self.handle.value, bvalue.type, bvalue.value)
		end
	end
	local x = rawget(meta, acc)
	if x then return x end
	if(acc >= 1 and acc-1 < self.internal_list.length) then
		return toLua(self.internal_list.elements[acc-1])
	else
		return nil
	end
end

function listMeta:__newindex(index, newval)
	index = tonumber(index) or error('List index must be a number.')
	if(index >= 1 and index-1 < self.length) then
		self.internal_list.elements[index-1] = toValue(newval)
	end
end

--[[local M = {
type = meta,
--new = NYI
}
return M]]