module bin_grey(
  input [3:0] Bin,
  output [3:0] gre
);
  always @(*)  begin
 gre[3] = Bin[3]
gre[2] = Bin[3] ^ Bin[2]
gre[1] = Bin[2] ^ Bin[1]
gre[0] = Bin[1] ^ Bin[0]
  end
endmodule
