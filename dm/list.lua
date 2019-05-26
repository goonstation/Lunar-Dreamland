require('byond_funcs')
local def = require('defines')
listM = {}

function listM:__index(acc)
	if acc == "length" then
		return self.internal_list.length
	elseif acc == "append" then
		return function(val)
			bvalue = lua2value(val)
			AppendToContainer(def.List, self.id, bvalue.type, bvalue.value)
		end
	elseif acc == "remove" then
		return function(val)
			bvalue = lua2value(val)
			RemoveFromContainer(def.List, self.id, bvalue.type, bvalue.value)
		end
	end
	if(acc-1 < self.internal_list.length) then
		return value2lua(self.internal_list.elements[acc-1])
	else
		return nil
	end
end

function listM:__newindex(index, newval)
	if(index-1 < self.length) then
		self.internal_list.elements[index-1] = lua2value(newval)
	end
end