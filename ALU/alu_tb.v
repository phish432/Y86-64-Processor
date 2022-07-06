`timescale 1ns / 1ps

module alu_tb;
	reg signed    [63:0] ALUA;
	reg signed    [63:0] ALUB;
	reg           [ 1:0] ALUfun;
	output signed [63:0] valE;
	output        [ 2:0] CC;

	alu uut (ALUA, ALUB, ALUfun, valE, CC);

	initial begin
		$dumpfile("alu_tb.vcd");
		$dumpvars(0, alu_tb);

		$monitor($time, " ALUfun = %b\n\t\t     ALUA = %b = %d\n\t\t     ALUB = %b = %d\n\t\t     valE = %b = %d\n\t\t     OF = %d, SF = %d, ZF = %d\n", ALUfun, ALUA, ALUA, ALUB, ALUB, valE, valE, CC[0], CC[1], CC[2]);

		ALUfun = 2'b00; ALUA = 64'b0; ALUB = 64'b0;
		#20 ALUfun = 2'b00; ALUA =  64'b101101; ALUB =  64'b100110;
		#20 ALUfun = 2'b01; ALUA =  64'b101101; ALUB =  64'b100110;
		#20 ALUfun = 2'b10; ALUA =  64'b101101; ALUB =  64'b100110;
		#20 ALUfun = 2'b11; ALUA =  64'b101101; ALUB =  64'b100110;
		#20 ALUfun = 2'b00; ALUA = -64'b101101; ALUB =  64'b100110;
		#20 ALUfun = 2'b01; ALUA = -64'b101101; ALUB =  64'b100110;
		#20 ALUfun = 2'b10; ALUA = -64'b101101; ALUB =  64'b100110;
		#20 ALUfun = 2'b11; ALUA = -64'b101101; ALUB =  64'b100110;
		#20 ALUfun = 2'b00; ALUA =  64'b101101; ALUB = -64'b100110;
		#20 ALUfun = 2'b01; ALUA =  64'b101101; ALUB = -64'b100110;
		#20 ALUfun = 2'b10; ALUA =  64'b101101; ALUB = -64'b100110;
		#20 ALUfun = 2'b11; ALUA =  64'b101101; ALUB = -64'b100110;
		#20 ALUfun = 2'b00; ALUA = -64'b101101; ALUB = -64'b100110;
		#20 ALUfun = 2'b01; ALUA = -64'b101101; ALUB = -64'b100110;
		#20 ALUfun = 2'b10; ALUA = -64'b101101; ALUB = -64'b100110;
		#20 ALUfun = 2'b11; ALUA = -64'b101101; ALUB = -64'b100110;
		#20 ALUfun = 2'b00; ALUA =  64'd9223372036854775807; ALUB =  64'd1;
		#20 ALUfun = 2'b01; ALUA =  64'd9223372036854775807; ALUB = -64'd1;

		$finish;
	end
endmodule