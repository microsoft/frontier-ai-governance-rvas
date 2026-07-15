# Dev Container

A ready-to-use development environment for both the **documentation site** and the
**lab takeaway kits**, provisioned with the exact toolchain the CI gates use.

## What you get

| Tool | Provides / CI job it mirrors |
|------|------------------------------|
| Node 22 (`npm run build`) | `site-build.yml` (site build) |
| Python 3.13 + `ruff` | `lab-lint.yml` → python job |
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
npm run build                                  # build the site data (site-build gate)
npm run test:session-kits                      # delivery-kit structure gate
python3 -m http.server -d docs 8000            # live-preview the site at :8000
ruff check labs                                # python lint gate
bicep build labs/s6-security-runtime/infra/main.bicep --stdout > /dev/null
pwsh -c "Invoke-ScriptAnalyzer -Path labs -Recurse -Severity Error"
shellcheck labs/**/*.sh
```
