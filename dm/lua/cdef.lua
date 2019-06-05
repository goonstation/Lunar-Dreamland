local ffi = require("ffi")
ffi.cdef [[
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

typedef struct Type {
	unsigned int path;
	unsigned int parentTypeIdx;
	unsigned int last_typepath_part;
} Type;

]]

ffi.metatype(
	"Value",
	{
		__eq = function(a, b)
			if (ffi.istype("Value", b)) then
				return a.type == b.type and a.value == b.value
			elseif (type(b) == "table" and getmetatable(b) == datumM) then
				return a == b.handle
			end
			return false
		end
	}
)
