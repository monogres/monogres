from dataclasses import dataclass

import svg

BLUE_L1 = "#82a0b9"
GREEN_L1 = "#91c87d"

BLUE_BORDER = "#1e3250"

PG_BLUE_L1 = "#689FCA"
PG_BLUE_L2 = "#4989BA"
PG_BLUE_D1 = "#3E5E88"
PG_BLUE_D2 = "#326791"  # "Slonik" blue

BZL_GREEN_L1 = "#76D276"
BZL_GREEN_L2 = "#42A047"
BZL_GREEN_D1 = "#00701A"
BZL_GREEN_D2 = "#014300"

BZL_GRAY_L1 = "#E0E0E0"
BZL_GRAY_L2 = "#B0B0B0"
BZL_GRAY_D1 = "#707070"
BZL_GRAY_D2 = "#404040"

GRAY_L1 = "#c5c5c5"
GRAY_L2 = "#ccc"
GRAY_D1 = "#999"
GRAY_D2 = "#666"


@dataclass
class Shades:
    l1: svg.Style
    l2: svg.Style
    d1: svg.Style
    d2: svg.Style


@dataclass
class Palette:
    c1: Shades
    c2: Shades
    c3: Shades
    c4: Shades


def stroke(color: str, width: int = 8) -> svg.Stroke:
    return svg.Stroke(color, width)


COLORS = {
    "c1": {
        "l1": BZL_GREEN_L1,
        "l2": BZL_GREEN_L2,
        "d1": BZL_GREEN_D1,
        "d2": BZL_GREEN_D2,
    },
    "c2": {
        "l1": PG_BLUE_L1,
        "l2": PG_BLUE_L2,
        "d1": PG_BLUE_D2,
        "d2": BLUE_BORDER,
    },
    "c3": {
        "l1": GRAY_L1,
        "l2": GRAY_L2,
        "d1": GRAY_D1,
        "d2": GRAY_D2,
    },
    "c4": {
        "l1": BZL_GRAY_L1,
        "l2": BZL_GRAY_L2,
        "d1": BZL_GRAY_D1,
        "d2": BZL_GRAY_D2,
    },
}

PALETTE_1 = Palette(
    **{
        name: Shades(
            **{
                shade: svg.Style(svg.Fill(color), stroke(BLUE_BORDER))
                for shade, color in shades.items()
            },
        )
        for name, shades in COLORS.items()
    },
)

PALETTE_2 = Palette(
    **{
        name: Shades(
            **{
                shade: svg.Style(svg.Fill(color), stroke(color, width=0))
                for shade, color in shades.items()
            },
        )
        for name, shades in COLORS.items()
    },
)
