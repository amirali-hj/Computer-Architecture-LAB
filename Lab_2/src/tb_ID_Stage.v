`timescale 1ns/1ps
`include "EXE_Commands.vh"
module tb_ID_Stage;
    // Icarus: compile with -DDUMP_VCD to export waveforms.
`ifdef DUMP_VCD
    initial begin
        $dumpfile("tb_ID_Stage.vcd");
        $dumpvars(0, tb_ID_Stage);
    end
`endif
    reg clk=0; always #5 clk=~clk;
    reg rst=0, Hazard=0, writeBackEN=0;
    reg [31:0] PC_in=32'd0, Instruction=0, Result_WB=0;
    reg [3:0] SR=0, Dest_WB=0;
    wire [31:0] PC;
    wire B;
    wire S;
    wire imm;
    wire WB_EN;
    wire Two_src;
    wire MEM_W_EN;
    wire MEM_R_EN;
    wire [3:0] Dest;
    wire [3:0] EXE_CMD;
    wire [3:0] src_1;
    wire [3:0] src_2;
    wire [11:0] Shift_operand;
    wire [23:0] Signed_imm_24;
    wire [31:0] Val_Rn;
    wire [31:0] Val_Rm;
    wire [31:0] q_PC;
    wire q_B;
    wire q_S;
    wire q_imm;
    wire q_WB_EN;
    wire q_Two_src;
    wire q_MEM_W_EN;
    wire q_MEM_R_EN;
    wire [3:0] q_Dest;
    wire [3:0] q_EXE_CMD;
    wire [3:0] q_src_1;
    wire [3:0] q_src_2;
    wire [11:0] q_Shift_operand;
    wire [23:0] q_Signed_imm_24;
    wire [31:0] q_Val_Rn;
    wire [31:0] q_Val_Rm;

    reg freeze=0, flush=0;
    ID_Stage dut (.clk(clk),.rst(rst),.PC_in(PC_in),.Instruction(Instruction),
      .SR(SR),.Hazard(Hazard),.writeBackEN(writeBackEN),.Dest_WB(Dest_WB),
      .Result_WB(Result_WB),.PC(PC),
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
      .Val_Rm(Val_Rm));
    ID_EXE_Reg pipe (.clk(clk),.rst(rst),.freeze(freeze),.flush(flush),
      .PC_in(PC),.PC(q_PC),
      .B_in(B),.B(q_B),
      .S_in(S),.S(q_S),
      .imm_in(imm),.imm(q_imm),
      .WB_EN_in(WB_EN),.WB_EN(q_WB_EN),
      .Two_src_in(Two_src),.Two_src(q_Two_src),
      .MEM_W_EN_in(MEM_W_EN),.MEM_W_EN(q_MEM_W_EN),
      .MEM_R_EN_in(MEM_R_EN),.MEM_R_EN(q_MEM_R_EN),
      .Dest_in(Dest),.Dest(q_Dest),
      .EXE_CMD_in(EXE_CMD),.EXE_CMD(q_EXE_CMD),
      .src_1_in(src_1),.src_1(q_src_1),
      .src_2_in(src_2),.src_2(q_src_2),
      .Shift_operand_in(Shift_operand),.Shift_operand(q_Shift_operand),
      .Signed_imm_24_in(Signed_imm_24),.Signed_imm_24(q_Signed_imm_24),
      .Val_Rn_in(Val_Rn),.Val_Rn(q_Val_Rn),
      .Val_Rm_in(Val_Rm),.Val_Rm(q_Val_Rm));
    integer failures = 0;
    integer vector_index = 0;
    reg [255:0] test_name;
    task check;
        input ok;
        input [255:0] what;
        begin
            if (ok !== 1'b1) begin
                failures = failures + 1;
                $display("FAIL vector %0d (%0s): %0s", vector_index, test_name, what);
            end
        end
    endtask

    // Control Signals.xlsx, sheet "ID stage", A2:A19, in original order.
    // Only instruction words are stimulus. Other columns describe outputs.
    // SR={N,Z,C,V}=0, Hazard=0, no WB: registers keep their index values.
    // Each vector begins at negedge and spans two full 10 ns clocks.
    task apply_vector;
        input [31:0] instruction_word;
        input [31:0] pc_value;
        input [255:0] name;
        input [8:0] expected_controls;
        input [3:0] expected_src2;
        begin
            @(negedge clk);
            vector_index = vector_index + 1;
            test_name = name;
            Instruction = instruction_word;
            PC_in = pc_value;
            #1;
            check({WB_EN,MEM_R_EN,MEM_W_EN,EXE_CMD,B,S} == expected_controls,
                  "control outputs");
            check(PC == pc_value, "PC passthrough");
            check(Dest == instruction_word[15:12], "Dest");
            check(src_1 == instruction_word[19:16], "src_1");
            check(src_2 == expected_src2, "src_2 (Rd for STR, otherwise Rm)");
            check(Val_Rn == {28'b0,src_1}, "Val_Rn initialized register value");
            check(Val_Rm == {28'b0,src_2}, "Val_Rm initialized register value");
            check(imm == instruction_word[25], "imm");
            check(Two_src == (!instruction_word[25] || instruction_word[27:26]==2'b01 && !instruction_word[20]), "Two_src");
            check(Shift_operand == instruction_word[11:0], "Shift_operand");
            check(Signed_imm_24 == instruction_word[23:0], "Signed_imm_24 raw bits");
            @(posedge clk); #1;
            check(q_PC == PC, "ID/EXE PC");
            check(q_B == B, "ID/EXE B");
            check(q_S == S, "ID/EXE S");
            check(q_imm == imm, "ID/EXE imm");
            check(q_WB_EN == WB_EN, "ID/EXE WB_EN");
            check(q_Two_src == Two_src, "ID/EXE Two_src");
            check(q_MEM_W_EN == MEM_W_EN, "ID/EXE MEM_W_EN");
            check(q_MEM_R_EN == MEM_R_EN, "ID/EXE MEM_R_EN");
            check(q_Dest == Dest, "ID/EXE Dest");
            check(q_EXE_CMD == EXE_CMD, "ID/EXE EXE_CMD");
            check(q_src_1 == src_1, "ID/EXE src_1");
            check(q_src_2 == src_2, "ID/EXE src_2");
            check(q_Shift_operand == Shift_operand, "ID/EXE Shift_operand");
            check(q_Signed_imm_24 == Signed_imm_24, "ID/EXE Signed_imm_24");
            check(q_Val_Rn == Val_Rn, "ID/EXE Val_Rn");
            check(q_Val_Rm == Val_Rm, "ID/EXE Val_Rm");
            @(posedge clk); #1;
        end
    endtask

    initial begin
        // Establish an explicit reset edge before presenting the vectors.
        #1; rst = 1;
        repeat (2) @(posedge clk);
        @(negedge clk); rst = 0;
        SR = 4'b0000;
        Hazard = 0;
        writeBackEN = 0;
        Dest_WB = 0;
        Result_WB = 0;
        freeze = 0;
        flush = 0;

        // Excel row 2: 1. 32'b1110_00_1_1101_0_0000_0000_000000010100; //MOV R0 ,#20  //R0 = 20
        apply_vector(32'hE3A00014, 32'd4, "MOV R0 ,#20", 9'b100000100, 4'd4);
        // Excel row 3: 2. 32'b1110_00_1_1101_0_0000_0001_101000000001; //MOV R1 ,#4096 //R1 = 4096
        apply_vector(32'hE3A01A01, 32'd8, "MOV R1 ,#4096", 9'b100000100, 4'd1);
        // Excel row 4: 3. 32'b1110_00_1_1101_0_0000_0010_000100000011; //MOV R2 ,#0xC0000000 //R2 = -1073741824
        apply_vector(32'hE3A02103, 32'd12, "MOV R2 ,#0xC0000000", 9'b100000100, 4'd3);
        // Excel row 5: 4. 32'b1110_00_0_0100_1_0010_0011_000000000010; //ADD R3 ,R2,R2 //R3 = -2147483648
        apply_vector(32'hE0923002, 32'd16, "ADD R3 ,R2,R2", 9'b100001001, 4'd2);
        // Excel row 6: 5. 32'b1110_00_0_0101_0_0000_0100_000000000000; //ADC R4 ,R0,R0 //R4 = 41
        apply_vector(32'hE0A04000, 32'd20, "ADC R4 ,R0,R0", 9'b100001100, 4'd0);
        // Excel row 7: 6. 32'b1110_00_0_0010_0_0100_0101_000100000100; //SUB R5 ,R4,R4,LSL #2 //R5 = -123
        apply_vector(32'hE0445104, 32'd24, "SUB R5 ,R4,R4,LSL #2", 9'b100010000, 4'd4);
        // Excel row 8: 7. 32'b1110_00_0_0110_0_0000_0110_000010100000; //SBC R6 ,R0,R0,LSR #1 //R6 = 10
        apply_vector(32'hE0C060A0, 32'd28, "SBC R6 ,R0,R0,LSR #1", 9'b100010100, 4'd0);
        // Excel row 9: 8. 32'b1110_00_0_1100_0_0101_0111_000101000010; //ORR R7 ,R5,R2,ASR #2 //R7 = -123
        apply_vector(32'hE1857142, 32'd32, "ORR R7 ,R5,R2,ASR #2", 9'b100011100, 4'd2);
        // Excel row 10: 9. 32'b1110_00_0_0000_0_0111_1000_000000000011; //AND R8 ,R7,R3 //R8 = -2147483648
        apply_vector(32'hE0078003, 32'd36, "AND R8 ,R7,R3", 9'b100011000, 4'd3);
        // Excel row 11: 10. 32'b1110_00_0_1111_0_0000_1001_000000000110; //MVN R9 ,R6 //R9 = -11
        apply_vector(32'hE1E09006, 32'd40, "MVN R9 ,R6", 9'b100100100, 4'd6);
        // Excel row 12: 11. 32'b1110_00_0_0001_0_0100_1010_000000000101; //EOR R10,R4,R5 //R10 = -84
        apply_vector(32'hE024A005, 32'd44, "EOR R10,R4,R5", 9'b100100000, 4'd5);
        // Excel row 13: 12. 32'b1110_00_0_1010_1_1000_0000_000000000110; //CMP R8 ,R6
        apply_vector(32'hE1580006, 32'd48, "CMP R8 ,R6", 9'b000010001, 4'd6);
        // Excel row 14: 13. 32'b0001_00_0_0100_0_0001_0001_000000000001; //ADDNE R1 ,R1,R1 //R1 = 8192
        apply_vector(32'h10811001, 32'd52, "ADDNE R1 ,R1,R1", 9'b100001000, 4'd1);
        // Excel row 15: 14. 32'b1110_00_0_1000_1_1001_0000_000000001000; //TST R9 ,R8
        apply_vector(32'hE1190008, 32'd56, "TST R9 ,R8", 9'b000011001, 4'd8);
        // Excel row 16: 15. 32'b0000_00_0_0100_0_0010_0010_000000000010; //ADDEQ R2 ,R2,R2  //R2 = -1073741824
        apply_vector(32'h00822002, 32'd60, "ADDEQ R2 ,R2,R2", 9'b000000000, 4'd2);
        // Excel row 17: 16. 32'b1110_00_1_1101_0_0000_0000_101100000001; //MOV R0 ,#1024 //R0 = 1024
        apply_vector(32'hE3A00B01, 32'd64, "MOV R0 ,#1024", 9'b100000100, 4'd1);
        // Excel row 18: 17. 32'b1110_01_0_0100_0_0000_0001_000000000000; //STR R1 ,[R0],#0 //MEM[1024] = 8192
        apply_vector(32'hE4801000, 32'd68, "STR R1 ,[R0],#0", 9'b001001000, 4'd1);
        // Excel row 19: 18. 32'b1110_01_0_0100_1_0000_1011_000000000000; //LDR R11,[R0],#0 //R11 = 8192
        apply_vector(32'hE490B000, 32'd72, "LDR R11,[R0],#0", 9'b110001000, 4'd0);

        if (failures == 0)
            $display("PASS: all 18 spreadsheet vectors and ID/EXE outputs");
        else begin
            $display("FAIL: %0d checks failed", failures);
            $fatal(1);
        end
        $finish;
    end
endmodule
