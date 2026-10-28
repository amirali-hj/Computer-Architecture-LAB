`timescale 1ns / 1ps

module tb_ARM();

    // Testbench signals
    reg clk;
    reg rst;

    // Instantiate the ARM processor directly for simulation
    ARM uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation (10 ns period -> 100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // 1. Initial Reset 
        // Verifies that PC becomes 0 when reset is active
        rst = 1;
        #20;

        // 2. Release Reset 
        // Verifies that PC counts up (0, 1, 2...) and instructions ripple through 
        // IF/ID, ID/EXE, EXE/MEM, and MEM/WB registers on each clock cycle
        rst = 0;
        #100;

        // 3. Assert Reset Again
        // Verifies that PC successfully resets back to 0 mid-execution
        rst = 1;
        #20;
        
        // 4. Release Reset and resume execution
        rst = 0;
        #100;

        // End simulation
        $stop;
    end

endmodule