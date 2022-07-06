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