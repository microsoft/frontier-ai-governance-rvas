# Dev Container

A ready-to-use development environment for both the **documentation site** and the
**lab takeaway kits**, provisioned with the exact toolchain the CI gates use.

## What you get

| Tool | Provides / CI job it mirrors |
|------|------------------------------|
| Python 3.13 + `mkdocs`, `mkdocs-material`, `pymdown-extensions` | `site-build.yml` (strict build), `mkdocs serve` |
| `ruff` | `lab-lint.yml` → python job |
| PowerShell + `PSScriptAnalyzer` | `lab-lint.yml` → powershell job |
| Azure CLI + Bicep (`bicep`) | `lab-lint.yml` → bicep job |
| `shellcheck` | `lab-lint.yml` → shell job |
| GitHub CLI (`gh`) | ancillary tooling |

## Open it

- **VS Code:** install the *Dev Containers* extension, then **Reopen in Container**.
- **GitHub Codespaces:** **Code ▸ Codespaces ▸ Create codespace**.

The first build runs [`post-create.sh`](./post-create.sh), which installs the
site dependencies and every lab-lint tool.

## Common commands (identical to CI)

```bash
mkdocs serve                                   # live-preview the site at :8000
mkdocs build --strict                          # site-build gate
ruff check labs                                # python lint gate
python labs/s1-identity/pipelines/run_mock.py  # a lab mock-target pipeline
bicep build labs/s3-security-runtime/infra/main.bicep --stdout > /dev/null
pwsh -c "Invoke-ScriptAnalyzer -Path labs -Recurse -Severity Error"
shellcheck labs/**/*.sh
```
