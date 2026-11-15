#!/usr/bin/env python3
"""Normalize the GF180 SRAM GDS hierarchy for Tiny Tapeout rendering."""

from pathlib import Path

import gdstk


GDS_PATH = Path(
    "macros/gf180_sram_128x8/"
    "gf180mcu_fd_ip_sram__sram128x8m8wm1.gds"
)
ROOT_CELL = "gf180mcu_fd_ip_sram__sram128x8m8wm1"
UNSUPPORTED_LAYER = 58
CELL_PREFIX = "GF180S_"


def main() -> None:
    if not GDS_PATH.is_file():
        raise SystemExit(f"SRAM GDS not found: {GDS_PATH}")

    library = gdstk.read_gds(str(GDS_PATH))
    roots = [cell for cell in library.cells if cell.name == ROOT_CELL]
    if len(roots) != 1:
        raise SystemExit(
            f"Expected one SRAM root cell {ROOT_CELL!r}; found {len(roots)}"
        )

    root = roots[0]
    internal_cells = sorted(
        (cell for cell in library.cells if cell is not root),
        key=lambda cell: cell.name,
    )
    for index, cell in enumerate(internal_cells):
        cell.name = f"{CELL_PREFIX}{index:04d}"

    removed = 0
    for cell in library.cells:
        elements = [
            polygon
            for polygon in cell.polygons
            if polygon.layer == UNSUPPORTED_LAYER
        ]
        elements.extend(
            path
            for path in cell.paths
            if UNSUPPORTED_LAYER in set(path.layers)
        )
        elements.extend(
            label
            for label in cell.labels
            if label.layer == UNSUPPORTED_LAYER
        )
        if elements:
            cell.remove(*elements)
            removed += len(elements)

    temporary = GDS_PATH.with_suffix(".normalized.gds")
    library.write_gds(str(temporary))
    temporary.replace(GDS_PATH)
    print(
        f"Normalized {GDS_PATH}: renamed {len(internal_cells)} internal cells, "
        f"removed {removed} unsupported-layer elements"
    )


if __name__ == "__main__":
    main()
