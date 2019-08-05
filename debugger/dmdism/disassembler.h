#pragma once

#include "stdafx.h"
#include <vector>

#include "byond_structures.h"
#include "instruction.h"

class Context;

class Disassembler
{
public:
	Disassembler(std::vector<std::uint32_t> bc, std::vector<ProcInfo>& ps);
	std::vector<Instruction> disassemble();

	Context* context() const { return context_; }

	void disassemble_var(Instruction& instr);
	void add_call_args(Instruction& instr, unsigned int num_args);

private:
	Context* context_;
	
	Instruction disassemble_next();
};
