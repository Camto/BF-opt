#include <stdio.h>
#include "instructions.h"

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

int main(int argc, char** argv) {
	if(argc != 2) {
		printf("Only 1 argument can be passed: the filename of the program.");
		return 0;
	}
	
	Instructions instrs = parse_file(argv[1]);
	print_pretty_instrs(instrs);
	
	return 0;
}