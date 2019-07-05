local ffi = require "ffi"
local disasm = require "disassembler"
local consts = require "defines"
local t2t = require "type2type"
local M = {}

ffi.cdef [[
	typedef struct CompiledCode {
		unsigned int local_var_count;
		const char** strings;
		unsigned int strings_len;
		unsigned int* bytecode;
		unsigned int bytecode_len;
	} CompiledCode;

	CompiledCode compile(const char* code);
]]

print("\n")

local compiler = ffi.load("dmcompiler2")

function M.link(bytecode, bytecode_len, strings)
	for i = 0, bytecode_len do
		if bytecode[i] == 0xBABE0001 then
			bytecode[i] = consts.String
			bytecode[i + 1] = t2t.toValue(ffi.string(strings[bytecode[i + 1]]), true).value
		end
	end
end

function M.compile(code)
	local compiled = compiler.compile(code)
	local strings = ffi.new("const char*[?]", compiled.strings_len, compiled.strings[0])
	M.link(compiled.bytecode, compiled.bytecode_len, strings)
	return compiled.bytecode
end

return M
