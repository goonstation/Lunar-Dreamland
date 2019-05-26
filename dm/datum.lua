local ffi = require('cdef')
require('byond_funcs')

datumM = {}--setmetatable(datumM, {__index=datumM})-- datumM.__index = datumM

ffi.metatype( 'Value', {
	__eq = function(a, b)
		if(ffi.istype('Value', b)) then return a.type == b.type and a.value == b.value
		elseif( type(b) == 'table' and getmetatable(b) == datumM ) then return a == b.handle end
		return false
	end
})

function datumM:__index(key)
	var = GetVariable( self.handle.type, self.handle.value, GetStringTableIndex( key, 0, 1))
	t = type(var)
	if t == 'table' then
		return rawget(datumM, key) or value2lua(var)
	elseif t == 'cdata' then
		return value2lua({type=var.type, value=var.value})
	end
end

function datumM:__newindex(key, val)
	local converted = lua2value(val, true) or M.null
	
	SetVariable( self.handle.type, self.handle.value, GetStringTableIndex( key, 0, 1), converted.type, converted.value )
end

local procCallHook

function datumM:invoke( procName, ... )
	local proc = M.getProc( procName )
	if not proc then error('no such proc ' .. procName) end
	local args = {...}
	local argv = {}
	for i = 1, #args do
		local v = lua2value(args[i])
		if v then table.insert(argv, v) end
	end
	local vals = ffi.new('Value[' .. #argv .. ']', argv)
	return value2lua(procCallHook.trampoline( 0, 0, 2, proc.id, 0, self.handle.type, self.handle.value, vals, #argv, 0, 0 --[[no callback]] ))
end

function datumM:__eq(b) if not b then return self == M.null end
	if ffi.istype('Value', b) then
		return self.handle == b
	else
		return self.handle == b or self.handle == b.handle
	end
end

function datumM:__tostring()
	return ("BYOND %s [0x%x%06x]"):format(types[tonumber(self.handle.type)], self.handle.type, self.handle.value)
end

function datumM:ref()
	return ("[0x%x%06x]"):format(self.handle.type, self.handle.value)
end