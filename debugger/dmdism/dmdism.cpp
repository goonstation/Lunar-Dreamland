// dmdism.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"

#include <iostream>
#include <thread>
#include <string>
#include <vector>
#include <unordered_map>
#include <iomanip>
#include <sstream>
#include <algorithm>

#include "byond_structures.h"
#include "json.hpp"
#include "disassembler.h"
#include "helpers.h"

std::vector<ProcArrayEntry> proc_array;
ExecutionContext** current_context_pointer;
GetStringTableIndexPtr getStringRaw;

std::vector<std::string> split(const std::string &s, char delim) {
	std::vector<std::string> elems;
	std::stringstream ss(s);
	std::string part;
	while (std::getline(ss, part, delim)) {
		elems.push_back(part);
	}
	return elems;
}

struct Breakpoint
{
	ProcInfo proc;
	int offset;
	int replaced_opcode;
	bool persistent;
};

std::unordered_map<std::string, ProcInfo> proc_information;
std::unordered_map<std::string, std::vector<Instruction>> disassemblies;
std::unordered_map<std::string, std::vector<Breakpoint>> breakpoints;
std::unordered_map<int*, ProcInfo> bytecode_to_proc_lol;
std::vector<ProcInfo> procs;

HANDLE hPipeRead;
HANDLE hPipeWrite;

inline ExecutionContext* get_context()
{
	return *current_context_pointer;
}

std::vector<Instruction> disassemble(std::string name)
{
	if(disassemblies.find(name) != disassemblies.end())
	{
		return disassemblies.at(name);
	}
	ProcInfo proc = proc_information[name];
	std::vector<uint32_t> a;
	for (int i = 0; i < proc.bytecode_length; i++) {
		a.push_back(proc.bytecode[i]);
	}
	auto instructions = Disassembler(a, procs).disassemble();
	disassemblies[name] = instructions;
	return instructions;
}

std::string totypename(int typeno)
{
	if(datatype_names.find((DataType)typeno) != datatype_names.end())
	{
		return datatype_names.at((DataType)typeno);
	}
	return "??? (" + tohex(typeno) + ")";
}

void send_message(std::string type, nlohmann::json content)
{
	//std::cout << "Sending " << content << std::endl;
	nlohmann::json message;
	message["type"] = type;
	message["content"] = content.dump();
	std::string s = message.dump();
	s += "\n";
	DWORD numWritten;
	WriteFile(hPipeWrite, s.c_str(), s.length(), &numWritten, NULL);
	FlushFileBuffers(hPipeWrite);
	std::cout << numWritten << "/" << s.size() << std::endl;
}

void send_proc_list()
{
	nlohmann::json list;
	for (auto const& x : proc_information)
	{
		list.push_back(x.first);
	}
	send_message("proc list", list);
}

void send_disassembly(std::string procName)
{
	std::vector<Instruction> instructions = disassemble(procName);
	nlohmann::json disassembly;
	for(Instruction& i : instructions)
	{
		nlohmann::json dong;
		dong["BP"] = "";
		dong["isCurrent"] = "";
		dong["Offset"] = i.offset();
		dong["Bytes"] = i.bytes_str();
		dong["Mnemonic"] = i.opcode().tostring();
		dong["Comment"] = i.comment();
		disassembly.push_back(dong);
	}
	send_message("disassembly", disassembly);
}

void set_breakpoint(std::string procName, int offset, bool persistent = false)
{
	ProcInfo proc = proc_information.at(procName);
	Breakpoint bp;
	bp.offset = offset;
	bp.replaced_opcode = proc.bytecode[offset];
	bp.persistent = persistent;
	proc.bytecode[offset] = DBG_BREAK;
	breakpoints[procName].push_back(bp);
	std::cout << "Breakpoint set in " << procName << " at offset " << offset << std::endl;
}

HANDLE resume_handles[2];

int get_next_instruction_offset(ProcInfo proc, int current_offset)
{
	std::vector<Instruction> disassembly = disassemble(proc.name);
	for(unsigned int i = 0; i < disassembly.size(); i++)
	{
		if(disassembly[i].offset() == current_offset)
		{
			return disassembly[i + 1].offset();
		}
	}

	return -1;
}

std::string wtfstring;

void debugger_set_current(std::string name, int offset)
{
	nlohmann::json current;
	current["procname"] = name;
	current["offset"] = offset;
	send_message("debugger current", current);
}

nlohmann::json read_values(Value* source, int count, std::string name)
{
	nlohmann::json values;
	for (int i = 0; i<count; i++)
	{
		Value val = source[i];
		nlohmann::json v;
		v["ID"] = name + std::to_string(i);
		v["Type"] = totypename(val.type);
		if (val.type == NUMBER)
		{
			v["Value"] = val.valuef;
		}
		else if (val.type == STRING)
		{
			v["Value"] = byond_tostring(val.value);
		}
		else
		{
			v["Value"] = val.value;
		}
		values.push_back(v);
	}
	return values;
}

void update_locals()
{
	ExecutionContext* ctx = get_context();
	send_message("local variables", read_values(ctx->local_variables, bytecode_to_proc_lol[ctx->bytecode].local_var_count, "LOCAL"));
}

void update_arguments()
{
	ExecutionContext* ctx = get_context();
	send_message("arguments", read_values(ctx->constants->args, ctx->constants->arg_count, "ARG"));
}

void update_stack()
{
	ExecutionContext* ctx = get_context();
	send_message("stack", read_values(ctx->stack, ctx->stack_size, "STACK"));
}

void update_call_stack()
{
	nlohmann::json names;
	ExecutionContext* ctx = get_context();
	while (ctx)
	{
		names.push_back(bytecode_to_proc_lol[ctx->bytecode].name);
		ctx = ctx->parent_context;
	}
	send_message("callstack", names);
}

void erase_readouts()
{
	send_message("local variables", {});
	send_message("arguments", {});
	send_message("stack", {});
	send_message("callstack", {});
}

extern "C" __declspec(dllexport) void breakpoint_hit(int* bytecode, int offset)
{
	std::cout << "Searching for breakpoint at offset " << offset << std::endl;
	//std::cout << bytecode << " " << offset << std::endl;
	ProcInfo proc = bytecode_to_proc_lol.at(bytecode);
	Breakpoint* bp = nullptr;
	ExecutionContext* ctx = get_context();
	for(Breakpoint& b : breakpoints[proc.name])
	{
		if(b.offset == offset)
		{
			bp = &b;
			break;
		}
	}
	std::cout << "found" << std::endl;
	std::cout << ctx->current_opcode << std::endl;
	ctx->current_opcode--;
	std::cout << "writing" << std::endl;
	//FlushFileBuffers(ghPipe);

	std::cout << "BREAKPOINT HIT!" << std::endl;
	std::cout << proc.name << std::endl;
	std::cout << "At offset: " << bp->offset << std::endl;
	std::cout << ", replacing opcode: " << bp->replaced_opcode << " " << std::endl;
	std::cout << "Waiting for user action..." << std::endl;
	debugger_set_current(proc.name, bp->offset);
	update_locals();
	update_arguments();
	update_stack();
	update_call_stack();
	switch(WaitForMultipleObjects(2, resume_handles, FALSE, INFINITE))
	{
	case WAIT_OBJECT_0: {
		std::cout << "Single step!" << std::endl;
		proc.bytecode[bp->offset] = bp->replaced_opcode;
		int next_offset = get_next_instruction_offset(proc, bp->offset);
		bp->offset = next_offset;
		bp->replaced_opcode = proc.bytecode[next_offset];
		proc.bytecode[next_offset] = DBG_BREAK;
		std::cout << "Set up next breakpoint!" << std::endl;
		std::cout << next_offset << std::endl;
		break;
	}
	case WAIT_OBJECT_0 + 1:
		std::cout << "Resume!" << std::endl;
		proc.bytecode[bp->offset] = bp->replaced_opcode;
		erase_readouts();
		break;
	}

}

void step()
{
	SetEvent(resume_handles[0]);
}

void resume()
{
	SetEvent(resume_handles[1]);
}

void run_debugger()
{
	resume_handles[0] = CreateEvent(
		NULL,               // default security attributes
		FALSE,               // manual-reset event
		FALSE,              // initial state is nonsignaled
		TEXT("DebugStep")  // object name
	);
	resume_handles[1] = CreateEvent(
		NULL,               // default security attributes
		FALSE,               // manual-reset event
		FALSE,              // initial state is nonsignaled
		TEXT("DebugResume")  // object name
	);
	std::cout << "making pipe" << std::endl;
	hPipeRead = CreateNamedPipe("\\\\.\\pipe\\DMDBGRead",
		PIPE_ACCESS_DUPLEX,
		PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
		1,
		1024 * 16,
		1024 * 16,
		NMPWAIT_USE_DEFAULT_WAIT,
		NULL);
	hPipeWrite = CreateNamedPipe("\\\\.\\pipe\\DMDBGWrite",
		PIPE_ACCESS_DUPLEX,
		PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
		1,
		1024 * 16,
		1024 * 16,
		NMPWAIT_USE_DEFAULT_WAIT,
		NULL);
	std::cout << "Connecting reader..." << std::endl;
	ConnectNamedPipe(hPipeRead, NULL);
	std::cout << "Connecting writer..." << std::endl;
	ConnectNamedPipe(hPipeWrite, NULL);
	std::cout << "Connected" << std::endl;
	while(true)
	{
		std::string message = "";
		DWORD dwRead;
		char shitty_read;
		std::cout << "Waiting to read" << std::endl;
		while (true) {
			if (ReadFile(hPipeRead, &shitty_read, 1, &dwRead, NULL) == FALSE)
			{
				std::cout << "Pipe closed" << std::endl;
				return;
			}
			if (shitty_read == '\n') {
				break;
			}
			message += shitty_read;
		}
		std::cout << "Read" << std::endl;
		std::cout << message << std::endl;
		nlohmann::json msg = nlohmann::json::parse(message);
		std::string request_type = msg["type"];
		if(request_type == "disassembly")
		{
			send_disassembly(msg["content"]);
		}
		else if(request_type == "set_breakpoint")
		{
			unsigned int offset = msg["content"]["offset"];
			set_breakpoint(msg["content"]["proc_name"], offset);
		}
		else if(request_type == "step")
		{
			step();
		}
		else if (request_type == "resume")
		{
			resume();
		}
		else if(request_type == "Proc list please")
		{
			send_proc_list();
		}
	}
}

extern "C" __declspec(dllexport) void pass_shit(const char** proc_names, int* proc_ids, short* varcounts, short* bytecode_lens, int** bytecodes, int number_of_procs, ExecutionContext** execContext, GetStringTableIndexPtr strgetter)
{
	for(int i=0;i<number_of_procs;i++)
	{
		ProcInfo pi;
		pi.name = proc_names[i];
		pi.id = proc_ids[i];
		pi.local_var_count = varcounts[i];
		pi.bytecode_length = bytecode_lens[i];
		pi.bytecode = bytecodes[i];
		bytecode_to_proc_lol[pi.bytecode] = pi;
		proc_information[pi.name] = pi;
		procs.push_back(pi);
		if(i % 500 == 0)
		{
			std::cout << std::setprecision(2) << i / (float)number_of_procs * 100 << "%   \r";
		}
	}
	std::sort(procs.begin(), procs.end());
	std::cout << "Processed " << number_of_procs << " procs." << std::endl;
	current_context_pointer = execContext;
	getStringRaw = strgetter;

	std::thread(run_debugger).detach();
}
