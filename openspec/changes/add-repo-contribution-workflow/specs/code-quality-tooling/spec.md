## ADDED Requirements

### Requirement: CI builds and tests every pull request
The system SHALL run `swift build` and `swift test` in CI for every pull request targeting `main`, using a GitHub-hosted macOS runner.

#### Scenario: PR opened or updated
- **WHEN** a pull request targeting `main` is opened or its branch is updated
- **THEN** the CI workflow SHALL run `swift build` and `swift test` and report the result as a status check

### Requirement: CI enforces lint and format rules
The system SHALL run `swiftlint --strict` and `swiftformat --lint` in CI for every pull request, failing the check on any violation.

#### Scenario: Lint violation present
- **WHEN** a pull request's changed files violate a `swiftlint` rule configured as an error
- **THEN** the CI lint check SHALL fail

#### Scenario: Formatting violation present
- **WHEN** a pull request's changed files are not formatted per `.swiftformat`
- **THEN** the CI format check SHALL fail

### Requirement: Lint configuration targets common AI-assisted code smells
The system SHALL configure `swiftlint` to flag, as errors outside test targets: force unwrapping, force casting, and force try. The system SHALL configure length/complexity limits (function body length, type body length, file length, cyclomatic complexity) as warnings.

#### Scenario: Force unwrap in non-test code
- **WHEN** non-test source code contains a force unwrap (`!`) flagged by the configured rule
- **THEN** `swiftlint` SHALL report it as an error

#### Scenario: Force unwrap in test code
- **WHEN** test code contains a force unwrap
- **THEN** `swiftlint` SHALL NOT flag it as an error (test code is exempt from this rule)

#### Scenario: Function exceeds configured length
- **WHEN** a function's body exceeds the configured length threshold
- **THEN** `swiftlint` SHALL report a warning
