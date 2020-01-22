local function offset_to_char(offset)
	if offset >= 0 then
		return offset
	else
		return 256 + offset
	end
end

return function(abc)
	local list_bc = {}
	for _, node in pairs(abc) do
		table.insert(list_bc, string.char(node.instr))
		if node.args then
			for _, arg in pairs(node.args) do
				table.insert(list_bc, string.char(offset_to_char(arg)))
			end
		end
	end
	
	return table.concat(list_bc)
end