`timescale 1ns/1ps
module d_ff(
	input din,
	input clk,
	input rst,
	output reg dout
);
always @(posedge clk or posedge rst )begin
	if(rst) begin
	dout <= 0;
end
else begin 
dout <= din;
end
end
endmodule
