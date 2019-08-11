#include "stdafx.h"
#include "helpers.h"

std::string byond_tostring(int idx)
{
	String* s = getStringRaw(idx);
	s->refcount++;
	return std::string(s->stringData);
}

int intern_string(std::string str)
{
	int idx = getStringIndex(str.c_str(), 0, 1);
	String* s = getStringRaw(idx);
	s->refcount++;
	return idx;
}

std::string tohex(int numero) {
	std::stringstream stream;
	stream << std::hex << std::uppercase << numero;
	return "0x" + std::string(stream.str());
}

std::string todec(int numero) {
	std::stringstream stream;
	stream << std::dec << numero;
	return std::string(stream.str());
}
