
module toggle_0 (
    input clk,
    input reg key1, key2,

    output reg led1
  );

  initial
  begin
    led1 = 1'b0;
  end

  always @(posedge clk)
  begin

    if(key1)
      led1 <= 1'b1;
    else if(key2)
      led1 <= 1'b0;

  end
endmodule