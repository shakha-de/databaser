// src/entity.typ
// Entity (rectangle with header) rendering for typst-erd.

#import "@preview/cetz:0.4.2": draw
#import "styles.typ": default-theme
#import "utils.typ": resolve-style

/// Draws a named entity box with a filled header and attribute rows.
///
/// Parameters:
///   - name (string):       Entity label shown in the header.
///   - pos (array):         (x, y) CeTZ coordinate for the box centre.
///   - attributes (array):  List of attribute strings shown below the header.
///   - width (float):       Box width in CeTZ units. Default: 3.
///   - key (string):        Optional CeTZ anchor key. Defaults to `name`.
///   - style (dictionary):  Per-element style overrides merged over the active theme.
///   - theme (dictionary):  Active theme (passed in by `erd()`). Default: default-theme.
///
/// Anchors created (all relative to the group named `key`):
///   - "center", "north", "south", "east", "west"
#let entity(
  name,
  pos,
  attributes: (),
  width:      3,
  key:        none,
  style:      (:),
  theme:      default-theme,
) = {
  let anchor-key = if key != none { key } else { name }
  let s = resolve-style(theme, "entity", style)

  let header-h = s.header-height
  let row-h    = s.row-height
  let n-attrs  = attributes.len()
  let total-h  = header-h + n-attrs * row-h

  // The `pos` is the centre of the whole box.
  let x = pos.at(0)
  let y = pos.at(1)

  let left   = x - width / 2
  let right  = x + width / 2
  let top    = y + total-h / 2
  let bottom = y - total-h / 2

  draw.group(name: anchor-key, {
    // ── Named anchors ──────────────────────────────────────────────────────
    draw.anchor("center", pos)
    draw.anchor("north",  (x, top))
    draw.anchor("south",  (x, bottom))
    draw.anchor("east",   (right, y))
    draw.anchor("west",   (left, y))

    // ── Drop shadow ────────────────────────────────────────────────────────
    let sx = s.shadow-offset.at(0)
    let sy = s.shadow-offset.at(1)
    draw.rect(
      (left  + sx, bottom + sy),
      (right + sx, top    + sy),
      fill:   s.shadow-fill,
      stroke: none,
      radius: s.radius,
    )

    // ── Body background ────────────────────────────────────────────────────
    draw.rect(
      (left, bottom),
      (right, top),
      fill:   s.body-fill,
      stroke: s.stroke,
      radius: s.radius,
    )

    // ── Header ─────────────────────────────────────────────────────────────
    let header-top    = top
    let header-bottom = top - header-h
    draw.rect(
      (left, header-bottom),
      (right, header-top),
      fill:   s.header-fill,
      stroke: s.stroke,
      radius: (top-left: s.radius, top-right: s.radius, bottom-left: 0, bottom-right: 0),
    )

    // Header label.
    draw.content(
      ((left + right) / 2, (header-top + header-bottom) / 2),
      text(fill: s.header-text, weight: "bold", size: s.font-size * 1em, name),
      anchor: "center",
    )

    // ── Attribute rows ─────────────────────────────────────────────────────
    for (i, attr) in attributes.enumerate() {
      let row-top    = header-bottom - i * row-h
      let row-bottom = row-top - row-h
      let row-fill   = if calc.rem(i, 2) == 0 { s.body-fill } else { s.alt-row-fill }

      draw.rect(
        (left, row-bottom),
        (right, row-top),
        fill:   row-fill,
        stroke: s.stroke,
        radius: 0,
      )

      draw.content(
        (left + s.padding, (row-top + row-bottom) / 2),
        text(size: s.font-size * 1em, attr),
        anchor: "west",
      )
    }
  })
}
