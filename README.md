# Ext Manager

A pinnable Firefox/Chrome (Manifest V3) toolbar popup that lists every installed extension and lets you toggle each one on or off in a single click. Built because the existing managers either lacked a pinnable toolbar button or were broken by Chrome's MV2 deprecation.

Filter rows by name in the search box. Icons are fetched from the [addons.mozilla.org public API](https://addons.mozilla.org/api/v5/addons/addon/) and cached in `browser.storage.local`; extensions not on AMO fall back to a letter avatar.

## Load it

**Firefox** — `about:debugging#/runtime/this-firefox` → "Load Temporary Add-on…" → pick `manifest.json`. Click the puzzle-piece in the toolbar → gear icon next to "Ext Manager" → Pin to Toolbar.

**Chrome** — `chrome://extensions` → enable Developer mode → "Load unpacked" → pick this directory.

## License

[AGPL-3.0](LICENSE). Toolbar icon adapted from [Lucide](https://lucide.dev) (MIT).
