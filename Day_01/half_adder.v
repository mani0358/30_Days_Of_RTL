module half_adder(
        input wire a_in,
        input wire b_in,
        output wire sum_out,
        output wire c_out
);
        assign sum_out = a_in ^ b_in;
        assign c_out = a_in & b_in;
endmodule 
