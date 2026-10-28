module ARM (
    input clk,
    input rst
);

    // Wires for inter-stage connections
    wire [31:0] IF_pc, IF_instruction;
    wire [31:0] ID_pc, ID_instruction;
    wire [31:0] ID_out_pc;
    wire [31:0] EXE_pc;
    wire [31:0] EXE_out_pc;
    wire [31:0] MEM_pc;
    wire [31:0] MEM_out_pc;
    wire [31:0] WB_pc;

    // ---------------------------------------------------------
    // 1. Instruction Fetch (IF) Stage[cite: 13]
    // ---------------------------------------------------------
    IF_Stage IF_stage_inst (
        .clk(clk),
        .rst(rst),
        .freeze(1'b0),          // Assigned to 0[cite: 13]
        .Branch_taken(1'b0),    // Assigned to 0[cite: 13]
        .BranchAddr(32'b0),     // Assigned to 0[cite: 13]
        .PC(IF_pc),
        .Instruction(IF_instruction)
    );

    // ---------------------------------------------------------
    // IF/ID Pipeline Register[cite: 13]
    // ---------------------------------------------------------
    IF_Stage_Reg IF_ID_reg_inst (
        .clk(clk),
        .rst(rst),
        .freeze(1'b0),
        .flush(1'b0),
        .PC_in(IF_pc),
        .Instruction_in(IF_instruction),
        .PC(ID_pc),
        .Instruction(ID_instruction)
    );

    // ---------------------------------------------------------
    // 2. Instruction Decode (ID) Stage (Dummy)[cite: 13]
    // ---------------------------------------------------------
    ID_Stage ID_stage_inst (
        .clk(clk),
        .rst(rst),
        .PC_in(ID_pc),
        .PC(ID_out_pc)
    );

    // ---------------------------------------------------------
    // ID/EXE Pipeline Register (Dummy pass-through)[cite: 13]
    // ---------------------------------------------------------
    ID_EXE_Reg ID_EXE_reg_inst (
        .clk(clk),
        .rst(rst),
        .PC_in(ID_out_pc),
        .PC(EXE_pc)
    );

    // ---------------------------------------------------------
    // 3. Execution (EXE) Stage (Dummy)[cite: 13]
    // ---------------------------------------------------------
    EXE_Stage EXE_stage_inst (
        .clk(clk),
        .rst(rst),
        .PC_in(EXE_pc),
        .PC(EXE_out_pc)
    );

    // ---------------------------------------------------------
    // EXE/MEM Pipeline Register (Dummy pass-through)[cite: 13]
    // ---------------------------------------------------------
    EXE_MEM_Reg EXE_MEM_reg_inst (
        .clk(clk),
        .rst(rst),
        .PC_in(EXE_out_pc),
        .PC(MEM_pc)
    );

    // ---------------------------------------------------------
    // 4. Memory (MEM) Stage (Dummy)[cite: 13]
    // ---------------------------------------------------------
    MEM_Stage MEM_stage_inst (
        .clk(clk),
        .rst(rst),
        .PC_in(MEM_pc),
        .PC(MEM_out_pc)
    );

    // ---------------------------------------------------------
    // MEM/WB Pipeline Register (Dummy pass-through)[cite: 13]
    // ---------------------------------------------------------
    MEM_WB_Reg MEM_WB_reg_inst (
        .clk(clk),
        .rst(rst),
        .PC_in(MEM_out_pc),
        .PC(WB_pc)
    );

    // ---------------------------------------------------------
    // 5. Write Back (WB) Stage (Dummy)[cite: 13]
    // ---------------------------------------------------------
    WB_Stage WB_stage_inst (
        .clk(clk),
        .rst(rst),
        .PC_in(WB_pc),
        // No pipeline register follows the WB stage
        .PC() // Output left unconnected for now
    );

endmodule