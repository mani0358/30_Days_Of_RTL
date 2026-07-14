`timescale 1ns/1ps

module tb_asy;

reg clk;
reg reset;
wire [3:0] count;

// Instantiate the DUT
counter_asy uut (
    .clk(clk),
    .reset(reset),
    .count(count)
);

// Clock generation (10 ns period)
always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;

    // Apply asynchronous reset
    #12 reset = 0;

    // Let the counter run
    #100;

    // Apply reset again
    reset = 1;
    #8;
    reset = 0;

    #50;
    $finish;
end

// Monitor output
initial begin
    $monitor("Time=%0t Reset=%b Count=%d (%b)",
             $time, reset, count, count);
end

endmodule
