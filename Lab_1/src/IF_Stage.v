module IF_Stage (
    input clk, rst, freeze, Branch_taken,
    input [31:0] BranchAddr,
    output [31:0] PC, Instruction
);

    wire [31:0] pc_plus_1;
    wire [31:0] next_pc;

    adder #(
        .WIDTH(32)
    ) pc_adder (
        .in1(PC),
        .in2(32'd1),
        .sum(pc_plus_1)
    );

    MUX #(
        .WIDTH(32)
    ) pc_mux (
        .in0(pc_plus_1),
        .in1(BranchAddr),
        .sel(Branch_taken),
        .out(next_pc)
    );

    PC_Reg #(
        .WIDTH(32)
    ) pc_register (
        .in(next_pc),
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .out(PC)
    );

    dist_mem_gen_0 inst_mem_ip (
        .a(PC[31:0]),      
        .spo(Instruction) 
    );

endmodule