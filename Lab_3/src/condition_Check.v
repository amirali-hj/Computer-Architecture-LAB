module condition_Check (
    input [3:0] Cond, SR,
    output reg Cond_out
);
    // Explicit convention: SR = {N,Z,C,V}. Check against the main handout.
    wire N = SR[3], Z = SR[2], C = SR[1], V = SR[0];
    always @* begin
        case (Cond)
            4'h0: Cond_out = Z;
            4'h1: Cond_out = !Z;
            4'h2: Cond_out = C;
            4'h3: Cond_out = !C;
            4'h4: Cond_out = N;
            4'h5: Cond_out = !N;
            4'h6: Cond_out = V;
            4'h7: Cond_out = !V;
            4'h8: Cond_out = C && !Z;
            4'h9: Cond_out = !C || Z;
            4'hA: Cond_out = (N == V);
            4'hB: Cond_out = (N != V);
            4'hC: Cond_out = !Z && (N == V);
            4'hD: Cond_out = Z || (N != V);
            4'hE: Cond_out = 1'b1;
            default: Cond_out = 1'b0;
        endcase
    end
endmodule
