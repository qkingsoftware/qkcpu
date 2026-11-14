
module control_unit (
    input wire clk,
    input wire rst_n,
    input wire [3:0] opcode
);

reg [2:0] state;
reg [2:0] next_state;

always @(*) begin
    next_state = 3'b000;

    case (state)
        3'b000: begin // FETCH
            next_state = 3'b001;
        end

        3'b001: begin // DECODE
            case (opcode)
                4'b0000: next_state = 3'b010; // ADD
                4'b0001: next_state = 3'b010; // SUB
                4'b0010: next_state = 3'b010; // AND
                4'b0011: next_state = 3'b010; // OR
                4'b0100: next_state = 3'b010; // XOR
                4'b0101: next_state = 3'b010; // NOT
                4'b0110: next_state = 3'b010; // SHL
                4'b0111: next_state = 3'b010; // SHR

                4'b1000: next_state = 3'b011; // LDI
                4'b1001: next_state = 3'b011; // LOAD
                4'b1010: next_state = 3'b010; // STORE
                4'b1011: next_state = 3'b011; // MOV

                4'b1100: next_state = 3'b010; // OUT
                4'b1101: next_state = 3'b010; // JMP
                4'b1110: next_state = 3'b010; // JZ
                4'b1111: next_state = 3'b100; // HALT

                default: next_state = 3'b000;
            endcase
        end

        3'b010: begin // EXECUTE
            next_state = 3'b000;
        end

        3'b011: begin // WRITEBACK
            next_state = 3'b000;
        end

        3'b100: begin // HALTED
            next_state = 3'b100;
        end

        default: begin
            next_state = 3'b000;
        end
    endcase
end

always @(posedge clk) begin
    if (!rst_n)
        state <= 3'b000;
    else
        state <= next_state;
end

endmodule
