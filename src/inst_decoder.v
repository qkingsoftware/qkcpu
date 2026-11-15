`default_nettype none

module inst_decoder (
    input wire [15:0] instruction,

    output wire [3:0] opcode,
    output wire [1:0] dest,
    output wire [1:0] src_a,
    output wire [1:0] src_b,
    output wire [7:0] immediate,
    output wire [5:0] jump_address,
    output wire [6:0] memory_address,
    output wire       io_direction,
    output wire       mem_mode,
    output wire [1:0] branch_cond,
    output wire [1:0] sys_cmd
);

    assign opcode         = instruction[15:12];
    assign dest           = (instruction[15:12] == 4'b1100 && instruction[11] == 1'b1) ? instruction[9:8] : instruction[11:10];
    assign src_a          = (instruction[15:12] == 4'b1101) ? instruction[5:4] : instruction[9:8];
    assign src_b          = instruction[7:6];
    assign immediate      = instruction[9:2];
    assign jump_address   = instruction[11:6];
    assign memory_address = {1'b0, instruction[9:4]};
    assign io_direction   = instruction[11];
    assign mem_mode       = instruction[0];
    assign branch_cond    = instruction[1:0];
    assign sys_cmd        = instruction[1:0];

endmodule

`default_nettype wire
