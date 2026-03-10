// lib.typ
// Public API entry point for typst-erd.

#import "@preview/cetz:0.4.2": canvas
#import "src/entity.typ":       entity       as _entity
#import "src/relationship.typ": relationship as _relationship
#import "src/attribute.typ":    attribute    as _attribute
#import "src/connector.typ":    connector    as _connector, cardinality-label
#import "src/styles.typ":       default-theme, erd-theme

// ── Public element functions ───────────────────────────────────────────────────

/// Draws a named entity box with a filled header and attribute rows.
///
/// Parameters:
///   - name (string):       Entity label shown in the header.
///   - pos (array):         (x, y) CeTZ coordinate for the box centre.
///   - attributes (array):  List of attribute strings shown below the header.
///   - width (float):       Box width in CeTZ units. Default: 3.
///   - key (string):        Optional CeTZ anchor key. Defaults to `name`.
///   - style (dictionary):  Per-element style overrides merged over the active theme.
///   - theme (dictionary):  Theme used for this element. Defaults to `default-theme`.
///
/// Anchors created: "center", "north", "south", "east", "west".
#let entity(
  name,
  pos,
  attributes: (),
  width:      3,
  key:        none,
  style:      (:),
  theme:      default-theme,
) = _entity(
  name,
  pos,
  attributes: attributes,
  width:      width,
  key:        key,
  style:      style,
  theme:      theme,
)

/// Draws a relationship diamond.
///
/// Parameters:
///   - name (string):       Relationship label displayed inside the diamond.
///   - pos (array):         (x, y) CeTZ coordinate for the diamond centre.
///   - identifying (bool):  If true, draws a double-bordered (inner) diamond.
///   - style (dictionary):  Per-element style overrides merged over the active theme.
///   - theme (dictionary):  Theme used for this element. Defaults to `default-theme`.
///
/// Anchors created: "center", "north", "south", "east", "west".
#let relationship(
  name,
  pos,
  identifying: false,
  style:       (:),
  theme:       default-theme,
) = _relationship(
  name,
  pos,
  identifying: identifying,
  style:       style,
  theme:       theme,
)

/// Draws an attribute ellipse connected to a parent entity or relationship.
///
/// Parameters:
///   - name (string):         Attribute label displayed inside the ellipse.
///   - pos (array):           (x, y) CeTZ coordinate for the ellipse centre.
///   - entity-key (string):   Key of the parent element to connect to.
///   - derived (bool):        Dashed border for derived attributes. Default: false.
///   - multivalued (bool):    Double border for multivalued attributes. Default: false.
///   - primary-key (bool):    Underlines the label (PK attribute). Default: false.
///   - style (dictionary):    Per-element style overrides merged over the active theme.
///   - theme (dictionary):    Theme used for this element. Defaults to `default-theme`.
///
/// Anchors created: "center", "north", "south", "east", "west".
#let attribute(
  name,
  pos,
  entity-key:  none,
  derived:     false,
  multivalued: false,
  primary-key: false,
  style:       (:),
  theme:       default-theme,
) = _attribute(
  name,
  pos,
  entity-key:  entity-key,
  derived:     derived,
  multivalued: multivalued,
  primary-key: primary-key,
  style:       style,
  theme:       theme,
)

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
///   - theme (dictionary):     Theme used for this element. Defaults to `default-theme`.
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
) = _connector(
  from,
  to,
  label:       label,
  label-pos:   label-pos,
  notation:    notation,
  from-anchor: from-anchor,
  to-anchor:   to-anchor,
  style:       style,
  theme:       theme,
)

// ── Main canvas wrapper ────────────────────────────────────────────────────────

/// Main ERD canvas wrapper.
/// All ERD elements must be placed inside this function.
///
/// Parameters:
///   - width (length):     Canvas width. Default: 100%.
///   - body (content):     CeTZ draw calls produced by entity(), relationship(), etc.
///
/// Example:
///   #erd({
///     entity("User", (0,0), attributes: ("id [PK]", "name", "email"))
///     entity("Order", (6,0), attributes: ("id [PK]", "date", "total"))
///     relationship("places", (3, 0))
///     connector("User", "places", label: "1")
///     connector("places", "Order", label: "N")
///   })
#let erd(width: 100%, body) = {
  block(width: width, canvas(length: 1cm, body))
}
