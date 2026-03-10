// examples/basic.typ
// Demonstrates all three README examples in one compilable file.

#import "../lib.typ": *

// ── Page settings ─────────────────────────────────────────────────────────────
#set page(width: 200mm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 10pt)

= typst-erd Examples

== Example 1 — Simple Two-Entity ERD (Chen notation)

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

== Example 2 — Many-to-Many with Crow's Foot notation

#erd(width: 140mm, {
  entity("Student", (0, 0),
    attributes: ("StudentID [PK]", "Name", "GPA"))

  entity("Course", (8, 0),
    attributes: ("CourseID [PK]", "Title", "Credits"))

  relationship("enrolls", (4, 0))

  connector("Student", "enrolls", label: "0..N", notation: "crow")
  connector("enrolls", "Course",  label: "0..N", notation: "crow")

  attribute("Grade",      (4, -2.5), entity-key: "enrolls")
  attribute("EnrollDate", (4,  2.5), entity-key: "enrolls")
})

== Example 3 — Custom Theme

#let my-theme = erd-theme(
  entity:       (header-fill: eastern, header-text: white),
  relationship: (fill: yellow.lighten(70%), stroke: 1.5pt + yellow.darken(30%)),
)

#erd({
  entity("Product", (0, 0),
    attributes: ("ProductID [PK]", "Name", "Price"),
    theme: my-theme)

  entity("Category", (6, 0),
    attributes: ("CategoryID [PK]", "Name"),
    theme: my-theme)

  relationship("belongs_to", (3, 0), theme: my-theme)

  connector("Product", "belongs_to", label: "N", theme: my-theme)
  connector("belongs_to", "Category", label: "1", theme: my-theme)
})

== Example 4 — EBNF Cardinality Notation

#erd(width: 140mm, {
  entity("Product", (0, 0),
    attributes: ("ProductID [PK]", "Name", "Price", "Stock"))

  entity("OrderItem", (7, 0),
    attributes: ("OrderItemID [PK]", "Quantity", "UnitPrice"))

  relationship("contains", (3.5, 0))

  connector("Product", "contains", notation: "ebnf",
    from-cardinality: (min: 1, max: 1),
    to-cardinality: (min: 1, max: "*"))

  connector("contains", "OrderItem", notation: "ebnf",
    from-cardinality: (min: 1, max: "*"),
    to-cardinality: (min: 0, max: "*"))
})
