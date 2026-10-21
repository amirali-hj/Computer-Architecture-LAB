module Toggle_v1_0 (
    input wire clk,
    input wire key1,
    input wire key2,
    output reg led1
);
    reg key1_prev;
    reg key2_prev;

    initial begin
        led1 = 1'b0;
        key1_prev = 1'b1; 
        key2_prev = 1'b1;
    end

    always @(posedge clk) begin
        key1_prev <= key1;
        key2_prev <= key2;

        if (key1_prev == 1'b1 && key1 == 1'b0) begin
            led1 <= 1'b0;
        end 
        else if (key2_prev == 1'b1 && key2 == 1'b0) begin
            led1 <= 1'b1;
        end
    end

endmodule
