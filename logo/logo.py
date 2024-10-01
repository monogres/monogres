#!/usr/bin/env python3

import math
import sys
from pathlib import Path

import palette
import svg


def _gen_logo(  # noqa: PLR0913, PLR0914, PLR0915, PLR0917
    width: int = 640,
    height: int = 640,
    unit_cube: int = 100,  # "unit cube length"
    palette: palette.Palette = palette.PALETTE_2,
    cbox_cubes: bool = True,  # noqa: FBT001, FBT002
    cbox_bazel_colors: bool = True,  # noqa: FBT001, FBT002
    remove_top_cbox_cube: bool = False,  # noqa: FBT001, FBT002
) -> svg.SVG:
    # Let's make the center box be of 1 unit height and 2 units width/depth
    c_h = 1 * unit_cube
    c_w = 2 * unit_cube

    # Isometric projection uses angles of 120 degrees between the three
    # coordinate axes, with the x and z axes tilted at 30 degrees relative to
    # the horizontal.

    # 30 degrees is 0.1666666667 * Pi radians which is 0.5235987755983 radians
    # let's approx to 0.52
    isometric_angle = 0.52

    # Thus, the center box side projected on the x axis will be:
    c_x = math.cos(isometric_angle) * c_w
    # while the height is not affected by the projection, so
    c_y = c_h

    # The height of the "M" will be 4 times the center cube height
    m_h = 4 * c_h
    # and the width will be half the center cube width
    m_w = 0.5 * c_w

    # Again, let's do the projections
    m_x = math.cos(isometric_angle) * m_w
    m_y = m_h

    # Finally, d_y is the "delta y" of the back-side of the M due to the
    # projection
    d_y = math.sin(isometric_angle) * m_w

    # With all the maths done, we can easily create the logo. First, we setup
    # all the coordinates we will need

    center = svg.Point(int(width / 2), int(height / 2), "center")

    p01 = svg.Point(center.x, center.y, "p1")

    p02 = svg.Point(p01.x - 1 * c_x, p01.y - 1 * c_y, "p2")
    p03 = svg.Point(p01.x - 1 * c_x, p01.y + 1 * c_y, "p3")

    p04 = svg.Point(p01.x + 1 * c_x, p01.y - 1 * c_y, "p4")
    p05 = svg.Point(p01.x + 1 * c_x, p01.y + 1 * c_y, "p5")

    p06 = svg.Point(p01.x, p01.y + 2 * c_y, "p6")

    p07 = svg.Point(p01.x, p06.y + 1 * c_y, "p7")
    p08 = svg.Point(p03.x, p03.y + 1 * c_y, "p8")
    p09 = svg.Point(p05.x, p05.y + 1 * c_y, "p9")

    p10 = svg.Point(p08.x - 1 * m_x, p08.y - 1 * d_y, "p10")
    p11 = svg.Point(p10.x, p10.y - 1 * m_y, "p11")
    p12 = svg.Point(p01.x, p01.y - 1 * c_y, "p12")
    p13 = svg.Point(p08.x, p08.y - 3 * c_y, "p13")

    p14 = svg.Point(p09.x + 1 * m_x, p09.y - 1 * d_y, "p14")
    p15 = svg.Point(p14.x, p14.y - 1 * m_y, "p15")
    p16 = svg.Point(p09.x, p09.y - 3 * c_y, "p16")

    p17 = svg.Point(p11.x + 1 * m_x, p11.y - 1 * d_y, "p17")
    p18 = svg.Point(p12.x + 1 * m_x, p12.y - 1 * d_y, "p18")

    p19 = svg.Point(p12.x, p12.y - 2 * d_y, "p19")
    p20 = svg.Point(p15.x - 1 * m_x, p15.y - 1 * d_y, "p20")

    # center box points
    cb_x = math.cos(isometric_angle) * unit_cube
    cb_y = math.sin(isometric_angle) * unit_cube

    cb1 = svg.Point(p01.x, p01.y + c_y, "cb1")
    cb2 = svg.Point(cb1.x - cb_x, cb1.y - cb_y, "cb2")
    cb3 = svg.Point(cb1.x - cb_x, cb1.y + cb_y, "cb3")
    cb4 = svg.Point(cb1.x + cb_x, cb1.y + cb_y, "cb4")
    cb5 = svg.Point(cb1.x + cb_x, cb1.y - cb_y, "cb5")
    cb6 = svg.Point(cb3.x, cb3.y + c_y, "cb6")
    cb7 = svg.Point(cb4.x, cb4.y + c_y, "cb7")

    # final "leg points" of the M
    p21 = svg.Point(cb2.x, cb2.y - c_y, "p21")
    p22 = svg.Point(cb5.x, cb5.y - c_y, "p22")

    # Then, we create the polygons
    polygons_letter_m = [
        svg.Polygon(
            points=[p14, p15, p12, p01, p16, p09],
            style=palette.c3.d2,
            id="M_BODY_R",
        ),
        svg.Polygon(
            points=[p22, p04, p05, cb5],
            style=palette.c3.d1,
            id="M_LEG_R",
        ),
        svg.Polygon(
            points=[p15, p18, p19, p20],
            style=palette.c3.l2,
            id="M_ROOF_R",
        ),
        svg.Polygon(
            points=[p10, p11, p12, p01, p13, p08],
            style=palette.c2.d1,
            id="M_BODY_L",
        ),
        svg.Polygon(
            points=[p21, p02, p03, cb2],
            style=palette.c2.d2,
            id="M_LEG_L",
        ),
        svg.Polygon(
            points=[p11, p12, p18, p17],
            style=palette.c2.l1,
            id="M_ROOF_L",
        ),
        svg.Polygon(
            points=[p01, p12, p18, p22],
            style=palette.c2.d2,
            id="M_ROOF_FRONT",
        ),
    ]

    cb_p = palette.c1 if cbox_bazel_colors else palette.c4

    polygons_center_box = [
        svg.Polygon(points=[p01, p03, p06, p05], style=cb_p.l1, id="CB_TOP"),
        svg.Polygon(points=[p06, p07, p08, p03], style=cb_p.l2, id="CB_LEFT"),
        svg.Polygon(points=[p06, p07, p09, p05], style=cb_p.d2, id="CB_RIGHT"),
    ]

    polygons_center_box_cubes = [
        svg.Polygon(points=[cb1, cb2, p03, cb3], style=cb_p.l1, id="CB1"),
        svg.Polygon(points=[cb1, cb3, p06, cb4], style=cb_p.l2, id="CB2"),
        svg.Polygon(points=[cb1, cb4, p05, cb5], style=cb_p.l1, id="CB3"),
        svg.Polygon(points=[p03, cb3, cb6, p08], style=cb_p.l2, id="CB4"),
        svg.Polygon(points=[p05, cb4, cb7, p09], style=cb_p.l2, id="CB5"),
        svg.Polygon(points=[cb3, cb6, p07, p06], style=cb_p.d1, id="CB6"),
        svg.Polygon(points=[cb4, cb7, p07, p06], style=cb_p.d2, id="CB7"),
        svg.Polygon(points=[cb1, cb2, p01, cb5], style=cb_p.d1, id="CB8"),
    ]

    groups = [svg.Group(id="M", polygons=polygons_letter_m)]

    if cbox_cubes:
        if remove_top_cbox_cube:
            # NOTE: since removing the cube makes the center_box the Bazel logo
            # we would probably need approval: https://bazel.build/brand
            polygons_center_box_cubes.pop()

        center_box = svg.Group(id="cubes", polygons=polygons_center_box_cubes)
    else:
        center_box = svg.Group(id="box", polygons=polygons_center_box)

    groups.append(center_box)

    return svg.SVG(width=width, height=height, groups=groups, id="logo")


if __name__ == "__main__":
    logo = _gen_logo()

    with Path.open(sys.argv[1], "w", encoding="utf8") as f:
        f.write(str(logo))
