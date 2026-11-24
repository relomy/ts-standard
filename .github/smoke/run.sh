#!/usr/bin/env bash
# Smoke test: each config loads in a consumer-shaped directory, a good sample
# passes, and a deliberately bad sample fails lint. Run from the repo root
# after `npm ci --ignore-scripts`.
set -euo pipefail

root="$(pwd)"
consumer="$root/.github/smoke/consumer"
mkdir -p "$consumer/node_modules"
ln -sfn "$root" "$consumer/node_modules/ts-standard"
ln -sfn "$root/node_modules/@nkzw" "$consumer/node_modules/@nkzw"
ln -sfn "$root/node_modules/@types" "$consumer/node_modules/@types"
ln -sfn "$root/node_modules/oxlint" "$consumer/node_modules/oxlint"
ln -sfn "$root/node_modules/prettier" "$consumer/node_modules/prettier"
ln -sfn "$root/node_modules/typescript" "$consumer/node_modules/typescript"
cd "$consumer"
bin="$root/node_modules/.bin"

echo "tsconfig loads and the good sample typechecks"
"$bin/tsc" --noEmit -p tsconfig.json
"$bin/tsc" --showConfig -p tsconfig.json | grep -q '"noUncheckedIndexedAccess": true'

echo "oxlint base loads and the good sample passes"
"$bin/oxlint" --deny-warnings good.ts

echo "prettier config loads and the good sample is formatted"
"$bin/prettier" --check good.ts
"$bin/prettier" --find-config-path good.ts | grep -q package.json

echo "the bad sample must fail lint"
if out="$("$bin/oxlint" --deny-warnings bad/bad.ts 2>&1)"; then
  echo "bad sample passed lint" >&2
  exit 1
fi
for rule in no-unsafe-member-access no-unsafe-assignment no-reflect-apply; do
  grep -q "$rule" <<<"$out" || { echo "expected $rule in output" >&2; echo "$out" >&2; exit 1; }
done
echo "smoke ok"
