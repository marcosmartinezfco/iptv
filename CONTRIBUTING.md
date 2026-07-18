# Contributing

## Workflow

All changes land on `main` via a pull request — direct pushes to `main` are blocked by branch
protection. To contribute:

1. Create a feature branch.
2. Make your change, following the coding style below.
3. Open a PR against `main`. Fill out the PR template completely, including the Gen-AI
   disclosure field.
4. CI must pass (build, lint, format check, test) and all review conversations must be
   resolved before the PR can merge.

## Local setup

```bash
brew install swiftlint swiftformat pre-commit
pre-commit install
```

`pre-commit install` enables local git hooks that run `swiftlint`/`swiftformat` on staged files
before each commit — the same checks CI runs, but with faster feedback. CI remains the
authoritative gate either way, so don't worry if you skip this step, but it saves round-trips.

> **Known caveat**: on a machine with only Xcode Command Line Tools installed (no full Xcode),
> `swiftlint` crashes locally with a SourceKit loading error — the same root cause as
> `swift test` being unavailable locally. If you hit this, skip the SwiftLint hook with
> `SKIP=swiftlint git commit ...` and rely on CI (which runs on a full-Xcode runner) to catch
> lint issues. `swiftformat` is unaffected and still runs locally.

## Coding style

Most style is enforced by `swiftlint`/`swiftformat` (see `.swiftlint.yml` / `.swiftformat`) —
run them locally rather than relying on review to catch formatting nits. A few rules worth
calling out explicitly:

- No force unwrapping (`!`), force casting (`as!`), or `try!` in non-test code — handle the
  failure case explicitly instead.
- Keep functions and types small and focused; the lint config's length/complexity warnings are
  a signal to split things up, not a target to squeeze under.
- Don't leave dead code, commented-out code, or speculative abstractions for features that
  don't exist yet — see the project's minimalism guidelines.
- `TODO`s should reference a tracked issue, not stand alone.

## Pull request guidelines

- **Descriptive title, imperative mood** — e.g. "Add channel search filter", not "fixed stuff"
  or "feat: add search".
- **Meaningful description** — explain what the PR does and why, not just what's in the diff.
- **Small and focused** — one logical change per PR. Split unrelated changes into separate PRs
  even if you touched the files together.
- **Tests or manual verification** — describe how you verified the change works (automated
  test, or manual steps if no test target covers it yet).

## Gen-AI disclosure policy

This project is built with heavy AI assistance, and that's fine — but every PR must disclose
it via the pull request template's Gen-AI field, whether or not AI tools were used. If you used
AI assistance:

- Review and understand everything generated before including it — don't blindly trust output.
- Make sure it follows the coding style and guidelines above.
- Run lint/format/build/tests locally (or via the PR's CI run) before requesting review.
- Remove unrelated changes AI tools tend to introduce along the way.
- You're responsible for the code in your PR regardless of how it was produced — be ready to
  explain any part of it.

(Adapted from [Apache Airflow's Gen-AI contribution guidelines](https://github.com/apache/airflow/blob/main/contributing-docs/05_pull_requests.rst).)
