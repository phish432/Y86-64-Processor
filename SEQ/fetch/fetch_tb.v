`timescale 1ns / 1ps

module fetch_tb;
	reg clk;
	reg [63:0] PC;
	output [ 3:0] icode;
	output [ 3:0] ifun;
	output [ 3:0] rA;
	output [ 3:0] rB;
	output [63:0] valC;
	output [63:0] valP;
	output hlt;
	output imem_error;
	output instr_valid;

	fetch uut (clk, PC, icode, ifun, rA, rB, valC, valP, hlt, imem_error, instr_valid);

	initial begin
		$dumpfile("fetch_tb.vcd");
		$dumpvars(0, fetch_tb);

		clk = 0;
		PC = 0;

		#20 $finish;
	end

	always begin
		#10 clk = ~clk;
	end

	always @(posedge clk) begin
		$monitor($time, " icode = %h, ifun = %h\n\t\t     rA = %h\n\t\t     rB = %h\n\t\t     valC = %h\n\t\t     valP = %h\n\t\t     hlt = %d, imem_error = %d, instr_valid = %d\n", icode, ifun, rA, rB, valC, valP, hlt, imem_error, instr_valid);
	end
endmodule