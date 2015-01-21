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
				sel_i,
				//wb_output
				dat_o, 				
				ack_o,

				clk,
				Signext
				//W_En,
				//Addr,
				//D_In,
				//D_Out
    			);
	//cpu_read_write		
	input wire [31: 0] 	dat_i;
	input wire [31: 0] 	adr_i;
	input wire	 		we_i;
	input wire 			stb_i;
	output reg [31: 0] 	dat_o;
	output 				ack_o;

	input 				clk;
	input wire 			Signext;
	input wire		[3: 0] sel_i;
	wire [1:0]	byte_offset;
	wire [12:0] ram_addr;
	wire				W_En;
	wire	[ 3: 0]		W_sel;
	wire	[ 3: 0]		wea;
	
	
	assign ram_addr = adr_i[14:2];
	assign byte_offset = adr_i[1:0];

//	(* bram_map="yes" *)
//	reg 	[31: 0] RAM[8191:   0];
	wire		[31: 0] tmp;
	reg		[31: 0] dina = 0;
	reg				first_rd = 0;


//	initial begin
//		$readmemb("../Coe/test_lh.coe",RAM);
//	end

	assign ack_o = stb_i;
	assign W_En = stb_i & ack_o & we_i;
	assign R_En = stb_i & ack_o & ~we_i ;
	assign W_sel = sel_i << byte_offset;
	//assign wea = {W_sel[0], W_sel[1], W_sel[2], W_sel[3]}&{4{W_En}};
	assign wea = W_sel&{4{W_En}};
	
	//wire mem_wr;
	//assign mem_wr = stb_i && ack_o;

	
	always @(*) begin
		case({byte_offset,sel_i}) 
			6'b001111:begin
				dina <= dat_i;
				dat_o <= tmp;
			end
			6'b000011:begin
				//dina <= {dat_i[15:0], 16'h0};
				//dat_o <= Signext?{16'h0, tmp[31:16]}:{{16{tmp[31]}}, tmp[31:16]};
				dina <= {16'h0, dat_i[15:0]};
				dat_o <= Signext?{16'h0, tmp[15:0]}:{{16{tmp[15]}}, tmp[15:0]};
			end
			6'b100011:begin
				//dina <= {16'h0, dat_i[15:0]};
				//dat_o <= Signext?{16'h0, tmp[15:0]}:{{16{tmp[15]}}, tmp[15:0]}; 
				dina <= {dat_i[15:0], 16'h0};
				dat_o <= Signext?{16'h0, tmp[31:16]}:{{16{tmp[31]}}, tmp[31:16]}; 
			end
			default:begin
				dina <= dat_i;
				dat_o <= tmp;
			end
		endcase
	end
	
//	always @(posedge clk) begin
//		//if(W_En) begin //write
//			//case({byte_offset,sel_i})
//				//6'b001111: dina <= dat_i;//tmpReg2 <= dat_i; //sw
//				//6'b000011: dina = {16'h0,dat_i};//tmpReg2 <= {dat_i[15:0], tmpReg[15:0]}; //sh byte_offset=0
//				//6'b100011: dina = {dat_i,16'h0};//tmpReg2 <= {tmpReg[31:16], dat_i[15:0]}; //sh byte_offset=2
//				//6'b000011: dina <= {dat_i[15:0],16'h0};//tmpReg2 <= {dat_i[15:0], tmpReg[15:0]}; //sh byte_offset=0
//				//6'b000011: dina <= {dat_i[15:0], tmp[15:0]};
//				//6'b100011: dina <= {16'h0,dat_i[15:0]};//tmpReg2 <= {tmpReg[31:16], dat_i[15:0]}; //sh byte_offset=2
//				//6'b100011: dina <= {tmp[31:16], dat_i[15:0]};
//			//endcase
//			//RAM[ram_addr] <= tmpReg2;	
//		//end
//		if(R_En) begin //read
//			//dat_o = tmpReg;
////			case({byte_offset,sel_i})
////				6'b001111: dat_o <= tmp; //lw
////				6'b000011: dat_o <= Signext?{16'h0, tmp[31:16]}:{{16{tmp[31]}}, tmp[31:16]}; //lh & lhu byte_offset=0
////				6'b100011: dat_o <= Signext?{16'h0, tmp[15:0]}:{{16{tmp[15]}}, tmp[15:0]}; //lh & lhu byte_offset=2
//				//6'b000011: dat_o <= Signext?{16'h0, tmp[15:0]}:{{16{tmp[15]}}, tmp[15:0]}; //lh & lhu byte_offset=0
//				//6'b100011: dat_o <= Signext?{16'h0, tmp[31:16]}:{{16{tmp[31]}}, tmp[31:16]}; //lh & lhu byte_offset=2
//				//default: dat_o <= 32'hffff_ffff;
//			//endcase
//			first_rd = 1;
//		end
//		else first_rd = 0;
//	end
	
	Mem mem (
			  .clka(clk), // input clka
			  .wea(wea), // input [3 : 0] wea
			  .addra(adr_i), // input [31 : 0] addra
			  .dina(dina), // input [31 : 0] dina
			  .douta(tmp) // output [31 : 0] douta
				);
	
	
	/*
	always @(posedge clk ) begin
		if ( W_En ) begin
			RAM[Addr] <= D_In;
		end
		else D_Out <= RAM[Addr];
	end*/

endmodule
