local instrs = require "instructions"
local loop_checks = require "loop checks"

local function mult_loop_to_instrs(ast)
	local mult_instrs = {}
	
	for _, node in ipairs(ast) do
		if node.instr == instrs.add_offset then
			table.insert(mult_instrs, {
				instr = instrs.mult,
				args = {node.args[1], node.args[2]}
			})
		elseif
			node.instr == instrs.sub_offset and
			node.args[1] ~= 0
		then
			table.insert(mult_instrs, {
				instr = instrs.mult,
				args = {node.args[1], -node.args[2]}
			})
		end
	end
	
	table.insert(mult_instrs, {
		instr = instrs.set,
		args = {0}
	})
	return mult_instrs
end

local function mult_opt(ast)
	local opt_ast = {}
	
	for _, node in ipairs(ast) do
		local instr = node.instr
		if
			instrs.is_loop_instr(instr) and
			loop_checks.is_simple_linear_loop(node.body) and
			loop_checks.has_only_loop_dec(node.body)
		then
			local mult_instrs = mult_loop_to_instrs(node.body)
			for _, node in ipairs(mult_instrs) do
				table.insert(opt_ast, node)
			end
		elseif instrs.is_loop_instr(instr) then
			table.insert(opt_ast, {
				instr = instrs.begin_loop,
				body = mult_opt(node.body)
			})
		else
			table.insert(opt_ast, node)
		end
	end
	
	return opt_ast
end

return mult_opt