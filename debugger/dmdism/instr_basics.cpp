
#include "stdafx.h"

#include "instr_basics.h"
#include "helpers.h"
#include "context.h"



void Instr_PUSHVAL::Disassemble(Context* context, Disassembler* dism)
{
	std::uint32_t type = context->eat();
	if (type == NUMBER)
	{
		typedef union
		{
			int i; float f;
		} funk;
		funk f;
		std::uint32_t first_part = context->eat();
		std::uint32_t second_part = context->eat();
		f.i = first_part << 16 | second_part; //32 bit floats are split into two 16 bit halves in the bytecode. Cool right?
		opcode().add_info(" NUMBER " + tohex(f.i));
		comment_ = std::to_string(f.f);
		return;
	}

	if (datatype_names.find(static_cast<DataType>(type)) != datatype_names.end())
	{
		opcode().add_info(" " + datatype_names.at(static_cast<DataType>(type)));
	}
	else
	{
		opcode().add_info(" ??? ");
	}
	std::uint32_t value = context->eat();
	if (type == STRING)
	{
		comment_ += '"' + byond_tostring(value) + '"';
	}
}
