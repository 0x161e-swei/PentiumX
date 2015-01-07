`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:11:19 03/13/2014 
// Design Name: 
// Module Name:    mux4-1_32bit 
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
module mux4to1_32(
                    a,
	                b,
	                c,
	                d,
	                sel,
	                o
                    );
    input wire [31: 0] a, b, c, d;
    input wire [ 1: 0] sel;
    output reg [31: 0] o;

    always @(*) begin
	    case(sel)
		    2'b00:o <= a;
			2'b01:o <= b;
			2'b10:o <= c;
			2'b11:o <= d;
		endcase
	end

endmodule
