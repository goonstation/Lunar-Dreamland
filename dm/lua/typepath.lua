local ffi = require('ffi')
local consts = require('defines')
local signatures = require('signatures')
local t2t = require('type2type')

local M = require'byond'
local meta = {}

local typecache = {
	types = {},
	mobtypes = {}
}

function meta:__toString()
	return self.path
end

function add_type_entry(i, entry)
	local built = setmetatable( {
		id = i,
		type = entry,
		path = t2t.idx2str(entry.path),
		parentType = entry.parentTypeIdx,
		typeName = t2t.idx2str(entry.last_typepath_part),
	}, meta )
	typecache.types[i] = {id=i, type=built}
	typecache.types[ built.path ] = built
end

for i=0,0xFFFFFF do
	local entry = signatures.GetTypeTableIndexPtr(i)
	if entry ~= ffi.null then
		add_type_entry(i, entry)
	else break end
end

for i=0,0xFFFFFF do
	local g_index = signatures.MobTableIndexToGlobalTableIndex(i)
	if g_index == ffi.null then break end
	typecache.mobtypes[i] = {id=i, type=typecache.types[g_index[0]].type}
	typecache.mobtypes[typecache.types[g_index[0]].type.path] = typecache.types[g_index[0]].type
end

function M.T(typepath)
	return typecache.types[typepath]
end

function M.istype(thingy, type)
	local d_type = nil
	if thingy.handle.type == consts.Mob then
		d_type = typecache.mobtypes[thingy.type.value]
	else
		d_type = typecache.types[thingy.type.value]
	end
	if d_type.type.path:find(type.path, 1, true) then return true else return false end
end

return M