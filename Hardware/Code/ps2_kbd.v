`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:40:01 08/24/2014 
// Design Name: 
// Module Name:    ps2_kbd 
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
module ps2_kbd (
                clk, 
                clrn, 
                ps2_clk, 
                ps2_data, 
                rdn, 
                data, 
                ready, 
                overflow
                );

	input              	clk, clrn;          // clock and reset (active low)
	input              	ps2_clk, ps2_data;  // ps2 signals from keyboard
	input              	rdn;                // read (active low) signal from cpu
	output     	[ 7: 0] data;               // keyboard code
	output             	ready;              // queue (fifo) state
	output reg         	overflow;           // queue (fifo) overflow

	reg        	[ 3: 0] count;              // count ps2_data bits
	reg        	[ 9: 0] buffer;             // ps2_data bits
	reg        	[ 7: 0] fifoo[7:0];         // data queue (fifo)
	reg        	[ 2: 0] w_ptr, r_ptr;       // fifo write and read pointers
	reg        	[ 2: 0] ps2_clk_sync;       // for detecting the falling-edge of a frame
	integer    	        i;

	initial begin 
        count    <= 0;                     	// clear count
        w_ptr    <= 0;                     	// clear w_ptr
        r_ptr    <= 0;                     	// clear r_ptr
        overflow <= 0;                     	// clear overflow
		for(i = 0; i < 8; i = i + 1) fifoo[i]=0;
	end


	always @ (posedge clk) begin                       // this is a common method to
		ps2_clk_sync <= {ps2_clk_sync[1:0],ps2_clk};       // detect
	end                                                    // falling-edge

	wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];    // (start bit)

	reg [1:0] rdn_falling;
	
	always @ (posedge clk) begin
		rdn_falling <= {rdn_falling[0],rdn};
		if (clrn == 0) begin
			count 		<= 0;
			w_ptr 		<= 0;
			r_ptr 		<= 0;
			overflow 	<= 0;
		end else if (sampling) begin
			if (count == 4'd10) begin                  // for one frame
				if ((buffer[0] == 0) && (ps2_data) && (^buffer[9:1])) begin // odd prity
					fifoo[w_ptr] <= buffer[8:1];       // write fifo
					w_ptr <= w_ptr + 3'b1;             // w_ptr++
					overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
				end
			count <= 0;                                // for next
			end else begin                             // within one frame
				buffer[count]   <= ps2_data;           // store ps2_data
				count           <= count + 3'b1;       // count ps2_data bits
			end
		end

		if ((rdn_falling == 2'b01) && ready) begin     // when cpu reads fifo
			r_ptr    <= r_ptr + 3'b1;                  // r_ptr++
			overflow <= 0;                             // clear overflow
		end
	end

	assign ready   = (w_ptr != r_ptr);                 // fifo has data
	assign data    = fifoo[r_ptr];                     // fifo data
endmodule

