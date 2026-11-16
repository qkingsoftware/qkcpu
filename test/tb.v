`default_nettype none
`timescale 1ns / 1ps

module tb;
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  QKCPU user_project (
`ifdef GL_TEST
    .VPWR(VPWR),
    .VGND(VGND),
`endif
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(ena),
    .clk(clk),
    .rst_n(rst_n)
  );

  // Standalone instances exercise the four official GF180 SRAM models.
  // These are testbench-only and are not included in the ASIC source list.
  wire model_vdd = 1'b1;
  wire model_vss = 1'b0;

  reg sram64_test_cen;
  reg sram64_test_gwen;
  reg [7:0] sram64_test_wen;
  reg [5:0] sram64_test_a;
  reg [7:0] sram64_test_d;
  wire [7:0] sram64_test_q;
  gf180mcu_fd_ip_sram__sram64x8m8wm1 sram64_test (
    .CLK(clk), .CEN(sram64_test_cen), .GWEN(sram64_test_gwen),
    .WEN(sram64_test_wen), .A(sram64_test_a), .D(sram64_test_d),
    .Q(sram64_test_q), .VDD(model_vdd), .VSS(model_vss)
  );

  reg sram128_test_cen;
  reg sram128_test_gwen;
  reg [7:0] sram128_test_wen;
  reg [6:0] sram128_test_a;
  reg [7:0] sram128_test_d;
  wire [7:0] sram128_test_q;
  gf180mcu_fd_ip_sram__sram128x8m8wm1 sram128_test (
    .CLK(clk), .CEN(sram128_test_cen), .GWEN(sram128_test_gwen),
    .WEN(sram128_test_wen), .A(sram128_test_a), .D(sram128_test_d),
    .Q(sram128_test_q), .VDD(model_vdd), .VSS(model_vss)
  );

  reg sram256_test_cen;
  reg sram256_test_gwen;
  reg [7:0] sram256_test_wen;
  reg [7:0] sram256_test_a;
  reg [7:0] sram256_test_d;
  wire [7:0] sram256_test_q;
  gf180mcu_fd_ip_sram__sram256x8m8wm1 sram256_test (
    .CLK(clk), .CEN(sram256_test_cen), .GWEN(sram256_test_gwen),
    .WEN(sram256_test_wen), .A(sram256_test_a), .D(sram256_test_d),
    .Q(sram256_test_q), .VDD(model_vdd), .VSS(model_vss)
  );

  reg sram512_test_cen;
  reg sram512_test_gwen;
  reg [7:0] sram512_test_wen;
  reg [8:0] sram512_test_a;
  reg [7:0] sram512_test_d;
  wire [7:0] sram512_test_q;
  gf180mcu_fd_ip_sram__sram512x8m8wm1 sram512_test (
    .CLK(clk), .CEN(sram512_test_cen), .GWEN(sram512_test_gwen),
    .WEN(sram512_test_wen), .A(sram512_test_a), .D(sram512_test_d),
    .Q(sram512_test_q), .VDD(model_vdd), .VSS(model_vss)
  );

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end
endmodule

`default_nettype wire
