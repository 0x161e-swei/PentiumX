`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:46:08 08/24/2014 
// Design Name: 
// Module Name:    vga_core 
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
module vga_core(
                vga_clk, 
                rst, 
                addr,
                v_active,
                h_sync, 
                v_sync
                ); // dot_in, vga_rdn, r, g, b,

	input              	vga_clk;                // 25MHz
	input              	rst;
	output     	[18: 0] addr;                   // pixel Screen address, 640 (1024) x 480 (512)
	output             	v_active;               // read VRAM RAM (active_low)
	output             	h_sync, v_sync;         // horizontal and vertical synchronization

    //  input [2:0] dot_in;                    // r_g_b, pixel
    //  output reg r, g, b;                    // red, green, blue colors, 4-bit for each if N3

	// h_count: VGA horizontal counter (0-799)
	reg [9:0] h_count = 0; // VGA horizontal counter (0-799): pixels
	always @ (posedge vga_clk or posedge rst) begin
		if (rst) begin
			h_count <= 10'h0;
		end else if (h_count == 10'd799) begin
			h_count <= 10'h0;
		end else begin
			h_count <= h_count + 10'h1;
		end
	end

	// v_count: VGA vertical counter (0-524)
	reg [9:0] v_count = 0; // VGA vertical counter (0-524): lines
	always @ (posedge vga_clk or posedge rst) begin
		if (rst) begin
			v_count <= 10'h0;
		end else if (h_count == 10'd799) begin
			if (v_count == 10'd524) begin
				v_count <= 10'h0;
			end else begin
				v_count <= v_count + 10'h1;
			end
		end
	end

	// signal timing
	wire h_sync 		= (h_count > 10'd95);          // 96 -> 799
	wire v_sync 		= (v_count > 10'd1);           // 2 -> 524
	wire v_active 		= (h_count > 10'd142) &&     // 143 -> 782
						  (h_count < 10'd783) &&     // 640 pixels
						  (v_count > 10'd34) &&      // 35 -> 514
						  (v_count < 10'd515);       // 480 lines

	wire [ 9: 0] col   	= h_count - 10'd143;    // pixel Screen addr col
	wire [ 9: 0] row   	= v_count - 10'd35;     // pixel Screen addr row
	wire [18: 0] addr  	= {row[ 8: 0], col};    // pixel Screen addr

	// vga signals
	/* always @ (posedge vga_clk) begin
		pixel_addr <= addr;
		vga_rdn <= ~read;
		hs <= h_sync; // horizontal synchronization
		vs <= v_sync; // vertical synchronization
		r <= vga_rdn ? 4'h0 : dot_in[2]; // 1-bit red
		g <= vga_rdn ? 4'h0 : dot_in[1]; // 1-bit green
		b <= vga_rdn ? 4'h0 : dot_in[0]; // 1-bit blue
	end
	*/
endmodule
