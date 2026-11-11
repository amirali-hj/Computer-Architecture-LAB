`timescale 1ns/1ps

module tb_ARM_IF_ID;
    reg clk = 1'b0;
    reg rst = 1'b1;
    always #5 clk = ~clk;

    wire [31:0] IF_pc, IF_instruction, ID_pc, ID_instruction, EXE_pc;
    wire B, S, imm, WB_EN, Two_src, MEM_W_EN, MEM_R_EN;
    wire [3:0] Dest, EXE_CMD, src_1, src_2;
    wire [11:0] Shift_operand;
    wire [23:0] Signed_imm_24;
    wire [31:0] Val_Rn, Val_Rm;
    wire EXE_B, EXE_S, EXE_imm, EXE_WB_EN, EXE_Two_src;
    wire EXE_MEM_W_EN, EXE_MEM_R_EN;
    wire [3:0] EXE_Dest, EXE_EXE_CMD, EXE_src_1, EXE_src_2;
    wire [11:0] EXE_Shift_operand;
    wire [23:0] EXE_Signed_imm_24;
    wire [31:0] EXE_Val_Rn, EXE_Val_Rm;

    ARM dut (
        .clk(clk), .rst(rst),
        .IF_pc(IF_pc), .IF_instruction(IF_instruction),
        .ID_pc(ID_pc), .ID_instruction(ID_instruction), .EXE_pc(EXE_pc),
        .B(B), .S(S), .imm(imm), .WB_EN(WB_EN), .Two_src(Two_src),
        .MEM_W_EN(MEM_W_EN), .MEM_R_EN(MEM_R_EN),
        .Dest(Dest), .EXE_CMD(EXE_CMD), .src_1(src_1), .src_2(src_2),
        .Shift_operand(Shift_operand), .Signed_imm_24(Signed_imm_24),
        .Val_Rn(Val_Rn), .Val_Rm(Val_Rm),
        .EXE_B(EXE_B), .EXE_S(EXE_S), .EXE_imm(EXE_imm),
        .EXE_WB_EN(EXE_WB_EN), .EXE_Two_src(EXE_Two_src),
        .EXE_MEM_W_EN(EXE_MEM_W_EN), .EXE_MEM_R_EN(EXE_MEM_R_EN),
        .EXE_Dest(EXE_Dest), .EXE_EXE_CMD(EXE_EXE_CMD),
        .EXE_src_1(EXE_src_1), .EXE_src_2(EXE_src_2),
        .EXE_Shift_operand(EXE_Shift_operand),
        .EXE_Signed_imm_24(EXE_Signed_imm_24),
        .EXE_Val_Rn(EXE_Val_Rn), .EXE_Val_Rm(EXE_Val_Rm)
    );

    // -------- Raw instruction fields (pure bit slicing, NOT control decode) --------
    wire [3:0] ID_Cond       = ID_instruction[31:28];
    wire [1:0] ID_Mode       = ID_instruction[27:26];
    wire       ID_I_bit      = ID_instruction[25];
    wire [3:0] ID_Opcode     = ID_instruction[24:21];
    wire       ID_S_bit      = ID_instruction[20];
    wire [3:0] ID_Rn_bits    = ID_instruction[19:16];
    wire [3:0] ID_Rd_bits    = ID_instruction[15:12];
    wire [3:0] ID_Rm_bits    = ID_instruction[3:0];
    wire [11:0] ID_operand12 = ID_instruction[11:0];
    wire [3:0] ID_rotate_imm = ID_instruction[11:8];
    wire [7:0] ID_immed_8    = ID_instruction[7:0];
    wire [4:0] ID_shift_imm  = ID_instruction[11:7];
    wire [1:0] ID_shift_type = ID_instruction[6:5];
    wire [23:0] ID_branch_offset = ID_instruction[23:0];

    // -------- Actual decoded outputs of the ID stage --------
    wire ID_B = B;
    wire ID_S = S;
    wire ID_imm = imm;
    wire ID_WB_EN = WB_EN;
    wire ID_Two_src = Two_src;
    wire ID_MEM_W_EN = MEM_W_EN;
    wire ID_MEM_R_EN = MEM_R_EN;
    wire [3:0] ID_Dest = Dest;
    wire [3:0] ID_EXE_CMD = EXE_CMD;
    wire [3:0] ID_src_1 = src_1;
    wire [3:0] ID_src_2 = src_2;
    wire [11:0] ID_Shift_operand = Shift_operand;
    wire [23:0] ID_Signed_imm_24 = Signed_imm_24;
    wire [31:0] ID_Val_Rn = Val_Rn;
    wire [31:0] ID_Val_Rm = Val_Rm;

    // -------- Optional internal diagnostics (names from YOUR ID_Stage.v) --------
    wire ID_Cond_out = dut.ID_stage_inst.Cond_out;
    wire ID_suppress = dut.ID_stage_inst.suppress;
    wire ID_raw_WB_EN = dut.ID_stage_inst.uncond_WB_EN;
    wire ID_raw_MEM_R_EN = dut.ID_stage_inst.uncond_MEM_R_EN;
    wire ID_raw_MEM_W_EN = dut.ID_stage_inst.uncond_MEM_W_EN;
    wire [3:0] ID_raw_EXE_CMD = dut.ID_stage_inst.uncond_EXE_CMD;

    // Capture combinational ID signals BEFORE next posedge, then verify the ID/EXE register.
    reg [154:0] captured_ID; // 32+7+16+12+24+64 = 155 bits
    wire [154:0] current_ID_bus = {
        ID_pc, ID_B, ID_S, ID_imm, ID_WB_EN, ID_Two_src,
        ID_MEM_W_EN, ID_MEM_R_EN, ID_Dest, ID_EXE_CMD,
        ID_src_1, ID_src_2, ID_Shift_operand, ID_Signed_imm_24,
        ID_Val_Rn, ID_Val_Rm
    };
    wire [154:0] current_EXE_bus = {
        EXE_pc, EXE_B, EXE_S, EXE_imm, EXE_WB_EN, EXE_Two_src,
        EXE_MEM_W_EN, EXE_MEM_R_EN, EXE_Dest, EXE_EXE_CMD,
        EXE_src_1, EXE_src_2, EXE_Shift_operand, EXE_Signed_imm_24,
        EXE_Val_Rn, EXE_Val_Rm
    };

    integer cycle, errors;
    integer log_file;
    initial begin
        cycle = 0;
        errors = 0;
        log_file = $fopen("ID_decode_results.csv", "w");
        $fdisplay(log_file, "cycle,ID_PC,Instruction,Cond,Mode,I,Opcode,S_bit,Rn,Rd,Rm,B,S,imm,WB_EN,Two_src,MEM_W_EN,MEM_R_EN,EXE_CMD,Dest,src_1,src_2,Shift_operand,Signed_imm_24,Val_Rn,Val_Rm,Cond_out,suppress,raw_WB_EN,raw_MEM_R_EN,raw_MEM_W_EN,raw_EXE_CMD");
        #12 rst = 1'b0;
        repeat (55) begin
            @(negedge clk);
            #1; // ID is stable; sample BEFORE the next rising edge.
            captured_ID = current_ID_bus;
            $display("\n========= ID DECODE | cycle=%0d PC=%0d instruction=%08h =========", cycle, ID_pc, ID_instruction);
            $display("RAW   : Cond=%b Mode=%b I=%b Opcode=%b S_bit=%b Rn=%0d Rd=%0d Rm=%0d", ID_Cond, ID_Mode, ID_I_bit, ID_Opcode, ID_S_bit, ID_Rn_bits, ID_Rd_bits, ID_Rm_bits);
            $display("CTRL  : B=%b S=%b imm=%b WB_EN=%b Two_src=%b MEM_W_EN=%b MEM_R_EN=%b EXE_CMD=%b", ID_B, ID_S, ID_imm, ID_WB_EN, ID_Two_src, ID_MEM_W_EN, ID_MEM_R_EN, ID_EXE_CMD);
            $display("REGS  : Dest=R%0d src_1=R%0d src_2=R%0d Val_Rn=%08h Val_Rm=%08h", ID_Dest, ID_src_1, ID_src_2, ID_Val_Rn, ID_Val_Rm);
            $display("IMMED : Shift_operand=%03h Signed_imm_24=%06h", ID_Shift_operand, ID_Signed_imm_24);
            $display("GATING: Cond_out=%b suppress=%b raw_WB_EN=%b raw_MEM_R_EN=%b raw_MEM_W_EN=%b raw_EXE_CMD=%b", ID_Cond_out, ID_suppress, ID_raw_WB_EN, ID_raw_MEM_R_EN, ID_raw_MEM_W_EN, ID_raw_EXE_CMD);
            $fdisplay(log_file, "%0d,%0d,%08h,%b,%b,%b,%b,%b,%0d,%0d,%0d,%b,%b,%b,%b,%b,%b,%b,%b,%0d,%0d,%0d,%03h,%06h,%08h,%08h,%b,%b,%b,%b,%b,%b",
                cycle, ID_pc, ID_instruction, ID_Cond, ID_Mode, ID_I_bit, ID_Opcode, ID_S_bit,
                ID_Rn_bits, ID_Rd_bits, ID_Rm_bits, ID_B, ID_S, ID_imm, ID_WB_EN, ID_Two_src,
                ID_MEM_W_EN, ID_MEM_R_EN, ID_EXE_CMD, ID_Dest, ID_src_1, ID_src_2,
                ID_Shift_operand, ID_Signed_imm_24, ID_Val_Rn, ID_Val_Rm,
                ID_Cond_out, ID_suppress, ID_raw_WB_EN, ID_raw_MEM_R_EN, ID_raw_MEM_W_EN,
                ID_raw_EXE_CMD);
            @(posedge clk);
            #1; // Nonblocking updates in ID_EXE_Reg have completed.
            if (current_EXE_bus === captured_ID[154:0]) begin
                $display("[PASS] ID -> ID/EXE register transfer");
            end else begin
                errors = errors + 1;
                $display("[FAIL] ID -> ID/EXE register transfer");
            end
            cycle = cycle + 1;
        end
        $display("\nFinished: %0d cycles, %0d pipeline transfer errors", cycle, errors);
        $fclose(log_file);
        $finish;
    end
endmodule
