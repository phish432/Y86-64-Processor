module fetch (clk, PC, icode, ifun, rA, rB, valC, valP, hlt, imem_error, instr_valid);
	// Ports
	input clk;
	input [63:0] PC;
	output reg [ 3:0] icode;
	output reg [ 3:0] ifun;
	output reg [ 3:0] rA;
	output reg [ 3:0] rB;
	output reg [63:0] valC;
	output reg [63:0] valP;
	output reg hlt;
	output reg imem_error;
	output reg instr_valid;

	initial begin
		rA = 4'hf;
		rB = 4'hf;
		valC = 64'd0;
		valP = 64'd0;
		hlt = 0;
		imem_error = 0;
		instr_valid = 1;
	end

	// Instruction Codes
	parameter INOP    = 4'h0;
	parameter IHALT   = 4'h1;
	parameter ICMOVXX = 4'h2;
	parameter IIRMOVQ = 4'h3;
	parameter IRMMOVQ = 4'h4;
	parameter IMRMOVQ = 4'h5;
	parameter IOPQ    = 4'h6;
	parameter IJXX    = 4'h7;
	parameter ICALL   = 4'h8;
	parameter IRET    = 4'h9;
	parameter IPUSHQ  = 4'ha;
	parameter IPOPQ   = 4'hb;

	// Instruction Memory
	reg [7:0] i_mem [1023:0];
	initial begin
		// 30 f0 0c 00 00 00 00 00 00 00 | irmovq $12, %rax
		i_mem[0] = 8'h30;
		i_mem[1] = 8'hf0;
		i_mem[2] = 8'h0c;
		i_mem[3] = 8'h00;
		i_mem[4] = 8'h00;
		i_mem[5] = 8'h00;
		i_mem[6] = 8'h00;
		i_mem[7] = 8'h00;
		i_mem[8] = 8'h00;
		i_mem[9] = 8'h00;

		// // 00 | halt
		// i_mem[0] = 8'h00;

		// // ff | INVALID
		// i_mem[0] = 8'hff;
	end

	// Fetch Stage
	reg [7:0] opcode;
	reg [7:0] regids;

	always @(posedge clk) begin
		if (PC > 1023) begin
			imem_error = 1;
		end

		opcode = i_mem[PC];
		icode = opcode[7:4];
		ifun = opcode[3:0];

		if (icode == IHALT) begin
			hlt = 1;
			valP = PC + 1;
		end
		else if (icode == INOP) begin
			valP = PC + 1;
		end
		else if (icode == ICMOVXX) begin
			regids = i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valP = PC + 2;
		end
		else if (icode == IIRMOVQ) begin
			regids = i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valC = {
			    i_mem[PC + 9],
			    i_mem[PC + 8],
			    i_mem[PC + 7],
			    i_mem[PC + 6],
			    i_mem[PC + 5],
			    i_mem[PC + 4],
			    i_mem[PC + 3],
			    i_mem[PC + 2]
			};
			valP = PC + 10;
		end
		else if (icode == IRMMOVQ) begin
			regids = i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valC = {
			    i_mem[PC + 9],
			    i_mem[PC + 8],
			    i_mem[PC + 7],
			    i_mem[PC + 6],
			    i_mem[PC + 5],
			    i_mem[PC + 4],
			    i_mem[PC + 3],
			    i_mem[PC + 2]
			};
			valP = PC + 10;
		end
		else if (icode == IMRMOVQ) begin
			regids = i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valC = {
			    i_mem[PC + 9],
			    i_mem[PC + 8],
			    i_mem[PC + 7],
			    i_mem[PC + 6],
			    i_mem[PC + 5],
			    i_mem[PC + 4],
			    i_mem[PC + 3],
			    i_mem[PC + 2]
			};
			valP = PC + 10;
		end
		else if (icode == IOPQ) begin
			regids = i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valP = PC + 2;
		end
		else if (icode == IJXX) begin
			valC = {
			    i_mem[PC + 8],
			    i_mem[PC + 7],
			    i_mem[PC + 6],
			    i_mem[PC + 5],
			    i_mem[PC + 4],
			    i_mem[PC + 3],
			    i_mem[PC + 2],
			    i_mem[PC + 1]
			};
			valP = PC + 9;
		end
		else if (icode == ICALL) begin
			valC = {
			    i_mem[PC + 8],
			    i_mem[PC + 7],
			    i_mem[PC + 6],
			    i_mem[PC + 5],
			    i_mem[PC + 4],
			    i_mem[PC + 3],
			    i_mem[PC + 2],
			    i_mem[PC + 1]
			};
			valP = PC + 9;		
		end
		else if (icode == IRET) begin
			valP = PC + 1;
		end
		else if (icode == IPUSHQ) begin
			regids = i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valP = PC + 2;
		end
		else if (icode == IPOPQ) begin
			regids = i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valP = PC + 2;
		end
		else begin
			instr_valid = 0;
		end
	end
endmodule