module memory (clk, icode, valA, valE, valP, valM, dmem_error);
	// Ports
	input clk;
	input [ 3:0] icode;
	input [63:0] valA;
	input [63:0] valE;
	input [63:0] valP;
	output reg [63:0] valM;
	output dmem_error;

	initial begin
		valE = 64'd0;
		dmem_error = 1'b0;
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

	// Data Memory
	reg [63:0] d_mem [2047:0];
	initial begin
		d_mem[0] = 64'd0;
		d_mem[1] = 64'd1;
		d_mem[2] = 64'd2;
		d_mem[3] = 64'd3;
		d_mem[4] = 64'd4;
		d_mem[5] = 64'd5;
		d_mem[6] = 64'd6;
		d_mem[7] = 64'd7;
		d_mem[8] = 64'd8;
		d_mem[9] = 64'd9;
		d_mem[10] = 64'd10;
		d_mem[11] = 64'd11;
		d_mem[12] = 64'd12;
		d_mem[13] = 64'd13;
		d_mem[14] = 64'd14;
		d_mem[15] = 64'd15;
	end

	// Memory Stage
	reg mem_read;
	reg mem_write;
	reg [63:0] mem_data;
	reg [63:0] mem_addr;
	initial begin
		mem_read = 1'b0;
		mem_write = 1'b0;
		mem_data = 64'd0;
		mem_addr = 64'd0;
	end

	always @(posedge clk) begin
		if (icode == IRMMOVQ) begin
			mem_write = 1;
			mem_read = 0;	
			mem_data = valA;
			mem_addr = valE;
		end
		else if (icode == IMRMOVQ) begin
			mem_write = 0;
			mem_read = 1;
			mem_addr = valE;
		end
		else if (icode == ICALL) begin
			mem_write = 1;
			mem_read = 0;
			mem_data = valP;
			mem_addr = valE;
		end
		else if (icode == IRET) begin
			mem_write = 0;
			mem_read = 1;
			mem_addr = valA;
		end
		else if (icode == IPUSHQ) begin
			mem_write = 1;
			mem_read = 0;
			mem_data = valA;
			mem_addr = valE;
		end
		else if (icode == IPOPQ) begin
			mem_write = 0;
			mem_read = 1;
			mem_addr = valA;
		end

		if (mem_addr > 2047) begin
			dmem_error = 1'b1;
		end
		if (mem_write && !mem_read) begin
			d_mem[mem_addr] = mem_data;
		end
		else if (!mem_write && mem_read) begin
			valM = d_mem[mem_addr];
		end
	end
endmodule