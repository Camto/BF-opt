pretty = require "pl.pretty"
parse = require "parse bf"
glob_opt = require "glob opt"
set_opt = require "set opt"
offset_opt = require "offset opt"
mult_opt = require "mult opt"
linear_opt = require "linear opt"
ast_to_abc = require "ast to abc"
abc_to_bc = require "abc to bc"

--[[
	Settings:
		code: string to replace reading from a string.
		noglob: disable default globbing optimization.
		printpreast: print parsed ast before optional optimizations.
		nocomp: do not compile, instead print ast.
			noprint: do not print ast either.
			noflat: do not flatten printed ast.
		outfile: string to replace default compiled file path.
		opts: enable certain optional optimizations.
			set: turning [-] into setting.
			offset: simplify movement when many of +-<> are together.
				mult: turn multiplication loops into corresponding instructions.
				linear: turn any linear loop into corresponding instructions.
]]--

settings = pretty.read(arg[2] or "{}")

if settings.code then
	code = settings.code
else
	program = io.open(arg[1], "rb")
	code = program:read("*a")
	program:close()
end

-- Always do these.
ast = parse(code)
if not settings.noglob then
	ast = glob_opt(ast)
end

if settings.printpreast then
	pretty.dump(ast)
end

-- Optional opts.
opts = settings.opts or {}
if opts.set then
	ast = set_opt(ast)
end
if opts.offset or opts.mult or opt.linear then
	ast = offset_opt(ast)
	if opts.mult then
		ast = mult_opt(ast)
		if not opts.offset then
			print("The multiplication optimization depends on the offset optimization, so it was enabled.")
		end
	end
	if opts.linear then
		ast = linear_opt(ast)
		if not opts.offset then
			print("The linear optimization depends on the offset optimization, so it was enabled.")
		end
	end
end

if not settings.nocomp then
	outfile = settings.outfile or arg[1]:sub(0, -4) .. ".bc"
	file = io.open(outfile, "wb")
	io.output(file)
	io.write(abc_to_bc(ast_to_abc(ast)))
	file:close()
	print('Wrote to "'.. outfile .. '"')
elseif not settings.noprint then
	if not settings.noflat then
		ast = ast_to_abc(ast)
	end
	pretty.dump(ast)
end