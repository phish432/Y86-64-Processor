module pc_update_tb();

reg clk;
reg [3:0] icode;
reg Cnd;
reg [63:0] PC; 
reg [63:0] valC;
reg [63:0] valP;
reg [63:0] valM;
output [63:0] new_pc;

program_counter_update program_counter_update(
    .clk(clk),
    .PC(PC),
    .Cnd(Cnd),
    .icode(icode),
    .valC(valC),
    .valM(valM),
    .valP(valP),
    .new_pc(new_pc)
  );

initial begin

    clk=1'b0;
    PC = 64'h0000;

    icode = 4'b1000; valC = 64'd1; valM = 64'd2; valP = 64'd3; cnd = 1'b0;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b0111; valC = 64'd12; valM = 64'd15; valP = 64'd3; cnd = 1'b0;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b0111; valC = 64'd12; valM = 64'd15; valP = 64'd3; cnd = 1'b1;
    #10 clk = ~clk; 
    #10 clk = ~clk;
    icode = 4'b1001; valC = 64'd24; valM = 64'd15; valP = 64'd10; cnd = 1'b1;
    #10 clk = ~clk; 

end 
  
initial
	$monitor("clk = %d icode = %b valC = %g valP = %g valM = %g cnd = %g new_pc = %g\n",clk,icode,valC,valP,valM,cnd,new_pc);
    
endmodule