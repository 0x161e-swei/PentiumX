`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:29:34 08/24/2014 
// Design Name: 
// Module Name:    VGA_IO 
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
module VGA_IO(
	            vga_clk, 
                rst,
			    vram_out,
			    text_Cursor_switch,
			    Cursor,
			    Blink,
			    R, 
                G, 
                B, 
                HSYNC, 
                VSYNC,
			    vga_addr,
			    vga_rdn
			    );

	input               vga_clk, rst, Blink, text_Cursor_switch;
    input       [10: 0] vram_out;
    input       [12: 0] Cursor;

	// VGA output signals

	output wire [ 2: 0] R;
	output wire [ 2: 0] G;
	output wire [ 1: 0] B;
	output reg          HSYNC;
	output reg          VSYNC;
	output      [10: 0] vga_addr;
	output wire         vga_rdn;

	// variable declarations
	wire                h_sync;
	wire                v_sync;
	wire                v_active;
	wire        [18: 0] addr;

	wire        [11: 0] font_addr;
	wire        [15: 0] font_out;

	reg         [ 2: 0] dot_in;
	reg         [15: 0] l_font_out;
	reg         [31: 0] l_vram_out,vram_data;
	reg         [18: 0] pixel_addr;
	reg                 red, green, blue, vga_dispn;

	//
	// module body
	//
	// wire [18:0] pixel_addr = addr;
	wire 		[ 8: 0] vga_row    = pixel_addr[18:10];							// 480	
	wire 		[ 9: 0] vga_col    = pixel_addr[ 9: 0];							// 640
	wire 		[ 3: 0] font_row   = vga_row[ 3: 0];							// 2^4 = 16
	wire 		[ 3: 0] font_col   = vga_col[ 3: 0];
	wire 		[ 4: 0] char_row   = vga_row[ 8: 4]; 							// 30 rows
	wire 		[ 5: 0] char_col   = vga_col[ 9: 4];							// 40 colums 
	assign 			 	vga_addr   = char_row * (32 + 8) + addr[ 9: 4];
	assign 		 		font_addr  = {vram_out[7: 0], font_row};				// Actually the font_addr shoud be {vram_out[15: 0], font_row}
	assign 		 		vga_rdn    = ~(v_active && (addr[ 2: 0] == 3'b000)); 	//

	wire 		 		Blinking   = (Cursor[11: 6] == char_row) && (Cursor[ 5: 0] == char_col) &&( vga_row[ 3: 0] > 13) && (~text_Cursor_switch); //&& (vga_col[2:0]<7 )
	assign 		 		R[2]       = Blinking ? red   ^ Blink : red;
	assign 				R[1]       = Blinking ? red   ^ Blink : red;
	assign 				R[0]       = Blinking ? red   ^ Blink : red;

	assign 				G[2]       = Blinking ? green ^ Blink : green;
	assign 				G[1]       = Blinking ? green ^ Blink : green;
	assign 				G[0]       = Blinking ? green ^ Blink : green;
				
	assign 				B[0]       = Blinking ? blue  ^ Blink : blue;
	assign 				B[1]       = Blinking ? blue  ^ Blink : blue; 
				
	vga_core vga_Scans(
					.vga_clk   (vga_clk),
					.rst       (rst),
					// .dot_in(dot_in),
					.addr      (addr),
					.v_active  (v_active),
					// .r(r),
					// .g(g),
					// .b(b),
					.h_sync    (h_sync),
					.v_sync    (v_sync)
					);

	Font_table Font_Rom(
                    //.clk       (vga_clk),
					.Addr      (font_addr),
					.D_out     (font_out)
					);

	/* always @(posedge vga_clk )
	if(~vga_rdn) vram_data<=vram_out;
	else vram_data<=vram_data;
	*/

	always @(posedge vga_clk) begin
		if(~vga_rdn) begin //vga_col[2:0] == 3'd0
			l_font_out <= font_out;
			l_vram_out <= vram_out;
		end else begin
			l_font_out <= l_font_out;
			l_vram_out <= l_vram_out;
		end
	end


	always @* begin
		if( vga_dispn )
		dot_in = 3'b0;
	else
		case(vga_col[ 3: 0])
			4'b0000: dot_in = encolor(l_vram_out[10: 8], l_font_out[15]);
			4'b0001: dot_in = encolor(l_vram_out[10: 8], l_font_out[14]);
			4'b0010: dot_in = encolor(l_vram_out[10: 8], l_font_out[13]);
			4'b0011: dot_in = encolor(l_vram_out[10: 8], l_font_out[12]);
			4'b0100: dot_in = encolor(l_vram_out[10: 8], l_font_out[11]);
			4'b0101: dot_in = encolor(l_vram_out[10: 8], l_font_out[10]);
			4'b0110: dot_in = encolor(l_vram_out[10: 8], l_font_out[ 9]);
			4'b0111: dot_in = encolor(l_vram_out[10: 8], l_font_out[ 8]);
			4'b1000: dot_in = encolor(l_vram_out[10: 8], l_font_out[ 7]);
			4'b1001: dot_in = encolor(l_vram_out[10: 8], l_font_out[ 6]);
			4'b1010: dot_in = encolor(l_vram_out[10: 8], l_font_out[ 5]);
			4'b1011: dot_in = encolor(l_vram_out[10: 8], l_font_out[ 4]);
			4'b1100: dot_in = encolor(l_vram_out[10: 8], l_font_out[ 3]);
			4'b1101: dot_in = encolor(l_vram_out[10: 8], l_font_out[ 2]);
			4'b1110: dot_in = encolor(l_vram_out[10: 8], l_font_out[ 1]);
			4'b1111: dot_in = encolor(l_vram_out[10: 8], l_font_out[ 0]);
		endcase
	end


	function [ 2: 0] encolor;
	input 	 [ 2: 0] color;
	input 			 fonto;
	case(color)
		3'b000: encolor = {1'b0, 1'b0, 1'b0};
		3'b001: encolor = {1'b0, 1'b0, fonto};
		3'b010: encolor = {1'b0, fonto, 1'b0};
		3'b011: encolor = {1'b0, fonto, fonto};
		3'b100: encolor = {fonto, 1'b0, 1'b0};
		3'b101: encolor = {fonto, 1'b0, fonto};
		3'b110: encolor = {fonto, fonto, 1'b0};
		3'b111: encolor = {fonto, fonto, fonto};
	endcase
	endfunction

	// vga signals
	always @ (posedge vga_clk) begin
		pixel_addr    <= addr;
		HSYNC         <= h_sync;                          // horizontal synchronization
		vga_dispn     <= ~v_active;
		VSYNC         <= v_sync;                          // vertical synchronization
		red           <= vga_dispn ? 1'h0 : dot_in[2];    // 1-bit red
		green         <= vga_dispn ? 1'h0 : dot_in[1];    // 1-bit green
		blue          <= vga_dispn ? 1'h0 : dot_in[0];    // 1-bit blue
	end

endmodule


