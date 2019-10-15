#define _CRT_SECURE_NO_WARNINGS
#include "urmem.hpp"
//AAAAAAAAAAAAAAAAA ^
extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
	#include <lualib.h>
	#include <luajit.h>
}
#include "sigscan.h"
#include <cstring>

#if defined(_MSC_VER)
//  Microsoft 
#define EXPORT __declspec(dllexport)
#define IMPORT __declspec(dllimport)
#elif defined(__GNUC__)
//  GCC
#define EXPORT __attribute__((visibility("default")))
#define IMPORT
#include <dlfcn.h>
#include <link.h>
#else
//  do nothing and hope for the best?
#define EXPORT
#define IMPORT
#pragma warning Unknown dynamic link import/export semantics.
#endif

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#define BYOND_FUNC __declspec(dllexport) const char* _cdecl
#else
#define BYOND_FUNC __attribute__((visibility("default"))) const char*
#endif

#include <cstdio>

static int lj_hook_table;
lua_State* L = nullptr;


luaL_Reg lj_plhdetour[] = {
	{"getArch", [](lua_State * L) {
		auto detour = (urmem::hook*) luaL_checkudata(L, 1, "urmem::hook");
		lua_pushstring(L, "x86");
		return 1;
	}},
	{"hook", [](lua_State * L) {
		auto detour = (urmem::hook*)luaL_checkudata(L, 1, "urmem::hook");
		detour->enable();
		if (detour->is_enabled()) {
			lua_pushnumber(L, (uintptr_t)detour->get_original_addr());
		}
		else
			lua_pushboolean(L, 0);
		return 1;
	}},
	{"unhook", [](lua_State * L) {
		auto detour = (urmem::hook*) luaL_checkudata(L, 1, "urmem::hook");
		detour->disable();
		lua_pushboolean(L, !detour->is_enabled());
		return 1;
	}},
	{"__gc", [](lua_State * L) {
		auto detour = (urmem::hook*) luaL_checkudata(L, 1, "urmem::hook");
		detour->disable();
		lua_pushboolean(L, !detour->is_enabled());
		return 1;
	}},
	{"getTrampoline", [](lua_State * L) {
		auto detour = (urmem::hook*) luaL_checkudata(L, 1, "urmem::hook");
		lua_pushnumber(L, (uintptr_t)detour->get_original_addr());
		return 1;
	}},
	{nullptr, nullptr}
};

void bh_initmetatables() {
	{
		luaL_newmetatable(L, "urmem::hook");
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
		luaL_setfuncs(L, lj_plhdetour, 0);
		lua_pop(L, 1);
	}
}

static int lj_new_hook(lua_State * L) {
	void* orig = (void*)(uintptr_t)lua_tonumber(L, 1);
	void* hook = (void*)(uintptr_t)lua_tonumber(L, 2);
	urmem::hook* detour = (urmem::hook*)lua_newuserdata(L, sizeof(urmem::hook));
	printf("hooking %p to %p\n", orig, hook);
	detour->install(urmem::get_func_addr(orig), urmem::get_func_addr(hook));
	luaL_setmetatable(L, "urmem::hook");
	return 1;
}


static int lj_sigscan(lua_State * L) {
	if (lua_isnumber(L, 1)) {
		luaL_gsub(L, lua_tostring(L, 3), " ? ", " ?? ");
		lua_pushnumber(L, (lua_Number)(uintptr_t)Pocket::Sigscan::FindPattern(lua_tostring(L, 1), lua_tostring(L, 2)));
		//lua_pop(L, 1);
		return 1;
	}
	else {
		luaL_gsub(L, lua_tostring(L, 2), " ? ", " ?? ");
		lua_pushnumber(L, (lua_Number)(uintptr_t)Pocket::Sigscan::FindPattern(lua_tostring(L, 1), lua_tostring(L, 2)));
		//lua_pop(L, 1);
		return 1;
	}
}

#ifndef _WIN32
static void* disgusting;
static int callback(struct dl_phdr_info* info, size_t size, void* data)
{
	int j;
	//printf("name: %s vs %s\n", info->dlpi_name, (const char*)data);
	if (!strstr(info->dlpi_name, (const char*)data)) return 0;
	for (j = 0; j < info->dlpi_phnum; j++) {

		if (info->dlpi_phdr[j].p_type == PT_LOAD) {
			char* beg = (char*)info->dlpi_addr + info->dlpi_phdr[j].p_vaddr;
			char* end = beg + info->dlpi_phdr[j].p_memsz;
			disgusting = beg;
			return 0;
		}
	}
	return 0;
}
#endif


static int lj_get_module(lua_State * L) {
#ifdef _WIN32
	auto addr = GetModuleHandleA(lua_tostring(L, 1));
#else
	disgusting = nullptr;
	dl_iterate_phdr(callback, (void*)lua_tostring(L, 1));
	auto addr = (uintptr_t)disgusting;

#endif
	if (addr) {
		lua_pushnumber(L, (lua_Number)(uintptr_t)addr);//This is a SIN
	}
	else {
		lua_pushnil(L);
	}
	return 1;
}

#ifdef _WIN32
typedef unsigned int(GetStringTableIndex)(char* string, int handleEscapes, int duplicateString);
#else
typedef unsigned int(__attribute__((regparm(3))) GetStringTableIndex)(char* string, int handleEscapes, int duplicateString);
#endif
GetStringTableIndex* gstiTrampoline;

urmem::hook* gstiDetour;

#ifdef _WIN32
unsigned int gstiHook(char* string, int handleEscapes, int duplicateString) {
#else
__attribute__((regparm(3))) unsigned int gstiHook(char* string, int handleEscapes, int duplicateString) {
#endif
	printf("GetStringTableIndex(\"%s\", %i, %i);\n", string, handleEscapes, duplicateString);
	return gstiDetour->call<urmem::calling_convention::cdeclcall, unsigned int>(string, handleEscapes, duplicateString);
}

typedef void(SetVariable)(int dType, int dId, unsigned int varName, int newType, float newVal);
SetVariable* sv;
urmem::hook* svDetour;

void svHook(int dType, int dId, unsigned int varName, int newType, float newVal) {
	printf("SetVariable(%i, %i, %i, %i, %f)\n", dType, dId, varName, newType, newVal);
	svDetour->call(dType, dId, varName, newType, newVal);
}

GetStringTableIndex* getStringTableIndex;
extern "C" BYOND_FUNC testing(int n, char** v) {
	getStringTableIndex = (GetStringTableIndex*)Pocket::Sigscan::FindPattern("libbyond", "55 89 E5 57 56 53 89 D3 83 EC ?? 85 C0");
	if (!getStringTableIndex)
	{
		printf("ERROR: Failed to locate getStringTableIndex.\n");
		return "ERROR: Failed to locate getStringTableIndex.";
	}
	gstiDetour = new urmem::hook(urmem::get_func_addr(getStringTableIndex), urmem::get_func_addr(gstiHook));
	gstiDetour->enable();
	/*
	printf("a\n");
	sv = (SetVariable*)Pocket::Sigscan::FindPattern("libbyond", "55 89 E5 ?? EC ?? ?? ?? ?? 89 75 ?? 8B 55 ?? 8B 75 ??");
	if (!sv)
	{
		printf("ERROR: Failed to locate SetVariable.\n");
		return "ERROR: Failed to locate SetVariable.";
	}
	printf("b\n");
	svDetour = new urmem::hook(urmem::get_func_addr(sv), urmem::get_func_addr(&svHook));
	printf("c\n");
	if(!svDetour)
	{
		printf("ERROR: Failed to hook SetVariable.\n");
		return "ERROR: Failed to hook SetVariable.";
	}
	printf("d\n");
	svDetour->enable();
	printf("e\n");
	printf("%u\n", svDetour->is_enabled());*/
	return "";
}

extern "C" BYOND_FUNC BHOOK_Init(int n, char** v) {
	if (L) {
		return "ERROR: Already initialized.";
	}

	L = luaL_newstate();
	luaL_openlibs(L);
	bh_initmetatables();

	lua_newtable(L);
	lua_pushcfunction(L, lj_new_hook);
	lua_setfield(L, -2, "create");
	lua_pushcfunction(L, lj_sigscan);
	lua_setfield(L, -2, "sigscan");
	lua_pushcfunction(L, lj_get_module);
	lua_setfield(L, -2, "getModule");
	lua_setglobal(L, "hook");
#ifdef _WIN32
	AllocConsole();
	freopen("CONOUT$", "w", stdout);
#endif
	return "Setup complete!";
}

extern "C" BYOND_FUNC BHOOK_RunLua(int n, char* v[]) {
	if (n > 0 && L) {
		switch (luaL_loadstring(L, v[0])) {
		case 0: {
			auto ret = lua_pcall(L, 0, 0, 0);
			if (ret == 0) return "";
			if (ret == LUA_ERRRUN) return lua_tostring(L, -1);
			if (ret == LUA_ERRMEM) return "!Out of Memory.";
			break;
		}
		default:
			return lua_tostring(L, -1);
		}
	}
	else if (L) {
		return "!Not enough arguments!";
	}
	return "!Lua not loaded!";
}

extern "C" BYOND_FUNC BHOOK_Unload(int n, char* v[]) {
	if (L) {
		lua_close(L);
		L = nullptr;
		return "Unloaded!";
	}
	else {
		return "!Already unloaded!";
	}
}
#ifdef _WIN32
static HINSTANCE us;
BOOL WINAPI DllMain(
	_In_ HINSTANCE hinstDLL,
	_In_ DWORD     fdwReason,
	_In_ LPVOID    lpvReserved
) {
	switch (fdwReason) {
	case DLL_PROCESS_ATTACH:
		us = hinstDLL;
		break;
	}
	return TRUE;
}
#endif

int test(lua_State * L) {
	void* ptr = (void*)lua_tointeger(L, 1);
	printf("ptr: %p\n", ptr);
	void* (*test)() = (void* (*)())ptr;
	printf("return value: %p\n", test());
	return 0;
}
void hookme() {
	printf("Original function!");
}
const char* luacode = R"[](
print("Starting test...")
local ffi = require'ffi'
local original = ffi.cast('void(*)()', hookme)
print'Calling original...'
original()
local cb = ffi.cast('void(*)()', function() print'lua hook success, calling original' original() end)
local function ptr(n) return tonumber( ffi.cast('uint64_t', n) ) end
print("The hook target: " .. bit.tohex(hookme))
local tramp = newHook(hookme, ptr(cb))
local hook = tramp:hook()
if not hook then print'Detour failed!' return end
original = ffi.cast('void(*)()', hook)
print(original)
print("Test end.")
)[]";