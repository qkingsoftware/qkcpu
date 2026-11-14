module datapath (
    input wire [0:0] clk,
    input wire [0:0] rst_n,
    input wire [0:0] enable,
    input wire [1:0] write_select,
    input wire [1:0] read_select_a,
    input wire [1:0] read_select_b,
    input wire [7:0] write_data,
    input wire [3:0] opcode,
    input wire writeback_select,
    output wire [7:0] alu_result
    
);


wire [7:0] alu_to_register;
wire [7:0] register_data_a;
wire [7:0] register_data_b;
wire [7:0] writeback_data;

alu alu (
    .a(register_data_a),
    .b(register_data_b),
    .opcode(opcode),
    .result(alu_to_register)
);

assign alu_result = alu_to_register;
assign writeback_data = writeback_select ? alu_to_register : write_data;

register_bank register_bank (
    .clk(clk),
    .rst_n(rst_n),
    .write_enable(enable),
    .write_select(write_select),
    .write_data(writeback_data),
    .read_select_a(read_select_a),
    .read_select_b(read_select_b),
    .read_data_a(register_data_a),
    .read_data_b(register_data_b)
);


endmodule