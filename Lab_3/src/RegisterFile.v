module RegisterFile (
    input clk, rst,
    input [3:0] src_1, src_2, Dest_WB,
    input [31:0] Result_WB,
    input writeBackEN,
    output [31:0] reg_out_1, reg_out_2
);
    reg [31:0] registers [0:14];
    integer i;
    // FPGA power-up initialization; reset restores the same values.
    initial begin
        for (i=0; i<15; i=i+1) registers[i] = i;
    end
    integer j;
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            for (j=0; j<15; j=j+1) registers[j] <= j;
        end else if (writeBackEN && Dest_WB < 15)
            registers[Dest_WB] <= Result_WB;
    end
    // R15 is outside this lab register file. Reserved reads return zero.
    assign reg_out_1 = (src_1 < 15) ? registers[src_1] : 32'b0;
    assign reg_out_2 = (src_2 < 15) ? registers[src_2] : 32'b0;
endmodule
