# Next Steps

Open items left after the initial scaffold.

## Loose ends from the build

- **Firefox persistence.** Loaded via `about:debugging`; unloads on browser restart. Fix paths: submit as unlisted to AMO for a signed XPI; or use Developer Edition / ESR with `xpinstall.signatures.required=false`; or `web-ext sign` for self-distribution.
- **Lucide MIT attribution.** `README.md` references Lucide but the actual MIT text isn't shipped. Add `images/LUCIDE_LICENSE` (verbatim MIT) before redistributing.
- **Chrome compatibility unverified.** Manifest and APIs are written cross-browser, only tested on Firefox. Load unpacked in `chrome://extensions` and confirm parity; `host_permissions` may trigger an install warning.
- **AMO cache has no TTL.** `amoIcon:<id>` entries in `browser.storage.local` are written once and never refreshed.

## Possible features (not started)

- Per-row "open options page" (`ExtensionInfo.optionsUrl`).
- Per-row uninstall (`management.uninstall(id)`).
- Sort: enabled-first, recently toggled.
- Groups / profiles (one-click enable a saved set).
- Manual "Clear icon cache" button.

## Broader thread that started this repo

This repo is the first of a planned series — own the code for extensions whose store versions keep getting disabled. Rebuild candidates from prior triage:

- **Genuinely dead / orphaned:** Social Fixer for Facebook, Hello Goodbye, Rewind Reddit, behind!
- **Alive but fragile:** hckr news, Refined Hacker News, Save Image to Downloads
- **Don't rebuild — well maintained:** uBlock Origin Lite, SponsorBlock, Return YouTube Dislike, refined-github, Close Duplicate Tabs

## Privacy note

Each popup open hits `https://addons.mozilla.org/api/v5/addons/addon/<id>/` for any uncached extension, revealing every installed extension's ID to Mozilla. Fine for personal use; document and consider opt-in if ever published.
