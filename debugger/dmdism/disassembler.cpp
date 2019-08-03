#include "stdafx.h"
#include "disassembler.h"
#include "opcodes.h"
#include "helpers.h"
#include <iostream>
#include <sstream>
#include <algorithm>

Disassembler::Disassembler(std::vector<int> bc, std::vector<ProcInfo>& ps) : procs(ps)
{
	bytecode = std::vector<Opcode>();
	for(int& b : bc)
	{
		bytecode.push_back(static_cast<Opcode>(b));
	}
}


std::vector<Instruction> Disassembler::disassemble()
{
	std::vector<Instruction> instrs;
	while (current_offset < bytecode.size()) {
		instrs.push_back(disassemble_next());
	}
	return instrs;
}

Instruction Disassembler::prepare_instruction()
{
	Instruction instr;
	instr.offset = current_offset;
	Opcode op = eat();
	instr.mnemonic = mnemonics.at(op);
	instr.bytes = tohex(op);
	instr.comment = "";
	return instr;
}

void Disassembler::add_var_disassembly(Instruction& instr)
{
	Instruction acc = disassemble_var();
	instr.mnemonic += acc.mnemonic;
	instr.bytes += acc.bytes;
	instr.comment += acc.comment;
}

void Disassembler::add_call_args(Instruction& instr, int num_args)
{
	instr.comment += "(";
	for (int i = 0; i<num_args; i++)
	{
		instr.comment += "STACK" + std::to_string(i) + ", ";
	}
	if (num_args) {
		instr.comment.pop_back();
		instr.comment.pop_back();
	}
	instr.comment += ")";
}


Instruction Disassembler::disassemble_next()
{
	const Opcode current_opcode = peek();
	if(std::find(zero_argument_opcodes.begin(), zero_argument_opcodes.end(), current_opcode) != zero_argument_opcodes.end())
	{
		return disassemble_zeroarg();
	}

	if (std::find(variable_accessors.begin(), variable_accessors.end(), current_opcode) != variable_accessors.end())
	{
		return disassemble_variable_access();
	}
	if(simple_argument_counts.find(current_opcode) != simple_argument_counts.end())
	{
		return disassemble_simple();
	}
	switch(current_opcode)
	{
	case PUSHVAL:
		return disassemble_pushval();
	case CALLNR:
	case CALL:
		return disassemble_call();
	case CALLGLOB:
		return disassemble_global_call();
	}
	return disassemble_unknown();
}

Instruction Disassembler::disassemble_simple()
{
	Instruction instr = prepare_instruction();
	const int arg_len = simple_argument_counts.at(last_opcode);
	for (int i = 0; i<arg_len; i++)
	{
		eat_add(instr);
	}
	instr.comment = "";
	return instr;
}

Instruction Disassembler::disassemble_unknown()
{
	Instruction instr;
	instr.offset = current_offset;
	Opcode op = eat();
	instr.mnemonic = "???";
	instr.bytes = tohex(op);
	instr.comment = "";
	return instr;
}

Instruction Disassembler::disassemble_zeroarg()
{
	return prepare_instruction();
}

Instruction Disassembler::disassemble_variable_access()
{
	Instruction instr = prepare_instruction();
	add_var_disassembly(instr);
	return instr;
}

Instruction Disassembler::disassemble_var()
{
	Instruction res;
	switch (peek())
	{
	case SUBVAR:
		{
		Opcode val = eat();
		res.bytes += " " + tohex(val);
		res.mnemonic += " SUBVAR";
		Instruction subexpr = disassemble_var();
		res.bytes += subexpr.bytes;
		res.mnemonic += subexpr.mnemonic;
		val = eat();
		res.bytes += " " + tohex(val);
		res.mnemonic += " " + std::to_string(val);
		res.comment += subexpr.comment;
		res.comment += ".";
		res.comment += byond_tostring(val);
		return res;
		}

	case LOCAL:
	case GLOBAL:
	case CACHE:
	case ARG:
		{
		Opcode type = eat();
		res.bytes += " " + tohex(type);
		Opcode localno = eat();
		res.bytes += " " + tohex(localno);
		res.mnemonic += " " + modifier_names.at(static_cast<AccessModifier>(type)) + std::to_string(localno);
		res.comment += modifier_names.at(static_cast<AccessModifier>(type)) + std::to_string(localno);
		return res;
		}
	case WORLD:
	case NULL_:
	case DOT:
	case SRC:
		{
		Opcode type = eat();
		res.bytes += " " + tohex(type);
		res.mnemonic += " " + modifier_names.at(static_cast<AccessModifier>(type));
		res.comment += modifier_names.at(static_cast<AccessModifier>(type));
		return res;
		}
	default:
		{
		Opcode val = eat_add(res);
		return res;
		}
	}
}

Instruction Disassembler::disassemble_pushval()
{
	Instruction instr = prepare_instruction();
	Opcode type = eat();
	instr.bytes += " "+tohex(type);
	if (type == NUMBER)
	{
		typedef union
		{
			int i; float f;
		} funk;
		funk f;
		f.i = eat();
		instr.bytes += " " + tohex(f.i);
		instr.bytes += " " + tohex(eat());
		instr.mnemonic += " NUMBER " + tohex(f.i);
		instr.comment = std::to_string(f.f);
		return instr;
	}
	if (datatype_names.find(static_cast<DataType>(type)) != datatype_names.end())
	{
		instr.mnemonic += " " + datatype_names.at(static_cast<DataType>(type));
	}
	else
	{
		instr.mnemonic += " ??? ";
	}
	Opcode value = eat_add(instr);
	if(type == STRING)
	{
		instr.comment += '"' + byond_tostring(value) + '"';
	}
	return instr;
}

Instruction Disassembler::disassemble_call()
{
	Instruction instr = prepare_instruction();
	instr.comment = "";
	add_var_disassembly(instr);
	Opcode procid = eat_add(instr);
	std::string name = byond_tostring(procid);
	std::replace(name.begin(), name.end(), ' ', '_');
	instr.comment += name;
	Opcode num_args = eat_add(instr);
	add_call_args(instr, num_args);
	return instr;
}

Instruction Disassembler::disassemble_global_call()
{
	Instruction instr = prepare_instruction();
	Opcode num_args = eat_add(instr);
	Opcode proc_id = eat_add(instr);
	instr.comment += procs[proc_id].name;
	add_call_args(instr, num_args);
	return instr;
}






Opcode Disassembler::peek()
{
	if (current_offset >= bytecode.size())
	{
		std::cout << "READ PAST END OF BYTECODE" << std::endl;
		return RET;
	}
	return bytecode[current_offset];
}

Opcode Disassembler::eat()
{
	if(current_offset >= bytecode.size())
	{
		std::cout << "READ PAST END OF BYTECODE" << std::endl;
		return RET;
	}
	last_opcode = bytecode[current_offset++];
	return last_opcode;
}

Opcode Disassembler::eat_add(Instruction& instr)
{
	Opcode op = eat();
	instr.bytes += " " + tohex(op);
	instr.mnemonic += " " + tohex(op);
	return op;
}