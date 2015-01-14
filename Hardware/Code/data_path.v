`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:02:02 05/08/2014 
// Design Name: 
// Module Name:    data_path 
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
module data_path(
                clk,
                reset,
                MIO_ready,
                IorD,
                IRWrite,
                RegDst,
                RegWrite,
                MemtoReg,
				data2Mem,
				data2CPU,
                ALUSrcA,
	
                ALUSrcB,
                PCSource,
                PCWrite,
				PCWriteCond,
                Beq,
				Signext,
                ALU_operation,
				
                PC_Current, 
                	
                Inst_R,
                data_out,
                M_addr,

                zero,
                overflow
            	);

    input wire 			clk, reset;
    input wire 	 		MIO_ready, IorD, RegWrite, IRWrite, PCWrite, PCWriteCond, Beq, data2Mem, Signext;

    input wire  [ 1: 0] RegDst, ALUSrcA, ALUSrcB, MemtoReg;
	input wire  [ 2: 0] PCSource;
    input wire  [ 3: 0] ALU_operation;
	input wire  [31: 0] data2CPU;

    output reg  [31: 0] PC_Current; 
    output reg  [31: 0]	Inst_R = 0;
    output wire [31: 0]	data_out;
    output wire [31: 0]	M_addr;
    output wire 		zero, overflow;


	reg  		[31: 0] ALU_Out = 32'h0, MDR = 32'h0, ALU_Out2 = 32'h0;
	wire 		[31: 0] reg_outA, reg_outB, r6out; //regs

	wire 				modificative;
	//ALU
	wire 		[31: 0] Alu_A,Alu_B,res;
	wire 		[31: 0] w_reg_data, rdata_A, rdata_B;
	wire 		[15: 0] imm;
	wire        [31: 0] imm_ext;
	wire 		[ 4: 0] shamt;
	wire 		[ 4: 0] reg_Rs_addr_A,reg_Rt_addr_B,reg_rd_addr,reg_Wt_addr;
	reg  		[31: 0] dataToCpu;
	
	always @(posedge clk)  dataToCpu <= data2CPU;
 
	assign rst=reset;
	// locked inst form memory
	always @(posedge clk or posedge rst)begin
		if(rst) begin
			Inst_R <= 0; 
		end
		else begin
			if (IRWrite && MIO_ready) 
				Inst_R		<= data2CPU; 
			else 
				Inst_R		<= Inst_R;
			if (MIO_ready)
			    MDR 		<= data2CPU;
				ALU_Out 	<= res;
				ALU_Out2	<= ALU_Out;
			end
		end
 
 
  //+++++++++++++++++++++++++++++++++++++++++++ signed or unsigned extends
	single_signext signext(Signext, imm, imm_ext);
 
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	alu 			D1(
		  			.A 					(Alu_A),
		  			.B 					(Alu_B),
		  			.ALU_operation 		(ALU_operation),
		  			.shamt 				(shamt),
		  			.res 				(res),
		  			.zero 				(zero),
		  			.overflow(overflow) 
		  			);
		  
	Regs 	reg_files( 
					.clk 				(clk),
					.rst 				(rst),
					.reg_R_addr_A		(reg_Rs_addr_A),
					.reg_R_addr_B		(reg_Rt_addr_B),
					.reg_W_addr  		(reg_Wt_addr),
					.wdata 		 		(w_reg_data),
					.reg_we 			(RegWrite),
					.rdata_A 			(rdata_A),
					.rdata_B 			(rdata_B)
					);

	// Instructions as mfc0 $t1, $11
	Coprocessor cp0(
  					.clk(clk),
  					.rst(reset),
  					.c0_rd_addr(reg_Rt_addr_B),
  					.c0_wr_addr(reg_rd_addr),
					.c0_w_data(w_reg_data),
					.pc_i(res),
					.InTcause(InTcause),
					.c0_reg_we(WriteCp0),
					.WriteEPC(WriteEPC),
					.WriteCause(WriteCause),
					.c0_r_data(c0_r_data), 				// used for instructions mfc0
					.epc_o(epc_out)
					);

	initial begin
		 PC_Current = 32'h0000_0000;
	end
        
	//path with MUX++++++++++++++++++++++++++++++++++++++++++++++++++++++
	// reg path
	assign reg_Rs_addr_A 	= Inst_R[25:21]; 					//REG Source 1 rs
	assign reg_Rt_addr_B 	= Inst_R[20:16]; 					//REG Source 2 or Destination rt
	assign reg_rd_addr 		= Inst_R[15:11]; 					//REG Destination rd
	assign imm 				= Inst_R[15: 0]; 					//Immediate
	assign shamt  			= Inst_R[10: 6];
 
	// reg write data
	mux4to1_32 mux_w_reg_data(
					.a 					(ALU_Out), 				//ALU OP
					.b 					(MDR), 					//LW
					.c 					({imm,16'h0000}), 		//lui
					.d 					(PC_Current), 			// jr
					.sel 				(MemtoReg),
					.o 					(w_reg_data)
					);

	// reg write port addr
	mux4to1_5 mux_w_reg_addr(
					.a					(reg_Rt_addr_B), 		//reg addr=IR[21:16]
					.b					(reg_rd_addr), 			//reg addr=IR[15:11], LW or lui
					.c					(5'b11111), 			//reg addr=$Ra(31) jr
					.d					(5'b00000), 			// not use
					.sel				(RegDst),
					.o 					(reg_Wt_addr)
					);

 	//---------------ALU path
 	// Alu source A
 	always @(*) begin
 		case( ALUSrcA ) begin
 			2'b00: 	Alu_A <= PC_Current;				// PC
 			2'b01:  Alu_A <= rdata_A;					// reg out A
 			2'b10: 	Alu_A <= dataToCpu;					// Sh
 			2'b11: 	Alu_A <= PC_Current - 4;			// pc - 4 for syscall
 		end
 	end

 	/*
	mux3to1_32 mux_Alu_A(
					.a					(rdata_A), 				// reg out A
					.b					(PC_Current),  			// PC
					.c					(dataToCpu),  			// Sh
					.d 					(PC_Current - 4),		// pc - 4 for syscall
					.sel 				(ALUSrcA),
					.o					(Alu_A)
					);
    */     
  mux4to1_32 mux_Alu_B(
         			.a					(rdata_B), 						//reg out B
         			.b					(32'h00000004), 				//4 for PC+4
         			.c					(imm_ext), 						//imm
         			.d					({{14{imm[15]}},imm,2'b00}),	// offset
         			.sel 				(ALUSrcB),
         			.o					(Alu_B)
          			);
  //pc Generator
  //+++++++++++++++++++++++++++++++++++++++++++++++++
  	assign modificative = PCWrite || (PCWriteCond && (~(zero || Beq) | (zero && Beq)));
//(PCWriteCond&&zero)
 
  	always @(posedge clk or posedge reset) begin
      	if (reset == 1) // reset
          PC_Current <= 32'h00000000;
      	else if (modificative == 1)begin
          	case ( PCSource )
             	3'b000: if (MIO_ready) 
             			PC_Current <= res; 												// PC+4
              	3'b001: PC_Current <= ALU_Out; 											// branch
              	3'b010: PC_Current <= {PC_Current[31:28],Inst_R[25:0],2'b00}; 			// jump
              	3'b011: PC_Current <= res; 												// jr and jalr
				3'b100:	PC_Current <= 32'h0000_0004;
				3'b101:	PC_Current <= epc_out;
          	endcase
     	end
	end

 //---------------memory path
  	assign data_out = data2Mem? ALU_Out2: rdata_B; //data to store memory or IO
  	
  	mux2to1_32 mux_M_addr (
         			.a					(ALU_Out), //access memory
         			.b					(PC_Current), //IF
         			.sel 				(IorD),
         			.o					(M_addr)
       				);

 
endmodule 