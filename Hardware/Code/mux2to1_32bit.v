`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:09:31 03/13/2014 
// Design Name: 
// Module Name:    mux2-1_32bit 
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
module mux2to1_32(
				a,
				b,
				sel,
				o
    			);

	input wire  [31: 0] a, b;
	input wire 			sel;
	output wire [31:0]	o;

 	assign o = sel? a: b;
 
endmodule
