module ALU (
    input  wire [31:0] Val1,
    input  wire [31:0] Val2,
    input  wire [3:0]  EXE_CMD,
    input  wire        C_in,
    output reg  [31:0] ALU_res,
    output reg         N,
    output reg         Z,
    output reg         C,
    output reg         V
);
    reg [32:0] extended_result;

    always @(*) begin
        ALU_res = 32'b0;
        extended_result = 33'b0;
        C = 1'b0;
        V = 1'b0;

        case (EXE_CMD)
            4'b0001: ALU_res = Val2;                    // MOV
            4'b1001: ALU_res = ~Val2;                   // MVN

            4'b0010: begin                             // ADD, LDR, STR
                extended_result = {1'b0, Val1} + {1'b0, Val2};
                ALU_res = extended_result[31:0];
                C = extended_result[32];
                V = (~(Val1[31] ^ Val2[31])) & (Val1[31] ^ ALU_res[31]);
            end
            4'b0011: begin                             // ADC
                extended_result = {1'b0, Val1} + {1'b0, Val2} + {32'b0, C_in};
                ALU_res = extended_result[31:0];
                C = extended_result[32];
                V = (~(Val1[31] ^ Val2[31])) & (Val1[31] ^ ALU_res[31]);
            end
            4'b0100: begin                             // SUB, CMP
                extended_result = {1'b0, Val1} + {1'b0, ~Val2} + 33'd1;
                ALU_res = extended_result[31:0];
                C = extended_result[32];               // 1 = no borrow
                V = (Val1[31] ^ Val2[31]) & (Val1[31] ^ ALU_res[31]);
            end
            4'b0101: begin                             // SBC: Val1 - Val2 - !C_in
                extended_result = {1'b0, Val1} + {1'b0, ~Val2} + {32'b0, C_in};
                ALU_res = extended_result[31:0];
                C = extended_result[32];
                V = (Val1[31] ^ Val2[31]) & (Val1[31] ^ ALU_res[31]);
            end
            4'b0110: ALU_res = Val1 & Val2;             // AND, TST
            4'b0111: ALU_res = Val1 | Val2;             // ORR
            4'b1000: ALU_res = Val1 ^ Val2;             // EOR
            default: ALU_res = 32'b0;
        endcase

        N = ALU_res[31];
        Z = (ALU_res == 32'b0);
    end
endmodule
