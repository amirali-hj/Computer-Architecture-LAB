module ID_Stage (
    input clk, rst,
    input [31:0] PC_in, Instruction,
    input [3:0] SR,
    input Hazard, writeBackEN,
    input [3:0] Dest_WB,
    input [31:0] Result_WB,
    output [31:0] PC,
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
    output [31:0] Val_Rm
);
    wire uncond_WB_EN, uncond_MEM_R_EN, uncond_MEM_W_EN;
    wire uncond_B, uncond_S, Cond_out;
    wire [3:0] uncond_EXE_CMD;
    wire [8:0] uncond_control, control;
    wire suppress;
    assign PC = PC_in;
    assign imm = Instruction[25];
    assign Dest = Instruction[15:12];
    assign src_1 = Instruction[19:16];
    assign Shift_operand = Instruction[11:0];
    assign Signed_imm_24 = Instruction[23:0];
    // Use the RAW store enable, even when condition fails or Hazard is high.
    MUX #(.WIDTH(4)) src2_mux (
        .in0(Instruction[3:0]), .in1(Dest),
        .sel(uncond_MEM_W_EN), .out(src_2)
    );
    assign Two_src = !imm || uncond_MEM_W_EN;
    RegisterFile register_file (
        .clk(clk), .rst(rst), .src_1(src_1), .src_2(src_2),
        .Dest_WB(Dest_WB), .Result_WB(Result_WB), .writeBackEN(writeBackEN),
        .reg_out_1(Val_Rn), .reg_out_2(Val_Rm)
    );
    control_unit controller (
        .Mode(Instruction[27:26]), .Opcode(Instruction[24:21]),
        .S_in(Instruction[20]), .EXE_CMD(uncond_EXE_CMD),
        .WB_EN(uncond_WB_EN), .MEM_R_EN(uncond_MEM_R_EN),
        .MEM_W_EN(uncond_MEM_W_EN), .B(uncond_B), .S(uncond_S)
    );
    condition_Check condition_checker (
        .Cond(Instruction[31:28]), .SR(SR), .Cond_out(Cond_out)
    );
    // The instruction table reserves E0000000 for NOP; zero is reset bubble.
    assign suppress = rst || Hazard || !Cond_out ||
                      (Instruction == 32'hE0000000) || (Instruction == 0);
    assign uncond_control = {uncond_WB_EN, uncond_MEM_R_EN,
        uncond_MEM_W_EN, uncond_EXE_CMD, uncond_B, uncond_S};
    MUX #(.WIDTH(9)) control_mux (
        .in0(uncond_control), .in1(9'b0), .sel(suppress), .out(control)
    );
    assign {WB_EN,MEM_R_EN,MEM_W_EN,EXE_CMD,B,S} = control;
endmodule
