#include <stdlib.h>

typedef enum {
	inc = 0, dec = 1,
	left = 2, right = 3,
	output = 4, input = 5,	
	begin_loop = 6, end_loop = 7,
	
	add = 8, sub = 9,
	move_left = 10, move_right = 11,
	
	set = 12,
	
	add_offset = 13, sub_offset = 14,
	set_offset = 15,
	
	mult = 16,
	
	linear_set_loops = 17, linear_opt_mult = 18
} Instruction;

size_t args_per_instr[] = {
	/*inc*/ 0, /*dec*/ 0,
	/*left*/ 0, /*right*/ 0,
	/*output*/ 0, /*input*/ 0,
	/*begin_loop*/ 2, /*end_loop*/ 2, // Two bytes for the jump location.
	
	/*add*/ 1, /*sub*/ 1,
	/*move_left*/ 1, /*move_right*/ 1,
	
	/*set*/ 1,
	
	// First byte is offset.
	/*add_offset*/ 2, /*sub_offset*/ 2,
	/*set_offset*/ 2,
	
	/*mult*/ 2,
	
	/*linear_set_loops*/ 1, /*linear_opt_mult*/ 2
};

unsigned char* instr_to_str[] = {
	"inc", "dec",
	"left", "right",
	"output", "input",
	"begin_loop", "end_loop",
	
	"add", "sub",
	"move_left", "move_right",
	
	"set",
	
	"add_offset", "sub_offset",
	"set_offset",
	
	"mult",
	
	"linear_set_loops", "linear_opt_mult"
};

typedef struct {
	Instruction instr;
	unsigned char* args;
} Instr_With_Args;

typedef struct {
	size_t len;
	Instr_With_Args* instrs;
} Instructions;

Instructions parse_instrs(size_t bytecode_len, unsigned char* raw_bytecode) {
	Instructions instructions = {
		0,
		malloc(sizeof(Instr_With_Args) * bytecode_len)
	};
	
	size_t i = 0;
	while(i < bytecode_len) {
		Instr_With_Args current_instr = {
			(Instruction) raw_bytecode[i],
			malloc(sizeof(unsigned char) * args_per_instr[raw_bytecode[i]])
		};
		size_t j;
		for(j = 0; j < args_per_instr[raw_bytecode[i]]; j++) {
			current_instr.args[j] = raw_bytecode[i + j + 1];
		}
		i += j + 1;
		
		instructions.instrs[instructions.len] = current_instr;
		instructions.len++;
	}
	
	return instructions;
}

void print_pretty_instrs(Instructions instrs) {
	for(size_t i = 0; i < instrs.len; i++) {
		Instruction current_instr = instrs.instrs[i].instr;
		printf("%zd %s", i, instr_to_str[current_instr]);
		for(size_t j = 0; j < args_per_instr[current_instr]; j++) {
			printf(" %u", instrs.instrs[i].args[j]);
		}
		printf("\n");
	}
}