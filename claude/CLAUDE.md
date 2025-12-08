# Instructions

Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
Only support backwards compatilibilty if instructed to do so by the User.

## Documentation and Architecture Work

When working on architecture documents or design documentation:
- Include verbatim quotes from user input when they provide valuable context, explain reasoning behind decisions, or offer key insights that led to design choices
- Use blockquote format (> quote text) to capture exact user language
- Focus on quotes that serve as historical context and rationale, not just any user input
- Write architecture documents in present tense, describing the system as it is being designed, not as an evolving product over time

## Python

- When expecting an exception or result with a human-readable string, don't verify the string contents in tests - verify the string is set, but not its contents (allows changing language without updating tests)
- To keep list comprehensions on multiple lines without `fmt:off`, add a trailing comment (`#`) before `]` to force ruff to format on multiple lines - prefer this when a function/method is being called
- Always put imports at the top of the file unless they cause a circular import
