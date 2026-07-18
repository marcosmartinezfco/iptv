## Why

The repo is public and will take AI-assisted contributions (this project is being built largely with Claude Code). Without enforced process, that combination reliably produces "AI slop": unreviewed generated code merged straight to `main`, inconsistent style, silent regressions. GitHub gives public repos free unlimited Actions minutes on hosted runners — including macOS runners with full Xcode preinstalled, which resolves the local dev gap (this machine only has Command Line Tools, so tests can't run locally yet, but they can run in CI). We should require every change to go through a PR gated on CI before it reaches `main`, and document explicit standards for AI-assisted contributions, before more feature work lands.

Researched `apache/airflow`'s contributor docs for a proven open-source reference (Python project, but the *process* patterns transfer): required static checks before merge, small/focused PRs, mandatory disclosure when a PR was AI-assisted, PR quality criteria that get a PR converted to draft rather than silently merged, and locally-runnable pre-commit-style hooks that mirror what CI checks.

## What Changes

- Add a GitHub Actions workflow (`.github/workflows/ci.yml`) that runs on every PR targeting `main`: `swift build`, `swiftlint --strict`, `swiftformat --lint`, and `swift test` (macOS-hosted runner has full Xcode, so this also gives us test execution we currently can't do locally).
- Add `.swiftlint.yml` and `.swiftformat` configs codifying concrete anti-slop rules (complexity/length limits, no force-unwrap/force-cast in non-test code, no unused code, consistent formatting) so style is enforced by tooling, not review nitpicking.
- Add `CONTRIBUTING.md` documenting the PR-only workflow, PR quality criteria, coding style pointers, and a **mandatory Gen-AI disclosure requirement** for any AI-assisted PR (adapted from Airflow's Gen-AI contribution policy).
- Add `.github/pull_request_template.md` with a checklist (description, testing performed, static checks pass, Gen-AI disclosure) so the disclosure requirement is structurally hard to skip.
- Add `CODEOWNERS` (single owner for now).
- Configure branch protection on `main` via `gh api`: require PR before merging, require the CI status check to pass, require conversation resolution before merging. No direct pushes to `main`.
- **BREAKING**: after this lands, direct pushes to `main` will be rejected — all further work (including the in-flight `add-catalog-browsing-and-playback` change) must go through a PR.

## Capabilities

### New Capabilities
- `contribution-workflow`: PR-only process, required CI gate, branch protection, PR template, contributing guidelines, Gen-AI disclosure requirement.
- `code-quality-tooling`: SwiftLint/SwiftFormat configuration enforcing style/complexity rules, wired into both CI and local usage.

### Modified Capabilities
(none — no existing specs affected)

## Impact

- Affected: repo root (`CONTRIBUTING.md`, `CODEOWNERS`, `.swiftlint.yml`, `.swiftformat`), `.github/workflows/ci.yml`, `.github/pull_request_template.md`.
- GitHub repo settings: branch protection rule added on `main` (a shared setting change, not just code).
- Local dev: `swiftlint`/`swiftformat` now expected tools (installed via Homebrew); no git hook manager introduced yet (no `pre-commit`/`prek` equivalent set up in this change — noted as a follow-up in design.md).
- Process impact: from this point forward, changes land via PR + CI, not direct commits to `main`.
