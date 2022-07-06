module decode(clk, icode, rA, rB, valA, valB);
	// Ports
	input clk;
	input [3:0] icode;
	input [3:0] rA;
	input [3:0] rB;
	output reg [63:0] valA;
	output reg [63:0] valB;

	initial begin
		valA = 64'd0;
		valB = 64'd0;
	end

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
	parameter RRAX = 4'h0;
	parameter RRCX = 4'h1;
	parameter RRDX = 4'h2;
	parameter RRBX = 4'h3;
	parameter RRSP = 4'h4;
	parameter RRBP = 4'h5;
	parameter RRSI = 4'h6;
	parameter RRDI = 4'h7;
	parameter R8   = 4'h8;
	parameter R9   = 4'h9;
	parameter R10  = 4'ha;
	parameter R11  = 4'hb;
	parameter R12  = 4'hc;
	parameter R13  = 4'hd;
	parameter R14  = 4'he;

	reg [63:0] register_file[0:14];
	initial begin
		register_file[RRAX] = 64'd0;
		register_file[RRCX] = 64'd1;
		register_file[RRDX] = 64'd2;
		register_file[RRBX] = 64'd3;
		register_file[RRSP] = 64'd4;
		register_file[RRBP] = 64'd5;
		register_file[RRSI] = 64'd6;
		register_file[RRDI] = 64'd7;
		register_file[R8]   = 64'd8;
		register_file[R9]   = 64'd9;
		register_file[R10]  = 64'd10;
		register_file[R11]  = 64'd11;
		register_file[R12]  = 64'd12;
		register_file[R13]  = 64'd13;
		register_file[R14]  = 64'd14;
	end

	// Decode Stage
	always @(posedge clk) begin
		if (icode == ICMOVXX) begin
			valA = register_file[rA];
		end
		else if(icode == IIRMOVQ) begin
			valB = register_file[rB];
		end
		else if(icode == IRMMOVQ) begin
			valA = register_file[rA];
			valB = register_file[rB];
		end
		else if(icode == IMRMOVQ) begin
			valB = register_file[rB];
		end
		else if(icode == IOPQ) begin
			valA = register_file[rA];
			valB = register_file[rB];
		end
		else if(icode == ICALL) begin
			valB = register_file[4];
		end
		else if(icode == IRET) begin
			valA = register_file[4];
			valB = register_file[4];
		end
		else if(icode == IPUSHQ) begin
			valA = register_file[rA];
			valB = register_file[4];
		end
		else if(icode == IPOPQ) begin
			valA = register_file[4];
			valB = register_file[4];
		end
	end
endmodule