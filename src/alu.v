module alu (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [3:0] opcode,
    output reg [7:0] result
);

always @(*) begin
    case (opcode)
        4'b0000: result = a + b; // Addition
        4'b0001: result = a - b; // Subtraction
        4'b0010: result = a & b; // Bitwise AND
        4'b0011: result = a | b; // Bitwise OR
        4'b0100: result = a ^ b; // Bitwise XOR
        4'b0101: result = ~a;    // Bitwise NOT
        4'b0110: result = a << 1; // Left shift
        4'b0111: result = a >> 1; // Right shift
        default: result = 8'b00000000; // Default case
    endcase
end

endmodule

