/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009, 2010 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module uart #(
	//parameter csr_addr = 4'h0,
	parameter clk_freq = 100000000,
	parameter baud = 115200
) (
	//cpu_read_write
	//wb_input
	input [31:0] dat_i, 
	input [31:0] adr_i, 
	input we_i,
	input stb_i,
	//wb_output
	output reg [31:0] dat_o, 				
	output ack_o,

	input sys_clk,
	input sys_rst,

	output rx_irq,
	output tx_irq,

	input uart_rx,
	output uart_tx,
	input rx_iack
);

reg [15:0] divisor;
wire [7:0] rx_data;
wire [7:0] tx_data;
wire tx_wr;
wire rx_done, tx_done;
wire tx_busy;
wire full_rx, full_tx, empty_rx, empty_tx;

reg thru = 0;
wire uart_tx_transceiver;

wire [7:0] rx_data_out;
reg fifo_rx_wr = 0;
reg tmpflag = 0;

wire fifo_rx_rd;
reg fifo_rd_once = 0;

wire [7:0] tx_data_out;
wire 	fifo_tx_rd;
reg		tran_tx_wr;

reg fifo_busy;

wire uart_wr;

uart_transceiver transceiver(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),

	.uart_rx(uart_rx),
	.uart_tx(uart_tx_transceiver),

	.divisor(divisor),

	.rx_data(rx_data),
	.rx_done(rx_done),

	.tx_data(tx_data_out),
	.tx_wr(fifo_tx_rd),
	.tx_done(tx_done),
	.tx_busy(tx_busy),
	.rx_busy(rx_busy)
);



// always @(posedge sys_clk) begin
// 	if(rx_done & ~fifo_rx_wr) fifo_rx_wr = 1;
// 	else if(~rx_done & fifo_rx_wr & ~tmpflag) begin 
// 		fifo_rx_wr = 1;
// 		tmpflag = 1;
// 		end
// 	else if(tmpflag) begin 
// 		fifo_rx_wr = 0;
// 		tmpflag = 0;
// 		end
// end

 always @(posedge sys_clk) begin
 	if(rx_done) fifo_rx_wr = 1;
 	else fifo_rx_wr = 0;
 	end

assign fifo_rx_rd = rx_wr & ~fifo_rd_once;
always @(posedge sys_clk) begin
	if(rx_wr) fifo_rd_once = 1;
	else fifo_rd_once = 0;
end

assign rx_irq = full_rx & ~rx_iack;

uart_fifo fifo_rx (
  .clk(sys_clk), // input clk
  .rst(sys_rst), // input rst
  .din(rx_data), // input [7 : 0] din
  .wr_en(fifo_rx_wr), // input wr_en
  .rd_en(fifo_rx_rd), // input rd_en
  .dout(rx_data_out), // output [7 : 0] dout
  .full(full_rx), // output full
  .empty(empty_rx), // output empty
  .data_count() // output [7 : 0] data_count
);


assign fifo_tx_rd = ~tx_busy & ~empty_tx;
always @(posedge sys_clk) begin 
	tran_tx_wr = fifo_tx_rd;
	end

always @(posedge sys_clk) begin
	if(tx_wr) fifo_busy = 1;
	else fifo_busy = 0;
end

//assign tx_irq = full_tx;

reg fifo_tx_rd2 = 0;
always @(posedge sys_clk) begin
    fifo_tx_rd2 = fifo_tx_rd;
end


uart_fifo fifo_tx (
  .clk(sys_clk), // input clk
  .rst(sys_rst), // input rst
  .din(tx_data), // input [7 : 0] din
  .wr_en(tx_wr & ~fifo_busy), // input wr_en
  .rd_en(fifo_tx_rd), // input rd_en
  .dout(tx_data_out), // output [7 : 0] dout
  .full(full_tx), // output full
  .empty(empty_tx), // output empty
  .data_count() // output [7 : 0] data_count
);


assign uart_tx = thru ? uart_rx : uart_tx_transceiver;

/* CSR interface */
//wire csr_selected = csr_a[13:10] == csr_addr;

assign tx_data = dat_i[7:0];
//assign tx_wr = csr_selected & csr_we & (csr_a[1:0] == 2'b00);
assign tx_wr = stb_i & ack_o & we_i & (adr_i[1:0] == 2'b00);
assign rx_wr = stb_i & ack_o & ~we_i & (adr_i[1:0] == 2'b00) & ~empty_rx;

parameter default_divisor = clk_freq/baud/16;

assign ack_o = stb_i & (we_i?~full_tx:1) ;//& ((we_i&~full_tx) | (~we_i&~empty_rx));

assign uart_wr = stb_i && ack_o;

always @(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		divisor <= default_divisor;
		dat_o <= 32'd0;
	end else if(uart_wr) begin
		dat_o <= 32'd0;
		case(adr_i[1:0])
			2'b00: if(rx_wr) begin dat_o <= {23'h0, 1'b1, rx_data_out}; end
			2'b01: dat_o <= divisor;
			2'b10: dat_o <= thru;
		endcase
		if(we_i/*csr_we*/) begin
			case(adr_i[1:0])
				2'b00:; /* handled by transceiver */
				2'b01: divisor <= dat_i[15:0];
				2'b10: thru <= dat_i[0];
			endcase
		end
	end
end

//always @(posedge sys_clk) begin
//	if(sys_rst) begin
//		divisor <= default_divisor;
//		dat_o <= 32'd0;
//	end else begin
//		dat_o <= 32'd0;
//		if(stb_i && ack_o/*csr_selected*/) begin
//			case(adr_i[1:0])
//				2'b00: dat_o <= rx_data;
//				2'b01: dat_o <= divisor;
//				2'b10: dat_o <= thru;
//			endcase
//			if(we_i/*csr_we*/) begin
//				case(adr_i[1:0])
//					2'b00:; /* handled by transceiver */
//					2'b01: divisor <= dat_i[15:0];
//					2'b10: thru <= dat_i[0];
//				endcase
//			end
//		end
//	end
//end

endmodule
