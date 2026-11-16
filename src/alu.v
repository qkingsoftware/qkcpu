// ALU module
// All math will be parsed to this module and send back to the result register for further processing
`default_nettype none

module alu (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [3:0] opcode,
    output reg [7:0] result
);

    always @(*) begin
        case (opcode)
            4'b0000: result = a + b; // ADD
            4'b0001: result = a - b; // SUB
            4'b0010: result = a & b; // AND
            4'b0011: result = a | b; // OR
            4'b0100: result = a ^ b; // XOR
            4'b0101: result = ~a; // NOT
            4'b0110: result = a << 1; // SHL
            4'b0111: result = a >> 1; // SHR
            default: result = 8'b00000000; // Default is add, for if you forget to set the opcode
        endcase
    end

endmodule

`default_nettype wire
