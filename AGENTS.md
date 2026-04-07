# AGENTS GUIDE FOR THIS REPO

Purpose: brief everything an agent needs to work here without surprises.
Audience: coding agents working locally in this repository.

## Repository Snapshot
- Language: Python 3 (requires >=3.10; `.python-version` pins 3.13).
- Packages: minimal (`yt-dlp`, `imageio-ffmpeg`); packaged with hatchling.
- Entry points: `ExtractAudio` (YouTube MP3 extraction), `Splitter` (MP3 splitter).
- Layout: `src/youtuedownload/main.py` for extraction CLI, `src/splitter/splitter.py` for splitting CLI, `pyproject.toml` for packaging, `install.sh` for pipx-based install script, `README.md` for end-user docs, `JOB_GUIDE.md` and `vibecode.txt` for requirements context.
- Cursor rules: none found (`.cursor/`, `.cursorrules` absent). Copilot rules: none (`.github/copilot-instructions.md` absent).

## Setup and Environments
- Use Python 3.13 (or any 3.10+) with a virtualenv; `.venv/` is ignored. Activate before commands.
- Dependencies come from `pyproject.toml`; install with `pip install -e .` for editable work or `pipx install .` for isolated CLI installation.
- CLI install script: `bash install.sh` handles pipx installation and PATH hints (macOS/Linux).
- FFmpeg is provided via `imageio-ffmpeg.get_ffmpeg_exe()`; no system ffmpeg required but acceptable as fallback for `Splitter`.
- OS targets: macOS and common Linux distros. No Windows-specific support.

## Build / Lint / Test Commands
- Build wheel: `python -m build` (install `build` if missing) or `hatch build` (hatchling backend). Output goes to `dist/`.
- Editable install for local runs: `pip install -e .`.
- Lint: no configured linter. If you add one, prefer `ruff` or `flake8`; document commands in this file when introduced.
- Tests: none present. If you add pytest, run full suite with `python -m pytest`.
- Run a single test (when pytest exists): `python -m pytest tests/test_file.py -k pattern`.
- Smoke checks today: `ExtractAudio --help`, `Splitter -h`, and sample runs against a short video file; ensure these exit 0.

## CLI Usage Cheat Sheet
- Extract audio: `ExtractAudio "<youtube_url>" [-d directory] [-name filename]`.
- Split audio: `Splitter <file.mp3> -c <count>`; `-h` prints usage when args missing.
- Entry-point modules: `python -m youtuedownload.main` mirrors `ExtractAudio`; `python -m splitter.splitter` mirrors `Splitter`.
- Input quoting: wrap URLs with `?` or `&` in quotes to avoid shell globbing (zsh especially).
- Default naming: extraction uses `youtube_YYYYMMDD_HHMMSS.mp3` if no `-name` provided; splitting produces `<basename>_NNN.mp3` in the source directory.

## Repo Expectations (from JOB_GUIDE)
- Plan before coding; clarify ambiguous requirements early.
- Ask questions during planning if anything is unclear; avoid surprises later.
- Run unit and end-to-end tests after coding (today this means CLI smoke runs).
- Update `README.md` with usage changes when behaviors or flags change.

## Coding Style: Imports and Organization
- Order imports stdlib → third-party → local; keep blank line groups (see `main.py` and `splitter.py`).
- Avoid unused imports; keep module-level constants minimal.
- Do not introduce wildcards; import specific functions or modules.
- Keep shebangs only for scripts intended to be executed directly (`splitter.py` has one). Do not duplicate shebangs in library modules.

## Formatting and Structure
- Use 4-space indentation, lowercase with underscores for module and function names.
- Prefer clear, verbose naming over abbreviations (`resolve_output_dir`, `build_ydl_opts`).
- Keep functions small and linear; prefer early exits via `sys.exit` for fatal CLI errors.
- Keep docstrings short; this codebase currently favors descriptive help text instead of extensive docstrings.
- Maintain blank lines between top-level functions as in existing files.

## Typing Guidance
- Use type hints for public functions. Existing code uses `str | None`, `dict`, and `-> None` for side-effect functions.
- Keep runtime type usage light—no heavy validation frameworks in current scope.
- Prefer explicit return annotations even for `main()` functions.

## CLI Argument Handling
- Use `argparse` (as in both CLIs) with clear `prog`, `description`, and explicit help text.
- Provide helpful epilog/examples; preserve Korean copy style used today.
- When adding flags, ensure default behaviors remain backward-compatible.
- Exit with code 0 on help/normal completion; exit 1 on user errors.

## Error Handling
- Use `sys.exit(1)` after printing a concise error message to stderr/stdout; avoid stack traces for user-facing CLI errors.
- Catch `yt_dlp.utils.DownloadError` when downloading; echo the message and exit.
- For filesystem checks, validate existence and type before use (see `resolve_output_dir`).
- For subprocesses, use `check=True` where failure should abort; capture output to avoid noisy stderr unless debugging.

## File and Path Handling
- Use `os.path` functions for normalization and joins; expanduser for user-supplied paths.
- Keep all generated outputs in user-provided directories; do not write inside repo by default.
- When creating filenames, strip extensions before appending `.mp3` to avoid duplicates.

## External Tools
- Prefer `imageio_ffmpeg.get_ffmpeg_exe()` to locate bundled ffmpeg; fall back to common paths only when necessary (see `get_ffmpeg`).
- For YouTube downloads, use `yt_dlp.YoutubeDL` with options configured via `build_ydl_opts` (format `bestaudio/best`, postprocessor `FFmpegExtractAudio` to mp3 192k).
- Keep `quiet` and `no_warnings` aligned with current defaults (both False) unless adding verbose flags.

## Subprocess Practices
- Use `subprocess.run(..., check=True)` for operations expected to succeed; capture output to keep CLI tidy.
- When parsing durations, fall back gracefully if `ffprobe` is missing; mirror the pattern in `get_duration`.
- Avoid long-running background processes; these are single-shot CLIs.

## Logging and Output Style
- Favor plain `print` statements with short Korean messages; match existing tone (`완료`, `오류` prefixes).
- Announce key steps: target URL/file, output directory, progress counts for splitting, and completion.
- Keep progress formatting simple (e.g., `[idx/count] filename (seconds)`).
- Avoid ANSI colors in Python output; colors are limited to `install.sh` only.

## Dependency Management
- Keep runtime dependencies minimal; currently only `yt-dlp` and `imageio-ffmpeg` are required.
- Do not add heavy frameworks without need; prefer stdlib for argparse, os, sys, subprocess.
- If adding dependencies, update `pyproject.toml` and document install commands here.

## Packaging Notes
- Project uses `hatchling`; packages under `src/` are referenced in `[tool.hatch.build.targets.wheel]`.
- Entry points defined in `[project.scripts]` must stay in sync with module paths.
- When bumping version, update `pyproject.toml` and consider tagging releases.

## Testing Approach
- No automated tests exist; add pytest-based tests under `tests/` when you introduce new logic.
- Prefer deterministic fixtures (sample MP3 files or mocked subprocess calls) to avoid network usage in tests.
- For manual checks, run: `ExtractAudio "<url>" -d /tmp` on a short video and `Splitter sample.mp3 -c 2`; verify outputs and exit codes.
- If adding tests, seed them with small test assets tracked via git-lfs or generated on the fly to keep repo light.

## Git and Hygiene
- `.venv/`, build outputs (`dist/`, `*.egg-info`, `__pycache__`) are ignored; keep them untracked.
- Do not commit credentials or `.env` files; none are used now.
- Keep edits ASCII unless reusing existing Korean strings in help text/output.

## When Extending Functionality
- Maintain backward compatibility for CLI flags; avoid renaming existing options.
- Keep user messaging bilingual style consistent (current output is Korean-first).
- Prefer small, composable functions; reuse `resolve_output_dir`, `build_ydl_opts`, and splitting helpers where possible.
- Document any new flag or behavior in `README.md` and update this `AGENTS.md`.

## Operational Notes
- There is no CodeGraph index yet. If you want faster symbol lookups, initialize with `codegraph init -i` from repo root (optional; ask the user if unsure).
- Network access is only needed for `yt-dlp` downloads; other operations are local.
- Long downloads can be slow; consider adding timeout/abort flags only if requested.

## Quick File Map
- `README.md`: user-facing docs for ExtractAudio and Splitter.
- `pyproject.toml`: package metadata, dependencies, entry points.
- `install.sh`: automated pipx install script with OS/Python checks.
- `src/youtuedownload/main.py`: ExtractAudio CLI implementation.
- `src/splitter/splitter.py`: MP3 splitter CLI implementation.
- `JOB_GUIDE.md`: original requirements and workflow expectations.
- `vibecode.txt`: short Splitter prompt reference.
- `main.py` (root): placeholder hello script; not used in packaging.

## How to Ask for Help (for agents)
- If a requirement is unclear, pause and ask a single targeted question with your proposed default.
- Do not ask permission to run obvious commands; run them and report results concisely.
- Keep commits small and purposeful if/when requested; do not amend without explicit approval.

## Ready-Made Snippets
- Single test (after pytest added): `python -m pytest tests/test_main.py -k ExtractAudio`.
- Build and reinstall locally: `python -m build && pip install dist/youtuedownload-*.whl`.
- Editable dev loop: `pip install -e .` then run `ExtractAudio --help` to verify entry points.
- Manual split check: `Splitter example.mp3 -c 3` (expects numbered outputs in same directory).

## Final Reminders
- Keep changes minimal and aligned with existing CLI behavior.
- Favor clarity over cleverness; this is a user-facing utility.
- Update this file when you change commands, style rules, or add tooling.
