`timescale 1ns/1ps

module tb_counter;

reg clk;
reg rst;
wire [2:0] count;

// Instantiate the DUT
counter dut (
    .clk(clk),
    .rst(rst),
    .count(count)
);

// Clock Generation (10 ns period)
always #5 clk = ~clk;

// Test Stimulus
initial begin
    // Initialize signals
    clk = 0;
    rst = 1;

    // Create VCD file
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_counter);

    // Display output in terminal
    $monitor("Time = %0t | rst = %b | count = %b (%0d)",
              $time, rst, count, count);

    // Hold reset for 10 ns
    #10;
    rst = 0;

    // Let the counter run for 80 ns
    #80;

    // Apply reset again
    rst = 1;
    #10;

    // Release reset
    rst = 0;
    #40;

    $finish;
end

endmodule
