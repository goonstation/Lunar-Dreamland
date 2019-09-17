#ifdef _WIN32
#include <windows.h>
#else
#include <time.h>
#endif
#include <chrono>
#include <cstring>
#include "urmem.hpp"
#include "sigscan.h"

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



typedef void(SendMaps)(void);
#ifdef _WIN32
typedef void(__cdecl SetVariable)(int dType, int dId, int varName, int newType, float newVal);
typedef unsigned int(__cdecl GetStringTableIndex)(const char* string, int handleEscapes, int duplicateString);
#else
typedef void(SetVariable)(int dType, int dId, int varName, int newType, float newVal);
typedef unsigned int(__attribute__((regparm(3))) GetStringTableIndex)(const char* string, int handleEscapes, int duplicateString);
#endif

urmem::hook* sendMapsDetour;
SendMaps* oSendMaps;
SetVariable* setVariable;
GetStringTableIndex* getStringTableIndex;

bool initialized = false;

int last_internal_tick_usage_string_id = 0;
int maptick_datum_id = 0;

char returnData[128];

float counterFrequency = 0;
void hSendMaps()
{
#ifdef _WIN32
	long long start;
	QueryPerformanceCounter((LARGE_INTEGER*)&start);
#else
	struct timespec start, end; 
	clock_gettime(CLOCK_MONOTONIC_RAW, &start);
#endif
	sendMapsDetour->call();
	float time_taken;
#ifdef _WIN32
	long long end;
	QueryPerformanceCounter((LARGE_INTEGER*)&end);
	time_taken = (end - start) / counterFrequency;
#else
	clock_gettime(CLOCK_MONOTONIC_RAW, &end);
	time_taken = end.tv_nsec - start.tv_nsec;
#endif
	//setVariable(0x21, maptick_datum_id, last_internal_tick_usage_string_id, 0x2A, time_taken * 10);
	//printf("setVariable(0x21, %u, %u, 0x2A, %f * 10)\n", maptick_datum_id, last_internal_tick_usage_string_id, time_taken);
}

std::string hook_sendmaps()
{
#ifdef _WIN32
	SendMaps* sendMaps = (SendMaps*)Pocket::Sigscan::FindPattern("byondcore.dll", "55 8B EC 6A FF 68 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 50 81 EC ?? ?? ?? ?? A1 ?? ?? ?? ?? 33 C5 89 45 F0 53 56 57 50 8D 45 F4 ?? ?? ?? ?? ?? ?? A0 ?? ?? ?? ?? 04 01 75 05 E8 ?? ?? ?? ?? E8");
#else
	SendMaps* sendMaps = (SendMaps*)Pocket::Sigscan::FindPattern("libbyond", "55 89 E5 57 56 53 81 EC ?? ?? ?? ?? 80 3D ?? ?? ?? ?? ?? 0F 84 ?? ?? ?? ??");
#endif
	if (!sendMaps)
	{
		return "Failed to find SendMaps signature.";
	}
	sendMapsDetour = new urmem::hook(urmem::get_func_addr(sendMaps), urmem::get_func_addr(&hSendMaps));
	if (!sendMapsDetour)
	{
		return "Failed to create detour.";
	}
	sendMapsDetour->enable();
	if (!sendMapsDetour->is_enabled())
	{
		return "Failed to hook SendMaps.";
	}
	oSendMaps = (SendMaps*)sendMapsDetour->get_original_addr();
	if (!oSendMaps)
	{
		sendMapsDetour->disable();
		return "Failed to cast trampoline.";
	}
	return "";
}

const char* find_function_pointers()
{
#ifdef _WIN32
	setVariable = (SetVariable*)Pocket::Sigscan::FindPattern("byondcore.dll", "55 8B EC 8B 4D 08 0F B6 C1 48 57 8B 7D 10 83 F8 53 0F ?? ?? ?? ?? ?? 0F B6 80 ?? ?? ?? ?? FF 24 85 ?? ?? ?? ?? FF 75 18 FF 75 14 57 FF 75 0C E8 ?? ?? ?? ?? 83 C4 10 5F 5D C3");
#else
	setVariable = (SetVariable*)Pocket::Sigscan::FindPattern("libbyond", "55 89 E5 ?? EC ?? ?? ?? ?? 89 75 ?? 8B 55 ?? 8B 75 ??");
#endif
	if (!setVariable)
	{
		return "ERROR: Failed to locate setVariable.";
	}
#ifdef _WIN32
	getStringTableIndex = (GetStringTableIndex*)Pocket::Sigscan::FindPattern("byondcore.dll", "55 8B EC 8B 45 08 83 EC 18 53 8B 1D ?? ?? ?? ?? 56 57 85 C0 75 ?? 68 ?? ?? ?? ?? FF D3 83 C4 04 C6 45 10 00 80 7D 0C 00 89 45 E8 74 ?? 8D 45 10 50 8D 45 E8 50");
#else
	getStringTableIndex = (GetStringTableIndex*)Pocket::Sigscan::FindPattern("libbyond", "55 89 E5 57 56 53 89 D3 83 EC ?? 85 C0");
#endif
	if (!getStringTableIndex)
	{
		return "ERROR: Failed to locate getStringTableIndex.";
	}
	return "";
}
extern "C" BYOND_FUNC initialize(int n, char* v[])
{
	//std::string maptick_datum_ref(v[0]);
	//maptick_datum_ref.erase(maptick_datum_ref.begin(), maptick_datum_ref.begin()+3);
	//maptick_datum_id = std::stoi(maptick_datum_ref.substr(maptick_datum_ref.find("0"), maptick_datum_ref.length() - 2), nullptr, 16);
	if (initialized)
	{
		return "MAPTICK ERROR: Library initialized twice!";
	}
	std::string result = hook_sendmaps();
	if (result.empty())
	{
		result = find_function_pointers();
		if (result.empty())
		{
			//last_internal_tick_usage_string_id = getStringTableIndex("last_internal_tick_usage", 0, 1);
			//printf("last_internal_tick_usage_string_id: %u\n", last_internal_tick_usage_string_id);
#ifdef _WIN32
			long long temp_freq;
			QueryPerformanceFrequency((LARGE_INTEGER*)&temp_freq);
			counterFrequency = static_cast<float>(temp_freq);
#endif
			initialized = true;
			return "MAPTICK: Initialization successful!";
		}
	}
	result = "MAPTICK ERROR: " + result;
#ifdef WIN32
	strcpy_s(returnData, 128, result.c_str());
#else
	strcpy(returnData, result.c_str());
#endif
	return returnData;
}

extern "C" BYOND_FUNC cleanup(int n, char* v[])
{
	if (sendMapsDetour)
	{
		sendMapsDetour->disable();
	}
	delete sendMapsDetour;
	initialized = false;
	return "";
}

#ifdef _WIN32
BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
#endif