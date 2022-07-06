`timescale  1ns / 1ps

`include "reg.v"

module PIPEm;
	reg clk;
	reg [63:0] PC;

	wire [63:0] new_pc;
	wire [63:0] f_pc;

	wire [2:0]  f_stat;
	wire [3:0]  f_icode;
	wire [3:0]  f_ifun; 
	wire [3:0]  f_rA;
	wire [3:0]  f_rB;
	wire [63:0] f_valC;
	wire [63:0] f_valP;
	
	wire [2:0]  d_stat;
	wire [3:0]  d_icode;
	wire [3:0]  d_ifun;
	wire [3:0]  d_rA;
	wire [3:0]  d_rB;
	wire [63:0] d_valC;
	wire [63:0] d_valP;
	wire [63:0] d_valA;
	wire [63:0] d_valB;
	wire [ 3:0] d_dstE;
	wire [ 3:0] d_dstM;
	wire [ 3:0] d_srcA;
	wire [ 3:0] d_srcB;

	wire [2:0]  e_stat;
	wire [3:0]  e_icode;
	wire [3:0]  e_ifun;
	wire        e_Cnd;
	wire [63:0] e_valC;
	wire [63:0] e_valA;
	wire [63:0] e_valB;
	wire [63:0] e_valE;
	wire [ 3:0] e_dstE;
	wire [ 3:0] e_dstM;
	wire [ 3:0] e_srcA;
	wire [ 3:0] e_srcB;


	wire [2:0]  m_stat;
	wire [3:0]  m_icode;
	wire        m_Cnd;
	wire [63:0] m_valA;
	wire [63:0] m_valE;
	wire [63:0] m_valM;
	wire [ 3:0] m_dstE;
	wire [ 3:0] m_dstM;
	
	wire [2:0]  w_stat;
	wire [3:0]  w_icode;
	wire        w_cnd;
	wire [3:0]  w_rA;
	wire [3:0]  w_rB;
	wire [63:0] w_valC;
	wire [63:0] w_valP;
	wire [63:0] w_valA;
	wire [63:0] w_valB;
	wire [63:0] w_valE;
	wire [63:0] w_valM;

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

		// 30 f0 0c 00 00 00 00 00 00 00 | irmovq $12, %rcx
		i_mem[10] = 8'h30;
		i_mem[11] = 8'hf1;
		i_mem[12] = 8'h0c;
		i_mem[13] = 8'h00;
		i_mem[14] = 8'h00;
		i_mem[15] = 8'h00;
		i_mem[16] = 8'h00;
		i_mem[17] = 8'h00;
		i_mem[18] = 8'h00;
		i_mem[19] = 8'h00;

		// 30 f0 0c 00 00 00 00 00 00 00 | irmovq $12, %rcx
		i_mem[20] = 8'h30;
		i_mem[21] = 8'hf1;
		i_mem[22] = 8'h0c;
		i_mem[23] = 8'h00;
		i_mem[24] = 8'h00;
		i_mem[25] = 8'h00;
		i_mem[26] = 8'h00;
		i_mem[27] = 8'h00;
		i_mem[28] = 8'h00;
		i_mem[29] = 8'h00;

		// nop
		i_mem[30] = 8'h00;
		i_mem[31] = 8'h00;
		i_mem[32] = 8'h00;

		// 00 | halt
		i_mem[33] = 8'h00;
		// // ff | INVALID
		// i_mem[11] = 8'hff;
	end

	fetch     fetch_stage     (clk, f_pc, f_icode, f_ifun, f_rA, f_rB, f_valC, f_valP, hlt, imem_error, instr_valid);
	decode    decode_stage    (clk, d_icode, d_rA, d_rB, e_valA, e_valB);
	execute   execute_stage   (clk, e_icode, e_ifun, e_valA, e_valB, e_valC, m_valE, m_Cnd);
	memory    memory_stage    (clk, m_icode, m_valA, m_valE, m_valP, w_valM, dmem_error);
	writeback writeback_stage (clk, w_icode, d_rA, d_rB, w_valE, w_valM, e_Cnd, e_dstE, e_dstM);
	pcupdate  pcupdate_stage  (clk, f_pc, w_icode, w_Cnd, w_valC, w_valM, f_valP, new_PC);

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

module fetch (clk, f_pc, f_icode, f_ifun, f_rA, f_rB, f_valC, f_valP, hlt, imem_error, instr_valid);
	input clk;
	input [63:0] f_pc;
	output reg [ 3:0] f_icode;
	output reg [ 3:0] f_ifun;
	output reg [ 3:0] f_rA;
	output reg [ 3:0] f_rB;
	output reg [63:0] f_valC;
	output reg [63:0] f_valP;
	output reg hlt;
	output reg imem_error;
	output reg instr_valid;

	initial begin
		f_rA = 4'hf;
		f_rB = 4'hf;
		f_valC = 64'd0;
		f_valP = 64'd0;
		hlt = 0;
		imem_error = 0;
		instr_valid = 1;
	end

	reg [7:0] opcode;
	reg [7:0] regids;

	always @(posedge clk) begin
		if (f_pc > 1023) begin
			imem_error = 1;
		end

		opcode = PIPEm.i_mem[f_pc];
		f_icode = opcode[7:4];
		f_ifun = opcode[3:0];

		if (f_icode == 4'h0) begin
			hlt = 1;
			f_valP = f_pc + 1;
		end
		else if (f_icode == 4'h1) begin
			f_valP = f_pc + 1;
		end
		else if (f_icode == 4'h2) begin
			regids = PIPEm.i_mem[f_pc + 1];
			f_rA = regids[7:4];
			f_rB = regids[3:0];
			f_valP = f_pc + 2;
		end
		else if (f_icode == 4'h3) begin
			regids = PIPEm.i_mem[f_pc + 1];
			f_rA = regids[7:4];
			f_rB = regids[3:0];
			f_valC = {
			    PIPEm.i_mem[f_pc + 9],
			    PIPEm.i_mem[f_pc + 8],
			    PIPEm.i_mem[f_pc + 7],
			    PIPEm.i_mem[f_pc + 6],
			    PIPEm.i_mem[f_pc + 5],
			    PIPEm.i_mem[f_pc + 4],
			    PIPEm.i_mem[f_pc + 3],
			    PIPEm.i_mem[f_pc + 2]
			};
			f_valP = f_pc + 10;
		end
		else if (f_icode == 4'h4) begin
			regids = PIPEm.i_mem[f_pc + 1];
			f_rA = regids[7:4];
			f_rB = regids[3:0];
			f_valC = {
			    PIPEm.i_mem[f_pc + 9],
			    PIPEm.i_mem[f_pc + 8],
			    PIPEm.i_mem[f_pc + 7],
			    PIPEm.i_mem[f_pc + 6],
			    PIPEm.i_mem[f_pc + 5],
			    PIPEm.i_mem[f_pc + 4],
			    PIPEm.i_mem[f_pc + 3],
			    PIPEm.i_mem[f_pc + 2]
			};
			f_valP = f_pc + 10;
		end
		else if (f_icode == 4'h5) begin
			regids = PIPEm.i_mem[f_pc + 1];
			f_rA = regids[7:4];
			f_rB = regids[3:0];
			f_valC = {
			    PIPEm.i_mem[f_pc + 9],
			    PIPEm.i_mem[f_pc + 8],
			    PIPEm.i_mem[f_pc + 7],
			    PIPEm.i_mem[f_pc + 6],
			    PIPEm.i_mem[f_pc + 5],
			    PIPEm.i_mem[f_pc + 4],
			    PIPEm.i_mem[f_pc + 3],
			    PIPEm.i_mem[f_pc + 2]
			};
			f_valP = f_pc + 10;
		end
		else if (f_icode == 4'h6) begin
			regids = PIPEm.i_mem[f_pc + 1];
			f_rA = regids[7:4];
			f_rB = regids[3:0];
			f_valP = f_pc + 2;
		end
		else if (f_icode == 4'h7) begin
			f_valC = {
			    PIPEm.i_mem[f_pc + 8],
			    PIPEm.i_mem[f_pc + 7],
			    PIPEm.i_mem[f_pc + 6],
			    PIPEm.i_mem[f_pc + 5],
			    PIPEm.i_mem[f_pc + 4],
			    PIPEm.i_mem[f_pc + 3],
			    PIPEm.i_mem[f_pc + 2],
			    PIPEm.i_mem[f_pc + 1]
			};
			f_valP = f_pc + 9;
		end
		else if (f_icode == 4'h8) begin
			f_valC = {
			    PIPEm.i_mem[f_pc + 8],
			    PIPEm.i_mem[f_pc + 7],
			    PIPEm.i_mem[f_pc + 6],
			    PIPEm.i_mem[f_pc + 5],
			    PIPEm.i_mem[f_pc + 4],
			    PIPEm.i_mem[f_pc + 3],
			    PIPEm.i_mem[f_pc + 2],
			    PIPEm.i_mem[f_pc + 1]
			};
			f_valP = f_pc + 9;		
		end
		else if (f_icode == 4'h9) begin
			f_valP = f_pc + 1;
		end
		else if (f_icode == 4'ha) begin
			regids = PIPEm.i_mem[f_pc + 1];
			f_rA = regids[7:4];
			f_rB = regids[3:0];
			f_valP = f_pc + 2;
		end
		else if (f_icode == 4'hb) begin
			regids = PIPEm.i_mem[f_pc + 1];
			f_rA = regids[7:4];
			f_rB = regids[3:0];
			f_valP = f_pc + 2;
		end
		else begin
			instr_valid = 0;
		end
	end
endmodule

module decode (clk, d_icode, d_rA, d_rB, e_valA, e_valB);
	input clk;
	input [3:0] d_icode;	
	input [3:0] d_rA;
	input [3:0] d_rB;
	output reg [63:0] e_valA;
	output reg [63:0] e_valB;

	initial begin
		e_valA = 64'd0;
		e_valB = 64'd0;
	end

	always @(posedge clk) begin
		if (d_icode == 4'h2) begin
			e_valA = PIPEm.register_file[d_rA];
		end
		else if(d_icode == 4'h3) begin
			e_valB = PIPEm.register_file[d_rB];
		end
		else if(d_icode == 4'h4) begin
			e_valA = PIPEm.register_file[d_rA];
			e_valB = PIPEm.register_file[d_rB];
		end
		else if(d_icode == 4'h5) begin
			e_valB = PIPEm.register_file[d_rB];
		end
		else if(d_icode == 4'h6) begin
			e_valA = PIPEm.register_file[d_rA];
			e_valB = PIPEm.register_file[d_rB];
		end
		else if(d_icode == 4'h8) begin
			e_valB = PIPEm.register_file[4];
		end
		else if(d_icode == 4'h9) begin
			e_valA = PIPEm.register_file[4];
			e_valB = PIPEm.register_file[4];
		end
		else if(d_icode == 4'ha) begin
			e_valA = PIPEm.register_file[d_rA];
			e_valB = PIPEm.register_file[4];
		end
		else if(d_icode == 4'hb) begin
			e_valA = PIPEm.register_file[4];
			e_valB = PIPEm.register_file[4];
		end
	end
endmodule

module execute (clk, e_icode, e_ifun, e_valA, e_valB, e_valC, m_valE, m_Cnd);
	input clk;
	input [ 3:0] e_icode;
	input [ 3:0] e_ifun;
	input [63:0] e_valA;
	input [63:0] e_valB;
	input [63:0] e_valC;
	output wire [63:0] m_valE;
	output wire m_Cnd;

	reg [63:0] ALUA;
	reg [63:0] ALUB;
	reg [ 1:0] ALUfun;
	wire [ 2:0] CC = 3'b000;

	always @(posedge clk) begin
		if (e_icode == 4'h2) begin
			ALUA = e_valA;
			ALUB = 0;
			ALUfun = 2'b00;
		end
		else if (e_icode == 4'h3) begin
			ALUA = e_valC;
			ALUB = 0;
			ALUfun = 2'b00;
		end
		else if (e_icode == 4'h4) begin
			ALUA = e_valC;
			ALUB = e_valB;
			ALUfun = 2'b00;
		end
		else if (e_icode == 4'h5) begin
			ALUA = e_valC;
			ALUB = e_valB;
			ALUfun = 2'b00;
		end
		else if (e_icode == 4'h6) begin
			ALUA = e_valA;
			ALUB = e_valB;
			ALUfun =
			e_ifun == 4'b0000 ? 2'b00 :
			e_ifun == 4'b0001 ? 2'b01 :
			e_ifun == 4'b0010 ? 2'b10 :
			2'b11;
		end
		else if (e_icode == 4'h8) begin
			ALUA = -8;
			ALUB = e_valB;
			ALUfun = 2'b00;
		end
		else if (e_icode == 4'h9) begin
			ALUA = 8;
			ALUB = e_valB;
			ALUfun = 2'b00;
		end
		else if (e_icode == 4'ha) begin
			ALUA = -8;
			ALUB = e_valB;
			ALUfun = 2'b00;
		end
		else if (e_icode == 4'hb) begin
			ALUA = 8;
			ALUB = e_valB;
			ALUfun = 2'b00;
		end
	end

	wire [63:0] valE_ans;
	wire Cnd_ans;

	alu alu0 (ALUA, ALUB, ALUfun, valE_ans, CC);
	cond cond0 (e_ifun, CC, Cnd_ans);

	assign m_valE = valE_ans;
	assign m_Cnd = Cnd_ans;
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

module memory (clk, m_icode, m_valA, m_valE, m_valP, w_valM, dmem_error);
	input clk;
	input [ 3:0] m_icode;
	input [63:0] m_valA;
	input [63:0] m_valE;
	input [63:0] m_valP;
	output reg [63:0] w_valM;
	output reg dmem_error;

	initial begin
		w_valM = 64'd0;
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
		if (m_icode == 4'h4) begin
			mem_write = 1;
			mem_read = 0;	
			mem_data = m_valA;
			mem_addr = m_valE;
		end
		else if (m_icode == 4'h5) begin
			mem_write = 0;
			mem_read = 1;
			mem_addr = m_valE;
		end
		else if (m_icode == 4'h8) begin
			mem_write = 1;
			mem_read = 0;
			mem_data = m_valP;
			mem_addr = m_valE;
		end
		else if (m_icode == 4'h9) begin
			mem_write = 0;
			mem_read = 1;
			mem_addr = m_valA;
		end
		else if (m_icode == 4'ha) begin
			mem_write = 1;
			mem_read = 0;
			mem_data = m_valA;
			mem_addr = m_valE;
		end
		else if (m_icode == 4'hb) begin
			mem_write = 0;
			mem_read = 1;
			mem_addr = m_valA;
		end

		if (mem_addr > 2047) begin
			dmem_error = 1'b1;
		end
		if (mem_write && !mem_read) begin
			PIPEm.d_mem[mem_addr] = mem_data;
		end
		else if (!mem_write && mem_read) begin
			w_valM = PIPEm.d_mem[mem_addr];
		end
	end
endmodule

module writeback (clk, w_icode, d_rA, d_rB, w_valE, w_valM, e_Cnd, e_dstE, e_dstM);
	input clk;
	input [ 3:0] w_icode;
	input [ 3:0] d_rA;
	input [ 3:0] d_rB;
	input [63:0] w_valE;
	input [63:0] w_valM;
	input e_Cnd;
	output reg [3:0] e_dstE = 4'hf;
	output reg [3:0] e_dstM = 4'hf;

	always @(posedge clk) begin
		if ((w_icode == 4'h2 && e_Cnd == 1) || w_icode == 4'h3 || w_icode == 4'h6) begin
			e_dstE = d_rB;
			PIPEm.register_file[e_dstE] = w_valE;
		end
		else if (w_icode == 4'h5) begin
			e_dstM = d_rA;
			PIPEm.register_file[e_dstM] = w_valM;
		end
		else if (w_icode == 4'h8 || w_icode == 4'h9 || w_icode == 4'ha || w_icode == 4'hb) begin
			e_dstE = 4'h4;
			PIPEm.register_file[e_dstE] = w_valE;
		end
	end
endmodule

module pcupdate (clk, f_pc, w_icode, w_Cnd, w_valC, w_valM, f_valP, new_PC);
	input clk;
	input [63:0] f_pc;
	input [ 3:0] w_icode;
	input w_Cnd;
	input [63:0] w_valC;
	input [63:0] w_valM;
	input [63:0] f_valP;
	output reg [63:0] new_PC;
	
	always @(posedge clk) begin
		if(w_icode == 4'h7) begin
			new_PC = w_valC;
		end
		else if (w_icode == 4'h8) begin
			new_PC = w_valC;
		end
		else if(w_icode == 4'h9) begin
			new_PC = w_valM;
		end
		else begin
			new_PC = f_valP;
		end
	end
endmodule