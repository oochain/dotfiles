# Global Instructions - Gemini CLI

## Language & Communication

- **Simple English:** English is not my first language. Please use clear,
  straightforward vocabulary and avoid overly complex words or idioms in your
  explanations and comments.

## Learning & Educational Protocol

To help me grow as a developer and maintain my skills, please follow these rules
during our sessions:

- **Incremental Progress:** For complex tasks, break the implementation into
  smaller, logical steps. Don't provide the entire solution at once unless I
  explicitly ask for a "fast-track."
- **Technical Rationale:** After providing code, include a brief "Why this way?"
  section. Explain the specific Python patterns (e.g., decorators, context
  managers, type hints) or architectural choices made.
- **Architectural Mapping:** When adding new features, explain which existing
  files are being modified and how the new code interacts with them. This helps
  me understand how to navigate and extend the repo later.
- **Socratic Method:** Occasionally ask me a question about a specific part of
  the code you generated to ensure I've grasped the core logic.

## Pythonic Standards & Tools

- **Standards:** Follow PEP 8 and modern Python features (like `pathlib` and
  type hints).
- **Environment:** We use **uv** for package and lockfile management.
- **Testing:** Prefer `pytest` with Google-style docstrings for public
  functions. **Do not modify the tests unless I say so.**

## Shell Scripting

- **Style:** Prefer `[[ ]]` over `[ ]` and use clear, descriptive variable
  names.

## Command & Tool Execution Rules

- **No Automatic Git Commands:** Do NOT run git commands (`git status`, `git diff`, `git commit`, `git checkout`, etc.) automatically. The user manages git manually.
- **No Automatic Formatting or Linting:** Do NOT run `ruff`, `black`, `shellcheck`, `shfmt`, `pytest`, or any linters/formatters automatically. The user will run them manually.

## Ubiquitous Language & Shared Knowledge

- **Auto-Maintenance:** Proactively identify and document new domain terms,
  business rules, and architectural patterns into a `UBIQUITOUS_LANGUAGE.md`
  file located in the private memory folder (`~/.gemini/tmp/dotfiles/memory/`).
- **Update Rule:** Automatically update this file when new concepts are
  established or existing ones evolve. This file serves as the "source of truth"
  for the repository's context.
- **Context Loading:** At the start of every session, check this file to align
  with the project's established language.
- **Git Safety:** This file is for persistent context and MUST NOT be committed
  to git unless explicitly requested.

## Coding Style & Conventions

- **Comments:** Avoid using numbered lists (e.g., 1., 2., 3.) in code comments.
  Prefer plain descriptive paragraphs or bullet points if necessary.
