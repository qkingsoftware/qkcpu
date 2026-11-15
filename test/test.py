# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Load and run CPU program")

    # Loader mode: ui_in[5:0] is the word address and ui_in[6] selects
    # the high byte. Keep reset asserted while loading.
    program = [0x80A8, 0xC000, 0xF000]  # LDI R0, 42; OUT R0; HALT
    for address, instruction in enumerate(program):
        dut.ui_in.value = 0x80 | address
        dut.uio_in.value = instruction & 0xFF
        await ClockCycles(dut.clk, 1)
        dut.ui_in.value = 0xC0 | address
        dut.uio_in.value = (instruction >> 8) & 0xFF
        await ClockCycles(dut.clk, 1)

    dut.ui_in.value = 0
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 12)

    # ui_in[5:4] selects the exposed register; uio_out is the OUT port.
    assert dut.uo_out.value == 42
    assert dut.uio_out.value == 42
    assert dut.uio_oe.value == 0xFF
