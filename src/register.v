module register (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire [7:0] a,
    output reg [7:0] b
);

always @(posedge clk) begin
    if (!rst_n) begin
        b <= 8'b0;
    end else if (enable) begin
        b <= a;
    end
end

endmodule