module WB_Stage ( // Or whichever module is failing at line 111
    input clk,
    input rst,
    input [31:0] PC_in,
    output [31:0] PC
);
    // Simple pass-through logic for the dummy stage
    assign PC = PC_in; 
endmodule