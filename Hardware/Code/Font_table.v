module Font_table (
					//clk,
                    Addr,
					D_out
					);
    //input               clk;
    input  wire [11: 0] Addr;       // 8*8*128=2^3*2^3*2^7
    output reg  [15: 0] D_out;      // Font dot
    
    (* bram_map="yes" *)
    reg         [15: 0] Rom [   0:4095];
    initial begin
        $readmemh("../Coe/Font16", Rom);
    end
    /*
    always @( negedge clk )begin
        D_out <= Rom[Addr];
    end
    */
    always @(*) begin 
        D_out <= Rom[Addr];
    end
endmodule
