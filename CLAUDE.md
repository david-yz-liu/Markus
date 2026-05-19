# MarkUs – Claude Code notes

## Development environment

All commands run inside Docker:

```bash
docker compose run --rm rails <cmd>
```

Examples:
```bash
docker compose run --rm rails npm install
docker compose run --rm rails node_modules/.bin/webpack --config webpack.production.js
docker compose run --rm rails bundle exec rspec spec/path/to/spec.rb
docker compose run --rm rails npx jest path/to/test
```

Use `node_modules/.bin/webpack` directly rather than `npx webpack` — the latter triggers the CSS watcher via npm scripts and blocks.

## JavaScript assets

- Bundler: **Webpack 5** (`webpack.common.js`, `webpack.development.js`, `webpack.production.js`)
- JS source: `app/javascript/`
- Built output: `app/assets/builds/`
- CSS/SCSS source: `app/assets/stylesheets/`; built by a separate Sass watcher

To verify changes compile (fast — skips minification):
```bash
docker compose run --rm webpack node_modules/.bin/webpack --config webpack.development.js --no-watch
```

To do a one-shot production build (JS + CSS bundled together, slow):
```bash
docker compose run --rm webpack node_modules/.bin/webpack --config webpack.production.js --no-watch
```

**Always use the `webpack` service (not `rails`) and pass `--no-watch`** — using the `rails` service or omitting `--no-watch` enables watch mode and the process never terminates.

## JS tests

```bash
docker compose run --rm rails npx jest                  # all JS tests
docker compose run --rm rails npx jest path/to/test     # specific file
```

## Jest testing conventions

Test files live in `app/javascript/Components/__tests__/` and match `**/__tests__/*.test.[jt]s?(x)` (see `jest.config.js`).

### Annotation modules

Annotation-related JavaScript has been migrated to ES modules bundled with webpack. Files are located at `app/javascript/common/annotations/` and include:
- `PdfAnnotationManager` (from `pdf_annotation_manager.js`)
- `AbstractAnnotationManager` (from `annotation_manager.js`)
- Supporting modules for text, image, HTML annotations, etc.

Import them as ES modules:
```js
import { PdfAnnotationManager } from "../../../common/annotations/pdf_annotation_manager";
```

Some bare globals (`annotation_type`, `ANNOTATION_TYPES`, `annotation_manager`) may still be set on `window` at runtime for legacy compatibility. In Jest tests, set them manually in `beforeEach` if needed:

```js
global.ANNOTATION_TYPES = {CODE: 0, IMAGE: 1, PDF: 2, HTML: 3};
global.annotation_type  = global.ANNOTATION_TYPES.PDF;
window.annotation_manager = new PdfAnnotationManager(false);
```

`I18n` and `$`/`jQuery` are already available via `jest_env_setup.js`.

### Mocking jQuery plugins (e.g. `$.fn.contextmenu`)

jQuery UI plugins used in production code (like `ui-contextmenu`) are available as npm dependencies but may need mocking for test isolation. Capture the options object by spying before calling the setup function:

```js
let capturedOptions;
jest.spyOn($.fn, "contextmenu").mockImplementation(function(opts) {
  if (typeof opts === "object") capturedOptions = opts;
  return this;
});
```

Then invoke handlers directly: `capturedOptions.beforeOpen(fakeEvent, fakeUi)`.

## pdfjs-dist

- Imported globally in `app/javascript/application_webpack.js` as `window.pdfjs` and `window.pdfjsViewer`
- Worker bundle is a separate webpack entry (`"pdf.worker": "pdfjs-dist/build/pdf.worker.mjs"`)
- Worker URL wired up at request time in `app/views/layouts/_pdfjs_config.html.erb` via Rails `asset_path`
- MarkUs-specific pdfjs CSS overrides live in `app/assets/stylesheets/common/pdfjs_custom.scss`
