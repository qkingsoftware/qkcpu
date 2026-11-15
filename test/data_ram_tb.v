module data_ram_tb;

    reg clk;
    reg [6:0] address;
    reg [7:0] data_in;
    reg write_enable;
    wire [7:0] data_out;

    dataram dut (
        .clk(clk),
        .address(address),
        .data_in(data_in),
        .write_enable(write_enable),
        .data_out(data_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Test 1: Write and read back
        address = 7'd10;
        data_in = 8'd55;
        write_enable = 1;
        @(posedge clk);
        #1;
        write_enable = 0;
        @(posedge clk);
        #1;
        if (data_out == 8'd55) begin
            $display("WRITE AND READ TEST PASSED!");
        end else begin
            $display("WRITE AND READ TEST FAILED!");
        end

        // Test 2: Independent memory locations
        address = 7'd20;
        data_in = 8'd99;
        write_enable = 1;
        @(posedge clk);
        #1;
        write_enable = 0;
        @(posedge clk);
        #1;
        if (data_out == 8'd99) begin
            $display("INDEPENDENT MEMORY LOCATIONS TEST PASSED!");
        end else begin
            $display("INDEPENDENT MEMORY LOCATIONS TEST FAILED!");
        end
        address = 7'd10;
        @(posedge clk);
        #1;
        if (data_out == 8'd55) begin
            $display("INDEPENDENT MEMORY LOCATIONS TEST PASSED!");
        end else begin
            $display("INDEPENDENT MEMORY LOCATIONS TEST FAILED!");
        end

        // Test 3: Write protection
        address = 7'd20;
        data_in = 8'd123;
        write_enable = 0;
        @(posedge clk);

        #1;
        if (data_out == 8'd99) begin
            $display("WRITE PROTECTION TEST PASSED!");
        end else begin
            $display("WRITE PROTECTION TEST FAILED!");
        end

        // Test 4: Synchronous read
        address = 7'd10;

        // Change the address between clock edges.
        // data_out should still contain the previous value (99).
        #1;
        if (data_out == 8'd99) begin
            $display("SYNCHRONOUS READ HOLD TEST PASSED!");
        end else begin
            $display("SYNCHRONOUS READ HOLD TEST FAILED!");
        end

        // After the next rising edge, data_out should become 55.
        @(posedge clk);
        #1;
        if (data_out == 8'd55) begin
            $display("SYNCHRONOUS READ UPDATE TEST PASSED!");
        end else begin
            $display("SYNCHRONOUS READ UPDATE TEST FAILED!");
        end

        // Test 5: Highest address in the 128-word macro
        address = 7'd127;
        data_in = 8'hC3;
        write_enable = 1;
        @(posedge clk);
        #1;
        write_enable = 0;
        @(posedge clk);
        #1;
        if (data_out == 8'hC3) begin
            $display("128 WORD ADDRESS TEST PASSED!");
        end else begin
            $display("128 WORD ADDRESS TEST FAILED!");
        end

        $finish;
    end
endmodule

