`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:45:49 08/25/2014
// Design Name:   Counter_x
// Module Name:   E:/Summer Course/Top_Computer_IOBUS_VGA_PS2_N3/test_counter.v
// Project Name:  Top_Computer_IOBUS_VGA_PS2_N3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Counter_x
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_counter;

	// Inputs
	reg clk;
	reg rst;
	reg clk0;
	reg clk1;
	reg clk2;
	reg counter_we;
	reg [31:0] counter_val;
	reg [1:0] counter_ch;

	// Outputs
	wire counter0_OUT;
	wire counter1_OUT;
	wire counter2_OUT;
	wire [31:0] counter_out;

	// Instantiate the Unit Under Test (UUT)
	Counter_x uut (
		.clk(clk), 
		.rst(rst), 
		.clk0(clk0), 
		.clk1(clk1), 
		.clk2(clk2), 
		.counter_we(counter_we), 
		.counter_val(counter_val), 
		.counter_ch(counter_ch), 
		.counter0_OUT(counter0_OUT), 
		.counter1_OUT(counter1_OUT), 
		.counter2_OUT(counter2_OUT), 
		.counter_out(counter_out)
	);

	parameter PERIOD = 20;
	parameter real DUTY_CYCLE = 0.5;
	initial forever begin
		clk = 1'b0;
		#(PERIOD-(PERIOD*DUTY_CYCLE)) clk = 1'b1;
		#(PERIOD*DUTY_CYCLE);
	end

	initial forever begin
		clk0 = 1'b0;
		#(10*PERIOD-(10*PERIOD*DUTY_CYCLE)) clk0 = 1'b1;
		#(10*PERIOD*DUTY_CYCLE);
	end
	
	initial forever begin
		clk1 = 1'b0;
		#(10*PERIOD-(10*PERIOD*DUTY_CYCLE)) clk1 = 1'b1;
		#(10*PERIOD*DUTY_CYCLE);
	end
	
	initial forever begin
		clk2 = 1'b0;
		#(10*PERIOD-(10*PERIOD*DUTY_CYCLE)) clk2 = 1'b1;
		#(10*PERIOD*DUTY_CYCLE);
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		clk0 = 0;
		clk1 = 0;
		clk2 = 0;
		counter_we = 0;
		counter_val = 16'h10;
		counter_ch = 0;

		// Wait 100 ns for global reset to finish
		#100;
      //#100 rst = 1;
		//#100 rst = 0;
		// Add stimulus here
		#100 counter_we = 1;
			  //counter_ch = 1;
			  //counter_val = 10;
		#100 counter_we = 0;

	end
      
endmodule

