# Plan Reviewer Memory Index

- [IIFE Legacy Scripts in Jest](feedback_iife_legacy_scripts.md) — annotation manager files in `app/assets/javascripts/` are IIFEs/window globals, not ES modules; special Jest handling required
- [jsdom Layout Properties are Zero](feedback_jsdom_layout.md) — offsetWidth/offsetHeight/$.fn.width() are always 0 in jsdom; plans testing layout-dependent code need explicit mock strategy
- [mouseOffset=0 Does Not Suppress Default Offset](feedback_mouseoffset_falsy.md) — `getRelativePointForEvent(ev, el, 0)` still applies 10px default because 0 is falsy
- [Annotation System Global Variables](project_annotation_globals.md) — annotation_manager, annotation_type, ANNOTATION_TYPES, resultComponent, submissionFilePanel are bare globals not in ES module graph; annotation_manager is null for HTML files; ES module functions (pathToNode) are not globals
- [PDF Coordinate Space](project_pdf_coordinate_space.md) — PDF coordinates must be stored in inverse-rotated space; any synthetic coordinate source must apply getRotatedCoords(box, 360 - angle)
