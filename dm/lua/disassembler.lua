local consts = require "defines"
local t2t = require "type2type"
local M = {}

local xvar_magic_numbers = {
	[0xFFCD] = "USR",
	[0xFFCE] = "SRC",
	[0xFFD0] = "DOT",
	[0xFFD9] = "ARG",
	[0xFFDA] = "LOCAL",
	[0xFFDB] = "GLOBAL",
	[0xFFDC] = "DATUM",
	[0xFFDD] = "CACHE",
	[0xFFE5] = "WORLD",
	[0xFFE6] = "NULL"
}

local mnemonics = {
	[0x00] = "RETN", --return
	[0x01] = "NEW", --create new datum
	[0x03] = "OUTPUT", --output to something (<<)
	[0x0D] = "TEST", --test if top of stack is true and set test flag
	[0x0E] = "LNEG", --logical negation
	[0x11] = "JMPF", --jump if test flag is false
	[0x12] = "RET", --return value
	[0x1A] = "NLIST", --create new list
	[0x25] = "SPAWN", --pop value from stack and create "thread" after that many deciseconds, jump ahead arg1 opcodes and continue
	[0x2A] = "CALLDATUM", --decref variables?
	[0x30] = "CALLGLOB", --call proc by id
	[0x33] = "GETVAR", --get variable by id and push
	[0x34] = "SETVAR", --pop and set variable by id
	[0x37] = "TEQ", --test equal
	[0x38] = "TNE", --test not equal
	[0x39] = "TL", --test lower
	[0x3A] = "TG", --test greater
	[0x3B] = "TLE", --test lower or equal
	[0x3C] = "TGE", --test greater or equal
	[0x3D] = "ANEG",
	[0x3E] = "ADD", --add two values
	[0x3F] = "SUB", --subtract two values
	[0x45] = "ADDIP",
	[0x46] = "SUBIP",
	[0x50] = "PUSHI", --push integer
	[0x51] = "DECREF", --decrement value refcount
	[0x52] = "ITERLOAD",
	[0x53] = "ITERNEXT",
	[0x5B] = "LOCATE",
	[0x60] = "PUSHVAL", --push value
	[0x66] = "INC",
	[0x67] = "DEC",
	[0x7D] = "ISTYPE",
	[0x84] = "DBG FILE", --set context proc file field (debug mode only)
	[0x85] = "DBG LINENO", --set context line number (debug mode only)
	[0xBA] = "PROMPTCHECK",
	[0xC1] = "INPUT",
	[0xF8] = "JMP",
	[0xFA] = "JMPT",
	[0xFB] = "POP",
	[0xFC] = "CHECKNUM",
	[0x109] = "MD5",
	[0x1337] = "DBG BREAK" --invoke breakpoint handler (dreamland only)
}

local mnemonic_meta = {}
function mnemonic_meta.__index(self, key)
	return rawget(self, key) or "??? (" .. tostring(key) .. ")"
end

mnemonics = setmetatable(mnemonics, mnemonic_meta)

local arg_counts = {
	[0x01] = 1,
	[0x11] = 1,
	[0x1A] = 1,
	[0x25] = 1,
	[0x30] = 3,
	[0x50] = 1,
	[0x52] = 2,
	[0x5B] = 1,
	[0x84] = 1,
	[0x85] = 1,
	[0xC1] = 3,
	[0xF8] = 1,
	[0xFA] = 1,
	[0xFB] = 1
}

function disassemble_procfile(bytecode, offset)
	return "", 1, {bytecode[offset + 1], "(" .. t2t.idx2str(bytecode[offset + 1]) .. ")"}
end

function disassemble_var_access(bytecode, offset)
	local gettype = xvar_magic_numbers[bytecode[offset + 1]]
	local arg_len = 2
	local arg_prettyprint = {}
	if gettype == "LOCAL" then
		arg_prettyprint = {bytecode[offset + 2]}
	elseif gettype == "WORLD" or gettype == "USR" or gettype == "SRC" then
		arg_len = 1
	elseif gettype == "DATUM" then
		local datumscope = xvar_magic_numbers[bytecode[offset + 2]]
		if datumscope == "LOCAL" then
			arg_len = 4
			arg_prettyprint = {bytecode[offset + 3], bytecode[offset + 4], "(" .. t2t.idx2str(bytecode[offset + 4]) .. ")"}
		end
	elseif gettype == "NULL" then
		arg_len = 1
	end
	return gettype, arg_len, arg_prettyprint
end

function disassemble_pushval(bytecode, offset)
	local type = bytecode[offset + 1]
	local arg_len = 2
	local arg_prettyprint
	if type == consts.Number then
		arg_len = 3
	elseif type == consts.Null then
		arg_len = 2
	end
	return consts.types[type]:upper(), arg_len, {bytecode[offset + 2]}
end

function disassemble_datumcall(bytecode, offset)
	local srcsource = xvar_magic_numbers[bytecode[offset + 1]]
	if srcsource == "DATUM" then
		return "", 6, {
			xvar_magic_numbers[bytecode[offset + 2]],
			bytecode[offset + 3],
			bytecode[offset + 5],
			bytecode[offset + 6],
			"(" .. t2t.idx2str(bytecode[offset + 5]) .. ")"
		}
	elseif srcsource == "CACHE" then
		return srcsource, 3, {bytecode[offset + 2], bytecode[offset + 3], "(" .. t2t.idx2str(bytecode[offset + 2]) .. ")"}
	end
end

local variable_argcount_disassemblers = {
	[0x2A] = disassemble_datumcall,
	[0x33] = disassemble_var_access,
	[0x34] = disassemble_var_access,
	[0x60] = disassemble_pushval,
	[0x66] = disassemble_var_access,
	[0x67] = disassemble_var_access,
	[0x45] = disassemble_var_access,
	[0x46] = disassemble_var_access,
	[0x84] = disassemble_procfile
}

function M.test_disassemble()
	local bytecode = {0x50, 0x01, 0x34, 0xFFDA, 0x00, 0x00}
	M.disassemble(bytecode)
end

function M.disassemble(bytecode, bytecode_len, wanted_offset)
	local bytecode_len = bytecode_len or #bytecode
	local current_offset = 0
	--[[for i = 0, bytecode_len do
		print(string.format("%x", bytecode[i]))
	end]]
	while current_offset < bytecode_len do
		local current_opcode = bytecode[current_offset]
		local mnemonic = mnemonics[current_opcode]
		local arg_count

		local vararg_dis = variable_argcount_disassemblers[current_opcode]
		if vararg_dis then
			mnemonic_mod, arg_count, pretty_args = vararg_dis(bytecode, current_offset)
			local out
			if mnemonic_mod ~= "" then
				out = {current_offset, "|", mnemonic, mnemonic_mod, table.concat(pretty_args or {}, " ")}
			else
				out = {current_offset, "|", mnemonic, table.concat(pretty_args or {}, " ")}
			end
			if wanted_offset then
				if current_offset == wanted_offset then
					print(table.concat(out, " "))
				end
			else
				print(table.concat(out, " "))
			end
			current_offset = current_offset + arg_count
		else
			arg_count = arg_counts[current_opcode] or 0
			local pretty_args = {}
			for i = 1, arg_count do
				table.insert(pretty_args, bytecode[current_offset + i])
			end
			local out = {current_offset, "|", mnemonic, table.concat(pretty_args, " ")}
			if wanted_offset then
				if current_offset == wanted_offset then
					print(table.concat(out, " "))
				end
			else
				print(table.concat(out, " "))
			end
			current_offset = current_offset + arg_count
		end
		current_offset = current_offset + 1
	end
end

function M.get_next_instruction_offset(bytecode, offset)
	local current_opcode = bytecode[offset]
	local vararg_dis = variable_argcount_disassemblers[current_opcode]
	if vararg_dis then
		mnemonic_mod, arg_count, pretty_args = vararg_dis(bytecode, offset)
		return offset + arg_count + 1
	else
		arg_count = arg_counts[current_opcode] or 0
		return offset + arg_count + 1
	end
end

return M
