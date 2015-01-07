`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    10:51:10 08/26/2014
// Design Name:
// Module Name:    Mem_I_D
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
module Mem_I_D 	(
				//cpu_read_write
				//wb_input
				dat_i, 
				adr_i, 
				we_i,
				stb_i,
				//wb_output
				dat_o, 				
				ack_o,

				clk,
				//W_En,
				//Addr,
				//D_In,
				//D_Out
    			);
	//cpu_read_write		
	input wire [31:0] dat_i;
	input wire [32:0] adr_i;
	input wire we_i;
	input wire stb_i;
	output reg [31:0] dat_o;
	output reg ack_o = 0;

	input 				clk;
	//input 				W_En;
	//input 		[11: 0] Addr;
	//input		[31: 0] D_In;
	//output reg	[31: 0] D_Out;
	wire [11:0] ram_addr;
	assign ram_addr = adr_i[13:2];

	(* bram_map="yes" *)
	reg 	[31: 0] RAM[8191:   0];


	initial begin
		$readmemb("../Coe/ChineseTest",RAM);
	end

	always @(posedge clk) ack_o <= stb_i;
	
	always @(posedge clk) begin
		if(stb_i && ack_o) begin
			if(we_i) begin //write
				RAM[ram_addr] <= dat_i;
			end
			else begin //read
				dat_o <= RAM[ram_addr];
			end
		end
	end
	
	/*
	always @(posedge clk ) begin
		if ( W_En ) begin
			RAM[Addr] <= D_In;
		end
		else D_Out <= RAM[Addr];
	end*/

endmodule
