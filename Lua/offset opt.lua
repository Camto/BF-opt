instrs = require "instructions"

local function offset_opt(ast)
	local opt_ast = {}
	
	local offset_location = 0
	for _, node in ipairs(ast) do
		if node.instr == instrs.move_left then
			offset_location = offset_location - node.args[1]
		elseif node.instr == instrs.move_right then
			offset_location = offset_location + node.args[1]
		elseif node.instr == instrs.add then
			table.insert(opt_ast, {
				instr = instrs.add_offset,
				args = {offset_location, node.args[1]}
			})
		elseif node.instr == instrs.sub then
			table.insert(opt_ast, {
				instr = instrs.sub_offset,
				args = {offset_location, node.args[1]}
			})
		elseif node.instr == instrs.set then
			table.insert(opt_ast, {
				instr = instrs.set_offset,
				args = {offset_location, node.args[1]}
			})
		else
			if offset_location < 0 then
				table.insert(opt_ast, {
					instr = instrs.move_left,
					args = {-offset_location}
				})
			elseif offset_location > 0 then
				table.insert(opt_ast, {
					instr = instrs.move_right,
					args = {offset_location}
				})
			end
			offset_location = 0
			
			if node.instr == instrs.begin_loop then
				table.insert(opt_ast, {
					instr = instrs.begin_loop,
					body = offset_opt(node.body)
				})
			else
				table.insert(opt_ast, node)
			end
		end
	end
	
	if offset_location < 0 then
		table.insert(opt_ast, {
			instr = instrs.move_left,
			args = {-offset_location}
		})
	elseif offset_location > 0 then
		table.insert(opt_ast, {
			instr = instrs.move_right,
			args = {offset_location}
		})
	end
	
	return opt_ast
end

return offset_opt