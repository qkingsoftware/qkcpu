`timescale 1ns/1ps

module datapath_tb;
    reg  [0:0] clk;
    reg  [0:0] rst_n;
    reg  [0:0] enable;
    reg [1:0] write_select;
    reg [1:0] read_select_a;
    reg [1:0] read_select_b;
    reg [7:0] write_data;
    reg writeback_select;
    reg  [3:0] opcode;
    wire  [7:0] alu_result;

datapath dut (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .write_select(write_select),
    .read_select_a(read_select_a),
    .read_select_b(read_select_b),
    .write_data(write_data),
    .writeback_select(writeback_select),
    .opcode(opcode),
    .alu_result(alu_result)
);

clock_gen clock (
    .clk(clk)
);

initial begin
    // test 1
    rst_n = 0;
    enable = 0;
    read_select_a = 2'd0;
    read_select_b = 2'd0;
    write_data = 8'd0;
    writeback_select = 1'b0;
    opcode = 4'b0000;
    @(posedge clk);
    #1;
    if (alu_result == 8'd0) begin
        $display("DATAPATH FIRST RESET TEST PASSED!");
    end else begin
        $display("DATAPATH FIRST RESET TEST FAILED!");
    end
    $display("Register A: %d", dut.register_bank.regA);
    $display("Register B: %d", dut.register_bank.regB);
    $display("Datapath clock: %b", dut.clk);
    
    // test 2
    rst_n = 1;
    enable = 1;
    write_select = 2'b00;
    write_data = 8'd42;
    writeback_select = 1'b0;

    @(posedge clk);
    #1;

    if (dut.register_bank.regA == 8'd42) begin
        $display("REGISTER A LOAD TEST PASSED!");
    end else begin
        $display("REGISTER A LOAD TEST FAILED!");
    end
        $display("Register A: %d", dut.register_bank.regA);
        $display("Register B: %d", dut.register_bank.regB);
        $display("Datapath clock: %b", dut.clk);

    // test 3
    rst_n = 1;
    enable = 1;
    write_select = 2'b01;
    write_data = 8'd10;
    writeback_select = 1'b0;

    @(posedge clk);
    #1;

    if (dut.register_bank.regB == 8'd10) begin
        $display("REGISTER B LOAD TEST PASSED!");
    end else begin
        $display("REGISTER B LOAD TEST FAILED!");
    end
        $display("Register A: %d", dut.register_bank.regA);
        $display("Register B: %d", dut.register_bank.regB);
        $display("Datapath clock: %b", dut.clk);

    // test 4
    rst_n = 1;
    enable = 1;
    write_select = 2'b10;
    writeback_select = 1'b1;
    read_select_a = 2'd0;
    read_select_b = 2'd1;
    opcode = 4'b0000;
    #1;
    if (alu_result == 8'd52) begin
        $display("DATAPATH ALU TEST PASSED!");
    end else begin
        $display("DATAPATH ALU TEST FAILED!");
    end
    @(posedge clk);
    #1;
    if (dut.register_bank.regR == 8'd52) begin
        $display("DATAPATH fourth TEST PASSED!");
    end else begin
        $display("DATAPATH fourth TEST FAILED!");
    end

    $finish;
end

endmodule