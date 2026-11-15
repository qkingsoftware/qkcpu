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
    dut._log.info("Starting QKCPU with Dual GF180 SRAM tests")

    clock = Clock(dut.clk, 100, unit="ns")
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0x80  # Start in loader mode
    dut.uio_in.value = 0

    # Keep all standalone macro testbench instances inactive
    for prefix in ("sram64_test", "sram128_test", "sram256_test", "sram512_test"):
        getattr(dut, f"{prefix}_cen").value = 1
        getattr(dut, f"{prefix}_gwen").value = 1
        getattr(dut, f"{prefix}_wen").value = 0xFF
        getattr(dut, f"{prefix}_a").value = 0
        getattr(dut, f"{prefix}_d").value = 0

    cocotb.start_soon(clock.start(start_high=False))
    await ClockCycles(dut.clk, 5)

    # Reset CPU
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Load CPU Program into Program RAM (SRAM0) via Loader:
    # Program:
    # 0x80A8: LDI R0, 42
    # 0xC000: OUT R0
    # 0xF000: HALT
    program = [0x80A8, 0xC000, 0xF000]
    for inst_idx, instruction in enumerate(program):
        byte_lo_addr = inst_idx * 2
        byte_hi_addr = inst_idx * 2 + 1

        # Write low byte
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x80 | byte_lo_addr
        dut.uio_in.value = instruction & 0xFF
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")

        # Write high byte
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x80 | byte_hi_addr
        dut.uio_in.value = (instruction >> 8) & 0xFF
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")

    # Exit loader mode: switch to Run Mode (ui_in[7]=0)
    await FallingEdge(dut.clk)
    dut.ui_in.value = 0x00  # run mode, select R0 (ui_in[5:4] = 2'b00)

    # Let CPU run for 25 clock cycles
    await ClockCycles(dut.clk, 25)

    # Check that R0 was loaded with 42 and output to uo_out
    assert int(dut.uo_out.value) == 42, f"Expected R0=42 on uo_out, got {int(dut.uo_out.value)}"
    # Check that OUT R0 sent 42 to uio_out
    assert int(dut.uio_out.value) == 42, f"Expected 42 on uio_out, got {int(dut.uio_out.value)}"
    assert int(dut.uio_oe.value) == 0xFF, f"Expected uio_oe=0xFF in run mode, got {int(dut.uio_oe.value)}"

    # Exercise each official macro model in testbench
    await exercise_macro(dut, "sram64_test", 63)
    await exercise_macro(dut, "sram128_test", 127)
    await exercise_macro(dut, "sram256_test", 255)
    await exercise_macro(dut, "sram512_test", 511)

    dut._log.info("All QKCPU and GF180 SRAM tests passed successfully!")
