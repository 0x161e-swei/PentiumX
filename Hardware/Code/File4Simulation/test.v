`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:35:00 08/24/2014
// Design Name:   Top_N3_Computer_IOBUS_VGA_PS2
// Module Name:   E:/Summer Course/Top_Computer_IOBUS_VGA_PS2_N3/test.v
// Project Name:  Top_Computer_IOBUS_VGA_PS2_N3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Top_N3_Computer_IOBUS_VGA_PS2
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test;

	// Inputs
	reg clk_100mhz;
	reg [4:0] BTN;
	reg [7:0] SW;
	reg PS2_clk;
	reg PS2_Data;

	// Outputs
	wire [7:0] LED;
	wire [7:0] SEGMENT;
	wire [3:0] AN_SEL;
	wire [2:0] Red;
	wire [2:0] Green;
	wire [1:0] Blue;
	wire HSYNC;
	wire VSYNC;

	// Instantiate the Unit Under Test (UUT)
	Top_N3_Computer_IOBUS_VGA_PS2 uut (
		.clk_100mhz(clk_100mhz), 
		.BTN(BTN), 
		.SW(SW), 
		.LED(LED), 
		.SEGMENT(SEGMENT), 
		.AN_SEL(AN_SEL), 
		.PS2_clk(PS2_clk), 
		.PS2_Data(PS2_Data), 
		.Red(Red), 
		.Green(Green), 
		.Blue(Blue), 
		.HSYNC(HSYNC), 
		.VSYNC(VSYNC)
	);

	parameter PERIOD = 20;
	parameter real DUTY_CYCLE = 0.5;
	initial forever begin
		clk_100mhz = 1'b0;
		#(PERIOD-(PERIOD*DUTY_CYCLE)) clk_100mhz = 1'b1;
		#(PERIOD*DUTY_CYCLE);
	end
	
	initial forever begin
		PS2_clk = 1'b0;
		#(10*PERIOD-(10*PERIOD*DUTY_CYCLE)) PS2_clk = 1'b1;
		#(10*PERIOD*DUTY_CYCLE);
	end

	initial begin
		// Initialize Inputs
		clk_100mhz = 0;
		BTN = 0;
		SW = 0;
		PS2_clk = 0;
		PS2_Data = 0;

		// Wait 100 ns for global reset to finish
		#100;
       
		// Add stimulus here
		//0d
		#100 BTN[3] = 1;
		#100 BTN[3] = 0;
		
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		//5a
		#200 PS2_Data = 0;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		//5a
		#200 PS2_Data = 0;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		//5a
		#200 PS2_Data = 0;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		//5a
		#200 PS2_Data = 0;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		#200 PS2_Data = 0;
		#200 PS2_Data = 0;
		#200 PS2_Data = 1;
		
		
	end
      
endmodule

