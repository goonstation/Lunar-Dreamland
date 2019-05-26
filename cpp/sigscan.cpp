#include <sigscan.h>

#ifdef _WIN32
#include <Windows.h>
#include <Psapi.h>
#else
// lol
#endif

#define INRANGE(x,a,b)	(x >= a && x <= b) 
#define getBits( x )	(INRANGE((x&(~0x20)),'A','F') ? ((x&(~0x20)) - 'A' + 0xa) : (INRANGE(x,'0','9') ? x - '0' : 0))
#define getByte( x )	(getBits(x[0]) << 4 | getBits(x[1]))

inline bool Pocket::Sigscan::DataCompare(const unsigned char* base, const char* pattern)
{
	for (; *(pattern + 2); ++base, pattern += *(pattern + 1) == ' ' ? 2 : 3)
	{
		if (*pattern != '?')
			if (*base != getByte(pattern))
				return false;
	}

	return *(pattern + 2) == 0;
}

void* Pocket::Sigscan::FindPattern(std::uintptr_t address, size_t size, const char* pattern, const short offset)
{
	for (size_t i = 0; i < size; ++i, ++address)
		if (DataCompare(reinterpret_cast<const unsigned char*>(address), pattern))
			return reinterpret_cast<void*>(address + offset);

	return nullptr;
}

void* Pocket::Sigscan::FindPattern(const char* moduleName, const char* pattern, const short offset)
{
	
	uint32_t rangeStart;
	uint32_t size;
#ifdef _WIN32
	if (!(rangeStart = reinterpret_cast<DWORD>(GetModuleHandleA(moduleName))))
		return nullptr;
	MODULEINFO miModInfo; GetModuleInformation(GetCurrentProcess(), reinterpret_cast<HMODULE>(rangeStart), &miModInfo, sizeof(MODULEINFO));
	size = miModInfo.SizeOfImage;
#else

	Dl_info info;
	struct stat buf;
	void* hdl;
	if(!(hdl = dlopen(moduleName, RTLD_NOLOAD))) return nullptr;

	if (!dladdr(hdl, &info)) return nullptr;

	if (!info.dli_fbase || !info.dli_fname)
	return nullptr;

	if (stat(info.dli_fname, &buf) != 0)
	return nullptr;

	rangeStart = reinterpret_cast<uint32_t>(info.dli_fbase);
	size = buf.st_size;
#endif

	return FindPattern(rangeStart, size, pattern, offset);
}
