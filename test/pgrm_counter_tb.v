module pgrm_counter_tb;

    reg clk;
    reg rst_n;
    reg enable;
    reg [0:0] jump;
    reg [5:0] jump_address;
    wire [5:0] count;

    pgrm_counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .jump(jump),
        .jump_address(jump_address),
        .count(count)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Test 1: Reset functionality
        rst_n = 0;
        enable = 0;
        jump = 0;
        jump_address = 6'd0;
        @(posedge clk);
        #1;
        if (count == 6'd0) begin
            $display("RESET TEST PASSED!");
        end else begin
            $display("RESET TEST FAILED!");
        end

        // Test 2: Enable counting
        rst_n = 1;
        enable = 1;
        @(posedge clk);
        #1;
        if (count == 6'd1) begin
            $display("ENABLE COUNTING TEST PASSED!");
        end else begin
            $display("ENABLE COUNTING TEST FAILED!");
        end

        // Test 3: Jump functionality
        enable = 0;
        jump = 1;
        jump_address = 6'd20;

        @(posedge clk);
        #1;

        if (count == 6'd20) begin
            $display("JUMP TEST PASSED!");
        end else begin
            $display("JUMP TEST FAILED!");
        end

        // Test 4: Jump prioty
        jump = 1;
        jump_address = 6'd30;
        enable = 1;

        @(posedge clk);
        #1;

        if (count == 6'd30) begin
            $display("JUMP PRIORITY TEST PASSED!");
        end else begin
            $display("JUMP PRIORITY TEST FAILED!");
        end

        // Test 5: Hold
        jump = 0;
        enable = 0;
        @(posedge clk);
        #1;
        if (count == 6'd30) begin
            $display("HOLD TEST PASSED!");
        end else begin
            $display("HOLD TEST FAILED!");
        end
        $finish;

    end
    endmodule