`default_nettype none

module alu (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [3:0] opcode,
    output reg [7:0] result
);

    always @(*) begin
        case (opcode)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = a & b;
            4'b0011: result = a | b;
            4'b0100: result = a ^ b;
            4'b0101: result = ~a;
            4'b0110: result = a << 1;
            4'b0111: result = a >> 1;
            default: result = 8'b00000000;
        endcase
    end

endmodule

`default_nettype wire
