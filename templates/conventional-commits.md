# Conventional Commits v1.0.0

Source: https://www.conventionalcommits.org/en/v1.0.0/
License: Creative Commons - CC BY 3.0

## Format

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

## Specification

1. Commits MUST be prefixed with a type (noun: `feat`, `fix`, etc.), followed by OPTIONAL scope, OPTIONAL `!`, and REQUIRED terminal colon and space.
2. `feat` MUST be used when a commit adds a new feature (correlates with SemVer MINOR).
3. `fix` MUST be used when a commit represents a bug fix (correlates with SemVer PATCH).
4. A scope MAY follow the type. Scope MUST be a noun in parentheses describing a section of the codebase, e.g., `fix(parser):`.
5. A description MUST immediately follow the colon and space. It is a short summary of the code changes.
6. A longer body MAY follow the short description. The body MUST begin one blank line after the description.
7. A body is free-form and MAY consist of any number of newline-separated paragraphs.
8. One or more footers MAY follow one blank line after the body. Each footer MUST consist of a word token, followed by `:<space>` or `<space>#` separator, followed by a string value.
9. A footer's token MUST use `-` in place of whitespace (e.g., `Acked-by`, `Reviewed-by`). Exception: `BREAKING CHANGE` MAY be used as a token.
10. A footer's value MAY contain spaces and newlines; parsing terminates at the next valid footer token/separator pair.
11. Breaking changes MUST be indicated in the type/scope prefix (via `!`) or as a footer entry.
12. As a footer: MUST be uppercase `BREAKING CHANGE:`, followed by a space and description.
13. As a prefix: `!` immediately before `:`. If `!` is used, `BREAKING CHANGE:` MAY be omitted from footers; the description SHALL describe the breaking change.
14. Types other than `feat` and `fix` MAY be used (e.g., `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`).
15. Types MUST NOT be treated as case-sensitive, EXCEPT `BREAKING CHANGE` which MUST be uppercase.
16. `BREAKING-CHANGE` MUST be synonymous with `BREAKING CHANGE` when used as a footer token.

## SemVer Mapping

| Type | SemVer |
|------|--------|
| `fix` | PATCH |
| `feat` | MINOR |
| `BREAKING CHANGE` (any type) | MAJOR |
