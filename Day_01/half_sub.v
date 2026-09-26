module half_sub(
  input a,b
  output b,d
);
  assign d= a  ^ b;
  assign b = ~a & b ;
endmodule
