--local dis = require "disassembler"
local signatures = require "signatures"
local ffi = require "ffi"
local M = {}

M.replaced_opcode = 0xDEAD
M.bytecode_len = 0
M.replaced_offset = 0

M.suspended_proc = nil
M.suspended_replaced_opcode = 0x1338

function M.debug_hook(ctx)
	local bytecode = ctx.bytecode
	bytecode[M.replaced_offset] = M.replaced_opcode
	--dis.disassemble(bytecode, M.bytecode_len, M.replaced_offset)
	--M.replaced_offset = dis.get_next_instruction_offset(bytecode, M.replaced_offset)
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

function M.suspend_current_proc(ctx)
	print("Pausing proc")
	ctx.current_opcode = ctx.current_opcode + 1 --advance to next instruction so it resumes there
	M.suspended_proc = signatures.ResumeIn(ctx, 0x7fffff00)
	ctx.current_opcode = ctx.current_opcode - 1
	ctx.bytecode[ctx.current_opcode] = 0x00
	ctx.current_opcode = ctx.current_opcode - 1
	M.suspended_ctx = ctx
end

function M.resume_suspended(ctx)
	print("Resuming proc")
	M.suspended_proc.time_to_resume = 0
end

return M
