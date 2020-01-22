local instrs = require "instructions"

local function erase_opt(ast)
	local opt_ast = {}
	
	local last_was_erase = false
	for _, node in ipairs(ast) do
		if instrs.is_loop_instr(node.instr) then
			
			if
				#node.body == 1 and
				node.body[1].instr == instrs.sub and
				node.body[1].args[1] == 1
			then
				last_was_erase = true
			else
				if last_was_erase then
					table.insert(opt_ast, {
						instr = instrs.set,
						args = {0}
					})
				end
				table.insert(opt_ast, {
					instr = instrs.begin_loop,
					body = erase_opt(node.body)
				})
				last_was_erase = false
			end
			
		else
			
			if last_was_erase then
				if node.instr == instrs.add then
					table.insert(opt_ast, {
						instr = instrs.set,
						args = node.args
					})
				elseif last_was_erase and node.instr == instrs.sub then
					table.insert(opt_ast, {
						instr = instrs.set,
						args = {256 - node.args[1]}
					})
				else
					table.insert(opt_ast, {
						instr = instrs.set,
						args = {0}
					})
					table.insert(opt_ast, node)
				end
			else
				table.insert(opt_ast, node)
			end
			last_was_erase = false
			
		end
	end
	
	if last_was_erase then
		table.insert(opt_ast, {
			instr = instrs.set,
			args = {0}
		})
	end
	
	return opt_ast
end

return erase_opt