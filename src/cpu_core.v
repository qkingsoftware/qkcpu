// This combines all the modules into one
// This file itself doesnt do much
// It just connects modules together and wires them
`default_nettype none

module cpu_core (
    input wire clk,
    input wire rst_n,
    input wire run_enable,
    input wire [7:0] input_port,

    output wire [6:0] program_address,
    input wire [7:0] program_data,

    output wire [6:0] data_address,
    output wire [7:0] data_write_data,
    output wire data_write_enable,
    input wire [7:0] data_read_data,

    output reg [7:0] output_port,
    output wire [31:0] register_values,
    output wire halted
);

    reg [15:0] instruction;

    wire [3:0] opcode;
    wire [1:0] dest;
    wire [1:0] src_a;
    wire [1:0] src_b;
    wire [7:0] immediate;
    wire [5:0] jump_address;
    wire [6:0] memory_address;
    wire io_direction;
    wire mem_mode;
    wire [1:0] branch_cond;
    wire [1:0] sys_cmd;

    wire fetch_byte_sel;
    wire inst_latch_lo;
    wire inst_latch_hi;
    wire pc_enable;
    wire pc_jump;
    wire pc_call;
    wire pc_ret;
    wire reg_write_enable;
    wire [2:0] reg_write_src;
    wire out_enable;

    wire [7:0] reg_data_a;
    wire [7:0] reg_data_b;
    reg  [7:0] reg_write_data;

    wire [7:0] alu_result;
    wire [5:0] pc_count;

    assign program_address = {pc_count, fetch_byte_sel};
    assign data_address    = mem_mode ? (opcode == 4'b1010 ? reg_data_b[6:0] : reg_data_a[6:0]) : memory_address;
    assign data_write_data = reg_data_a;

    always @(posedge clk) begin
        if (!rst_n) begin
            instruction <= 16'd0;
        end else begin
            if (inst_latch_lo)
                instruction[7:0] <= program_data;
            if (inst_latch_hi)
                instruction[15:8] <= program_data;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            output_port <= 8'd0;
        end else if (out_enable) begin
            output_port <= reg_data_a;
        end
    end

    inst_decoder u_decoder (
        .instruction    (instruction),
        .opcode         (opcode),
        .dest           (dest),
        .src_a          (src_a),
        .src_b          (src_b),
        .immediate      (immediate),
        .jump_address   (jump_address),
        .memory_address (memory_address),
        .io_direction   (io_direction),
        .mem_mode       (mem_mode),
        .branch_cond    (branch_cond),
        .sys_cmd        (sys_cmd)
    );

    control_unit u_ctrl (
        .clk               (clk),
        .rst_n             (rst_n),
        .run_enable        (run_enable),
        .opcode            (opcode),
        .is_zero           (reg_data_a == 8'd0),
        .io_direction      (io_direction),
        .branch_cond       (branch_cond),
        .sys_cmd           (sys_cmd),
        .fetch_byte_sel    (fetch_byte_sel),
        .inst_latch_lo     (inst_latch_lo),
        .inst_latch_hi     (inst_latch_hi),
        .pc_enable         (pc_enable),
        .pc_jump           (pc_jump),
        .pc_call           (pc_call),
        .pc_ret            (pc_ret),
        .reg_write_enable  (reg_write_enable),
        .reg_write_src     (reg_write_src),
        .data_write_enable (data_write_enable),
        .out_enable        (out_enable),
        .halted            (halted)
    );

    always @(*) begin
        case (reg_write_src)
            3'd0: reg_write_data = alu_result;
            3'd1: reg_write_data = immediate;
            3'd2: reg_write_data = data_read_data;
            3'd3: reg_write_data = reg_data_a;
            3'd4: reg_write_data = input_port;
            default: reg_write_data = reg_data_a;
        endcase
    end

    register_bank u_regbank (
        .clk             (clk),
        .rst_n           (rst_n),
        .write_enable    (reg_write_enable),
        .write_select    (dest),
        .write_data      (reg_write_data),
        .read_select_a   (src_a),
        .read_select_b   (src_b),
        .read_data_a     (reg_data_a),
        .read_data_b     (reg_data_b),
        .register_values (register_values)
    );

    alu u_alu (
        .a      (reg_data_a),
        .b      (reg_data_b),
        .opcode (opcode),
        .result (alu_result)
    );

    pgrm_counter u_pc (
        .clk          (clk),
        .rst_n        (rst_n),
        .enable       (pc_enable),
        .jump         (pc_jump),
        .call         (pc_call),
        .ret          (pc_ret),
        .jump_address (jump_address),
        .count        (pc_count)
    );

endmodule

`default_nettype wire
