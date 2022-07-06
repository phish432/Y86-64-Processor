module f_reg (
	clk,
	predPC,
	f_pc
);
	input             clk;
	input      [63:0] predPC;
	output reg [63:0] f_pc;

	always @(posedge clk) begin
		f_pc <= predPC;
	end
endmodule

module d_reg (
	clk,
	f_stat, f_icode, f_ifun, f_rA, f_rB, f_valC, f_valP,
	d_stat, d_icode, d_ifun, d_rA, d_rB, d_valC, d_valP
);
	input             clk;

	input      [ 2:0] f_stat;
	input      [ 3:0] f_icode, f_ifun, f_rA, f_rB;
	input      [63:0] f_valC, f_valP;

	output reg [ 2:0] d_stat;
	output reg [ 3:0] d_icode, d_ifun, d_rA, d_rB;
	output reg [63:0] d_valC, d_valP;

	always @(posedge clk) begin
		d_stat  <= f_stat;
		d_icode <= f_icode;
		d_ifun  <= f_ifun;
		d_rA    <= f_rA;
		d_rB    <= f_rB;
		d_valC  <= f_valC;
		d_valP  <= f_valP;
	end
endmodule

module e_reg (
	clk,
	d_stat, d_icode, d_ifun, d_valC, d_valA, d_valB, d_dstE, d_dstM, d_srcA, d_srcB,
	e_stat, e_icode, e_ifun, e_valC, e_valA, e_valB, e_dstE, e_dstM, e_srcA, e_srcB
);
	input clk;

	input      [ 2:0] d_stat;
	input      [ 3:0] d_icode, d_ifun;
	input      [63:0] d_valC;
	input      [63:0] d_valA, d_valB;
	input      [ 3:0] d_dstE, d_dstM, d_srcA, d_srcB;

	output reg [ 2:0] d_stat;
	output reg [ 3:0] d_icode, d_ifun;
	output reg [63:0] d_valC;
	output reg [63:0] d_valA, d_valB;
	output reg [ 3:0] d_dstE, d_dstM, d_srcA, d_srcB;

	always @(posedge clk) begin
		d_stat  <= e_stat;
		d_icode <= e_icode;
		d_ifun  <= e_ifun;
		d_valC  <= e_valC;
		d_valA  <= e_valA;
		d_valB  <= e_valB;
		d_dstE  <= e_dstE;
		d_dstM  <= e_dstM;
		d_srcA  <= e_srcA;
		d_srcB  <= e_srcB;
	end
endmodule

module m_reg (
	clk,
	e_stat, e_icode, e_Cnd, e_valE, e_valA, e_dstE, e_dstM,
	m_stat, m_icode, m_Cnd, m_valE, m_valA, m_dstE, m_dstM	
);
	input clk;

	input      [ 2:0] e_stat;
	input      [ 3:0] e_icode;
	input             e_Cnd;
	input      [63:0] e_valE, e_valA;
	input      [ 3:0] e_dstE, e_dstM;

	output reg [ 2:0] m_stat;
	output reg [ 3:0] m_icode;
	output reg        m_Cnd;
	output reg [63:0] m_valE, m_valA;
	output reg [ 3:0] m_dstE, m_dstM;

	always @(posedge clk) begin
		e_stat  <= m_stat;
		e_icode <= m_icode;
		e_Cnd   <= m_Cnd;
		e_valE  <= m_valE;
		e_valA  <= m_valA;
		e_dstE  <= m_dstE;
		e_dstM  <= m_dstM;
	end
endmodule

module w_reg (
	clk,
	m_stat, m_icode, m_valE, m_valM, m_dstE, m_dstM,
	w_stat, w_icode, w_valE, w_valM, w_dstE, w_dstM
);
	input clk;

	input      [ 2:0] m_stat;
	input      [ 3:0] m_icode;
	input      [63:0] m_valE, m_valM;
	input      [ 3:0] m_dstE, m_dstM;

	output reg [ 2:0] w_stat;
	output reg [ 3:0] w_icode;
	output reg [63:0] w_valE, w_valM;
	output reg [ 3:0] w_dstE, w_dstM;

	always @(posedge clk) begin
		m_stat  <= w_stat;
		m_icode <= w_icode;
		m_valE  <= w_valE;
		m_valM  <= w_valM;
		m_dstE  <= w_dstE;
		m_dstM  <= w_dstM;
	end
endmodule