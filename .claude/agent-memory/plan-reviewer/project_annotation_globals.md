---
name: annotation-globals
description: The annotation system relies on several bare global variables that are not in the ES module graph — plans touching context_menu.js or annotation managers must account for these
metadata:
  type: project
---

The annotation subsystem uses bare global variables that are set by legacy Rails-served scripts and are NOT imported via ES modules:

- `window.annotation_manager` — the active annotation manager instance (PdfAnnotationManager, etc.)
- `window.annotation_type` / `annotation_type` — a string constant for the current file type
- `window.ANNOTATION_TYPES` / `ANNOTATION_TYPES` — an object of constants (PDF, CODE, IMAGE, HTML)
- `window.resultComponent` / `resultComponent` — a React ref to the Result component
- `window.submissionFilePanel` / `submissionFilePanel` — a ref to the file panel

**Why:** These are set by legacy code that runs outside the Webpack bundle. `context_menu.js` references them as bare identifiers (not `window.X`) which means they must exist in the JS global scope at call time.

**How to apply:** Any Jest test for `context_menu.js` must set all of these on `global` in `beforeEach`. Any plan that proposes tests for this file without listing these globals as required mocks is incomplete.

**Corollary — ES module functions are not globals:** `pathToNode` is a named export from `app/javascript/Components/Helpers/range_selector.js` and is NOT assigned to `window`. Legacy scripts in `app/assets/javascripts/` cannot call `pathToNode` — they must either receive it as an argument or the calling code must live in `result.jsx` where the import is in scope. Seen in plan for "Allow Annotations Without Prior Region Selection" (2026-05): `synthesize_html_fallback_selection()` was incorrectly placed in `html_annotations.js` where `pathToNode` is unavailable.

**Note — `annotation_manager` is null for HTML files:** When `annotation_type === ANNOTATION_TYPES.HTML`, `window.annotation_manager` is `null`. Any code in `beforeOpen` or elsewhere that calls `window.annotation_manager.getSelection()` crashes for HTML files. Plans that remove this call are fixing a pre-existing bug, not introducing a regression.
