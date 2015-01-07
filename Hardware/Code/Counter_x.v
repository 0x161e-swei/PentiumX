`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:16:26 05/02/2014 
// Design Name: 
// Module Name:    Counter_x 
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

module  Counter_x(  clk,                    
            	    rst,
            	    clk0,                   
            	    clk1,                   
            	    clk2,                   
            	    counter_we,
            	    counter_val,             
            	    counter_ch,              

            	    counter0_OUT,
            	    counter1_OUT,
            	    counter2_OUT,
            	    counter_out		
                    );

    input               clk,                // clk_CPU
                        rst;
    input  wire         clk0,               // clk_div[9]
                        clk1,               // clk_div[10]
                        clk2;               // clk_div[10]
    input  wire         counter_we;
    input  wire [31: 0] counter_val;        // data_from cpu
    input  wire [ 1: 0] counter_ch;         // counter_set
                                
    output wire         counter0_OUT, counter1_OUT, counter2_OUT;
    output wire [31: 0] counter_out;      

	reg         [32: 0] counter0       = 0, counter1       = 0, counter2        = 0;
	reg         [31: 0] counter0_Lock  = 0, counter1_Lock  = 0, counter2_Lock   = 0;
	reg         [23: 0] counter_Ctrl   = 0;
	reg         [ 1: 0] last_ch        = 0, curr_ch        = 0;
    reg                 sq0            = 0, sq1            = 0, sq2             = 0, 
                        M0             = 0, M1             = 0, M2              = 0, 
                        clr0           = 0, clr1           = 0, clr2            = 0;
	
	always @(posedge clk or posedge rst) begin
		if ( rst ) begin
			counter0_Lock <= 0;
			counter1_Lock <= 0;
			counter2_Lock <= 0;
			counter_Ctrl  <= 0;
		end else begin
			if ( counter_we ) begin
				case ( counter_ch )
					2'h0: begin
						counter0_Lock <= counter_val;
						M0            <= 1;
						//last_ch     <= curr_ch;
						curr_ch       <= counter_ch;
					end
					2'h1: begin
						counter1_Lock <= counter_val;
						M1            <= 1;
						//last_ch     <= curr_ch;
						curr_ch       <= counter_ch;
					end
					2'h2: begin
						counter2_Lock <= counter_val;
						M2            <= 1;
						//last_ch     <= curr_ch;
						curr_ch       <= counter_ch;
					end
					2'h3: begin
						counter_Ctrl  <= counter_val[23:0];
					end
				endcase
			end else begin
				counter1_Lock         <= counter1_Lock;
				counter2_Lock         <= counter2_Lock;
				counter0_Lock         <= counter0_Lock;
				counter_Ctrl          <= counter_Ctrl;
				if ( clr0 ) M0        <= 0;
				if ( clr1 ) M1        <= 0;
				if ( clr2 ) M2        <= 0;
			end
		end
	end

// Channel 00
	always @(posedge clk0 or posedge rst) begin
		if(rst) begin
			counter0 <= 0;
			sq0      <= 0;
		end else begin
			case(counter_Ctrl[2:1])
				2'b00: begin
					if ( M0 ) begin
						counter0  <= {1'b0, counter0_Lock};
						clr0      <= 1;
					end else begin
						if ( counter0[32] == 0 ) begin
							counter0 <= counter0 - 1'b1;
							clr0     <= 0;
						end
					end
				end
				2'b01: begin
					sq0 <= counter0[32];
					if ( sq0 != counter0[32] )
						counter0[31:0] <= {1'b0, counter0_Lock[31:1]};
					else 
					    counter0       <= counter0 - 1'b1;
				end
				2'b11: begin
				    counter0 <= counter0 - 1'b1;
				end
			endcase
		end
	end

// Channel 01
	always @(posedge clk1 or posedge rst) begin
		if ( rst ) begin
			counter1 <= 0;
			sq1      <= 0;
		end else begin
			case ( counter_Ctrl[2:1] )
				2'b00: begin
					if ( M1 ) begin
						counter1  <= {1'b0, counter1_Lock};
						clr1      <= 1;
					end else begin
						if ( counter1[32] == 0 ) begin
							counter1 <= counter1 - 1'b1;
							clr1     <= 0;
						end
					end
				end
				2'b01: begin
					sq1 <= counter1[32];
					if ( sq1 != counter1[32] )
						counter1[31:0] <= {1'b0, counter1_Lock[31:1]};
					else 
						counter1       <= counter1 - 1'b1;
				end
				2'b11: begin
					counter1 <= counter1 - 1'b1;
				end
			endcase
		end
	end

// Channel 10
	always @(posedge clk2 or posedge rst) begin
		if ( rst ) begin
			counter2 <= 0;
			sq2      <= 0;
		end else begin
			case ( counter_Ctrl[2:1] )
				2'b00: begin
					if ( M2 ) begin
						counter2     <= {1'b0, counter2_Lock};
				        clr2         <= 1;
					end else begin
						if ( counter2[32] == 0 ) begin
							counter2 <= counter2 - 1'b1;
							clr2     <= 0;
						end
					end
				end
				2'b01: begin
					sq2 <= counter2[32];
					if ( sq2 != counter2[32] )
						counter2[31:0] <= {1'b0, counter2_Lock[31:1]};
					else 
				        counter2       <= counter2 - 1'b1;
				end
				2'b11: begin
					counter2 <= counter2 - 1'b1;
				end
			endcase
		end
	end

	
	assign counter0_OUT = counter0[32];
	assign counter1_OUT = counter1[32];
	assign counter2_OUT = counter2[32];
	assign counter_out  = curr_ch[1]? counter2[31:0]: (curr_ch[0]?  counter1[31:0 ]: 
                                                                    counter0[31:0 ]);
	
endmodule
