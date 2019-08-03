#pragma once
#include "stdafx.h"
#include <string>
#include <vector>
#include "opcodes.h"
#include "byond_structures.h"
#include <map>
#include <unordered_map>

struct Instruction
{
	int offset;
	std::string bytes;
	std::string mnemonic;
	std::string comment;
};

class Disassembler
{

	std::vector<Opcode> bytecode;
	std::vector<ProcInfo>& procs;
	unsigned int current_offset = 0;
	std::vector<Instruction> instructions;
	Opcode last_opcode;

	Instruction prepare_instruction();
	void add_var_disassembly(Instruction& instr);
	void add_call_args(Instruction& instr, int count);

	Instruction disassemble_next();
	Instruction disassemble_simple();
	Instruction disassemble_unknown();
	Instruction disassemble_zeroarg();
	Instruction disassemble_var();
	Instruction disassemble_variable_access();
	Instruction disassemble_pushval();
	Instruction disassemble_call();
	Instruction disassemble_global_call();
	Instruction disassemble_debug_file();
	Instruction disassemble_debug_line();

	Opcode peek();
	Opcode eat();
	Opcode eat_add(Instruction& instr);

public:
	Disassembler(std::vector<int> bc, std::vector<ProcInfo>& ps);
	std::vector<Instruction> disassemble();
};

const std::vector<Opcode> zero_argument_opcodes = {
	RET, RETN, TEST, TEQ, TNE, TL, TG, TLE, TGE, ANEG, NOT, ADD, SUB, MUL, DIV, MOD, ROUND, POP, ITERNEXT, LISTGET, PROMPTCHECK, CHECKNUM, MD5, OUTPUT, CALLPARENT, SLEEP, ISTYPE
};

const std::unordered_map<Opcode, int> simple_argument_counts = {
	{NEW, 1},
	{JMP, 1},
	{JZ, 1},
	{NLIST, 1},
	{SPAWN, 1},
	{CALLPATH, 1},
	{PUSHI, 1},
	{LOCATE, 1},
	{CALLNAME, 1},
	{INPUT_, 3},
	{JMP2, 1},
	{JNZ, 1},
	{POPN, 1},
	{CALL_LIB, 1}
};

const std::vector<Opcode> variable_accessors = {
	SETVAR, GETVAR, AUGADD, AUGSUB
};

std::string tohex(int numero);