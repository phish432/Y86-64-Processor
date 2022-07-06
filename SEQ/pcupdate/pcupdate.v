module pcupdate (clk, PC, icode, Cnd, valC, valM, valP, new_PC);
	input clk,
	input [63:0] PC;
	input [ 3:0] icode;
	input Cnd;
	input [63:0] valC;
	input [63:0] valM;
	input [63:0] valP;
	output reg [63:0] new_PC;
	
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

	// PC Update Stage
	always @(posedge clk) begin
		if(icode == IJXX) begin
			new_PC = Cnd == 1 ? valC : valP;
		end
		else if (icode == ICALL) begin
			new_PC = valC;
		end
		else if(icode == IRET) begin
			new_PC = valM;
		end
		else begin
			new_pc = valP;
		end
	end
endmodule