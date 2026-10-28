module PC_Reg (
    input [WIDTH-1:0] in,
    input clk,
    input rst,
    input freeze,
    output reg [WIDTH-1:0] out
);
    parameter WIDTH = 32;

    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 0;
        else if (!freeze)
            out <= in;
    end
endmodule