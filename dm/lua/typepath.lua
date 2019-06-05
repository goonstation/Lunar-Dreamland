local ffi = require("ffi")
local consts = require("defines")
local signatures = require("signatures")
local t2t = require("type2type")

local M = require "byond"
local meta = {}

t2t.luaHandlers[consts.MobType] = function(val)
	return typecache.mobtypes[val.value]
end

for k, v in pairs {
	consts.ObjType,
	consts.DatumType
} do
	t2t.luaHandlers[v] = function(val)
		return M.typecache.types[val.value]
	end
end

M.typecache = {
	types = {},
	mobtypes = {}
}

function meta:__toString()
	return self.path
end

function add_type_entry(i, entry)
	local built =
		setmetatable(
		{
			id = i,
			type = entry,
			path = t2t.idx2str(entry.path),
			parentType = entry.parentTypeIdx,
			typeName = t2t.idx2str(entry.last_typepath_part)
		},
		meta
	)
	M.typecache.types[i] = built
	M.typecache.types[built.path] = built
end

for i = 0, 0xFFFFFF do
	local entry = signatures.GetTypeTableIndexPtr(i)
	if entry ~= ffi.null then
		add_type_entry(i, entry)
	else
		break
	end
end

for i = 0, 0xFFFFFF do
	local g_index = signatures.MobTableIndexToGlobalTableIndex(i)
	if g_index == ffi.null then
		break
	end
	M.typecache.mobtypes[i] = M.typecache.types[g_index[0]].type
	M.typecache.mobtypes[M.typecache.types[g_index[0]].path] = M.typecache.types[g_index[0]]
end

function M.T(typepath)
	return M.typecache.types[typepath]
end

function M.istype(thingy, wtype)
	return not (not thingy.type.path:find(wtype.path, 1, true)) --honk
end

return M
