local ffi = require "ffi"
local disasm = require "disassembler"
local consts = require "defines"
local t2t = require "type2type"
local proc = require "proc"
local M = {}

ffi.cdef [[
	typedef struct CompiledCode {
		unsigned int local_var_count;
		const char** strings;
		unsigned int* string_positions;
		unsigned int strings_len;
		unsigned int* call_positions;
		const char** function_names;
		unsigned int function_names_len;
		unsigned int* bytecode;
		unsigned int bytecode_len;
	} CompiledCode;

	CompiledCode* compile(const char* code);
]]

print("\n")

local compiler = ffi.load("compiler4")

function M.link(compiled)
	print("Linking...")
	for i = 0, compiled.strings_len - 1 do
		compiled.bytecode[compiled.string_positions[i]] = t2t.str2index(ffi.string(compiled.strings[i]))
	end
	for i = 0, compiled.function_names_len - 1 do
		compiled.bytecode[compiled.call_positions[i]] = proc.getProc("/proc/" .. ffi.string(compiled.function_names[i])).id
	end
	print("Linked successfully!")
end

function M.compile(code)
	local compiled = compiler.compile(code)
	M.link(compiled)
	print("")
	print("Generated " .. tostring(compiled.bytecode_len) .. " bytes.")
	print(
		tostring(compiled.local_var_count) ..
			" local variables, " ..
				tostring(compiled.strings_len) .. " strings, " .. tostring(compiled.function_names_len) .. " procs to link."
	)
	print("")
	disasm.disassemble(compiled.bytecode, compiled.bytecode_len)
	return compiled.bytecode
end

return M
