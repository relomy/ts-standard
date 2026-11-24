# ts-standard

Shared TypeScript configuration: a strict tsconfig base, an oxlint base and a
prettier config, plus one small option-free oxlint rule
(`require-disable-reason.js`). There is no build, bin, shared check or ratchet
in this package.

All rights reserved. This repository is public so it can be installed without
credentials, but it carries no license and grants no open-source rights.
Contributions are not accepted.

The package is private and is never published to npm. (The unscoped
`ts-standard` name on npm belongs to an unrelated project.)

## Contents

- `tsconfig.json`: the strict options common to the consumer repos. No
  `include` or `files`; the consumer sets those.
- `oxlintrc.json`: the oxlint base (rules below).
- `require-disable-reason.js`: the oxlint JS plugin the base loads. It needs
  no consumer setup beyond extending the base.
- `prettier.json`: prettier options pinned to current behavior, including
  `trailingComma: "all"`.

## Install

Install as a git dependency pinned to a tag. The lockfile pins the commit.
Upgrades are manual tag bumps.

```
npm install --save-dev "github:relomy/ts-standard#<tag>"
```

Use `npm ci --ignore-scripts`; the package needs no build. The tools are exact
peer dependencies. List each in the consumer's own `devDependencies` at the
same exact version: `typescript`, `oxlint`, `oxlint-tsgolint`, `prettier`,
`@nkzw/oxlint-config`. A consumer also needs `@types/node` (the tsconfig sets
`types: ["node"]`). oxlint JS plugins are alpha, so each version bump is a
deliberate change.

## Use

tsconfig, by package specifier:

```json
{ "extends": "ts-standard/tsconfig.json", "include": ["scripts/**/*.ts"] }
```

prettier, by package specifier (in `package.json`):

```json
{ "prettier": "ts-standard/prettier.json" }
```

A repo that needs a different value (for example `trailingComma: "es5"`) uses a
`prettier.config.mjs` that spreads the base and overrides it. Delete any
`.prettierrc`, which takes precedence over the `package.json` key.

oxlint, by relative path (oxlint `extends` accepts only file paths):

```json
{
  "extends": ["./node_modules/ts-standard/oxlintrc.json"],
  "plugins": ["eslint", "typescript", "import", "node", "oxc"],
  "env": { "builtin": true, "node": true }
}
```

`plugins` and `env` are not reliably inherited through `extends`, so repeat
them in the consumer. Type-aware rules need `oxlint-tsgolint` and a
`tsconfig.json` discoverable upward from each linted file (tsgolint ignores
`--tsconfig`). The `@nkzw/oxlint-config` plugin resolves by package specifier,
so the consumer must list it at the root.

A consumer's own `rules` override the base.

## oxlint base

- `correctness`, `suspicious` and `perf` are all errors.
- Type-aware linting is on. Every type-aware rule outside the five below is
  explicitly off in the base (enabling them is out of scope and adds many
  diagnostics). The five `typescript/no-unsafe-{argument,assignment,call,member-access,return}`
  are errors for `**/*.ts`.
- `eslint/max-lines` is 300 (blank and comment lines count).
- The nkzw `quality/*` anti-slop plugin is wired in. Any rule with hits in
  either consumer repo is off; rules with no hits are errors.

### Anti-slop rules

Hits scanned over the whole of each repo (repo A, repo B, the first two consumers) on
2026-11-24.

| rule                                         | repo A | repo B | base  |
| -------------------------------------------- | ------ | ------ | ----- |
| `quality/no-conditional-empty-object-spread` | 0      | 156    | off   |
| `quality/no-unknown-returns`                 | 5      | 24     | off   |
| `quality/no-known-value-widening`            | 2      | 20     | off   |
| `quality/no-unsafe-dictionary-type`          | 2      | 20     | off   |
| `quality/no-object-parameters`               | 0      | 15     | off   |
| `quality/no-array-filter-map`                | 0      | 14     | off   |
| `quality/no-chained-type-assertions`         | 0      | 3      | off   |
| `quality/no-reflect-get`                     | 0      | 1      | off   |
| `quality/no-reduce-accumulator-copy`         | 0      | 0      | error |
| `quality/no-reflect-apply`                   | 0      | 0      | error |
| `quality/no-unknown-type-aliases`            | 0      | 0      | error |
| `quality/no-widen-then-assert`               | 0      | 0      | error |

## Adoption guidance

- Fix straightforward violations. Grandfather only larger backlogs.
- Prefer a file-level exemption (an oxlint `overrides` entry listing files)
  over turning a rule off repo-wide, so the rule stays active everywhere else.
- Exemptions must not grow in ordinary development without justification and
  operator approval. This is a review rule with no mechanism behind it.
- Repos with a ratchet keep it. Shared configuration never replaces a stricter
  local mechanism. A ratchet that reads the local oxlint config directly (it
  does not follow `extends`) must keep its rules, such as `eslint/max-lines`
  and the five type-aware rules, literally in the local file.
- Every lint-disable comment needs a reason, for example
  `// oxlint-disable-next-line <rule> -- <reason>`. The
  `ts-standard/require-disable-reason` rule enforces this at error for
  `oxlint-disable*` and `eslint-disable*` directives (no native oxlint rule
  does, checked at oxlint 1.95.0). It takes no options.

## Known limit

A grandfathered file can worsen unnoticed. An exemption list is not a
guarantee that the exempted file stays as it was.

## Smoke CI

`.github/workflows/smoke.yml` runs on GitHub-hosted runners only. It checks
that each config loads in a consumer-shaped directory, that a good sample
passes, and that a deliberately bad sample fails lint. A tag is cut only after
it is green.
