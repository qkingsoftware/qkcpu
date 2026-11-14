module pgrm_counter(
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire [0:0] jump,
    input wire [5:0] jump_address,
    output reg [5:0] count
);

    always @(posedge clk)
        if (!rst_n) begin
            count <= 6'd0;
        end else if (jump) begin
            count <= jump_address;
        end else if (enable) begin
            count <= count + 6'd1;
        end
endmodule