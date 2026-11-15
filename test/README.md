# GF180 SRAM simulation tests

The Cocotb testbench drives the actual Tiny Tapeout top-level interface and
independently exercises the official 64x8, 128x8, 256x8 and 512x8 SRAM models.

The vendor models contain specify timing paths, but Icarus Verilog 12 cannot
elaborate their conditional bit-specific output path declarations: it reports
source/destination width mismatches. Consequently the Icarus test intentionally
runs the models' functional behavior with specify path checking disabled. The
test clock is 100 ns (50 ns high and low), above the model's 55.6 ns minimum
cycle and 25 ns minimum pulse widths. Physical setup/hold and macro timing are
not waived: the ASIC flow reads the vendor Liberty files and runs STA. Do not
interpret this functional RTL test as timing signoff.

Run the RTL test:

```sh
make -B
```

For gate-level testing, first run the GF180 GDS workflow or copy the hardened
Tiny Tapeout netlist to `gate_level_netlist.v`, then run:

```sh
make -B GATES=yes
```

The ASIC source list contains only the project RTL. The official behavioral
SRAM models are simulation-only. The physical GDS, LEF and Liberty files are
provided by the pinned submodule and registered in `src/config.json`.
