# Tiny Tapeout GF180MCU SRAM Template

[![GDS](https://github.com/opilitethesmartdev/ttgf-verilog-sram/actions/workflows/gds.yaml/badge.svg)](https://github.com/opilitethesmartdev/ttgf-verilog-sram/actions/workflows/gds.yaml)
[![RTL tests](https://github.com/opilitethesmartdev/ttgf-verilog-sram/actions/workflows/test.yaml/badge.svg)](https://github.com/opilitethesmartdev/ttgf-verilog-sram/actions/workflows/test.yaml)
[![Docs](https://github.com/opilitethesmartdev/ttgf-verilog-sram/actions/workflows/docs.yaml/badge.svg)](https://github.com/opilitethesmartdev/ttgf-verilog-sram/actions/workflows/docs.yaml)
[![FPGA](https://github.com/opilitethesmartdev/ttgf-verilog-sram/actions/workflows/fpga.yaml/badge.svg)](https://github.com/opilitethesmartdev/ttgf-verilog-sram/actions/workflows/fpga.yaml)

A Tiny Tapeout GF180MCU **Verilog** template demonstrating integration of the
official Google/GlobalFoundries SRAM macros. The default design instantiates a
physical 64×8 SRAM.

## Features

- Pinned [GF180MCU SRAM IP](https://github.com/google/globalfoundries-pdk-ip-gf180mcu_fd_ip_sram)
  submodule with official GDS, LEF, Liberty and Verilog views.
- 64×8, 128×8, 256×8 and 512×8 single-port SRAM variants.
- Separate ASIC black-box declarations and vendor simulation models.
- Cocotb tests using the official models.
- Inferred 64×8 memory for the iCE40 FPGA flow; the foundry macro is used in
  the ASIC flow.
- Tiny Tapeout GDS submission, precheck, gate-level test, KLayout 2D render
  and interactive 3D viewer workflow.

## Getting started

Clone with the SRAM submodule:

```sh
git clone --recurse-submodules https://github.com/opilitethesmartdev/ttgf-verilog-sram.git
cd ttgf-verilog-sram
```

For an existing checkout:

```sh
git submodule update --init --recursive
```

The example RTL is in `src/project.v`. Project metadata and pin labels are in
`info.yaml`; physical macro views and timing corners are registered in
`src/config.json`.

## Default interface

| Tiny Tapeout signal | Function |
|---|---|
| `ui_in[5:0]` | SRAM address |
| `ui_in[6]` | Write enable, active high |
| `uio_in[7:0]` | Write data |
| `uo_out[7:0]` | Read data |
| `ui_in[7]` | Unused |

The design uses the macro's full-byte write mask (`WEN=8'h00`). The macro has
no reset pin: reset disables access but does not clear memory. SRAM contents
after power-up are undefined in hardware.

## Available SRAMs

All variants are 8 bits wide. The dimensions below are from their official
LEF views.

| Macro | Capacity | Size (µm) | Minimum tile |
|---|---:|---:|---:|
| 64×8 | 512 bits | 431.86 × 232.88 | 2×2 |
| 128×8 | 1 Kibit | 431.86 × 268.88 | 2×2 |
| 256×8 | 2 Kibit | 431.86 × 340.88 | 3×4 |
| 512×8 | 4 Kibit | 431.86 × 484.88 | 3×4 |

Only the 64×8 macro is instantiated and registered in `src/config.json` by
default. Keep unused macros out of the active `MACROS` object. When selecting
another size, update the RTL module and address width, macro configuration and
placement, and `info.yaml` tile count together.

## Workflows and visualisation

GitHub Actions runs RTL simulation, GF180 hardening, Tiny Tapeout precheck,
gate-level simulation, documentation generation and the iCE40 FPGA build.

The GDS job generates:
- A KLayout **2D PNG preview** (`gds_render` artifact).
- The final GDS and OASIS submission (`tt_submission` artifact).
- Hardening logs and reports (`GDS_logs` artifact).

The viewer job uses the same `TinyTapeout/tt-gds-action/viewer` action as
[OPI-SiliconPUdx](https://github.com/opilitethesmartdev/opi-siliconpudx). It
publishes the OASIS file to GitHub Pages and adds links to the interactive
[3D viewer](https://gds-viewer.tinytapeout.com/) and
[Tiny Tapeout Explorer](https://gds-explorer.tinytapeout.com/), with the 2D
PNG embedded in the workflow summary.

**One-time setup:** open the repository
[Pages settings](https://github.com/opilitethesmartdev/ttgf-verilog-sram/settings/pages)
and set **Build and deployment → Source** to **GitHub Actions**. The viewer
job skips deployment until this is configured. After enabling it, run the
`gds` workflow again to publish the existing design.

## Physical-flow notes

The active ASIC macro has a GDS, LEF, black-box Verilog declaration and three
3.3 V Liberty corners (typical, slow and fast). Place-and-route uses the LEF;
synthesis uses the black-box declaration; STA uses the Liberty files; final
KLayout streamout includes the normalized official macro GDS.

Before hardening, `.github/scripts/normalize_sram_gds.py` gives internal GDS
cells unique names for Magic compatibility and removes the unsupported GF180
layer 58/0. The SRAM root cell and geometry on supported layers are retained.
The official LEF, Liberty, Verilog and behavioral simulation models are not
modified.

### Verification limitations

A successful workflow is not the same as DRC signoff. In the current
configuration, Magic DRC and illegal-overlap findings are non-fatal, and
KLayout DRC is disabled. The latest inspected GDS run reported 1,246 Magic
DRC findings; LVS and antenna checks passed. Review the `GDS_logs` artifact
before relying on the layout. The current flow is a working integration
example, not a signoff-clean SRAM macro release.

The Icarus RTL tests exercise functional behavior with specify-path checking
disabled because Icarus cannot elaborate the vendor model's bit-specific
specify paths. See [test/README.md](test/README.md) and
[docs/sram.md](docs/sram.md) for timing and integration details.
