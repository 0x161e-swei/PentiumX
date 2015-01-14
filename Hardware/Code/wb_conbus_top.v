/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE Connection Bus Top Level		                 	 ////
////                                                             ////
////                                                             ////
////  Author: Johny Chi			                         		 ////
////          chisuhua@yahoo.com.cn                              ////
////          skar.Wei                                           ////
////                                                             ////
////                                                             ////
//// 															 ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                ////
//// Copyright (C) 2014-2015 	skar.Wei<dtsps.skar@gmail.com>   ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation;////
//// either version 2.1 of the License, or (at your option) any  ////
//// later version.                                              ////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details.                                                    ////
////                                                             ////
//// You should have received a copy of the GNU Lesser General   ////
//// Public License along with this source; if not, download it  ////
//// from http://www.opencores.org/lgpl.shtml                    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
//
//  Description
//	1. Up to 8 masters and 8 slaves share bus Wishbone connection
//	2. no priorty arbitor , 8 masters are processed in a round
//	   robin way,
//	3. if WB_USE_TRISTATE was defined, the share bus is a tristate
//	   bus, and use less logic resource.
//	4. wb_conbus was synthesis to XC2S100-5-PQ208 using synplify,
//     Max speed >60M , and 374 SLICE if using Multiplexor bus
//		or 150 SLICE if using tri-state bus.
//

`include "wb_conbus_defines.v"


//`define 		WB_USE_TRISTATE


module wb_conbus_top(
	clk_i, rst_i,

	// Master 0 Interface
	m0_dat_i, m0_dat_o, m0_adr_i, m0_sel_i, m0_we_i,
	m0_stb_i, m0_ack_o,

	// Master 1 Interface
	m1_dat_i, m1_dat_o, m1_adr_i, m1_sel_i, m1_we_i,
	m1_stb_i, m1_ack_o, 


	// Slave 0 Interface
	s0_dat_i, s0_dat_o, s0_adr_o, s0_sel_o, s0_we_o,
	s0_stb_o, s0_ack_i,

	// Slave 1 Interface
	s1_dat_i, s1_dat_o, s1_adr_o, s1_sel_o, s1_we_o,
	s1_stb_o, s1_ack_i,

	// Slave 2 Interface
	s2_dat_i, s2_dat_o, s2_adr_o, s2_sel_o, s2_we_o,
	s2_stb_o, s2_ack_i,

	// Slave 3 Interface
	s3_dat_i, s3_dat_o, s3_adr_o, s3_sel_o, s3_we_o,
	s3_stb_o, s3_ack_i,

	// Slave 4 Interface
	s4_dat_i, s4_dat_o, s4_adr_o, s4_sel_o, s4_we_o,
	s4_stb_o, s4_ack_i,

	// Slave 5 Interface
	s5_dat_i, s5_dat_o, s5_adr_o, s5_sel_o, s5_we_o,
	s5_stb_o, s5_ack_i,

	// Slave 6 Interface
	s6_dat_i, s6_dat_o, s6_adr_o, s6_sel_o, s6_we_o,
	s6_stb_o, s6_ack_i,

	// Slave 7 Interface
	s7_dat_i, s7_dat_o, s7_adr_o, s7_sel_o, s7_we_o,
	s7_stb_o, s7_ack_i
);

	////////////////////////////////////////////////////////////////////
	//
	// Module Parameters
	//


	parameter			s0_addr_w 	= 8 ;			// slave 0 address decode width, 
	parameter			s0_addr 	= 8'hfe;		// slave 0, UART address
	parameter			s1_addr_w 	= 16;			
	parameter			s1_addr 	= 16'h000c;		// slave 1, VRAM address 
	parameter 			s2_addr_w 	= 16;			
	parameter			s2_addr 	= 16'h0000;		// slave 2, MainMem  address
	parameter			s37_addr_w 	= 20;			// slave 3 to slave 7 address decode width
	parameter			s3_addr 	= 20'hfffff;	// slave 3, MIO address
	parameter			s4_addr 	= 20'hffffd;	// slave 4, PS2 address
	parameter			s5_addr 	= 8'hff;		// slave 5 address, not yet in use for timer maybe
	parameter			s6_addr 	= 8'hfc;		// slave 6 address, not yet in use for sdCard maybe
	parameter			s7_addr 	= 8'hfd;		// slave 7 address, not yet in use


	////////////////////////////////////////////////////////////////////
	//
	// Module IOs
	//

	input				clk_i, rst_i;

	// Master 0 Interface
	input	[`dw-1:0]	m0_dat_i;
	output	[`dw-1:0]	m0_dat_o;
	input	[`aw-1:0]	m0_adr_i;
	input	[`sw-1:0]	m0_sel_i;
	input				m0_we_i;
	input				m0_stb_i;
	output				m0_ack_o;

	// Master 1 Interface
	input	[`dw-1:0]	m1_dat_i;
	output	[`dw-1:0]	m1_dat_o;
	input	[`aw-1:0]	m1_adr_i;
	input	[`sw-1:0]	m1_sel_i;
	input				m1_we_i;
	input				m1_stb_i;
	output				m1_ack_o;


	// Slave 0 Interface
	input	[`dw-1:0]	s0_dat_i;
	output	[`dw-1:0]	s0_dat_o;
	output	[`aw-1:0]	s0_adr_o;
	output	[`sw-1:0]	s0_sel_o;
	output				s0_we_o;
	output				s0_stb_o;
	input				s0_ack_i;

	// Slave 1 Interface
	input	[`dw-1:0]	s1_dat_i;
	output	[`dw-1:0]	s1_dat_o;
	output	[`aw-1:0]	s1_adr_o;
	output	[`sw-1:0]	s1_sel_o;
	output				s1_we_o;
	output				s1_stb_o;
	input				s1_ack_i;

	// Slave 2 Interface
	input	[`dw-1:0]	s2_dat_i;
	output	[`dw-1:0]	s2_dat_o;
	output	[`aw-1:0]	s2_adr_o;
	output	[`sw-1:0]	s2_sel_o;
	output				s2_we_o;
	output				s2_stb_o;
	input				s2_ack_i;

	// Slave 3 Interface
	input	[`dw-1:0]	s3_dat_i;
	output	[`dw-1:0]	s3_dat_o;
	output	[`aw-1:0]	s3_adr_o;
	output	[`sw-1:0]	s3_sel_o;
	output				s3_we_o;
	output				s3_stb_o;
	input				s3_ack_i;

	// Slave 4 Interface
	input	[`dw-1:0]	s4_dat_i;
	output	[`dw-1:0]	s4_dat_o;
	output	[`aw-1:0]	s4_adr_o;
	output	[`sw-1:0]	s4_sel_o;
	output				s4_we_o;
	output				s4_stb_o;
	input				s4_ack_i;

	// Slave 5 Interface
	input	[`dw-1:0]	s5_dat_i;
	output	[`dw-1:0]	s5_dat_o;
	output	[`aw-1:0]	s5_adr_o;
	output	[`sw-1:0]	s5_sel_o;
	output				s5_we_o;
	output				s5_stb_o;
	input				s5_ack_i;

	// Slave 6 Interface
	input	[`dw-1:0]	s6_dat_i;
	output	[`dw-1:0]	s6_dat_o;
	output	[`aw-1:0]	s6_adr_o;
	output	[`sw-1:0]	s6_sel_o;
	output				s6_we_o;
	output				s6_stb_o;
	input				s6_ack_i;


	// Slave 7 Interface
	input	[`dw-1:0]	s7_dat_i;
	output	[`dw-1:0]	s7_dat_o;
	output	[`aw-1:0]	s7_adr_o;
	output	[`sw-1:0]	s7_sel_o;
	output				s7_we_o;
	output				s7_stb_o;
	input				s7_ack_i;


	////////////////////////////////////////////////////////////////////
	//
	// Local wires
	//

	wire	[`mselectw - 1:	0]	i_gnt_arb;
	wire						gnt;
	reg		[`sselectw - 1:	0]	i_ssel_dec;
	reg		[`mbusw - 1   :	0]	i_bus_m;		// internal share bus, master data and control to slave
	wire	[`dw - 1      : 0]	i_dat_s;		// internal share bus , slave data to master
	wire	[`sbusw - 1   :	0]	i_bus_s;		// internal share bus , slave control to master



	////////////////////////////////////////////////////////////////////
	//
	// Master output Interfaces
	//

	// master0
	assign	m0_dat_o = i_dat_s;
	assign  m0_ack_o = i_bus_s & i_gnt_arb[0];

	// master1
	assign	m1_dat_o = i_dat_s;
	assign  m1_ack_o = i_bus_s & i_gnt_arb[1];

	// TODO: modify i_bus_s to fit number of slaves
	assign  i_bus_s = { s0_ack_i | s1_ack_i | s2_ack_i | s3_ack_i | s4_ack_i }; //s5_ack_i | s6_ack_i | s7_ack_i};

	////////////////////////////////
	//	Slave output interface
	//
	// slave0
	assign  {s0_adr_o, s0_sel_o, s0_dat_o, s0_we_o} = i_bus_m[`mbusw -1:1];
	assign	s0_stb_o = i_bus_m[0] & i_ssel_dec[0];  // stb_o = cyc_i & stb_i & i_ssel_dec

	// slave1

	assign  {s1_adr_o, s1_sel_o, s1_dat_o, s1_we_o} = i_bus_m[`mbusw -1:1];
	assign	s1_stb_o = i_bus_m[0] & i_ssel_dec[1];

	// slave2

	assign  {s2_adr_o, s2_sel_o, s2_dat_o, s2_we_o} = i_bus_m[`mbusw -1:1];
	assign	s2_stb_o = i_bus_m[0] & i_ssel_dec[2];

	// slave3

	assign  {s3_adr_o, s3_sel_o, s3_dat_o, s3_we_o} = i_bus_m[`mbusw -1:1];
	assign	s3_stb_o = i_bus_m[0] & i_ssel_dec[3];

	// slave4

	assign  {s4_adr_o, s4_sel_o, s4_dat_o, s4_we_o} = i_bus_m[`mbusw -1:1];
	assign	s4_stb_o = i_bus_m[0] & i_ssel_dec[4];

	// slave5

	assign  {s5_adr_o, s5_sel_o, s5_dat_o, s5_we_o} = i_bus_m[`mbusw -1:1];
	assign	s5_stb_o = i_bus_m[0] & i_ssel_dec[5];

	// slave6

	assign  {s6_adr_o, s6_sel_o, s6_dat_o, s6_we_o} = i_bus_m[`mbusw -1:1];
	assign	s6_stb_o = i_bus_m[0] & i_ssel_dec[6];

	// slave7

	assign  {s7_adr_o, s7_sel_o, s7_dat_o, s7_we_o} = i_bus_m[`mbusw -1:1];
	assign	s7_stb_o = i_bus_m[0] & i_ssel_dec[7];

	///////////////////////////////////////
	//	Master and Slave input interface
	//

	always @(gnt, 	
		m0_adr_i, m0_sel_i, m0_dat_i, m0_we_i, m0_stb_i,
		m1_adr_i, m1_sel_i, m1_dat_i, m1_we_i, m1_stb_i)
	begin	  
		case(gnt)
			1'h0:	i_bus_m = {m0_adr_i, m0_sel_i, m0_dat_i, m0_we_i, m0_stb_i};
			1'h1:	i_bus_m = {m1_adr_i, m1_sel_i, m1_dat_i, m1_we_i, m1_stb_i};
			default:i_bus_m =  72'b0;	//{m0_adr_i, m0_sel_i, m0_dat_i, m0_we_i, m0_cab_i, m0_cyc_i,m0_stb_i};
		endcase			
	end

	assign	i_dat_s = i_ssel_dec[0] ? s0_dat_i :
					  i_ssel_dec[1] ? s1_dat_i :
					  i_ssel_dec[2] ? s2_dat_i :
					  i_ssel_dec[3] ? s3_dat_i :
					  i_ssel_dec[4] ? s4_dat_i :
					  i_ssel_dec[5] ? s5_dat_i :
					  i_ssel_dec[6] ? s6_dat_i :
					  i_ssel_dec[7] ? s7_dat_i : {`dw'b0}; 

	//
	// arbitor 
	//
	assign i_gnt_arb[0] = (gnt == 1'd0);
	assign i_gnt_arb[1] = (gnt == 1'd1);

	wb_conbus_arb	wb_conbus_arb(
		.clk(clk_i), 
		.rst(rst_i),
		.req(
			{m1_stb_i,
			 m0_stb_i}
			),
		.gnt(gnt)
	);

	//////////////////////////////////
	// 		address decode logic
	//
	wire [7:0]	m0_ssel_dec, m1_ssel_dec;
	always @(gnt, m0_ssel_dec, m1_ssel_dec)
		case(gnt)
			1'h0: i_ssel_dec = m0_ssel_dec;
			1'h1: i_ssel_dec = m1_ssel_dec;
			default: i_ssel_dec = 7'b0;
	endcase

	//
	//	decode all master address before arbitor for running faster
	//	
	assign m0_ssel_dec[0] = (m0_adr_i[`aw -1 : `aw - s0_addr_w ] == s0_addr);
	assign m0_ssel_dec[1] = (m0_adr_i[`aw -1 : `aw - s1_addr_w ] == s1_addr);
	assign m0_ssel_dec[2] = (m0_adr_i[`aw -1 : `aw - s2_addr_w ] == s2_addr);
	assign m0_ssel_dec[3] = (m0_adr_i[`aw -1 : `aw - s37_addr_w ] == s3_addr);
	assign m0_ssel_dec[4] = (m0_adr_i[`aw -1 : `aw - s37_addr_w ] == s4_addr);
	assign m0_ssel_dec[5] = 0; // (m0_adr_i[`aw -1 : `aw - s37_addr_w ] == s5_addr);
	assign m0_ssel_dec[6] = 0; // (m0_adr_i[`aw -1 : `aw - s37_addr_w ] == s6_addr);
	assign m0_ssel_dec[7] = 0; // (m0_adr_i[`aw -1 : `aw - s37_addr_w ] == s7_addr);

	assign m1_ssel_dec[0] = (m1_adr_i[`aw -1 : `aw - s0_addr_w ] == s0_addr);
	assign m1_ssel_dec[1] = (m1_adr_i[`aw -1 : `aw - s1_addr_w ] == s1_addr);
	assign m1_ssel_dec[2] = (m1_adr_i[`aw -1 : `aw - s2_addr_w ] == s2_addr);
	assign m1_ssel_dec[3] = (m1_adr_i[`aw -1 : `aw - s37_addr_w ] == s3_addr);
	assign m1_ssel_dec[4] = (m1_adr_i[`aw -1 : `aw - s37_addr_w ] == s4_addr);
	assign m1_ssel_dec[5] = 0; // (m1_adr_i[`aw -1 : `aw - s37_addr_w ] == s5_addr);
	assign m1_ssel_dec[6] = 0; // (m1_adr_i[`aw -1 : `aw - s37_addr_w ] == s6_addr);
	assign m1_ssel_dec[7] = 0; // (m1_adr_i[`aw -1 : `aw - s37_addr_w ] == s7_addr);

	// assign i_ssel_dec[0] = (i_bus_m[`mbusw -1 : `mbusw - s0_addr_w ] == s0_addr);
	// assign i_ssel_dec[1] = (i_bus_m[`mbusw -1 : `mbusw - s1_addr_w ] == s1_addr);
	// assign i_ssel_dec[2] = (i_bus_m[`mbusw -1 : `mbusw - s27_addr_w ] == s2_addr);
	// assign i_ssel_dec[3] = (i_bus_m[`mbusw -1 : `mbusw - s27_addr_w ] == s3_addr);
	// assign i_ssel_dec[4] = (i_bus_m[`mbusw -1 : `mbusw - s27_addr_w ] == s4_addr);
	// assign i_ssel_dec[5] = (i_bus_m[`mbusw -1 : `mbusw - s27_addr_w ] == s5_addr);
	// assign i_ssel_dec[6] = (i_bus_m[`mbusw -1 : `mbusw - s27_addr_w ] == s6_addr);
	// assign i_ssel_dec[7] = (i_bus_m[`mbusw -1 : `mbusw - s27_addr_w ] == s7_addr);


endmodule

