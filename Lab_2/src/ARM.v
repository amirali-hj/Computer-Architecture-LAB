module ARM (
    input clk, rst,
    output [31:0] IF_pc,
    output [31:0] IF_instruction,
    output [31:0] ID_pc,
    output [31:0] ID_instruction,
    output [31:0] EXE_pc,
    output B,
    output S,
    output imm,
    output WB_EN,
    output Two_src,
    output MEM_W_EN,
    output MEM_R_EN,
    output [3:0] Dest,
    output [3:0] EXE_CMD,
    output [3:0] src_1,
    output [3:0] src_2,
    output [11:0] Shift_operand,
    output [23:0] Signed_imm_24,
    output [31:0] Val_Rn,
    output [31:0] Val_Rm,
    output EXE_B,
    output EXE_S,
    output EXE_imm,
    output EXE_WB_EN,
    output EXE_Two_src,
    output EXE_MEM_W_EN,
    output EXE_MEM_R_EN,
    output [3:0] EXE_Dest,
    output [3:0] EXE_EXE_CMD,
    output [3:0] EXE_src_1,
    output [3:0] EXE_src_2,
    output [11:0] EXE_Shift_operand,
    output [23:0] EXE_Signed_imm_24,
    output [31:0] EXE_Val_Rn,
    output [31:0] EXE_Val_Rm
);
    wire [31:0] ID_out_pc;
    IF_Stage IF_stage_inst (
        .clk(clk), .rst(rst), .freeze(1'b0), .Branch_taken(1'b0),
        .BranchAddr(32'b0), .PC(IF_pc), .Instruction(IF_instruction)
    );
    IF_Stage_Reg IF_ID_reg_inst (
        .clk(clk), .rst(rst), .freeze(1'b0), .flush(1'b0),
        .PC_in(IF_pc), .Instruction_in(IF_instruction),
        .PC(ID_pc), .Instruction(ID_instruction)
    );
    ID_Stage ID_stage_inst (
        .clk(clk), .rst(rst), .PC_in(ID_pc), .Instruction(ID_instruction),
        .SR(4'b0), .Hazard(1'b0), .writeBackEN(1'b0),
        .Dest_WB(4'b0), .Result_WB(32'b0), .PC(ID_out_pc),
        .B(B),
        .S(S),
        .imm(imm),
        .WB_EN(WB_EN),
        .Two_src(Two_src),
        .MEM_W_EN(MEM_W_EN),
        .MEM_R_EN(MEM_R_EN),
        .Dest(Dest),
        .EXE_CMD(EXE_CMD),
        .src_1(src_1),
        .src_2(src_2),
        .Shift_operand(Shift_operand),
        .Signed_imm_24(Signed_imm_24),
        .Val_Rn(Val_Rn),
        .Val_Rm(Val_Rm)
    );
    ID_EXE_Reg ID_EXE_reg_inst (
        .clk(clk), .rst(rst), .freeze(1'b0), .flush(1'b0),
        .PC_in(ID_out_pc), .PC(EXE_pc),
        .B_in(B), .B(EXE_B),
        .S_in(S), .S(EXE_S),
        .imm_in(imm), .imm(EXE_imm),
        .WB_EN_in(WB_EN), .WB_EN(EXE_WB_EN),
        .Two_src_in(Two_src), .Two_src(EXE_Two_src),
        .MEM_W_EN_in(MEM_W_EN), .MEM_W_EN(EXE_MEM_W_EN),
        .MEM_R_EN_in(MEM_R_EN), .MEM_R_EN(EXE_MEM_R_EN),
        .Dest_in(Dest), .Dest(EXE_Dest),
        .EXE_CMD_in(EXE_CMD), .EXE_CMD(EXE_EXE_CMD),
        .src_1_in(src_1), .src_1(EXE_src_1),
        .src_2_in(src_2), .src_2(EXE_src_2),
        .Shift_operand_in(Shift_operand), .Shift_operand(EXE_Shift_operand),
        .Signed_imm_24_in(Signed_imm_24), .Signed_imm_24(EXE_Signed_imm_24),
        .Val_Rn_in(Val_Rn), .Val_Rn(EXE_Val_Rn),
        .Val_Rm_in(Val_Rm), .Val_Rm(EXE_Val_Rm)
    );
    // EXE, MEM and WB are not implemented in this session.
endmodule
