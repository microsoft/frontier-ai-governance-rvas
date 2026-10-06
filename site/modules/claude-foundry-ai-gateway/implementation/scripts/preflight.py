#!/usr/bin/env python3
"""Check configured files and live Azure scope without changing service state."""

import argparse
import json
import re
import shutil
import subprocess
import sys
import uuid
import xml.etree.ElementTree as ET
from pathlib import Path
from urllib.parse import urlsplit


FILES = (
    "gateway-inputs.json", "api-policy.xml", "budget-fragment.xml",
    "claude-code-settings.json", "get-entra-token.sh", "get-entra-token.ps1",
)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def azure(*args):
    result = subprocess.run(
        ["az", *args, "--output", "json"], check=True, capture_output=True, text=True
    )
    return json.loads(result.stdout)


def check(directory):
    require(shutil.which("az"), "Azure CLI is required.")
    texts = {}
    for name in FILES:
        path = directory / name
        require(path.is_file(), f"Required file missing: {name}")
        texts[name] = path.read_text(encoding="utf-8")
        unresolved = sorted(set(re.findall(r"__REQUIRED_[A-Z0-9_]+__", texts[name])))
        require(not unresolved, f"{name}: unresolved decisions: {', '.join(unresolved)}")

    inputs = json.loads(texts["gateway-inputs.json"])
    require(inputs["implementationSession"] == "optional-module-claude-foundry-ai-gateway",
            "Unexpected implementationSession marker.")
    for key in ("approvedSubscription", "tenantId", "gatewayApiClientId", "desktopClientId"):
        uuid.UUID(inputs[key])
    require(inputs["gatewayApiClientId"] != inputs["desktopClientId"],
            "Code and Desktop must use different application registrations.")
    for key in ("apimResourceGroup", "apimName", "foundryResourceGroup", "foundryName",
                "gatewayOwner", "identityOwner", "clientOwner", "restoreReference"):
        require(isinstance(inputs[key], str) and inputs[key].strip(), f"Missing {key}.")
    for key in ("hostingApproved", "identityApproved", "budgetsApproved",
                "diagnosticsApproved", "networkApproved"):
        require(inputs[key] is True, f"The responsible owner must approve {key}.")
    require(inputs["networkPath"] in ("direct-apim", "application-gateway", "private"),
            "networkPath must be direct-apim, application-gateway, or private.")
    require(inputs["backendTokenResource"] == "https://ai.azure.com",
            "This policy uses the documented Foundry https://ai.azure.com token resource.")
    require(inputs["foundryRole"] == "Cognitive Services User", "Unexpected Foundry role.")
    base = urlsplit(inputs["gatewayBaseUrl"])
    require(base.scheme == "https" and base.hostname and not base.username
            and not base.password and not base.query and not base.fragment,
            "gatewayBaseUrl must be an HTTPS base URL without credentials or query.")
    require(not inputs["gatewayBaseUrl"].endswith("/"),
            "Use the same base URL without a trailing slash on both clients.")
    require(not base.path.endswith("/v1/messages"), "Use a base URL, not an operation URL.")

    settings = json.loads(texts["claude-code-settings.json"])
    require(settings["env"]["ANTHROPIC_BASE_URL"] == inputs["gatewayBaseUrl"],
            "Code base URL differs from the approved route.")
    require(isinstance(settings["apiKeyHelper"], str) and settings["apiKeyHelper"].strip(),
            "Configure the installed helper command.")
    models = {settings["env"][key] for key in (
        "ANTHROPIC_DEFAULT_SONNET_MODEL", "ANTHROPIC_DEFAULT_OPUS_MODEL",
        "ANTHROPIC_DEFAULT_HAIKU_MODEL",
    )}
    require(settings["env"]["ANTHROPIC_MODEL"] in models,
            "The default model must be one of the configured deployments.")
    require(all(isinstance(model, str) and model and model == model.strip().lower()
                for model in models), "Use exact lowercase deployment names.")

    fragment = ET.fromstring(texts["budget-fragment.xml"])
    require(fragment.tag == "fragment", "Budget file must be an APIM fragment.")
    maps = {item.attrib["name"]: json.loads(item.attrib["value"])
            for item in fragment.findall("set-variable")}
    defaults = maps["defaultModelTokenQuotasJson"]
    overrides = maps["userModelTokenQuotasJson"]
    require(isinstance(defaults, dict) and isinstance(overrides, dict),
            "Budget mappings must be JSON objects.")
    require(set(defaults) == models, "Default budgets must match the managed deployments.")
    for user, mapping in overrides.items():
        require(isinstance(user, str) and user == user.strip().lower() and "@" in user,
                "Override keys must be normalized UPNs.")
        require(isinstance(mapping, dict), "Each user override must be a model-budget object.")
        require(set(mapping) <= models, "An override names an unmanaged deployment.")
    for mapping in [defaults, *overrides.values()]:
        for quota in mapping.values():
            require(type(quota) is int and 0 <= quota <= 2147483647,
                    "Budgets must be nonnegative 32-bit integers; zero blocks a model.")

    policy = ET.fromstring(texts["api-policy.xml"])
    require(policy.tag == "policies", "API policy must have a policies root.")
    validators = policy.findall(".//validate-jwt")
    require(len(validators) == 2, "Expected separate Code and Desktop validators.")
    expected_audiences = {"api://" + inputs["gatewayApiClientId"], inputs["desktopClientId"]}
    require({item.findtext("audiences/audience") for item in validators} == expected_audiences,
            "Policy audiences differ from the approved application registrations.")
    for item in validators:
        require(item.findtext("required-claims/claim[@name='tid']/value") == inputs["tenantId"],
                "Policy tenant differs from the approved tenant.")
        require(item.findtext("required-claims/claim[@name='roles']/value") == "Gateway.Invoke",
                "Both validators must require Gateway.Invoke.")
    require(policy.find("backend/forward-request").get("buffer-response") == "false",
            "Streaming must not buffer the response.")
    require(policy.find(".//authentication-managed-identity").get("resource")
            == inputs["backendTokenResource"], "Policy backend audience differs from inputs.")
    for name in ("get-entra-token.sh", "get-entra-token.ps1"):
        require(inputs["tenantId"] in texts[name] and inputs["gatewayApiClientId"] in texts[name],
                f"{name}: tenant or audience differs from inputs.")

    account = azure("account", "show")
    require(account["id"] == inputs["approvedSubscription"]
            and account["tenantId"] == inputs["tenantId"],
            "Azure CLI subscription or tenant differs from the approved target scope.")
    apim = azure("apim", "show", "--resource-group", inputs["apimResourceGroup"],
                 "--name", inputs["apimName"])
    require(apim["sku"]["name"] in ("BasicV2", "StandardV2", "PremiumV2"),
            "Native Anthropic token policies require an APIM v2 tier.")
    identity = apim.get("identity") or {}
    principal = identity.get("principalId")
    require(principal and "SystemAssigned" in identity.get("type", ""),
            "APIM needs a system-assigned managed identity.")
    foundry = azure("cognitiveservices", "account", "show", "--resource-group",
                    inputs["foundryResourceGroup"], "--name", inputs["foundryName"])
    roles = azure("role", "assignment", "list", "--scope", foundry["id"])
    require(any(role["roleDefinitionName"] == inputs["foundryRole"]
                and role["principalId"] == principal
                and role["scope"].lower() == foundry["id"].lower() for role in roles),
            "Assign Cognitive Services User directly to APIM at the Foundry resource.")
    deployments = azure("cognitiveservices", "account", "deployment", "list",
                        "--resource-group", inputs["foundryResourceGroup"],
                        "--name", inputs["foundryName"])
    live_models = {item["name"] for item in deployments
                   if item["properties"]["provisioningState"] == "Succeeded"}
    require(models <= live_models, "A configured model deployment is missing or not Succeeded.")
    print(f"PASS: approved target scope {apim['id']}")
    print("PASS: v2 tier, managed identity, Foundry resource role, deployment names, and files.")
    print("No service state changed. Portal policy changes have no ARM what-if preview.")
    print("Review inherited policies and the portal effective policy before saving.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--artifacts-dir", type=Path, required=True)
    args = parser.parse_args()
    try:
        check(args.artifacts_dir)
    except subprocess.CalledProcessError as error:
        print(f"Preflight failed: Azure CLI returned {error.returncode}.\n{error.stderr}",
              file=sys.stderr)
        return 1
    except (ValueError, KeyError, TypeError, AttributeError, OSError, ET.ParseError) as error:
        print(f"Preflight failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
