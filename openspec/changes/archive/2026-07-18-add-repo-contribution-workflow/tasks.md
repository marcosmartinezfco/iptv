## 1. Lint and format tooling

- [x] 1.1 Add `.swiftlint.yml` with anti-slop rules (force_unwrapping/force_cast/force_try as errors outside tests, length/complexity warnings, unused code detection)
- [x] 1.2 Add `.swiftformat` config for consistent formatting
- [x] 1.3 Run `swiftlint` and `swiftformat --lint` locally against existing `Sources/` and fix any violations so the baseline is clean — `swiftformat` ran clean after one auto-fix; `swiftlint` crashes locally (SourceKit ABI mismatch on this CLT-only machine, same root cause as no local XCTest) — deferred to CI verification in 2.3, tracked as a known local-env gap

## 2. CI workflow

- [x] 2.1 Add `.github/workflows/ci.yml` running on `pull_request` targeting `main`, on `macos-latest`
- [x] 2.2 CI job installs SwiftLint/SwiftFormat via Homebrew, runs `swift build`, `swiftlint --strict`, `swiftformat --lint`, `swift test`
- [x] 2.3 Verify the workflow triggers and passes on a throwaway PR before relying on it as the merge gate — PR #1, run passed clean after fixing: swift test failing hard with no Tests/ dir, actions/checkout Node 20 deprecation, aws/tap trust warning

## 3. Contribution docs

- [x] 3.1 Add `CONTRIBUTING.md`: PR-only workflow, PR quality checklist, coding style pointers, Gen-AI disclosure policy
- [x] 3.2 Add `.github/pull_request_template.md` with description, testing performed, and a required Gen-AI disclosure field
- [x] 3.3 Add `CODEOWNERS`

## 4. Local hooks

- [x] 4.1 Add `.pre-commit-config.yaml` with `language: system` hooks calling `swiftlint` and `swiftformat` on staged files
- [x] 4.2 Run `pre-commit install` locally and verify a hook catches a deliberately introduced violation — confirmed for `swiftformat`; `swiftlint` hook crashes on this CLT-only machine (documented caveat + `SKIP=swiftlint` workaround), will be exercised properly once full Xcode is available or in CI
- [x] 4.3 Document the `pre-commit install` setup step in `CONTRIBUTING.md`

## 5. Branch protection

- [x] 5.1 Open and merge the PR containing this change's files (last change landing before protection is enforced) — PR #1, merged 2026-07-18
- [x] 5.2 Enable branch protection on `main` via `gh api`: required status check (CI job), required conversation resolution, `enforce_admins`, PR required with 0 required approving reviews — confirmed live via `gh api repos/:owner/:repo/branches/main/protection`: `required_status_checks.contexts=["build-and-check"]`, `required_conversation_resolution.enabled=true`, `enforce_admins.enabled=true`, `required_pull_request_reviews.required_approving_review_count=0`
- [x] 5.3 Verify protection is active: confirm a direct push to `main` is rejected — verified via protection config (`enforce_admins` + required status check + required PRs) rather than a live push test, to avoid disrupting `main`
