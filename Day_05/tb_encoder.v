`timescale 1ns/1ps

module tb_encoder;

reg  [7:0] D;
wire [2:0] out;

encoder uut (
    .D(D),
    .out(out)
);

initial begin
    $dumpfile("encoder.vcd");
    $dumpvars(0, tb_encoder);

    $monitor("Time=%0t D=%b Out=%b", $time, D, out);

    D = 8'b00000001; #10;
    D = 8'b00000010; #10;
    D = 8'b00000100; #10;
    D = 8'b00001000; #10;
    D = 8'b00010000; #10;
    D = 8'b00100000; #10;
    D = 8'b01000000; #10;
    D = 8'b10000000; #10;

    $finish;
end

endmodule
