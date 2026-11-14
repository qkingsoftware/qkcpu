module data_ram_tb;

    reg clk;
    reg [5:0] address;
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
        address = 6'd10;
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
        address = 6'd20;
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
        address = 6'd10;
        @(posedge clk);
        #1;
        if (data_out == 8'd55) begin
            $display("INDEPENDENT MEMORY LOCATIONS TEST PASSED!");
        end else begin
            $display("INDEPENDENT MEMORY LOCATIONS TEST FAILED!");
        end

        // Test 3: Write protection
        address = 6'd20;
        data_in = 8'd123;
        write_enable = 0;
        @(posedge clk);

        #1;
        if (data_out == 8'd99) begin
            $display("WRITE PROTECTION TEST PASSED!");
        end else begin
            $display("WRITE PROTECTION TEST FAILED!");
        end

        $finish;
    end
endmodule

