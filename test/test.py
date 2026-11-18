                                     
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer


async def exercise_macro(dut, prefix, address):
    cen = getattr(dut, f"{prefix}_cen")
    gwen = getattr(dut, f"{prefix}_gwen")
    wen = getattr(dut, f"{prefix}_wen")
    addr = getattr(dut, f"{prefix}_a")
    data = getattr(dut, f"{prefix}_d")
    q = getattr(dut, f"{prefix}_q")

    await FallingEdge(dut.clk)
    cen.value = 0
    gwen.value = 0
    wen.value = 0x00
    addr.value = address
    data.value = 0xA5

    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    await FallingEdge(dut.clk)
    gwen.value = 1
    await RisingEdge(dut.clk)
    await Timer(50, unit="ns")
    assert int(q.value) == 0xA5, f"{prefix}: full-byte write/read failed"

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


async def load_program(dut, program):
    for inst_idx, instruction in enumerate(program):
        byte_lo_addr = inst_idx * 2
        byte_hi_addr = inst_idx * 2 + 1

        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x80 | byte_lo_addr
        dut.uio_in.value = instruction & 0xFF
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")

        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x80 | byte_hi_addr
        dut.uio_in.value = (instruction >> 8) & 0xFF
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")


@cocotb.test()
async def test_sram_template(dut):
    dut._log.info("Starting QKCPU with Runtime uo_out & Per-Pin GPIO/PWM tests")

    clock = Clock(dut.clk, 100, unit="ns")
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0x80                        
    dut.uio_in.value = 0

    for prefix in ("sram64_test", "sram128_test", "sram256_test", "sram512_test"):
        getattr(dut, f"{prefix}_cen").value = 1
        getattr(dut, f"{prefix}_gwen").value = 1
        getattr(dut, f"{prefix}_wen").value = 0xFF
        getattr(dut, f"{prefix}_a").value = 0
        getattr(dut, f"{prefix}_d").value = 0

    cocotb.start_soon(clock.start(start_high=False))
    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)


    program = [
        0x80A8,                                
        0xC000,                                                            
        0x840C,                                                       
        0x8980,                                                    
        0xA181,                                                                             
        0x8600,                                              
        0x89C0,                                                    
        0xA181,                                            
        0x8408,                                                   
        0x8984,                                                    
        0xA181,                                                            
        0x8600,                                              
        0x89C4,                                                    
        0xA181,                                            
        0x8855,                                                                               
        0xF000,            
    ]
    await load_program(dut, program)

                                                                                             
    await FallingEdge(dut.clk)
    dut.ui_in.value = 0x20

                                                                    
    await ClockCycles(dut.clk, 12)
    assert int(dut.uo_out.value) == 42, f"Expected runtime uo_out=42, got {int(dut.uo_out.value)}"

                                                       
    await ClockCycles(dut.clk, 70)

                                                                                    
    assert int(dut.uo_out.value) == 0x15, f"Expected halted reg view R2=21 on uo_out, got {int(dut.uo_out.value)}"

                                                                                     
    assert int(dut.uio_oe.value) == 0x03, f"Expected uio_oe=0x03, got {int(dut.uio_oe.value):#04x}"
                                     
    assert (int(dut.uio_out.value) & 0x01) == 1, "Expected uio_out[0] == 1"

                                                                                
    pwm_high_cycles = 0
    for _ in range(256):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")
        if (int(dut.uio_out.value) >> 1) & 1:
            pwm_high_cycles += 1
    assert 120 <= pwm_high_cycles <= 136, f"Expected ~128 PWM high cycles, got {pwm_high_cycles}"

                                                     
    await exercise_macro(dut, "sram64_test", 63)
    await exercise_macro(dut, "sram128_test", 127)
    await exercise_macro(dut, "sram256_test", 255)
    await exercise_macro(dut, "sram512_test", 511)

    dut._log.info("All QKCPU runtime I/O, per-pin GPIO/PWM, and SRAM tests passed!")