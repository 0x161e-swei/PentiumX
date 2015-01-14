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


//`define 		WB_USE_TRISTATE


module wb_conbus_top(
	clk_i, rst_i,

	// Master 0 Interface
	m0_irq_o, m0_ack_i,

	// Device 0 Interface
	d0_irq_i, d0_ack_o,

	// Device 1 Interface
	d1_irq_i, d1_ack_o,

	// Device 2 Interface
	d2_irq_i, d2_ack_o,

	// Device 3 Interface
	d3_irq_i, d3_ack_o,

	// Device 4 Interface
	d4_irq_i, d4_ack_o,

	// Device 5 Interface
	d5_irq_i, d5_ack_o,

	// Device 6 Interface
	d6_irq_i, d6_ack_o,

	// Device 7 Interface
	d7_irq_i, d7_ack_o,
);

	////////////////////////////////////////////////////////////////////
	//
	// Module IOs
	//

	input				clk_i, rst_i;

	// Master 0 Interface
	input				m0_ack_i;
	output				m0_irq_o;

	// Slave 0 Interface
	input				d0_irq_i;
	output				d0_ack_o;

	// Slave 1 Interface
	input				d1_irq_i;
	output				d1_ack_o;

	// Slave 2 Interface
	input				d2_irq_i;
	output				d2_ack_o;

	// Slave 3 Interface
	input				d3_irq_i;
	output				d3_ack_o;

	// Slave 4 Interface
	input				d4_irq_i;
	output				d4_ack_o;

	// Slave 5 Interface
	input				d5_irq_i;
	output				d5_ack_o;

	// Slave 6 Interface
	input				d6_irq_i;
	output				d6_ack_o;


	// Slave 7 Interface
	input				d7_irq_i;
	output				d7_ack_o;


	////////////////////////////////////////////////////////////////////
	//
	// Local wires
	//

	wire	[	5:	0]	i_gnt_arb;
	wire	[	2:	0]	gnt;
	reg					i_bus_irq;		// internal share bus, master data and control to slave
	wire				i_bus_ack;		// internal share bus , slave control to master



	////////////////////////////////////////////////////////////////////
	//
	// Master output Interfaces
	//

	// devices
	assign  d0_ack_o = i_bus_ack & i_gnt_arb[0];

	assign  d1_ack_o = i_bus_ack & i_gnt_arb[1];

	assign  d2_ack_o = i_bus_ack & i_gnt_arb[2];

	assign  d3_ack_o = i_bus_ack & i_gnt_arb[3];

	assign  d4_ack_o = i_bus_ack & i_gnt_arb[4];



	// TODO: modify i_bus_s to fit number of slaves
	assign  i_bus_ack = { m0_ack_i }; //s5_ack_i | s6_ack_i | s7_ack_i};

	////////////////////////////////
	//	Slave output interface
	//
	// slave1

	assign	m0_irq_o = i_bus_irq;


	///////////////////////////////////////
	//	Master and Slave input interface
	//

	always @(gnt, 	
		d0_irq_i,
		d1_irq_i,
		d2_irq_i,
		d3_irq_i,
		d4_irq_i)
	begin	  
		case(gnt)
			3'h0:	i_bus_irq = d0_irq_i;
			3'h1:	i_bus_irq = d1_irq_i;
			3'h2:	i_bus_irq = d2_irq_i;
			3'h3:	i_bus_irq = d3_irq_i;
			3'h4:	i_bus_irq = d4_irq_i;
			default:i_bus_irq =  0;	//{m0_adr_i, m0_sel_i, m0_dat_i, m0_we_i, m0_cab_i, m0_cyc_i,m0_stb_i};
		endcase			
	end

	//
	// arbitor 
	//
	assign i_gnt_arb[0] = (gnt == 3'd0);
	assign i_gnt_arb[1] = (gnt == 3'd1);
	assign i_gnt_arb[2] = (gnt == 3'd2);
	assign i_gnt_arb[3] = (gnt == 3'd3);
	assign i_gnt_arb[4] = (gnt == 3'd4);

	irq_arb	irq_arb(
		.clk(clk_i), 
		.rst(rst_i),
		.req(
			{d4_irq_i,
			 d3_irq_i,
			 d2_irq_i,
			 d1_irq_i,
			 d0_irq_i}
			),
		.gnt(gnt)
	);


endmodule

