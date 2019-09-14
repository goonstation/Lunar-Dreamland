#include <windows.h>
#include <chrono>

#include "polyhook/headers/CapstoneDisassembler.hpp"
#include "polyhook/headers/Detour/x86Detour.hpp"

#include "sigscan.h"


typedef void(SendMaps)(void);
typedef void(__cdecl SetVariable)(int dType, int dId, int varName, int newType, float newVal);
typedef unsigned int(__cdecl GetStringTableIndex)(const char* string, int handleEscapes, int duplicateString);

PLH::CapstoneDisassembler* disassembler;
PLH::x86Detour* sendMapsDetour;
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
	long long start;
	QueryPerformanceCounter((LARGE_INTEGER*)&start);
	oSendMaps();
	long long end;
	QueryPerformanceCounter((LARGE_INTEGER*)&end);
	float time_taken = (end - start) / counterFrequency;
	setVariable(0x21, maptick_datum_id, last_internal_tick_usage_string_id, 0x2A, time_taken * 10);
}


std::string hook_sendmaps()
{
	SendMaps* sendMaps = (SendMaps*)Pocket::Sigscan::FindPattern("byondcore.dll", "55 8B EC 6A FF 68 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 50 81 EC ?? ?? ?? ?? A1 ?? ?? ?? ?? 33 C5 89 45 F0 53 56 57 50 8D 45 F4 ?? ?? ?? ?? ?? ?? A0 ?? ?? ?? ?? 04 01 75 05 E8 ?? ?? ?? ?? E8");
	if (!sendMaps)
	{
		return "Failed to find SendMaps signature.";
	}
	disassembler = new PLH::CapstoneDisassembler(PLH::Mode::x86);
	if (!disassembler)
	{
		return "Failed to create disassembler.";
	}
	std::uint64_t sendMapsTrampoline;
	sendMapsDetour = new PLH::x86Detour((char*)sendMaps, (char*)&hSendMaps, &sendMapsTrampoline, *disassembler);
	if (!sendMapsDetour)
	{
		return "Failed to create detour.";
	}
	if (!sendMapsDetour->hook())
	{
		return "Failed to hook SendMaps.";
	}
	oSendMaps = PLH::FnCast(sendMapsTrampoline, oSendMaps);
	if (!oSendMaps)
	{
		sendMapsDetour->unHook();
		return "Failed to cast trampoline.";
	}
	return "";
}

std::string find_function_pointers()
{
	setVariable = (SetVariable*)Pocket::Sigscan::FindPattern("byondcore.dll", "55 8B EC 8B 4D 08 0F B6 C1 48 57 8B 7D 10 83 F8 53 0F ?? ?? ?? ?? ?? 0F B6 80 ?? ?? ?? ?? FF 24 85 ?? ?? ?? ?? FF 75 18 FF 75 14 57 FF 75 0C E8 ?? ?? ?? ?? 83 C4 10 5F 5D C3");
	if (!setVariable)
	{
		return "Failed to locate setVariable.";
	}
	getStringTableIndex = (GetStringTableIndex*)Pocket::Sigscan::FindPattern("byondcore.dll", "55 8B EC 8B 45 08 83 EC 18 53 8B 1D ?? ?? ?? ?? 56 57 85 C0 75 ?? 68 ?? ?? ?? ?? FF D3 83 C4 04 C6 45 10 00 80 7D 0C 00 89 45 E8 74 ?? 8D 45 10 50 8D 45 E8 50");
	if (!getStringTableIndex)
	{
		return "Failed to locate getStringTableIndex.";
	}
	return "";
}

extern "C" __declspec(dllexport) const char* initialize(int n, char* v[])
{
	std::string maptick_datum_ref(v[0]);
	maptick_datum_ref.erase(maptick_datum_ref.begin(), maptick_datum_ref.begin()+3);
	maptick_datum_id = std::stoi(maptick_datum_ref.substr(maptick_datum_ref.find("0"), maptick_datum_ref.length() - 2), nullptr, 16);
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
			last_internal_tick_usage_string_id = getStringTableIndex("last_internal_tick_usage", 0, 1);
			long long temp_freq;
			QueryPerformanceFrequency((LARGE_INTEGER*)&temp_freq);
			counterFrequency = static_cast<float>(temp_freq);
			initialized = true;
			return "MAPTICK: Initialization successful!";
		}
	}
	result = "MAPTICK ERROR: " + result;
	strcpy_s(returnData, 128, result.c_str());
	return returnData;
}

extern "C" __declspec(dllexport) const char* cleanup(int n, char* v[])
{
	if (sendMapsDetour)
	{
		sendMapsDetour->unHook();
	}
	delete sendMapsDetour;
	delete disassembler;
	initialized = false;
	return "";
}

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

