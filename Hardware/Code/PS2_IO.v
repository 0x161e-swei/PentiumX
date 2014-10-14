`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:29:42 08/24/2014 
// Design Name: 
// Module Name:    PS2_IO 
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
module PS2_IO(  
                io_read_clk,
				clk_ps2,
				rst,
				PS2_clk,
				PS2_Data,
				ps2_rd,

				ps2_ready,
				key_d,
				key
				);

    input               io_read_clk, clk_ps2, rst, PS2_clk, PS2_Data, ps2_rd;

    output              ps2_ready;
    output      [ 7: 0] key;
    output reg  [31: 0] key_d;
    



	reg ps2_rdn;

	always @(posedge io_read_clk or posedge rst)
		if ( rst ) begin
            ps2_rdn   <= 1; 
            key_d     <= 0; 
        end
		else if( ps2_rd && ps2_ready) begin
			key_d     <= {key_d[23:0], ps2_key};   // TEST
			ps2_rdn   <= ~ps2_rd | ~ps2_ready;     // cancel key_ready
		end
		else ps2_rdn  <=1;

	assign key = ( ps2_rd && ps2_ready) ? ps2_key : 8'haa;

	wire [7:0]ps2_key;
	wire ps2_ready;

	ps2_kbd ps2_kbd(
                    .clk           (clk_ps2),
					.clrn          (~rst),
					.ps2_clk       (PS2_clk),
					.ps2_data      (PS2_Data),
					.rdn           (ps2_rdn),
					.data          (ps2_key),
					.ready         (ps2_ready),
					.overflow      ()
					);

endmodule
