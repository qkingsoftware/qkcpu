module pgrm_ram (
    input wire clk,
    input wire [5:0] address,
    input wire [15:0] data_in,
    input wire write_enable,
    output reg [15:0] data_out
);

reg [15:0] memory [0:63];
    always @(posedge clk) begin
        data_out <= memory[address];

        if (write_enable) begin
            memory[address] <= data_in;
        end
    end
    endmodule
