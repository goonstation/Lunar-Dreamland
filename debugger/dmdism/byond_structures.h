#pragma once

#include <vector>
#include <optional>
#include <iostream>
#include <map>
#include <unordered_map>

struct String
{
	char* stringData;
	int unk1;
	int unk2;
	unsigned int refcount;
};

struct Value {
	union {
		struct {
			char type;
			union {
				int value;
				float valuef;
			};
		};
		long long longlongman;
	};
};

typedef struct ProcArrayEntry {
	int procPath;
	int procName;
	int procDesc;
	int procCategory;
	int procFlags;
	int unknown1;
	int bytecode_idx; // ProcSetupEntry index
	int local_var_count_idx; // ProcSetupEntry index 
	int unknown2;
} ProcArrayEntry;

struct ExecutionContext;

struct ProcConstants {
	int proc_id;
	int unknown2;
	Value src;
	Value usr;
	ExecutionContext* context;
	int unknown3;
	int unknown4;
	int unknown5;
	int arg_count;
	Value* args;
};

struct AnotherProcState {
	char unknown[0x88];
	int time_to_resume;
};

struct ExecutionContext {
	ProcConstants* constants;
	ExecutionContext* parent_context;
	int dbg_proc_file;
	int dbg_current_line;
	int* bytecode;
	unsigned short current_opcode;
	Value cached_datum;
	char unknown2[8];
	int test_flag;
	char unknown3[12];
	Value* local_variables;
	Value* stack;
	short local_var_count;
	short stack_size;
	int unknown;
	Value* current_iterator;
	int iterator_allocated;
	int iterator_length;
	int iterator_index;
	char unknown4[7];
	char iterator_filtered_type;
	char unknown5;
	char iterator_unknown;
	char unknown6;
	int infinite_loop_count;
	char unknown7[2];
	bool paused;
	char unknown8[51];
};

struct ProcSetupEntry {
	union {
		short local_var_count;
		short bytecode_length;
	};
	int* bytecode;
	int unknown;
};

extern ProcArrayEntry* proc_array;
extern ExecutionContext** current_context_pointer;

typedef unsigned int(*GetStringTableIndex)(const char* string, int handleEscapes, int duplicateString);
typedef String*(*GetStringTableIndexPtr)(int stringId);

extern GetStringTableIndexPtr getStringRaw;
extern GetStringTableIndex getStringIndex;

struct ProcInfo;
extern ProcSetupEntry* setup_entries;
extern std::unordered_map<int*, ProcInfo> bytecode_to_proc_lol;

struct ProcInfo
{
	std::string name;
	unsigned int id;
	unsigned short local_var_count;
	unsigned short bytecode_length;
private:
	int* bytecode;
public:
	unsigned int varcount_idx;
	unsigned int bytecode_idx;
	bool operator< (const ProcInfo &other) const {
		return id < other.id;
	}

	unsigned short get_varcount() const
	{
		return setup_entries[varcount_idx].local_var_count;
	}

	void set_varcount(short new_varcount) const
	{
		setup_entries[varcount_idx].local_var_count = 12;
	}

	unsigned short get_bytecode_length() const
	{
		return setup_entries[bytecode_idx].bytecode_length;
	}

	int* get_bytecode() const
	{
		std::cout << bytecode_idx << std::endl;
		return setup_entries[bytecode_idx].bytecode;
	}

	void set_bytecode(std::vector<int>* new_bytecode)
	{
		setup_entries[bytecode_idx].bytecode = new_bytecode->data();
		setup_entries[bytecode_idx].bytecode_length = (short)new_bytecode->size();
		bytecode_to_proc_lol[setup_entries[bytecode_idx].bytecode] = *this;
	}
};