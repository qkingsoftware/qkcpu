module datapath (
    input wire [0:0] clk,
    input wire [0:0] rst_n,
    input wire [0:0] enable,
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [3:0] opcode,
    output wire [7:0] stored_result,
    output wire [7:0] alu_result

);

wire [7:0] alu_to_register;

alu alu (
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(alu_to_register)
);

assign alu_result = alu_to_register;

register register (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .a(alu_to_register),
    .b(stored_result)
);


endmodule