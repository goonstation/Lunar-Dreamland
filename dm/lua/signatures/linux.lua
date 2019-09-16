local ffi = require("ffi")
local ret = {}

local function scan(name, signature, module, offset)
	local scanned = hook.sigscan(module or "libbyond", signature)
	if not scanned or scanned == 0 then
		print("Sigscan failed: " .. name)
		error("Signature not found: " .. scanned)
	end
	return scanned + (offset or 0)
end

local function sigscan(name, type, signature, module, offset)
	ret[name] = ffi.cast(type, scan(name, signature, module, offset))
end

local function varscan(name, type, signature, offset, dereferences, module)
	local addr = ffi.cast(type, scan(name, signature, module, offset))
	print("Dereferences:", dereferences)
	for i = 0, (dereferences or 1) do
		print("Dereferencing")
		addr = addr[0]
	end
	ret[name] = addr
end

sigscan("GetStringTableIndexPtr", "GetStringTableIndexPtr", "55 89 E5 83 EC ?? 8B 45 ?? 39 05 ?? ?? ?? ??")
sigscan(
	"CallGlobalProc",
	"CallGlobalProc",
	"55 89 E5 57 56 53 81 EC ?? ?? ?? ?? 0F B6 45 ?? 81 7D ?? ?? ?? ?? ??"
)
sigscan(
	"GetStringTableIndex",
	"GetStringTableIndex",
	"55 89 E5 57 56 53 89 D3 83 EC ?? 85 C0"
)
sigscan(
	"Text2Path",
	"Text2PathPtr",
	"55 89 E5 83 EC ?? 89 5D ?? 8B 5D ?? 89 75 ?? 89 7D ?? 89 1C 24 E8 ?? ?? ?? ?? 81 FB ?? ?? ?? ??"
)
sigscan(
	"SetVariable",
	"SetVariablePtr",
	"55 89 E5 ?? EC ?? ?? ?? ?? 89 75 ?? 8B 55 ?? 8B 75 ??"
)
sigscan(
	"GetVariable",
	"ReadVariablePtr",
	"55 89 E5 81 EC ?? ?? ?? ?? 8B 55 ?? 89 5D ?? 8B 5D ?? 89 75 ?? 8B 75 ??"
)
sigscan(
	"SendMaps",
	"SendMapsPtr",
	"55 89 E5 57 56 53 81 EC ?? ?? ?? ?? 80 3D ?? ?? ?? ?? ?? 0F 84 ?? ?? ?? ??"
)