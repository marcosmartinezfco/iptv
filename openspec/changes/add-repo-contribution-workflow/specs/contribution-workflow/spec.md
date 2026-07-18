## ADDED Requirements

### Requirement: All changes to main land via pull request
The system SHALL reject direct pushes to `main`; all changes SHALL be merged via a pull request.

#### Scenario: Direct push attempted
- **WHEN** a contributor attempts to push a commit directly to `main`
- **THEN** the push SHALL be rejected by branch protection

#### Scenario: Change merged via PR
- **WHEN** a contributor wants to land a change
- **THEN** they SHALL open a pull request from a feature branch targeting `main`

### Requirement: CI must pass before a PR can merge
The system SHALL require the CI status check to pass before a pull request can be merged into `main`.

#### Scenario: CI passes
- **WHEN** a pull request's CI workflow (build, lint, format check, test) completes successfully
- **THEN** the PR becomes mergeable (subject to other required checks)

#### Scenario: CI fails
- **WHEN** a pull request's CI workflow fails
- **THEN** the PR SHALL be blocked from merging until the failure is resolved

### Requirement: All PR conversations must be resolved before merge
The system SHALL require all review conversations on a pull request to be marked resolved before it can be merged.

#### Scenario: Unresolved conversation exists
- **WHEN** a pull request has at least one unresolved review conversation
- **THEN** the PR SHALL be blocked from merging

### Requirement: Pull requests disclose Gen-AI assistance
The system SHALL require every pull request description to state whether generative AI tools were used to assist in creating the change, via a structured pull request template field.

#### Scenario: PR was AI-assisted
- **WHEN** a contributor opens a PR for a change that generative AI tools helped produce
- **THEN** the PR description SHALL disclose that assistance using the pull request template's Gen-AI disclosure field

#### Scenario: PR was not AI-assisted
- **WHEN** a contributor opens a PR for a change written without generative AI assistance
- **THEN** the PR description SHALL explicitly indicate no Gen-AI assistance was used, rather than leaving the field blank

### Requirement: Contributing guidelines document the workflow and standards
The system SHALL provide a `CONTRIBUTING.md` documenting the PR-only workflow, PR quality expectations (descriptive title, imperative mood, meaningful description, focused/small scope), coding style pointers, and the Gen-AI disclosure policy.

#### Scenario: New contributor reads guidelines
- **WHEN** a contributor opens `CONTRIBUTING.md`
- **THEN** they SHALL find the PR workflow, PR quality expectations, and Gen-AI disclosure policy documented
