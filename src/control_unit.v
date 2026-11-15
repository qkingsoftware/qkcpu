`default_nettype none

module control_unit (
    input wire clk,
    input wire rst_n,
    input wire run_enable,
    input wire [3:0] opcode,
    input wire is_zero,
    input wire io_direction,
    input wire [1:0] branch_cond,
    input wire [1:0] sys_cmd,

    output reg fetch_byte_sel,
    output reg inst_latch_lo,
    output reg inst_latch_hi,
    output reg pc_enable,
    output reg pc_jump,
    output reg pc_call,
    output reg pc_ret,
    output reg reg_write_enable,
    output reg [2:0] reg_write_src,
    output reg data_write_enable,
    output reg out_enable,
    output wire halted
);

    localparam STATE_FETCH_LO      = 3'd0;
    localparam STATE_FETCH_WAIT_LO = 3'd1;
    localparam STATE_FETCH_WAIT_HI = 3'd2;
    localparam STATE_EXECUTE       = 3'd3;
    localparam STATE_LOAD_WAIT     = 3'd4;
    localparam STATE_LOAD_CAPTURE  = 3'd5;
    localparam STATE_HALTED        = 3'd6;

    reg [2:0] state;
    reg [2:0] next_state;

    assign halted = (state == STATE_HALTED);

    always @(*) begin
        next_state = state;

        case (state)
            STATE_FETCH_LO: begin
                next_state = STATE_FETCH_WAIT_LO;
            end

            STATE_FETCH_WAIT_LO: begin
                next_state = STATE_FETCH_WAIT_HI;
            end

            STATE_FETCH_WAIT_HI: begin
                next_state = STATE_EXECUTE;
            end

            STATE_EXECUTE: begin
                case (opcode)
                    4'b0000, 4'b0001, 4'b0010, 4'b0011,
                    4'b0100, 4'b0101, 4'b0110, 4'b0111,
                    4'b1000, 4'b1010, 4'b1011, 4'b1100,
                    4'b1101, 4'b1110: begin
                        next_state = STATE_FETCH_LO;
                    end

                    4'b1001: begin
                        next_state = STATE_LOAD_WAIT;
                    end

                    4'b1111: begin
                        if (sys_cmd == 2'b00)
                            next_state = STATE_HALTED;
                        else
                            next_state = STATE_FETCH_LO;
                    end

                    default: begin
                        next_state = STATE_FETCH_LO;
                    end
                endcase
            end

            STATE_LOAD_WAIT: begin
                next_state = STATE_LOAD_CAPTURE;
            end

            STATE_LOAD_CAPTURE: begin
                next_state = STATE_FETCH_LO;
            end

            STATE_HALTED: begin
                next_state = STATE_HALTED;
            end

            default: begin
                next_state = STATE_FETCH_LO;
            end
        endcase
    end

    always @(*) begin
        fetch_byte_sel    = 1'b0;
        inst_latch_lo     = 1'b0;
        inst_latch_hi     = 1'b0;
        pc_enable         = 1'b0;
        pc_jump           = 1'b0;
        pc_call           = 1'b0;
        pc_ret            = 1'b0;
        reg_write_enable  = 1'b0;
        reg_write_src     = 3'd0;
        data_write_enable = 1'b0;
        out_enable        = 1'b0;

        case (state)
            STATE_FETCH_LO: begin
                fetch_byte_sel = 1'b0;
            end

            STATE_FETCH_WAIT_LO: begin
                fetch_byte_sel = 1'b1;
                inst_latch_lo  = 1'b1;
            end

            STATE_FETCH_WAIT_HI: begin
                inst_latch_hi = 1'b1;
            end

            STATE_EXECUTE: begin
                case (opcode)
                    4'b0000, 4'b0001, 4'b0010, 4'b0011,
                    4'b0100, 4'b0101, 4'b0110, 4'b0111: begin
                        reg_write_enable = 1'b1;
                        reg_write_src    = 3'd0;
                        pc_enable        = 1'b1;
                    end

                    4'b1000: begin
                        reg_write_enable = 1'b1;
                        reg_write_src    = 3'd1;
                        pc_enable        = 1'b1;
                    end

                    4'b1001: begin
                    end

                    4'b1010: begin
                        data_write_enable = 1'b1;
                        pc_enable         = 1'b1;
                    end

                    4'b1011: begin
                        reg_write_enable = 1'b1;
                        reg_write_src    = 3'd3;
                        pc_enable        = 1'b1;
                    end

                    4'b1100: begin
                        if (!io_direction) begin
                            out_enable = 1'b1;
                            pc_enable  = 1'b1;
                        end else begin
                            reg_write_enable = 1'b1;
                            reg_write_src    = 3'd4;
                            pc_enable        = 1'b1;
                        end
                    end

                    4'b1101: begin
                        case (branch_cond)
                            2'b00: pc_jump = 1'b1;
                            2'b01: begin
                                if (is_zero)
                                    pc_jump = 1'b1;
                                else
                                    pc_enable = 1'b1;
                            end
                            2'b10: begin
                                if (!is_zero)
                                    pc_jump = 1'b1;
                                else
                                    pc_enable = 1'b1;
                            end
                            default: pc_enable = 1'b1;
                        endcase
                    end

                    4'b1110: begin
                        pc_jump = 1'b1;
                        pc_call = 1'b1;
                    end

                    4'b1111: begin
                        case (sys_cmd)
                            2'b00: begin end
                            2'b01: pc_enable = 1'b1;
                            2'b10: pc_ret = 1'b1;
                            default: pc_enable = 1'b1;
                        endcase
                    end

                    default: begin
                        pc_enable = 1'b1;
                    end
                endcase
            end

            STATE_LOAD_WAIT: begin
            end

            STATE_LOAD_CAPTURE: begin
                reg_write_enable = 1'b1;
                reg_write_src    = 3'd2;
                pc_enable        = 1'b1;
            end

            STATE_HALTED: begin
            end

            default: begin
            end
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= STATE_FETCH_LO;
        end else if (!run_enable) begin
            state <= STATE_FETCH_LO;
        end else begin
            state <= next_state;
        end
    end

endmodule

`default_nettype wire
