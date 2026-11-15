## How it works

This project demonstrates the official Google/GlobalFoundries GF180MCU single-port SRAM macro in a Tiny Tapeout Verilog design. The default design instantiates the 64-word by 8-bit macro. The physical GDS, LEF, Liberty timing views, datasheet and vendor simulation model are obtained from the pinned `gf180mcu_fd_ip_sram` submodule.

The SRAM uses a rising-edge clock. `CEN` is active low, `GWEN` is active low for writes, and each `WEN` bit is an active-low byte-bit write mask. The sample enables the macro while the design is enabled and out of reset, writes when `ui_in[6]` is high, and reads otherwise.

The FPGA workflow uses an inferred 64x8 memory because the GF180 hard macro cannot be placed in the iCE40 FPGA flow. The ASIC flow uses the physical SRAM macro.

## How to test

The Cocotb testbench checks the sample design through its Tiny Tapeout pins and independently tests the official 64x8, 128x8, 256x8 and 512x8 vendor simulation models. Icarus Verilog runs with specify timing checks enabled. The model tests use a 100 ns clock period to satisfy the timing checks included in the vendor Verilog model; the ASIC timing constraint remains 20 ns and is evaluated using the vendor Liberty files.

## External hardware

No external hardware is required.
