#!/usr/bin/env bash
# Provisions every tool the CI gates use, so contributors can validate the site
# and lab kits locally exactly as GitHub Actions does.
set -euo pipefail

echo "==> Installing Python site + lint tooling"
python -m pip install --upgrade pip
pip install -r requirements.txt
pip install ruff

echo "==> Installing shellcheck (lab-lint: shell job)"
# Tolerate transient/third-party apt source errors during update; the install
# step will still fail loudly if shellcheck itself cannot be fetched.
sudo apt-get update -y || true
sudo apt-get install -y --no-install-recommends shellcheck
sudo rm -rf /var/lib/apt/lists/*

echo "==> Installing Bicep CLI (lab-lint: bicep job)"
# Azure CLI feature provides 'az'; add the bundled Bicep for `bicep build`.
az bicep install || true
# Also expose a standalone `bicep` on PATH for the CI-equivalent command.
if ! command -v bicep >/dev/null 2>&1; then
  curl -Lo /tmp/bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
  chmod +x /tmp/bicep
  sudo mv /tmp/bicep /usr/local/bin/bicep
fi

echo "==> Installing PSScriptAnalyzer (lab-lint: powershell job)"
pwsh -NoProfile -Command "Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -Repository PSGallery"

echo "==> Verifying toolchain"
python --version
ruff --version
shellcheck --version | head -1
bicep --version || true
pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'

echo "==> Done. Try: mkdocs serve   |   ruff check labs   |   python labs/s1-identity/pipelines/run_mock.py"
