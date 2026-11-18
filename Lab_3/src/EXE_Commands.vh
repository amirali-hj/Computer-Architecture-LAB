`ifndef EXE_COMMANDS_VH
`define EXE_COMMANDS_VH
// Provisional lab ALU command mapping: verify against Table 5 of ARM handout.
`define CMD_MOV 4'b0001
`define CMD_MVN 4'b1001
`define CMD_ADD 4'b0010
`define CMD_ADC 4'b0011
`define CMD_SUB 4'b0100
`define CMD_SBC 4'b0101
`define CMD_AND 4'b0110
`define CMD_ORR 4'b0111
`define CMD_EOR 4'b1000
`endif
