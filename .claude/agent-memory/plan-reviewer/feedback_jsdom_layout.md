---
name: jsdom-layout-zero
description: jsdom does not perform CSS layout — offsetWidth/offsetHeight/offsetTop are always 0 — plans that test layout-dependent code need explicit mocking strategy
metadata:
  type: feedback
---

`jsdom` (used by Jest in this project) does not perform CSS layout. Any property that depends on layout — `offsetWidth`, `offsetHeight`, `offsetTop`, `offsetLeft`, `getBoundingClientRect()`, `$.fn.width()`, `$.fn.height()`, `$.fn.offset()` — will return 0 or a zero-filled object.

**Why:** This has already surfaced in the PDF annotation manager: `selectionBoxSize()` reads `$box.offsetWidth` and `$box.offsetHeight`, which are always 0 in Jest. After `setSelectionBox(...)` is called, `getSelection()` still returns `false` because `selectionBoxSize()` fails the `HIDE_BOX_THRESHOLD` check.

**How to apply:** When reviewing plans that propose Jest tests for code that reads layout properties, flag that the test must either:
- Mock the layout method (`jest.spyOn(manager, 'selectionBoxSize').mockReturnValue({width: 30, height: 30})`), or
- Inspect internal state (`currentSelection`) directly rather than going through the full `getSelection()` pipeline.

Plans that propose testing layout-dependent code without specifying a mock strategy are incomplete.
