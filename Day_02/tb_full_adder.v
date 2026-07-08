`timescale 1ns /1ps
module tb_full_adder ;

        reg a_in;
        reg b_in;
	reg c_in ;
         wire sum_out ;
         wire c_out ;
         
  full_adder dut (
  .a_in(a_in),
    .b_in(b_in),
    .c_in(c_in),
    .sum_out(sum_out),
    .c_out(c_out)
);

  initial begin
  $dumpfile("wave.vcd");
  $dumpvars(0,tb_full_adder);
  $monitor("Time =%0t | a_in=%b,b_in=%b,c_in =%b || c_out=%b,sum_out=%b",$time,a_in,b_in,c_in,c_out,sum_out);
  
  a_in=0;	b_in=0;	c_in=0;
  #10;	
  a_in=0;	b_in=0;	c_in=1;
  #10;	
  a_in=0;	b_in=1;	c_in=0;
  #10;	
  a_in=0;	b_in=1;	c_in=1;
  #10;	
  a_in=1;	b_in=0;	c_in=0;
  #10;	
  a_in=1;	b_in=0;	c_in=1;
  #10;	
  a_in=1;	b_in=1;	c_in=0;
  #10;	
  a_in=1;	b_in=1;	c_in=1;
  #10;	
  $finish;
  end
  endmodule
