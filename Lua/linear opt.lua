local instrs = require "instructions"
local loop_checks = require "loop checks"

local function linear_loop_to_instrs(ast)
	local linear_instrs = {}
	
	local change_to_main_cell = 0
	for _, node in ipairs(ast) do
		if node.args and node.args[1] == 0 then
			-- The - and + signs are not backward because the whole looping table starts with -1 and ends with -255, which is +1.
			if node.instr == instrs.add_offset then
				change_to_main_cell = change_to_main_cell - node.args[2]
			elseif node.instr == instrs.sub_offset then
				change_to_main_cell = change_to_main_cell + node.args[2]
			end
		end
	end
	if change_to_main_cell < 0 then
		change_to_main_cell = change_to_main_cell + 256
	end
	table.insert(linear_instrs, {
		instr = instrs.linear_set_loops,
		args = {change_to_main_cell}
	})
	
	for _, node in ipairs(ast) do
		if
			node.instr == instrs.add_offset and
			node.args[1] ~= 0
		then
			table.insert(linear_instrs, {
				instr = instrs.linear_opt_mult,
				args = {node.args[1], node.args[2]}
			})
		elseif
			node.instr == instrs.sub_offset and
			node.args[1] ~= 0
		then
			table.insert(linear_instrs, {
				instr = instrs.linear_opt_mult,
				args = {node.args[1], 256 - node.args[2]}
			})
		end
	end
	
	table.insert(linear_instrs, {
		instr = instrs.set,
		args = {0}
	})
	return linear_instrs
end

local function linear_opt(ast)
	local opt_ast = {}
	
	for _, node in ipairs(ast) do
		local instr = node.instr
		if
			instrs.is_loop_instr(instr) and
			loop_checks.is_simple_linear_loop(node.body)
		then
			local linear_instrs = linear_loop_to_instrs(node.body)
			for _, node in ipairs(linear_instrs) do
				table.insert(opt_ast, node)
			end
		elseif instrs.is_loop_instr(instr) then
			table.insert(opt_ast, {
				instr = instrs.begin_loop,
				body = linear_opt(node.body)
			})
		else
			table.insert(opt_ast, node)
		end
	end
	
	return opt_ast
end

return linear_opt