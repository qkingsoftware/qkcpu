module register_bank (
    input wire clk,
    input wire rst_n,
    input wire write_enable,
    input wire [1:0] write_select,
    input wire [7:0] write_data,
    input wire [1:0] read_select_a,
    input wire [1:0] read_select_b,
    output reg [7:0] read_data_a,
    output reg [7:0] read_data_b

);

reg [7:0] regA;
reg [7:0] regB;
reg [7:0] regR;
reg [7:0] regTMP;

always @(posedge clk) begin
    if (!rst_n) begin
        regA   <= 8'b0;
        regB   <= 8'b0;
        regR   <= 8'b0;
        regTMP <= 8'b0;
        read_data_a <= 8'b0;
        read_data_b <= 8'b0;
    end else begin
        if (write_enable) begin
            case (write_select)
                2'b00: regA   <= write_data;
                2'b01: regB   <= write_data;
                2'b10: regR   <= write_data;
                2'b11: regTMP <= write_data;
            endcase
        end

        case (read_select_a)
            2'b00: read_data_a <= regA;
            2'b01: read_data_a <= regB;
            2'b10: read_data_a <= regR;
            2'b11: read_data_a <= regTMP;
            default: read_data_a <= 8'b0;
        endcase

        case (read_select_b)
            2'b00: read_data_b <= regA;
            2'b01: read_data_b <= regB;
            2'b10: read_data_b <= regR;
            2'b11: read_data_b <= regTMP;
            default: read_data_b <= 8'b0;
        endcase
    end
end

endmodule