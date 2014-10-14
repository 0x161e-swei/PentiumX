`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:10:31 10/14/2014 
// Design Name: 
// Module Name:    Vram_B 
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
module 	Vram_B(
                clk,               
			    W_En,                
        		Addr,              
        		D_In,               
			    D_Out              
    			);

	input 				clk;
	input 				W_En;
	input 		[12: 0] Addr;
	input		[10: 0] D_In;
	output reg	[10: 0] D_Out;

	(* bram_map="yes" *)
	reg 		[10: 0] Vram_B[4799:	0];

	/*
	initial begin
		$readmemb("Whatever to make it cool~",Vram_B);
	end
	*/

	always @(posedge clk ) begin
		if ( W_En ) begin
			Vram_B[Addr] <= D_In;
		end
		else D_Out <= Vram_B[Addr];
	end


endmodule
