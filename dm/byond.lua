local ffi = require'ffi'ffi.cdef[[
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
			union {
				int value;
				float valuef;
			};
		};
		long long longlongman;
	};
} Value;
typedef struct IDArrayEntry {
	short size;
	int unknown;
	int refcountMaybe;
} IDArrayEntry;
typedef struct ProcArrayEntry {
	int procPath;//all these are string table IDs
	int procName;
	int procDesc;
	int procCategory;
	int procFlags;
	int bytecode;//idarray index
	char unknown[12];
} ProcArrayEntry;
typedef Value(*CallGlobalProc)(int unk1, int unk2, int proc_type, unsigned int proc_id, int const_0, int unk3, int unk4, Value* argList, unsigned int argListLen, int const_0_2, int const_0_3);
typedef Value(*Text2PathPtr)(unsigned int text);
typedef unsigned int(*GetStringTableIndex)(const char* string, int unk1, int unk2);
typedef void(*SetVariablePtr)(unsigned char type, unsigned int datumId, unsigned int varNameId, unsigned char varType, void* newValue);
typedef Value(*ReadVariablePtr)(unsigned char type, unsigned int datumId, unsigned int varNameId);
typedef Value(*CallProcPtr)(int unk1, int unk2, unsigned int proc_type, unsigned int proc_name, unsigned char datumType, unsigned int datumId, Value* argList, unsigned int argListLen, int unk4, int unk5);
typedef IDArrayEntry*(*GetIDArrayEntryPtr)(unsigned int index);
typedef int(*ThrowDMErrorPtr)(const char* msg);
typedef ProcArrayEntry*(*GetProcArrayEntryPtr)(unsigned int index);]]
local M = {}

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
Number 		= 0x2A--todo not globalize these nerds
M.null = ffi.new('Value', {type = Null, value = 0})

GetStringTableIndexPtr = ffi.cast('String*(__cdecl*)(int stringId)', hook.sigscan("byondcore.dll", "55 8B EC 8B 4D 08 3B 0D ?? ?? ?? ?? 73 10 A1"))
CallGlobalProc = ffi.cast('CallGlobalProc', hook.sigscan("byondcore.dll", "55 8B EC 81 EC 98 00 00 00 A1 ?? ?? ?? ?? 33 C5 89 45 FC 8B 55 14 8B 45 30 89 85 6C FF FF FF 53 8B 5D 24 56 8B 75 2C 57 8B 7D 28 81 FA FF FF 00 00 75 ?? 0F 57 C0 66 0F 13 85 68 FF FF FF 8B BD 6C FF FF FF 8B 9D 68 FF FF FF 85 F6"))
GetStringTableIndex = ffi.cast('GetStringTableIndex', hook.sigscan("byondcore.dll", "55 8B EC 8B 45 08 83 EC 18 53 8B 1D ?? ?? ?? ?? 56 57 85 C0 75 ?? 68 ?? ?? ?? ?? FF D3 83 C4 04 C6 45 10 00 80 7D 0C 00 89 45 E8 74 ?? 8D 45 10 50 8D 45 E8 50"))
Text2PathPtr = ffi.cast('Text2PathPtr', hook.sigscan("byondcore.dll", "55 8B EC 83 EC 08 56 57 8B 7D 08 57 E8 ?? ?? ?? ?? 83 C4 04 8B 30 A1 ?? ?? ?? ?? 89 45 FC A1 ?? ?? ?? ?? 89 45 F8 81 FF 9D 00 00 00 0F ?? ?? ?? ?? ?? 6A 06 57 E8 ?? ?? ?? ?? 52 50 FF 35 ?? ?? ?? ?? E8 ?? ?? ?? ?? 8B D0 83 C4 14 85 D2 74 ?? 8B 42 08"))
SetVariable = ffi.cast('SetVariablePtr', hook.sigscan("byondcore.dll", "55 8B EC 8B 4D 08 0F B6 C1 48 57 8B 7D 10 83 F8 53 0F ?? ?? ?? ?? ?? 0F B6 80 ?? ?? ?? ?? FF 24 85 ?? ?? ?? ?? FF 75 18 FF 75 14 57 FF 75 0C E8 ?? ?? ?? ?? 83 C4 10 5F 5D C3"))
GetVariable = ffi.cast('ReadVariablePtr', hook.sigscan("byondcore.dll", "55 8B EC 8B 4D 08 0F B6 C1 48 83 F8 53 0F 87 F1 00 00 00 0F B6 80 ?? ?? ?? ?? FF 24 85 ?? ?? ?? ?? FF 75 10 FF 75 0C E8 ?? ?? ?? ?? 83 C4 08 5D C3"))
CallProc = ffi.cast('CallProcPtr', hook.sigscan("byondcore.dll", "55 8B EC 83 EC 0C 53 8B 5D 10 8D 45 FF 56 8B 75 14 57 6A 01 50 FF 75 1C C6 45 FF 00 FF 75 18 6A 00 56 53"))
GetProcArrayEntry = ffi.cast('GetProcArrayEntryPtr', hook.sigscan("byondcore.dll", "55 8B EC 8B 45 08 3B 05 ? ? ? ? 72 04 33 C0 5D C3 8D 0C C0 A1 ? ? ? ? 8D 04 88 5D C3"))
ThrowDMError = ffi.cast('ThrowDMErrorPtr', hook.sigscan("byondcore.dll", "55 8B EC 6A FF 68 ?? ?? ?? ?? 64 A1 ?? ?? ?? ?? 50 83 EC 40 53 56 57 A1 ?? ?? ?? ?? 33 C5 50 8D 45 F4 64 A3 ?? ?? ?? ?? 89 65 F0 A1 ?? ?? ?? ?? 32 DB 85 C0 74 29 80 78 6B 02 0F 83 ?? ?? ?? ??"))
--local yolo = hook.sigscan("byondcore.dll", "?? ?? ?? ?? 8B F0 83 C4 04 85 F6 74 5F 0F B7 1E C1 E3 02 53 ")

--local idarr = ffi.cast('uint32_t*', yolo)
--GetIDArrayEntry = ffi.cast('GetIDArrayEntryPtr', idarr[0]+yolo+4)
local typecache = {
	procs = {}
}

local function ptr(n) return tonumber( ffi.cast('uint64_t', n) ) end
local function str2val(str)
	local idx = GetStringTableIndex(str, 0, 1)
	return ffi.new('Value', {type = String, value = idx})
end
local function value2lua(value)
	if value.type == String then
		return ffi.string( GetStringTableIndexPtr(value.value).stringData )
	elseif value.type == Number then
		return tonumber(value.fvalue)
	elseif value.type == Null then
		return nil
	else
		print('??? value2lua type: ' .. value.type )
	end
end
local function lua2value(value)
	local t = type(value)
	if t == 'string' then
		return ffi.new('Value', {type=String, value=GetStringTableIndex(value, 0, 1)})
	elseif t == 'number' then
		return ffi.new('Value', {type=Number, value=GetStringTableIndex(value, 0, 1)})
	elseif t == 'nil' then
		return M.null
	else print('??? type: ' .. a) end
end
function M.toLuaString(index)
	local entry = GetStringTableIndexPtr(index)
	if not entry then return end
	return ffi.string( entry.stringData )
end
local procMeta = {} procMeta.__index = procMeta
function procMeta:__tostring()
	return '[BYOND Proc #'..self.id..']: ' .. self.path
end
local prochooks = {}
function procMeta:hook(callback)
	prochooks[self.id] = callback
end
local procCallHook
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
			path = M.toLuaString(entry.procPath),
			name = M.toLuaString(entry.procName),
			category = M.toLuaString(entry.procCategory),
			desc = M.toLuaString(entry.procDesc),
			flags = tonumber(entry.procFlags)
		}, procMeta )
		typecache.procs[i] = {id=i, proc=entry}
		typecache.procs[ built.path ] = built
	else break end
end
local hooks = {}
function M.hook(fn, callback, cbType, errRet)
	if hooks[fn] then
		local hk = hooks[fn]
		hk.func = callback
		return hk
		
	end
	cbType = ffi.typeof(cbType or fn)
	local entry = {}
	entry.func = callback
	entry.cb = ffi.cast(cbType, function(...)
		local suc, err = pcall( entry.func, entry.trampoline, ... )
		if not suc then print("HOOK ERROR: (dangerous!) " .. tostring(err)) return errRet --[[eek]] end
		return err
	end)
	jit.off(callback)
	
	local hook = hook.create( ptr(fn), ptr(entry.cb) )
	local tramp = hook:hook()
	
	if tramp then
		entry.trampoline = ffi.cast( ffi.typeof(fn), tramp )
	else return nil end
	hooks[fn] = entry
	return entry
end

function M.getProc(path)
	return typecache.procs[path]
end
procCallHook = M.hook(CallGlobalProc, function(original, usrType, usrVal, c, procid, d, srcType, srcVal, argv, argc, callback, callbackVar)
	local theProc = GetProcArrayEntry(procid)
	--if byond.toLuaString(theProc.procPath) == '/proc/conoutput' and argc == 1 then
	--	print('dbg: ' ..byond.toLuaString(argv[0].value))
	--	return byond.null.longlongman
	--end
	
	if prochooks[tonumber(procid)] then
		local luad = {}
		for i = 1, tonumber(argc) do
			luad[i] = value2lua(argv[i-1])--dont skip arguments if they fail conversion
		end
		return lua2value(prochooks[tonumber(procid)](function(...)
			local honk = {}
			for k, v in pairs{...} do
				honk[k] = lua2value(v)
			end
			return value2lua(original(usrType, usrVal, c, procid, d, srcType, srcVal, ffi.new('Value[' .. #honk .. ']', honk), #honk, 0, 0))
		end, unpack(luad))).longlongman
	else

		local ret = original(usrType, usrVal, c, procid, d, srcType, srcVal, argv, argc, callback, callbackVar)
		print( usrType, usrVal, c, byond.toLuaString(theProc.procPath), d, srcType, srcVal, argv, argc, callback, callbackVar, '|', ret.type, ret.value)
		return ret.longlongman
	end
end, 'long long(*)(int unk1, int unk2, int const_2, unsigned int proc_id, int const_0, int unk3, int unk4, Value* argList, unsigned int argListLen, int const_0_2, int const_0_3)', M.null.longlongman)

local errhk = M.hook(ThrowDMError, function(orig, msg)
	print('DM error: ' .. ffi.string(msg))
	return orig(msg)
end, 'ThrowDMErrorPtr', 0)
M.ptr = ptr
return M