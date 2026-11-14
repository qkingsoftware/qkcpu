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
        // test 1
        rst_n = 0;
        enable = 0;
        a = 8'd0;
        clk = 0;
        @(posedge clk);
        #1;
        if (b == 8'd0) begin
        $display("FIRST RESET TEST PASSED!");
        end else begin
        $display("FIRST RESET TEST FAILED!");
        end
        $display("TEST 1 - Register output: %d", b);

        // 2nd test
        rst_n = 1;
        enable = 1;
        a = 8'd42;
        @(posedge clk);
        #1;
        if (b == 8'd42) begin
        $display("2ND RESET TEST PASSED!");
        end else begin
        $display("2ND RESET TEST FAILED!");
        end
        $display("TEST 2 - Register output: %d", b);

        // 3nd test
        rst_n = 1;
        enable = 0;
        a = 8'd99;
        @(posedge clk);
        #1;
        if (b == 8'd42) begin
        $display("3ND RESET TEST PASSED!");
        end else begin
        $display("3ND RESET TEST FAILED!");
        end
        $display("TEST 3 - Register output: %d", b);
        $finish;

    end
    always #5 clk = ~clk;



    endmodule