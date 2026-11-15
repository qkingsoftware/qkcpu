# GF180MCU SRAM integration

This template uses the official Google/GlobalFoundries GF180MCU SRAM IP from
`google/globalfoundries-pdk-ip-gf180mcu_fd_ip_sram`. It is pinned as a Git
submodule so the physical and simulation views remain a matched set.

## Included macros

All four official single-port, 8-bit-wide macro variants are present in the
pinned submodule and have black-box declarations plus simulation coverage.
Only the active 64×8 macro is registered in `src/config.json` by default.

| Cell | Capacity | LEF dimensions (µm) | Minimum tile |
|---|---:|---:|---:|
| `gf180mcu_fd_ip_sram__sram64x8m8wm1` | 64×8 | 431.86 × 232.88 | 2×2 |
| `gf180mcu_fd_ip_sram__sram128x8m8wm1` | 128×8 | 431.86 × 268.88 | 2×2 |
| `gf180mcu_fd_ip_sram__sram256x8m8wm1` | 256×8 | 431.86 × 340.88 | 3×4 |
| `gf180mcu_fd_ip_sram__sram512x8m8wm1` | 512×8 | 431.86 × 484.88 | 3×4 |

The current design instantiates only the 64×8 cell. It is placed at
(140, 45) µm in the 2×2 tile. Larger cells are available in the submodule but
are not registered in the active `MACROS` object until instantiated.

## Physical implementation

Place-and-route uses the official SRAM LEF. Synthesis uses a separate
black-box Verilog declaration, STA uses the vendor 3.3 V Liberty corners, and
the final KLayout GDS streamout includes the SRAM GDS registered in
`src/config.json`.

The GDS workflow creates a Magic abstract view from the official SRAM LEF and
loads it through `MAGIC_DRC_MAGLEFS`. Magic DRC and SPICE extraction use
routed DEF/LEF abstractions rather than the full transistor-level SRAM GDS
hierarchy. The full SRAM GDS remains part of the final streamout.

LibreLane's `KLayout.Render` step is enabled. It generates the 2D PNG preview
from the routed layout. The Tiny Tapeout viewer job publishes the final OASIS
file to GitHub Pages for the interactive 3D viewer and Tiny Tapeout Explorer.
Enable GitHub Pages with **GitHub Actions** as its source in the repository
settings before the first viewer deployment.

Before hardening, `.github/scripts/normalize_sram_gds.py` gives internal GDS
cells unique identifiers to avoid Magic name collisions and removes layer
58/0, which is not defined by the GF180MCU layer specification. The macro
root cell and geometry on supported GF180 layers are retained; the official
LEF, Liberty, Verilog and simulation model are not modified.

## DRC and signoff status

The current configuration sets `ERROR_ON_MAGIC_DRC=false` and
`ERROR_ON_ILLEGAL_OVERLAPS=false`, so findings from those Magic checks do not
fail the hardening job. `RUN_KLAYOUT_DRC=0` disables KLayout DRC. On the
latest inspected run, the manufacturability report showed 1,246 Magic DRC
findings and reported DRC as failed; LVS and antenna checks passed.

A green GDS workflow therefore confirms that the configured flow completed,
not that the layout is DRC-clean or ready for manufacture. Inspect the
`GDS_logs` artifact and perform appropriate signoff before using the layout.

Each active macro entry includes GDS, LEF, a Verilog black-box declaration
and three 3.3 V Liberty corners: typical 25°C, slow 125°C and fast -40°C.
The official Verilog functional/timing models are used only for simulation.

## Default example interface

| Signal | Function |
|---|---|
| `ui_in[5:0]` | 64-word SRAM address |
| `ui_in[6]` | Write enable, active high |
| `uio_in[7:0]` | Write data |
| `uo_out[7:0]` | Registered SRAM read data |
| `ena` | Enables SRAM access when high |
| `rst_n` | Holds SRAM chip enable inactive while reset is asserted |
| `clk` | Rising-edge SRAM clock |

The top-level ties `WEN=8'h00`, enabling all eight data bits. It drives
`GWEN=0` for writes and `GWEN=1` for reads. Both `CEN` and `GWEN` are
active low. `CEN` is kept high while reset is asserted or `ena` is low.

The macro has no reset input. Reset only disables the macro; it does not clear
the memory array. Do not rely on power-up SRAM contents in a manufactured
device. The vendor simulation model initializes its internal array for
simulation, but that initialization is not a silicon reset mechanism.

## Timing and simulation

The official GF180 model specifies a 55.6 ns minimum clock cycle, 25 ns
minimum high and low pulse widths, 5 ns input setup and 10 ns input hold.
Icarus Verilog cannot elaborate the model's conditional bit-specific output
path declarations, so the Cocotb functional tests do not enable specify path
checking. They use a 100 ns clock period, but this does not constitute timing
signoff and does not test setup/hold violations.

The physical implementation uses the vendor 3.3 V Liberty files and the
project's 20 ns clock constraint (50 MHz). LibreLane STA runs across the
configured process, voltage and temperature corners. Review the STA reports;
the functional RTL test is not a substitute for timing analysis.

## Adding a different SRAM size

To switch the default instance:

1. Replace the cell module in `src/project.v` with the required macro name and
   match its address width (6, 7, 8 or 9 bits).
2. Replace the active `MACROS` entry in `src/config.json` with the selected
   cell's GDS, LEF, black-box header and Liberty corners. Keep unused macro
   entries out of `MACROS`. Set `instances` to the actual RTL instance name
   and place it within the selected tile.
3. Update `info.yaml` `tiles` to a size that contains the LEF dimensions.
4. Update the RTL and Cocotb top-level tests for the changed address range.

The 256×8 and 512×8 macros are taller than a 2×2 tile, so use at least 3×4.
Do not treat these hard macros as inferred memories: keep the black-box
declaration for ASIC synthesis and use the official behavioral model only for
simulation.

## Source and licensing

The macro views are maintained by the Google GF180MCU SRAM IP repository and
carry their upstream GlobalFoundries PDK Authors copyright and Apache-2.0
license. This project pins the upstream submodule commit; it does not modify
or regenerate the vendor GDS, LEF, Liberty or functional Verilog views.
