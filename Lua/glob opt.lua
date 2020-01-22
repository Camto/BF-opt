local instrs = require "instructions"

local function glob(last_instr, glob_instr_count, opt_ast)
	local glob_instr =
		instrs.instr_to_glob(last_instr)
	if glob_instr then
		return {
			instr = glob_instr,
			args = {glob_instr_count}
		}
	else
		error("Nonbasic instruction " .. last_instr .. " found in ast to have the globbing optimization.")
	end
end

local function glob_opt(ast)
	local opt_ast = {}
	
	local last_instr
	local glob_instr_count = 0
	for pos, node in ipairs(ast) do
		local instr = node.instr
		
		if
			instrs.is_glob_instr(last_instr)
		then
			if pos == 1 then
				glob_instr_count = 1
			elseif instr == last_instr then
				glob_instr_count = glob_instr_count + 1
			end
		end
		
		if
			instrs.is_glob_instr(last_instr) and
			instr ~= last_instr and pos > 1
		then
			table.insert(
				opt_ast,
				glob(last_instr, glob_instr_count, opt_ast)
			)
			glob_instr_count = 1
		end
		
		if
			pos == #ast and
			instrs.is_glob_instr(instr)
		then
			table.insert(
				opt_ast,
				glob(instr, glob_instr_count, opt_ast)
			)
		end
		
		if instrs.is_loop_instr(instr) then
			table.insert(opt_ast, {
				instr = instrs.begin_loop,
				body = glob_opt(node.body)
			})
		elseif instrs.is_io_instr(instr) then
			table.insert(opt_ast, node)
		end
		
		last_instr = instr
	end
	return opt_ast
end

return glob_opt