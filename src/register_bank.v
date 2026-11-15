`default_nettype none

module register_bank (
    input wire clk,
    input wire rst_n,
    input wire write_enable,
    input wire [1:0] write_select,
    input wire [7:0] write_data,
    input wire [1:0] read_select_a,
    input wire [1:0] read_select_b,
    output wire [7:0] read_data_a,
    output wire [7:0] read_data_b,
    output wire [31:0] register_values
);

    reg [7:0] regA;
    reg [7:0] regB;
    reg [7:0] regR;
    reg [7:0] regTMP;

    assign register_values = {regTMP, regR, regB, regA};

    assign read_data_a = (read_select_a == 2'b00) ? regA :
                         (read_select_a == 2'b01) ? regB :
                         (read_select_a == 2'b10) ? regR : regTMP;

    assign read_data_b = (read_select_b == 2'b00) ? regA :
                         (read_select_b == 2'b01) ? regB :
                         (read_select_b == 2'b10) ? regR : regTMP;

    always @(posedge clk) begin
        if (!rst_n) begin
            regA   <= 8'b0;
            regB   <= 8'b0;
            regR   <= 8'b0;
            regTMP <= 8'b0;
        end else if (write_enable) begin
            case (write_select)
                2'b00: regA   <= write_data;
                2'b01: regB   <= write_data;
                2'b10: regR   <= write_data;
                2'b11: regTMP <= write_data;
            endcase
        end
    end

endmodule

`default_nettype wire
