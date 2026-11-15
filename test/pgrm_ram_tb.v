module pgrm_ram_tb;

    reg clk;
    reg [6:0] address;
    reg [15:0] data_in;
    reg write_enable;
    reg [1:0] byte_write_enable;
    wire [15:0] data_out;

    pgrm_ram dut (
        .clk(clk),
        .address(address),
        .data_in(data_in),
        .write_enable(write_enable),
        .byte_write_enable(byte_write_enable),
        .data_out(data_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Test 1: Write and read back
        address = 7'd10;
        data_in = 16'd55;
        write_enable = 1;
        byte_write_enable = 2'b11;
        @(posedge clk);
        #1;
        write_enable = 0;
        @(posedge clk);
        #1;
        if (data_out == 16'd55) begin
            $display("WRITE AND READ TEST PASSED!");
        end else begin
            $display("WRITE AND READ TEST FAILED!");
        end

        // Test 2: Independent memory locations
        address = 7'd20;
        data_in = 16'hA55A;
        write_enable = 1;
        byte_write_enable = 2'b11;
        @(posedge clk);
        #1;
        write_enable = 0;
        @(posedge clk);
        #1;
        if (data_out == 16'hA55A) begin
            $display("INDEPENDENT MEMORY LOCATIONS TEST PASSED!");
        end else begin
            $display("INDEPENDENT MEMORY LOCATIONS TEST FAILED!");
        end
        address = 7'd10;
        @(posedge clk);
        #1;
        if (data_out == 16'd55) begin
            $display("INDEPENDENT MEMORY LOCATIONS TEST PASSED!");
        end else begin
            $display("INDEPENDENT MEMORY LOCATIONS TEST FAILED!");
        end

        // Test 3: Write protection
        address = 7'd20;
        data_in = 16'd123;
        write_enable = 0;
        byte_write_enable = 2'b11;
        @(posedge clk);

        #1;
        if (data_out == 16'hA55A) begin
            $display("WRITE PROTECTION TEST PASSED!");
        end else begin
            $display("WRITE PROTECTION TEST FAILED!");
        end

        // Test 4: Synchronous read
        address = 7'd10;
        #1;
        if (data_out == 16'hA55A) begin
            $display("SYNCHRONOUS READ HOLD TEST PASSED!");
        end else begin
            $display("SYNCHRONOUS READ HOLD TEST FAILED!");
        end

        @(posedge clk);
        #1;
        if (data_out == 16'd55) begin
            $display("SYNCHRONOUS READ UPDATE TEST PASSED!");
        end else begin
            $display("SYNCHRONOUS READ UPDATE TEST FAILED!");
        end

        // Test 5: Highest address in both 128-word macro banks
        address = 7'd127;
        data_in = 16'h3CC3;
        write_enable = 1;
        byte_write_enable = 2'b11;
        @(posedge clk);
        #1;
        write_enable = 0;
        @(posedge clk);
        #1;
        if (data_out == 16'h3CC3) begin
            $display("128 WORD ADDRESS TEST PASSED!");
        end else begin
            $display("128 WORD ADDRESS TEST FAILED!");
        end

        $finish;
    end
endmodule

