module tb_half ;
	reg a_in;
	reg b_in;
	wire sum_out;
	wire c_out;
 half_adder dut(
	.a_in(a_in),
	.b_in(b_in),
	.sum_out(sum_out),
	.c_out(c_out)
);

initial begin
	$dumpfile("wave.vcd");
	$dumpvars(0,tb_half);
	$monitor("Time=%0t,a_in=%b,b_in=%b,sum_out=%b,c_out=%b",$time,a_in,b_in,sum_out,c_out);
a_in=0;	b_in=0;
#10;
a_in=0;	b_in=1;
#10;
a_in=1;	b_in=0;
#10;
a_in=1;	b_in=1;
#10;
$finish;
end 
endmodule
