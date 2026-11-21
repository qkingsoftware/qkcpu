
#!/usr/bin/env python3

import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()

size = re.search(
    r"(?m)^\s*SIZE\s+([\d.]+)\s+BY\s+([\d.]+)\s*;",
    text,
)
if not size:
    raise SystemExit("Cannot determine LEF die dimensions")

die_height = float(size.group(2))
moved = []

for pin in ("VGND", "VPWR"):
    pin_re = re.compile(
        rf"(?ms)^[ \t]*PIN {pin}[ \t]*\n"
        rf"(?P<body>.*?)"
        rf"(?=^[ \t]*END {pin}[ \t]*$)"
    )

    match = pin_re.search(text)
    if not match:
        raise SystemExit(f"Missing power pin: {pin}")

    body = match.group("body")

    port_re = re.compile(
        r"(?ms)^[ \t]*PORT[ \t]*\n.*?^[ \t]*END[ \t]*$"
    )

    def fix_port(port_match):
        block = port_match.group(0)

        layer = re.search(
            r"(?m)^[ \t]*LAYER\s+(\S+)\s*;",
            block,
        )
        rect = re.search(
            r"(?m)^[ \t]*RECT\s+"
            r"([-\d.]+)\s+([-\d.]+)\s+"
            r"([-\d.]+)\s+([-\d.]+)\s*;",
            block,
        )

        if not layer or not rect:
            return block

        x1, y1, x2, y2 = map(float, rect.groups())

        # Internal power geometry is not a top-level boundary pin.
        if y1 > 10 and die_height - y2 > 10:
            if len(re.findall(r"(?m)^[ \t]*RECT\s+", block)) != 1:
                raise SystemExit("Unexpected multi-rectangle PORT")

            moved.append((pin, layer.group(1), x1, y1, x2, y2))
            return ""

        return block

    new_body = port_re.sub(fix_port, body)

    text = (
        text[:match.start("body")]
        + new_body
        + text[match.end("body"):]
    )

if len(moved) != 2:
    raise SystemExit(
        f"Expected exactly 2 internal power rectangles; found {len(moved)}"
    )

obs = re.search(
    r"(?ms)^[ \t]*OBS[ \t]*\n"
    r"(?P<body>.*?)"
    r"(?=^[ \t]*END[ \t]*\n[ \t]*END\s+\S+\s*$)",
    text,
)

if not obs:
    raise SystemExit("LEF OBS section not found")

obstructions = "\n".join(
    f"    LAYER {layer} ;\n"
    f"      RECT {x1:.3f} {y1:.3f} {x2:.3f} {y2:.3f} ;"
    for _, layer, x1, y1, x2, y2 in moved
)

text = (
    text[:obs.end("body")]
    + "\n"
    + obstructions
    + "\n"
    + text[obs.end("body"):]
)

path.write_text(text)

print("Corrected LEF power-pin export:")
for pin, layer, x1, y1, x2, y2 in moved:
    print(f"  {pin}: moved {layer} rectangle to OBS")
