`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:25:02 05/08/2
// Design Name: 
// Module Name:    ctrl 
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
module 		ctrl(
				clk,
				reset,
				Inst,		
				MIO_ready,	
				zero,			
				overflow,		
				
				PCWrite,
				PCWriteCond,
				IorD,
				MemRead,
				MemWrite,
				IRWrite,
				data2Mem,
				MemtoReg,
				PCSource,
				ALUSrcB,
				ALUSrcA,
				RegWrite,
				RegDst,
				CPU_MIO,
				Beq,
				ALU_operation,
				state_out
				);


	input wire 			clk, reset;
	input wire 	[31: 0] Inst;		
	input wire 			MIO_ready, zero, overflow;
	
	output reg 			PCWrite, PCWriteCond, IorD, MemRead, MemWrite, IRWrite, data2Mem, RegWrite, CPU_MIO, Beq;
	output reg 	[ 1: 0]	RegDst, MemtoReg, PCSource, ALUSrcB, ALUSrcA;
	output reg 	[ 3: 0]	ALU_operation;
	output wire [ 4: 0]	state_out;

	reg [4:0] state = 5'b00000;

	localparam 	IF 		  = 5'b00000, ID 	 = 5'b00001, EX_R 	= 5'b00010, EX_Mem 	= 5'b00011, EX_I 	= 5'b00100,
				WB_Lui	  = 5'b00101, EX_beq = 5'b00110, EX_bne = 5'b00111, EX_jr 	= 5'b01000, EX_JAL  = 5'b01001,
				Ex_J 	  = 5'b01010, MEM_RD = 5'b01011, MEM_WD = 5'b01100, WB_R 	= 5'b01101, WB_I 	= 5'b01110,
				WB_LW 	  = 5'b01111, Error  = 5'b11111,
				MEM_RD_LH = 5'b10000, LH_ALU = 5'b10001, 
				MEM_RD_SH = 5'b10010, SH_ALU = 5'b10011, 
				WB_LW_SH  = 5'b10100, 
				EX_Mem_SH = 5'b10101;

	localparam 	AND = 4'b0000, OR 	= 4'b0001, ADD 	= 4'b0010, SUB 	= 4'b0110, NOR 	= 4'b0100, SLT 	  = 4'b0111, XOR  	= 4'b0011, 
				SRL = 4'b0101, SLL 	= 4'b1000, ADDU = 4'b1001, SUBU = 4'b1010, SLTU = 4'b1011, ALU_LH = 4'b1100, ALU_SH = 4'b1101;

	`define CPU_ctrl_signals {PCWrite, PCWriteCond, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource, ALUSrcB, ALUSrcA[0], RegWrite, RegDst, CPU_MIO}
							//   1         1         1       1         1        1        2         2         2        1           1        2         1

	assign state_out = state;
	initial begin
		`CPU_ctrl_signals 	= 17'h12821;
		ALUSrcA[1] 			= 0;
		data2Mem 			= 0;
		ALU_operation  		= 3'b010;
	end

	always @ (posedge clk or posedge reset)
		
		if (reset == 1) begin
			`CPU_ctrl_signals 				<= 17'h12821;
			state 							<= IF;
		end	
		else begin	
			case (state)	
			IF: begin	
				if(MIO_ready)begin	
					`CPU_ctrl_signals 		<= 17'h00060;
					ALU_operation 			<= ADD;
					state  					<= ID;
				end	
				else begin	
					state  					<=IF;
					`CPU_ctrl_signals  		<= 17'h12821;
				end
			end

			ID: begin
				case (Inst[31:26])
					6'b000000:begin  //R type

						`CPU_ctrl_signals 	<= 17'h00010;
						state 				<= EX_R;

						case (Inst[5:0])
							6'b100000: ALU_operation <= ADD;
							6'b100010: ALU_operation <= SUB;
							6'b100100: ALU_operation <= AND;
							6'b100101: ALU_operation <= OR;
							6'b100110: ALU_operation <= XOR;
							6'b100111: ALU_operation <= NOR;
							6'b101010: ALU_operation <= SLT;
							6'b000010: ALU_operation <= SRL;
							6'b000000: ALU_operation <= SLL;
							6'b100001: ALU_operation <= ADDU;
							6'b100011: ALU_operation <= SUBU;
							6'b101011: ALU_operation <= SLTU;							
							6'b001000: begin 				
								`CPU_ctrl_signals 	 <= 17'h10010;
								ALU_operation 		 <= ADD; 
								state  				 <= EX_jr; 
							end 
							default: begin 
								`CPU_ctrl_signals 	 <= `CPU_ctrl_signals;
								ALU_operation 		 <= ALU_operation;
								state 				 <= state;
							end
						endcase

					end

					6'b100011:begin 												//Lw
						`CPU_ctrl_signals	<= 17'h00050;
						ALU_operation  		<= ADD;
						state 				<= EX_Mem;
					end

					6'b101011:begin 												//Sw
						`CPU_ctrl_signals	<= 17'h00050;
						ALU_operation		<= ADD;
						state 				<= EX_Mem;
					end
					
					////////////////////////////////////////////////////////////////////////
					6'b100001:begin 												//Lh
						`CPU_ctrl_signals	<= 17'h00050;
						ALU_operation		<= ADD;
						state  				<= EX_Mem;
					end
					
					6'b101001:begin 												//Sh
						`CPU_ctrl_signals 	<= 17'h00050;
						ALU_operation 		<= ADD;
						state 				<= EX_Mem;
					end
					
					6'b000010:begin 												//Jump
						`CPU_ctrl_signals 	<= 17'h10160;
						state  				<= Ex_J;
					end

					6'b000100:begin 												//Beq
						`CPU_ctrl_signals 	<= 17'h08090; 
						Beq 				<= 1;
						ALU_operation 		<= SUB; 
						state 				<= EX_beq; 
					end

					6'b000101:begin 												//Bne
						`CPU_ctrl_signals 	<= 17'h08090; 
						Beq 				<= 0;
						ALU_operation 		<= SUB; 
						state 		 		<= EX_bne; 
					end

					6'b000011:begin 												//Jal
						`CPU_ctrl_signals 	<= 17'h1076c;
						state 				<= EX_JAL;
					end

					6'b001000:begin 												//Addi
						`CPU_ctrl_signals 	<= 17'h00050;
						ALU_operation 		<= ADD;
						state 				<= EX_I;
					end
					
					6'b001100:begin 												//Andi  
						`CPU_ctrl_signals	<= 17'h00050;
						ALU_operation 		<= AND;
						state 				<= EX_I;
					end
					
					6'b001101:begin 												//Ori  
						`CPU_ctrl_signals 	<= 17'h00050;
						ALU_operation 		<= OR;
						state 				<= EX_I;
					end
					
					6'b001110:begin 												//Xori 
						`CPU_ctrl_signals 	<= 17'h00050;
						ALU_operation  		<= XOR;
						state 				<= EX_I;
					end

					6'b001010:begin 												//Slti
						`CPU_ctrl_signals 	<= 	17'h00050;
						ALU_operation  		<= SLT;
						state 				<= EX_I;
					end
					
					6'b001011:begin 												//Sltiu
						`CPU_ctrl_signals 	<= 17'h00050;
						ALU_operation 		<= SLTU;
						state 				<= EX_I;
					end
					
					6'b001001:begin 												//Addiu
						`CPU_ctrl_signals 	<= 17'h00050;
						ALU_operation 		<= ADDU;
						state 				<= EX_I;
					end

					6'b001111:begin 												//Lui
						`CPU_ctrl_signals	<= 17'h00468;
						state 				<= WB_Lui;
					end

					default: begin
						`CPU_ctrl_signals	<=	17'h12821;
						state 				<= Error;
					end

				endcase
			end

			EX_R:begin
				`CPU_ctrl_signals 	<= 17'h0001a;
				state 				<= WB_R; 
			end

			EX_I:begin
				`CPU_ctrl_signals 	<= 17'h00058;
				state 				<= WB_I;
			end

			EX_Mem:begin
				if(Inst[31:26] == 6'b100011)begin 									// Lw
					`CPU_ctrl_signals	<= 17'h06051; 
					state 				<= MEM_RD; 
				end
				else if(Inst[31:26] == 6'b100001)begin 								// Lh
					`CPU_ctrl_signals	<= 17'h06051; 
					state 				<= MEM_RD_LH; 
				end
				else if(Inst[31:26] == 6'b101001)begin 								// Sh
					`CPU_ctrl_signals 	<= 17'h06051; 
					state 				<= MEM_RD_SH; 
				end
				
				else if(Inst[31:26] == 6'b101011)begin
					`CPU_ctrl_signals 	<=17'h05051; 
					state 				<= MEM_WD; 
					end
			end
			
			EX_Mem_SH:begin				
				if(Inst[31:26] == 6'b101001)begin
				`CPU_ctrl_signals	<= 17'h05051; 
				data2Mem 			<= 1;
				state 				<= MEM_WD; 
				end
			end

			Ex_J:begin
				`CPU_ctrl_signals 	<= 17'h12821;
				ALU_operation 		<= ADD; 
				state  				<= IF; 
			end

			EX_bne:begin
				`CPU_ctrl_signals 	<= 17'h12821;
				ALU_operation 		<= ADD; 
				state 				<= IF; 
			end

			EX_beq:begin
				`CPU_ctrl_signals 	<= 17'h12821;
				ALU_operation 		<= ADD; 
				state 				<= IF; 
			end

			EX_jr:begin
				`CPU_ctrl_signals 	<= 17'h12821;
				ALU_operation 		<= ADD; 
				state 				<= IF; 
			end

			EX_JAL:begin
				`CPU_ctrl_signals 	<= 17'h12821;
				ALU_operation 		<= ADD; 
				state 				<= IF; 
			end

			MEM_RD:begin
				if(MIO_ready)begin
					`CPU_ctrl_signals<= 17'h00208; 
					state 			<= WB_LW; 
				end
				else begin
					state 			<= MEM_RD;
					`CPU_ctrl_signals<= 17'h06050; 
				end
			end
			
			////////////////////////////////////////////////////////////
			MEM_RD_LH: begin
				if ( MIO_ready ) begin
					`CPU_ctrl_signals<=17'h00040; 
					ALUSrcA[1] 		<= 1; 											// Operator select data2cpu
					ALU_operation	<= ALU_LH; 
					state 			<= LH_ALU; 
				end
				else begin
					state 			<= MEM_RD;
					`CPU_ctrl_signals<=17'h06050; 
				end
			end
			
			LH_ALU:begin
				`CPU_ctrl_signals	<= 17'h00008; 									// MemToReg Select alu_out
				ALUSrcA[1] 			<= 0;
				state <= WB_LW; 
			end

			MEM_RD_SH:begin
				if(MIO_ready)begin
					`CPU_ctrl_signals<= 17'h00000; 
					ALUSrcA[1] 		<= 1; 											// Operator: data2cpu & rt
					ALU_operation 	<= ALU_SH; 
					state 			<= SH_ALU; 
				end
				else begin
					state 			<= MEM_RD;
					`CPU_ctrl_signals<= 17'h06050; 
				end
			end
			
			SH_ALU:begin
				`CPU_ctrl_signals	<= 17'h00050; 			// To calculate ram address 
				ALUSrcA[1] 			<= 0; 
				ALU_operation 		<= ADD;
				state 				<= EX_Mem_SH;
			end


			MEM_WD:begin
				if(MIO_ready)begin
					`CPU_ctrl_signals<= 17'h12821;
					data2Mem 		<= 0;
					ALU_operation 	<= ADD;
					state 			<= IF; 
				end
				else begin
					state <=MEM_WD;
					`CPU_ctrl_signals<= 17'h05050;
				end
			end

			WB_LW:begin
				`CPU_ctrl_signals	<= 17'h12821;
				ALU_operation		<= ADD;
				state 				<= IF;
			end


			WB_R:begin
				`CPU_ctrl_signals 	<= 17'h12821;
				ALU_operation		<= ADD;
				state 				<= IF;
			end

			WB_I:begin
				`CPU_ctrl_signals	<= 17'h12821;
				ALU_operation 		<= ADD; 
				state 				<= IF; 
			end


			WB_Lui:begin
				`CPU_ctrl_signals 	<= 17'h12821;
				ALU_operation 		<= ADD; 
				state 				<= IF; 
			end

			Error: 
				state <= Error;

			default: begin
				`CPU_ctrl_signals 	<= 17'h12821; 
				Beq 				<= 0;
				ALU_operation 		<= ADD; 
				state 				<= Error; 
			end
		endcase
	end
endmodule