`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:51:10 08/26/2014
// Design Name:
// Module Name:    Mem_I_D
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module Mem_I_D 	(
				clk,
				W_En,
				Addr,
				D_In,
				D_Out
    			);

	input 				clk;
	input 				W_En;
	input 		[11: 0] Addr;
	input		[31: 0] D_In;
	output reg	[31: 0] D_Out;

	(* bram_map="yes" *)
	reg 	[31: 0] RAM[8191:   0];


	initial begin
		$readmemb("../Coe/ChineseTest",RAM);
	end

	always @(posedge clk ) begin
		if ( W_En ) begin
			RAM[Addr] <= D_In;
		end
		else D_Out <= RAM[Addr];
	end

endmodule
