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
						gntInt,
						Ireq,
						Iack,
    					pc_out,	
						Inst,	   
						mem_w,	
						Addr_out,	
						data_out,						
						CPU_MIO,
						state,
                        cpu_stb_o,
                        intrrupt_en_o
						);

	input wire 			clk, reset, MIO_ready;
    input wire 	[31: 0]	data_in;	
    input wire 	[ 3: 0] gntInt;							// INT grant
    input wire 			Ireq;							// INT request
	
    output wire [31: 0] pc_out, Inst;	//test
	output wire [31: 0] Addr_out, data_out;						
	output wire [ 4: 0] state;
	output wire 		mem_w, CPU_MIO;	
    output wire         cpu_stb_o, Iack, intrrupt_en_o;	// Bus requset and 
    													// Interrupt acknowlegement

	wire 		[31: 0] PC_Current;
	wire 		[15: 0] imm;
	wire 		[ 4: 0] InTcause;						// Int cause, either syscall or INT
	wire 		[ 3: 0] ALU_operation;
	wire 		[ 1: 0] RegDst, ALUSrcB, ALUSrcA;
    wire        [ 2: 0] MemtoReg;
	wire 		[ 2: 0] PCSource;
	wire 				MemRead, MemWrite, IorD, IRWrite, RegWrite, 
						PCWrite, PCWriteCond, Beq, data2Mem, zero, 
						overflow, Signext, WriteEPC, WriteCause, 
						WriteCp0, sysCause, WriteInt, Int_enm;			



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
 					.overflow 			(overflow),
 					.Ireq 				(Ireq),
 					.Iack 				(Iack),
 					.Signext			(Signext),
 					.WriteEPC			(WriteEPC), 
					.WriteCause			(WriteCause), 
					.WriteCp0			(WriteCp0), 
					.sysCause			(sysCause),
					.WriteIen 			(WriteIen),
					.Int_en 			(Int_en)
 					);

 		assign InTcause		= {gntInt & {4{Ireq}}, sysCause};				// TODO: to be precise

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
					.overflow 			(overflow),
					.Signext			(Signext),
					.WriteEPC			(WriteEPC), 
					.WriteCause			(WriteCause), 
					.WriteCp0			(WriteCp0), 
					.InTcause			(InTcause),
					.WriteIen 			(WriteIen),
					.Int_en				(Int_en),
					.intrrupt_en_o 		(intrrupt_en_o)
					);

    
	assign mem_w 	    = MemWrite && ~MemRead;
	assign cpu_stb_o    = MemWrite | MemRead;			// Used for wishbone interface 
	assign pc_out	    = PC_Current;



endmodule
