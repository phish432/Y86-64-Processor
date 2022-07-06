`timescale  1ns / 1ps

module SEQ;
	reg clk;
	reg [63:0] PC;

	wire [ 3:0] icode;
	wire [ 3:0] ifun;
	wire [ 3:0] rA;
	wire [ 3:0] rB;
	wire [63:0] valA;
	wire [63:0] valB;
	wire [63:0] valC;
	wire [63:0] valP;
	wire [63:0] valE;
	wire [63:0] valM;
	wire [ 3:0] dstE;
	wire [ 3:0] dstM;
	wire [63:0] new_PC;
	wire Cnd;
	wire hlt;
	wire imem_error;
	wire instr_valid;
	wire dmem_error;

	reg [ 7:0] i_mem [1023:0];
	reg [63:0] d_mem [2047:0];
	reg [63:0] register_file [0:14];
	initial begin
		// 30 f0 0c 00 00 00 00 00 00 00 | irmovq $12, %rcx
		i_mem[0] = 8'h30;
		i_mem[1] = 8'hf1;
		i_mem[2] = 8'h0c;
		i_mem[3] = 8'h00;
		i_mem[4] = 8'h00;
		i_mem[5] = 8'h00;
		i_mem[6] = 8'h00;
		i_mem[7] = 8'h00;
		i_mem[8] = 8'h00;
		i_mem[9] = 8'h00;

		i_mem[10] = 8'h10;
		i_mem[11] = 8'h10;
		i_mem[12] = 8'h10;
		i_mem[13] = 8'h10;
		i_mem[14] = 8'h10;
		i_mem[15] = 8'h10;

		// 00 | halt
		i_mem[16] = 8'h00;
		// // ff | INVALID
		// i_mem[11] = 8'hff;
	end

	fetch     fetch_stage     (clk, PC, icode, ifun, rA, rB, valC, valP, hlt, imem_error, instr_valid);
	decode    decode_stage    (clk, icode, rA, rB, valA, valB);
	execute   execute_stage   (clk, icode, ifun, valA, valB, valC, valE, Cnd);
	memory    memory_stage    (clk, icode, valA, valE, valP, valM, dmem_error);
	writeback writeback_stage (clk, icode, rA, rB, valE, valM, Cnd, dstE, dstM);
	pcupdate  pcupdate_stage  (clk, PC, icode, Cnd, valC, valM, valP, new_PC);

	always #10 clk = ~clk;
	always #110 PC = new_PC;

	initial begin
		clk = 0;
		PC = 0;
	end

	always @(*) begin
		if (hlt) begin
			$finish;
		end
	end

	always @(posedge clk) begin
		$monitor($time, " Fetch\n\t\t     PC = %d\n\t\t     icode = %h\n\t\t     ifun  = %h\n\t\t     rA = %d\n\t\t     rB = %d\n\t\t     valC = %d\n\t\t     valP = %d\n\t\t     Decode\n\t\t     valA = %d\n\t\t     valB = %d\n\t\t     Execute\n\t\t     valE = %d\n\t\t     Memory\n\t\t     valM = %d\n\t\t     Writeback\n\t\t     dstE = %h\n\t\t     valE = %d\n\t\t     dstM = %h\n\t\t     valM = %d\n\t\t     PC Update\n\t\t     nPC  = %d\n\t\t     hlt = %d\n", PC, icode, ifun, rA, rB, valC, valP, valA, valB, valE, valM, dstE, valE, dstM, valM, new_PC, hlt);
	end
endmodule

module fetch (clk, PC, icode, ifun, rA, rB, valC, valP, hlt, imem_error, instr_valid);
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

	reg [7:0] opcode;
	reg [7:0] regids;

	always @(posedge clk) begin
		if (PC > 1023) begin
			imem_error = 1;
		end

		opcode = SEQ.i_mem[PC];
		icode = opcode[7:4];
		ifun = opcode[3:0];

		if (icode == 4'h0) begin
			hlt = 1;
			valP = PC + 1;
		end
		else if (icode == 4'h1) begin
			valP = PC + 1;
		end
		else if (icode == 4'h2) begin
			regids = SEQ.i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valP = PC + 2;
		end
		else if (icode == 4'h3) begin
			regids = SEQ.i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valC = {
			    SEQ.i_mem[PC + 9],
			    SEQ.i_mem[PC + 8],
			    SEQ.i_mem[PC + 7],
			    SEQ.i_mem[PC + 6],
			    SEQ.i_mem[PC + 5],
			    SEQ.i_mem[PC + 4],
			    SEQ.i_mem[PC + 3],
			    SEQ.i_mem[PC + 2]
			};
			valP = PC + 10;
		end
		else if (icode == 4'h4) begin
			regids = SEQ.i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valC = {
			    SEQ.i_mem[PC + 9],
			    SEQ.i_mem[PC + 8],
			    SEQ.i_mem[PC + 7],
			    SEQ.i_mem[PC + 6],
			    SEQ.i_mem[PC + 5],
			    SEQ.i_mem[PC + 4],
			    SEQ.i_mem[PC + 3],
			    SEQ.i_mem[PC + 2]
			};
			valP = PC + 10;
		end
		else if (icode == 4'h5) begin
			regids = SEQ.i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valC = {
			    SEQ.i_mem[PC + 9],
			    SEQ.i_mem[PC + 8],
			    SEQ.i_mem[PC + 7],
			    SEQ.i_mem[PC + 6],
			    SEQ.i_mem[PC + 5],
			    SEQ.i_mem[PC + 4],
			    SEQ.i_mem[PC + 3],
			    SEQ.i_mem[PC + 2]
			};
			valP = PC + 10;
		end
		else if (icode == 4'h6) begin
			regids = SEQ.i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valP = PC + 2;
		end
		else if (icode == 4'h7) begin
			valC = {
			    SEQ.i_mem[PC + 8],
			    SEQ.i_mem[PC + 7],
			    SEQ.i_mem[PC + 6],
			    SEQ.i_mem[PC + 5],
			    SEQ.i_mem[PC + 4],
			    SEQ.i_mem[PC + 3],
			    SEQ.i_mem[PC + 2],
			    SEQ.i_mem[PC + 1]
			};
			valP = PC + 9;
		end
		else if (icode == 4'h8) begin
			valC = {
			    SEQ.i_mem[PC + 8],
			    SEQ.i_mem[PC + 7],
			    SEQ.i_mem[PC + 6],
			    SEQ.i_mem[PC + 5],
			    SEQ.i_mem[PC + 4],
			    SEQ.i_mem[PC + 3],
			    SEQ.i_mem[PC + 2],
			    SEQ.i_mem[PC + 1]
			};
			valP = PC + 9;		
		end
		else if (icode == 4'h9) begin
			valP = PC + 1;
		end
		else if (icode == 4'ha) begin
			regids = SEQ.i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valP = PC + 2;
		end
		else if (icode == 4'hb) begin
			regids = SEQ.i_mem[PC + 1];
			rA = regids[7:4];
			rB = regids[3:0];
			valP = PC + 2;
		end
		else begin
			instr_valid = 0;
		end
	end
endmodule

module decode (clk, icode, rA, rB, valA, valB);
	input clk;
	input [3:0] icode;
	input [3:0] rA;
	input [3:0] rB;
	output reg [63:0] valA;
	output reg [63:0] valB;

	initial begin
		valA = 64'd0;
		valB = 64'd0;
	end

	always @(posedge clk) begin
		if (icode == 4'h2) begin
			valA = SEQ.register_file[rA];
		end
		else if(icode == 4'h3) begin
			valB = SEQ.register_file[rB];
		end
		else if(icode == 4'h4) begin
			valA = SEQ.register_file[rA];
			valB = SEQ.register_file[rB];
		end
		else if(icode == 4'h5) begin
			valB = SEQ.register_file[rB];
		end
		else if(icode == 4'h6) begin
			valA = SEQ.register_file[rA];
			valB = SEQ.register_file[rB];
		end
		else if(icode == 4'h8) begin
			valB = SEQ.register_file[4];
		end
		else if(icode == 4'h9) begin
			valA = SEQ.register_file[4];
			valB = SEQ.register_file[4];
		end
		else if(icode == 4'ha) begin
			valA = SEQ.register_file[rA];
			valB = SEQ.register_file[4];
		end
		else if(icode == 4'hb) begin
			valA = SEQ.register_file[4];
			valB = SEQ.register_file[4];
		end
	end
endmodule

module execute (clk, icode, ifun, valA, valB, valC, valE, Cnd);
	input clk;
	input [ 3:0] icode;
	input [ 3:0] ifun;
	input [63:0] valA;
	input [63:0] valB;
	input [63:0] valC;
	output wire [63:0] valE;
	output wire Cnd;

	reg [63:0] ALUA;
	reg [63:0] ALUB;
	reg [ 1:0] ALUfun;
	wire [ 2:0] CC = 3'b000;

	always @(posedge clk) begin
		if (icode == 4'h2) begin
			ALUA = valA;
			ALUB = 0;
			ALUfun = 2'b00;
		end
		else if (icode == 4'h3) begin
			ALUA = valC;
			ALUB = 0;
			ALUfun = 2'b00;
		end
		else if (icode == 4'h4) begin
			ALUA = valC;
			ALUB = valB;
			ALUfun = 2'b00;
		end
		else if (icode == 4'h5) begin
			ALUA = valC;
			ALUB = valB;
			ALUfun = 2'b00;
		end
		else if (icode == 4'h6) begin
			ALUA = valA;
			ALUB = valB;
			ALUfun =
			ifun == 4'b0000 ? 2'b00 :
			ifun == 4'b0001 ? 2'b01 :
			ifun == 4'b0010 ? 2'b10 :
			2'b11;
		end
		else if (icode == 4'h8) begin
			ALUA = -8;
			ALUB = valB;
			ALUfun = 2'b00;
		end
		else if (icode == 4'h9) begin
			ALUA = 8;
			ALUB = valB;
			ALUfun = 2'b00;
		end
		else if (icode == 4'ha) begin
			ALUA = -8;
			ALUB = valB;
			ALUfun = 2'b00;
		end
		else if (icode == 4'hb) begin
			ALUA = 8;
			ALUB = valB;
			ALUfun = 2'b00;
		end
	end

	wire [63:0] valE_ans;
	wire Cnd_ans;

	alu alu0 (ALUA, ALUB, ALUfun, valE_ans, CC);
	cond cond0 (ifun, CC, Cnd_ans);

	assign valE = valE_ans;
	assign Cnd = Cnd_ans;
endmodule

module cond (ifun, CC, Cnd);
	input [3:0] ifun;
	input [2:0] CC;
	output Cnd;

	parameter BRANCH_UNC = 4'h0; // Unconditional jump
	parameter BRANCH_LE  = 4'h1; // Jump if less than or equal
	parameter BRANCH_L   = 4'h2; // Jump if less than
	parameter BRANCH_E   = 4'h3; // Jump if equal
	parameter BRANCH_NE  = 4'h4; // Jump if not equal
	parameter BRANCH_GE  = 4'h5; // Jump if greater than or equal
	parameter BRANCH_G   = 4'h6; // Jump if greater than

	wire ZF = CC[2];
	wire SF = CC[1];
	wire OF = CC[0];

	assign Cnd =
	(ifun == BRANCH_UNC) |
	(ifun == BRANCH_LE & ((ZF ^ OF) | ZF)) |
	(ifun == BRANCH_L  & (SF ^ OF)) |
	(ifun == BRANCH_E  & ZF) |
	(ifun == BRANCH_NE & ~ZF) |
	(ifun == BRANCH_GE & (~SF ^ OF)) |
	(ifun == BRANCH_G  & (~SF ^ OF) & ~ZF);
endmodule

module alu (ALUA, ALUB, ALUfun, valE, CC);
	input  [63:0] ALUA;
	input  [63:0] ALUB;
	input  [ 1:0] ALUfun;
	output [63:0] valE;
	output [ 2:0] CC;

	wire [63:0] valE_addq, valE_subq, valE_andq, valE_xorq;

	addsub64bit addq (ALUB, ALUA, 1'b0, valE_addq);
	addsub64bit subq (ALUB, ALUA, 1'b1, valE_subq);
	and64bit    andq (ALUB, ALUA, valE_andq);
	xor64bit    xorq (ALUB, ALUA, valE_xorq);

	assign valE =
	ALUfun == 2'b00 ? valE_addq :
	ALUfun == 2'b01 ? valE_subq :
	ALUfun == 2'b10 ? valE_andq :
	valE_xorq;

	assign CC[2] = (valE == 1'b0); // ZF
	assign CC[1] = (valE[63] == 1); // SF
	assign CC[0] =
	ALUfun == 2'b00 ? (ALUA[63] == ALUB[63]) & (ALUA[63] != valE[63]) :
	ALUfun == 2'b01 ? (~ALUA[63] == ALUB[63]) & (ALUA[63] != valE[63]) :
	0; // OF
endmodule

module fulladder (in1, in2, cin, sum, cout);
	input  in1;
	input  in2;
	input  cin;
	output sum;
	output cout;

	wire w1, w2, w3;

	xor x1 (w1, in1, in2);	
	and x2 (w2, in1, in2);	
	xor x3 (sum, cin, w1);
	and x4 (w3, cin, w1);	
	or  x5 (cout, w2, w3);
endmodule

module addsub64bit (in1, in2, op, out);
	input  signed [63:0] in1;
	input  signed [63:0] in2;
	input  op;
	output signed [63:0] out;

	wire [63:0] nin2;
	wire [64:0] carry;
	assign carry[0] = op;

	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin
			xor x1 (nin2[i], in2[i], op);
		end
	endgenerate

	genvar j;
	generate
		for (j = 0; j < 64; j = j + 1) begin
			fulladder x2 (in1[j], nin2[j], carry[j], out[j], carry[j + 1]);
		end
	endgenerate
endmodule

module and64bit (in1, in2, out);
	input  signed [63:0] in1;
	input  signed [63:0] in2;
	output signed [63:0] out;

	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin
			and x1 (out[i], in1[i], in2[i]);
		end
	endgenerate
endmodule

module xor64bit (in1, in2, out);
	input  signed [63:0] in1;
	input  signed [63:0] in2;
	output signed [63:0] out;

	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin
			xor x1 (out[i], in1[i], in2[i]);
		end
	endgenerate
endmodule

module memory (clk, icode, valA, valE, valP, valM, dmem_error);
	input clk;
	input [ 3:0] icode;
	input [63:0] valA;
	input [63:0] valE;
	input [63:0] valP;
	output reg [63:0] valM;
	output reg dmem_error;

	initial begin
		valM = 64'd0;
		dmem_error = 1'b0;
	end

	reg mem_read;
	reg mem_write;
	reg [63:0] mem_data;
	reg [63:0] mem_addr;
	initial begin
		mem_read = 1'b0;
		mem_write = 1'b0;
		mem_data = 64'd0;
		mem_addr = 64'd0;
	end

	always @(posedge clk) begin
		if (icode == 4'h4) begin
			mem_write = 1;
			mem_read = 0;	
			mem_data = valA;
			mem_addr = valE;
		end
		else if (icode == 4'h5) begin
			mem_write = 0;
			mem_read = 1;
			mem_addr = valE;
		end
		else if (icode == 4'h8) begin
			mem_write = 1;
			mem_read = 0;
			mem_data = valP;
			mem_addr = valE;
		end
		else if (icode == 4'h9) begin
			mem_write = 0;
			mem_read = 1;
			mem_addr = valA;
		end
		else if (icode == 4'ha) begin
			mem_write = 1;
			mem_read = 0;
			mem_data = valA;
			mem_addr = valE;
		end
		else if (icode == 4'hb) begin
			mem_write = 0;
			mem_read = 1;
			mem_addr = valA;
		end

		if (mem_addr > 2047) begin
			dmem_error = 1'b1;
		end
		if (mem_write && !mem_read) begin
			SEQ.d_mem[mem_addr] = mem_data;
		end
		else if (!mem_write && mem_read) begin
			valM = SEQ.d_mem[mem_addr];
		end
	end
endmodule

module writeback (clk, icode, rA, rB, valE, valM, Cnd, dstE, dstM);
	input clk;
	input [ 3:0] icode;
	input [ 3:0] rA;
	input [ 3:0] rB;
	input [63:0] valE;
	input [63:0] valM;
	input Cnd;
	output reg [3:0] dstE = 4'hf;
	output reg [3:0] dstM = 4'hf;

	always @(posedge clk) begin
		if ((icode == 4'h2 && Cnd == 1) || icode == 4'h3 || icode == 4'h6) begin
			dstE = rB;
			SEQ.register_file[dstE] = valE;
		end
		else if (icode == 4'h5) begin
			dstM = rA;
			SEQ.register_file[dstM] = valM;
		end
		else if (icode == 4'h8 || icode == 4'h9 || icode == 4'ha || icode == 4'hb) begin
			dstE = 4'h4;
			SEQ.register_file[dstE] = valE;
		end
	end
endmodule

module pcupdate (clk, PC, icode, Cnd, valC, valM, valP, new_PC);
	input clk;
	input [63:0] PC;
	input [ 3:0] icode;
	input Cnd;
	input [63:0] valC;
	input [63:0] valM;
	input [63:0] valP;
	output reg [63:0] new_PC;
	
	always @(posedge clk) begin
		if(icode == 4'h7) begin
			new_PC = Cnd == 1 ? valC : valP;
		end
		else if (icode == 4'h8) begin
			new_PC = valC;
		end
		else if(icode == 4'h9) begin
			new_PC = valM;
		end
		else begin
			new_PC = valP;
		end
	end
endmodule