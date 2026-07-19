## Why

The app currently has no way to distribute a build to anyone but the person running `swift build` from source. There's no release process at all — no packaged artifact, no versioning, no changelog. A tag-triggered CI workflow that builds, packages, and publishes a GitHub Release gives the project a repeatable, reviewable release process instead of ad-hoc manual builds.

## What Changes

- Add a reusable packaging script that builds a release `.app` bundle without launching it (extracted from `Scripts/run-app.sh`'s bundling logic, which continues to build+launch for local dev).
- Add a GitHub Actions workflow that triggers on `v*` tag pushes, builds a release configuration binary, packages it into a zipped `.app` bundle, and publishes a GitHub Release with that artifact attached and auto-generated release notes.
- Cut and push the `v0.1.0` tag once the workflow is merged, producing the first real release.
- Document the release process (how to cut a release) in the README.

## Capabilities

### New Capabilities
- `release-automation`: packaging a release build and publishing it as a GitHub Release when a version tag is pushed.

### Modified Capabilities
(none)

## Impact

- `Scripts/package-app.sh` — new: builds and bundles the `.app` without launching it, reusable by both local dev and CI
- `Scripts/run-app.sh` — refactored to call `package-app.sh` then `open` the result
- `.github/workflows/release.yml` — new: tag-triggered build/package/publish workflow
- `README.md` — document the release process
