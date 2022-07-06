module write_back_tb();

reg clk;
reg [3:0] icode;
reg [3:0] rA;
reg [3:0] rB; 
reg [63:0] valA;
reg [63:0] valB;
reg [63:0] valE;
reg [63:0] valM;
output [63:0] dstE;
output [63:0] dstM;

write_back write_back(
    .clk(clk),
    .icode(icode),
    .rA(rA),
    .rB(rB),
    .valA(valA),
    .valB(valB),
    .valE(valE),
    .valM(valM),
    .dstE(dstE),
    .dstM(dstM)
  );

initial begin

    clk=1'b0;
    
    icode = 4'b0010; rA = 4'b0010; rB = 4'b0110; valA = 64'd3; valB = 64'd18; valE = 64'd140; valM = 64'd16;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b0011; rA = 4'b0000; rB = 4'b0010; valA = 64'd16; valB = 64'd20; valE = 64'd10; valM = 64'd0;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b0110; rA = 4'b1010; rB = 4'b1100; valA = 64'd2; valB = 64'd16; valE = 64'd0; valM = 64'd1;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1000; rA = 4'b1110; rB = 4'b0000; valA = 64'd57; valB = 64'd17; valE = 64'd0; valM = 64'd20;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1001; rA = 4'b0000; rB = 4'b0110; valA = 64'd23; valB = 64'd11; valE = 64'd0; valM = 64'd17;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1010; rA = 4'b0001; rB = 4'b0011; valA = 64'd0; valB = 64'd9; valE = 64'd10; valM = 64'd10;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1011; rA = 4'b0010; rB = 4'b0010; valA = 64'd15; valB = 64'd7; valE = 64'd40; valM = 64'd5;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b0101; rA = 4'b0011; rB = 4'b0011; valA = 64'd65; valB = 64'd5; valE = 64'd78; valM = 64'd1;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1011; rA = 4'b1010; rB = 4'b1110; valA = 64'd69; valB = 64'd1; valE = 64'd12; valM = 64'd0;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1011; rA = 4'b0110; rB = 4'b1010; valA = 64'd20; valB = 64'd0; valE = 64'd15; valM = 64'd0;
    #10 clk = ~clk; 
    #10 clk = ~clk;

end 
  
initial 
	$monitor("clk=%d icode=%b rA=%b rB=%b valA=%g valB=%g valE=%g valM=%g dstE=%g dstM=%g\n",clk,icode,rA,rB,valA,valB,valE,valM,dstE,dstM);
endmodule