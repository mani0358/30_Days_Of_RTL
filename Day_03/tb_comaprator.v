`timescale 1ns/1ps
module tb_comparator ;
	reg [1:0]a_in;
	reg [1:0]b_in;
	wire a_gt_b;
	wire a_lt_b;
	wire a_eq_b;

comparator dut(
	.a_in(a_in),
	.b_in(b_in),
	.a_gt_b(a_gt_b),
	.a_lt_b(a_lt_b),
	.a_eq_b(a_eq_b)
);
initial begin 
$dumpfile("wave.vcd");
$dumpvars(0,tb_comparator);

a_in=2'b00;	b_in =2'b00;
#10;
a_in=2'b00;	b_in =2'b01;
#10;
a_in=2'b01;	b_in =2'b00;
#10;
a_in=2'b11;	b_in =2'b11;
#10;
$finish;
end
endmodule
