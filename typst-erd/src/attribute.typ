// src/attribute.typ
// Attribute (ellipse) rendering for typst-erd.

#import "@preview/cetz:0.4.2": draw, coordinate as cetz-coord
#import "styles.typ": default-theme
#import "utils.typ": resolve-style, auto-anchor

/// Draws an attribute ellipse connected to a parent entity or relationship.
///
/// Parameters:
///   - name (string):         Attribute label displayed inside the ellipse.
///   - pos (array):           (x, y) CeTZ coordinate for the ellipse centre.
///   - entity-key (string):   Key of the parent element to draw a connecting line to.
///   - derived (bool):        Dashed border for derived attributes. Default: false.
///   - multivalued (bool):    Double border for multivalued attributes. Default: false.
///   - primary-key (bool):    Underlines the label (PK attribute). Default: false.
///   - style (dictionary):    Per-element style overrides merged over the active theme.
///   - theme (dictionary):    Active theme (passed in by `erd()`). Default: default-theme.
///
/// Anchors created:
///   - "<name>.center", "<name>.north", "<name>.south", "<name>.east", "<name>.west"
#let attribute(
  name,
  pos,
  entity-key:  none,
  derived:     false,
  multivalued: false,
  primary-key: false,
  style:       (:),
  theme:       default-theme,
) = {
  let s = resolve-style(theme, "attribute", style)
  let rx = s.rx
  let ry = s.ry

  // Stroke style — dashed for derived attributes.
  let stroke-style = if derived {
    stroke(paint: s.stroke.paint, thickness: s.stroke.thickness, dash: "dashed")
  } else {
    s.stroke
  }

  // Draw connecting line to parent element first (behind the ellipse).
  // Resolve the parent's facing edge anchor so the line stops at its border,
  // not through its centre.
  if entity-key != none {
    draw.get-ctx(ctx => {
      let (_, parent-center) = cetz-coord.resolve(ctx, entity-key + ".center")
      let dir = auto-anchor(parent-center, pos)
      draw.line(
        pos,
        entity-key + "." + dir,
        stroke: theme.connector.stroke,
      )
    })
  }

  draw.group(name: name, {
    // Drop a named anchor at the centre.
    draw.anchor("center", pos)

    // Cardinal anchors.
    draw.anchor("north", (pos.at(0),      pos.at(1) + ry))
    draw.anchor("south", (pos.at(0),      pos.at(1) - ry))
    draw.anchor("east",  (pos.at(0) + rx, pos.at(1)))
    draw.anchor("west",  (pos.at(0) - rx, pos.at(1)))

    // Outer ellipse.
    draw.circle(
      pos,
      radius: (rx, ry),
      fill:   s.fill,
      stroke: stroke-style,
    )

    // Inner ellipse for multivalued attributes (85 % scale).
    if multivalued {
      draw.circle(
        pos,
        radius: (rx * 0.85, ry * 0.85),
        fill:   none,
        stroke: stroke-style,
      )
    }

    // Label — underlined for primary-key attributes.
    let label-content = if primary-key {
      underline(text(size: s.font-size * 1em, name))
    } else {
      text(size: s.font-size * 1em, name)
    }

    draw.content(pos, label-content, anchor: "center")
  })
}
