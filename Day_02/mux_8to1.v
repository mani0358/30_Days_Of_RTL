`timescale 1ns / 1ps
module mux_8to1(
	input [7:0] a,b,c,d,e,f,g,h,
	input [2:0] sel,
	output reg [7:0] d_out,
	input clk
);
reg [7:0] ta,tb,tc,td,te,tf,tg,th;
reg [2:0] tsel;

	always @(posedge clk) begin
ta <=a;
tb <=b;
tc <=c;
td <=d;
te <=e;
tf <=f;
tg <=g;
th <=h;
tsel <= sel;
end
reg [7:0] temp;
	always @(posedge clk) begin
	case(tsel)
0: temp <= ta;
1: temp <=tb ;
2: temp <=tc;
3: temp<=td;
4:temp<=te;
5:temp<=tf;
6:temp<=tg;
7:temp <=th;
	default : temp <= 8'h00;
endcase
d_out <=temp;
end
endmodule
