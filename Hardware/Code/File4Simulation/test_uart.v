`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:33:46 01/07/2015
// Design Name:   uart
// Module Name:   E:/Study/PentiumX/Hardware/PentiumX_OnSoC/test_uart.v
// Project Name:  PentiumX_OnSoC
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_uart;

	// Inputs
	reg [31:0] dat_i;
	reg [31:0] adr_i;
	reg we_i;
	reg stb_i;
	reg sys_clk;
	reg sys_rst;
	reg uart_rx;

	// Outputs
	wire [31:0] dat_o;
	wire ack_o;
	wire rx_irq;
	wire tx_irq;
	wire uart_tx;

	// Instantiate the Unit Under Test (UUT)
	uart uut (
		.dat_i(dat_i), 
		.adr_i(adr_i), 
		.we_i(we_i), 
		.stb_i(stb_i), 
		.dat_o(dat_o), 
		.ack_o(ack_o), 
		.sys_clk(sys_clk), 
		.sys_rst(sys_rst), 
		.rx_irq(rx_irq), 
		.tx_irq(tx_irq), 
		.uart_rx(uart_rx), 
		.uart_tx(uart_tx)
	);

	parameter PERIOD = 20;
	parameter real DUTY_CYCLE = 0.5;
	initial forever begin
		sys_clk = 1'b0;
		#(PERIOD-(PERIOD*DUTY_CYCLE)) sys_clk = 1'b1;
		#(PERIOD*DUTY_CYCLE);
	end

	initial begin
		// Initialize Inputs
		dat_i = 32'h0000_00ff;
		adr_i = 0;
		we_i = 0;
		stb_i = 0;
		//sys_clk = 0;
		sys_rst = 0;
		uart_rx = 0;

		// Wait 100 ns for global reset to finish
		#100 ;	
		#100 sys_rst = 1;
		#100 sys_rst = 0;
		
		//#100 we_i = 0;
        #100 uart_rx = 1;
		#3000 uart_rx = 0;
		#400 uart_rx = 1;
		#3000 uart_rx = 0;
		#400 uart_rx = 1;
		#3000 uart_rx = 0;
		#400 uart_rx = 1;
		#3000 uart_rx = 0;
		#400 uart_rx = 1;
		#100 stb_i = 1;
		// Add stimulus here

	end
      
endmodule

