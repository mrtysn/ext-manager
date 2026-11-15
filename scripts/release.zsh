#!/bin/zsh
# DESC: Ship the add-on: bump its version, sign it on AMO (unlisted), open it in Firefox to install, commit.
#
# A Firefox release build keeps only signed add-ons across restarts; about:debugging loads are
# temporary. Signing uploads the add-on's files to Mozilla as an unlisted add-on: checked
# automatically, never published. AMO throttles signing (3 a minute, 10 an hour, 24 a day), so run
# this once per finished batch. Keys come from Doppler's firefox-signing project, as for the other add-ons.
#
# Usage:
#   scripts/release.zsh            # 0.1.0 → 0.1.1: sign, open in Firefox (click Add), commit, push
#   scripts/release.zsh --dry-run  # say what it would do, change nothing
#   scripts/release.zsh --no-open  # sign only; print the signed xpi's path

set -euo pipefail

repo=${0:A:h:h}
manifest=$repo/manifest.json

if [[ ${1:-} == -h || ${1:-} == --help ]]; then
  sed -n '4,13p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi
dry=0 no_open=0
[[ ${1:-} == --dry-run ]] && dry=1
[[ ${1:-} == --no-open ]] && no_open=1

if [[ -n $(git -C "$repo" status --porcelain) ]]; then
  print -u2 "the tree has uncommitted changes; commit the batch first"
  exit 1
fi
[[ -x $repo/node_modules/.bin/web-ext ]] || { print -u2 "web-ext is missing: run npm install in $repo"; exit 1 }

current=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$manifest")
next=${current%.*}.$(( ${current##*.} + 1 ))
print "release: $current → $next"
(( dry )) && { print "dry run: nothing changed"; exit 0 }

set_version() { sed -i '' "s/\"version\": \"$1\"/\"version\": \"$2\"/" "$manifest" }
set_version "$current" "$next"

# The add-on's files sit at the repo root, so everything that is not the add-on is left out.
ignore=(README.md NEXT.md LICENSE package.json package-lock.json 'scripts/**' 'node_modules/**' 'web-ext-artifacts/**' .amo-upload-uuid)
if ! (cd "$repo" && doppler run --project firefox-signing --config prd -- \
      "$repo/node_modules/.bin/web-ext" sign --channel unlisted --artifacts-dir "$repo/web-ext-artifacts" \
      --ignore-files $ignore); then
  set_version "$next" "$current"   # a refused signing leaves no version on AMO
  print -u2 "signing failed; the version is back at $current"
  exit 1
fi

xpis=("$repo"/web-ext-artifacts/*-"$next".xpi(N))
(( ${#xpis} )) || { print -u2 "signed, but no $next xpi in web-ext-artifacts"; exit 1 }
xpi=${xpis[1]}
print "signed: $xpi"
(( no_open )) || open -a Firefox "$xpi"

git -C "$repo" add manifest.json
git -C "$repo" commit -qm "ship $next as a signed release"
git -C "$repo" push -q
print "committed and pushed $next"
(( no_open )) && print "open this in Firefox to install it: $xpi"
exit 0
