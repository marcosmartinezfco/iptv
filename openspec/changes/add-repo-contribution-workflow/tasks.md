## 1. Lint and format tooling

- [ ] 1.1 Add `.swiftlint.yml` with anti-slop rules (force_unwrapping/force_cast/force_try as errors outside tests, length/complexity warnings, unused code detection)
- [ ] 1.2 Add `.swiftformat` config for consistent formatting
- [ ] 1.3 Run `swiftlint` and `swiftformat --lint` locally against existing `Sources/` and fix any violations so the baseline is clean

## 2. CI workflow

- [ ] 2.1 Add `.github/workflows/ci.yml` running on `pull_request` targeting `main`, on `macos-latest`
- [ ] 2.2 CI job installs SwiftLint/SwiftFormat via Homebrew, runs `swift build`, `swiftlint --strict`, `swiftformat --lint`, `swift test`
- [ ] 2.3 Verify the workflow triggers and passes on a throwaway PR before relying on it as the merge gate

## 3. Contribution docs

- [ ] 3.1 Add `CONTRIBUTING.md`: PR-only workflow, PR quality checklist, coding style pointers, Gen-AI disclosure policy
- [ ] 3.2 Add `.github/pull_request_template.md` with description, testing performed, and a required Gen-AI disclosure field
- [ ] 3.3 Add `CODEOWNERS`

## 4. Local hooks

- [ ] 4.1 Add `.pre-commit-config.yaml` with `language: system` hooks calling `swiftlint` and `swiftformat` on staged files
- [ ] 4.2 Run `pre-commit install` locally and verify a hook catches a deliberately introduced violation
- [ ] 4.3 Document the `pre-commit install` setup step in `CONTRIBUTING.md`

## 5. Branch protection

- [ ] 5.1 Open and merge the PR containing this change's files (last change landing before protection is enforced)
- [ ] 5.2 Enable branch protection on `main` via `gh api`: required status check (CI job), required conversation resolution, `enforce_admins`, PR required with 0 required approving reviews
- [ ] 5.3 Verify protection is active: confirm a direct push to `main` is rejected
