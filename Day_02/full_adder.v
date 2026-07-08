`timescale 1ns /1ps
module full_adder(
        input wire a_in,
        input wire b_in,
	input c_in,
        output wire sum_out,
        output wire c_out
);
	wire s1;
	wire c1;
	wire c2;

half_adder HA1(
	.a_in(a_in),
	.b_in(b_in),
	.sum_out(s1),
	.c_out(c1)
);

half_adder HA2(
	.a_in(s1),
	.b_in(c_in),
	.sum_out(sum_out),
	.c_out(c2)
);
assign c_out = c2 | c1 ;
endmodule 
