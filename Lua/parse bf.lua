local instrs = require "instructions"

local function parse_rec(code, pos)
	local ast = {}
	while pos <= #code do
		local token = instrs.char_to_instr(code:sub(pos, pos))
		-- print(code:sub(pos, pos), token)
		if token then
			if not instrs.is_loop_instr(token) then
				table.insert(ast, {instr = token})
			else
				if token == instrs.begin_loop then
					-- print(pos)
					loop_body, pos = parse_rec(code, pos + 1)
					if pos == 0 then
						error "Unclosed bracket."
					end
					table.insert(ast, {
						instr = token,
						body = loop_body
					})
				else
					return ast, pos
				end
			end
		end
		pos = pos + 1
	end
	return ast, 0
end

return function(code)
	local ast, pos = parse_rec(code, 1)
	if pos == 0 then
		return ast
	else
		error "Too many closing brackets."
	end
end