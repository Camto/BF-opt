local
	inc, dec,
	left, right,
	output, input,
	begin_loop, end_loop, -- Two bytes for the jump location.
	
	add, sub,
	move_left, move_right,
	
	set,
	
	-- First byte is offset.
	add_offset, sub_offset,
	set_offset,
	
	mult,
	
	linear_set_loops, linear_opt_mult
=
	0, 1,
	2, 3,
	4, 5,
	6, 7,
	
	8, 9,
	10, 11,
	
	12,
	
	13, 14,
	15,
	
	16,
	
	17, 18

local function is_loop_instr(instr)
	if instr == begin_loop or instr == end_loop then
		return true
	else
		return false
	end
end

local function is_io_instr(instr)
	if instr == output or instr == input then
		return true
	else
		return false
	end
end

return {
	inc = inc, dec = dec,
	left = left, right = right,
	output = output, input = input,
	begin_loop = begin_loop, end_loop = end_loop,
	
	add = add, sub = sub,
	move_left = move_left, move_right = move_right,
	
	set = set,
	
	add_offset = add_offset, sub_offset = sub_offset,
	set_offset = set_offset,
	
	mult = mult,
	
	linear_set_loops = linear_set_loops, linear_opt_mult = linear_opt_mult,
	
	char_to_instr = function(char)
		if char == "+" then return inc
		elseif char == "-" then return dec
		elseif char == "<" then return left
		elseif char == ">" then return right
		elseif char == "." then return output
		elseif char == "," then return input
		elseif char == "[" then return begin_loop
		elseif char == "]" then return end_loop
		else return false end
	end,
	
	-- These are defined outside because the next functions depend on them.
	is_loop_instr = is_loop_instr,
	is_io_instr = is_io_instr,
	
	instr_to_glob = function(instr)
		if instr == inc then return add
		elseif instr == dec then return sub
		elseif instr == left then return move_left
		elseif instr == right then return move_right
		else return false end
	end,
	
	is_glob_instr = function(instr)
		return
			not is_loop_instr(instr) and
			not is_io_instr(instr)
	end
}