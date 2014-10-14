`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:32:07 08/24/2014
// Design Name:   ps2_kbd
// Module Name:   E:/Summer Course/Top_Computer_IOBUS_VGA_PS2_N3/test_ps2kbd.v
// Project Name:  Top_Computer_IOBUS_VGA_PS2_N3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ps2_kbd
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_ps2kbd;

	// Inputs
	reg clk;
	reg clrn;
	reg ps2_clk;
	reg ps2_data;
	reg rdn;

	// Outputs
	wire [7:0] data;
	wire ready;
	wire overflow;

	// Instantiate the Unit Under Test (UUT)
	ps2_kbd uut (
		.clk(clk), 
		.clrn(clrn), 
		.ps2_clk(ps2_clk), 
		.ps2_data(ps2_data), 
		.rdn(rdn), 
		.data(data), 
		.ready(ready), 
		.overflow(overflow)
	);

	parameter PERIOD = 20;
	parameter real DUTY_CYCLE = 0.5;
	initial forever begin
		clk = 1'b0;
		#(PERIOD-(PERIOD*DUTY_CYCLE)) clk = 1'b1;
		#(PERIOD*DUTY_CYCLE);
	end

	initial forever begin
		ps2_clk = 1'b0;
		#(10*PERIOD-(10*PERIOD*DUTY_CYCLE)) ps2_clk = 1'b1;
		#(10*PERIOD*DUTY_CYCLE);
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		clrn = 0;
		ps2_clk = 0;
		ps2_data = 0;
		rdn = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
				#10 clrn = 1;
		//#200 ps2_data = 0;
		#200 ps2_data = 1;
		#200 ps2_data = 1;
		#200 ps2_data = 0;
		#200 ps2_data = 1;
		#200 ps2_data = 0;
		#200 ps2_data = 0;
		#200 ps2_data = 1;
		#200 ps2_data = 0;
		#200 ps2_data = 1;
		#200 ps2_data = 1;
		
	end
      
endmodule

