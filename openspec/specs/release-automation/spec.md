# release-automation Specification

## Purpose
TBD - created by archiving change add-release-workflow. Update Purpose after archive.
## Requirements
### Requirement: Publish a GitHub Release on version tag push
The system SHALL build a release-configuration `.app` bundle and publish it as a GitHub Release, with the bundle attached as a downloadable artifact, whenever a tag matching `v*` is pushed.

#### Scenario: Version tag pushed
- **WHEN** a tag matching `v*` (e.g. `v0.1.0`) is pushed to the repository
- **THEN** the system SHALL build the app in release configuration, package it as a zipped `.app` bundle, and publish a GitHub Release named after the tag with that zip attached

#### Scenario: Non-version tag or branch push
- **WHEN** a branch is pushed, or a tag not matching `v*` is pushed
- **THEN** the system SHALL NOT trigger the release workflow

### Requirement: Release artifact carries the tagged version
The packaged `.app` bundle's version metadata SHALL reflect the git tag that triggered the release, not a hardcoded value.

#### Scenario: Bundle version matches tag
- **WHEN** tag `v0.1.0` triggers a release build
- **THEN** the resulting `.app` bundle's `CFBundleShortVersionString` SHALL be `0.1.0`

### Requirement: Release notes are auto-generated
The system SHALL generate release notes automatically from pull requests merged since the previous release, without requiring a manually-maintained changelog file.

#### Scenario: Release notes generated
- **WHEN** a GitHub Release is published by the workflow
- **THEN** its description SHALL include a "What's Changed" summary of pull requests merged since the prior release tag

