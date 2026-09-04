# Practical Microsoft AI Governance

This repository publishes a seven-session enterprise adoption program around Citadel. Upstream
Citadel repositories remain authoritative for the architecture, templates, supported parameters,
and product deployment mechanics. This program helps customer teams choose a bounded path, apply
customer-owned overlays, implement the missing governance controls, and hand the result to its
long-term owners.

The sequence builds the platform foundation, Governance Hub, and Agent Spoke before adding contract
governance, evaluation and threat gates, observability, and controlled promotion. Each session keeps
changes bounded to an approved nonproduction scope and ends with an observable check plus a named
restore or removal owner.

## Where this guide starts

| Upstream Citadel documentation | This program |
| --- | --- |
| Explains the reference architecture and supported implementation options | Selects the customer path and records why it fits |
| Supplies the deployable accelerators and product parameters | Pins a tested version and maps customer decisions into small overlays |
| Documents component behavior | Adds scope checks, approval points, operating ownership, and restore paths |
| Describes individual platform capabilities | Connects hub, spoke, contracts, assurance, operations, and promotion into one adoption sequence |

Use the upstream repositories when you need product mechanics or the complete parameter reference.
Use this program when you need to decide what the customer will deploy, which defaults to reject,
who approves the change, and how the deployed control will operate.

Start with the [Citadel platform architecture](https://github.com/Azure-Samples/foundry-citadel-platform)
for the reference design and implementation links. Return here for the customer adoption sequence.

## Execution environment

Use a working branch and run each guided implementation from its `implementation/` directory.
Install the tools required by the commands you plan to run:

- Azure CLI with Bicep support. Sign in to the approved subscription before Azure work.
- PowerShell 7 for PowerShell-based implementation steps.
- Git, GitHub CLI, and Python 3.12 for the controlled-promotion commands.

Preflight checks the session-specific command capability, active scope, and configuration. Keep
credentials, tenant and subscription IDs, and runtime values out of the repository.

## Preview locally

The files in `sessions/` are the source for the numbered session guides and slide decks.
Need-based implementation kits live under `modules/` and remain separate from the seven-session
sequence. These optional modules include Agent 365 with Purview controls, multi-region recovery,
and delegated access.
Root `services.json` supplies the service labels and categories plus the icon filenames used across
the generated site.
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
homepage, service map, session pages, and module pages, then publishes `site/` to `gh-pages`.
It runs on pushes to `master` or `main`, on pull requests, and manually. Each pull request from
this repository publishes a preview at `pr-<number>/` and updates one bot comment with its link.

For the first deployment, open **Settings > Pages** in the GitHub repository and
set **Source** to **Deploy from a branch**, then select the `gh-pages` branch and
the `/(root)` folder. Push the branch or run **Deploy static site to Pages** from
the Actions tab.

## Content source

`PRODUCT.md` defines the program. Each `sessions/*/session.yaml` file records a numbered session;
each `modules/*/module.yaml` file records an optional module. Review time-sensitive licensing,
regional availability, preview status, quotas, and product behavior before production use.
