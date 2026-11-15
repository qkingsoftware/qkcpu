module cpu_core (
    input wire clk,
    input wire rst_n,
    input wire run_enable,
    output wire [6:0] program_address,
    input wire [15:0] program_data,
    output reg [6:0] data_address,
    output reg [7:0] data_write_data,
    output reg data_write_enable,
    input wire [7:0] data_read_data,
    output reg [7:0] output_port,
    output wire [31:0] register_values,
    output wire halted
);

localparam STATE_FETCH = 3'd0;
localparam STATE_FETCH_WAIT = 3'd1;
localparam STATE_EXECUTE = 3'd2;
localparam STATE_LOAD_WAIT = 3'd3;
localparam STATE_LOAD_CAPTURE = 3'd4;
localparam STATE_HALTED = 3'd5;

reg [2:0] state;
reg [6:0] program_counter;
reg [15:0] instruction;
reg [7:0] registers [0:3];
reg [1:0] load_destination;
reg [3:0] alu_opcode;
wire [7:0] alu_result;

wire [3:0] opcode = instruction[15:12];
wire [1:0] destination = instruction[11:10];
wire [1:0] source_a = instruction[9:8];
wire [1:0] source_b = instruction[7:6];
wire [7:0] immediate = instruction[9:2];
wire [6:0] memory_address = {1'b0, instruction[9:4]};
wire [6:0] jump_address = {1'b0, instruction[11:6]};

assign program_address = program_counter;
assign register_values = {registers[3], registers[2], registers[1], registers[0]};
assign halted = state == STATE_HALTED;

alu core_alu (
    .a(registers[source_a]),
    .b(registers[source_b]),
    .opcode(alu_opcode),
    .result(alu_result)
);

always @(*) begin
    alu_opcode = opcode;
end

always @(posedge clk) begin
    data_write_enable <= 1'b0;

    if (!rst_n) begin
        state <= STATE_FETCH;
        program_counter <= 7'd0;
        instruction <= 16'd0;
        data_address <= 7'd0;
        data_write_data <= 8'd0;
        output_port <= 8'd0;
        load_destination <= 2'd0;
        registers[0] <= 8'd0;
        registers[1] <= 8'd0;
        registers[2] <= 8'd0;
        registers[3] <= 8'd0;
    end else if (!run_enable) begin
        state <= STATE_FETCH;
    end else begin
        case (state)
            STATE_FETCH: begin
                state <= STATE_FETCH_WAIT;
            end

            STATE_FETCH_WAIT: begin
                instruction <= program_data;
                state <= STATE_EXECUTE;
            end

            STATE_EXECUTE: begin
                case (opcode)
                    4'b0000,
                    4'b0001,
                    4'b0010,
                    4'b0011,
                    4'b0100,
                    4'b0101,
                    4'b0110,
                    4'b0111: begin
                        registers[destination] <= alu_result;
                        program_counter <= program_counter + 7'd1;
                        state <= STATE_FETCH;
                    end

                    4'b1000: begin
                        registers[destination] <= immediate;
                        program_counter <= program_counter + 7'd1;
                        state <= STATE_FETCH;
                    end

                    4'b1001: begin
                        data_address <= memory_address;
                        load_destination <= destination;
                        state <= STATE_LOAD_WAIT;
                    end

                    4'b1010: begin
                        data_address <= memory_address;
                        data_write_data <= registers[source_a];
                        data_write_enable <= 1'b1;
                        program_counter <= program_counter + 7'd1;
                        state <= STATE_FETCH;
                    end

                    4'b1011: begin
                        registers[destination] <= registers[source_a];
                        program_counter <= program_counter + 7'd1;
                        state <= STATE_FETCH;
                    end

                    4'b1100: begin
                        output_port <= registers[source_a];
                        program_counter <= program_counter + 7'd1;
                        state <= STATE_FETCH;
                    end

                    4'b1101: begin
                        program_counter <= jump_address;
                        state <= STATE_FETCH;
                    end

                    4'b1110: begin
                        if (registers[source_a] == 8'd0)
                            program_counter <= jump_address;
                        else
                            program_counter <= program_counter + 7'd1;
                        state <= STATE_FETCH;
                    end

                    4'b1111: begin
                        state <= STATE_HALTED;
                    end

                    default: begin
                        program_counter <= program_counter + 7'd1;
                        state <= STATE_FETCH;
                    end
                endcase
            end

            STATE_LOAD_WAIT: begin
                state <= STATE_LOAD_CAPTURE;
            end

            STATE_LOAD_CAPTURE: begin
                registers[load_destination] <= data_read_data;
                program_counter <= program_counter + 7'd1;
                state <= STATE_FETCH;
            end

            STATE_HALTED: begin
                state <= STATE_HALTED;
            end

            default: begin
                state <= STATE_FETCH;
            end
        endcase
    end
end

endmodule
