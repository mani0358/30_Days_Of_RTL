module tb_grey_bin;

reg  [3:0] gre;
wire [3:0] bin;

// Instantiate DUT
grey_bin uut (
    .gre(gre),
    .bin(bin)
);

initial begin
    $dumpfile("grey_bin.vcd");
    $dumpvars(0, tb_grey_bin);

    $monitor("Time=%0t | Gray=%b | Binary=%b",
              $time, gre, bin);

    gre = 4'b0000; #10;
    gre = 4'b0001; #10;
    gre = 4'b0011; #10;
    gre = 4'b0010; #10;
    gre = 4'b0110; #10;
    gre = 4'b0111; #10;
    gre = 4'b0101; #10;
    gre = 4'b0100; #10;
    gre = 4'b1100; #10;
    gre = 4'b1101; #10;
    gre = 4'b1111; #10;
    gre = 4'b1110; #10;
    gre = 4'b1010; #10;
    gre = 4'b1011; #10;
    gre = 4'b1001; #10;
    gre = 4'b1000; #10;

    $finish;
end

endmodule
