`include "addsub/addsub_func.v"
`include "and/and_func.v"
`include "xor/xor_func.v"

module alu(ALUA, ALUB, ALUfun, valE, CC);
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