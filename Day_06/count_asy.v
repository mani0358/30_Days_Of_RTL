`timescale 1ns/1ps

module count_asy(
    input clk,
    input reset,
    output [3:0] q
);

wire q0, q1, q2, q3;
wire qb0, qb1, qb2, qb3;

// Toggle Flip-Flop 0
t_ff FF0(
    .clk(clk),
    .reset(reset),
    .q(q0),
    .qb(qb0)
);

// Toggle Flip-Flop 1
t_ff FF1(
    .clk(q0),
    .reset(reset),
    .q(q1),
    .qb(qb1)
);

// Toggle Flip-Flop 2
t_ff FF2(
    .clk(q1),
    .reset(reset),
    .q(q2),
    .qb(qb2)
);

// Toggle Flip-Flop 3
t_ff FF3(
    .clk(q2),
    .reset(reset),
    .q(q3),
    .qb(qb3)
);

assign q = {q3, q2, q1, q0};

endmodule


//-------------------------
// T Flip-Flop
//-------------------------
module t_ff(
    input clk,
    input reset,
    output reg q,
    output qb
);

assign qb = ~q;

always @(posedge clk or posedge reset)
begin
    if(reset)
        q <= 1'b0;
    else
        q <= ~q;
end

endmodule
