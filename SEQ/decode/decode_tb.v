`timescale 1ns / 1ps

module decode_tb;
	reg clk;
	reg [3:0] icode;
	reg [3:0] rA;
	reg [3:0] rB;
	output [63:0] valA;
	output [63:0] valB;

	decode uut (clk, icode, rA, rB, valA, valB);

	initial begin
		$dumpfile("decode_tb.vcd");
		$dumpvars(0, decode_tb);

		clk = 1'b0;

		#10 clk = ~clk;
		icode = 4'b0010; rA = 4'b0010; rB = 4'b0010;
		#10 clk = ~clk;

		#10 clk = ~clk;
		icode = 4'b0011; rA = 4'b0000; rB = 4'b1000;
		#10 clk = ~clk;

		#10 clk = ~clk;
		icode = 4'b0100; rA = 4'b1100; rB = 4'b0101;
		#10 clk = ~clk;

		#10 clk = ~clk;
		icode = 4'b0101; rA = 4'b1110; rB = 4'b1001;
		#10 clk = ~clk;

		#10 clk = ~clk;
		icode = 4'b0110; rA = 4'b0011; rB = 4'b0001;
		#10 clk = ~clk;

		#10 clk = ~clk;
		icode = 4'b1000; rA = 4'b0000; rB = 4'b1110;
		#10 clk = ~clk;

		#10 clk = ~clk;
		icode = 4'b1001; rA = 4'b0100; rB = 4'b1001;
		#10 clk = ~clk;

		#10 clk = ~clk;
		icode = 4'b1010; rA = 4'b0101; rB = 4'b1101;
		#10 clk = ~clk;

		#10 clk = ~clk;
		icode = 4'b1011; rA = 4'b0000; rB = 4'b0000;
		#10 clk = ~clk;
	end

	initial begin
		$monitor($time, " clk = %d icode = %b rA = %b rB = %b valA = %g valB = %g\n", clk,icode, rA, rB, valA, valB);
	end
endmodule