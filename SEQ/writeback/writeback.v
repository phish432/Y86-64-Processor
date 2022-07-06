module writeback (clk, icode, rA, rB, valA, valB, valE, valM, Cnd, dstE, dstM);
	// Ports
	input clk;
	input [ 3:0] icode;
	input [ 3:0] rA;
	input [ 3:0] rB;
	input [63:0] valA;
	input [63:0] valB;
	input [63:0] valE;
	input [63:0] valM;
	input Cnd;

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

	// Register File
	parameter RRAX = 4'h0
	parameter RRCX = 4'h1
	parameter RRDX = 4'h2
	parameter RRBX = 4'h3
	parameter RRSP = 4'h4
	parameter RRBP = 4'h5
	parameter RRSI = 4'h6
	parameter RRDI = 4'h7
	parameter R8   = 4'h8
	parameter R9   = 4'h9
	parameter R10  = 4'ha
	parameter R11  = 4'hb
	parameter R12  = 4'hc
	parameter R13  = 4'hd
	parameter R14  = 4'he

	// Register File
	reg [63:0] register_file[0:14];

	// Write-Back Stage
	reg [3:0] dstE = 4'hf;
	reg [3:0] dstM = 4'hf;

	always @(posedge clk) begin
		if ((icode == ICMOVXX && Cnd == 1) || icode == IRMMOVQ || icode == IOPQ) begin
			dstE = rB;
			register_file[dstE] = valE;
		end
		else if (icode == IMRMOVQ) begin
			dstM = rA;
			register_file[dstM] = valM;
		end
		else if (icode == ICALL || icode == IRET || icode == IPUSHQ || icode == IPOPQ) begin
			dstE = RRSP;
			register_file[dstE] = valE;
		end
	end
endmodule