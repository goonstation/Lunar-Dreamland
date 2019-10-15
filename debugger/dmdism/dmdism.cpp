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

ProcArrayEntry* proc_array;
ExecutionContext** current_context_pointer;
GetStringTableIndexPtr getStringRaw;
GetStringTableIndex getStringIndex;
ProcSetupEntry* setup_entries;
std::unordered_map<int*, ProcInfo> bytecode_to_proc_lol;


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
	int* bytecode = proc.get_bytecode();
	std::cout << proc.get_bytecode_length() << std::endl;
	for (int i = 0; i < proc.get_bytecode_length(); i++) {
		std::cout << bytecode[i] << std::endl;
		a.push_back(bytecode[i]);
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

bool invalidChar(char c)
{
	return !(c >= 0 && c < 128);
}

std::string strip(std::string str)
{
	str.erase(remove_if(str.begin(), str.end(), invalidChar), str.end());
	return str;
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
		dong["Mnemonic"] = strip(i.opcode().tostring());
		dong["Comment"] = strip(i.comment());
		disassembly.push_back(dong);
	}
	send_message("disassembly", disassembly);
}

void set_breakpoint(std::string procName, int offset, bool persistent = false)
{
	ProcInfo proc = proc_information.at(procName);
	Breakpoint bp;
	bp.offset = offset;
	bp.replaced_opcode = proc.get_bytecode()[offset];
	bp.persistent = persistent;
	proc.get_bytecode()[offset] = DBG_BREAK;
	breakpoints[procName].push_back(bp);
	std::cout << "Breakpoint set in " << procName << " at offset " << offset << std::endl;
}

HANDLE resume_handles[2];

int get_next_instruction_offset(ProcInfo proc, int current_offset)
{
	if(proc.get_bytecode()[current_offset] == JMP || proc.get_bytecode()[current_offset] == JMP2)
	{
		return proc.get_bytecode()[current_offset + 1];
	}
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
	send_message("local variables", read_values(ctx->local_variables, bytecode_to_proc_lol[ctx->bytecode].get_varcount(), "LOCAL"));
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
	std::cout << bytecode << std::endl;
	//std::cout << bytecode << " " << offset << std::endl;
	ProcInfo proc = bytecode_to_proc_lol.at(bytecode);
	std::cout << "Proc name: " << proc.name << std::endl;
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
		proc.get_bytecode()[bp->offset] = bp->replaced_opcode;
		int next_offset = get_next_instruction_offset(proc, bp->offset);
		bp->offset = next_offset;
		bp->replaced_opcode = proc.get_bytecode()[next_offset];
		proc.get_bytecode()[next_offset] = DBG_BREAK;
		std::cout << "Set up next breakpoint!" << std::endl;
		std::cout << next_offset << std::endl;
		break;
	}
	case WAIT_OBJECT_0 + 1:
		std::cout << "Resume!" << std::endl;
		proc.get_bytecode()[bp->offset] = bp->replaced_opcode;
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

std::string read_line(HANDLE hPipe)
{
	std::string message = "";
	DWORD dwRead;
	char shitty_read;
	std::cout << "Waiting to read" << std::endl;
	while (true) {
		if (ReadFile(hPipe, &shitty_read, 1, &dwRead, NULL) == FALSE)
		{
			std::cout << "Pipe closed" << std::endl;
			return "";
		}
		//std::cout << shitty_read << std::endl;
		if (shitty_read == '\n') {
			break;
		}
		message += shitty_read;
	}
	return message;
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
		std::string message = read_line(hPipeRead);
		if(message.empty())
		{
			std::cout << "Empty message received, closing" << std::endl;
			break;
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

struct InlinedProc
{
	ProcInfo proc;
	int return_to;
	int num_args;
};

std::vector<int>* peephole_optimize(std::vector<int>* bytecode)
{
	int offset = 0;
	std::vector<int>* copy = new std::vector<int>();
	copy->reserve(bytecode->size());
	bool changes_made;
	do {
		changes_made = false;
		offset = 0;
		while (offset < bytecode->size())
		{
			if (bytecode->at(offset) == SETVAR && bytecode->at(offset + 1) == LOCAL &&
				bytecode->at(offset + 3) == GETVAR && bytecode->at(offset + 4) == LOCAL &&
				bytecode->at(offset + 2) == bytecode->at(offset + 5))
			{
				offset += 5;
				changes_made = true;
			}
			else
			{
				copy->push_back(bytecode->at(offset));
			}
			offset++;
		}
		if(changes_made)
		{
			bytecode = copy;
			copy = new std::vector<int>;
		}
	} while (changes_made);
	if(copy->empty())
	{
		delete copy;
		return bytecode;
	}
	delete bytecode;
	return copy;
}

int count_locals(std::vector<int>* bytecode)
{
	int offset = 0;
	int max_local = 0;
	while (offset < bytecode->size())
	{
		if (bytecode->at(offset) == SETVAR && bytecode->at(offset + 1) == LOCAL)
		{
			max_local = max(bytecode->at(offset + 2), max_local);
		}
		offset++;
	}
	return max_local;
}

void inlinize(std::string procname)
{
	ProcInfo recipient = proc_information[procname];
	//std::cout << "Processing: " << recipient.name << std::endl;
	ProcInfo donor;

	std::vector<int>* new_bytecode = new std::vector<int>;
	short r_offset = 0;

	short recipient_len = recipient.get_bytecode_length();
	int* recipient_bytecode = recipient.get_bytecode();
	std::vector<int> call_offsets;
	std::vector<InlinedProc> inlined_procs;
	while (r_offset < recipient_len) {
		if (recipient_bytecode[r_offset] == CALLGLOB && recipient_bytecode[r_offset+1] < 8) {
			new_bytecode->push_back(JMP2);
			new_bytecode->push_back(0);
			call_offsets.push_back(new_bytecode->size()-1);
			new_bytecode->push_back(0x1337);
			InlinedProc ip;
			r_offset++;
			ip.num_args = recipient_bytecode[r_offset++];
			ip.proc = procs.at(recipient_bytecode[r_offset++]);
			ip.return_to = r_offset;
			inlined_procs.push_back(ip);
		}
		else if ((recipient_bytecode[r_offset] == CALLNR  || recipient_bytecode[r_offset] == CALL) && recipient_bytecode[r_offset + 1] == SUBVAR && recipient_bytecode[r_offset + 2] == SRC && recipient_bytecode[r_offset + 3] == 0xFFDD || (recipient_bytecode[r_offset] == CALLNR && recipient_bytecode[r_offset + 1] == SUBVAR && recipient_bytecode[r_offset + 2] == SRC && recipient_bytecode[r_offset + 3] == 0xFFDE))
		{
			new_bytecode->push_back(JMP2);
			new_bytecode->push_back(0);
			call_offsets.push_back(new_bytecode->size() - 1);
			new_bytecode->push_back(0x1337);
			new_bytecode->push_back(0x1337);
			new_bytecode->push_back(0x1337);
			new_bytecode->push_back(0x1337);
			r_offset += 4;
			InlinedProc ip;
			std::string cprocname = byond_tostring(recipient_bytecode[r_offset++]);
			std::replace(cprocname.begin(), cprocname.end(), ' ', '_');
			std::string head = procname.substr(0, procname.rfind("/"));
			head = head.substr(0, head.rfind("/"));
			if(proc_information.find(head+"/proc/"+cprocname) != proc_information.end())
			{
				cprocname = head + "/proc/" + cprocname;
			}else if (proc_information.find(head + "/verb/" + cprocname) != proc_information.end())
			{
				cprocname = head + "/verb/" + cprocname;
			}
			ip.proc = proc_information.at(cprocname);
			ip.num_args = recipient_bytecode[r_offset++];
			ip.return_to = r_offset;
			inlined_procs.push_back(ip);
		}
		else {
			new_bytecode->push_back(recipient_bytecode[r_offset]);
			r_offset += 1;
		}
	}

	if(inlined_procs.empty())
	{
		//std::cout << "No procs inlined, leaving" << std::endl;
		return;
	}
	std::cout << std::endl << "Processing: " << recipient.name << std::endl;
	std::reverse(call_offsets.begin(), call_offsets.end());
	short d_offset;
	short var_offset = recipient.get_varcount();
	for (InlinedProc& ip : inlined_procs) {
		donor = ip.proc;
		std::cout << "Inlining: " << donor.name << std::endl;
		d_offset = 4;
		(*new_bytecode)[call_offsets.back()] = new_bytecode->size();
		call_offsets.pop_back();
		short var_args_base = var_offset;
		short var_locals_base = var_offset + ip.num_args;
		for(; var_offset < var_locals_base; var_offset++)
		{
			new_bytecode->push_back(SETVAR);
			new_bytecode->push_back(LOCAL);
			new_bytecode->push_back(var_locals_base-var_offset-1);
		}
		while (d_offset < donor.get_bytecode_length() - 1) {
			if (donor.get_bytecode()[d_offset] == ARG) {
				new_bytecode->push_back(LOCAL);
				d_offset++;
				new_bytecode->push_back(var_args_base + donor.get_bytecode()[d_offset]);
				d_offset++;
			}
			else if (donor.get_bytecode()[d_offset] == GETVAR && donor.get_bytecode()[d_offset+1] == LOCAL)
			{
				new_bytecode->push_back(donor.get_bytecode()[d_offset++]);
				new_bytecode->push_back(donor.get_bytecode()[d_offset++]);
				new_bytecode->push_back(var_locals_base + donor.get_bytecode()[d_offset++]);
			}
			else if (donor.get_bytecode()[d_offset] == RET) {
				new_bytecode->push_back(JMP2);
				new_bytecode->push_back(ip.return_to);
				d_offset++;
			}
			else {
				new_bytecode->push_back(donor.get_bytecode()[d_offset]);
				d_offset++;
			}
		}
		new_bytecode->push_back(JMP2);
		new_bytecode->push_back(ip.return_to);
		new_bytecode->push_back(END);
	}
	//new_bytecode = peephole_optimize(new_bytecode);
	//int locals_needed = count_locals(new_bytecode);
	int locals_needed = var_offset;
	//std::cout << locals_needed << std::endl;
	bool found = false;
	for(ProcInfo& pi: procs)
	{
		if(setup_entries[proc_array[pi.id].local_var_count_idx].local_var_count >= locals_needed)
		{
			recipient.varcount_idx = pi.varcount_idx;
			proc_array[recipient.id].local_var_count_idx = pi.varcount_idx;
			found = true;
			break;
		}
	}
	if(!found)
	{
		std::cout << "COULD NOT FIND MATCHING VARCOUNT FOR INLINING" << std::endl;
		return;
	}
	//std::cout << recipient.varcount_idx << std::endl;
	//std::cout << recipient.get_varcount() << std::endl;
	recipient.set_bytecode(new_bytecode);
}

struct CompileResult
{
	std::string path;
	std::vector<int> bytecode;
	unsigned int local_count;
	std::vector<std::pair<std::string, int>> strings;
	std::vector<std::pair<std::string, int>> src_procs;
	std::vector<std::pair<std::string, int>> global_procs;
};

void run_patcher()
{
	HANDLE hPatchPipe = CreateNamedPipe("\\\\.\\pipe\\DMDBGPatch",
		PIPE_ACCESS_DUPLEX,
		PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
		1,
		1024 * 16,
		1024 * 16,
		NMPWAIT_USE_DEFAULT_WAIT,
		NULL);

	while(true)
	{
		ConnectNamedPipe(hPatchPipe, NULL);
		std::string message = read_line(hPatchPipe);
		if(message.empty())
		{
			continue;
		}
		//std::cout << message << std::endl;
		nlohmann::json msg = nlohmann::json::parse(message);
		CompileResult res{
			msg["path"],
			msg["bytecode"],
			msg["local_count"],
			msg["strings"],
			msg["src_procs"],
			msg["global_procs"]
		};
		std::cout << "Received patch for " << res.path << std::endl;
		std::cout << msg["bytecode"] << std::endl;
		std::vector<int>* new_bytecode = new std::vector<int>(res.bytecode.begin(), res.bytecode.end());
		for(auto str: res.strings)
		{
			std::replace(str.first.begin(), str.first.end(), 0x05, 0xFF);
			(*new_bytecode)[str.second] = intern_string(str.first);
		}
		for (auto proc : res.global_procs)
		{
			(*new_bytecode)[proc.second] = proc_information.at("/proc/" + proc.first).id;
		}
		ProcInfo proc = proc_information.at(res.path);
		proc.set_bytecode(new_bytecode);
		//proc.set_varcount(res.local_count);
		proc_array[proc.id].local_var_count_idx = proc_information.at("/proc/twelve_locals").varcount_idx;
		std::cout << proc.get_bytecode_length() << std::endl;
		DisconnectNamedPipe(hPatchPipe);
	}
}

void inline_all()
{
	for(ProcInfo& p: procs)
	{
		if(p.name.back() == ')')
		{
			continue;
		}
		if(p.name.find("/area/") == std::string::npos &&
			p.name.find("/turf/") == std::string::npos &&
			p.name.find("/obj/") == std::string::npos &&
			p.name.find("/mob/") == std::string::npos &&
			p.name.find("/client/") == std::string::npos)
		{
			continue;
		}
		inlinize(p.name);
	}
	std::cout << "That's all folks!" << std::endl;
}

extern "C" __declspec(dllexport) void pass_shit(const char** proc_names, int* proc_ids, int* varcounts, int* bytecode_lens, int** bytecodes, ProcSetupEntry** lsetup_entries, int number_of_procs, ExecutionContext** execContext, GetStringTableIndexPtr strgetter, GetStringTableIndex strindexer, unsigned short* varcount_indices, unsigned short* bytecode_indices, ProcArrayEntry* pproc_array)
{
	setup_entries = *lsetup_entries;
	for(int i=0;i<number_of_procs;i++)
	{
		ProcInfo pi;
		pi.name = proc_names[i];
		pi.id = proc_ids[i];
		pi.local_var_count = varcounts[i];
		pi.bytecode_length = bytecode_lens[i];
		//pi.bytecode = bytecodes[i];
		//pi.setup_entry = lsetup_entries[i];
		//std::cout << varcount_indices[i] << std::endl;
		pi.varcount_idx = varcount_indices[i];
		pi.bytecode_idx = bytecode_indices[i];
		bytecode_to_proc_lol[pi.get_bytecode()] = pi;
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
	getStringIndex = strindexer;
	proc_array = pproc_array;

	std::cout << std::hex << intern_string("test arguments p") << std::endl;

	std::cout << &setup_entries[proc_information.at("/client/verb/test_patching").bytecode_idx] << std::endl;

	std::thread(run_debugger).detach();
	std::thread(run_patcher).detach();
	//std::thread(inline_all).detach();
}
