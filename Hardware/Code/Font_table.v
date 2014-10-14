module Font_table (
					//clk,
                    Addr,
					D_out
					);
    //input               clk;
    input  wire [ 9: 0] Addr;       // 8*8*128=2^3*2^3*2^7
    output reg  [ 7: 0] D_out;      // Font dot
    
    (* bram_map="yes" *)
    reg         [ 7: 0] Rom [   0:1023];
    initial begin
        $readmemb("../Coe/Font.coe", Rom);
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
