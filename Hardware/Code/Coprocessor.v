`timescale 1ns / 1ps

module Coprocessor(
	clk,
	rst,
	c0_rd_addr,
	c0_wr_addr,
	c0_w_data,
	pc_i,
	InTcause,
	c0_reg_we,
	WriteEPC,
	WriteCause,
	c0_r_data,
	epc_o
);

// ================ IO interface
	input clk, rst;
	input wire 	[31: 0] c0_w_data, pc_i;
	input wire 	[ 4: 0] c0_rd_addr, c0_wr_addr;
	input wire 	[ 4: 0]	InTcause;
	input wire 			c0_reg_we, WriteEPC, WriteCause;

	output wire [31: 0]	c0_r_data, epc_o;

	reg [31: 0]  c0reg[11:14];

	assign c0_r_data 	= c0reg[c0_rd_addr];
	assign epc_o  		= c0reg[14];

	always @(posedge clk ) begin
		if (rst) begin
			// reset
			for(i = 11; i <= 14; i = i + 1)
				c0reg <= 32'b0;
		end
		else begin
			if (c0_reg_we == 1)
				c0reg[c0_wr_addr] <= c0_w_data;
			if (WriteEPC == 1)
            	c0reg[14] <= pc_i;
			if (CauseWrite == 1)
            	c0reg[13] <= InTcause;
		end
	end
	
endmodule