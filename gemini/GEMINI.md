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
- **Linting & Formatting:** We use **Ruff** (`ruff-check`, `ruff-format`) for
  all Python code.
- **Environment:** We use **uv** for package and lockfile management.
- **Testing:** Prefer `pytest` with Google-style docstrings for public
  functions. **Do not modify the tests unless I say so.**

## Shell Scripting

- **Standards:** Use **ShellCheck** and **shfmt** for all bash scripts.
- **Style:** Prefer `[[ ]]` over `[ ]` and use clear, descriptive variable
  names.
