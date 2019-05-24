
local ffi = require'ffi'

if not DEFINED then DEFINED = true
	ffi.cdef[[
		typedef struct String
		{
			char* stringData;
			int unk1;
			int unk2;
			unsigned int refcount;
		} String;
		typedef struct Value {
			union {
				struct {
					char type;
					int value;
				};
				long long longlongman;
			};
		} Value;
		typedef Value(*CallGlobalProc)(int unk1, int unk2, int proc_type, unsigned int proc_id, int const_0, int unk3, int unk4, Value* argList, unsigned int argListLen, int const_0_2, int const_0_3);
		typedef Value(*Text2PathPtr)(unsigned int text);
		typedef unsigned int(*GetStringTableIndex)(const char* string, int unk1, int unk2);
		typedef void(*SetVariablePtr)(unsigned char type, unsigned int datumId, unsigned int varNameId, unsigned char varType, void* newValue);
		typedef Value(*ReadVariablePtr)(unsigned char type, unsigned int datumId, unsigned int varNameId);
		typedef Value(*CallProcPtr)(int unk1, int unk2, unsigned int proc_type, unsigned int proc_name, unsigned char datumType, unsigned int datumId, Value* argList, unsigned int argListLen, int unk4, int unk5);
		]]
end

Null		= 0x00
Turf		= 0x01
Obj			= 0x02
Mob			= 0x03
Area		= 0x04
Client		= 0x05
Image		= 0x0D
World		= 0x0E
Global		= 0x0E
Datum		= 0x21
Savefile	= 0x23
Path		= 0x26
List		= 0x54
Null		= 0x00
Turf		= 0x01
Obj			= 0x02
Mob			= 0x03
Area		= 0x04
String		= 0x06
World		= 0x0E
List		= 0x0F
Datum		= 0x21
Path		= 0x26
Number 		= 0x2A

local GetStringTableIndexPtr = ffi.cast('String*(__cdecl*)(int stringId)', hook.sigscan("byondcore.dll", "55 8B EC 8B 4D 08 3B 0D ?? ?? ?? ?? 73 10 A1"))
local CallGlobalProc = ffi.cast('CallGlobalProc', hook.sigscan("byondcore.dll", "55 8B EC 81 EC 98 00 00 00 A1 ?? ?? ?? ?? 33 C5 89 45 FC 8B 55 14 8B 45 30 89 85 6C FF FF FF 53 8B 5D 24 56 8B 75 2C 57 8B 7D 28 81 FA FF FF 00 00 75 ?? 0F 57 C0 66 0F 13 85 68 FF FF FF 8B BD 6C FF FF FF 8B 9D 68 FF FF FF 85 F6"))
local GetStringTableIndex = ffi.cast('GetStringTableIndex', hook.sigscan("byondcore.dll", "55 8B EC 8B 45 08 83 EC 18 53 8B 1D ?? ?? ?? ?? 56 57 85 C0 75 ?? 68 ?? ?? ?? ?? FF D3 83 C4 04 C6 45 10 00 80 7D 0C 00 89 45 E8 74 ?? 8D 45 10 50 8D 45 E8 50"))
local Text2PathPtr = ffi.cast('Text2PathPtr', hook.sigscan("byondcore.dll", "55 8B EC 83 EC 08 56 57 8B 7D 08 57 E8 ?? ?? ?? ?? 83 C4 04 8B 30 A1 ?? ?? ?? ?? 89 45 FC A1 ?? ?? ?? ?? 89 45 F8 81 FF 9D 00 00 00 0F ?? ?? ?? ?? ?? 6A 06 57 E8 ?? ?? ?? ?? 52 50 FF 35 ?? ?? ?? ?? E8 ?? ?? ?? ?? 8B D0 83 C4 14 85 D2 74 ?? 8B 42 08"))
local SetVariable = ffi.cast('SetVariablePtr', hook.sigscan("byondcore.dll", "55 8B EC 8B 4D 08 0F B6 C1 48 57 8B 7D 10 83 F8 53 0F ?? ?? ?? ?? ?? 0F B6 80 ?? ?? ?? ?? FF 24 85 ?? ?? ?? ?? FF 75 18 FF 75 14 57 FF 75 0C E8 ?? ?? ?? ?? 83 C4 10 5F 5D C3"))
local GetVariable = ffi.cast('ReadVariablePtr', hook.sigscan("byondcore.dll", "55 8B EC 8B 4D 08 0F B6 C1 48 83 F8 53 0F 87 F1 00 00 00 0F B6 80 ?? ?? ?? ?? FF 24 85 ?? ?? ?? ?? FF 75 10 FF 75 0C E8 ?? ?? ?? ?? 83 C4 08 5D C3"))
local CallProc = ffi.cast('CallProcPtr', hook.sigscan("byondcore.dll", "55 8B EC 83 EC 0C 53 8B 5D 10 8D 45 FF 56 8B 75 14 57 6A 01 50 FF 75 1C C6 45 FF 00 FF 75 18 6A 00 56 53"))

local function ptr(n) return tonumber( ffi.cast('uint64_t', n) ) end
local function str2val(str)
	local idx = GetStringTableIndex(str, 0, 1)
	return ffi.new('Value', {type = String, value = idx})
end
local function value2lua(a, b)
	local t, v = a and a.type or a, a and a.value or b
	if t == String then
		return ffi.string( GetStringTableIndexPtr(a.value).stringData )
	else
		print('??? type: ' .. a )
	end
end
local datummeta = {}
function datummeta:__index(key)
	return value2lua(GetVariable(self.__type, self.__value, GetStringTableIndex(key, 0, 1)))
end
function datummeta:__newindex(key, value)
	SetVariable( self.__type, self.__value, GetStringTableIndex(key, 0, 1), value.type, value.value )
end
local world = setmetatable({__type = World, __value=0}, datummeta)
print(world.address)
-- --local asd = Text2PathPtr(GetStringTableIndex("/proc/WorldOutput", 0, 1))

-- print("heck")
-- local trampoline
-- cpHook = hook.create(ptr(CallGlobalProc), ptr(ffi.cast('long long(*)(int unk1, int unk2, int const_2, unsigned int proc_id, int const_0, int unk3, int unk4, Value* argList, unsigned int argListLen, int const_0_2, int const_0_3)', function(a,b,c,d,e,...)
	-- --[[print'im a hook mom'
	-- --print(d)
	-- local name = GetStringTableIndexPtr(str2val("cats").value)
	-- name.refcount = name.refcount + 1]]
	-- local val = trampoline(a,b,c,d,e,...)
	-- --[[print(a,b,c,d,e,...)
	-- --print(bit.lshift(val.type, 8) + 0LL + val.value)
	-- print("hmmstve")
	-- print('global proc called: ' .. ffi.string(name.stringData) .. '! returning ' .. tostring(val or 'null'), val.type)]]
	-- return val.longlongman--a kinda embarassing hack since LuaJIT doesn't support pass-by-reference return values due to no decent abi
-- end)))
-- trampoline = cpHook:hook()
-- if(trampoline) then
	-- trampoline = ffi.cast('CallGlobalProc', trampoline)
	-- print'hook succeeded'
-- else
	-- print'hook failed'
-- end