`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:16:55 08/03/2009 
// Design Name: 
// Module Name:    anti_jitter 
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
module BTN_Anti_jitter(
                        clk, 
                        button,
                        SW, 
                        button_out,
                        SW_OK
                        );
    input  wire         clk;
    input  wire [ 3: 0] button;
    input  wire [ 7: 0] SW;
    output reg  [ 3: 0] button_out = 0;
	output reg  [ 7: 0] SW_OK      = 0;
    reg         [31: 0] counter    = 0;

    always @(posedge clk) begin
       if ( counter > 0 ) begin
            if ( counter < 100000 )
                counter <= counter+1;
            else 
				begin 
				    counter     <= 32'b0;
                    button_out  <= button; 
					SW_OK       <= SW; 
				end
        end else begin
            if ( button > 0 || SW > 0 )
                counter <= counter + 1;
        end     
    end
endmodule
