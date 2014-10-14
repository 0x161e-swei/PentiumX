`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:58:11 07/01/2012 
// Design Name: 
// Module Name:    Device_led 
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
module Device_GPIO_led(
                  	clk,
	               	rst,
	               	GPIOffffff00_we,
	               	Peripheral_in,
	               	counter_set,
	               	led_out,
	               	GPIOf0				 
					);


	input  wire 		clk, rst, GPIOffffff00_we;
	input  wire [31: 0]	Peripheral_in;

	output wire [ 7: 0]	led_out;
	output reg 	[ 1: 0]	counter_set = 0;
	output reg 	[21: 0]	GPIOf0 = 0;

	reg 		[ 7: 0] LED = 0; 

	assign led_out = LED; 
	
	always @(negedge clk or posedge rst) begin 
		if( rst ) begin 
			LED 		<= 8'hAA; 
			counter_set	<= 2'b00; 
		end 
		else begin 
			if( GPIOffffff00_we ) 
				{GPIOf0[21:0], LED, counter_set} <= Peripheral_in; 
			else begin 
				LED 		<= LED; 
				counter_set <= counter_set; 
			end 
		end 
	end 
						
endmodule
