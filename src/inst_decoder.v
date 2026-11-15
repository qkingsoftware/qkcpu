module inst_decoder(
    input wire [15:0] instruction,

    output reg [3:0] opcode,
    output reg [1:0] dest,
    output reg [1:0] src_a,
    output reg [1:0] src_b,
    output reg [7:0] immediate,
    output reg [5:0] address
);

    always @(*) begin
        opcode = instruction[15:12];
        dest = instruction[11:10];
        src_a = instruction[9:8];
        src_b = instruction[7:6];
        case (opcode)
            4'b0000: begin // ADD
                immediate = 8'd0;
                address = 6'd0;
            end
            4'b0001: begin // SUB
                immediate = 8'd0;
                address = 6'd0;
            end
            4'b0010: begin // AND
                immediate = 8'd0;
                address = 6'd0;
            end
            4'b0011: begin // OR
                immediate = 8'd0;
                address = 6'd0;
            end
            4'b0100: begin // XOR
                immediate = 8'd0;
                address = 6'd0;
            end
            4'b0101: begin // NOT
                immediate = 8'd0;
                address = 6'd0;
            end
            4'b0110: begin // SHL
                immediate = 8'd0;
                address = 6'd0;
            end
            4'b0111: begin // SHR
                immediate = 8'd0;
                address = 6'd0;
            end
            4'b1000: begin // LDI
                immediate = instruction[9:2];
                address = 6'd0;
            end
            4'b1001: begin // LOAD
                immediate = 8'd0;
                address = instruction[9:4];
            end
            4'b1010: begin // STORE
                immediate = 8'd0;
                address = instruction[9:4];
            end
            4'b1011: begin // MOV
                immediate = 8'd0;
                address = 6'd0;
            end
            4'b1100: begin // OUT
                immediate = 8'd0;
                address = 6'd0;
            end
            4'b1101: begin // JMP
                immediate = 8'd0;
                address = instruction[11:6];
            end
            4'b1110: begin // JZ
                immediate = 8'd0;
                address = instruction[11:6];
            end
            4'b1111: begin // HALT
                immediate = 8'd0;
                address = 6'd0;
            end
            default: begin
                immediate = 8'd0;
                address = 6'd0;
            end
        endcase
    end
endmodule