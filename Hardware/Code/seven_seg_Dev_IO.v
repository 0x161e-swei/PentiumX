`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:46:42 07/01/2012 
// Design Name: 
// Module Name:    Device_7seg 
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
module Device_GPIO_7seg(
                        clk,
						rst,
						GPIOfffffe00_we,
						Test,
						disp_cpudata,
						Test_data0,
						Test_data1,
                        Test_data2,
						Test_data3,
						Test_data4,
						Test_data5,
						Test_data6,						 						 
						disp_num						 
						);
						
    input               clk, rst, GPIOfffffe00_we; 
    input       [ 2: 0] Test; 
    input       [31: 0] disp_cpudata, Test_data0, Test_data1, Test_data2, Test_data3, Test_data4, Test_data5, Test_data6; 
    output reg  [31: 0] disp_num = 32'h0;


    always @(negedge clk or posedge rst) begin 
    	if ( rst ) disp_num <= 32'hAA5555AA; 
    	else begin 
    		case ( Test ) 
    			0: begin 
    				if ( GPIOfffffe00_we ) 
    					disp_num <= disp_cpudata; 
    				else 
                        disp_num <= disp_num; 
    			end 
    			1: disp_num      <= Test_data0; 
    			2: disp_num      <= Test_data1; 
    			3: disp_num      <= Test_data2; 
    			4: disp_num      <= Test_data3; 
    			5: disp_num      <= Test_data4; 
    			6: disp_num      <= Test_data5;
    			7: disp_num      <= Test_data6; 
    		endcase
    	end
    end

endmodule
