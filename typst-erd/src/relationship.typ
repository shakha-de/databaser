// src/relationship.typ
// Relationship (diamond) rendering for typst-erd.

#import "@preview/cetz:0.4.2": draw
#import "styles.typ": default-theme
#import "utils.typ": resolve-style

/// Draws a relationship diamond.
///
/// Parameters:
///   - name (string):       Relationship label displayed inside the diamond.
///   - pos (array):         (x, y) CeTZ coordinate for the diamond centre.
///   - identifying (bool):  If true, a double-bordered (inner) diamond is also drawn.
///   - style (dictionary):  Per-element style overrides merged over the active theme.
///   - theme (dictionary):  Active theme (passed in by `erd()`). Default: default-theme.
///
/// Anchors created:
///   - "center", "north", "south", "east", "west"
#let relationship(
  name,
  pos,
  identifying: false,
  style:       (:),
  theme:       default-theme,
) = {
  let s  = resolve-style(theme, "relationship", style)
  let hw = s.half-width    // horizontal half-span
  let hh = s.half-height   // vertical half-span

  let x = pos.at(0)
  let y = pos.at(1)

  let north = (x,      y + hh)
  let south = (x,      y - hh)
  let east  = (x + hw, y)
  let west  = (x - hw, y)

  draw.group(name: name, {
    // ── Named anchors ──────────────────────────────────────────────────────
    draw.anchor("center", pos)
    draw.anchor("north",  north)
    draw.anchor("south",  south)
    draw.anchor("east",   east)
    draw.anchor("west",   west)

    // ── Outer diamond ──────────────────────────────────────────────────────
    draw.line(
      north, east, south, west,
      close:  true,
      fill:   s.fill,
      stroke: s.stroke,
    )

    // ── Inner diamond (identifying relationships) ──────────────────────────
    if identifying {
      let scale = 0.80
      draw.line(
        (x,            y + hh * scale),
        (x + hw * scale, y),
        (x,            y - hh * scale),
        (x - hw * scale, y),
        close:  true,
        fill:   none,
        stroke: s.stroke,
      )
    }

    // ── Label ──────────────────────────────────────────────────────────────
    draw.content(
      pos,
      text(weight: s.label-weight, size: s.font-size * 1em, name),
      anchor: "center",
    )
  })
}
