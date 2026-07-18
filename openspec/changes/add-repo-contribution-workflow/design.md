## Context

The repo currently has two commits pushed directly to `main` (the initial scaffold and the first OpenSpec proposal) — acceptable for the bootstrap, but that pattern needs to stop before real feature work lands, especially since this project is being built with heavy AI assistance and is public. GitHub Actions is free and unlimited (standard runners) for public repos, and — importantly — the `macos-14`/`macos-15` hosted runners ship with full Xcode, unlike this local machine (Command Line Tools only, no XCTest). That means CI can do things local dev currently can't: run `swift test`, build via `xcodebuild` if we ever add a `.xcodeproj`, etc.

Reference: `apache/airflow`'s contributor docs (`contributing-docs/05_pull_requests.rst`, `08_static_code_checks.rst`). It's a Python project so tooling doesn't transfer (ruff/mypy/prek → SwiftLint/SwiftFormat/GitHub Actions for us), but the *process* patterns do: required static checks before merge, small/focused PRs, a documented PR quality bar that results in automatic draft-conversion rather than silent low-quality merges, and — most relevant here — a mandatory **Gen-AI disclosure** requirement for AI-assisted PRs.

## Goals / Non-Goals

**Goals:**
- No commits land on `main` except via a reviewed, CI-passing PR.
- CI enforces build + lint + format + test on every PR, using free GitHub-hosted macOS runners.
- Concrete, tool-enforced style rules that target common "AI slop" failure modes (unused code, force-unwraps, oversized functions/files, inconsistent formatting) rather than relying on manual review to catch them.
- Explicit, written expectation that AI-assisted contributions are disclosed and reviewed by a human before merge.
- Local pre-commit hooks that mirror the CI lint/format checks, so violations are caught before a PR is even pushed, not just in CI.

**Non-Goals:**
- Multi-reviewer / CODEOWNERS-enforced review requirements — this is currently a single-maintainer repo; branch protection will require the PR+CI gate but not a second human approver yet. Revisit if/when there are other contributors.
- Code coverage tooling (Codecov-equivalent) — no test target exists yet in this slice of the codebase (blocked on `add-catalog-browsing-and-playback` landing first); revisit once there's meaningful test surface.

## Decisions

**CI runs on `macos-latest` (GitHub-hosted), not a self-hosted runner.**
Public repos get free unlimited minutes on GitHub-hosted runners, including macOS. No need for self-hosted infrastructure. Alternative considered: skip macOS-specific CI and only lint on `ubuntu-latest` — rejected, since `swift build`/`swift test` for an AVKit-dependent macOS app needs a macOS runner with the right SDKs.

**Lint/format tools: SwiftLint + SwiftFormat, installed via Homebrew in the CI job (not vendored as a SwiftPM plugin).**
Both are the de facto standard for Swift and available via `brew install swiftlint swiftformat` on GitHub's macOS runners without extra setup. A SwiftPM plugin approach was considered (`SwiftLintPlugin`) but adds a `Package.swift` dependency and couples linting to every `swift build` invocation, which is slower for local dev; a separate CI step is simpler and keeps `Package.swift` dependency-free per the `add-catalog-browsing-and-playback` design.

**Style rules enforced by SwiftLint config target "AI slop" patterns specifically:** disallow `force_unwrapping`/`force_cast`/`force_try` outside test targets, cap `function_body_length`/`type_body_length`/`file_length`/`cyclomatic_complexity`, flag unused imports/declarations, require `TODO`s to reference an issue.
These are the concrete, automatable proxies for the qualitative problems AI-assisted code tends to introduce: force-unwrap everywhere instead of proper error handling, sprawling functions from "just make it work" generation passes, dead code left behind from abandoned approaches, unactionable TODOs.

**Gen-AI disclosure is a required PR template field, not just a CONTRIBUTING.md suggestion.**
Airflow makes this a written policy but relies on the PR body; we bake a checkbox/field directly into `.github/pull_request_template.md` so it's structurally part of opening a PR, not something a checklist reader can skip. This matters more here than in Airflow's case since most contributions to this repo, at least initially, are AI-assisted by design.

**Branch protection via `gh api repos/:owner/:repo/branches/main/protection` (imperative, run once during apply), not documented as a manual step.**
Since `gh` is already authenticated in this environment, scripting it is more reliable than a manual "go click these settings" instruction that can be forgotten. Required: `required_status_checks` (the CI job), `required_pull_request_reviews` with `required_approving_review_count: 0` (solo maintainer — the PR+CI gate is the enforcement, not a second approver), `enforce_admins: true` so the rule applies even to the repo owner, `required_conversation_resolution: true`.

**Local hooks via the `pre-commit` framework (`.pre-commit-config.yaml`), the same tool Airflow itself uses (as `prek`, a Rust-based drop-in replacement for the same config format).**
`pre-commit` is language-agnostic despite its Python packaging — hooks are configured with `language: system` and just shell out to the already-installed `swiftlint`/`swiftformat` binaries, so it doesn't pull Swift tooling through Python. Installed via `brew install pre-commit`. Alternative considered: a hand-rolled `.git/hooks/pre-commit` shell script — rejected because `pre-commit` gives per-hook file filtering (only lints staged/changed files, matching what Airflow's docs describe), a standard `pre-commit install` onboarding step, and an escape hatch (`git commit --no-verify`) contributors already know from other projects.

## Risks / Trade-offs

- [`enforce_admins: true` means even the maintainer can't push directly to `main` in an emergency] → Acceptable trade-off for a personal project; can be temporarily disabled via `gh api` if ever truly needed, and re-enabled after.
- [`pre-commit install` is an opt-in step a contributor can forget to run, so local hooks aren't guaranteed] → CI remains the actual enforcement point regardless; the local hook is a fast-feedback convenience documented as a required setup step in `CONTRIBUTING.md`, not a substitute for the CI gate.
- [SwiftLint/SwiftFormat rule choices are opinionated and could be too strict early on, causing friction] → Start with a moderate rule set (warnings for style, errors only for the concrete anti-slop rules listed above); tune thresholds later based on real friction rather than guessing upfront.
- [`required_approving_review_count: 0` means CI-passing AI-generated PRs could theoretically self-merge without human eyes] → The PR template's Gen-AI disclosure + "what did you verify" fields exist precisely to force the human-review step to happen in the PR description even without a second reviewer; this is a process control, not a technical one, and is the accepted trade-off for a solo-maintainer repo.

## Migration Plan

1. Land this change's files via a PR against current `main` (the last PR that can be merged before protection is enforced, or protection can be enabled right after this PR merges).
2. Enable branch protection immediately after this PR merges.
3. All subsequent work, including continuing `add-catalog-browsing-and-playback`, proceeds via feature branches + PRs.

## Open Questions

- None blocking. Code coverage tooling is explicitly deferred, not forgotten — track as a follow-up change once there's a meaningful test target.
