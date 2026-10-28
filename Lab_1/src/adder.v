module adder (
    input [WIDTH-1:0] in1, in2,
    output [WIDTH-1:0] sum
);
    parameter WIDTH = 32;
    assign sum = in1 + in2;
endmodule