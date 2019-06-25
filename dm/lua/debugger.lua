local dis = require "disassembler"

local M = {}

M.replaced_opcode = 0xDEAD
M.bytecode_len = 0
M.replaced_offset = 0

function M.debug_hook(ctx)
	local bytecode = ctx.bytecode
	bytecode[M.replaced_offset] = M.replaced_opcode
	dis.disassemble(bytecode, M.bytecode_len, M.replaced_offset)
	M.replaced_offset = dis.get_instruction_length(bytecode, M.replaced_offset)
	print("Next instruction to replace is at offset", M.replaced_offset)
	if M.replaced_offset >= M.bytecode_len then
		print("Stepped through everything!")
		ctx.current_opcode = ctx.current_opcode - 1
		return
	end
	ctx.current_opcode = ctx.current_opcode - 1
	M.replaced_opcode = bytecode[M.replaced_offset]
	bytecode[M.replaced_offset] = 0x1337
end

return M
