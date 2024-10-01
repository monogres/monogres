from __future__ import annotations

from dataclasses import Field, dataclass, fields
from typing import Any, Protocol, TypeVar

T = TypeVar("T")


class CssRenderable(Protocol):
    def __str__(self) -> str:
        cls_name = self.__class__.__name__.lower()

        def render(field: Field[Any]) -> str:
            key = cls_name if field.name == "color" else f"{cls_name}-{field.name}"
            value = getattr(self, field.name)
            return f"{key}: {value}"

        return "; ".join(render(field) for field in fields(self))


def css_dataclass(cls: type[T]) -> type[T]:
    """
    Class decorator to apply both dataclass and CssRenderable base class.
    """
    return dataclass(type(cls.__name__, (CssRenderable, cls), dict(cls.__dict__)))


@css_dataclass
class Fill:
    color: str


@css_dataclass
class Stroke:
    color: str
    width: int = 8
    linecap: str = "round"
    linejoin: str = "round"


@css_dataclass
class Style:
    fill: Fill
    stroke: Stroke

    def __str__(self) -> str:
        return "; ".join(str(getattr(self, field.name)) for field in fields(self))


@dataclass
class Point:
    x: int
    y: int
    id: str

    def __str__(self) -> str:
        return ",".join([str(self.x), str(self.y)])


@dataclass
class Polygon:
    points: list[Point]
    style: Style
    id: str
    description: str | None = None

    def __str__(self) -> str:
        points = " ".join(str(p) for p in self.points)

        chunks = [
            "<polygon",
            f'    style="{self.style}"',
            f'    points="{points}"',
            f'    id="{self.id}"',
            " />",
        ]

        if self.description:
            chunks = [f"<!-- {self.description} -->", *chunks]

        return "\n".join(chunks)


@dataclass
class Group:
    id: str
    polygons: list[Polygon]

    def __str__(self) -> str:
        return "\n".join(
            [
                f'<g id="{self.id}">',
                "\n".join(str(p) for p in self.polygons),
                "</g>",
            ],
        )


@dataclass
class SVG:
    width: int
    height: int
    groups: list[Group]
    id: str

    def __str__(self) -> str:
        template = """
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   version="1.0"
   width="{width}pt"
   height="{height}pt"
   viewBox="0 0 {width} {height}"
   preserveAspectRatio="xMidYMid meet"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:svg="http://www.w3.org/2000/svg"
   id="{id}"
>
  {groups}
</svg>
""".lstrip()

        return template.format(
            id=self.id,
            width=self.width,
            height=self.height,
            groups="\n".join(str(g) for g in self.groups),
        )
