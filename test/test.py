# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer


async def exercise_macro(dut, prefix, address):
    """Write, read, and test the active-low bit mask of one vendor SRAM model."""
    cen = getattr(dut, f"{prefix}_cen")
    gwen = getattr(dut, f"{prefix}_gwen")
    wen = getattr(dut, f"{prefix}_wen")
    addr = getattr(dut, f"{prefix}_a")
    data = getattr(dut, f"{prefix}_d")
    q = getattr(dut, f"{prefix}_q")

    # CEN must be high for a clock before the first active cycle.
    await FallingEdge(dut.clk)
    cen.value = 0
    gwen.value = 0
    wen.value = 0x00
    addr.value = address
    data.value = 0xA5

    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    # Read the location on the next rising edge.
    await FallingEdge(dut.clk)
    gwen.value = 1
    await RisingEdge(dut.clk)
    await Timer(50, unit="ns")
    assert int(q.value) == 0xA5, f"{prefix}: full-byte write/read failed"

    # WEN is an active-low bit mask. 0xFE writes only bit 0.
    await FallingEdge(dut.clk)
    gwen.value = 0
    wen.value = 0xFE
    data.value = 0x5A
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    await FallingEdge(dut.clk)
    gwen.value = 1
    await RisingEdge(dut.clk)
    await Timer(50, unit="ns")
    assert int(q.value) == 0xA4, f"{prefix}: active-low WEN mask failed"

    await FallingEdge(dut.clk)
    cen.value = 1


@cocotb.test()
async def test_sram_template(dut):
    dut._log.info("Starting GF180 SRAM tests")

    # The vendor data sheet/model specifies Tcyc=55.6 ns and 25 ns minimum
    # high/low pulses. Use 100 ns. Icarus cannot elaborate the model's
    # conditional bit-specific specify output paths, so this test exercises
    # functional model behavior; physical timing remains checked by LibreLane
    # STA using the vendor Liberty timing views.
    clock = Clock(dut.clk, 100, unit="ns")
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Keep all standalone macros inactive during their initial clock cycle.
    for prefix in ("sram64_test", "sram128_test", "sram256_test", "sram512_test"):
        getattr(dut, f"{prefix}_cen").value = 1
        getattr(dut, f"{prefix}_gwen").value = 1
        getattr(dut, f"{prefix}_wen").value = 0xFF
        getattr(dut, f"{prefix}_a").value = 0
        getattr(dut, f"{prefix}_d").value = 0

    cocotb.start_soon(clock.start(start_high=False))
    await ClockCycles(dut.clk, 2)

    # Exercise the actual Tiny Tapeout top-level pin mapping.
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1
    dut.ui_in.value = (1 << 6) | 13
    dut.uio_in.value = 0xA5
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    await FallingEdge(dut.clk)
    dut.ui_in.value = 13  # ui_in[6]=0 selects read mode
    await RisingEdge(dut.clk)
    await Timer(50, unit="ns")
    assert int(dut.uo_out.value) == 0xA5, "Tiny Tapeout top-level SRAM access failed"
    assert int(dut.uio_out.value) == 0
    assert int(dut.uio_oe.value) == 0

    # Exercise each official macro model at its highest address.
    await exercise_macro(dut, "sram64_test", 63)
    await exercise_macro(dut, "sram128_test", 127)
    await exercise_macro(dut, "sram256_test", 255)
    await exercise_macro(dut, "sram512_test", 511)

    dut._log.info("All GF180 SRAM tests passed")
