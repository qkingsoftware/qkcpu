`timescale 1ns/1ps

module pwm_tb;

// declarations
reg clk = 0;
reg rst_n = 0;
reg bus_we = 0;
reg [6:0] bus_addr = 0;
reg [7:0] bus_wdata = 0;
wire [7:0] bus_rdata;
wire       mmio_hit;
reg [7:0] uio_in = 0;
wire [7:0] uio_out;
wire [7:0] uio_oe;
    
// dut init
gpio_pwm dut (
    .clk(clk),
    .rst_n(rst_n),
    .bus_we(bus_we),
    .bus_addr(bus_addr),
    .bus_wdata(bus_wdata),
    .bus_rdata(bus_rdata),
    .mmio_hit(mmio_hit),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe)
);

// Init the fake clock
always #10 clk = ~clk;
// Error/check counter
integer errors = 0;
integer checks = 0;

task check(input cond, input [8*40-1:0] name);
    begin
        checks = checks +1;
        if (cond)
            $display("Succes: %0s", name);
        else begin
            $display("Fuck it doesnt work: %0s", name);
            errors = errors + 1;
        end
    end
endtask

// Seduce the MMIO register (only write for one clock cycle to the mmio register)
task mmio_write(input [6:0] addr, input [7:0] data);
    begin
        @(negedge clk);
        bus_we = 1;
        bus_addr = addr;
        bus_wdata = data;
        @(negedge clk);
        bus_we = 0;
        bus_addr = 7'h00;
        bus_wdata = 8'h00;
    end
endtask

// Read mmio
task mmio_read(input [6:0] addr, output [7:0] data);
    begin
        @(negedge clk);
        bus_we = 0;
        bus_addr = addr;
        @(posedge clk);
        #1;
        data = bus_rdata;
        @(negedge clk);
        bus_addr = 7'h00;
    end
endtask

// Definitions for the actual test
reg [7:0] rd;
integer high_cycles;
integer cyc;
integer wrap_len;

// the test :tada: (please somehow have emoji markdown)
initial begin
    $dumpfile("pwm_tb.fst");
    $dumpvars(0, pwm_tb);

    // reset the cpu
    rst_n = 0;
    repeat (4) @(posedge clk);
    rst_n = 1;
    @(negedge clk);

    // wipe values out of existence
    mmio_read(7'h79, rd);
    check(rd == 8'hFF, "Period 0xFF after reset");
    check(uio_oe == 8'h00, "all uio pins are inputs after reset");

    // Set period register
    mmio_write(7'h79, 8'h7F);
    mmio_read(7'h79, rd);
    check(rd == 8'h7F, "period readback 0x7F");

    // Let counter reach 0 and time the next wrap
    while (dut.pwm_cnt != 8'd0) @(posedge clk);
    cyc = 0;
    @(posedge clk);
    while (dut.pwm_cnt != 8'd0) begin
        @(posedge clk);
        cyc = cyc + 1;
    end
    wrap_len = cyc + 1;
    check(wrap_len == 128, "period 0x7F gives 128-cycle wrap");

    // set pin 0 to out (GPIO)
    mmio_write(7'h60, 8'h01);
    @(negedge clk);
    check(uio_oe[0] == 1'b1, "pin 0 output on");
    check(uio_out[0] == 1'b0, "pin 0 drives 0");

    mmio_write(7'h60, 8'h03);
    @(negedge clk);
    check(uio_out[0] == 1'b1, "pin 0 drives 1 when written 0x03");

    // PWM on pin 1 (gpio)
    mmio_write(7'h79, 8'h7F);
    mmio_write(7'h71, 8'h40);
    mmio_write(7'h61, 8'h02);
    @(negedge clk);
    check(uio_oe[1] == 1'b1, "pin 1 is doing fucking PWM out now");

    // Count the ups 
    high_cycles = 0;
    for (cyc = 0; cyc < 128; cyc = cyc + 1) begin
        @(posedge clk);
        #1;
        if (uio_out[1]) high_cycles = high_cycles + 1;
    end
    check(high_cycles == 64, "PWM duty 64/128 gives 64 high cycles");

    // Full duty!
    mmio_write(7'h71, 8'hFF);
    high_cycles = 0;
    for (cyc = 0; cyc < 128; cyc = cyc + 1) begin
        @(posedge clk);
        #1;
        if (uio_out[1]) high_cycles = high_cycles + 1;
    end
    check(high_cycles == 128, "duty 0xFF is always high");

    // check if 11 is out as well (why not?)
    mmio_write(7'h62, 8'h04);
    @(negedge clk);
    check(uio_oe[2] == 1'b1, "mode 11 (0x04) drives uio_oe");

    // Set pin to input since we never tested it
    mmio_write(7'h62, 8'h00);
    @(negedge clk);
    check(uio_oe[2] == 1'b0, "input mode (0x00) releases the pin");

    // READ
    uio_in = 8'b1010_0101;
    mmio_read(7'h78, rd);
    check(rd == 8'b1010_0101, "0x78 reads all uio_in bits");
    mmio_read(7'h65, rd);
    check(rd == 8'h01, "0x65 reads uio_in[5]");

    $display("%0d yessss, %0d fucks", checks, errors);
    if (errors == 0)
        $display("ALL TESTS PASSED");
    else
        $display("FUCK, SOME TESTS FAILED");

    $finish;
end

// Timeout in case something goes wrong
initial begin
    #1000000;
    $display("TIMEOUT");
    $finish;
end

endmodule
