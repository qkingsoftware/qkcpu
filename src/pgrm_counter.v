// Program counter!
// It counts till 64 at max, maybe I need to upgrade it later....
// It already uses 3x4 tiles and that is a lot, I am not expanding anymore
// Hey QKing here, 6 bits might be a bit low for this....
// Shall I increase it?

`default_nettype none

module pgrm_counter (
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire jump,
    input wire call,
    input wire ret,
    input wire [5:0] jump_address,
    output reg [5:0] count
);

    reg [5:0] return_addr;

    always @(posedge clk) begin
        if (!rst_n) begin
            count       <= 6'd0;
            return_addr <= 6'd0;
        end else if (ret) begin
            count <= return_addr;
        end else if (jump) begin
            if (call)
                return_addr <= count + 6'd1;
            count <= jump_address;
        end else if (enable) begin
            count <= count + 6'd1;
        end
    end

endmodule

`default_nettype wire
