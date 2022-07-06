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