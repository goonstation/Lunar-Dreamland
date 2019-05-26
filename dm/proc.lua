require('converters')
require('byond_funcs')
require('hook')
local ffi = require('cdef')

local typecache = {
	procs = {}
}

local procMeta = {} procMeta.__index = procMeta
function procMeta:__tostring()
	return '[BYOND Proc #'..self.id..']: ' .. self.path
end

function procMeta:hook(callback)
	addHook(self.id, callback)
end

function procMeta:__call(...)
	local args = {...}
	local argv = {}
	for i = 1, #args do
		local v = lua2value(args[i])
		if v then table.insert(argv, v) end
	end
	local vals = ffi.new('Value[' .. #argv .. ']', argv)
	return value2lua(procCallHook.trampoline( 0, 0 --[[no src]], 2, self.id, 0, 0, 0, vals, #argv, 0, 0 --[[no callback]] ))
end

for i = 0, 0xFFFFFF do
	local entry = GetProcArrayEntry(i)
	if entry ~= ffi.null then
		local built = setmetatable( {
			id = i,
			proc = entry,
			path = toLuaString(entry.procPath),
			name = toLuaString(entry.procName),
			category = toLuaString(entry.procCategory),
			desc = toLuaString(entry.procDesc),
			flags = tonumber(entry.procFlags)
		}, procMeta )
		typecache.procs[i] = {id=i, proc=entry}
		typecache.procs[ built.path ] = built
	else break end
end

function getProc(path)
	return typecache.procs[path]
end