module dataram (
    input wire clk,
    input wire [6:0] address,
    input wire [7:0] data_in,
    input wire write_enable,
    output wire [7:0] data_out
`ifdef USE_POWER_PINS
    , inout wire VPWR,
    inout wire VGND
`endif
);

wire [7:0] write_enable_mask = {8{~write_enable}};
`ifndef USE_POWER_PINS
supply1 VPWR;
supply0 VGND;
`endif

/*
 * The macro model requires CEN to transition from high to low once after
 * startup. The physical macro remains enabled after that transition.
 */
`ifdef SYNTHESIS
wire macro_cen = 1'b0;
`else
reg macro_cen;
initial begin
    macro_cen = 1'b1;
    #1 macro_cen = 1'b0;
end
`endif

gf180mcu_fd_ip_sram__sram128x8m8wm1 data_memory (
    .CLK(clk),
    .CEN(macro_cen),
    .GWEN(write_enable_mask[0]),
    .WEN(write_enable_mask),
    .A(address),
    .D(data_in),
    .Q(data_out),
    .VDD(VPWR),
    .VSS(VGND)
);

endmodule
