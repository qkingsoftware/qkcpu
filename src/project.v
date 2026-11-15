/*
 * Copyright (c) 2026 opilitethesmartdev
 * SPDX-License-Identifier: Apache-2.0
 *
 * Tiny Tapeout GF180MCU SRAM example.
 *
 * ui_in[5:0]  SRAM address
 * ui_in[6]    Write enable (active high)
 * uio_in      Write data
 * uo_out      Read data
 *
 * The SRAM itself has no reset. rst_n is used only to hold CEN inactive
 * until the system has completed reset.
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire [7:0] sram_q;

    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;
    assign uo_out  = sram_q;

`ifdef SYNTH
    // Tiny Tapeout's FPGA workflow defines SYNTH. Use an inferred memory
    // on FPGA; the GF180 hard macro is only available in the ASIC flow.
    reg [7:0] fpga_mem [0:63];
    reg [7:0] fpga_q;

    always @(posedge clk) begin
        if (!rst_n) begin
            fpga_q <= 8'h00;
        end else if (ena) begin
            if (ui_in[6]) begin
                fpga_mem[ui_in[5:0]] <= uio_in;
            end else begin
                fpga_q <= fpga_mem[ui_in[5:0]];
            end
        end
    end

    assign sram_q = fpga_q;

`elsif __pnr__
    // LibreLane defines __pnr__ and supplies the black-box header through
    // the MACROS configuration. VPWR/VGND are internal PDN nets, not user pins.
    wire VPWR;
    wire VGND;

    gf180mcu_fd_ip_sram__sram64x8m8wm1 u_sram (
        .VDD  (VPWR),
        .VSS  (VGND),
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~ui_in[6]),
        .WEN  (8'h00),
        .A    (ui_in[5:0]),
        .D    (uio_in),
        .Q    (sram_q)
    );

`else
    // RTL simulation uses the official Google/GlobalFoundries timing model.
    // Its power pins are tied off here; the functional model does not model
    // power sequencing. The ASIC flow uses the physical macro branch above.
    wire model_vdd = 1'b1;
    wire model_vss = 1'b0;

    gf180mcu_fd_ip_sram__sram64x8m8wm1 u_sram (
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~ui_in[6]),
        .WEN  (8'h00),
        .A    (ui_in[5:0]),
        .D    (uio_in),
        .Q    (sram_q),
        .VDD  (model_vdd),
        .VSS  (model_vss)
    );
`endif

    // ui_in[7] is reserved. All bidirectional pins are inputs in this example.

endmodule

`default_nettype wire
