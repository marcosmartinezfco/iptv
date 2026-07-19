## 1. Extract reusable packaging script

- [x] 1.1 Create `Scripts/package-app.sh`: builds (configurable configuration, default `debug`) and bundles into `.app`, accepts a version string substituted into `Info.plist` via a `__VERSION__` placeholder, does NOT launch it
- [x] 1.2 Refactor `Scripts/run-app.sh` to call `package-app.sh` (given config, `0.0.0-dev` version) then `open` the result
- [x] 1.3 Verify `Scripts/run-app.sh`/`package-app.sh` still work for local dev — confirmed the packaged bundle builds correctly and `CFBundleShortVersionString` substitutes as expected; fullscreen re-verified manually in the prior change

## 2. Release workflow

- [x] 2.1 Add `.github/workflows/release.yml` triggered on `push: tags: ['v*']`
- [x] 2.2 Workflow builds release config, packages via `Scripts/package-app.sh` with the tag (stripped of `v`) as version
- [x] 2.3 Zip the `.app` with `ditto` (preserves bundle metadata correctly, unlike plain `zip`)
- [x] 2.4 Publish a GitHub Release via the tag, attaching the zip, with `generate_release_notes: true`

## 3. Documentation

- [x] 3.1 Document the release process in README (how to cut a release: tag + push)

## 4. First release

- [ ] 4.1 Merge this change
- [ ] 4.2 Tag and push `v0.1.0`
- [ ] 4.3 Verify the workflow runs and the release is published with the artifact attached

## 5. Verification

- [x] 5.1 `swift build` and `swiftformat --lint` pass
- [x] 5.2 `openspec validate add-release-workflow --strict` passes
