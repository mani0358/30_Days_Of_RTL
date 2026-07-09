`timescale 1ns/1ps
module comparator(
	input [1:0] a_in,
	input [1:0] b_in,
	output a_gt_b,
	output  a_lt_b,
	output a_eq_b
);
assign  a_gt_b = (a_in >  b_in);
assign  a_lt_b = ( a_in <  b_in);
assign  a_eq_b = (a_in == b_in);
endmodule 
