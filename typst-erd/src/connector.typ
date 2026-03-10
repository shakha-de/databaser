// src/connector.typ
// Line / arrow connection logic for typst-erd.

#import "@preview/cetz:0.4.2": draw, coordinate as cetz-coord
#import "styles.typ": default-theme
#import "utils.typ": resolve-style, clamp, auto-anchor

// ── Internal helpers ───────────────────────────────────────────────────────────

/// Draw a crow's foot symbol between two anchor points.
/// Uses draw.get-ctx to resolve actual coordinates at render time.
#let _crow-foot(src-anchor, dst-anchor, stroke-style) = {
  draw.get-ctx(ctx => {
    let (_, to-pt)   = cetz-coord.resolve(ctx, dst-anchor)
    let (_, from-pt) = cetz-coord.resolve(ctx, src-anchor)

    let dx = to-pt.at(0) - from-pt.at(0)
    let dy = to-pt.at(1) - from-pt.at(1)
    let len = calc.sqrt(dx * dx + dy * dy)
    if len < 0.001 { return }

    // Unit vector along the line (base → tip).
    let ux = dx / len
    let uy = dy / len

    // Perpendicular unit vector.
    let px = -uy
    let py = ux

    let fork-depth = 0.25
    let spread     = 0.18
    let bar-offset = 0.35

    let tip = (to-pt.at(0), to-pt.at(1))

    // Bar position (set-back from tip).
    let bar-pt = (tip.at(0) - ux * bar-offset, tip.at(1) - uy * bar-offset)
    let bar-l  = (bar-pt.at(0) + px * spread, bar-pt.at(1) + py * spread)
    let bar-r  = (bar-pt.at(0) - px * spread, bar-pt.at(1) - py * spread)

    // Fork prongs.
    let fork-base = (tip.at(0) - ux * fork-depth, tip.at(1) - uy * fork-depth)
    let left-tip  = (tip.at(0) + px * spread,     tip.at(1) + py * spread)
    let right-tip = (tip.at(0) - px * spread,     tip.at(1) - py * spread)

    draw.line(bar-l,     bar-r,     stroke: stroke-style)
    draw.line(fork-base, tip,       stroke: stroke-style)
    draw.line(fork-base, left-tip,  stroke: stroke-style)
    draw.line(fork-base, right-tip, stroke: stroke-style)
  })
}

/// Draw a simple open arrowhead at the destination anchor pointing away from source.
/// Uses draw.get-ctx to resolve actual coordinates at render time.
#let _uml-arrow(src-anchor, dst-anchor, stroke-style) = {
  draw.get-ctx(ctx => {
    let (_, to-pt)   = cetz-coord.resolve(ctx, dst-anchor)
    let (_, from-pt) = cetz-coord.resolve(ctx, src-anchor)

    let dx = to-pt.at(0) - from-pt.at(0)
    let dy = to-pt.at(1) - from-pt.at(1)
    let len = calc.sqrt(dx * dx + dy * dy)
    if len < 0.001 { return }

    let ux = dx / len
    let uy = dy / len
    let px = -uy
    let py = ux

    let depth  = 0.22
    let spread = 0.12

    let tip   = (to-pt.at(0), to-pt.at(1))
    let left  = (tip.at(0) - ux * depth + px * spread, tip.at(1) - uy * depth + py * spread)
    let right = (tip.at(0) - ux * depth - px * spread, tip.at(1) - uy * depth - py * spread)

    draw.line(tip, left,  stroke: stroke-style)
    draw.line(tip, right, stroke: stroke-style)
  })
}

// ── Public API ─────────────────────────────────────────────────────────────────

/// Draw a cardinality label at a given canvas position.
///
/// Parameters:
///   - label (string):         The cardinality text (e.g. "1", "N", "0..N").
///   - pos (array or string):  (x, y) canvas position or CeTZ anchor string.
///   - style (dictionary):     Connector style sub-dict from the active theme.
#let cardinality-label(label, pos, style) = {
  draw.content(
    pos,
    box(
      fill:    style.label-fill,
      inset:   2pt,
      radius:  2pt,
      text(
        weight: style.label-weight,
        size:   style.label-size * 1em,
        fill:   white,
        label,
      ),
    ),
    anchor: "center",
  )
}

/// Draws a line between two ERD elements with optional cardinality notation.
///
/// Parameters:
///   - from (string):          Source element key.
///   - to (string):            Target element key.
///   - label (string):         Cardinality label ("1", "N", "M", "0..1", etc.).
///   - label-pos (float):      0.0–1.0 position along the line. Default: 0.85.
///   - notation (string):      "crow" | "chen" | "uml". Default: "chen".
///   - from-anchor (string):   Override source anchor. Default: "center".
///   - to-anchor (string):     Override target anchor. Default: "center".
///   - style (dictionary):     Per-element style overrides merged over the active theme.
///   - theme (dictionary):     Active theme (passed in by `erd()`). Default: default-theme.
#let connector(
  from,
  to,
  label:       none,
  label-pos:   0.85,
  notation:    "chen",
  from-anchor: none,
  to-anchor:   none,
  style:       (:),
  theme:       default-theme,
) = {
  // ── Validation ─────────────────────────────────────────────────────────
  assert(
    notation in ("chen", "crow", "uml"),
    message: "connector: `notation` must be one of \"chen\", \"crow\", or \"uml\", got: " + notation,
  )
  assert(
    label-pos >= 0.0 and label-pos <= 1.0,
    message: "connector: `label-pos` must be between 0.0 and 1.0, got: " + str(label-pos),
  )

  let s = resolve-style(theme, "connector", style)

  // Capture user-supplied overrides before entering draw.get-ctx.
  let explicit-src = from-anchor
  let explicit-dst = to-anchor

  draw.get-ctx(ctx => {
    // ── Resolve source anchor ───────────────────────────────────────────
    let src-anchor = if explicit-src != none {
      explicit-src
    } else {
      let (_, fp) = cetz-coord.resolve(ctx, from + ".center")
      let (_, tp) = cetz-coord.resolve(ctx, to   + ".center")
      auto-anchor(fp, tp)
    }

    // ── Resolve destination anchor ──────────────────────────────────────
    let dst-anchor = if explicit-dst != none {
      explicit-dst
    } else {
      let (_, fp) = cetz-coord.resolve(ctx, from + ".center")
      let (_, tp) = cetz-coord.resolve(ctx, to   + ".center")
      auto-anchor(tp, fp)
    }

    let src = from + "." + src-anchor
    let dst = to   + "." + dst-anchor

    // ── Main line ─────────────────────────────────────────────────────────
    draw.line(src, dst, stroke: s.stroke)

    // ── Notation marks at the destination end ────────────────────────────
    if notation == "crow" {
      _crow-foot(src, dst, s.stroke)
    } else if notation == "uml" {
      _uml-arrow(src, dst, s.stroke)
    }

    // ── Cardinality label ─────────────────────────────────────────────────
    if label != none {
      let lp = clamp(label-pos, 0.0, 1.0)
      draw.content(
        (src, lp, dst),
        box(
          fill:   s.label-fill,
          inset:  2pt,
          radius: 2pt,
          text(
            weight: s.label-weight,
            size:   s.label-size * 1em,
            fill:   white,
            label,
          ),
        ),
        anchor: "center",
      )
    }
  })
}
