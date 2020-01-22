local instrs = require "instructions"

return {
	-- Checks to see if <> are balanced and loop has none of .,[]
	is_simple_linear_loop = function(ast)
		for _, node in ipairs(ast) do
			local instr = node.instr
			if
				instrs.is_loop_instr(instr) or
				instrs.is_io_instr(instr) or
				instr == instrs.move_left or
				instr == instrs.move_right
			then
				return false
			end
		end
		return true
	end,

	--[[
		Checks to see if
		{
			instr = instrs.sub_offset,
			args = {0, 1} -- dec on offset 0.
		}
		is the only thing that touches the current cell in the simple, linear loop.
	]]--
	has_only_loop_dec = function(ast)
		local loop_dec_count = 0
		for _, node in ipairs(ast) do
			if
				node.instr == instrs.add_offset and
				node.args[1] == 0 -- Affects current cell.
			then
				return false
			elseif
				node.instr == instrs.sub_offset and
				node.args[1] == 0 -- Affects current cell.
			then
				if node.args[2] == 1 then -- Onlt sub by 1.
					loop_dec_count = loop_dec_count + 1
				else
					return false
				end
			elseif
				node.instr == instrs.set_offset and
				node.args[1] == 0 -- Affects current cell.
			then
				return false
			end
		end
		return loop_dec_count == 1
	end
}