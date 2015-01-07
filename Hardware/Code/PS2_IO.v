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
				//cpu_read_write
				//wb_input
				dat_i, 
				adr_i, 
				we_i,
				stb_i,
				//wb_output
				dat_o, 				
				ack_o,

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

	//cpu_read_write		
	input wire [7:0] dat_i;
	input wire [31:0] adr_i;
	input wire we_i;
	input wire stb_i;
	output reg [7:0] dat_o;
	output ack_o;

    input               io_read_clk, clk_ps2, rst, PS2_clk, PS2_Data, ps2_rd;

    output              ps2_ready;
    output reg  [ 7: 0] key;
    output reg  [31: 0] key_d;
    



	reg ps2_rdn;
	
	assign ack_o = stb_i;
	
	always @(posedge io_read_clk or posedge rst)
		if ( rst ) begin
            ps2_rdn   <= 1; 
            key_d     <= 0; 
        end
		else if(stb_i && ack_o) begin
			if(~we_i && ps2_ready) begin
				key_d     <= {key_d[23:0], ps2_key};   // TEST
				ps2_rdn   <= we_i | ~ps2_ready;     // cancel key_ready
				key <= ps2_key;
			end
			else key <= 8'haa;
		end
		else begin
			ps2_rdn  <=1;
		end

	/*
	always @(posedge io_read_clk or posedge rst)
		if ( rst ) begin
            ps2_rdn   <= 1; 
            key_d     <= 0; 
        end
		else if( ps2_rd && ps2_ready) begin
			key_d     <= {key_d[23:0], ps2_key};   // TEST
			ps2_rdn   <= ~ps2_rd | ~ps2_ready;     // cancel key_ready
		end
		else ps2_rdn  <=1;*/

	//assign key = ( ps2_rd && ps2_ready) ? ps2_key : 8'haa;

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
