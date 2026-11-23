# Setup

| Folder | What it holds |
| --- | --- |
| [`linux/`](./linux/) | Global files for `~` with `install.sh`, and project files to copy into a repository |
| [`mac/`](./mac/) | The same for macOS |
| [`windows/`](./windows/) | The same for Windows, with PowerShell hooks and `install.ps1` |
| [`web/`](./web/) | The instruction set to paste into claude.ai (web, desktop and mobile apps) |
| [`tests/`](./tests/) | `hooks.test.sh`, which pipes sample inputs through the hooks of any `project/` or global `hooks/` folder |

Install the global files once per machine, copy the project files into each repository, and paste the web instructions into claude.ai. Each folder's README has the steps.
