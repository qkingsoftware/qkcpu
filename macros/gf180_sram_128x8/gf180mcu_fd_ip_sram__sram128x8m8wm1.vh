module gf180mcu_fd_ip_sram__sram128x8m8wm1 (
    input wire CLK,
    input wire CEN,
    input wire GWEN,
    input wire [7:0] WEN,
    input wire [6:0] A,
    input wire [7:0] D,
    output wire [7:0] Q
`ifdef USE_POWER_PINS
    , inout wire VDD,
    inout wire VSS
`endif
);
endmodule
