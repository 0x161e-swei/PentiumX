`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:00:21 05/08/2014 
// Design Name: 
// Module Name:    multi_cycle_Cpu 
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
module Muliti_cycle_Cpu( 
						clk,
						reset,
						MIO_ready,
    					data_in,	
	
    					pc_out,	
						Inst,	   
						mem_w,	
						Addr_out,	
						data_out,						
						CPU_MIO,
						state
						);

	input wire 			clk, reset, MIO_ready;
    input wire 	[31: 0]	data_in;	
	
    output wire [31: 0] pc_out, Inst;	//test
	output wire [31: 0] Addr_out, data_out;						
	output wire [ 4: 0] state;
	output wire 		mem_w, CPU_MIO;	


	wire 		[31: 0] PC_Current;
	wire 		[15: 0] imm;
	wire 		[ 3: 0] ALU_operation;
	wire 		[ 1: 0] RegDst, MemtoReg, ALUSrcB, PCSource, ALUSrcA;
	wire 				MemRead, MemWrite, IorD, IRWrite, RegWrite, PCWrite, PCWriteCond, Beq, data2Mem, zero, overflow;			



 	ctrl 			M1(
 					.clk 				(clk),
 					.reset 				(reset),
 					.Inst 				(Inst),
 					.MIO_ready			(MIO_ready),
 					.MemRead 			(MemRead),
 					.MemWrite 			(MemWrite),
 					.CPU_MIO 			(CPU_MIO),
 					.IorD 				(IorD),
 					.IRWrite 			(IRWrite),
 					.RegDst 			(RegDst),
 					.RegWrite 			(RegWrite),
 					.MemtoReg 			(MemtoReg),
					.data2Mem 			(data2Mem),
 					.ALUSrcA 			(ALUSrcA),
 					.ALUSrcB 			(ALUSrcB),
 					.PCSource 			(PCSource),
 					.PCWrite 			(PCWrite),
 					.PCWriteCond		(PCWriteCond),
 					.Beq 				(Beq),
 					.ALU_operation		(ALU_operation),
 					.state_out			(state),
 					.zero				(zero),
 					.overflow 			(overflow)
 					);

	data_path M2(
					.clk 				(clk),
					.reset 				(reset),
					.MIO_ready 			(MIO_ready),
			
					.IorD 				(IorD),
					.IRWrite 			(IRWrite),
					.RegDst 			(RegDst),
					.RegWrite 			(RegWrite),
					.MemtoReg 			(MemtoReg),
					.data2Mem 			(data2Mem),
					.ALUSrcA 			(ALUSrcA),
					.ALUSrcB 			(ALUSrcB),
					.PCSource			(PCSource),
					.PCWrite 			(PCWrite),
					.PCWriteCond 		(PCWriteCond),
					.Beq 				(Beq),
					
					.ALU_operation		(ALU_operation),
					.PC_Current 		(PC_Current),
					.data2CPU 			(data_in),
					.Inst_R 			(Inst),
					.data_out 	 		(data_out),
					.M_addr 			(Addr_out),
					.zero 				(zero),
					.overflow 			(overflow)
					);


	assign mem_w 	= MemWrite && ~MemRead;
	assign stb_o 	= MemWrite | MemRead;			// Used for wishbone interface 
	assign pc_out	= PC_Current;
	


endmodule
