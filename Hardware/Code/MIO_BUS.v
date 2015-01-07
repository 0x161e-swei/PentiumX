`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:36:02 05/06/2014 
// Design Name: 
// Module Name:    MIO_BUS 
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

module MIO_BUS(	
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
				rst,
				BTN,
				SW,
				//vga_rdn,
				//ps2_ready,
				//mem_w,
				//key,
				//Cpu_data2bus, 		// Data from CPU
				//addr_bus,
				//vga_addr,
				//ram_data_out,
				//vram_out,
				led_out,
				counter_out,
				counter0_out,
				counter1_out,
				counter2_out,

				//CPU_wait,
				//Cpu_data4bus, 		// Data write to CPU
				//ram_data_in, 		// From CPU write to Memory
				//ram_addr, 			// Memory Address signals
				//vram_data_in, 		// From CPU write to Vram Memory
				//vram_addr, 			// Vram Address signals
				//data_ram_we,
				//vram_we,
				GPIOffffff00_we,
				GPIOfffffe00_we,
				counter_we,
				//ps2_rd,
				Peripheral_in
				);
	//cpu_read_write		
	//wb interface
	input wire [31:0] dat_i;
	input wire [31:0] adr_i;
	input wire we_i;
	input wire stb_i;
	output reg [31:0] dat_o;
	output ack_o;

	//input  wire 		clk, rst, ps2_ready, mem_w, vga_rdn;
	input  wire 		clk, rst;
	input  wire			counter0_out, counter1_out, counter2_out;
	input  wire	[ 3: 0] BTN;
	//input  wire	[ 7: 0] SW, led_out, key;
	input  wire	[ 7: 0] SW, led_out;
	//input  wire	[10: 0] vram_out;	
	//input  wire	[12: 0] vga_addr;
	//input  wire	[31: 0] Cpu_data2bus, ram_data_out, addr_bus, counter_out;
	input  wire	[31: 0] addr_bus, counter_out;

	//output wire	[12: 0] vram_addr;	
	//output wire			CPU_wait, vram_we;
	//output reg 			data_ram_we, GPIOfffffe00_we, GPIOffffff00_we, counter_we, ps2_rd;
	output reg 				GPIOfffffe00_we, GPIOffffff00_we, counter_we;
	//output reg	[31: 0] Cpu_data4bus, ram_data_in, Peripheral_in;
	output reg	[31: 0] Peripheral_in;
	//output reg	[11: 0] ram_addr;
	//output reg	[10: 0] vram_data_in;



	wire 				counter_over;
	reg 	[31: 0] 	Cpu_data2bus, Cpu_data4bus;
	reg					wea;
	//reg 				vram_write,vram;
	//reg 				ready;
	//reg 		[12: 0] cpu_vram_addr;


	//assign CPU_wait 	= vram ? vga_rdn && ready : 1'b1; // ~vram &&
	//always@(posedge clk or posedge rst)
	//	if( rst ) 
	//		ready <= 1; 
	//	else 
	//		ready <= vga_rdn;

	//assign vram_we 	 	= vga_rdn && vram_write; //CPU_wait &
	//assign vram_addr 	= ~vga_rdn? vga_addr : cpu_vram_addr;

	assign ack_o = stb_i;
	always @(posedge clk) begin
		if(stb_i && ack_o) begin
				if(we_i) begin //write
					Cpu_data2bus <= dat_i;
					wea <= 1;
				end
				else begin //read
					wea <= 0;
					dat_o <= Cpu_data4bus;
				end
		end
		else begin
			wea <= 0;
		end
	end

	//RAM & IO decode signals:
	always @* begin
		//vram 						= 0;
		//data_ram_we  				= 0;
		//vram_write  				= 0;
		counter_we  				= 0;
		GPIOffffff00_we 			= 0;
		GPIOfffffe00_we 			= 0;
		//ps2_rd 						= 0;
		//ram_addr   					= 12'h0;
		//cpu_vram_addr 				= 13'h0;
		//ram_data_in  				= 32'h0;
		//vram_data_in 				= 31'h0;
		Peripheral_in 				= 32'h0;
		//Cpu_data4bus 				= 32'h0;

		casex(addr_bus[31:8])
			//24'h0000xx: begin // data_ram (00000000 - 0000ffff(00000ffc), actually lower 4KB RAM)
			//	data_ram_we 		= mem_w;
			//	ram_addr 			= addr_bus[13:2];
			//	ram_data_in 		= Cpu_data2bus;
			//	Cpu_data4bus 		= ram_data_out;
			//end

			//24'h000cxx: begin // Vram (000c0000 - 000cffff(000012c0), actually lower 4800 * 11bit VRAM)
			//	vram_write 			= mem_w;
			//	vram 				= 1;
			//	cpu_vram_addr 		= addr_bus[14:2];
			//	vram_data_in 		= Cpu_data2bus[31:0];
			//	Cpu_data4bus 		= vga_rdn? {21'h0, vram_out[10:0]} : 32'hx;
			//end

			//24'hffffdx: begin // PS2 (ffffd000 ~ ffffdfff)
			//	ps2_rd  			= ~mem_w;
			//	Peripheral_in   	= Cpu_data2bus; //write NU
			//	Cpu_data4bus  		= {23'h0, ps2_ready, key}; //read from PS2;
			//end

			24'hfffffe: begin // 7 Segement LEDs (fffffe00 - fffffeff, 4 7-seg display)
				GPIOfffffe00_we 	= wea;
				Peripheral_in 		= Cpu_data2bus;
				Cpu_data4bus 		= counter_out; //read from Counter
			end

			24'hffffff: begin // LED (ffffff00-ffffffff0,8 LEDs & counter, ffffff04-fffffff4)
				if( addr_bus[2] ) begin //ffffff04 for addr of counter
					counter_we 		= wea;
					Peripheral_in 	= Cpu_data2bus; //write Counter Value
					Cpu_data4bus 	= counter_out; //read from Counter;
				end
				else begin 		// ffffff00
					GPIOffffff00_we = wea;
					Peripheral_in 	= Cpu_data2bus; //write Counter set & Initialization and light LED
					Cpu_data4bus 	= {counter0_out, counter1_out, counter2_out, 9'h000, led_out, BTN, SW};
				end
	 		end
	 	endcase
	end // always end

endmodule

