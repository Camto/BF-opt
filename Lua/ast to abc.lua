local instrs = require "instructions"

local function ast_to_abc(ast, loop_offset)
	local abc = {}
	local previous_loops_offset = 0
	for pos, node in pairs(ast) do
		if not instrs.is_loop_instr(node.instr) then
			table.insert(abc, node)
		else
			local loop_abc = ast_to_abc(
				node.body,
				pos
					+ loop_offset
					+ previous_loops_offset
			)
			
			local begin_loop_arg =
				pos
					+ #loop_abc
					+ loop_offset
					+ previous_loops_offset
			table.insert(abc, {
				instr = instrs.begin_loop,
				args = {
					math.floor(begin_loop_arg / 256),
					begin_loop_arg % 256
				}
			})
			
			for _, node in pairs(loop_abc) do
				table.insert(abc, node)
			end
			
			local end_loop_arg =
				pos
					+ loop_offset
					+ previous_loops_offset
					- 1
			table.insert(abc, {
				instr = instrs.end_loop,
				args = {
					math.floor(end_loop_arg / 256),
					end_loop_arg % 256
				}
			})
			
			previous_loops_offset =
				previous_loops_offset
					+ #loop_abc
					+ 1
		end
	end
	return abc
end

return function(ast)
	return ast_to_abc(ast, 0)
end