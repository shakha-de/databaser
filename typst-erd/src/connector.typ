// src/connector.typ
// Line / arrow connection logic for typst-erd.

#import "@preview/cetz:0.4.2": draw, coordinate as cetz-coord
#import "styles.typ": default-theme
#import "utils.typ": resolve-style, clamp, auto-anchor

// ── Internal helpers ───────────────────────────────────────────────────────────

/// Compute line direction vectors from two resolved anchor points.
/// Returns a tuple of (ux, uy, px, py, from-pt, to-pt) or none if line is too short.
/// Called from within draw.get-ctx context (expects pre-resolved points).
#let _compute-vectors-from-points(from-pt, to-pt) = {
  let dx = to-pt.at(0) - from-pt.at(0)
  let dy = to-pt.at(1) - from-pt.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)
  if len < 0.001 { return none }

  // Unit vector along the line (base → tip).
  let ux = dx / len
  let uy = dy / len

  // Perpendicular unit vector.
  let px = -uy
  let py = ux

  (ux, uy, px, py, from-pt, to-pt)
}

/// Draw a crow's foot symbol at the destination endpoint.
/// Assumes we're inside draw.get-ctx context. Receives pre-computed vectors.
#let _crow-foot(rx-vectors, stroke-style, config) = {
  if rx-vectors == none { return }

  let (ux, uy, px, py, _, to-pt) = rx-vectors
  let fork-depth = config.fork-depth
  let spread     = config.spread
  let bar-offset = config.bar-offset

  let tip = to-pt

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
}

/// Draw a simple open arrowhead at the destination endpoint.
/// Assumes we're inside draw.get-ctx context. Receives pre-computed vectors.
#let _uml-arrow(rx-vectors, stroke-style, config) = {
  if rx-vectors == none { return }

  let (ux, uy, px, py, _, to-pt) = rx-vectors
  let depth  = config.depth
  let spread = config.spread

  let tip   = to-pt
  let left  = (tip.at(0) - ux * depth + px * spread, tip.at(1) - uy * depth + py * spread)
  let right = (tip.at(0) - ux * depth - px * spread, tip.at(1) - uy * depth - py * spread)

  draw.line(tip, left,  stroke: stroke-style)
  draw.line(tip, right, stroke: stroke-style)
}

/// Draw no mark for Chen notation (explicit placeholder).
#let _chen-notation(rx-vectors, stroke-style, config) = {
  // Chen notation uses only the plain line; no endpoint marks.
}

/// Draw EBNF notation with cardinality brackets at both endpoints.
/// Assumes we're inside draw.get-ctx context. Receives pre-computed vectors.
#let _ebnf-notation(rx-vectors, from-card, to-card, stroke-style, config) = {
  if rx-vectors == none { return }

  let (ux, uy, px, py, from-pt, to-pt) = rx-vectors
  let offset = config.endpoint-offset
  let font-size = config.font-size

  // Helper to format cardinality as string [min..max].
  let format-card(card) = {
    let min-str = str(card.min)
    let max-str = str(card.max)
    "[" + min-str + ".." + max-str + "]"
  }

  // Draw bracket at source (from endpoint).
  let src-bracket = format-card(from-card)
  let src-pos = (from-pt.at(0) + px * offset, from-pt.at(1) + py * offset)
  draw.content(src-pos, text(size: font-size * 1em, src-bracket), anchor: "center")

  // Draw bracket at destination (to endpoint).
  let dst-bracket = format-card(to-card)
  let dst-pos = (to-pt.at(0) + px * offset, to-pt.at(1) + py * offset)
  draw.content(dst-pos, text(size: font-size * 1em, dst-bracket), anchor: "center")
}

// ── Public API ─────────────────────────────────────────────────────────────────

/// Draw a cardinality label box with theme-driven styling.
///
/// Parameters:
///   - label (string):         The cardinality text (e.g. "1", "N", "0..N").
///   - pos (array or string):  (x, y) canvas position or CeTZ anchor string.
///   - style (dictionary):     Connector style sub-dict from the active theme.
#let _draw-label-box(label, pos, style) = {
  draw.content(
    pos,
    box(
      fill:    style.label-fill,
      inset:   style.label-box-inset,
      radius:  style.label-box-radius,
      text(
        weight: style.label-weight,
        size:   style.label-size * 1em,
        fill:   style.label-text-fill,
        label,
      ),
    ),
    anchor: "center",
  )
}

/// Draw a cardinality label at a given canvas position (backward-compatible public API).
///
/// Parameters:
///   - label (string):         The cardinality text (e.g. "1", "N", "0..N").
///   - pos (array or string):  (x, y) canvas position or CeTZ anchor string.
///   - style (dictionary):     Connector style sub-dict from the active theme.
#let cardinality-label(label, pos, style) = {
  _draw-label-box(label, pos, style)
}

/// Draws a line between two ERD elements with optional cardinality notation.
///
/// Parameters:
///   - from (string):            Source element key.
///   - to (string):              Target element key.
///   - label (string):           Cardinality label ("1", "N", "M", "0..1", etc.).
///   - label-pos (float):        0.0–1.0 position along the line. Default: 0.85.
///   - notation (string):        "chen" | "crow" | "uml" | "ebnf". Default: "chen".
///   - from-anchor (string):     Override source anchor. Default: "center".
///   - to-anchor (string):       Override target anchor. Default: "center".
///   - from-cardinality (dict):  For EBNF notation: (min: 0|1|"*", max: 0|1|"*"|number).
///   - to-cardinality (dict):    For EBNF notation: (min: 0|1|"*", max: 0|1|"*"|number).
///   - style (dictionary):       Per-element style overrides merged over the active theme.
///   - theme (dictionary):       Active theme (passed in by `erd()`). Default: default-theme.
#let connector(
  from,
  to,
  label:           none,
  label-pos:       0.85,
  notation:        "chen",
  from-anchor:     none,
  to-anchor:       none,
  from-cardinality: none,
  to-cardinality:   none,
  style:           (:),
  theme:           default-theme,
) = {
  // ── Validation ──────────────────────────────────────────────────────────
  assert(
    notation in ("chen", "crow", "uml", "ebnf"),
    message: "connector: `notation` must be one of \"chen\", \"crow\", \"uml\", or \"ebnf\", got: " + notation,
  )
  assert(
    label-pos >= 0.0 and label-pos <= 1.0,
    message: "connector: `label-pos` must be between 0.0 and 1.0, got: " + str(label-pos),
  )

  if notation == "ebnf" {
    assert(
      from-cardinality != none and to-cardinality != none,
      message: "connector: EBNF notation requires both `from-cardinality` and `to-cardinality` parameters",
    )
  }

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

    // ── Main line ──────────────────────────────────────────────────────────
    draw.line(src, dst, stroke: s.stroke)

    // ── Compute line vectors for notation marks ─────────────────────────────
    let (_, src-pt)   = cetz-coord.resolve(ctx, src)
    let (_, dst-pt)   = cetz-coord.resolve(ctx, dst)
    let rx-vectors = _compute-vectors-from-points(src-pt, dst-pt)

    // ── Notation dispatch ───────────────────────────────────────────────────
    if notation == "crow" {
      _crow-foot(rx-vectors, s.stroke, s.crow)
    } else if notation == "uml" {
      _uml-arrow(rx-vectors, s.stroke, s.uml)
    } else if notation == "ebnf" {
      _ebnf-notation(rx-vectors, from-cardinality, to-cardinality, s.stroke, s.ebnf)
    }
    // Chen notation requires no explicit handling (just the plain line above)

    // ── Cardinality label ──────────────────────────────────────────────────
    if label != none {
      let lp = clamp(label-pos, 0.0, 1.0)

      // Smart label positioning: avoid overlap with notation marks.
      // If auto-position is enabled and notation has marks near endpoints,
      // adjust label to safe middle zone if currently positioned too close.
      if s.label-auto-position and notation in ("crow", "ebnf") {
        let safe-margin = 0.25  // Safe distance from endpoints (0-1 scale)
        if lp < safe-margin or lp > (1.0 - safe-margin) {
          lp = 0.5  // Move to middle of line
        }
      }

      _draw-label-box(
        label,
        (src, lp, dst),
        s,
      )
    }
  })
}
