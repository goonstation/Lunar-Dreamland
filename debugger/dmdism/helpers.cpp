#include "stdafx.h"
#include "helpers.h"

std::string byond_tostring(int idx)
{
	String* s = getStringRaw(idx);
	s->refcount++;
	return std::string(s->stringData);
}

std::string tohex(int numero) {
	std::stringstream stream;
	stream << std::hex << std::uppercase << numero;
	return "0x" + std::string(stream.str());
}