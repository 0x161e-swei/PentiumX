`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:00:48 02/27/2014 
// Design Name: 
// Module Name:    clk_div 
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
module  clk_div(
                clk,
                rst,
                SW2,
                clkdiv,
                Clk_CPU
);
    input  wire         clk,
                        rst;
    input  wire         SW2;
    output reg  [31: 0]	clkdiv = 0;
    output wire         Clk_CPU;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
           clkdiv <= 0;
        end 
        else begin
            clkdiv <= clkdiv + 32'b1;
        end
    end

   assign Clk_CPU = SW2 ? clkdiv[24] : clkdiv[1]; // SW2 to chose Cpuclk

endmodule
