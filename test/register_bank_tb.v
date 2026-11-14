`timescale 1ns/1ps
module register_tb;

reg  [0:0] clk;
reg  [0:0] rst_n;
reg  [0:0] write_enable;
reg  [1:0] write_select;
reg  [7:0] write_data;
reg [1:0] read_select_a;
reg [1:0] read_select_b;
wire [7:0] read_data_a;
wire [7:0] read_data_b;


register_bank dut (
    .clk(clk),
    .rst_n(rst_n),
    .write_enable(write_enable),
    .write_select(write_select),
    .write_data(write_data),
    .read_select_a(read_select_a),
    .read_select_b(read_select_b),
    .read_data_a(read_data_a),
    .read_data_b(read_data_b)
);

clock_gen clock (
    .clk(clk)
);

always @(clk) begin
    $display("Clock changed: %b", clk);
end

initial begin
    // test 1
    rst_n = 0;
    write_enable = 0;
    write_select = 2'b00;
    write_data = 8'd0;
    read_select_a = 2'b00;
    read_select_b = 2'b00;
    $display("Waiting for rising edge...");
    @(posedge clk);
    $display("Rising edge detected!");    #1;
    if (read_data_a == 8'd0) begin
        $display("FIRST RESET TEST PASSED!");
    end else begin
        $display("FIRST RESET TEST FAILED!");
    end
    $display("TEST 1 - Register output: %d", read_data_a);

    // 2nd test
    rst_n = 1;
    write_enable = 1;
    write_select = 2'b00;
    write_data = 8'd42;
    read_select_a = 2'b00;
    read_select_b = 2'b00;
    $display("Waiting for rising edge...");
    @(posedge clk);
    $display("Rising edge detected!");    #1;
    if (read_data_a == 8'd0) begin
        $display("SYNCHRONOUS WRITE/READ DELAY TEST PASSED!");
    end else begin
        $display("SYNCHRONOUS WRITE/READ DELAY TEST FAILED!");
    end 
    $display("TEST 2 - Register output: %d", read_data_a);
    @(posedge clk);
    #1;
    if (read_data_a == 8'd42) begin
        $display("REGISTER A READ TEST PASSED!");
    end else begin
        $display("REGISTER A READ TEST FAILED!");
    end

    // test 3
    rst_n = 1;
    write_enable = 1;
    write_select = 2'b01;
    write_data = 8'd99;
    read_select_a = 2'b01;
    read_select_b = 2'b01;
    $display("Waiting for rising edge...");
    @(posedge clk);
    $display("Rising edge detected!");    #1;
    if (read_data_a == 8'd42) begin
        $display("SYNCHRONOUS WRITE/READ DELAY TEST PASSED!");
    end else begin
        $display("SYNCHRONOUS WRITE/READ DELAY TEST FAILED!");
    end
    $display("TEST 3 - Register output: %d", read_data_a);
    @(posedge clk);
    #1;
    if (read_data_a == 8'd99) begin
        $display("REGISTER B READ TEST PASSED!");
    end else begin
        $display("REGISTER B READ TEST FAILED!");
    end

    // test 4: outputs retain their last sampled values between clock edges
    write_enable = 0;
    read_select_a = 2'b00;
    read_select_b = 2'b01;
    #1;
    if (read_data_a == 8'd99) begin
        $display("FOURTH SYNCHRONOUS READ HOLD TEST PASSED!");
    end else begin
        $display("FOURTH SYNCHRONOUS READ HOLD TEST FAILED!");
    end
    if (read_data_b == 8'd99) begin
        $display("FOURTH SYNCHRONOUS READ HOLD TEST PASSED!");
    end else begin
        $display("FOURTH SYNCHRONOUS READ HOLD TEST FAILED!");
    end

    read_select_a = 2'b01;
    read_select_b = 2'b00;
    #1;
    if (read_data_a == 8'd99 && read_data_b == 8'd99) begin
        $display("FIFTH SYNCHRONOUS READ HOLD TEST PASSED!");
    end else begin
        $display("FIFTH SYNCHRONOUS READ HOLD TEST FAILED!");
    end

    @(posedge clk);
    #1;
    if (read_data_a == 8'd99 && read_data_b == 8'd42) begin
        $display("SYNCHRONOUS READ UPDATE TEST PASSED!");
    end else begin
        $display("SYNCHRONOUS READ UPDATE TEST FAILED!");
    end

    $finish;
end

endmodule