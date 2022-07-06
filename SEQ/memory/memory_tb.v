module memory_tb();

reg clk;
reg [3:0] icode;
reg [63:0] valA;
reg [63:0] valB; 
reg [63:0] valE;
reg [63:0] valP;
output [63:0] valM;
output dmem_error;

memory memory(
    .clk(clk),
    .icode(icode),
    .valA(valA),
    .valB(valB),
    .valE(valE),
    .valP(valP),
    .dmem_error(dmem_error),
    .valM(valM)
  );

initial begin

    clk=1'b0;

    icode = 4'b0100; valA = 64'd0; valB = 64'd0; valE = 64'd0; valP = 64'd0;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1010; valA = 64'd0; valB = 64'd1; valE = 64'd2; valP = 64'd3;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1000; valA = 64'd2; valB = 64'd7; valE = 64'd0; valP = 64'd5;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b0101; valA = 64'd0; valB = 64'd0; valE = 64'd5; valP = 64'd4;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1011; valA = 64'd5; valB = 64'd2; valE = 64'd6; valP = 64'd3;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1001; valA = 64'd4; valB = 64'd2; valE = 64'd1; valP = 64'd7;
    #10 clk = ~clk; 

end 
  
initial
	$monitor("clk = %d icode = %b valA = %g valB = %g valE = %g valP = %g valM = %g\n",clk,icode,valA,valB,valE,valP,valM);

endmodule