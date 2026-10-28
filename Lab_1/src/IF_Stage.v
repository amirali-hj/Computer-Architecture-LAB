module IF_Stage (
    input clk, rst, freeze, Branch_taken,
    input [31:0] BranchAddr,
    output [31:0] PC, Instruction

);

    wire [31:0] pc_plus_1;
    wire [31:0] next_pc;
    reg  [31:0] pc_reg;

    // Adder: Computes PC + 1 since memories are Word Addressable[cite: 5]
    assign pc_plus_1 = PC + 1;

    // Multiplexer: Selects between Branch Address and PC + 1[cite: 2]
    assign next_pc = Branch_taken ? BranchAddr : pc_plus_1;

    // PC Register[cite: 2]
    always @(posedge clk or posedge rst) begin
        if (rst) 
            pc_reg <= 32'b0; // Resets to 0
        else if (~freeze)    // Does not load if freeze is 1
            pc_reg <= next_pc;
    end
    
    assign PC = pc_reg;

    // Instruction Memory (Inst. Mem)[cite: 2, 5]
    // Note: The document specifies using Vivado's Distributed Memory Generator IP. 
    // You must provide a slice of the PC for the address (e.g., PC[9:0]) depending on your configured Depth[cite: 5].
    dist_mem_gen_0 inst_mem_ip (
        .a(PC[9:0]),      // Address input (Slice of PC)
        .spo(Instruction) // Instruction output
    );

endmodule