// Board ONLY. Simulation testbench instantiates ARM directly.
// ILA: 11 native probes: reset, 5 PCs, and 5 instructions.
// Connect board clock and active-high key1 in a board-specific XDC.
module ARM_FPGA_wrapper (
    input clk,
    input key1
);
    wire [0:0] deb_out;
    wire rst;
    debouncer deb_inst (
        .SIGNAL_I({key1}),
        .CLK_I(clk),
        .SIGNAL_O(deb_out)
    );
    assign rst = deb_out[0];

    ARM ARM_inst (
        .clk(clk), .rst(rst)
    );

    ila_0 ila_inst (
        .clk(clk),
        .probe0(rst),
        .probe1(ARM_inst.IF_pc),
        .probe2(ARM_inst.ID_pc),
        .probe3(ARM_inst.EXE_pc),
        .probe4(ARM_inst.MEM_pc),
        .probe5(ARM_inst.WB_pc),
        .probe6(ARM_inst.IF_instruction),
        .probe7(ARM_inst.ID_instruction),
        .probe8(ARM_inst.EXE_instruction),
        .probe9(ARM_inst.MEM_instruction),
        .probe10(ARM_inst.WB_instruction)
    );
endmodule
