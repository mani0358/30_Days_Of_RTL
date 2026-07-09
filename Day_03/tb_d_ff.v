`timescale 1ns/1ps
module tb_d_ff;
	reg din;
	reg clk;
	reg rst;
	wire dout;

d_ff dut(
	.din(din),
	.clk(clk),
	.rst(rst),
	.dout(dout)
);
always #5 clk = ~clk;
initial begin
$monitor("Time=%0t clk=%b rst=%b din=%b dout=%b",$time, clk, rst, din, dout);
$dumpfile("wave.vcd");
$dumpvars(0,tb_d_ff);
	
	clk =0;
	rst =1 ;
	din  =0;
	#10;
	rst=0;
	din=1; #10;
	din=0; #10;
	din=1; #10;
	
$finish;
end 
endmodule

