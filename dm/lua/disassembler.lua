local M = {}

local xvar_magic_numbers = {
	[0xFFCE] = "SRC",
	[0xFFD0] = "DOT",
	[0xFFDA] = "LOCAL",
	[0xFFDB] = "GLOBAL",
	[0xFFDC] = "DATUM",
	[0xFFE5] = "WORLD",
	[0xFFE6] = "NULL"
}

local mnemonics = {
	[0x00] = "RETD", --return dot variable
	[0x01] = "NEW", --create new datum
	[0x03] = "OUTPUT", --output to something (<<)
	[0x0D] = "TEST", --test if top of stack is true and set test flag
	[0x0E] = "LNEG", --logical negation
	[0x11] = "JMPF", --jump if test flag is false
	[0x12] = "RET", --return value
	[0x1A] = "NLIST", --create new list
	[0x30] = "CALL", --call proc by id
	[0x33] = "GETVAR", --get variable by id and push
	[0x34] = "SETVAR", --pop and set variable by id
	[0x37] = "TEQ", --test equal
	[0x38] = "TNE", --test not equal
	[0x39] = "TL", --test lower
	[0x3A] = "TG", --test greater
	[0x3B] = "TLE", --test lower or equal
	[0x3C] = "TGE", --test greater or equal
	[0x3E] = "ADD", --add two values
	[0x3F] = "SUB", --subtract two values
	[0x50] = "PUSHI", --push integer
	[0x51] = "DECREF", --decrement value refcount
	[0x60] = "PUSHVAL", --push value
	[0x84] = "DBG PROCNAME", --set context proc name field (debug mode only)
	[0x85] = "DBG LINENO", --set context line number (debug mode only)
	[0x1337] = "DBG BREAK" --invoke breakpoint handler (dreamland only)
}

local mnemonic_meta = {}
function mnemonic_meta.__index(self, key)
	return rawget(self, key) or "???"
end

mnemonics = setmetatable(mnemonics, mnemonic_meta)

local arg_counts = {
	[0x01] = 1,
	[0x11] = 1,
	[0x1A] = 1,
	[0x30] = 3,
	[0x50] = 1,
	[0x84] = 1,
	[0x85] = 1
}

function disassemble_set_get(bytecode, offset)
	local gettype = xvar_magic_numbers[bytecode[offset + 1]]
	local arg_prettyprint
	if gettype == "LOCAL" then
		arg_len = 2
		arg_prettyprint = {bytecode[offset + 2]}
	end
	return gettype, arg_len, arg_prettyprint
end

local variable_argcount_disassemblers = {
	[0x33] = disassemble_set_get,
	[0x34] = disassemble_set_get
}

function M.test_disassemble()
	local bytecode = {0x50, 0x01, 0x34, 0xFFDA, 0x00, 0x00}
	M.disassemble(bytecode)
end

function M.disassemble(bytecode, bytecode_len)
	local bytecode_len = bytecode_len or #bytecode
	local current_offset = 0
	while current_offset < bytecode_len do
		local current_opcode = bytecode[current_offset]
		local mnemonic = mnemonics[current_opcode]
		local arg_count

		local vararg_dis = variable_argcount_disassemblers[current_opcode]
		if vararg_dis then
			mnemonic_mod, arg_count, pretty_args = vararg_dis(bytecode, current_offset)
			local out = {mnemonic, mnemonic_mod, table.concat(pretty_args, " ")}
			print(table.concat(out, " "))
			current_offset = current_offset + arg_count
		else
			arg_count = arg_counts[current_opcode] or 0
			local pretty_args = {}
			for i = 1, arg_count do
				table.insert(pretty_args, bytecode[current_offset + i])
			end
			local out = {mnemonic, table.concat(pretty_args, " ")}
			print(table.concat(out, " "))
			current_offset = current_offset + arg_count
		end
		current_offset = current_offset + 1
	end
end

return M
