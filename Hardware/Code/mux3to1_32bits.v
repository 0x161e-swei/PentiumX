`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:43:55 10/10/2014 
// Design Name: 
// Module Name:    mux3to1_32bits 
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
module mux3to1_32(
                    a,
	                b,
	                c,
	                sel,
	                o
                    );
    input wire [31: 0] a, b, c;
    input wire [ 1: 0] sel;
    output reg [31: 0] o;

   always @(*)begin
	   case ( sel )
		    2'b00: o <= b;
			2'b01: o <= a;
			2'b10: o <= c;
            default : ;
		endcase
	end

endmodule