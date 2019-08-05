
#include "stdafx.h"

#include "instruction.h"
#include "helpers.h"
#include "context.h"


Instruction::Instruction(Bytecode op)
{
	opcode_ = Opcode(op);
}

void Instruction::Disassemble(Context* context, Disassembler* dism)
{
	for (unsigned int i = 0; i < arguments(); i++)
	{
		std::uint32_t val = context->eat_add();
	}
}

std::string Instruction::bytes_str()
{
	std::string result;
	for (std::uint32_t b : bytes_)
	{
		result.append(tohex(b));
		result.append(" ");
	}

	return result;
}

void Instruction::add_byte(std::uint32_t byte)
{
	bytes_.emplace_back(byte);
}

