`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:40:07 08/24/2014 
// Design Name: 
// Module Name:    Top_N3_Computer_IOBUS_VGA_PS2 
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
`define			dw	 32						// Data bus Width
`define			aw	 32						// Address bus Width
`define			sw   `dw / 8				// Number of Select Lines

module Top_N3_Computer_IOBUS_VGA_PS2(
									clk_100mhz,
									BTN,
									// I/O:
									SW,
									LED,
									SEGMENT,
									AN_SEL,
									PS2_clk, PS2_Data,
									Red,
									Green,
									Blue,
									HSYNC, 
                                    VSYNC
									);

//for wb input and output ---------------------------------------------------
// Master 0 Interface
	wire	[`dw-1:0]	m0_dat_i;
	wire	[`dw-1:0]	m0_dat_o;
	wire	[`aw-1:0]	m0_adr_i;
	wire	[`sw-1:0]	m0_sel_i;
	wire				m0_we_i;
	wire				m0_stb_i;
	wire				m0_ack_o;

	// Master 1 Interface
	wire	[`dw-1:0]	m1_dat_i;
	wire	[`dw-1:0]	m1_dat_o;
	wire	[`aw-1:0]	m1_adr_i;
	wire	[`sw-1:0]	m1_sel_i;
	wire				m1_we_i;
	wire				m1_stb_i;
	wire				m1_ack_o;


	// Slave 0 Interface
	wire	[`dw-1:0]	s0_dat_i;
	wire	[`dw-1:0]	s0_dat_o;
	wire	[`aw-1:0]	s0_adr_o;
	wire	[`sw-1:0]	s0_sel_o;
	wire				s0_we_o;
	wire				s0_stb_o;
	wire				s0_ack_i;

	// Slave 1 Interface
	wire	[`dw-1:0]	s1_dat_i;
	wire	[`dw-1:0]	s1_dat_o;
	wire	[`aw-1:0]	s1_adr_o;
	wire	[`sw-1:0]	s1_sel_o;
	wire				s1_we_o;
	wire				s1_stb_o;
	wire				s1_ack_i;

	// Slave 2 Interface
	wire	[`dw-1:0]	s2_dat_i;
	wire	[`dw-1:0]	s2_dat_o;
	wire	[`aw-1:0]	s2_adr_o;
	wire	[`sw-1:0]	s2_sel_o;
	wire				s2_we_o;
	wire				s2_stb_o;
	wire				s2_ack_i;

	// Slave 3 Interface
	wire	[`dw-1:0]	s3_dat_i;
	wire	[`dw-1:0]	s3_dat_o;
	wire	[`aw-1:0]	s3_adr_o;
	wire	[`sw-1:0]	s3_sel_o;
	wire				s3_we_o;
	wire				s3_stb_o;
	wire				s3_ack_i;

	// Slave 4 Interface
	wire	[`dw-1:0]	s4_dat_i;
	wire	[`dw-1:0]	s4_dat_o;
	wire	[`aw-1:0]	s4_adr_o;
	wire	[`sw-1:0]	s4_sel_o;
	wire				s4_we_o;
	wire				s4_stb_o;
	wire				s4_ack_i;

	// Slave 5 Interface
	wire	[`dw-1:0]	s5_dat_i;
	wire	[`dw-1:0]	s5_dat_o;
	wire	[`aw-1:0]	s5_adr_o;
	wire	[`sw-1:0]	s5_sel_o;
	wire				s5_we_o;
	wire				s5_stb_o;
	wire				s5_ack_i;

	// Slave 6 Interface
	wire	[`dw-1:0]	s6_dat_i;
	wire	[`dw-1:0]	s6_dat_o;
	wire	[`aw-1:0]	s6_adr_o;
	wire	[`sw-1:0]	s6_sel_o;
	wire				s6_we_o;
	wire				s6_stb_o;
	wire				s6_ack_i;


	// Slave 7 Interface
	wire	[`dw-1:0]	s7_dat_i;
	wire	[`dw-1:0]	s7_dat_o;
	wire	[`aw-1:0]	s7_adr_o;
	wire	[`sw-1:0]	s7_sel_o;
	wire				s7_we_o;
	wire				s7_stb_o;
	wire				s7_ack_i;
	
//----------------------------------------------------------



	input               clk_100mhz;
    input               PS2_clk, PS2_Data;
	input       [ 3: 0] BTN;
	input       [ 7: 0] SW;
	
	output      [ 7: 0] LED, SEGMENT;
	output      [ 3: 0] AN_SEL;
	output      [ 2: 0] Red, Green;
	output      [ 1: 0] Blue;
	output              HSYNC, VSYNC;

    // Variable Declarations
	wire                Clk_CPU, rst,clk_m, mem_w, data_ram_we, GPIOfffffe00_we, GPIOffffff00_we, counter_we;
	wire                counter_OUT0, counter_OUT1, counter_OUT2;
	wire        [ 1: 0] Counter_set;
	wire        [ 4: 0] state;
	wire        [ 3: 0] digit_anode, blinke;
	wire        [ 3: 0] button_out;
	wire        [ 7: 0] SW_OK, SW, ps2_key, led_out, LED, SEGMENT; //led_out is current LED light
	wire        [11: 0] ram_addr;
	wire        [21: 0] GPIOf0;
	wire        [31: 0] pc, Inst, cpu_addr, Cpu_data2bus, ram_data_out, disp_num;
	wire        [31: 0] clkdiv, Cpu_data4bus, counter_out, ram_data_in, Peripheral_in;
	wire        [31: 0] vram_out, vram_data_in;
	wire        [10: 0] vram_addr, vga_addr;
	wire                MIO_ready;
	wire                CPU_MIO, vga_rdn;
	wire        [31: 0] key_d;
	wire        [ 7: 0] key;
    reg                 key_ready;
	// assign MIO_ready=~button_out[1];


	//assign rst=button_out[3];
	assign rst         = BTN[3];
	assign SW2         = SW_OK[2];
	assign LED         = {led_out[7] | Clk_CPU, led_out[ 6: 0]};
	assign clk_m       = clk_100mhz;           	// ;~Clk_CPU
	assign AN_SEL      = digit_anode;
	assign clk_io      = ~Clk_CPU;             	// ~Clk_CPU; ~clk_100mhz
	
	wire [12:0] Cursor = GPIOf0[12: 0];
	wire text_Cursor_switch = GPIOf0[21]; 		// Disable Text Cursor

    BUFG VGA_CLOCK_BUF(.O(VGA_clk), .I(clkdiv[1]));
    // BUFG Key_CLOCK_BUF(.O(Key_clk), .I(clkdiv[2]));

	seven_seg      U6(
                    .disp_num           (disp_num),
			 	    .clk                (clk_100mhz),
			 	    .clr                (rst),
			 	    .SW                 (SW_OK[ 1: 0]),
			 	    .Scanning           (clkdiv[19:18]),
			 	    .SEGMENT            (SEGMENT),
			 	    .AN                 (digit_anode)
			 	    );

	BTN_Anti_jitter U9(
                    clk_100mhz, 
                    BTN,
                    SW, 
                    button_out,
                    SW_OK
                    );

	clk_div         U8(
                    clk_100mhz,
				    rst,
				    SW2,
				    clkdiv,
				    Clk_CPU
				    ); // Clock divider-



	//++++++++++++++++++++++muliti_cycle_cpu+++++++++++++++++++++++++++++++++++++++++++
	Muliti_cycle_Cpu U1(
                    .clk                (Clk_CPU),
					.reset              (rst),
					.MIO_ready          (MIO_ready), 		// MIO_ready

					// Internal signals:
					.pc_out             (pc), 				// Test
					.Inst               (Inst), 			// Test
					.mem_w              (mem_w),
					.Addr_out           (cpu_addr),
					.data_out           (Cpu_data2bus),
					.data_in            (Cpu_data4bus),
					.CPU_MIO            (CPU_MIO),
					.state              (state) 			// Test
					);

	// data RAM (2048¡Á32)
	Mem_I_D       	U2(
					//wb_input
					.dat_i				(s0_dat_o), 
					.adr_i				(s0_adr_o), 
					.we_i				(s0_we_o),
					.stb_i				(s0_stb_o),
					//wb_output
					.dat_o				(s0_dat_i), 				
					.ack_o				(s0_ack_i),

                    .clk                (clk_m),
			        .W_En               (data_ram_we),
			        .Addr               (ram_addr),
			        .D_In               (ram_data_in),
        			.D_Out              (ram_data_out)
        			); // Addre_Bus [9 : 0] ,Data_Bus [31 : 0]

	// VRAM (4800¡Á11)
	Vram_B        	U3(
					//wb_input
					.dat_i				(s1_dat_o), 
					.adr_i				(s1_adr_o), 
					.we_i				(s1_we_o),
					.stb_i				(s1_stb_o),
					//wb_output
					.dat_o				(s1_dat_i), 				
					.ack_o				(s1_ack_i),

                    .clk               	(clk_m),
			        .W_En               (vram_we),
        			.Addr              	(vram_addr),
        		  	.D_In               (vram_data_in),
			        .D_Out              (vram_out)
					);

	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	wb_conbus_top UU4(
					.clk_i(clk_100mhz), .rst_i(rst),

					// Master 0 Interface
					.m0_dat_i(m0_dat_i), .m0_dat_o(m0_dat_o), .m0_adr_i(m0_adr_i), .m0_sel_i(m0_sel_i), .m0_we_i(m0_we_i),
					.m0_stb_i(m0_stb_i), .m0_ack_o(m0_ack_o),

					// Master 1 Interface
					.m1_dat_i(m1_dat_i), .m1_dat_o, .m1_adr_i, .m1_sel_i, .m1_we_i,
					.m1_stb_i, .m1_ack_o, 


					// Slave 0 Interface
					.s0_dat_i(s0_dat_i), .s0_dat_o(s0_dat_o), .s0_adr_o(s0_adr_o), .s0_sel_o(s0_sel_o), .s0_we_o(s0_we_o),
					.s0_stb_o(s0_stb_o), .s0_ack_i(s0_ack_i),

					// Slave 1 Interface
					.s1_dat_i(s1_dat_i), .s1_dat_o(s1_dat_o), .s1_adr_o(s1_adr_o), .s1_sel_o(s1_sel_o), .s1_we_o(s1_we_o),
					.s1_stb_o(s1_stb_o), .s1_ack_i(s1_ack_i),

					// Slave 2 Interface
					.s2_dat_i(s2_dat_i), .s2_dat_o(s2_dat_o), .s2_adr_o(s2_adr_o), .s2_sel_o(s2_sel_o), .s2_we_o(s2_we_o),
					.s2_stb_o(s2_stb_o), .s2_ack_i(s2_ack_i),

					// Slave 3 Interface
					.s3_dat_i(s3_dat_i), .s3_dat_o(s3_dat_o), .s3_adr_o(s3_adr_o), .s3_sel_o(s3_sel_o), .s3_we_o(s3_we_o),
					.s3_stb_o(s3_stb_o), .s3_ack_i(s3_ack_i),

					// Slave 4 Interface
					.s4_dat_i(s4_dat_i), .s4_dat_o(s4_dat_o), .s4_adr_o(s4_adr_o), .s4_sel_o(s4_sel_o), .s4_we_o(s4_we_o),
					.s4_stb_o(s4_stb_o), .s4_ack_i(s4_ack_i),

					// Slave 5 Interface
					.s5_dat_i(s5_dat_i), .s5_dat_o(s5_dat_o), .s5_adr_o(s5_adr_o), .s5_sel_o(s5_sel_o), .s5_we_o(s5_we_o),
					.s5_stb_o(s5_stb_o), .s5_ack_i(s5_ack_i),

					// Slave 6 Interface
					.s6_dat_i(s6_dat_i), .s6_dat_o(s6_dat_o), .s6_adr_o(s6_adr_o), .s6_sel_o(s6_sel_o), .s6_we_o(s6_we_o),
					.s6_stb_o(s6_stb_o), .s6_ack_i(s6_ack_i),

					// Slave 7 Interface
					.s7_dat_i(s7_dat_i), .s7_dat_o(s7_dat_o), .s7_adr_o(s7_adr_o), .s7_sel_o(s7_sel_o), .s7_we_o(s7_we_o),
					.s7_stb_o(s7_stb_o), .s7_ack_i(s7_ack_i)
					
					//for MIO_BUS
	);

	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	MIO_BUS       	U4(
					//wb_input
					.dat_i				(s2_dat_o), 
					.adr_i				(s2_adr_o), 
					.we_i				(s2_we_o),
					.stb_i				(s2_stb_o),
					//wb_output
					.dat_o				(s2_dat_i), 				
					.ack_o				(s2_ack_i),

                    .clk                (clk_100mhz),
        			.rst                (rst),
		      	    .BTN                (button_out),
        			.SW                 (SW_OK),
        			//.vga_rdn            (vga_rdn), 			//
        			//.ps2_ready          (ps2_ready),
        			//.mem_w              (mem_w),
        			//.key 				(key),
        			//.Cpu_data2bus 		(Cpu_data2bus), 	// Data from CPU
        			//.addr_bus 			(cpu_addr),
        			//.vga_addr 			(vga_addr),
		      	    //.ram_data_out 		(ram_data_out),
        			//.vram_out 			(vram_out),
        			.led_out 			(led_out),
        			.counter_out 		(counter_out),
        			.counter0_out 		(counter_OUT0),
        			.counter1_out 		(counter_OUT1),
        			.counter2_out 		(counter_OUT2),

        			//.CPU_wait 			(MIO_ready),
        			//.Cpu_data4bus 		(Cpu_data4bus), 	// Data write to CPU
        			//.ram_data_in 		(ram_data_in), 		// From CPU write to Memory
        			//.ram_addr			(ram_addr), 		// Memory Address signals
        			//.vram_data_in 		(vram_data_in), 	// From CPU write to Vram Memory
        			//.vram_addr 			(vram_addr), 		// Vram Address signals
        			//.data_ram_we 		(data_ram_we),
        			//.vram_we 			(vram_we),
        			.GPIOffffff00_we 	(GPIOffffff00_we),
        			.GPIOfffffe00_we 	(GPIOfffffe00_we),
			        .counter_we 		(counter_we),
        			//.ps2_rd 			(ps2_rd),
					.Peripheral_in 		(Peripheral_in)
					);

	//------Peripheral Driver-----------------------------------
	/* GPIO out use on LEDs & Counter-Controler read and write addre=f0000000-ffffffff0
	*/
	Device_GPIO_led U7(
					clk_io,
					rst,
					GPIOffffff00_we,
					Peripheral_in,
					Counter_set,
					led_out,
					GPIOf0
					);

	/* GPIO out use on 7-seg display & CPU state display addre=e0000000-efffffff */
	Device_GPIO_7seg U5( 
					.clk 				(clk_io),
					.rst 				(rst),
					.GPIOfffffe00_we 	(GPIOfffffe00_we),
					.Test 				(SW_OK[7:5]),
					.disp_cpudata		(Peripheral_in), 	// CPU data output
					.Test_data0			(pc), 				// pc[31:2]
					.Test_data1			(counter_out), 		// counter
					.Test_data2			(Inst), 			// Inst
					.Test_data3			(cpu_addr), 		// cpu_addr
					.Test_data4			(Cpu_data2bus), 	// Cpu_data2bus;
					.Test_data5			(key_d), 			// Cpu_data4bus;
					.Test_data6			({ps2_ready, 15'h0, ps2_key, key}),
					//pc;
					.disp_num			(disp_num)
					);

	Counter_x 	   	U10(
					.clk				(clk_io),
					.rst				(rst),
					.clk0				(clkdiv[9]),
					.clk1				(clkdiv[10]),
					.clk2				(clkdiv[10]),
					.counter_we			(counter_we),
					.counter_val 		(Peripheral_in),
					.counter_ch 		(Counter_set),
					.counter0_OUT		(counter_OUT0),
					.counter1_OUT		(counter_OUT1),
					.counter2_OUT		(counter_OUT2),
					.counter_out 		(counter_out)
					);

	/* VGA IO use on display More Information with Text & Graph addre= */
	VGA_IO 			U11(
					.vga_clk 			(VGA_clk),
					.rst    			(rst),
					.vram_out			(vram_out),
					.text_Cursor_switch (text_Cursor_switch),
					.Cursor 			(Cursor),
					.Blink 				(clkdiv[24]),
					.R					(Red),
					.G					(Green),
					.B					(Blue),
					.HSYNC				(HSYNC),
					.VSYNC				(VSYNC),
					.vga_addr			(vga_addr),
					.vga_rdn			(vga_rdn)
					);

	// latch the input key from PS/2 module when ps2_ready signals is asserted,
	// note that the key here is still a scan code, and software needs to transform it into a ASCII code
	assign io_read_clk = Clk_CPU;

	PS2_IO 			U12(
					//wb_input
					.dat_i				(s3_dat_o), 
					.adr_i				(s3_adr_o), 
					.we_i				(s3_we_o),
					.stb_i				(s3_stb_o),
					//wb_output
					.dat_o				(s3_dat_i), 				
					.ack_o				(s3_ack_i),
					
					.io_read_clk 		(io_read_clk),
					.clk_ps2 			(clkdiv[0]),
					.rst 				(rst),
					.PS2_clk 			(PS2_clk),
					.PS2_Data 			(PS2_Data),
					.ps2_rd 			(ps2_rd),

					.ps2_ready 			(ps2_ready),
					.key_d      		(key_d),
					.key 				(key)
					);

endmodule
