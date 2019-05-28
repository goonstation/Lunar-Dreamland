#define _CRT_SECURE_NO_WARNINGS
#include "headers/CapstoneDisassembler.hpp"
#define protected public
#include "headers/Detour/x86Detour.hpp"
#undef protected
//AAAAAAAAAAAAAAAAA ^
#include <lua.hpp>
extern "C" {
#include <luajit.h>

}
#include <sigscan.h>

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

static PLH::CapstoneDisassembler* m_activeDisassembler;
static int lj_hook_table;
lua_State* L = nullptr;
luaL_Reg lj_plhdetour[] = {
	{"getArch", [](lua_State * L) {
		auto detour = (PLH::x86Detour*) luaL_checkudata(L, 1, "PLH::x86Detour");
		lua_pushstring(L, "x86");
		return 1;
	}},
	{"getJmpSize", [](lua_State * L) {
		auto detour = (PLH::x86Detour*) luaL_checkudata(L, 1, "PLH::x86Detour");
		lua_pushnumber(L, detour->getJmpSize());
		return 1;
	}},
	{"hook", [](lua_State * L) {
		auto detour = (PLH::x86Detour*) luaL_checkudata(L, 1, "PLH::x86Detour");
		uint64_t trampoline;
		detour->m_userTrampVar = &trampoline;
		if (detour->hook()) {
			lua_pushnumber(L, (uintptr_t)trampoline);
		}
		else
		   lua_pushboolean(L, 0);
		return 1;
	}},
	{"unhook", [](lua_State * L) {
		auto detour = (PLH::x86Detour*) luaL_checkudata(L, 1, "PLH::x86Detour");
		lua_pushboolean(L, detour->unHook() == 1);
		return 1;
	}},
	{"__gc", [](lua_State * L) {
		auto detour = (PLH::x86Detour*) luaL_checkudata(L, 1, "PLH::x86Detour");
		lua_pushboolean(L, detour->unHook() == 1);
		return 1;
	}},
	{"getTrampoline", [](lua_State * L) {
		auto detour = (PLH::x86Detour*) luaL_checkudata(L, 1, "PLH::x86Detour");
		lua_pushnumber(L, (uintptr_t)detour->m_trampoline);
		return 1;
	}},
	{nullptr, nullptr}
};


void bh_initmetatables() {
	{
		luaL_newmetatable(L, "PLH::x86Detour");
		lua_pushvalue(L, -1);
		lua_setfield(L, -2, "__index");
		luaL_setfuncs(L, lj_plhdetour, 0);
		lua_pop(L, 1);
	}
}

static int lj_new_hook(lua_State * L) {
	void* orig = (void*)(uintptr_t)lua_tonumber(L, 1);
	void* hook = (void*)(uintptr_t)lua_tonumber(L, 2);
	uint64_t trampoline;
	PLH::x86Detour* detour = new (lua_newuserdata(L, sizeof(PLH::x86Detour))) PLH::x86Detour((const char*)orig, (const char*)hook, &trampoline, *m_activeDisassembler);
	luaL_setmetatable(L, "PLH::x86Detour");

	return 1;

}
static int lj_sigscan(lua_State * L) {
	if (lua_isnumber(L, 1)) {
		luaL_gsub(L, lua_tostring(L, 3), " ? ", " ?? ");
		lua_pushnumber(L, (lua_Number)(uintptr_t)Pocket::Sigscan::FindPattern(lua_tointeger(L, 1), lua_tointeger(L, 2), lua_tostring(L, -1), (short)luaL_optnumber(L, 4, 0)));
		lua_pop(L, 1);
		return 1;
	}
	else {
		luaL_gsub(L, lua_tostring(L, 2), " ? ", " ?? ");
		lua_pushnumber(L, (lua_Number)(uintptr_t)Pocket::Sigscan::FindPattern(lua_tostring(L, 1), lua_tostring(L, 2), (short)luaL_optnumber(L, 3, 0)));
		lua_pop(L, 1);
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
extern "C" EXPORT const char* BHOOK_Init(int n, char* v[]) {
	if (L) {
		return "ERROR: Already initialized.";
	}

	//m_activeDisassembler = new PLH::CapstoneDisassembler(PLH::Mode::x86);
	m_activeDisassembler = new PLH::CapstoneDisassembler(PLH::Mode::x86);
	L = lua_open();
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
extern "C" EXPORT const char* BHOOK_RunLua(int n, char* v[]) {
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
	else {
		return "!Lua not loaded!";
	}
}
extern "C" EXPORT const char* BHOOK_Unload(int n, char* v[]) {
	if (L) {
		lua_close(L);
		delete m_activeDisassembler;
		m_activeDisassembler = nullptr;
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

int test(lua_State * L) {
	void* ptr = (void*)lua_tointeger(L, 1);
	printf("ptr: %p\n", ptr);
	void* (*test)() = (void* (*)())ptr;
	printf("return value: %p\n", test());
	return 0;
}
NOINLINE void hookme() {
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

#endif