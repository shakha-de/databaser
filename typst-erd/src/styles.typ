// src/styles.typ
// Default theme and style constants for typst-erd.
// All visual configuration lives here — no hard-coded colors in other modules.

/// Default visual theme dictionary.
/// Override individual keys by passing a partial dict to `erd-theme()`.
#let default-theme = (
  entity: (
    header-fill:   rgb("#2c3e50"),
    header-text:   white,
    body-fill:     rgb("#ecf0f1"),
    alt-row-fill:  rgb("#dfe6e9"),
    stroke:        1pt + rgb("#2c3e50"),
    radius:        0.12,
    font-size:     0.35,
    shadow-offset: (0.06, -0.06),
    shadow-fill:   rgb("#00000033"),
    padding:       0.12,
    row-height:    0.5,
    header-height: 0.6,
  ),
  relationship: (
    fill:         rgb("#f39c12").lighten(60%),
    stroke:       1.5pt + rgb("#f39c12"),
    font-size:    0.32,
    label-weight: "bold",
    half-width:   1.0,
    half-height:  0.6,
  ),
  attribute: (
    fill:      rgb("#ffffff"),
    stroke:    1pt + rgb("#7f8c8d"),
    font-size: 0.3,
    rx:        0.7,
    ry:        0.35,
  ),
  connector: (
    stroke:       0.8pt + rgb("#2c3e50"),
    label-size:   0.32,
    label-fill:   rgb("#e74c3c"),
    label-weight: "bold",
    label-text-fill: white,       // text color in label box
    label-box-inset: 2pt,         // padding inside label box
    label-box-radius: 2pt,        // corner radius of label box
    label-auto-position: true,    // auto-adjust position to avoid notation overlap
    crow: (                       // crow's foot notation parameters
      fork-depth: 0.25,
      spread: 0.18,
      bar-offset: 0.35,
    ),
    uml: (                        // UML notation parameters
      depth: 0.22,
      spread: 0.12,
    ),
    ebnf: (                       // EBNF notation parameters
      endpoint-offset: 0.15,
      font-size: 0.25,
    ),
  ),
)

/// Create a theme by merging user overrides into `default-theme`.
///
/// Parameters:
///   - ..overrides (dictionary): Partial theme overrides (same structure as `default-theme`).
///
/// Returns a fully merged theme dictionary.
///
/// Example:
///   #let my-theme = erd-theme(
///     entity: (header-fill: blue),
///     connector: (stroke: 1pt + black),
///   )
#let erd-theme(..overrides) = {
  import "utils.typ": dict-merge
  dict-merge(default-theme, overrides.named())
}
