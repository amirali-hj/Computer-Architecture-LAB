`include "EXE_Commands.vh"
module control_unit (
    input [1:0] Mode,
    input [3:0] Opcode,
    input S_in,
    output reg [3:0] EXE_CMD,
    output reg WB_EN, MEM_R_EN, MEM_W_EN, B, S
);
    always @* begin
        {WB_EN,MEM_R_EN,MEM_W_EN,B,S,EXE_CMD} = 9'b0;
        case (Mode)
            2'b00: begin
                S = S_in;
                WB_EN = 1'b1;
                case (Opcode)
                    4'b1101: EXE_CMD = `CMD_MOV;
                    4'b1111: EXE_CMD = `CMD_MVN;
                    4'b0100: EXE_CMD = `CMD_ADD;
                    4'b0101: EXE_CMD = `CMD_ADC;
                    4'b0010: EXE_CMD = `CMD_SUB;
                    4'b0110: EXE_CMD = `CMD_SBC;
                    4'b0000: EXE_CMD = `CMD_AND;
                    4'b1100: EXE_CMD = `CMD_ORR;
                    4'b0001: EXE_CMD = `CMD_EOR;
                    4'b1010: begin EXE_CMD = `CMD_SUB; WB_EN = 0; S = 1; end
                    4'b1000: begin EXE_CMD = `CMD_AND; WB_EN = 0; S = 1; end
                    default: {WB_EN,S,EXE_CMD} = 6'b0;
                endcase
            end
            2'b01: begin
                // Lab subset: Opcode=0100, bit 20 (S_in) is the L bit.
                if (Opcode == 4'b0100) begin
                    EXE_CMD = `CMD_ADD;
                    MEM_R_EN = S_in;
                    MEM_W_EN = !S_in;
                    WB_EN = S_in;
                end
            end
            2'b10: begin
                // B only, not BL (bit 24 is Opcode[3]).
                if (!Opcode[3]) B = 1'b1;
            end
            default: begin end
        endcase
    end
endmodule
