---
name: pdf-coordinate-space
description: PDF annotation coordinates must be stored in inverse-rotated space — plans that bypass getSelection() must apply getRotatedCoords(box, 360 - angle) themselves
metadata:
  type: project
---

`PdfAnnotationManager.getSelection()` always applies `getRotatedCoords(box, 360 - annotation_manager.angle)` before returning coordinates. `renderAnnotation()` later applies `getRotatedCoords(range, this.angle)` when drawing. This round-trip means stored coordinates must be in "inverse-rotated" form.

**Why:** Any code path that synthesizes annotation coordinates and bypasses `getSelection()` must apply the same `getRotatedCoords(box, 360 - this.angle)` correction. Failing to do so results in misplaced annotations on rotated PDFs. At 0° rotation the omission is invisible; at 90° a top-left fallback ({0,0,1000,1000}) renders at the far right instead.

**How to apply:** When reviewing plans that add `getFallbackSelection()` or other coordinate-synthesizing methods to `PdfAnnotationManager`, verify that the returned value passes through `getRotatedCoords(box, 360 - this.angle)`. Note that `getRotatedCoords` is a closure-private function inside `pdf_annotation_manager.js`'s IIFE, accessible to methods defined inside the same IIFE.

**COORDINATE_MULTIPLIER = 100000.** Percentage coordinates (0–1.0) are stored as integers scaled by 100000. A 1% square at top-left = `{x1:0, y1:0, x2:1000, y2:1000}`.
