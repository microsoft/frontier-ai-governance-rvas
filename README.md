# Practical Microsoft AI Governance

This repository publishes a 15-session Microsoft AI governance implementation
series. Teams deploy controls, check them in a nonproduction environment, and
keep the reusable configuration in source control.

LLMOps runs across the series rather than appearing as a separate session. Sessions 04, 10, 12,
13, and 14 connect model lifecycle, evaluation, observability, controlled release, and fleet
operations.

## Execution environment

Use a working branch and run each guided implementation from its `implementation/` directory.
Install the tools required by the commands you plan to run:

- Azure CLI with Bicep support. Sign in to the approved subscription before Azure work.
- PowerShell 7 for PowerShell-based implementation steps.
- Git, GitHub CLI, and Python 3.12 for the controlled-promotion commands.
- Exchange Online and Security & Compliance PowerShell for the Session 09 audit query.
- The current `apic-extension` when an API Center integration command requires it.

Preflight checks the session-specific command capability, active scope, and configuration. Keep
credentials, tenant and subscription IDs, and runtime values out of the repository.

## Preview locally

The files in `sessions/` are the source for the numbered session guides and slide decks.
Need-based implementation kits live under `modules/` and remain separate from the 15-session
sequence. Root `services.json` supplies the service labels and categories plus the icon filenames
used across the generated site.
Install the pinned build dependency:

```powershell
npm ci
```

After changing a session, optional module, or `services.json`, rebuild the site:

```powershell
npm run build:site
```

GitHub Pages builds link implementation files to the exact commit being published. To test those
links locally, set `SOURCE_REPOSITORY` to `owner/repository` and `SOURCE_REVISION` to a commit SHA
before running the build. `SOURCE_SERVER_URL` defaults to `https://github.com`.

The command prints progress as it renders each slide deck. Then serve the site
from the repository root:

```powershell
py -m http.server 8000 --directory site
```

Open <http://localhost:8000>.

The build writes `site/index.html` and `site/service-map.html`, then replaces `site/sessions/` and
`site/modules/`. It stops when a manifest uses an unknown or repeated service ID, when
`services.json` repeats an ID, or when a registered icon is missing. The GitHub Pages workflow runs
the same command, so these generated files should not be edited by hand.

## Publish with GitHub Pages

The workflow in `.github/workflows/pages.yml` installs the pinned build dependency, rebuilds the
homepage, service map, session pages, and module pages, then publishes `site/`.
It runs on pushes to `master` or `main` and can also be started manually.

For the first deployment, open **Settings > Pages** in the GitHub repository and
set **Source** to **GitHub Actions**. Push the branch or run **Deploy static site
to Pages** from the Actions tab. The deployment URL appears in the workflow's
`github-pages` environment.

## Content source

`PRODUCT.md` defines the program. Each `sessions/*/session.yaml` file records a numbered session;
each `modules/*/module.yaml` file records an optional module. Review time-sensitive licensing,
regional availability, preview status, quotas, and product behavior before production use.
