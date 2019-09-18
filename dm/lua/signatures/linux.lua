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

local function wip_sigscan(name)
	print("Unimplemented function scan: " .. name)
end

local function wip_varscan(name)
	print("Unimplemented variable scan: " .. name)
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

sigscan(
	"GetStringTableIndexPtr", 
	"GetStringTableIndexPtr", 
	"55 89 E5 83 EC ? 8B 45 ? 39 05 ? ? ? ?")
sigscan(
	"CallGlobalProc",
	"CallGlobalProc",
	"55 89 E5 57 56 53 81 EC ? ? ? ? 0F B6 45 ? 81 7D ? ? ? ? ?"
)
sigscan(
	"GetStringTableIndex",
	"GetStringTableIndex",
	"55 89 E5 57 56 53 89 D3 83 EC ? 85 C0"
)
sigscan(
	"Text2Path",
	"Text2PathPtr",
	"55 89 E5 83 EC ? 89 5D ? 8B 5D ? 89 75 ? 89 7D ? 89 1C 24 E8 ? ? ? ? 81 FB ? ? ? ?"
)
sigscan(
	"SetVariable",
	"SetVariablePtr",
	"55 89 E5 ? EC ? ? ? ? 89 75 ? 8B 55 ? 8B 75 ?"
)
sigscan(
	"GetVariable",
	"ReadVariablePtr",
	"55 89 E5 81 EC ? ? ? ? 8B 55 ? 89 5D ? 8B 5D ? 89 75 ? 8B 75 ?"
)
sigscan(
	"CallProc",
	"CallProcPtr",
	"55 89 E5 57 56 53 83 EC ? 8B 55 ? 0F B6 45 ? 8B 4D ? 8B 5D ? 89 14 24 8B 55 ? 88 45 ? 0F B6 F8 8B 75 ? 8D 45 ? 89 44 24 ? 89 F8 89 4C 24 ? 31 C9 C6 45 ? ? C7 44 24 ? ? ? ? ? E8 ? ? ? ? 80 7D ? ? 0F 84 ? ? ? ? 3D ? ? ? ? 74 ? 8B 4D ? 8B 55 ? 89 44 24 ? C7 44 24 ? ? ? ? ? 89 4C 24 ? 8B 4D ? 89 54 24 ? 8B 55 ? 89 7C 24 ? 89 5C 24 ? 89 4C 24 ? 8B 4D ? 89 54 24 ? 8B 55 ? 89 74 24 ? 89 4C 24 ? 8D 4D ? 89 54 24 ? 89 0C 24 E8 ? ? ? ? 8B 45 ? 8B 55 ? 8B 4D ? 83 EC ? 89 01 89 51 ? 8B 45 ? 8D 65 ? 5B 5E 5F 5D C2 ? ? 8D B4 26 ? ? ? ? F7 C7 ? ? ? ? 74 ? 80 7D ? ? 0F 84 ? ? ? ? 8B 4D ? C7 01 ? ? ? ? C7 41 ? ? ? ? ? 8B 45 ? 8B 55 ? 89 44 24 ? 89 14 24 E8 ? ? ? ? 8B 4D ?"
)
sigscan(
	"GetProcArrayEntry",
	"GetProcArrayEntryPtr",
	"55 31 C0 89 E5 8B 55 ? 39 15 ? ? ? ? 76 ? 8D 04 D2"
)
sigscan(
	"ThrowDMError",
	"ThrowDMErrorPtr",
	"55 89 E5 57 56 53 83 EC ? A1 ? ? ? ? 85 C0 0F 84 ? ? ? ? 0F B6 48 ?"
)
sigscan(
	"GetListArrayEntry",
	"GetListArrayEntryPtr",
	"55 89 E5 83 EC ? 8B 55 ? 3B 15 ? ? ? ? 72 ? 8D 45 ? 89 54 24 ? 89 04 24 C7 44 24 ? ? ? ? ? E8 ? ? ? ? 8B 45 ? 8B 55 ? 83 EC ? C7 44 24 ? ? ? ? ? 89 04 24 89 54 24 ? E8 ? ? ? ? C9 C3 90 A1 ? ? ? ? 8B 04 90 85 C0 74 ? 83 40 ? ? C9 C3 8D B6 ? ? ? ? 55"
)
sigscan(
	"AppendToContainer",
	"AppendToContainerPtr", 
	"55 8B EC 8B 4D 08 0F B6 C1 48 56 83 F8 53 0F")
sigscan(
	"RemoveFromContainer",
	"RemoveFromContainerPtr",
	"55 89 E5 83 EC ? 3C ? 89 5D ? 8B 5D ? 89 75 ? 8B 75 ? 89 7D ? 76 ?"
)
sigscan(
	"Path2Text",
	"Path2TextPtr",
	"55 89 E5 83 EC ? 8B 45 ? 8B 55 ? 3C ? 76 ? B8 ? ? ? ? C9 C3 90 0F B6 C8 FF 24 8D ? ? ? ? 8D B6 ? ? ? ? 83 7A ? ?"
)
sigscan(
	"GetTypeTableIndexPtr",
	"GetTypeTableIndexPtr",
	"55 31 C0 89 E5 8B 55 ? 39 15 ? ? ? ? 76 ? 6B C2 ?"
)
sigscan(
	"MobTableIndexToGlobalTableIndex",
	"MobTableIndexToGlobalTableIndex",
	"55 31 C0 89 E5 8B 55 ? 39 15 ? ? ? ? 76 ? 89 D0 "
)
sigscan(
	"GetAssocElement",
	"GetAssocElement",
	"55 89 E5 83 EC ? 89 4D ? B9 ? ? ? ?"
)
sigscan(
	"SetAssocElement",
	"SetAssocElement",
	"55 B9 ? ? ? ? 89 E5 83 EC ? 89 75 ?"
)
sigscan(
	"CreateList",
	"CreateList",
	"55 89 E5 57 56 53 83 EC ? A1 ? ? ? ? 8B 75 ? 85 C0 0F 84 ? ? ? ?"
)
sigscan(
	"New",
	"New",
	"55 89 E5 57 89 C7 56 53 81 EC ? ? ? ? A1 ? ? ? ?"
)

wip_sigscan(
	"TempBreakpoint",
	"TempBreakpoint",
	"55 8B EC 8B ?? ?? ?? ?? ?? 83 EC 08 66 FF 42 14 81 3D ?? ?? ?? ?? ?? ?? ?? ?? 0F B7 4A 14 8B 42 10 53 56 57 0F B7 34 88 73 15 E8 ?? ?? ?? ?? DC 0D ?? ?? ?? ?? DD 5D F8"
)

wip_sigscan(
	"CrashProc",
	"CrashProc",
	"55 8B EC 6A FF 68 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 50 A1 ?? ?? ?? ?? 33 C5 50 8D 45 F4 ?? ?? ?? ?? ?? ?? A1 ?? ?? ?? ?? A8 01 75 2D 83 C8 01 A3 ?? ?? ?? ?? B9 ?? ?? ?? ?? C7 45 ?? ?? ?? ?? ?? E8 ?? ?? ?? ?? 68 ?? ?? ?? ?? E8 ?? ?? ?? ?? 83 C4 04 C7 45 ?? ?? ?? ?? ?? B9 ?? ?? ?? ?? E8 ?? ?? ?? ?? 8D 45 0C B9 ?? ?? ?? ?? 50 FF 75 08 E8 ?? ?? ?? ?? B9 ?? ?? ?? ?? E8 ?? ?? ?? ?? FF 35 ?? ?? ?? ?? E8 ?? ?? ?? ?? 83 C4 04 8B 4D F4 ?? ?? ?? ?? ?? ?? ?? 59 8B E5 5D C3"
)

wip_sigscan(
	"ResumeIn",
	"ResumeIn",
	"55 8B EC F3 0F 10 45 0C 56 51 F3 0F 11 04 24 E8 ?? ?? ?? ?? 8B F0 83 C4 04 B8 ?? ?? ?? ?? 85 F6 75 0F F3 0F 10 45 0C 0F 2F ?? ?? ?? ?? ?? 0F 47 F0 81 3D"
)

wip_varscan(
	"CurrentExecutionContext",
	"ExecutionContext***",
	"A1 ?? ?? ?? ?? 8D ?? ?? ?? ?? ?? 83 C4 08 89 48 28 8D ?? ?? ?? ?? ?? 89 48 2C 83 3D ?? ?? ?? ?? ?? 74 25 8B 00 FF 30 E8 ?? ?? ?? ?? 83 C4 04 FF 30 E8 ?? ?? ?? ?? 83 C4 04 FF 30 68 ?? ?? ?? ?? E8 ?? ?? ?? ?? 83 C4 08 66 ?? ?? ?? ?? ?? ?? A1 ?? ?? ?? ?? 75 28 A8 02 75 24 E8 ?? ?? ?? ?? 85 C0 75 09 50",
	1,
	0
)

varscan(
	"ProcSetupTable",
	"ProcSetupEntry****",
	"A1 ? ? ? ? 8B 04 98 85 C0 74 ? 89 04 24 E8 ? ? ? ? 8B 15 ? ? ? ?",
	1
)

wip_varscan(
	"AlmostTotalProcs",
	"int**",
	"A1 ?? ?? ?? ?? FF 34 B8 FF D6 47 83 C4 04 3B ?? ?? ?? ?? ?? 72 EA FF 35 ?? ?? ?? ?? FF D6 33 FF 83 C4 04 39 ?? ?? ?? ?? ?? 76 1E",
	1,
	0 --Add 1 before dereferencing
)

sigscan(
	"SendMaps",
	"SendMapsPtr",
	"55 89 E5 57 56 53 81 EC ? ? ? ? 80 3D ? ? ? ? ? 0F 84 ? ? ? ?"
)

print(ret.ProcSetupTable)
return ret