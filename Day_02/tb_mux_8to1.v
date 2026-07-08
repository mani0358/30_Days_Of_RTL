`timescale 1ns/1ps
module tb_mux_8to1;
	reg [7:0] a,b,c,d,e,f,g,h;
	reg [2:0] sel;
	reg clk;
	wire [7:0] d_out;
mux_8to1 dut (
	.sel(sel),
	.clk(clk),
	.a(a),
	.b(b),
	.c(c),
	.d(d),
	.e(e),
	.f(f),
	.g(g),
	.h(h),
	.d_out(d_out)
);
	always #5 clk = ~clk;
initial begin
$dumpfile("wave.vcd");
$dumpvars(0,tb_mux_8to1);
 	clk=0;
a=8'h11;
b=8'h22;
c=8'h33;
d=8'h44;
e=8'h55;
f=8'h66;
g=8'h77;
h=8'h88;

sel=3'b000;
#20;
sel=3'b001;
#20;
sel=3'b010;
#20;
sel=3'b011;
#20;
sel=3'b100;
#20;

$finish;
end
endmodule
