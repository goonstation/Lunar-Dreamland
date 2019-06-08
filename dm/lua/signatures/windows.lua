local ffi = require("ffi")
local ret = {}
local function sigscan(name, type, signature)
	local scanned = hook.sigscan("byondcore.dll", signature)
	if not scanned or scanned == 0 then
		print("Sigscan failed: " .. name)
		error("Signature not found: " .. scanned)
	end
	local casted = ffi.cast(type, scanned)
	ret[name] = casted
end
sigscan("GetStringTableIndexPtr", "GetStringTableIndexPtr", "55 8B EC 8B 4D 08 3B 0D ?? ?? ?? ?? 73 10 A1")
sigscan(
	"CallGlobalProc",
	"CallGlobalProc",
	"55 8B EC 81 EC 98 00 00 00 A1 ?? ?? ?? ?? 33 C5 89 45 FC 8B 55 14 8B 45 30 89 85 6C FF FF FF 53 8B 5D 24 56 8B 75 2C 57 8B 7D 28 81 FA FF FF 00 00 75 ?? 0F 57 C0 66 0F 13 85 68 FF FF FF 8B BD 6C FF FF FF 8B 9D 68 FF FF FF 85 F6"
)
sigscan(
	"GetStringTableIndex",
	"GetStringTableIndex",
	"55 8B EC 8B 45 08 83 EC 18 53 8B 1D ?? ?? ?? ?? 56 57 85 C0 75 ?? 68 ?? ?? ?? ?? FF D3 83 C4 04 C6 45 10 00 80 7D 0C 00 89 45 E8 74 ?? 8D 45 10 50 8D 45 E8 50"
)
sigscan(
	"Text2Path",
	"Text2PathPtr",
	"55 8B EC 83 EC 08 56 57 8B 7D 08 57 E8 ?? ?? ?? ?? 83 C4 04 8B 30 A1 ?? ?? ?? ?? 89 45 FC A1 ?? ?? ?? ?? 89 45 F8 81 FF 9D 00 00 00 0F ?? ?? ?? ?? ?? 6A 06 57 E8 ?? ?? ?? ?? 52 50 FF 35 ?? ?? ?? ?? E8 ?? ?? ?? ?? 8B D0 83 C4 14 85 D2 74 ?? 8B 42 08"
)
sigscan(
	"SetVariable",
	"SetVariablePtr",
	"55 8B EC 8B 4D 08 0F B6 C1 48 57 8B 7D 10 83 F8 53 0F ?? ?? ?? ?? ?? 0F B6 80 ?? ?? ?? ?? FF 24 85 ?? ?? ?? ?? FF 75 18 FF 75 14 57 FF 75 0C E8 ?? ?? ?? ?? 83 C4 10 5F 5D C3"
)
sigscan(
	"GetVariable",
	"ReadVariablePtr",
	"55 8B EC 8B 4D 08 0F B6 C1 48 83 F8 53 0F 87 F1 00 00 00 0F B6 80 ?? ?? ?? ?? FF 24 85 ?? ?? ?? ?? FF 75 10 FF 75 0C E8 ?? ?? ?? ?? 83 C4 08 5D C3"
)
sigscan(
	"CallProc",
	"CallProcPtr",
	"55 8B EC 83 EC 0C 53 8B 5D 10 8D 45 FF 56 8B 75 14 57 6A 01 50 FF 75 1C C6 45 FF 00 FF 75 18 6A 00 56 53"
)
sigscan(
	"GetProcArrayEntry",
	"GetProcArrayEntryPtr",
	"55 8B EC 8B 45 08 3B 05 ?? ?? ?? ?? 72 04 33 C0 5D C3 8D 0C C0 A1 ?? ?? ?? ?? 8D 04 88 5D C3"
)
sigscan(
	"ThrowDMError",
	"ThrowDMErrorPtr",
	"55 8B EC 6A FF 68 ?? ?? ?? ?? 64 A1 ?? ?? ?? ?? 50 83 EC 40 53 56 57 A1 ?? ?? ?? ?? 33 C5 50 8D 45 F4 64 A3 ?? ?? ?? ?? 89 65 F0 A1 ?? ?? ?? ?? 32 DB 85 C0 74 29 80 78 6B 02 0F 83 ?? ?? ?? ??"
)
sigscan(
	"GetListArrayEntry",
	"GetListArrayEntryPtr",
	"55 8B EC 8B 4D 08 3B 0D ?? ?? ?? ?? 73 11 A1 ?? ?? ?? ?? 8B 04 88 85 C0 74 05 FF 40 10 5D C3 6A 0F 51 E8 ?? ?? ?? ?? 68 ?? ?? ?? ?? 52 50 E8 ?? ?? ?? ?? 83 C4 14 5D C3"
)
sigscan("AppendToContainer", "AppendToContainerPtr", "55 8B EC 8B 4D 08 0F B6 C1 48 56 83 F8 53 0F")
sigscan(
	"RemoveFromContainer",
	"RemoveFromContainerPtr",
	"55 8B EC 8B 45 08 3B 05 ? ? ? ? 72 04 33 C0 5D C3 8D 0C C0 A1 ? ? ? ? 8D 04 88 5D C3"
)
sigscan(
	"Path2Text",
	"Path2TextPtr",
	"55 8B EC 8B 4D 08 0F B6 C1 48 83 F8 53 0F 87 ?? ?? ?? ?? 0F B6 80 ?? ?? ?? ?? FF 24 85 ?? ?? ?? ?? FF 75 0C E8 ?? ?? ?? ?? 83 C4 04 85 C0 0F 84"
)
sigscan(
	"GetTypeTableIndexPtr",
	"GetTypeTableIndexPtr",
	"55 8B EC 8B 45 08 3B 05 ?? ?? ?? ?? 72 04 33 C0 5D C3 6B C0 64 03 05 ?? ?? ?? ?? 5D C3"
)
sigscan(
	"MobTableIndexToGlobalTableIndex",
	"MobTableIndexToGlobalTableIndex",
	"55 8B EC 8B 45 08 3B 05 ?? ?? ?? ?? 72 04 33 C0 5D C3 C1 E0 04 03 05 ?? ?? ?? ?? 5D C3"
)
sigscan(
	"GetAssocElement",
	"GetAssocElement",
	"55 8B EC 51 8B 4D 08 C6 45 FF 00 80 F9 05 76 11 80 F9 21 74 10 80 F9 0D 74 0B 80 F9 0E 75 65 EB 04 84 C9 74 5F"
)
sigscan(
	"SetAssocElement",
	"SetAssocElement",
	"55 8B EC 83 EC 14 8B 4D 08 C6 45 FF 00 80 F9 05 76 15 80 F9 21 74 14 80 F9 0D 74 0F 80 F9 0E 0F 85 80 00 00 00 EB 04 84 C9 74 7A 6A 00 8D 45 FF 50 FF 75 0C 51 6A 00 6A 7C"
)
sigscan(
	"CreateList",
	"CreateList",
	"55 8B EC 8B 0D ?? ?? ?? ?? 56 85 C9 74 1B A1 ?? ?? ?? ?? 49 89 0D ?? ?? ?? ?? 8B 34 88 81 FE FF FF 00 00 0F"
)
return ret
