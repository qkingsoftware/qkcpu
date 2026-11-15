<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The CPU loads 16-bit instructions into its 128-word program SRAM over two
8-bit loader cycles. After loading, it fetches instructions, executes ALU,
register, load/store, branch, output, and halt operations, and uses a separate
128-byte data SRAM.

Set `ui_in[7]` while loading. `ui_in[5:0]` selects the instruction word,
`ui_in[6]` selects its high or low byte, and `uio_in` supplies the byte.
Clear `ui_in[7]` to run the CPU. `ui_in[5:4]` selects which CPU register is
shown on `uo_out`; `uio_out` shows the CPU OUT port.

## How to test

Hold `rst_n` low, load each instruction's low byte followed by its high byte,
then release reset and clear loader mode. The cocotb test in `test/test.py`
demonstrates this sequence.

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
