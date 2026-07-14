`timescale 1ns/1ps

module tb_asy;

reg clk;
reg reset;
wire [3:0] q;

// Instantiate the Counter
count_asy uut(
    .clk(clk),
    .reset(reset),
    .q(q)
);

// Clock Generation (10 ns period)
always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;

    // Hold reset
    #15;
    reset = 0;

    // Run the counter
    #200;

    $finish;
end

// Display output
initial begin
    $display("Time\tReset\tCount");
    $monitor("%0t\t%b\t%b", $time, reset, q);
end

endmodule
