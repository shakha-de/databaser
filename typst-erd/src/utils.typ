// src/utils.typ
// Shared helper functions for typst-erd.

/// Deep-merge two dictionaries (2 levels deep).
/// Values in `b` override corresponding values in `a`.
///
/// Parameters:
///   - a (dictionary): Base dictionary.
///   - b (dictionary): Override dictionary.
///
/// Returns a new merged dictionary without mutating the inputs.
#let dict-merge(a, b) = {
  let result = a
  for (k, v) in b {
    if k in result and type(result.at(k)) == dictionary and type(v) == dictionary {
      result.insert(k, result.at(k) + v)
    } else {
      result.insert(k, v)
    }
  }
  result
}

/// Merge a local per-element `style` override into the relevant sub-dict of `theme`.
///
/// Parameters:
///   - theme (dictionary): The full active theme.
///   - key (string):       One of "entity", "relationship", "attribute", "connector".
///   - overrides (dictionary): Local per-call style overrides.
///
/// Returns the merged style dictionary for that element type.
#let resolve-style(theme, key, overrides) = {
  dict-merge(theme.at(key), overrides)
}

/// Compute the cardinal anchor name on `from` that faces toward `to`,
/// based on the relative (dx, dy) between their centres.
///
/// Parameters:
///   - from-center (array): (x, y) of the source element centre.
///   - to-center (array):   (x, y) of the target element centre.
///
/// Returns one of "east", "west", "north", "south" as a string.
#let auto-anchor(from-center, to-center) = {
  let dx = to-center.at(0) - from-center.at(0)
  let dy = to-center.at(1) - from-center.at(1)
  if calc.abs(dx) > calc.abs(dy) {
    if dx > 0 { "east" } else { "west" }
  } else {
    if dy > 0 { "north" } else { "south" }
  }
}

/// Linearly interpolate between two 2-D points.
///
/// Parameters:
///   - a (array): Start point (x, y).
///   - b (array): End point (x, y).
///   - t (float): Parameter in [0, 1].
///
/// Returns an interpolated (x, y) array.
#let lerp2(a, b, t) = {
  (
    a.at(0) + t * (b.at(0) - a.at(0)),
    a.at(1) + t * (b.at(1) - a.at(1)),
  )
}

/// Clamp a numeric value to [lo, hi].
///
/// Parameters:
///   - v (float): Value to clamp.
///   - lo (float): Lower bound.
///   - hi (float): Upper bound.
#let clamp(v, lo, hi) = {
  if v < lo { lo } else if v > hi { hi } else { v }
}
