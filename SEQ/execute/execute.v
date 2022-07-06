`include "alu.v"

module execute (clk, icode, ifun, valA, valB, valC, valE, Cnd);
	// Ports
	input clk;
	input [ 3:0] icode;
	input [ 3:0] ifun;
	input [63:0] valA;
	input [63:0] valB;
	input [63:0] valC;
	output reg [63:0] valE;
	output reg Cnd;

	initial begin
		valE = 64'd0;
		Cnd = 1'b0;
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

	// Condition Codes 2 -> ZF, 1 -> SF, 0 -> OF
	reg [2:0] CC;
	initial begin
		CC = 3'b000;
	end

	// ALU Control
	always @(posedge clk) begin
		if (icode == ICMOVXX) begin
			ALUA = valA;
			ALUB = 0;
			ALUfun = 2'b00;
		end
		else if (icode == IIRMOVQ) begin
			ALUA = valC;
			ALUB = 0;
			ALUfun = 2'b00;
		end
		else if (icode == IRMMOVQ) begin
			ALUA = valC;
			ALUB = valB;
			ALUfun = 2'b00;
		end
		else if (icode == IMRMOVQ) begin
			ALUA = valC;
			ALUB = valB;
			ALUfun = 2'b00;
		end
		else if (icode == IOPQ) begin
			ALUA = valA;
			ALUB = valB;
			ALUfun =
			ifun == 4'b0000 ? 2'b00 :
			ifun == 4'b0001 ? 2'b01 :
			ifun == 4'b0010 ? 2'b10 :
			2'b11;
		end
		else if (icode == ICALL) begin
			ALUA = -8;
			ALUB = valB;
			ALUfun = 2'b00;
		end
		else if (icode == IRET) begin
			ALUA = 8;
			ALUB = valB;
			ALUfun = 2'b00;
		end
		else if (icode == IPUSHQ) begin
			ALUA = -8;
			ALUB = valB;
			ALUfun = 2'b00;
		end
		else if (icode == IPOPQ) begin
			ALUA = 8;
			ALUB = valB;
			ALUfun = 2'b00;
		end

		alu alu0 (ALUA, ALUB, ALUfun, valE, CC);
		cond cond0 (ifun, CC, Cnd);
	end
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