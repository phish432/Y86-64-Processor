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