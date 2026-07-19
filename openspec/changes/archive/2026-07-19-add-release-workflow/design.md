## Context

`Scripts/run-app.sh` already builds and bundles a `.app` for local dev/testing, but it always launches it via `open` — not usable headlessly in CI. There's no versioning story: `Supporting/Info.plist` has hardcoded `CFBundleShortVersionString`/`CFBundleVersion` values, and nothing derives them from a release tag.

## Goals / Non-Goals

**Goals:**
- Pushing a `v*` tag produces a GitHub Release with a downloadable, working `.app` (zipped) attached.
- No duplicated bundling logic between local dev (`run-app.sh`) and CI.
- Release notes are generated automatically from merged PRs since the last release, so there's no manual changelog upkeep for now.

**Non-Goals:**
- Code signing / notarization — requires an Apple Developer account, explicitly deferred (confirmed with the app owner).
- Auto-incrementing/enforcing semver — the tag itself is the source of truth; no validation beyond "starts with v".
- Homebrew cask / other distribution channels.

## Decisions

- **Extract packaging into `Scripts/package-app.sh`, taking a version string and output path.** `run-app.sh` becomes a thin wrapper: call `package-app.sh`, then `open` the result. This is the same "single source of truth" principle as the rest of the codebase — one script builds the bundle, however it's invoked.
- **Version comes from the git tag, not a hardcoded file.** The release workflow passes the tag (stripped of its `v` prefix) into `package-app.sh`, which substitutes it into `CFBundleShortVersionString` at packaging time via `sed`, rather than checking in a version number that would immediately drift from the tag that actually shipped it.
- **Release notes: GitHub's built-in auto-generation (`generate_release_notes: true`)**, which compiles a "What's Changed" list from merged PRs since the previous tag. Zero maintenance, and this repo already merges everything through PRs with descriptive titles, so the output is meaningful without any extra authoring.
- **Artifact format: zipped `.app`**, since that's what most users expect to download and double-click-to-unzip; `ditto -c -k --sequesterRsrc --keepParent` (not plain `zip`) to preserve the bundle's resource forks/metadata correctly, which is Apple's documented way to zip `.app` bundles.
- **Workflow trigger: `on: push: tags: ['v*']`**, matching the existing `ci.yml` pattern for GitHub Actions style in this repo (macOS runner, same lint/build steps aren't re-run here — release build assumes the tag was already on a commit that passed `ci.yml` via its PR).

## Risks / Trade-offs

- [Unsigned build triggers Gatekeeper's "unidentified developer" warning] → acceptable per explicit confirmation; documented in the README release section so users know to right-click → Open the first time.
- [Tag pushed to a commit that never went through CI (e.g. tagged directly on main without a PR)] → acceptable for a single-maintainer repo; the release workflow doesn't re-run lint/tests itself since `ci.yml` already gates every PR into `main`, and re-running the full suite again on tag push would be redundant for a repo where every `main` commit already passed CI.
- [Auto-generated release notes are only as good as PR titles] → acceptable; this repo's PR titles have consistently been descriptive so far, and PR bodies still form the linked commit history for anyone wanting depth.

## Migration Plan

No migration — purely additive (new script, new workflow). First real usage is cutting `v0.1.0` once this change merges.
