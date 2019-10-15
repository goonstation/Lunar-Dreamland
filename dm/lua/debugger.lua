--local dis = require "disassembler"
local signatures = require "signatures"
local ffi = require "ffi"
local t2t = require"type2type"
local M = {}

M.replaced_opcode = 0xDEAD
M.bytecode_len = 0
M.replaced_offset = 0

M.suspended_proc = nil
M.suspended_replaced_opcode = 0x1338

M.dmdis = ffi.load("dmdism")
M.bffi = ffi.load("byondffi")

function M.debug_hook(ctx)
	print(ctx.bytecode)
	print(ctx.current_opcode)
	M.dmdis.breakpoint_hit(ctx.bytecode, ctx.current_opcode)
end

ffi.cdef [[
	void __cdecl register_suspension(float, SuspendedProc*);
]]

function M.suspend_current_proc(ctx)
	print("Pausing proc")
	ctx.current_opcode = ctx.current_opcode + 1 --advance to next instruction so it resumes there
	local suspended_proc = signatures.ResumeIn2(ctx, 0)
	suspended_proc.time_to_resume = 0x7fffff
	signatures.StartTiming(suspended_proc)
	--ctx.current_opcode = ctx.current_opcode - 1
	--ctx.bytecode[ctx.current_opcode] = 0x00
	--ctx.current_opcode = ctx.current_opcode - 1
	--M.suspended_ctx = ctx
	--local ref = tonumber(string.sub(t2t.toLua(ctx.constants.args[0]), 6, -2), 16)
	local ref = t2t.toLua(ctx.constants.args[1])
	print(ref)
	M.bffi.register_suspension(ref, suspended_proc)
end

function M.resume_suspended(ctx)
	print("Resuming proc")
	M.suspended_proc.time_to_resume = 1
end

return M
