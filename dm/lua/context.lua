local ffi = require("ffi")
local type2type = require "type2type"
local signatures = require "signatures"

local M = {}
function M.get_context()
	return signatures.CurrentExecutionContext[0]
end

function M.get_parent_context()
	local parent = ffi.cast("ExecutionContext*", M.get_context().parent_context)
	if parent ~= ffi.null then
		return parent[0]
	end
	return ffi.null
end

function M.get_bytecode()
	return M.get_context().bytecode
end

function M.get_instruction_pointer()
	return M.get_context().current_opcode
end

function M.get_locals()
	return M.get_context().local_variables
end

function M.get_stack()
	return M.get_context().stack
end

return M
