`timescale 1ns/1ps

module encoder
#(
    parameter W = 8
)
(
    input  wire [W-1:0] D,
    output reg [$clog2(W)-1:0] out
);

always @(*) begin
    case (D)
        8'b00000001: out = 3'd0;
        8'b00000010: out = 3'd1;
        8'b00000100: out = 3'd2;
        8'b00001000: out = 3'd3;
        8'b00010000: out = 3'd4;
        8'b00100000: out = 3'd5;
        8'b01000000: out = 3'd6;
        8'b10000000: out = 3'd7;
        default:     out = 3'd0;
    endcase
end

endmodule
