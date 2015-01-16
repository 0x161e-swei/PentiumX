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
	epc_o,
    WriteInt,
    Int_en_i,
    Int_en_o
);

// ================ IO interface
	input clk, rst;
	input wire 	[31: 0] c0_w_data, pc_i;
	input wire 	[ 4: 0] c0_rd_addr, c0_wr_addr;
	input wire 	[ 4: 0]	InTcause;
	input wire 			c0_reg_we, WriteEPC, WriteCause,
						WriteInt, Int_en_i;

	output wire [31: 0]	c0_r_data, epc_o, Int_en_o;
    integer             i = 0;
	reg 		[31: 0] c0reg[11:14];
				// 11 Enable, 12 Base, 13 Cause, 14 Epc

	assign c0_r_data 	= c0reg[c0_rd_addr];
	assign epc_o  		= c0reg[14];
	assign Int_en_o  	= c0reg[11];
       
	initial begin
		for(i = 11; i <= 14; i = i + 1)
			c0reg[i] <= 32'b0;
	end
	
	always @(posedge clk ) begin
		if (rst) begin
			// reset
			for(i = 11; i <= 14; i = i + 1)
				c0reg[i] <= 32'b0;
		end
		else begin

			if (c0_reg_we == 1)
				c0reg[c0_wr_addr] 	<= c0_w_data;
			if (WriteInt == 1)
            	c0reg[11][0] 		<= Int_en_i;
            if (WriteCause == 1)
            	c0reg[13] 			<= InTcause;
			if (WriteEPC == 1)
            	c0reg[14] 			<= pc_i;
			
		end
	end
	
endmodule
