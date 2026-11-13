    module register_tb;

    reg  [0:0] clk;
    reg  [0:0] rst_n;
    reg  [0:0] enable;
    reg  [7:0] a;
    wire  [7:0] b;


    register dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .a(a),
        .b(b)
    );

    initial begin
        rst_n = 0;
        enable = 0;
        a = 8'd0;
        clk = 0;
        @(posedge clk);
        #1;
        if (b == 8'd0) begin
        $display("RESET TEST PASSED!");
        end else begin
        $display("RESET TEST FAILED!");
        end
        $display("Register output: %d", b);
        $finish;

    end
    always #5 clk = ~clk;



    endmodule