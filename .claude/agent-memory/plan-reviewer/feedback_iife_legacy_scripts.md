---
name: iife-legacy-scripts-jest
description: Legacy JS files in app/assets/javascripts/ use IIFEs and assign to window globals — they are not ES modules and require special handling in Jest
metadata:
  type: feedback
---

Several annotation-related JS files (`pdf_annotation_manager.js`, `annotation_manager.js`, etc.) live in `app/assets/javascripts/Annotations/` and are wrapped in IIFEs that export to `window` (e.g., `window.PdfAnnotationManager`). They are NOT ES modules.

**Why:** These are legacy scripts that predate the Webpack/ES module migration. The React frontend in `app/javascript/` is ES module-based, but these annotation managers are loaded as globals.

**How to apply:** When reviewing plans that propose Jest tests for these files, flag that:
1. The file must be required for side effects (`require(...)`) rather than imported with named exports.
2. Private helper functions inside the IIFE (e.g., `getRelativePointForEvent`) cannot be mocked or accessed from outside — tests must go through the public class methods.
3. Global dependencies (`ANNOTATION_TYPES`, `resultComponent`, `annotation_type`, `I18n`, `$`) must be set on `global` in `beforeEach`.
