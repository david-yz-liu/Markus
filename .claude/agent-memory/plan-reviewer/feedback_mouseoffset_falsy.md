---
name: mouseoffset-falsy-zero
description: getRelativePointForEvent uses `mouseOffset || MOUSE_OFFSET` — passing 0 does NOT suppress the default 10px offset because 0 is falsy
metadata:
  type: feedback
---

In `pdf_annotation_manager.js`, `getRelativePointForEvent` computes:

```js
let x = eventOrTouch.pageX - offset.left - (mouseOffset || MOUSE_OFFSET);
```

Passing `mouseOffset = 0` does **not** zero out the offset — it falls back to `MOUSE_OFFSET` (10) because `0` is falsy.

**Why:** This is a subtle JavaScript truthy/falsy trap. The touch handlers pass `undefined` to get the default; the mouse handlers pass nothing. Passing `0` silently gets the default.

**How to apply:** Flag any plan that passes `0` as the third argument to `getRelativePointForEvent` expecting to suppress the cursor offset. The caller either accepts the 10px offset (pass nothing or `undefined`) or must compute coordinates manually without calling this helper.
