`timescale 1ns/1ps

module tb_behavioral_4to1;

	reg[3:0] in;
	reg[1:0] sel;

	wire out;

	behavioral_4to1 uut(
		.in(in),
		.sel(sel),
		.out(out)
);

	initial begin 
	
	in = 4'b1010;

	sel = 2'b00; #10;
	sel = 2'b01; #10;
	sel = 2'b10; #10;
	sel = 2'b11; #10;

	$finish;
 end

	initial begin
		$monitor("Time=%0t Inputs=%b Sel=%b Ouput=%b",
			$time, in, sel, out);

		$dumpfile("wave.vcd");
		$dumpvars(0, behavioral_4to1_tb);
end
endmodule
