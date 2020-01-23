#include <stdio.h>
#include "instructions.h"
#include "linear opt looping table.h"

#define tape_len 65536

Instructions parse_file(char* file_name) {
	FILE* prog = fopen(file_name, "rb");
	
	fseek(prog, 0, SEEK_END);
	size_t prog_len = ftell(prog);
	rewind(prog);
	
	char* raw_prog = malloc(sizeof(char) * prog_len);
	fread(raw_prog, sizeof(char), prog_len, prog);
	
	fclose(prog);
	
	return parse_instrs(prog_len, raw_prog);
}

void interpret_bf(Instructions instrs, char* input_str) {
	size_t tape_ptr = 0;
	char tape[tape_len] = {};
	size_t input_ptr = 0;
	
	size_t instr_ptr = 0;
	unsigned char times_to_loop;
	signed char offset;
	signed char multiplier;
	while(instr_ptr < instrs.len) {
		unsigned char* args = instrs.instrs[instr_ptr].args;
		switch(instrs.instrs[instr_ptr].instr) {
		case inc:
			tape[tape_ptr]++;
			break;
		case dec:
			tape[tape_ptr]--;
			break;
		case left:
			tape_ptr--;
			break;
		case right:
			tape_ptr++;
			break;
		case output:
			putc(tape[tape_ptr], stdout);
			break;
		case input:
			if(input_str[input_ptr]) {
				tape[tape_ptr] = input_str[input_ptr];
				// printf("\nGAVE %c AS INPUT\n", input_str[input_ptr]);
				input_ptr++;
			} else {
				tape[tape_ptr] = getchar();
			}
			break;
		case begin_loop:
			if(!tape[tape_ptr]) {
				// size_t ninstr_ptr = ((size_t)args[0]) * 256 + (size_t)args[1];
				// printf("%d down to %d\n", instr_ptr, ninstr_ptr);
				instr_ptr = ((size_t)args[0]) * 256 + (size_t)args[1];
			}
			break;
		case end_loop:
			if(tape[tape_ptr]) {
				// size_t ninstr_ptr = ((size_t)args[0]) * 256 + (size_t)args[1];
				// printf("%d up to %d\n", instr_ptr, ninstr_ptr);
				instr_ptr = ((size_t)args[0]) * 256 + (size_t)args[1];
			}
			break;
		case add:
			tape[tape_ptr] += args[0];
			break;
		case sub:
			tape[tape_ptr] -= args[0];
			break;
		case move_left:
			tape_ptr -= args[0];
			break;
		case move_right:
			tape_ptr += args[0];
			break;
		case set:
			tape[tape_ptr] = args[0];
			break;
		case add_offset:
			offset = args[0];
			tape[tape_ptr + offset] += args[1];
			break;
		case sub_offset:
			offset = args[0];
			tape[tape_ptr + offset] -= args[1];
			break;
		case set_offset:
			offset = args[0];
			tape[tape_ptr + offset] = args[1];
			break;
		case mult:
			offset = args[0];
			multiplier = args[1];
			tape[tape_ptr + offset] += tape[tape_ptr] * multiplier;
			break;
		case linear_set_loops:
			if(tape[tape_ptr] == 0) {
				times_to_loop = 0;
			} else {
				times_to_loop = linear_opt_table[args[0]][tape[tape_ptr] - 1];
			}
			break;
		case linear_opt_mult:
			offset = args[0];
			multiplier = args[1];
			tape[tape_ptr + offset] += times_to_loop * multiplier;
			break;
		default:
			printf("That instruction has not been implemented yet!");
			return;
		}
		instr_ptr++;
	}
}

int main(int argc, char** argv) {
	if(argc != 2 && argc != 3) {
		printf("Only 1 or 2 arguments can be passed: the filename of the program and the input for the program.");
		return 0;
	}
	
	Instructions instrs = parse_file(argv[1]);
	if(argc == 2) {
		interpret_bf(instrs, "");
	} else {
		interpret_bf(instrs, argv[2]);
	}
	
	return 0;
}