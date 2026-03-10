# typst-erd

**Entity-Relationship Diagram (ERD) drawing package for Typst, powered by [CeTZ](https://github.com/cetz-package/cetz).**

Draw professional ER diagrams directly in your Typst documents using a clean, ergonomic API. Supports Chen notation, crow's foot notation, derived/multivalued attributes, identifying relationships, and fully customisable themes.

---

## Installation

Add to your `typst.toml`:

```toml
[dependencies]
typst-erd = ">=0.1.0"
```

Or use the preview registry import:

```typst
#import "@preview/typst-erd:0.1.0": *
```

---

## Quick Start

```typst
#import "@preview/typst-erd:0.1.0": *

#erd({
  entity("Person", (0, 0), attributes: ("PersonID [PK]", "Name", "Age"))
  entity("Job",    (6, 0), attributes: ("JobID [PK]", "Title"))
  relationship("has", (3, 0))
  connector("Person", "has",  label: "1")
  connector("has",    "Job",  label: "N")
})
```

---

## Examples

### Example 1 — Simple Two-Entity ERD (Chen notation)

```typst
#import "@preview/typst-erd:0.1.0": *

#erd({
  entity("Customer", (0, 0),
    attributes: ("CustomerID [PK]", "Name", "Email", "Phone"))

  entity("Order", (7, 0),
    attributes: ("OrderID [PK]", "OrderDate", "TotalAmount"))

  relationship("places", (3.5, 0))

  connector("Customer", "places", label: "1")
  connector("places", "Order",    label: "N")

  attribute("DateOfBirth", (0, -3.5),
    entity-key: "Customer", derived: true)

  attribute("Phones", (0, 3.5),
    entity-key: "Customer", multivalued: true)
})
```

### Example 2 — Many-to-Many with Crow's Foot notation

```typst
#import "@preview/typst-erd:0.1.0": *

#erd(width: 140mm, {
  entity("Student", (0, 0),
    attributes: ("StudentID [PK]", "Name", "GPA"))

  entity("Course", (8, 0),
    attributes: ("CourseID [PK]", "Title", "Credits"))

  relationship("enrolls", (4, 0), identifying: false)

  connector("Student", "enrolls", label: "0..N", notation: "crow")
  connector("enrolls", "Course",  label: "0..N", notation: "crow")

  attribute("Grade",      (4, -2.5), entity-key: "enrolls")
  attribute("EnrollDate", (4,  2.5), entity-key: "enrolls")
})
```

### Example 3 — Custom Theme

```typst
#import "@preview/typst-erd:0.1.0": *

#let my-theme = erd-theme(
  entity:       (header-fill: eastern, header-text: white),
  relationship: (fill: yellow.lighten(70%), stroke: 1.5pt + yellow.darken(30%)),
)

#erd({
  entity("Product", (0, 0),
    attributes: ("ProductID [PK]", "Name", "Price", "Stock"),
    theme: my-theme)
  entity("Category", (7, 0),
    attributes: ("CategoryID [PK]", "CategoryName"),
    theme: my-theme)
  relationship("belongs_to", (3.5, 0), theme: my-theme)
  connector("Product",      "belongs_to", label: "N", theme: my-theme)
  connector("belongs_to",   "Category",   label: "1", theme: my-theme)
})
```

---

## API Reference

### `erd(width, body)`

Main canvas wrapper. All ERD elements must be placed inside this function with a code block body, for example `#erd({ ... })`.

| Parameter | Type       | Default | Description                              |
|-----------|------------|---------|------------------------------------------|
| `width`   | length     | `100%`  | Canvas width.                            |
| `body`    | content    | —       | Draw calls from `entity()`, `connector()`, etc. |

---

### `entity(name, pos, attributes, width, key, style)`

Draws a named entity box with a filled header and attribute rows.

| Parameter    | Type       | Default | Description                                    |
|--------------|------------|---------|------------------------------------------------|
| `name`       | string     | —       | Entity label (shown in header).                |
| `pos`        | array      | —       | `(x, y)` centre coordinate.                    |
| `attributes` | array      | `()`    | Attribute strings listed below the header.     |
| `width`      | float      | `3`     | Box width in CeTZ units (cm by default).       |
| `key`        | string     | `none`  | Anchor key; defaults to `name`.                |
| `style`      | dictionary | `(:)`   | Per-element style overrides.                   |
| `theme`      | dictionary | `default-theme` | Theme used for this element.         |

**Anchors created:** `<key>.center`, `<key>.north`, `<key>.south`, `<key>.east`, `<key>.west`

---

### `relationship(name, pos, identifying, style)`

Draws a relationship diamond.

| Parameter     | Type       | Default | Description                               |
|---------------|------------|---------|-------------------------------------------|
| `name`        | string     | —       | Label inside the diamond.                 |
| `pos`         | array      | —       | `(x, y)` centre coordinate.               |
| `identifying` | bool       | `false` | Double-bordered diamond if `true`.        |
| `style`       | dictionary | `(:)`   | Per-element style overrides.              |
| `theme`       | dictionary | `default-theme` | Theme used for this element.       |

**Anchors created:** `<name>.center`, `<name>.north`, `<name>.south`, `<name>.east`, `<name>.west`

---

### `attribute(name, pos, entity-key, derived, multivalued, primary-key, style)`

Draws an attribute ellipse with an optional connecting line to a parent element.

| Parameter     | Type       | Default | Description                                           |
|---------------|------------|---------|-------------------------------------------------------|
| `name`        | string     | —       | Attribute label.                                      |
| `pos`         | array      | —       | `(x, y)` centre coordinate.                           |
| `entity-key`  | string     | `none`  | Key of the parent element to draw a line to.          |
| `derived`     | bool       | `false` | Dashed border for derived attributes.                 |
| `multivalued` | bool       | `false` | Double border for multivalued attributes.             |
| `primary-key` | bool       | `false` | Underlined label for primary-key attributes.          |
| `style`       | dictionary | `(:)`   | Per-element style overrides.                          |
| `theme`       | dictionary | `default-theme` | Theme used for this element.               |

---

### `connector(from, to, label, label-pos, notation, from-anchor, to-anchor, style)`

Draws a line between two ERD elements with optional cardinality notation.

| Parameter     | Type       | Default  | Description                                            |
|---------------|------------|----------|--------------------------------------------------------|
| `from`        | string     | —        | Source element key.                                    |
| `to`          | string     | —        | Target element key.                                    |
| `label`       | string     | `none`   | Cardinality label ("1", "N", "0..N", …).               |
| `label-pos`   | float      | `0.85`   | Position along the line (0.0 = source, 1.0 = target). |
| `notation`    | string     | `"chen"` | `"chen"` / `"crow"` / `"uml"`.                        |
| `from-anchor` | string     | `none`   | Override source anchor (e.g. `"east"`).                |
| `to-anchor`   | string     | `none`   | Override target anchor.                                |
| `style`       | dictionary | `(:)`    | Per-element style overrides.                           |
| `theme`       | dictionary | `default-theme` | Theme used for this element.                |

---

### `erd-theme(..overrides)`

Create a custom theme by merging partial overrides into the `default-theme`.

```typst
#let my-theme = erd-theme(
  entity: (
    header-fill: blue.darken(20%),
    header-text: white,
  ),
  connector: (
    stroke: 1pt + gray,
  ),
)
```

Available top-level keys: `entity`, `relationship`, `attribute`, `connector`.

---

## Default Theme

```typst
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
  ),
)
```

---

## License

MIT — see [LICENSE](LICENSE).
