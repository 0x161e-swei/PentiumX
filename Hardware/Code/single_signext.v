`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:57:27 03/25/2014 
// Design Name: 
// Module Name:    single_signext 
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
module single_signext(signext, i_16, o_32);
	input  wire 		signext;
	input  wire [15: 0] i_16;
	output wire [31: 0] o_32;

	assign o_32 = signext?{16'h0, i_16}:{{16{i_16[15]}}, i_16};
endmodule