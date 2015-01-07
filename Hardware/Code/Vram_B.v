`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:10:31 10/14/2014 
// Design Name: 
// Module Name:    Vram_B 
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
module 	Vram_B(
				//cpu_read_write
				//wb_input
				dat_i, 
				adr_i, 
				we_i,
				stb_i,
				//wb_output
				dat_o, 				
				ack_o,
				
				//vga_read
				vga_addr,
				vga_dout,

            	clk            
			   	//W_En,                
        		//Addr,              
        		//D_In,               
			   	//D_Out           
    			);
	//cpu_read_write		

	input wire [31:0] dat_i;
	input wire [31:0] adr_i;
	input wire we_i;
	input wire stb_i;
	output reg [31:0] dat_o;
	output ack_o;
	
	//vga_read
	input wire [10:0] vga_addr;
	output wire [31:0] vga_dout;


	input 				clk;

	reg [10:0] addra;
	reg wea;
	reg [31:0] dina;
	reg [31:0] douta;
	wire [10:0] vram_addr;
	assign vram_addr = adr_i[14:2];
	//input 				W_En;
	//input 		[10: 0] Addr;						// eleven bits for 1200
	//input		[31: 0] D_In;
	//output reg	[31: 0] D_Out;

	//(* bram_map="yes" *)
	//reg 		[31: 0] Vram_B[1199:	0];

	/*
	initial begin
		$readmemb("Whatever to make it cool~",Vram_B);
	end
	*/

	assign ack_o = stb_i;
	
	always @(posedge clk) begin
		if(stb_i && ack_o) begin
				if(we_i) begin //write
					dina <= dat_i;
					wea <= 1;
				end
				else begin //read
					wea <= 0;
					dat_o <= douta;
				end
		end
		else begin
			wea <= 0;
		end
	end

	//always @(posedge clk ) begin
	//	if ( W_En ) begin
	//		Vram_B[Addr] <= D_In;
	//	end
	//	else D_Out <= Vram_B[Addr];
	//end


	Vram_2 vram_2p(
		//for cpu
	  .clka(clk), // input clka
	  .wea(wea), // input [0 : 0] wea
	  .addra(vram_addr), // input [10 : 0] addra
	  .dina(dina), // input [10 : 0] dina
	  .douta(douta), // output [10 : 0] douta
	  
	  //for vga
	  .clkb(clk), // input clkb
	  .web(0), // input [0 : 0] web
	  .addrb(vga_addr), // input [10 : 0] addrb
	  .dinb(0), // input [10 : 0] dinb
	  .doutb(vga_dout) // output [10 : 0] doutb
	);


endmodule
