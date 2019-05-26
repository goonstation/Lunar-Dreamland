local ffi = require('ffi')
ffi.cdef[[
typedef struct String
{
	char* stringData;
	int unk1;
	int unk2;
	unsigned int refcount;
} String;

typedef struct Value {
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
} Value;

typedef struct IDArrayEntry {
	short size;
	int unknown;
	int refcountMaybe;
} IDArrayEntry;

typedef struct ProcArrayEntry {
	int procPath;//all these are string table IDs
	int procName;
	int procDesc;
	int procCategory;
	int procFlags;
	int bytecode;//idarray index
	char unknown[12];
} ProcArrayEntry;

typedef struct List {
	Value* elements;
	int unk1;
	int unk2;
	int length;
	int refcount;
	int unk3;
	int unk4;
	int unk5;
} List;

typedef Value(*CallGlobalProc)(char unk1, int unk2, int proc_type, unsigned int proc_id, int const_0, char unk3, int unk4, Value* argList, unsigned int argListLen, int const_0_2, int const_0_3);
typedef Value(*Text2PathPtr)(unsigned int text);
typedef unsigned int(*GetStringTableIndex)(const char* string, int handleEscapes, int duplicateString);
typedef void(*SetVariablePtr)(unsigned char type, unsigned int datumId, unsigned int varNameId, unsigned char varType, int newValue);
typedef Value(*ReadVariablePtr)(unsigned char type, unsigned int datumId, unsigned int varNameId);
typedef Value(*CallProcPtr)(int unk1, int unk2, unsigned int proc_type, unsigned int proc_name, unsigned char datumType, unsigned int datumId, Value* argList, unsigned int argListLen, int unk4, int unk5);
typedef IDArrayEntry*(*GetIDArrayEntryPtr)(unsigned int index);
typedef int(*ThrowDMErrorPtr)(const char* msg);
typedef ProcArrayEntry*(*GetProcArrayEntryPtr)(unsigned int index);
typedef List*(*GetListArrayEntryPtr)(unsigned int index);
typedef void(*AppendToContainerPtr)(unsigned char containerType, int containerValue, unsigned char valueType, int newValue);
typedef void(*RemoveFromContainerPtr)(unsigned char containerType, int containerValue, unsigned char valueType, int newValue);
]]

return ffi