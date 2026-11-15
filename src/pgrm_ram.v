module pgrm_ram (
    input wire clk,
    input wire [6:0] address,
    input wire [15:0] data_in,
    input wire write_enable,
    input wire [1:0] byte_write_enable,
    output wire [15:0] data_out
);

wire [7:0] low_byte;
wire [7:0] high_byte;
wire low_write_enable = write_enable && byte_write_enable[0];
wire high_write_enable = write_enable && byte_write_enable[1];
wire [7:0] low_write_mask = {8{~low_write_enable}};
wire [7:0] high_write_mask = {8{~high_write_enable}};
`ifdef __pnr__
wire VDD;
wire VSS;
`else
supply1 VDD;
supply0 VSS;
`endif

// Yeah this was the macro part, this was done using AI sadly
// I am heavily dissapointed in myself for not doing this myself
// I got stuck for hours so I had too
// I do understand how it works now for the most part
// Macro's are hard, but its way better than my sloppy RTL async read sync write ram for on the ASIC

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

gf180mcu_fd_ip_sram__sram128x8m8wm1 low_byte_ram (
    .CLK(clk),
    .CEN(macro_cen),
    .GWEN(~low_write_enable),
    .WEN(low_write_mask),
    .A(address),
    .D(data_in[7:0]),
    .Q(low_byte),
    .VDD(VDD),
    .VSS(VSS)
);

gf180mcu_fd_ip_sram__sram128x8m8wm1 high_byte_ram (
    .CLK(clk),
    .CEN(macro_cen),
    .GWEN(~high_write_enable),
    .WEN(high_write_mask),
    .A(address),
    .D(data_in[15:8]),
    .Q(high_byte),
    .VDD(VDD),
    .VSS(VSS)
);

assign data_out = {high_byte, low_byte};

endmodule
