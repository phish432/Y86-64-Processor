module addsub_tb;

	reg signed [63:0] in1;
	reg signed [63:0] in2;
	reg op;
	output signed [63:0] out;

	addsub64bit uut (in1, in2, op, out);

	initial begin
		$dumpfile("addsub_tb.vcd");
		$dumpvars(0, addsub_tb);

		$monitor($time, " op = %d, in1 = %d, in2 = %d, out = %d", op, in1, in2, out);

		op = 2'b00; in1 = 64'b0; in2 = 64'b0;
		#20 op = 2'b00; in1 =  64'b101101; in2 =  64'b100110;
		#20 op = 2'b00; in1 = -64'b101101; in2 =  64'b100110;
		#20 op = 2'b00; in1 =  64'b101101; in2 = -64'b100110;
		#20 op = 2'b00; in1 = -64'b101101; in2 = -64'b100110;
		#20 op = 2'b01; in1 =  64'b101101; in2 =  64'b100110;
		#20 op = 2'b01; in1 = -64'b101101; in2 =  64'b100110;
		#20 op = 2'b01; in1 =  64'b101101; in2 = -64'b100110;
		#20 op = 2'b01; in1 = -64'b101101; in2 = -64'b100110;
		#20 op = 2'b00; in1 =  64'd9223372036854775807; in2 =  64'd1;
		#20 op = 2'b01; in1 =  64'd9223372036854775807; in2 = -64'd1;
		#20 op = 2'b00; in1 = -64'd9223372036854775808; in2 = -64'd1;
		#20 op = 2'b01; in1 = -64'd9223372036854775808; in2 =  64'd1;

		$finish;
	end

endmodule