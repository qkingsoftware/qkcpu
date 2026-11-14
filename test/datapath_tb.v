`timescale 1ns/1ps

module datapath_tb;
    reg  [0:0] clk;
    reg  [0:0] rst_n;
    reg  [0:0] enable;
    reg  [7:0] a;
    reg  [7:0] b;
    reg  [3:0] opcode;
    wire  [7:0] stored_result;
    wire  [7:0] alu_result;

datapath dut (
    .clk(clk),
    .rst_n(rst_n),
    .enable(enable),
    .a(a),
    .b(b),
    .opcode(opcode),
    .stored_result(stored_result),
    .alu_result(alu_result)
);

clock_gen clock (
    .clk(clk)
);

initial begin
    // test 1
    rst_n = 0;
    enable = 0;
    a = 8'd0;
    b = 8'd0;
    opcode = 4'b0000;
    @(posedge clk);
    #1;
    if (stored_result == 8'd0) begin
        $display("DATAPATH FIRST RESET TEST PASSED!");
    end else begin
        $display("DATAPATH FIRST RESET TEST FAILED!");
    end
    $display("Internal register output: %b", dut.register.b);
    $display("Datapath clock: %b", dut.clk);
    
    // test 2
    rst_n = 1;
    a = 8'd5;
    b = 8'd3;
    opcode = 4'b0000;
    #1;
    if (alu_result == 8'd8) begin
        $display("DATAPATH ALU TEST PASSED!");
    end else begin
        $display("DATAPATH ALU TEST FAILED!");
    end
    enable = 1;
    @(posedge clk);
    #1;
    if (stored_result == 8'd8) begin
        $display("DATAPATH SECOND TEST PASSED!");
    end else begin
        $display("DATAPATH SECOND TEST FAILED!");
    end
    $display("Internal register output: %b", dut.register.b);
    $display("Datapath clock: %b", dut.clk);

    // test 3
    rst_n = 1;
    enable = 0;
    a = 8'd10;
    b = 8'd20;
    opcode = 4'b0000;
    #1;
    if (alu_result == 8'd30) begin
        $display("DATAPATH ALU TEST PASSED!");
    end else begin
        $display("DATAPATH ALU TEST FAILED!");
    end
    @(posedge clk);
    #1;
    if (stored_result == 8'd8) begin
        $display("DATAPATH THIRD TEST PASSED!");
    end else begin
        $display("DATAPATH THIRD TEST FAILED!");
    end

    $finish;
end

endmodule